#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'fluent_fixtures/dsl'
require 'faker'


describe FluentFixtures::DSL do

	let( :collection ) { Module.new {extend FluentFixtures::Collection} }

	let( :fixtured_class ) do
		Class.new do
			def initialize( params={} )
				@saved = false
				params.each do |name, value|
					self.send( "#{name}=", value )
				end
			end
			attr_accessor :name, :login, :email
			def save; @saved = true; end
			def saved?; @saved; end
			def bizarroify
				self.name = "Bizarro #{self.name}"
				self.email = "bizarro+#{self.email}"
				self.login = "__#{self.login}__"
				self
			end
		end
	end


	let!( :fixture_module ) do
		mod = Module.new do
			def self::name ; "UsageTests"; end
		end
		mod.extend( collection )
		mod.fixtured_class( fixtured_class )
		mod.base( :fixture ) do
			self.name  ||= Faker::Name.name
			self.login ||= Faker::Internet.user_name
			self.email ||= Faker::Internet.email( self.login )
		end
		mod
	end


	it "allows the declaration of decorator blocks" do
		no_email_block = Proc.new { self.email = nil }
		fixture_module.decorator( :with_no_email, &no_email_block )
		no_login_block = Proc.new  { self.login = nil }
		fixture_module.decorator( :with_no_login, &no_login_block )

		expect( fixture_module ).to have_decorator( :with_no_email )
		expect( fixture_module ).to have_decorator( :with_no_login )

		expect( fixture_module.decorators[:with_no_email] ).to be( no_email_block )
		expect( fixture_module.decorators[:with_no_login] ).to be( no_login_block )
	end


	it "can register a before-creation hook to allow for unusual models" do
		expect {
			fixture_module.before_saving do |obj|
				obj
			end
		}.to change { fixture_module.respond_to?(:call_before_saving) }.
			from( false ).to( true )
	end


	it "can register an after-creation hook to allow for unusual models" do
		expect {
			fixture_module.after_saving do |obj|
				obj
			end
		}.to change { fixture_module.respond_to?(:call_after_saving) }.
			from( false ).to( true )
	end


	it "can declare an alias for an already-declared decorator" do
		fixture_module.decorator( :with_no_email ) { self.email = nil }
		fixture_module.alias_decorator( :emailless, :with_no_email )

		expect( fixture_module ).to have_decorator( :with_no_email )
		expect( fixture_module ).to have_decorator( :emailless )
	end


	it "raises an error when an alias for a non-existent decorator is declared" do
		expect {
			fixture_module.alias_decorator( :an_alias, :nonexistent_decorator )
		}.to raise_error( ScriptError, /undefined decorator.*nonexistent_decorator/ )
	end


	it "constructs the factory with the arguments passed to the base fixture" do
		args = { name: 'Phil', login: 'phil', email: 'phil@phil.org' }

		factory = collection.fixture( args )

		expect( factory.constructor_args ).to eq([ args ])
	end


	it "constructs the factory with a block passed to the base fixture" do
		block = Proc.new { self.tie = true }

		factory = collection.fixture( &block )

		expect( factory.constructor_block ).to eq( block )
	end


end

