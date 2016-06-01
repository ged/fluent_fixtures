#!/usr/bin/env rspec -cfd

require_relative 'spec_helper'

require 'fluent_fixtures'


describe FluentFixtures do

	it "has a semver version" do
		expect( described_class::VERSION ).to match( /\A\d+\.\d+\.\d+(-[\p{Alnum}-]+)?/ )
	end

end

