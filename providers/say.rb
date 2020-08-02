def whyrun_supported?
  true
end

use_inline_resources

action :say do

  module ::Slackr
    module IncomingWebhook
      extend self

      attr_accessor :connection

      # {
      #   :formatter => [BasicFormatter, LinkFormatter, AttachmentFormatter]
      # }
      def say(connection, text="", options={})
        @connection = connection
        #formatter = options[:formatter] || BasicFormatter
        #text      = format_text(formatter, text)
        #TODO: fix law of demeter violations
        request      = Net::HTTP::Post.new(service_url)
        request.body = encode_message(text, options)
        response     = connection.http_request(request)
        if response.code != "200"
          raise Slackr::ServiceError, "#{service_url} - #{response.code} - #{response.body}"
        end
      end
    end
  end

  slack = Slackr.connect(node.slack.team,node.slack.api_key)

  options = {}
  options["channel"]    = new_resource.channel     if new_resource.channel
  options["username"]   = new_resource.username    if new_resource.username
  options["icon_url"]   = new_resource.icon_url    if new_resource.icon_url
  options["icon_emoji"] = new_resource.icon_emoji  if new_resource.icon_emoji

  slack.say(new_resource.message,options)
end
