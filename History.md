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

