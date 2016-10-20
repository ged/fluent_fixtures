# -*- ruby -*-
#encoding: utf-8

require 'faker'
require 'acme/fixtures'
require 'acme/customer'

module Acme::Fixtures::Customers
	extend Acme::Fixtures

	fixtured_class Acme::Customer

	base :customer do
		self.first_name ||= Faker::Name.first_name
		self.last_name ||= Faker::Name.last_name
	end


	decorator :with_random_first_name do
		self.first_name = Faker::Name.first_name
	end

	decorator :with_random_last_name do
		self.last_name = Faker::Name.last_name
	end

end

