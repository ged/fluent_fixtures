# -*- ruby -*-
#encoding: utf-8

require 'loggability'
require 'fluent_fixtures' unless defined?( FluentFixtures )


# The fluent fixture monadic factory class.
class FluentFixtures::Factory
	extend Loggability


	# The methods to look for to save new instances when #create is called
	CREATE_METHODS = %i[ save_changes save ]


	# Loggability API -- log to the FluentFixtures logger
	log_to :fluent_fixtures


	### Create a new FluentFactory that will act as a monadic factory for the specified
	### +fixture_module+, and use the given +args+ in the construction of new objects.
	def initialize( fixture_module, *args, &block )
		@fixture_module = fixture_module
		@constructor_args = args
		@constructor_block = block
		@decorators = []
	end


	### Copy constructor -- make a distinct copy of the clone's decorators.
	def initialize_copy( original )
		@decorators = @decorators.dup
	end


	##
	# The fixture module that contains the decorator declarations
	attr_reader :fixture_module

	##
	# The decorators that will be applied to the fixtured object when it's created.
	attr_reader :decorators

	##
	# The Array of arguments to pass to the constructor when creating a new fixtured object.
	attr_reader :constructor_args

	##
	# The block to pass to the constructor when creating a new fixtured object.
	attr_reader :constructor_block


	### Return a new clone of the receiver with an additional decorator composed of the
	### specified +name+, +args+, and +block+.
	def mutate( name, *args, &block )
		new_instance = self.dup
		new_instance.decorators << [ name, args, block ]
		return new_instance
	end


	### Create an instance, apply declared decorators in order, and return the resulting
	### object.
	def instance( *args, &block )
		instance = self.fixture_module.
			fixtured_instance( *self.constructor_args, &self.constructor_block )

		self.decorators.each do |decorator_name, args, block|
			# :TODO: Reify other fixtures in `args` here?
			if !decorator_name
				self.apply_inline_decorator( instance, block )
			elsif self.fixture_module.decorators.key?( decorator_name )
				self.apply_named_decorator( instance, args, decorator_name )
			else
				self.apply_method_decorator( instance, args, decorator_name, block )
			end
		end

		# If the factory was called with a block, use it as a final decorator before
		# returning it.
		if block
			self.log.debug "Applying inline decorator %p" % [ block ]
			if block.arity.zero?
				instance.instance_exec( *args, &block )
			else
				block.call( instance, *args )
			end
		end

		return instance
	end


	### Return a saved #instance of the fixtured object.
	def create( *args, &block )
		obj = self.with_transaction do
			obj = self.instance( *args, &block )
			obj = self.fixture_module.call_before_saving( obj ) if
				self.fixture_module.respond_to?( :call_before_saving )

			self.try_to_save( obj )

			obj
		end

		return obj
	end


	### Return a copy of the factory that will apply the specified +block+ as a decorator.
	def decorated_with( &block )
		return self.mutate( nil, &block )
	end


	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		decorator_description = self.decorators.map( &:first ).join( ' + ' )

		return "#<%p:%0#16x for %p%s>" % [
			self.class,
			self.__id__ * 2,
			self.fixture_module,
			decorator_description.empty? ? '' : ' + ' + decorator_description
		]
	end


	#########
	protected
	#########

	### Apply a decorator +block+ added to the factory via #decorated_with to the +instance+.
	def apply_inline_decorator( instance, block )
		self.log.debug "Applying anonymous inline decorator %p" % [ block ]
		if block.arity.nonzero?
			block.call( instance )
		else
			instance.instance_eval( &block )
		end
	end


	### Apply a decorator declared in the fixture module by the given
	### +decorator_name+ to the specified +instance+.
	def apply_named_decorator( instance, args, decorator_name )
		decorator_block = self.fixture_module.decorators[ decorator_name ]
		self.log.debug "Applying decorator %p (%p) to a %p with args: %p" %
			[ decorator_name, decorator_block, instance.class, args ]
		instance.instance_exec( *args, &decorator_block )
	end


	### Apply a decorator declared by calling the proxy method with the specified
	### +name+, +args+, and +block+ to the given +instance+. 
	def apply_method_decorator( instance, args, name, block )
		self.log.debug "Mutating instance %p with regular method %p( %p, %p )" %
			[ instance, name, args, block ]
		if block
			instance.public_send( name, *args )
		else
			instance.public_send( name, *args, &block )
		end
	end


	### Look for common transaction mechanisms on the fixtured class, and wrap one of
	### them around the +block+ if one exists. If no transaction mechanism can be found,
	### just yield to the block.
	def with_transaction( &block )
		fixtured_class = self.fixture_module.fixtured_class
		if fixtured_class.respond_to?( :db )
			self.log.debug "Using db.transaction for creation."
			return fixtured_class.db.transaction( &block )
		else
			yield
		end
	end


	### Try various methods for saving the given +object+, logging a warning if it doesn't
	### respond to any of them.
	def try_to_save( object )
		CREATE_METHODS.each do |methodname|
			return object.public_send( methodname ) if object.respond_to?( methodname )
		end

		self.log.warn "create: don't know how to save %p" % [ object ]
	end


	### Proxy method -- look up the decorator with the same name as the method being called,
	### and if one is found, returned a new instance of the factory with the additional
	### decorator.
	def method_missing( sym, *args, &block )
		return self.mutate( sym, *args, &block )
	end

end # class FluentFixtures::Factory

