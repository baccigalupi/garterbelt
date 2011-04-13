require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "garterbelt"
  gem.homepage = "http://github.com/baccigalupi/garterbelt"
  gem.license = "MIT"
  gem.summary = %Q{Garterbelt is a Ruby HTML/XML markup framework. It is san DSL. Just all Ruby, all the time.}
  gem.description = %Q{Garterbelt is a Ruby HTML/XML markup framework inspired by Erector and Markaby. Garterbelt maps html tags to methods allowing the intuitive construction of HTML pages using nothing but Ruby. And because it is all Ruby all the time, views benefit from the dryness of inheritance, modules and all the meta magic that Ruby can imagine. Stockings not included.}
  gem.email = "baccigalupi@gmail.com"
  gem.authors = ["Kane Baccigalupi"]
  
  gem.add_development_dependency 'hashie', '~>1.0'
  gem.add_development_dependency 'rbench'
  
  gem.add_runtime_dependency 'activesupport', '>=2.3.8'
  gem.add_runtime_dependency 'moneta', '>=0.6.0'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
