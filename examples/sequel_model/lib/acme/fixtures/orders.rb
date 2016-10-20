# -*- ruby -*-
#encoding: utf-8

require 'faker'
require 'acme/fixtures'
require 'acme/order'

module Acme::Fixtures::Orders
	extend Acme::Fixtures
	fixtured_class Acme::Order
end

