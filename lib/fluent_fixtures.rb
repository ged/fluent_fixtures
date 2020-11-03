# -*- ruby -*-
#encoding: utf-8
# frozen_string_literal: true

require 'loggability'


# A toolkit for building testing objects with a fluent interface.
#
# The three main parts of fluent_fixtures are the Collection extension module,
# the DSL module, and the Factory class.
#
# The Collection is what you extend a Module with when you're setting up a
# collection of fixtures for a particular codebase.
#
# The DSL module contains methods for declaring individual fixtures for a
# Collection.
#
# Factories are the objects that provide the fluent interface set up by the
# decorators that evetually create the fixtured objects.
#
module FluentFixtures
	extend Loggability


	# Package version
	VERSION = '0.8.1'

	# Version control revision
	REVISION = %q$Revision$


	# Loggability API -- set up a named logger
	log_as :fluent_fixtures


	autoload :Collection, 'fluent_fixtures/collection'
	autoload :DSL, 'fluent_fixtures/dsl'
	autoload :Factory, 'fluent_fixtures/factory'

end # module FluentFixtures

