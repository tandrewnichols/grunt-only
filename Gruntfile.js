module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-open');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-mocha-cov');
  grunt.loadNpmTasks('grunt-travis-matrix');
  grunt.loadTasks('./tasks');

  grunt.initConfig({
    clean: {
      coverage: 'coverage'
    },
    jshint: {
      options: {
        reporter: require('jshint-stylish'),
        eqeqeq: true,
        es3: true,
        indent: 2,
        newcap: true,
        quotmark: 'single',
        boss: true
      },
      all: ['tasks/**/*.js']
    },
    mochaTest: {
      options: {
        reporter: 'spec',
        ui: 'mocha-given',
        require: 'coffee-script/register'
      },
      test: {
        src: ['test/**/*.coffee']
      }
    },
    mochacov: {
      lcov: {
        options: {
          reporter: 'mocha-lcov-reporter',
          ui: 'mocha-given',
          instrument: true,
          require: 'coffee-script/register',
          output: 'coverage/coverage.lcov'
        },
        src: ['test/**/*.coffee'],
      },
      html: {
        options: {
          reporter: 'html-cov',
          ui: 'mocha-given',
          require: 'coffee-script/register',
          output: 'coverage/coverage.html'
        },
        src: ['test/**/*.coffee']
      }
    },
    open: {
      coverage: {
        path: 'coverage/coverage.html'
      }
    },
    travis: {
      options: {
        targets: {
          test: '{{ version }}',
          when: 'v0.12',
          tasks: ['mochacov:lcov', 'matrix:v0.12']
        }
      }
    },
    matrix: {
      'v0.12': 'codeclimate-test-reporter < coverage/coverage.lcov'
    },
    watch: {
      tests: {
        files: ['tasks/**/*.js', 'test/**/*.coffee'],
        tasks: ['mocha'],
        options: {
          atBegin: true
        }
      }
    },
    only: {
      test: {
        src: ['test/**/*.coffee']
      }
    }
  });

  grunt.registerTask('mocha', ['mochaTest:test']);
  grunt.registerTask('default', ['jshint:all', 'mocha']);
  grunt.registerTask('coverage', ['mochacov:html']);
  grunt.registerTask('ci', ['jshint:all', 'mocha', 'travis']);
};
