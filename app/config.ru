require './my_app'
require './myrackmiddleware'
require "./check"
use Rack::Reloader
use MyRackMiddleware
run MyApp.new
