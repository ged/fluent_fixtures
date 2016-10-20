# -*- ruby -*-
#encoding: utf-8

require 'sequel'

module Acme

	DB = Sequel.postgres( 'acme' )

	Sequel::Model.plugin :validation_helpers
	Sequel::Model.plugin :auto_validations, not_null: :presence

	autoload :Customer, 'acme/customer'
	autoload :Order, 'acme/order'
	autoload :OrderItem, 'acme/order_item'

end

