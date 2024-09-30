class OpenaiClient < BaseClient
  def initialize(history, functions = nil)
    @history = history
    @functions = functions
  end

  def chat_answer
    parameters = {
      model: "gpt-3.5-turbo",
      messages: @history,
      temperature: 0.1,
      max_tokens: 150
    }

    if @functions
      parameters[:functions] = @functions
      parameters[:function_call] = "auto"
    end

    chat_answer ||= client.chat(parameters: parameters).dig("choices", 0, "message")

    if chat_answer["function_call"]
      {
        response_type: "function_call",
        function_name: chat_answer["function_call"]["name"],
        parameters: JSON.parse(chat_answer["function_call"]["arguments"])
      }
    else
      {
        response_type: "message",
        content: chat_answer["content"]
      }
    end
  end

  private

  def client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end
end
