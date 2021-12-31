require_relative 'github'
require_relative 'plex'

# All parsers reduce webhook contents into the following format:
# {
#   content: 'Notification content',
#   source: 'sourcename',
#   title: 'Notification Title'
#   url: 'URL to open',
# }

module Parsers
end
