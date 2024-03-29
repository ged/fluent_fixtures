# Release History for fluent_fixtures

---
## v0.11.0 [2023-05-09] Michael Granger <ged@faeriemud.org>

Enhancements:

- Test under Ruby 3.2
- Update gem-signing cert, dependencies


## v0.10.0 [2022-04-10] Michael Granger <ged@faeriemud.org>

Enhancements:

- Fix keyword argument decorators in Ruby 3.0. Thanks to rob.galanakis@gmail.com for the patch.


## v0.9.0 [2020-11-02] Michael Granger <ged@FaerieMUD.org>

Improvements:

- De-hoeify
- Update the Sequel example's bundle
- Bump Faker version to latest, fix usage
- Update for Ruby 2.7
- Update project links (bitbucket -> sr.ht)

Bugfixes:

- Fix passing keywords as trailing hash


## v0.8.1 [2018-11-20] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Make dependencies explicit in `additions_for`.
  This fixes the case where the base fixture is not named the same
  thing as the file that it is defined in. You can now explicitly
  depend on another fixture file with the `depends_on` keyword
  argument to `additions_for`.


## v0.8.0 [2018-08-28] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add syntax for adding decorators to already-existing fixtures


## v0.7.0 [2018-06-12] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add composed decorators
- Raise a more-informative error when invoking a non-existent fixture.


## v0.6.1 [2017-10-30] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Make decorator aliases use the same options as the original


##  v0.6.0 [2017-06-26] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add support for mutator blocks to factory generators.

Documentation:

- Added the beginnings of API docs.


##  v0.5.0 [2017-05-12] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add a `presave` option for decorators that need a saved instance.


## v0.4.0 [2016-12-13] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Added `depends_on` to the fixture DSL.


## v0.3.0 [2016-11-26] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Make the factory Enumerable and add a #generator method.


## v0.2.0 [2016-10-28] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Fix the way #create and #instance handle their arguments. Arguments are
  now iterated over and used to set attributes instead of just being
  discarded.


## v0.1.0 [2016-10-28] Michael Granger <ged@FaerieMUD.org>

New feature:

- Add an after-save hook and a declaration for it.


## v0.0.2 [2016-06-01] Michael Granger <ged@FaerieMUD.org>

Remove the release failsafe from the Rakefile


## v0.0.1 [2016-06-01] Michael Granger <ged@FaerieMUD.org>

Initial release.

