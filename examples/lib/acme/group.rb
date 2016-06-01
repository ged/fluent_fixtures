# -*- ruby -*-
#encoding: utf-8

require 'set'
require 'acme' unless defined?( Acme )
require 'acme/base'


class Acme::Group < Acme::Base

	def initialize( * )
		super
		@members ||= Set.new
	end

	attr_accessor :name, :members

end

