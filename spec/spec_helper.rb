$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'yell-adapters-logstash'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'simplecov'
SimpleCov.root(File.expand_path("#{File.dirname(__FILE__)}/.."))
SimpleCov.start do
  add_filter '/.idea/'
  add_filter '/config/'
  add_filter '/db/'
  add_filter '/lib/tasks'
  add_filter '/lib/assets'
  add_filter '/public/'
  add_filter '/log/'
  add_filter '/spec/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Views', 'app/views'
end #if ENV['COVERAGE']

RSpec.configure do |config|

end
