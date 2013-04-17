source "http://rubygems.org"

# Specify your gem's dependencies in pd-cap-recipes.gemspec
#

group :test, :development do
  gem 'rspec'
  gem 'guard-rspec'
  gem 'ruby-debug', :platform => :ruby_18
  gem 'debugger', :platform => :ruby_19
  gem 'mysql'
end

group :test do
  gem 'capistrano'
  gem 'git', '1.2.5'
  gem 'hipchat', :git => 'git://github.com/PagerDuty/hipchat.git'
  gem 'cap_gun'
  gem 'grit'  
  gem 'json'
  gem 'capistrano-spec', :git => 'git://github.com/PagerDuty/capistrano-spec.git'
end
