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
				@deleted = false
				@roles = []
				@copied = false
				params.each do |name, value|
					self.send( "#{name}=", value )
				end
				yield if block_given?
			end
			def initialize_copy( _original )
				@copied = true
			end
			attr_accessor :name, :login, :email, :roles
			def save; @saved = true; end
			def saved?; @saved; end
			def copied?; @copied; end
			def bizarroify
				self.name = "Bizarro #{self.name}"
				self.email = "bizarro+#{self.email}"
				self.login = "__#{self.login}__"
				self
			end
			def delete; @deleted = true; end
			def deleted?; @deleted; end
			def add_role( role )
				raise "not saved" unless self.saved?
				self.roles << role
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


	it "sets attributes on the object when #instance is passed hash arguments" do
		object = factory.instance( name: 'Dan', login: 'danp', email: 'danp@example.com' )

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Dan' )
		expect( object.login ).to eq( 'danp' )
		expect( object.email ).to eq( 'danp@example.com' )
		expect( object ).to_not be_saved
	end


	it "sets attributes on the object when #instance is passed a Hash" do
		values = { name: 'Dan', login: 'danp', email: 'danp@example.com' }
		object = factory.instance( values )

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Dan' )
		expect( object.login ).to eq( 'danp' )
		expect( object.email ).to eq( 'danp@example.com' )
		expect( object ).to_not be_saved
	end


	it "raises an argument when #instance is passed something that doesn't #each_pair" do
		expect {
			factory.instance( [:missiles, :weasels] )
		}.to raise_error( NoMethodError, /each_pair/i )
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


	it "sets attributes before saving when #create is passed a Hash" do
		object = factory.create( name: 'Jenn', login: 'jennnn', email: 'jennnn@allthejennifers.org' )

		expect( object ).to be_a( fixtured_class )
		expect( object.name ).to eq( 'Jenn' )
		expect( object.login ).to eq( 'jennnn' )
		expect( object.email ).to eq( 'jennnn@allthejennifers.org' )
		expect( object ).to be_saved
	end


	it "raises an argument when #create is passed something that doesn't #each_pair" do
		expect {
			factory.create( [:chocolate, :darkroom] )
		}.to raise_error( NoMethodError, /each_pair/i )
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


	it "calls its fixture module's #call_after_saving method after creating if it implements it" do
		def fixture_module.call_after_saving( instance )
			instance.delete
			instance
		end

		result = factory.create

		expect( result ).to be_an_instance_of( fixtured_class )
		expect( result ).to be_deleted
	end


	it "supports decorators that save the object before running" do
		fixture_module.decorator( :with_role, presave: true ) do |role|
			self.add_role( role )
		end

		object = factory.with_role( 'admin' ).instance

		expect( object ).to be_saved
		expect( object.roles ).to include( 'admin' )
	end


	it "calls pre- and post-save hooks for decorators with presaving" do
		fixture_module.decorator( :with_role, presave: true ) do |role|
			self.add_role( role )
		end
		def fixture_module.call_before_saving( instance )
			instance.dup
		end
		def fixture_module.call_after_saving( instance )
			instance.delete
			instance
		end

		object = factory.with_role( 'admin' ).instance

		expect( object ).to be_saved
		expect( object ).to be_copied
		expect( object ).to be_deleted
		expect( object.roles ).to include( 'admin' )
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


	describe "enumerator/generator" do

		it "is Enumerable" do
			expect( factory ).to be_an( Enumerable )
			expect( factory.each ).to be_an( Enumerator )
		end


		it "can create an enumerator (generator) of unsaved instances" do
			enum = factory.generator

			expect( enum ).to be_a( Enumerator )

			instance = enum.next

			expect( instance ).to be_a( fixtured_class )
			expect( instance ).to_not be_saved
		end


		it "can create an enumerator (generator) of saved instances" do
			enum = factory.generator( create: true )

			expect( enum ).to be_a( Enumerator )

			instance = enum.next

			expect( instance ).to be_a( fixtured_class )
			expect( instance ).to be_saved
		end


		it "is a limited generator by default" do
			enum = factory.generator
			expect( enum.size ).to eq( described_class::DEFAULT_GENERATOR_LIMIT )
		end


		it "can be limited to a different size" do
			enum = factory.generator( limit: 5 )
			expect( enum.size ).to eq( 5 )
			expect( enum.to_a ).to be_an( Array ).and( have_attributes(length: 5) )
		end


		it "can be created as an infinite generator" do
			enum = factory.generator( limit: nil )
			expect( enum.size ).to eq( Float::INFINITY )
		end


		it "yields each new object and the index to a block passed to the generator" do
			enum = factory.generator do |i, obj|
				obj.email = "user#{i}@example.com"
			end

			instances = enum.take( 5 )

			expect( instances[0].email ).to eq( 'user0@example.com' )
			expect( instances[1].email ).to eq( 'user1@example.com' )
			expect( instances[2].email ).to eq( 'user2@example.com' )
			expect( instances[3].email ).to eq( 'user3@example.com' )
			expect( instances[4].email ).to eq( 'user4@example.com' )
		end

	end


	describe "composed decorators" do

		it "applies a single-decorator prelude before running" do
			fixture_module.decorator( :with_anonymized_email ) { self.email = 'xxx@xxx.xxx' }
			fixture_module.decorator( :with_anonymized_login ) { self.login = 'xxxxxxx' }
			fixture_module.compose( :anonymized => :with_anonymized_email ) do
				self.name = 'Xxxx Xxxxxxxxx'
			end

			object = factory.anonymized.instance

			expect( object.name ).to eq( 'Xxxx Xxxxxxxxx' )
			expect( object.email ).to eq( 'xxx@xxx.xxx' )
			expect( object.login ).to_not eq( 'xxxxxxx' )
		end


		it "applies a multi-decorator prelude before running" do
			fixture_module.decorator( :with_anonymized_email ) { self.email = 'xxx@xxx.xxx' }
			fixture_module.decorator( :with_anonymized_login ) { self.login = 'xxxxxxx' }
			fixture_module.compose( :anonymized => [:with_anonymized_email, :with_anonymized_login] ) do
				self.name = 'Xxxx Xxxxxxxxx'
			end

			object = factory.anonymized.instance

			expect( object.name ).to eq( 'Xxxx Xxxxxxxxx' )
			expect( object.email ).to eq( 'xxx@xxx.xxx' )
			expect( object.login ).to eq( 'xxxxxxx' )
		end


		it "applies a decorator prelude with arguments before running" do
			fixture_module.decorator( :with_anonymized_email ) do |base_email='xxx@xxxx.com'|
				self.email = base_email.gsub(/\w/, 'x')
			end
			fixture_module.compose( :anonymized => {with_anonymized_email: 'thomas.dalton@example.com'} ) do
				self.name = 'Xxxx Xxxxxxxxx'
			end

			object = factory.anonymized.instance

			expect( object.name ).to eq( 'Xxxx Xxxxxxxxx' )
			expect( object.email ).to eq( 'xxxxxx.xxxxxx@xxxxxxx.xxx' )
		end


		it "raises a useful error if composed from a non-existent fixture" do
			fixture_module.compose( :anonymized => :with_anonymized_email ) do
				self.name = 'Xxxx Xxxxxxxxx'
			end

			expect {
				factory.anonymized.instance
			}.to raise_error( /non-existent fixture `with_anonymized_email`/i )
		end

	end

end

