class GenerateChatResponseJob < ApplicationJob
  queue_as :default
  discard_on StandardError

  def perform(user_message, user_phone_number)
    @user_message = user_message
    @user_phone_number = user_phone_number
    save_message("user", @user_message)
    handle_answer(openai_client.chat_answer)
  end

  private

  def openai_client
    @openai_client ||= OpenaiClient.new(chat_history, OpenaiConstants.functions)
  end

  def whatsapp_client
    @whatsapp_client ||= WhatsappClient.new
  end

  def chat_history
    @chat_history ||= [ { role: 'system', content: OpenaiConstants.base_prompt } ]
    csv_path = Rails.root.join('lib', 'assets', "chat_history.csv")
    CSV.foreach(csv_path, headers: true) do |row|
      @chat_history << { role: row['role'], content: row['content'] }
    end

    @chat_history
  end

  def save_message(role, message)
    csv_path = Rails.root.join('lib', 'assets', 'chat_history.csv')
    oneline_message = message.gsub(/\r?\n/, ' ') # Reemplaza los saltos de línea con un espacio
    CSV.open(csv_path, 'a', force_quotes: true) do |csv|
      csv << [role, oneline_message]
    end

    message
  end

  def handle_answer(chat_answer)
    if chat_answer[:response_type] == "message"
      response_message = chat_answer[:content]
      save_message("assistant", response_message)
      whatsapp_client.send_message(@user_phone_number, response_message)
    elsif chat_answer[:response_type] == "function_call"
      order_attributes = format_order_attributes(chat_answer[:parameters])
      save_message("assistant", "Tu pedido está siendo procesado para enviar a bodega...\nDetalles de tu pedido\n#{WinesCatalog.order_details_text(order_attributes)}")
      whatsapp_client.send_message(@user_phone_number, "Tu pedido está siendo procesado para enviar a bodega...\nDetalles de tu pedido\n#{WinesCatalog.order_details_text(order_attributes)}")
      whatsapp_client.send_message(@user_phone_number, "Acá tienes el link para cobrar tu pedido: #{payment_link(order_attributes[:precio_total])}")
      SendOrderJob.perform_later(order_attributes)
      whatsapp_client.send_message(@user_phone_number, "Tu pedido ha sido enviado a bodega! Puedes verlo en el mail que te llegó")
    end
  end

  def format_order_attributes(order_attributes)
    {
      nombre_cliente: order_attributes['nombre_cliente'],
      direccion_entrega: order_attributes['direccion_entrega'],
      items_pedido: order_attributes['items_pedido'].map do |item|
        {
          categoria: item['categoria'],
          codigo_categoria: WinesCatalog.get_code(item['categoria']),
          variedad: item['variedad'],
          cantidad: item['cantidad'],
          precio_cliente: WinesCatalog.get_price(item['categoria']),
          precio_costo: WinesCatalog.get_cost_price(item['categoria']),
        }
      end,
      precio_total: order_attributes['items_pedido'].sum { |item| item['cantidad'] * WinesCatalog.get_price(item['categoria']) }
    }
  end

  def payment_link(total_price)
    "https://slach.cl/matiascoxe/#{total_price}"
  end
end
