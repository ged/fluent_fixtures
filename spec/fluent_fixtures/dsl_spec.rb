#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'fluent_fixtures/dsl'
require 'faker'


RSpec.describe FluentFixtures::DSL do

	let( :collection ) { Module.new {extend FluentFixtures::Collection} }

	let( :fixtured_class ) do
		Class.new do
			def initialize( params={} )
				@saved = false
				@friends = []
				params.each do |name, value|
					self.send( "#{name}=", value )
				end
			end
			attr_accessor :name, :login, :email, :friends
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
			self.email ||= Faker::Internet.email( name: self.login )
		end
		mod
	end


	it "can load other fixtures it depends on" do
		expect( collection ).to receive( :load ).with( :lovers, :tyrants, :kings )
		fixture_module.depends_on( :lovers, :tyrants, :kings )
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


	it "can indicate that an object needs to be saved before a decorator is applied" do
		with_associated_object_block = Proc.new  {|obj| self.associated_object = obj }
		fixture_module.decorator( :with_associated_object, presave: true, &with_associated_object_block )

		expect( fixture_module ).to have_decorator( :with_associated_object )

		expect( fixture_module.decorators[:with_associated_object] ).to be( with_associated_object_block )
		expect( fixture_module.decorator_options[:with_associated_object] ).to include( presave: true )
	end


	it "can declare an alias for an already-declared decorator" do
		fixture_module.decorator( :with_no_email ) { self.email = nil }
		fixture_module.alias_decorator( :emailless, :with_no_email )

		expect( fixture_module ).to have_decorator( :with_no_email )
		expect( fixture_module ).to have_decorator( :emailless )
	end


	it "copies options of aliased decorators" do
		fixture_module.decorator( :with_renters, presave: true ) do |*renters|
			renters.each {|r| self.add(r) }
		end
		fixture_module.alias_decorator( :renters, :with_renters )

		expect( fixture_module.decorator_options[:with_renters] ).to include( presave: true )
		expect( fixture_module.decorator_options[:renters] ).to include( presave: true )
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


	it "can declare composed decorators" do
		fixture_module.decorator( :with_first_name ) { self.first_name = 'Mark' }
		fixture_module.decorator( :with_last_name ) { self.last_name = 'Walberg' }
		fixture_module.decorator( :with_friends ) do
			self.friends = [ 'Scott Ross', 'Hector Barros', 'Terry Yancey', 'Anothony Thomas' ]
		end

		fixture_module.compose( :marky_mark => [:with_first_name, :with_last_name, :with_friends] )

		expect( fixture_module ).to have_decorator( :marky_mark )
		expect( fixture_module.decorator_options[:marky_mark] ).
			to include( prelude: [:with_first_name, :with_last_name, :with_friends] )
	end


	it "can extend an existing fixture with more decorators" do
		collection.modules[ :tyrant ] = fixture_module

		mod = Module.new do
			def self::name ; "FixtureAdditionTests"; end
		end

		mod.extend( collection )
		mod.additions_for( :tyrant ) do
			decorator :despotic do
				self.authority = :absolute
			end
		end

		expect( fixture_module ).to have_decorator( :despotic )
	end


	it "can add a dependency via an extension" do
		expect( collection ).to receive( :load ) do |*args|
			expect( args ).to eq([ :tyrants ])
			collection.modules[ :tyrant ] = fixture_module
		end

		mod = Module.new do
			def self::name ; "FixtureAdditionTests"; end
		end

		mod.extend( collection )
		mod.additions_for( :tyrant, depends_on: :tyrants ) do
			decorator :despotic do
				self.authority = :absolute
			end
		end

		expect( fixture_module ).to have_decorator( :despotic )
	end

end

