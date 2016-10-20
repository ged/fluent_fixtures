#!/usr/bin/ruby -*- ruby -*-

require 'bundler/setup'
$LOAD_PATH.unshift( '../../lib', 'lib' )

begin
	require 'acme'
	require 'acme/fixtures'

	Acme::Fixtures.load_all
rescue Exception => e
	$stderr.puts "Ack! Libraries failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


