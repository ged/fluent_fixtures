#!/usr/bin/env ruby

BEGIN {
	basedir = File.dirname( __FILE__ )
	libdir = File.join( File.dirname(basedir), 'lib' )
	acmelibdir = File.join( basedir, 'lib' )
	$LOAD_PATH.unshift( libdir, acmelibdir )
}


puts "Load the Acme fixtures collection:"
require 'acme/fixtures'
puts Acme::Fixtures.describe

puts

puts "Now tell the collection we'll need the `users` and `groups` fixtures:"
Acme::Fixtures.load( :users, :groups )
puts Acme::Fixtures.describe

puts

puts "Create a factory that will create instances of Acme::User:"
factory = Acme::Fixtures.user
puts factory.inspect

puts

puts "Use it to create a few (unsaved) instances:"
users = 3.times.map { factory.instance }
puts users.inspect

puts

puts "Make a mutation of the previous factory that will create instances with a random first name:"
factory = factory.with_random_first_name
puts factory.inspect
users = 3.times.map { factory.instance }
puts users.inspect

puts

puts "Make a mutation of the random first name factory that will create instances with " \
	"a random last name too:"
factory = factory.with_random_last_name
puts factory.inspect
users = 3.times.map { factory.instance }
puts users.inspect

puts

puts "Use the same factory, but create saved instances now:"
users = 3.times.map { factory.create }
puts users.inspect
