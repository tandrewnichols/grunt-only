sinon = require 'sinon'
fs = require 'fs'
chalk = require 'chalk'

describe 'only', ->
  Given -> @only = require '../tasks/only'
  afterEach -> fs.readFile.restore()
  Given -> sinon.stub fs, 'readFile'
  Given -> @grunt =
    registerMultiTask: sinon.stub()
    file:
      expand: sinon.stub()
    log:
      writeln: sinon.stub()
      ok: sinon.stub()
    fail:
      fatal: sinon.stub()
  Given -> @context =
    options: (obj) -> obj
    async: sinon.stub()
    files: [
      src: 'foo/bar.coffee'
    ]
  Given -> @done = sinon.stub()
  Given -> @context.async.returns @done
  Given -> @grunt.registerMultiTask.withArgs('only', 'Fail builds in which .only was left on a test context', sinon.match.func).callsArgOn(2, @context)

  context 'files specified', ->
    context 'no onlys', ->
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'foo bar baz'
      When -> @only @grunt
      Then -> @done.should.have.been.called
      And -> @grunt.fail.fatal.called.should.be.false()
      And -> @grunt.log.writeln.called.should.be.false()
      And -> @grunt.log.ok.should.have.been.calledWith "1 file #{chalk.cyan('.only')} free"

    context '1 only', ->
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'foo\ncontext.only\nbar'
      Given -> @colon = chalk.cyan(':')
      When -> @only @grunt
      Then -> @grunt.fail.fatal.should.have.been.calledWith 'Some tests in your code are disabled'
      And -> @grunt.log.writeln.should.have.been.calledWith chalk.red('1 instance of only found in your tests.')
      And -> @grunt.log.writeln.should.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('2') + @colon, ' ', 'context.only'

    context 'more than 1 only', ->
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'describe.only\ncontext.only\nit.only'
      Given -> @colon = chalk.cyan(':')
      When -> @only @grunt
      Then -> @grunt.fail.fatal.should.have.been.calledWith 'Some tests in your code are disabled'
      And -> @grunt.log.writeln.should.have.been.calledWith chalk.red('3 instances of only found in your tests.')
      And -> @grunt.log.writeln.should.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('1') + @colon, ' ', 'describe.only'
      And -> @grunt.log.writeln.should.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('2') + @colon, ' ', 'context.only'
      And -> @grunt.log.writeln.should.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('3') + @colon, ' ', 'it.only'

    context 'no fail', ->
      Given -> @context.options = (obj) ->
        obj.fail = false
        obj
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'foo\ncontext.only\nbar'
      Given -> @colon = chalk.cyan(':')
      When -> @only @grunt
      Then -> @grunt.fail.fatal.called.should.be.false()
      And -> @grunt.log.writeln.should.have.been.calledWith chalk.red('1 instance of only found in your tests.')
      And -> @grunt.log.writeln.should.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('2') + @colon, ' ', 'context.only'

  context 'no files specified', ->
    context 'without dynamic set', ->
      Given -> @context.files = []
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'describe.only\ncontext.only\nit.only'
      Given -> @colon = chalk.cyan(':')
      Given -> @grunt.file.expand.returns ['hello/world.js']
      When -> @only @grunt
      Then -> @grunt.file.expand.should.have.been.calledWith ['test/**/*.{js,coffee}', 'spec/**/*.{js,coffee}']

    context 'with dynamic set', ->
      Given -> @context.files = []
      Given -> @context.options = (obj) ->
        obj.dynamic = true
        obj
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'describe.only\ncontext.only\nit.only'
      Given -> @colon = chalk.cyan(':')
      When -> @only @grunt
      Then -> @grunt.file.expand.called.should.be.false()

  context 'exports its patterns', ->
    Then -> @only.patterns.should.eql ['describe\\.only', 'context\\.only', 'it\\.only', 'Then\\.only', 'iit', 'ddescribe', 'fdescribe']
