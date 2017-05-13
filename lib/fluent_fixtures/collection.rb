# -*- ruby -*-
#encoding: utf-8

require 'inflecto'
require 'loggability'

require 'fluent_fixtures' unless defined?( FluentFixtures )


# Extension module for fixture collection modules
module FluentFixtures::Collection
	extend Loggability


	# The glob pattern to use when matching files in the search_path.
	FIXTURE_FILE_PATTERN = '*.rb'


	# Loggability API -- log to the FluentFixtures logger
	log_to :fluent_fixtures


	### Extension callback for the +collection_mod+. Sets up data structures for new
	### +collection_mod+s.
	def self::extended( collection_mod )
		super

		prefix = collection_mod.name || nil
		prefix &&= prefix.sub( /::.*\z/, '' ).downcase
		default_fixture_path_prefix = File.join( *[prefix, 'fixtures'].compact )

		collection_mod.extend( Loggability )
		collection_mod.log_to( :fluent_fixtures )

		collection_mod.instance_variable_set( :@modules, {} )
		collection_mod.instance_variable_set( :@fixture_path_prefix, default_fixture_path_prefix )
	end


	##
	# The Hash of fixture modules declared within this Collection
	attr_reader :modules


	### Declare one or more +prefixes+ to use when searching for fixtures to load
	### for the Collection.
	def fixture_path_prefix( new_prefix=nil )
		@fixture_path_prefix = new_prefix if new_prefix
		return @fixture_path_prefix
	end


	### Load fixtures of the specified +types+.
	def load( *types )
		types.each do |type|
			requirename = File.join( self.fixture_path_prefix, type.to_s )
			require( requirename )
		end
	end


	### Load all available fixture modules from loaded gems.
	def load_all
		pattern = File.join( self.fixture_path_prefix, FIXTURE_FILE_PATTERN )
		Gem.find_files( pattern ).each do |fixture_path|
			fixture_name = File.basename( fixture_path, '.rb' )
			self.load( fixture_name )
		end
	end


	### Extension callback -- add some stuff to every fixture module. Note that this is called
	### by fixtures which extend a collection module, not by the collection itself.
	def extended( fixture_mod )
		super

		fixture_mod.extend( Loggability )
		fixture_mod.log_to( :fluent_fixtures )

		fixture_mod.extend( FluentFixtures::DSL )
		fixture_mod.instance_variable_set( :@decorators, {} )
		fixture_mod.instance_variable_set( :@decorator_options, {} )
		fixture_mod.instance_variable_set( :@fixtured_class, nil )
		fixture_mod.instance_variable_set( :@base_fixture, nil )

		fixture_mod.collection = self

		if default_name = self.default_base_fixture_name( fixture_mod )
			self.add_base_fixture( default_name, fixture_mod )
		end
	end


	### Add a global fixture method with the specified +name+ to the top-level
	### Fixtures module.
	def add_base_fixture( name, fixture_mod )
		self.log.debug "Adding a base fixture to %p: %p as %p" % [ self, fixture_mod, name ]

		if previous_name = self.modules.key( fixture_mod )
			self.modules.delete( previous_name )
			# ugh, no remove_singleton_method
			self.singleton_class.instance_exec( previous_name ) do |methodname|
				remove_method( methodname )
			end
		end

		if self.modules.key?( name )
			raise ScriptError,
				"Already have a base fixture called %s: %p" % [ name, self.modules[name] ]
		end

		self.modules[ name ] = fixture_mod
		define_singleton_method( name, &fixture_mod.method(:factory) )
	end


	### Return the default base fixture name based on the name of the given +mod+ (a Module).
	def default_base_fixture_name( mod )
		modname = mod.name or return nil
		name = Inflecto.singularize( Inflecto.demodulize(modname).downcase )
		return name.to_sym
	end


	### Clear all declared fixtures from the Cozy::FluentFixtures namespace. Mostly used for
	### testing the fixtures system itself.
	def reset!
		self.modules.each do |name, mod|
			self.log.warn "Removing base fixture method for %p: %p" % [ mod, name ]
			self.singleton_class.instance_exec( name ) do |methodname|
				remove_method( methodname ) if method_defined?( methodname )
			end
		end
		self.modules.clear
	end


end # module FluentFixtures::Collection
