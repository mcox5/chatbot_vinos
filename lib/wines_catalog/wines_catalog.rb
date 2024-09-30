module WinesCatalog
  def self.wines_catalog
    @wines_catalog = {}
    CSV.foreach('lib/assets/wines_catalog.csv', headers: true) do |row|
      @wines_catalog[row['categoria'].downcase] = {
        code: row['codigo'],
        client_price: row['precio venta'],
        cost_price: row['precio vina'],
        gains_per_unit: row['comision']
      }
    end

    @wines_catalog
  end

  def self.wines_categories
    wines_catalog.keys - [ "flete" ]
  end

  def self.varieties
    [ "carmenere", "cabernet sauvignon", "merlot",
     "sauvignon blanc", "chardonnay", "syrah",
     "pinot noir", "malbec", "blend", "ensamblaje",
    "roussane marssane", "tempranillo" ]
  end

  def self.get_code(category)
    wines_catalog[category.downcase][:code]
  end

  def self.get_price(category)
    wines_catalog[category.downcase][:client_price].to_i
  end

  def self.get_cost_price(category)
    wines_catalog[category.downcase][:cost_price].to_i
  end

  def self.get_gains_per_unit(category)
    wines_catalog[category.downcase][:gains_per_unit].to_i
  end

  def self.order_details_text(order_attributes)
    <<~TEXT
      Nombre del cliente: #{order_attributes['nombre_cliente']}
      Dirección de entrega: #{order_attributes['direccion_entrega']}
      Detalles del pedido:
      #{order_attributes[:items_pedido].map { |item| "- #{item[:cantidad]} botellas de #{item[:variedad]} #{item[:categoria]} a $#{item[:precio_unitario]} c/u" }.join("\n")}
      Precio total: $#{order_attributes[:precio_total]}
    TEXT
  end
end
