require './my_app'
require './myrackmiddleware'
require "./algorithm/hs256"
require "./algorithm/rs256"
use Rack::Reloader
use MyRackMiddleware
run MyApp.new
