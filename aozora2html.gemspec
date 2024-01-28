# frozen_string_literal: true

require_relative 'lib/aozora2html/version'

Gem::Specification.new do |spec|
  spec.name          = 'aozora2html'
  spec.version       = Aozora2Html::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.license       = 'CC0'
  spec.authors       = ['aozorahack team']
  spec.email         = ['takahashimm@gmail.com']

  spec.summary       = %q(converter from Aozora Bunko format into xhtml. It's based of t2hs.rb from kumihan.aozora.gr.jp.)
  spec.description   = %q(converter from Aozora Bunko format into xhtml. It's based of t2hs.rb from kumihan.aozora.gr.jp.)
  spec.homepage      = 'https://github.com/aozorahack/aozora2html'

  spec.required_ruby_version = '>= 2.7.0'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rubyzip'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'test-unit-rr'
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
