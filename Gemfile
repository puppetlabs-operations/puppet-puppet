source "http://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.3'
  gem "puppet-lint"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "rspec", '< 3.0.0'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "puppet_spec_facts", '>= 0.2.0'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker"
  gem "beaker-rspec"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
