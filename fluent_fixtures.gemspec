# -*- encoding: utf-8 -*-
# stub: fluent_fixtures 0.0.1.pre.20160601191205 ruby lib

Gem::Specification.new do |s|
  s.name = "fluent_fixtures".freeze
  s.version = "0.0.1.pre.20160601191205"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.cert_chain = ["certs/ged.pem".freeze]
  s.date = "2016-06-02"
  s.description = "A toolkit for building a collection of composable testing fixtures with a fluent interface.\n\nTo get started using the library, check out the [Getting Started](GettingStarted_md.html) guide.".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.extra_rdoc_files = ["GettingStarted.md".freeze, "History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "GettingStarted.md".freeze, "History.md".freeze, "README.md".freeze]
  s.files = [".document".freeze, ".rdoc_options".freeze, ".simplecov".freeze, "ChangeLog".freeze, "GettingStarted.md".freeze, "History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "lib/fluent_fixtures.rb".freeze, "lib/fluent_fixtures/collection.rb".freeze, "lib/fluent_fixtures/dsl.rb".freeze, "lib/fluent_fixtures/factory.rb".freeze, "spec/fluent_fixtures/collection_spec.rb".freeze, "spec/fluent_fixtures/dsl_spec.rb".freeze, "spec/fluent_fixtures/factory_spec.rb".freeze, "spec/fluent_fixtures_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://deveiate.org/projects/fluent_fixtures".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0".freeze)
  s.rubygems_version = "2.6.2".freeze
  s.summary = "A toolkit for building a collection of composable testing fixtures with a fluent interface".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_runtime_dependency(%q<inflecto>.freeze, ["~> 0.0"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<faker>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.15"])
    else
      s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_dependency(%q<inflecto>.freeze, ["~> 0.0"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.8"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_dependency(%q<faker>.freeze, ["~> 1.6"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.15"])
    end
  else
    s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
    s.add_dependency(%q<inflecto>.freeze, ["~> 0.0"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.8"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<faker>.freeze, ["~> 1.6"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.15"])
  end
end