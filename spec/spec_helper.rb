require 'rubygems'

require 'rspec'
require 'hashie'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'garterbelt'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
Dir["#{File.dirname(__FILE__)}/integration/templates/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  include PutSpec
end
