require 'em-websocket'
require 'json'
require 'sinatra'
require_relative 'parsers/parsers'

# All parsers reduce webhook contents into the following format:
# {
#   content: 'Notification content',
#   source: 'sourcename',
#   title: 'Notification Title'
#   url: 'URL to open',
# }

channel = EM::Channel.new

post '/' do
  body = JSON(request.body.read)
  type = request.params['type']
  notification_content = nil

  case type
  when 'github'
    notification_content = Parsers.github(body)
  else
    puts "Unknown type: #{type}"
  end

  channel.push(notification_content) unless notification_content.nil?

  204
end

Thread.new do
  EM.run do
    EM::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
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
