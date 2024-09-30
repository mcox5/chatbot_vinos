module Google
  def self.client_secrets_path
    Rails.root.join('config', 'google', 'client_secret.json')
  end

  def self.credentials_path
    Rails.root.join('config', 'google', 'token.yaml')
  end

  def self.oob_uri
    'http://127.0.0.1:3000/' ## Acá no se que debiera ir si ya tengo la auth hecha
  end

  def self.application_name
    'Wines Chat'
  end

  def self.orders_to_send_folder_id
    '1c9MYgUm4tUUAbYKYg09sTL4H6Xlbd2zR'
  end

  def self.orders_database_spreadsheet_id
    '1tMnZ4e01IBHTsf9yl8otn8IF9pOLv0TS96UAlST-MQs'
  end

  def self.my_email
    'matiascoxed@gmail.com'
  end

  def self.order_subject
    "Pedido de vinos - #{Date.today}"
  end

  def self.order_body
    'Hola Lorena! Adjunto el pedido de vinos para mandar! gracias!'
  end

  def self.order_file_name_excel
    "pedido-#{Date.today}.xlsx"
  end
end
