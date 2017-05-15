# -*- ruby -*-
#encoding: utf-8
# frozen_string_literal: true

require 'loggability'


# Fluent fixtures
module FluentFixtures
	extend Loggability


	# Package version
	VERSION = '0.5.0'

	# Version control revision
	REVISION = %q$Revision$


	# Loggability API -- set up a named logger
	log_as :fluent_fixtures


	require 'fluent_fixtures/collection'
	require 'fluent_fixtures/dsl'
	require 'fluent_fixtures/factory'

end # module FluentFixtures

