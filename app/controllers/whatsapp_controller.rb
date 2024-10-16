class WhatsappController < ApplicationController
  def receive
    if request.get?
      verify_token
    elsif request.post?
      process_message
    else
      head :bad_request
    end
  end

  private

  def verify_token
    mode = params['hub.mode']
    token = params['hub.verify_token']
    challenge = params['hub.challenge']

    if mode == 'subscribe' && token == Whatsapp::Whatsapp.verify_webhook_token
      render plain: challenge
    else
      head :forbidden
    end
  end

  def process_message
    message = params.dig('entry', 0, 'changes', 0, 'value', 'messages', 0, 'text', 'body')
    from = params.dig('entry', 0, 'changes', 0, 'value', 'messages', 0, 'from')

    if message && from
      logger.info "Received message from #{from}: #{message}"
      GenerateChatResponseJob.perform_later(message, from)
    end

    head :ok
  end
end
