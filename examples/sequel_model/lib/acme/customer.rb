# -*- ruby -*-
#encoding: utf-8

require 'sequel/model'

require 'acme' unless defined?( Acme )


class Acme::Customer < Sequel::Model( :acme__customers )

	one_to_many :orders

end

