# -*- ruby -*-
#encoding: utf-8

require 'fluent_fixtures' unless defined?( FluentFixtures )


module FluentFixtures::DSL

	#
	# Accessors for extended fixture modules
	#

	##
	# The Hash of decorators declared for this fixture module
	attr_reader :decorators

	# The Hash of options hashes for declared decorators
	attr_reader :decorator_options

	##
	# The name of the base fixture for the fixture module as a Symbol
	attr_accessor :base_fixture


	##
	# The FluentFixtures::Collection the fixture is part of
	attr_accessor :collection


	#
	# Fixture API
	#

	### Declare a base fixture for the current module called +name+, with an optional
	### initial decorator as a +block+. If no +name+ is given, one is chosen based on the
	### name of the declaring module.
	def base( name=nil, &block )
		name ||= self.collection.default_base_fixture_name( self )

		self.base_fixture = name
		self.decorators[ :_ ] = block if block

		self.collection.add_base_fixture( name, self )
	end


	### Get/set the Class the fixture will use.
	def fixtured_class( new_class=nil )
		@fixtured_class = new_class if new_class
		return @fixtured_class
	end


	### Register one or more +other_fixtures+ that should be loaded when this
	### fixture is loaded.
	def depends_on( *other_fixtures )
		self.collection.load( *other_fixtures )
	end


	### Declare a decorator for the fixture with the specified +name+ that will use the
	### given +block+.
	def decorator( name, **options, &block )
		name = name.to_sym
		self.decorators[ name ] = block
		self.decorator_options[ name ] = options
	end


	### Returns +true+ if there is a decorator with the specified +name+.
	def decorator?( name )
		return self.decorators.key?( name.to_sym )
	end
	alias_method :has_decorator?, :decorator?


	### Declare a +new_name+ for the decorator declared with with +original_name+.
	def alias_decorator( new_name, original_name )
		block = self.decorators[ original_name.to_sym ] or
			raise ScriptError, "undefined decorator %p" % [ original_name ]
		self.decorators[ new_name.to_sym ] = block
	end


	### Add a callback to the fixture that will be passed new instances after all
	### decorators have been applied and immediately before it's saved. The results of
	### the block will be used as the fixtured instance.
	def before_saving( &block )
		define_singleton_method( :call_before_saving, &block )
	end


	### Add a callback to the fixture that will be passed new instances after it's
	### saved. The results of the block will be used as the fixtured instance.
	def after_saving( &block )
		define_singleton_method( :call_after_saving, &block )
	end


	### Return an instance of Cozy::FluentFixtures::FluentFactory for the base fixture
	### of the receiving module.
	def factory( *args, &block )
		return FluentFixtures::Factory.new( self, *args, &block )
	end


	### Return an unsaved instance of the fixtured class with the specified +args+
	### and +block+, applying the base decorator if there is one.
	def fixtured_instance( *args, &block )
		fixclass = self.fixtured_class or
			raise ScriptError, "%p doesn't declare its fixtured class!" % [ self ]

		instance = fixclass.new( *args, &block )

		if (( base_decorator = self.decorators[:_] ))
			self.log.debug "Applying base decorator to %p" % [ instance ]
			instance.instance_exec( &base_decorator )
		end

		return instance
	end


end # module FluentFixtures::DSL
