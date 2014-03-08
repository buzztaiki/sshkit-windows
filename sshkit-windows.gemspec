# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sshkit/windows/version'

Gem::Specification.new do |spec|
  spec.name          = "sshkit-windows"
  spec.version       = SSHKit::Windows::VERSION
  spec.authors       = ["Taiki Sugawara"]
  spec.email         = ["buzz.taiki@gmail.com"]
  spec.description   = %q{Windows support for SSHKit and Capistrano3}
  spec.summary       = %q{Windows support for SSHKit and Capistrano3}
  spec.homepage      = "https://github.com/buzztaiki/sshkit-windows"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sshkit", "~> 1.3"
  spec.add_runtime_dependency "winrm", "~> 1.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
