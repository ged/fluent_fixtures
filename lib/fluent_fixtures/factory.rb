# -*- ruby -*-
#encoding: utf-8

require 'loggability'
require 'fluent_fixtures' unless defined?( FluentFixtures )


# The fluent fixture monadic factory class.
class FluentFixtures::Factory
	extend Loggability
	include Enumerable


	# The methods to look for to save new instances when #create is called
	CREATE_METHODS = %i[ save_changes save ]

	# The default limit for generators
	DEFAULT_GENERATOR_LIMIT = 10_000


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
	def instance( args={}, &block )
		instance = self.fixture_module.
			fixtured_instance( *self.constructor_args, &self.constructor_block )

		self.decorators.each do |decorator_name, decorator_args, block|
			# :TODO: Reify other fixtures in `decorator_args` here?
			if !decorator_name
				self.apply_inline_decorator( instance, block )
			elsif self.fixture_module.decorators.key?( decorator_name )
				instance = self.apply_named_decorator( instance, decorator_args, decorator_name )
			else
				self.apply_method_decorator( instance, decorator_args, decorator_name, block )
			end
		end

		args.each_pair do |attrname, value|
			# :TODO: Reify the `value` if it responds to #create?
			instance.public_send( "#{attrname}=", value )
		end

		# If the factory was called with a block, use it as a final decorator before
		# returning it.
		if block
			self.log.debug "Applying inline decorator %p" % [ block ]
			if block.arity.zero?
				instance.instance_exec( &block )
			else
				block.call( instance )
			end
		end

		return instance
	end


	### Return a saved #instance of the fixtured object.
	def create( args={}, &block )
		obj = self.with_transaction do
			obj = self.instance( args, &block )
			obj = self.try_to_save( obj )
			obj
		end

		return obj
	end


	### Return a copy of the factory that will apply the specified +block+ as a decorator.
	def decorated_with( &block )
		return self.mutate( nil, &block )
	end


	### Iterate over DEFAULT_GENERATOR_LIMIT instances of the fixtured object, yielding
	### each new instance if a block is provided. If no block is provided, returns an
	### Enumerator.
	def each( &block )
		return self.generator unless block
		return self.generator.each( &block )
	end


	### Return an infinite generator for unsaved instances of the fixtured object.
	def generator( create: false, limit: DEFAULT_GENERATOR_LIMIT, &block )
		return Enumerator.new( limit || Float::INFINITY ) do |yielder|
			count = 0
			constructor = create ? :create : :instance
			loop do
				break if limit && count >= limit

				obj = if block
						self.send( constructor, &block.curry(2)[count] )
					else
						self.send( constructor )
					end

				yielder.yield( obj )

				count += 1
			end
		end
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
		decorator_block = self.fixture_module.decorators[ decorator_name ] or
			raise "non-existent fixture `%s`" % [ decorator_name ]
		decorator_options = self.fixture_module.decorator_options[ decorator_name ] || {}
		self.log.debug "Applying decorator %p (%p - %p) to a %p with args: %p" %
			[ decorator_name, decorator_block, decorator_options, instance.class, args ]

		self.apply_prelude( instance, decorator_options[:prelude] ) if decorator_options[:prelude]

		instance = self.try_to_save( instance ) if decorator_options[:presave]
		if args[-1].is_a?(Hash)
			kwargs = args[-1]
			args = args[0..-2]
		else
			kwargs = {}
		end
		instance.instance_exec( *args, **kwargs, &decorator_block )

		return instance
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


	### Apply a decorator +prelude+ to the current instance.
	def apply_prelude( instance, prelude, args=[] )
		case prelude
		when Symbol
			self.log.debug "Applying single prelude decorator: %p" % [ prelude ]
			self.apply_named_decorator( instance, args, prelude )
		when Array
			self.log.debug "Applying multiple prelude decorators: %p" % [ prelude ]
			prelude.each do |sublude|
				self.apply_prelude( instance, sublude, args )
			end
		when Hash
			self.log.debug "Applying one or more prelude decorators with args: %p" % [ prelude ]
			prelude.each do |sublude, args|
				self.apply_prelude( instance, sublude, args )
			end
		else
			raise ArgumentError, "unhandled prelude type %p" % [ prelude.class ]
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
		object = self.fixture_module.call_before_saving( object ) if
			self.fixture_module.respond_to?( :call_before_saving )

		save_method = CREATE_METHODS.find do |methodname|
			object.respond_to?( methodname )
		end

		if save_method
			object.public_send( save_method )
		else
			self.log.warn "create: don't know how to save %p" % [ object ]
		end

		object = self.fixture_module.call_after_saving( object ) if
			self.fixture_module.respond_to?( :call_after_saving )

		return object
	end


	### Proxy method -- look up the decorator with the same name as the method being called,
	### and if one is found, returned a new instance of the factory with the additional
	### decorator.
	def method_missing( sym, *args, &block )
		return self.mutate( sym, *args, &block )
	end

end # class FluentFixtures::Factory

