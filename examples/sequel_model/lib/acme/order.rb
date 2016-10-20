# -*- ruby -*-
#encoding: utf-8

require 'sequel/model'

require 'acme' unless defined?( Acme )

class Acme::Order < Sequel::Model( :acme__orders )

	many_to_one :customer, class: 'Acme::User'
	many_to_many :order_items

end

