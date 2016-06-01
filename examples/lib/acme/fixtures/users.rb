# -*- ruby -*-
#encoding: utf-8

require 'faker'
require 'acme/fixtures'
require 'acme/user'

module Acme::Fixtures::Users
	extend Acme::Fixtures
	fixtured_class Acme::User

	decorator :with_random_first_name do
		self.first_name = Faker::Name.first_name
	end

	decorator :with_random_last_name do
		self.last_name = Faker::Name.last_name
	end

end

