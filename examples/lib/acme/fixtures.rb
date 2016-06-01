# -*- ruby -*-
#encoding: utf-8

require 'fluent_fixtures'
require 'acme' unless defined?( Acme )

module Acme::Fixtures
	extend FluentFixtures::Collection

	fixture_path_prefix 'acme/fixtures'


	def self::describe
		desc = "%p: %d fixtures loaded" % [ self, self.modules.length ]
		unless self.modules.empty?
			desc << ": %s" % [ self.modules.keys.map(&:to_s).join(', ') ]
		end
		return desc
	end

end

