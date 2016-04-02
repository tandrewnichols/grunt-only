sinon = require 'sinon'
expect = require('indeed').expect
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
      Then -> expect(@done).to.have.been.called
      And -> expect(@grunt.fail.fatal.called).to.be.false()
      And -> expect(@grunt.log.writeln.called).to.be.false()
      And -> expect(@grunt.log.ok).to.have.been.calledWith "1 file #{chalk.cyan('.only')} free"

    context '1 only', ->
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'foo\ncontext.only\nbar'
      Given -> @colon = chalk.cyan(':')
      When -> @only @grunt
      Then -> expect(@grunt.fail.fatal).to.have.been.calledWith 'Some tests in your code are disabled'
      And -> expect(@grunt.log.writeln).to.have.been.calledWith chalk.red('1 instance of only found in your tests.')
      And -> expect(@grunt.log.writeln).to.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('2') + @colon, ' ', 'context.only'

    context 'more than 1 only', ->
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'describe.only\ncontext.only\nit.only'
      Given -> @colon = chalk.cyan(':')
      When -> @only @grunt
      Then -> expect(@grunt.fail.fatal).to.have.been.calledWith 'Some tests in your code are disabled'
      And -> expect(@grunt.log.writeln).to.have.been.calledWith chalk.red('3 instances of only found in your tests.')
      And -> expect(@grunt.log.writeln).to.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('1') + @colon, ' ', 'describe.only'
      And -> expect(@grunt.log.writeln).to.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('2') + @colon, ' ', 'context.only'
      And -> expect(@grunt.log.writeln).to.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('3') + @colon, ' ', 'it.only'

    context 'no fail', ->
      Given -> @context.options = (obj) ->
        obj.fail = false
        obj
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'foo\ncontext.only\nbar'
      Given -> @colon = chalk.cyan(':')
      When -> @only @grunt
      Then -> expect(@grunt.fail.fatal.called).to.be.false()
      And -> expect(@grunt.log.writeln).to.have.been.calledWith chalk.red('1 instance of only found in your tests.')
      And -> expect(@grunt.log.writeln).to.have.been.calledWith '  ', chalk.magenta('foo/bar.coffee') + @colon + chalk.green('2') + @colon, ' ', 'context.only'

  context 'no files specified', ->
    context 'without dynamic set', ->
      Given -> @context.files = []
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'describe.only\ncontext.only\nit.only'
      Given -> @colon = chalk.cyan(':')
      Given -> @grunt.file.expand.returns ['hello/world.js']
      When -> @only @grunt
      Then -> expect(@grunt.file.expand).to.have.been.calledWith ['test/**/*.{js,coffee}', 'spec/**/*.{js,coffee}']

    context 'with dynamic set', ->
      Given -> @context.files = []
      Given -> fs.readFile.withArgs('foo/bar.coffee', { encoding: 'utf8' }, sinon.match.func).callsArgWith 2, null, 'describe.only\ncontext.only\nit.only'
      Given -> @colon = chalk.cyan(':')
      Given -> @grunt.file.expand.returns ['hello/world.js']
      When -> @only @grunt
      Then -> expect(@grunt.file.expand).not.to.have.been.called

  context 'exports its patterns', ->
    Then -> expect(@only.patterns).to.deep.equal ['describe\\.only', 'context\\.only', 'it\\.only', 'Then\\.only', 'iit', 'ddescribe', 'fdescribe']
