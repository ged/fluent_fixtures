#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'faker'
require 'fluent_fixtures/factory'


describe FluentFixtures::Factory do

	let( :collection ) { Module.new {extend FluentFixtures::Collection} }

	let( :fixtured_class ) do
		Class.new do
			def initialize( params={} )
				@saved = false
				params.each do |name, value|
					self.send( "#{name}=", value )
				end
				yield if block_given?
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


	let( :fixture_module ) do
		mod = Module.new
		mod.extend( collection )
		mod.fixtured_class( fixtured_class )
		mod.base( :fixture ) do
			self.name  ||= Faker::Name.name
			self.login ||= Faker::Internet.user_name
			self.email ||= Faker::Internet.email( self.login )
		end
		mod
	end


	let( :factory ) { described_class.new(fixture_module) }


	it "can create an unsaved instance of the fixtured class" do
		object = factory.instance
		expect( object ).to be_a( fixtured_class )
		expect( object ).to_not be_saved
	end


	it "can create a saved instance of the fixtured class" do
		object = factory.create
		expect( object ).to be_a( fixtured_class )
		expect( object ).to be_saved
	end


	it "applies the base fixture decorator to all instances" do
		object = factory.instance

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to_not be_nil
		expect( object.login ).to_not be_nil
		expect( object.email ).to_not be_nil
	end


	it "applies named decorators via fluent interface on the factory" do
		fixture_module.decorator( :with_no_email ) { self.email = nil }
		fixture_module.decorator( :with_no_login ) { self.login = nil }

		object = factory.with_no_email.with_no_login.instance

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to_not be_nil
		expect( object.login ).to be_nil
		expect( object.email ).to be_nil
	end


	it "forwards constructor arguments to the class's constructor" do
		factory = described_class.new( fixture_module, name: 'Phil', login: 'phil', email: 'phil@phil.org' )
		object = factory.instance

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Phil' )
		expect( object.login ).to eq( 'phil' )
		expect( object.email ).to eq( 'phil@phil.org' )
		expect( object ).to_not be_saved
	end


	it "forwards a constructor block to the class's constructor" do
		called = false
		factory = described_class.new( fixture_module ) do
			called = true
		end

		expect { factory.instance }.to change { called }.to( true )
	end


	it "executes a block passed to #instance in the context of the new object if it doesn't declare arguments" do
		object = factory.instance do
			self.name = 'Dan'
			self.login = 'danp'
			self.email = 'danp@example.com'
		end

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Dan' )
		expect( object.login ).to eq( 'danp' )
		expect( object.email ).to eq( 'danp@example.com' )
		expect( object ).to_not be_saved
	end


	it "passes the new object to an #instance block if it accepts arguments" do
		object = factory.instance do |instance|
			instance.name = 'Dan'
			instance.login = 'danp'
			instance.email = 'danp@example.com'
		end

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Dan' )
		expect( object.login ).to eq( 'danp' )
		expect( object.email ).to eq( 'danp@example.com' )
		expect( object ).to_not be_saved
	end


	it "executes a block passed to #create in the context of the new object" do
		object = factory.create do
			self.name = 'Jenn'
			self.login = 'jennnn'
			self.email = 'jennnn@allthejennifers.org'
		end

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Jenn' )
		expect( object.login ).to eq( 'jennnn' )
		expect( object.email ).to eq( 'jennnn@allthejennifers.org' )
		expect( object ).to be_saved
	end


	it "passes the new object to a #create block if it accepts arguments" do
		object = factory.create do |instance|
			instance.name = 'Jenn'
			instance.login = 'jennnn'
			instance.email = 'jennnn@allthejennifers.org'
		end

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Jenn' )
		expect( object.login ).to eq( 'jennnn' )
		expect( object.email ).to eq( 'jennnn@allthejennifers.org' )
		expect( object ).to be_saved
	end


	it "allows ad-hoc decorators that call fluent mutator methods on the new object" do
		object = factory.bizarroify.instance

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to start_with( 'Bizarro ')
		expect( object.login ).to match( /\A__.*__\z/ )
		expect( object.email ).to start_with( 'bizarro+' )
		expect( object ).to_not be_saved
	end


	it "supports decorators that take one or more arguments" do
		fixture_module.decorator( :with_email ) do |new_email|
			self.email = new_email
		end

		object = factory.with_email( 'herzepholina@paquisod.org' ).instance

		expect( object ).to be_a( fixtured_class )
		expect( object.email ).to eq( 'herzepholina@paquisod.org' )
		expect( object ).to_not be_saved
	end


	it "calls its fixture module's #call_before_saving method before creating if it implements it" do
		def fixture_module.call_before_saving( instance )
			:not_the_instance
		end

		result = factory.create

		expect( result ).to be( :not_the_instance )
	end


	it "allows ad-hoc decorators declared as inline blocks" do
		counter = 0
		result = factory.decorated_with do |obj|
			counter += 1
		end

		5.times do
			expect {
				result.instance
			}.to change { counter }.by( 1 )
		end
	end


	it "raises when asked for an instance if its fixture module doesn't declare a fixtured class" do
		fixmod = Module.new
		fixmod.extend( collection )
		fixmod.base( :no_fixclass_fixture )

		factory = described_class.new( fixmod )

		expect {
			factory.instance
		}.to raise_error( ScriptError, /#{Regexp.escape fixmod.inspect}/ )
	end



end

