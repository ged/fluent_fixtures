# -*- ruby -*-
#encoding: utf-8

require 'faker'
require 'acme/fixtures'
require 'acme/group'

module Acme::Fixtures::Groups
	extend Acme::Fixtures
	fixtured_class Acme::Group
end

