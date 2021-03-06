const _ = require('lodash');
const async = require('async');
const fs = require('fs');
const chalk = require('chalk');

module.exports = function(grunt) {
  grunt.registerMultiTask('only', require('../package').description, function() {
    var done = this.async();

    var options = this.options({
      patterns: module.exports.patterns,
      fail: true,
      dynamic: false
    });

    var regex = new RegExp(options.patterns.join('|'), 'g');

    var files = _.reduce(this.files, function(memo, file) {
      return memo.concat(file.src);
    }, []);

    if (!files.length && !options.dynamic) {
      files = grunt.file.expand([ 'test/**/*.{js,coffee}', 'spec/**/*.{js,coffee}' ]);
    }

    async.reduce(files, [], function(memo, file, next) {
      fs.readFile(file, { encoding: 'utf8' }, function(err, contents) {
        if (!regex.test(contents)) {
          next(null, memo);
        } else {
          // regex.test advances the search index, so we need to reset it
          regex.lastIndex = 0;
          var match;
          while ((match = regex.exec(contents)) !== null) {
            memo.push({
              file: file,
              line: contents.substring(0, match.index).split('\n').length,
              match: match[0]
            });
          }
          next(null, memo);
        }
      });
    }, function(err, results) {
      if (results.length) {
        var instance = `instance${results.length > 1 ? 's' : ''}`;
        grunt.log.writeln(chalk.red(`${results.length} ${instance} of only found in your tests.`));
        var colon = chalk.cyan(':');
        results.forEach(function(result) {
          grunt.log.writeln('  ', chalk.magenta(result.file) + colon + chalk.green(result.line) + colon, ' ', result.match);
        });
        grunt.log.writeln();
        if (options.fail) {
          grunt.fail.fatal('Some tests in your code are disabled');
        }
      } else {
        var fileLength = `file${files.length === 1 ? '' : 's'}`;
        grunt.log.ok(`${files.length} ${fileLength} ${chalk.cyan('.only')} free`);
      }
      done();
    });
  });
};

module.exports.patterns = [ 'describe\\.only', 'context\\.only', 'it\\.only', 'Then\\.only', 'iit', 'ddescribe', 'fdescribe' ];
