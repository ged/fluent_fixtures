# -*- ruby -*-
#encoding: utf-8

require 'fluent_fixtures'
require 'acme' unless defined?( Acme )

module Acme::Fixtures
	extend FluentFixtures::Collection

	fixture_path_prefix 'acme/fixtures'

end

