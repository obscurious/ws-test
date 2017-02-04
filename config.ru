dev = ENV['RACK_ENV'] == 'development'

if dev
  require 'logger'
  logger = Logger.new($stdout)
end

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new(:subclasses=>%w'Roda Sequel::Model', :logger=>logger, :reload=>dev){Wassal}
require_relative 'models'
Unreloader.require('app.rb'){'Wassal'}
run(dev ? Unreloader : Wassal.freeze.app)
