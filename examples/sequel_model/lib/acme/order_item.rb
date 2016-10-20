# -*- ruby -*-
#encoding: utf-8

require 'sequel/model'

require 'acme' unless defined?( Acme )

class Acme::OrderItem < Sequel::Model( :acme__order_items )

	many_to_one :order

end

