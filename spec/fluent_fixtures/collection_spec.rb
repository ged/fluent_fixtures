#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'fluent_fixtures/collection'


describe FluentFixtures::Collection do

	let( :collection ) do
		mod = Module.new
		mod.extend( described_class )
		mod
	end


	it "registers its fixture modules when they are extended if they have a name" do
		mod = Module.new do
			def self::name; "NamedFixture"; end
		end
		mod.extend( collection )

		expect( collection.modules ).to include( namedfixture: mod )
	end


	it "registers its fixture modules when they declare a base if they are anonymous" do
		mod = Module.new
		mod.extend( collection )

		expect( collection.modules ).to be_empty

		mod.base( :namedfixture )

		expect( collection.modules ).to include( namedfixture: mod )
	end


	it "generates a factory constructor for the fixture when it regsters a base" do
		mod = Module.new
		mod.extend( collection )
		mod.base( :new_fixture )

		expect( collection ).to respond_to( :new_fixture )
		expect( collection.new_fixture ).to be_a( FluentFixtures::Factory )
		expect( collection.new_fixture.fixture_module ).to be( mod )
	end


	it "raises if two base fixtures are registered with the same name" do
		mod1 = Module.new
		mod1.extend( collection )

		mod2 = Module.new
		mod2.extend( collection )

		mod1.base( :base_fixture )

		expect {
			mod2.base( :base_fixture )
		}.to raise_error( ScriptError, /already have a base fixture.*base_fixture/i )
	end


	it "can be reset, removing all of its registered fixture modules and their factory methods" do
		mod1 = Module.new
		mod1.extend( collection )

		mod2 = Module.new
		mod2.extend( collection )

		mod1.base( :fixture1 )
		mod2.base( :fixture2 )

		expect( collection.modules ).to include( fixture1: mod1, fixture2: mod2 )
		expect( collection ).to respond_to( :fixture1 )
		expect( collection ).to respond_to( :fixture2 )

		collection.reset!

		expect( collection.modules ).to be_empty
		expect( collection ).to_not respond_to( :fixture1 )
		expect( collection ).to_not respond_to( :fixture2 )
	end


	it "can load fixtures by name" do
		# Mocking Kernel.require via the class under test
		expect( collection ).to receive( :require ).
			with( "fixtures/foo" ).and_return( false )
		expect( collection ).to receive( :require ).
			with( "fixtures/bar" ).and_return( false )

		collection.load( :foo, :bar )
	end


	it "can load all fixtures" do
		expect( Gem ).to receive( :find_files ).with( "fixtures/*.rb" ).and_return([
			"fixtures/foo.rb",
			"fixtures/bar.rb",
			"fixtures/baz.rb"
		])

		# Mocking Kernel.require via the class under test
		expect( collection ).to receive( :require ).
			with( "fixtures/foo" ).and_return( false )
		expect( collection ).to receive( :require ).
			with( "fixtures/bar" ).and_return( false )
		expect( collection ).to receive( :require ).
			with( "fixtures/baz" ).and_return( false )

		collection.load_all
	end


	it "allows the loading prefix to be customized" do
		collection.fixture_path_prefix( 'acme/fixtures' )
		expect( collection ).to receive( :require ).
			with( "acme/fixtures/foo" ).and_return( false )

		collection.load( :foo )
	end


	describe "fixture extension" do

		let( :extending_module ) do
			mod = Module.new do
				def self::name ; "CollectionTests"; end
			end
			mod.extend( collection )
			mod
		end


		it "adds instance data to its fixture modules" do
			expect( extending_module.decorators ).to be_a( Hash )
		end

	end


end

