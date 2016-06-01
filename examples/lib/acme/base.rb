# -*- ruby -*-
#encoding: utf-8

require 'acme' unless defined?( Acme )


class Acme::Base

	# Fancy database simulator
	DATASTORE = Hash.new do |h, modelclass|
		h[ modelclass ] = {}
	end
	SERIAL_GENERATOR = Hash.new do |h, modelclass|
		h[ modelclass ] = Enumerator.new do |yielder|
			i = 0
			loop { i += 1; yielder.yield(i) }
		end
	end


	def initialize( params={} )
		params.each do |name, value|
			self.send( "#{name}=", value )
		end
	end


	attr_accessor :id


	def save
		self.id ||= SERIAL_GENERATOR[ self.class ].next
		DATASTORE[ self.class ][ self.id ] = self
	end


	def saved?
		return self.id && DATASTORE[ self.class ].key?( self.id )
	end

end

