# -*- encoding: utf-8 -*-
# stub: fluent_fixtures 0.10.0.pre.20220324120205 ruby lib

Gem::Specification.new do |s|
  s.name = "fluent_fixtures".freeze
  s.version = "0.10.0.pre.20220324120205"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/fluent_fixtures/browse", "changelog_uri" => "http://deveiate.org/code/fluent_fixtures/History_md.html", "documentation_uri" => "http://deveiate.org/code/fluent_fixtures", "homepage_uri" => "https://hg.sr.ht/~ged/fluent_fixtures", "source_uri" => "https://hg.sr.ht/~ged/fluent_fixtures/browse" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2022-03-24"
  s.description = "FluentFixtures is a toolkit for building testing objects with a fluent interface.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.files = [".document".freeze, ".rdoc_options".freeze, ".simplecov".freeze, "History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "TheSetup.md".freeze, "lib/fluent_fixtures.rb".freeze, "lib/fluent_fixtures/collection.rb".freeze, "lib/fluent_fixtures/dsl.rb".freeze, "lib/fluent_fixtures/factory.rb".freeze, "spec/fluent_fixtures/collection_spec.rb".freeze, "spec/fluent_fixtures/dsl_spec.rb".freeze, "spec/fluent_fixtures/factory_spec.rb".freeze, "spec/fluent_fixtures_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/fluent_fixtures".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "FluentFixtures is a toolkit for building testing objects with a fluent interface.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<faker>.freeze, ["~> 2.14"])
    s.add_runtime_dependency(%q<inflecto>.freeze, ["~> 0.0"])
    s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.17"])
    s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.15"])
    s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
  else
    s.add_dependency(%q<faker>.freeze, ["~> 2.14"])
    s.add_dependency(%q<inflecto>.freeze, ["~> 0.0"])
    s.add_dependency(%q<loggability>.freeze, ["~> 0.17"])
    s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.15"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
  end
end
