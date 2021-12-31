module Parsers
  def self.github(content)
    {
      content: '',
      source: 'GitHub',
      title: '',
      url: content.dig('repository', 'html_url')
    }
  end
end
