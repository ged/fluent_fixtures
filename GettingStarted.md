# Getting Started With Fluent Fixtures

Declare a module that will act as a collection of fixtures:

    # lib/acme/fixtures.rb
    require 'fluent_fixtures'
    module Acme::Fixtures
        extend FluentFixtures::Collection
        fixture_path_prefix 'acme/fixtures'
    end

This module will act as the main interface to all of ACME's fixtures.

First, we'll add a bare-bones `user` fixture for creating instances of a hypothetical `Acme::User` class:

    # lib/acme/fixtures/users.rb
    require 'acme/fixtures'
    require 'acme/user
    module Acme::Fixtures::Users
        extend Acme::Fixtures
        fixtured_class Acme::User 
    end

[...more soon]


