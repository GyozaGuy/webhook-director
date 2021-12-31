require 'sinatra'

post '/' do
  puts request.body.read
  204
end
