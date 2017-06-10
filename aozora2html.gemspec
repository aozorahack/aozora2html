# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aozora2html/version'

Gem::Specification.new do |spec|
  spec.name          = "aozora2html"
  spec.version       = Aozora2Html::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.license       = "CC0"
  spec.authors       = ["aozorahack team"]
  spec.email         = ["takahashimm@gmail.com"]

  spec.summary       = %q{converter from Aozora Bunko format into xhtml. It's based of t2hs.rb from kumihan.aozora.gr.jp.}
  spec.description   = %q{converter from Aozora Bunko format into xhtml. It's based of t2hs.rb from kumihan.aozora.gr.jp.}
  spec.homepage      = "https://github.com/aozorahack/aozora2html"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rubyzip"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"
  if RUBY_VERSION >= "2.0.0"
    spec.add_development_dependency "rubocop"
    spec.add_development_dependency "meowcop"
  end
  # spec.add_development_dependency "test-unit-notify"
  # spec.add_development_dependency "terminal-notifier"
  if RUBY_VERSION > "2.2.0"
    spec.add_development_dependency "guard"
    spec.add_development_dependency "guard-test"
  end
end
