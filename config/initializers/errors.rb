module GoogleError
  class BaseGoogleError < StandardError; end
  class AuthenticationGoogleError < BaseGoogleError; end
end

module WhatsAppError
  class BaseWhatsappError < StandardError; end
  class SendMessageWhatsappError < BaseWhatsappError; end
end
