module OpenaiConstants
  BASE_PROMPT = <<~PROMPT.freeze
    Eres un vendedor de vinos de la viña Luis Felipe Edwards que recibe pedidos para después enviarlos a los clientes.
    Las categorias de vinos de la viña son: #{WinesCatalog.wines_categories.join(', ')}
    Las variedades disponibles son: #{WinesCatalog.varieties.join(', ')}
    Si la categoría o variedad del vino que quiere el usuario no está dentro de las disponibles, pídele que la aclare.
    En caso de que se trate de categoría Doña Bernarda, LFE900 blend, debes asumir que la variedad es "blend".
    En caso de que se trate de categoría Pater, debes asumir que la variedad es Cabernet Sauvignon.
    Cuando tengas todos los datos del pedido:
    -nombre
    -dirección
    -la lista de vinos que quiere con categoría, variedad, y cantidad.
    Debes pedirle que confirme el pedido con un mensaje:
    "Estás seguro que quieres enviar el siguiente pedido:
    -nombre
    -dirección
    -lista de vinos con sus respectivos detalles"
  PROMPT

  FUNCTIONS = [
    {
      name: "send_wine_order",
      description: "Extrae detalles del pedido de vinos del mensaje del cliente para poder enviarlo",
      parameters: {
        type: "object",
        properties: {
          nombre_cliente: { type: "string", description: "El nombre del cliente" },
          direccion_entrega: { type: "string", description: "La dirección de entrega" },
          items_pedido: {
            type: "array",
            items: {
              type: "object",
              properties: {
                categoria: { type: "string", description: "Categoría del vino solicitado" },
                variedad: { type: "string", description: "Tipo de variedad solicitada" },
                cantidad: { type: "integer", description: "Cantidad del vino solicitado" }
              },
              required: ["categoria", "variedad", "cantidad"]
            },
            description: "Lista de vinos con su categoria, variedad y cantidades solicitadas"
          }
        },
        required: [ "nombre_cliente", "direccion_entrega", "items_pedido" ]
      }
    }
  ]

  def self.base_prompt
    BASE_PROMPT
  end

  def self.functions
    FUNCTIONS
  end
end
