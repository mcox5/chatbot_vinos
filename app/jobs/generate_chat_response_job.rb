class GenerateChatResponseJob < ApplicationJob
  queue_as :default

  CHAT_HISTORY_PATH = Rails.root.join('lib', 'assets', 'chat_history.csv').freeze
  ERROR_MESSAGES = {
    chat_answer: "Hubo un error obteniendo la respuesta del chat. Por favor, intenta nuevamente más tarde.",
    whatsapp_send: "Hubo un error enviando el mensaje. Por favor, intenta nuevamente más tarde.",
    whatsapp_error: "Hubo un error de WhatsApp. Por favor, intenta nuevamente más tarde.",
    google_error: "Hubo un error procesando tu pedido con Google. Por favor, intenta nuevamente más tarde.",
    processing_order: "Hubo un error procesando tu pedido, revisa las categorías y las variedades e intenta nuevamente más tarde."
  }.freeze

  def perform(user_message, user_phone_number)
    chat_history_client.save_message('user', user_message)

    chat_answer = openai_client.chat_answer
    handle_answer(chat_answer, user_phone_number)
  rescue OpenaiError::ChatAnswerOpenaiError => e
    log_error("Error getting chat answer", e)
    chat_history_client.clear_history
    whatsapp_client.send_message(user_phone_number, ERROR_MESSAGES[:chat_answer])
  end

  private

  def openai_client
    @openai_client ||= OpenaiClient.new(chat_history_client.history, OpenaiConstants::OpenaiConstants.functions)
  end

  def whatsapp_client
    @whatsapp_client ||= WhatsappClient.new
  end

  def chat_history_client
    @chat_history_client ||= ChatHistoryClient.new(CHAT_HISTORY_PATH)
  end

  def handle_answer(chat_answer, user_phone_number)
    case chat_answer[:response_type]
    when "message"
      handle_message_response(chat_answer[:content], user_phone_number)
    when "function_call"
      handle_function_call(chat_answer[:parameters], user_phone_number)
    end
  end

  def handle_message_response(response_message, user_phone_number)
    chat_history_client.save_message('assistant', response_message)
    whatsapp_client.send_message(user_phone_number, response_message)
  rescue WhatsAppError::SendMessageWhatsappError => e
    log_error("Error sending WhatsApp message", e)
    whatsapp_client.send_message(user_phone_number, ERROR_MESSAGES[:whatsapp_send])
  end

  def handle_function_call(parameters, user_phone_number)
    order_attributes = format_order_attributes(parameters)
    send_order_messages(order_attributes, user_phone_number)
    SendOrderJob.perform_now(order_attributes)
    whatsapp_client.send_message(user_phone_number, "¡Tu pedido ha sido enviado correctamente a bodega y guardado en tu base de datos de drive! Puedes verlo en el correo que te llegó.")
    chat_history_client.clear_history
  rescue WhatsAppError::SendMessageWhatsappError => e
    log_error("Error sending WhatsApp message", e)
    whatsapp_client.send_message(user_phone_number, ERROR_MESSAGES[:whatsapp_error])
  rescue GoogleError::BaseGoogleError => e
    log_error("Error with Google service", e)
    whatsapp_client.send_message(user_phone_number, ERROR_MESSAGES[:google_error])
    chat_history_client.clear_history
  rescue StandardError => e
    log_error("Error processing order", e)
    whatsapp_client.send_message(user_phone_number, ERROR_MESSAGES[:processing_order])
    chat_history_client.clear_history
  end

  def send_order_messages(order_attributes, user_phone_number)
    order_details = WinesCatalog.order_details_text(order_attributes)
    whatsapp_client.send_message(user_phone_number, "Tu pedido está siendo procesado para enviar a bodega...\nDetalles de tu pedido\n#{order_details}")
    payment_url = payment_link(order_attributes[:precio_total])
    whatsapp_client.send_message(user_phone_number, "Acá tienes el link para cobrar tu pedido: #{payment_url}")
  end

  def format_order_attributes(attributes)
    items_pedido = attributes['items_pedido'].map do |item|
      categoria = item['categoria']
      {
        categoria: categoria,
        codigo_categoria: WinesCatalog.get_code(categoria),
        variedad: item['variedad'],
        cantidad: item['cantidad'],
        precio_cliente: WinesCatalog.get_price(categoria),
        precio_costo: WinesCatalog.get_cost_price(categoria)
      }
    end

    {
      nombre_cliente: attributes['nombre_cliente'],
      direccion_entrega: attributes['direccion_entrega'],
      items_pedido: items_pedido,
      precio_total: items_pedido.sum { |item| item[:cantidad] * item[:precio_cliente] }
    }
  end

  def payment_link(total_price)
    "https://slach.cl/matiascoxe/#{total_price}"
  end

  def log_error(message, exception)
    Rails.logger.error "#{message}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
  end
end
