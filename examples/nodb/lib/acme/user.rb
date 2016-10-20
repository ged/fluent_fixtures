# -*- ruby -*-
#encoding: utf-8

require 'set'
require 'acme' unless defined?( Acme )
require 'acme/base'


class Acme::User < Acme::Base

	def initialize( * )
		super
		@roles ||= Set.new
	end

	attr_accessor :first_name, :last_name, :email, :login, :groups

end

