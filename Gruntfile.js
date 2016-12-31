module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-open');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-travis-matrix');
  grunt.loadNpmTasks('grunt-eslint');
  grunt.loadNpmTasks('grunt-simple-istanbul');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadTasks('./tasks');

  grunt.initConfig({
    clean: {
      coverage: 'coverage'
    },
    mochaTest: {
      options: {
        reporter: 'spec',
        ui: 'mocha-given',
        require: ['should', 'should-sinon', 'coffee-script/register']
      },
      test: {
        src: ['test/**/*.coffee']
      },
      watch: {
        options: {
          reporter: 'dot'
        },
        src: ['test/**/*.coffee']
      }
    },
    open: {
      coverage: {
        path: 'coverage/lcov-report/index.html'
      }
    },
    istanbul: {
      unit: {
        options: {
          root: 'tasks',
          dir: 'coverage',
          simple: {
            cmd: 'cover',
            args: ['grunt', 'mocha'],
            rawArgs: ['--', '--color']
          }
        }
      }
    },
    eslint: {
      lib: {
        options: {
          configFile: '.eslint.json',
          format: 'node_modules/eslint-codeframe-formatter'
        },
        src: ['tasks/**/*.js']
      }
    },
    travisMatrix: {
      v4: {
        test: function() {
          return /^v4/.test(process.version);
        },
        tasks: ['istanbul:unit', 'shell:codeclimate']
      }
    },
    shell: {
      codeclimate: 'npm run codeclimate'
    },
    watch: {
      tests: {
        files: ['tasks/**/*.js', 'test/**/*.coffee'],
        tasks: ['mochaTest:watch'],
        options: {
          atBegin: true
        }
      }
    },
    only: {
      test: {
        options: {
          dynamic: true
        },
        src: []
      }
    }
  });

  grunt.registerTask('mocha', ['mochaTest:test']);
  grunt.registerTask('default', ['eslint:lib', 'mocha']);
  grunt.registerTask('cover', ['clean', 'istanbul:unit', 'open:coverage']);
  grunt.registerTask('ci', ['eslint:lib', 'mocha', 'travisMatrix']);

  // For manually testing that dynamic src assignment works
  grunt.registerTask('dynamic', function() {
    grunt.config.set('only.test.src', []);
  });
};
