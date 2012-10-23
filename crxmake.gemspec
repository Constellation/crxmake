# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{crxmake}
  s.version = "2.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Constellation"]
  s.date = %q{2011-07-11}
  s.default_executable = %q{crxmake}
  s.description = %q{make chromium extension}
  s.email = %q{utatane.tea@gmail.com}
  s.executables = ["crxmake"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "Rakefile", "bin/crxmake", "test/crxmake_test.rb", "lib/crxmake.rb"]
  s.homepage = %q{http://github.com/Constellation/crxmake/tree/master}
  s.rdoc_options = ["--main", "README.rdoc", "--charset", "utf-8", "--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{crxmake}
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{make chromium extension}
  s.test_files = ["test/crxmake_test.rb"]

  s.add_runtime_dependency "rubyzip"
end
