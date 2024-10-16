module Whatsapp
  class Whatsapp
    def self.api_uri
      URI.parse('https://graph.facebook.com/v20.0/387279134477980/messages')
    end

    def self.language_code
      'es'
    end

    def self.token
      ENV.fetch('WHATSAPP_TOKEN')
    end

    def self.verify_webhook_token
      ENV.fetch('VERIFY_WHATSAPP_WEBHOOK_TOKEN')
    end
  end
end
