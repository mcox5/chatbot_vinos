class ChatHistoryClient
  require 'csv'

  def initialize(file_path)
    @file_path = file_path
  end

  def history
    @history ||= load_history
  end

  def save_message(role, message)
    oneline_message = message.gsub(/\r?\n/, ' ')
    CSV.open(@file_path, 'a', force_quotes: true) do |csv|
      csv << [role, oneline_message]
    end
  end

  def clear_history
    CSV.open(@file_path, 'w', force_quotes: true) do |csv|
      csv << ['role', 'content']
    end
  end

  private

  def load_history
    history = [{ role: 'system', content: OpenaiConstants::OpenaiConstants.base_prompt }]
    return history unless File.exist?(@file_path)

    CSV.foreach(@file_path, headers: true) do |row|
      history << { role: row['role'], content: row['content'] }
    end
    history
  end
end
