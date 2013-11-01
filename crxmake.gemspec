# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "crxmake"
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Constellation"]
  s.date = "2013-11-01"
  s.description = "command line tool for making chromium extension"
  s.email = "utatane.tea@gmail.com"
  s.executables = ["crxmake"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "Rakefile", "bin/crxmake", "test/crxmake_test.rb", "lib/crxmake.rb"]
  s.homepage = "http://github.com/Constellation/crxmake/tree/master"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc", "--charset", "utf-8", "--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "crxmake"
  s.rubygems_version = "2.0.0"
  s.summary = "make chromium extension"
  s.test_files = ["test/crxmake_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<zip>, ["~> 2.0.2"])
    else
      s.add_dependency(%q<zip>, ["~> 2.0.2"])
    end
  else
    s.add_dependency(%q<zip>, ["~> 2.0.2"])
  end
end
