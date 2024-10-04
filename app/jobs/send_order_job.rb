class SendOrderJob < ApplicationJob
  queue_as :default

  def perform(order_attributes)
    @order = order_attributes
    write_order_sheet_to_send
    send_order_sheet
    save_order_in_sheets_database
  end

  private

  def google_sheets_client
    @google_sheets_client ||= GoogleSheetsClient.new
  end

  def google_drive_client
    @google_drive_client ||= GoogleDriveClient.new
  end

  def google_gmail_client
    @google_gmail_client ||= GoogleGmailClient.new
  end

  def spreadsheet
    @spreadsheet ||= google_sheets_client.create_spreadsheet("#{Date.today.to_s} - TEST")
  end

  def write_order_sheet_to_send
    headers = ['FECHA', 'NOMBRE', 'DIRECCIÓN', 'GUIA/BOLETA', 'CANTIDAD', 'CATEGORIA', 'VARIEDAD', 'VALOR', 'VALOR TOTAL']

    rows = @order[:items_pedido].map do |item|
      [
        Date.today.to_s,
        @order[:nombre_cliente],
        @order[:direccion_entrega],
        'boleta',
        item[:cantidad],
        item[:categoria],
        item[:variedad],
        item[:precio_cliente],
        item[:cantidad] * item[:precio_cliente]
      ]
    end

    google_sheets_client.write_to_sheet(spreadsheet, 'Hoja 1!A1:I1', [ headers ])
    google_sheets_client.write_to_sheet(spreadsheet, "Hoja 1!A2:I#{rows.size + 1}", rows)
    google_drive_client.move_file(spreadsheet, GoogleLib::Google.orders_to_send_folder_id)

    Rails.logger.info "Order sheet written to send"
  end

  def order_sheet_download
    @order_sheet_download ||= google_drive_client.download_file(spreadsheet)
  end

  def send_order_sheet
    google_gmail_client.send_email(
      GoogleLib::Google.my_email,
      GoogleLib::Google.my_email,
      GoogleLib::Google.order_subject,
      GoogleLib::Google.order_body,
      order_sheet_download,
      GoogleLib::Google.order_file_name_excel
    )

    Rails.logger.info "Order sent to Lorena"
  end

  def save_order_in_sheets_database
    ## COMMENT: SHEETS HEADERS ARE ['ID ORDEN', 'Nombre', 'Fecha', 'Dirección', 'Contacto', 'Codigo', 'Cantidad', 'Categoria', 'Variedad', 'Precio Viña', 'Precio Venta', 'CxP Vina', 'CxC Cliente', 'Comisión', 'Status', 'Status Transferencia', 'Total']

    last_row = google_sheets_client.read_last_row(GoogleLib::Google.orders_database_spreadsheet_id, 'Pedidos')
    last_order_id = last_row ? last_row[0].to_i : 0
    new_order_id = last_order_id + 1

    last_row_index = last_row ? last_row_index = google_sheets_client.get_last_row_index(GoogleLib::Google.orders_database_spreadsheet_id, 'Pedidos') : 2
    start_row = last_row_index

    rows = @order[:items_pedido].map do |item|
      cost_price = item[:precio_costo]
      client_price = item[:precio_cliente]
      total_cost_price = item[:cantidad] * cost_price
      total_client_price = item[:cantidad] * client_price
      comision = total_client_price - total_cost_price

      [
        new_order_id,
        @order[:nombre_cliente],
        Date.today.to_s,
        @order[:direccion_entrega],
        '-',
        item[:codigo_categoria],
        item[:cantidad],
        item[:categoria],
        item[:variedad],
        cost_price,
        client_price,
        total_cost_price,
        total_client_price,
        comision,
        'No pagado',
        ''
      ]
    end

    google_sheets_client.write_to_sheet(GoogleLib::Google.orders_database_spreadsheet_id, "Pedidos!A#{start_row}:Q#{start_row + rows.size - 1}", rows)
    Rails.logger.info "Order saved in database"
  end
end
