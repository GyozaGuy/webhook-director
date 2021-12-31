module Parsers
  def self.github(body_content)
    content = ''
    title = ''
    url = body_content.dig('repository', 'html_url')

    if body_content['action'] == 'opened' && body_content['pull_request']
      content = body_content.dig('pull_request', 'body')
      title = "New Pull Request :: #{body_content.dig('pull_request', 'title')}"
      url = body_content.dig('pull_request', 'html_url')
    end

    {
      content: content,
      source: 'GitHub',
      title: title,
      url: url
    }
  end
end
