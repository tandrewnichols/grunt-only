[![Build Status](https://travis-ci.org/tandrewnichols/grunt-only.png)](https://travis-ci.org/tandrewnichols/grunt-only) [![downloads](http://img.shields.io/npm/dm/grunt-only.svg)](https://npmjs.org/package/grunt-only) [![npm](http://img.shields.io/npm/v/grunt-only.svg)](https://npmjs.org/package/grunt-only) [![Code Climate](https://codeclimate.com/github/tandrewnichols/grunt-only/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/grunt-only) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/grunt-only/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/grunt-only) [![dependencies](https://david-dm.org/tandrewnichols/grunt-only.png)](https://david-dm.org/tandrewnichols/grunt-only)

# grunt-only

Fail builds in which .only was left on a test context

## Getting Started

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```bash
npm install grunt-only --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```javascript
grunt.loadNpmTasks('grunt-only');
```

Alternatively, install [task-master](http://github.com/tandrewnichols/task-master) and let it manage this for you.

## The "only" task

Many testrunners support the concept of exclusivity flags to run a subset of tests in a suite, often by marking the test context with `.only`. Everything is not awesome when you accidentally forget to remove one of these flags before committing, however. Everything passed in travis, so . . . we're good to go right? Wrong. Turns out you only ran 3 of your 900 tests and possibly stuff is broken, and you just don't know about it. That's what `grunt-only` was created to fix. Add this to your travis build to fail a build that contains a `.only` on a test context, and never worry about merging unsafe code again.

### Overview

In your project's Gruntfile, add a section named `only` to the data object passed into `grunt.initConfig()`. Again, I recommend [task-master](https://github.com/tandrewnichols/task-master) as it makes grunt configuration much cleaner. By default, `grunt-only` will look for a number of common exclusivity patterns in files matching `test/**/*.{js,coffee}` and `spec/**/*.{js,coffee}`, so it's possible you won't need any configuration at all.

```javascript
grunt.initConfig({
  only: {
    tests: {} // Look mom! The defaults are fine!
  }
});
```

If you do need to configure things, you can tell `grunt-only` where to look for test files using the normal grunt file mechanisms (noting that concepts like `dest` have no meaning for this plugin). You can also add `patterns` to options if you are using a testrunner that has a different mechanism for test exclusivity, and you can also turn off automatic test failure under options (for instance, if you just want to notify developers of their error without infringing upon their wild abandon).

```javascript
grunt.initConfig({
  only: {
    dev: {
      src: ['spec/**/*.coffee', 'spec-e2e/**/*.coffee'],
      options: {
        fail: false,
        patterns: ['describe.exclusive'] // Totally made up . . . AFAIK, there is no runner that uses this
      }
    },
    ci: {
      src: ['spec/**/*.coffee', 'spec-e2e/**/*.coffee'],
      options: {
        // No need for "fail: true" as that's the default
        patterns: ['describe.exclusive']
      }
    }
  }
});
```

If you are updating src files on the fly, i.e. when using this task in combination with something like grunt-newer or as part of a git hook, you can tell grunt-only not to use the default files (typically, it uses some sane defaults when it is run with no files). Just add the `dynamic` option.

```javascript
grunt.initConfig({
  only: {
    tests: {
      options: {
        dynamic: true
      },
      src: [] // Or omit this altogether
    }
  }
});
```

Note that the list of patterns is somewhat long and the "search" is performed via regex with a series of ors, which might not be performant in large code bases. In such cases, you may want to include your own list of patterns, even if they are in the default list, so that you're not wasting resources looking for patterns you don't use.

Additionally, this library exposes it's pattern list, so if you just want to add to the existing list, you can do so:

```javascript
var patterns = require('grunt-only').patterns.concat(['describe.foo', 'context.bar']);
```

The full list of patterns exposed is: describe.only, context.only, it.only, Then.only, iit, ddescribe, and fdescribe.

## A note on jasmine.

Jasmine 2.1 supports "focused specs" (which are exclusivity tests). See [here](http://jasmine.github.io/2.1/focused_specs.html). Unfortunately, they use `fit` to denote a "focused it." I have not added `fit` to the default list of patterns because that seems like a combination of characters that might come up in other instances and could, therefore, throw false negatives. If you're using jasmine 2.1 and `fit`, you can add it to the patterns via the methods above (at your own peril), or (recommended) redefine it in some global helper that runs prior to all tests. Something like `global.focusit = global.fit`. I realize this is inconvenient but what can you do.

## Contributing

Please see [the contribution guidelines](CONTRIBUTING.md).
