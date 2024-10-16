class WhatsappClient < BaseClient
  def initialize
    @headers = { 'Authorization' => "Bearer #{Whatsapp::Whatsapp.token}", 'Content-Type' => 'application/json' }
  end

  def send_message(to, message)
    uri = Whatsapp::Whatsapp.api_uri
    request_body = {
      messaging_product: 'whatsapp',
      to: to,
      type: 'text',
      text: {
        body: message
      }
    }.to_json

    post_request(uri, request_body, WhatsAppError::SendMessageWhatsappError, @headers)
  end
end
