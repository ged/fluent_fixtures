# The Setup

To make use of FluentFixtures, you'll need to first set up a module to contain them. Each base fixture you declare will show up in this module.

For example, say I'm adding fixtures to a hypothetical codebase for acme-warehouse.com's website. It has a set of Sequel::Model classes that are backed by a PostgreSQL database. with a schema like:

    CREATE SCHEMA acme;
    CREATE TABLE acme.customers (
        id serial primary key,
        first_name text NOT NULL,
        last_name text NOT NULL
    );
    CREATE TABLE acme.orders (
        id serial primary key,
        ordered_at timestamp with time zone DEFAULT now(),
        updated_at timestamp with time zone,
        customer_id integer REFERENCES acme.customers NOT NULL
    );
    CREATE TABLE acme.order_items (
        id serial primary key,
        sku text NOT NULL,
        order_id integer REFERENCES acme.orders NOT NULL
    );
  

 The codebase has three classes: Customers, Orders, and OrderItems, all in the `Acme` namespace:

    # lib/acme.rb
    
    require 'sequel'
    
    module Acme
    
    	DB = Sequel.postgres( 'acme' )
    
    	Sequel::Model.plugin :validation_helpers
    	Sequel::Model.plugin :auto_validations, not_null: :presence
    
    	autoload :Customer, 'acme/customer'
    	autoload :Order, 'acme/order'
    	autoload :OrderItem, 'acme/order_item'
    
    end

And the model classes look something like this:

    # lib/acme/customer.rb
    
    require 'sequel/model'
    require 'acme' unless defined?( Acme )
    
    class Acme::Customer < Sequel::Model( :acme__customers )
    
    	one_to_many :orders
    
    end

    # lib/acme/order.rb
    
    require 'sequel/model'
    require 'acme' unless defined?( Acme )
    
    class Acme::Order < Sequel::Model( :acme__orders )
    
    	many_to_one :customer, class: 'Acme::User'
    	one_to_many :order_items
    
    end
    
    # lib/acme/order_item.rb
    
    require 'sequel/model'
    require 'acme' unless defined?( Acme )
    
    class Acme::OrderItem < Sequel::Model( :acme__order_items )
    
    	many_to_one :order
    
    end


## Collections

To start the fixture library, I'll create a new `lib/acme/fixtures.rb` that looks like:

    # lib/acme/fixtures.rb
    
    require 'fluent_fixtures'
    require 'acme' unless defined?( Acme )
    
    module Acme::Fixtures
    	extend FluentFixtures::Collection
    
    	fixture_path_prefix 'acme/fixtures'
    
    end

The `extend` line tell FluentFixtures that the extended module is a collection of related fixtures, and the `fixture_path_prefix` line tells FluentFixtures where to find the files that contain the individual fixture declarations themselves.

This module will act as the main interface to all of ACME's fixtures.


## Fixtures

First, we'll add a bare-bones `customer` fixture for creating instances of `Acme::Customer`:

    # lib/acme/fixtures/customers.rb

    require 'acme/fixtures'
    require 'acme/customer

    module Acme::Fixtures::Customers
        extend Acme::Fixtures
        fixtured_class Acme::Customer
    end

This time, the `extend` line tells the fixture collection we just created that any fixtures declared in this module belong to it. The `fixtured_class` declaration tells FluentFixtures what kinds of objects these fixtures will create.

This by itself sets up some defaults based on convention. The first is the "base" fixture, which is the name of the method you'll call on the collection to get a factory that can create `Acme::Customer` objects:

    customer = Acme::Fixtures.customer
    # => #<FluentFixtures::Factory:0x007fede4113210 for Acme::Fixtures::Customers>

    customer.instance
    # => #<Acme::Customer @values={}>

### The `base` Declaration

If I wanted the base fixture to be called something else, I could also override the conventional one using the `base` declaration:

    module Acme::Fixtures::Customers
      # ...
      base :user
    end

    customer = Acme::Fixtures.user
    # => #<FluentFixtures::Factory:0x007fc15992a370 for Acme::Fixtures::Customers>

Obviously this is a little unintuitive, so I won't actually do that, but the `base` declaration can also take a block to provide reasonable defaults. I'll use the `Faker` gem to generate a default first and last name if one hasn't already been set when the object is created:

    require 'faker'

    module Acme::Fixtures::Customers
      # ...
      base :customer do
        self.first_name ||= Faker::Name.first_name
        self.last_name ||= Faker::Name.last_name
      end
    end

    customer = Acme::Fixtures.customer
    # => #<FluentFixtures::Factory:0x007fdb492cd4c8 for Acme::Fixtures::Customers>
    customer.instance
    # => #<Acme::Customer @values={:first_name=>"Polly", :last_name=>"Larson"}>


The block executes in the context of the new object if the `base` block doesn't take an argument; you can also declare a block that accepts the new object as an argument if you prefer that.


### Decorators



### Hooks



## RSpec



