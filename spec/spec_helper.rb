$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'mdns'

RSpec.configure do |config|
  config.formatter = 'documentation'
  config.color = true
end