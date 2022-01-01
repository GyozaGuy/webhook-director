require 'em-websocket'
require 'json'
require 'sinatra'
require 'yaml'
require_relative 'parsers/parsers'

SERVER_PORT, WEBSOCKET_PORT = YAML.safe_load_file('.env.yaml').values_at(*%w[
  server_port
  websocket_port
])

channel = EM::Channel.new

set :port, SERVER_PORT || 4567

post '/*' do
  body = JSON(request.body.read)
  notification_content = nil
  path = request.path[1..]

  case path
  when 'github'
    notification_content = Parsers.github(body)
  # when 'plex'
  #   notification_content = Parsers.plex(body)
  else
    puts "Unknown path: #{path}"
  end

  channel.push(notification_content) unless notification_content.nil?

  204
end

Thread.new do
  EM.run do
    EM::WebSocket.run(host: '0.0.0.0', port: WEBSOCKET_PORT) do |ws|
      ws.onopen do
        sid = channel.subscribe do |message|
          ws.send JSON(message).to_s
        end

        ws.onclose do
          channel.unsubscribe(sid)
        end
      end
    end
  end
end
