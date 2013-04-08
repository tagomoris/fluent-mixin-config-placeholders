# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-mixin-config-placeholders"
  gem.version       = "0.2.2"
  gem.authors       = ["TAGOMORI Satoshi"]
  gem.email         = ["tagomoris@gmail.com"]
  gem.description   = %q{to add various placeholders for plugin configurations}
  gem.summary       = %q{Configuration syntax extension mixin for fluentd plugin}
  gem.homepage      = "https://github.com/tagomoris/fluent-mixin-config-placeholders"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "fluentd"
  gem.add_development_dependency "uuidtools"
  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "uuidtools"
end
