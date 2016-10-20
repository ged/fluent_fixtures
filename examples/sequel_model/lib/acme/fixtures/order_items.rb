# -*- ruby -*-
#encoding: utf-8

require 'faker'
require 'acme/fixtures'
require 'acme/order_item'

module Acme::Fixtures::OrderItems
	extend Acme::Fixtures

	fixtured_class Acme::OrderItem

end

