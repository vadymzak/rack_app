require './app/my_app'
require './app/my_rack_middleware'
require "./app/algorithm/hs256"
require "./app/algorithm/rs256"
use Rack::Reloader
use MyRackMiddleware
run MyApp.new
