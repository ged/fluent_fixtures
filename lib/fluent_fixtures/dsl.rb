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

	##
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


	### Declare a decorator that is composed out of other decorators and an optional
	### +block+. The first +hash+ pair should be the name of the declared decorator
	### and the names of the decorator/s it is composed of.
	###
	### Example:
	###
	###     decorator :foo { ... }
	###     decorator :bar { ... }
	###     compose( :simple => :foo ) { ... }
	###     compose( :complex => [:foo, :bar] ) { ... }
	###     compose( :complex_with_args => {foo: [1,2], bar: "Something"} ) { ... }
	def compose( **hash, &block )
		name, components = hash.first

		raise ArgumentError, "expected a name and one or more component decorators" unless name
		unless [Symbol, Array, Hash].include?( components.class )
			raise ArgumentError, "invalid compose values: expected symbol, array, or hash; got %p" %
				[ components.class ]
		end

		options = hash.reject {|k,_| k == name }.merge( prelude: components )
		block ||= Proc.new {}

		self.decorator( name, options, &block )
	end


	### Declare decorators for the +other_fixture+ instead of the current one.
	def additions_for( other_fixture, &block )
		self.depends_on( other_fixture )
		mod = self.collection.modules[ other_fixture ] or
			raise "no such fixture %p" % [ other_fixture ]

		mod.module_eval( &block )
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
		self.decorator_options[ new_name.to_sym ] =
			self.decorator_options[ original_name.to_sym ].dup
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
