module GoogleError
  class BaseGoogleError < StandardError; end
  class AuthenticationGoogleError < BaseGoogleError; end
  class SendGmailGoogleError < BaseGoogleError; end
  class CreateSpreadsheetGoogleError < BaseGoogleError; end
  class WriteToSheetGoogleError < BaseGoogleError; end
  class ReadSheetGoogleError < BaseGoogleError; end
  class DownloadFileGoogleError < BaseGoogleError; end
  class MoveFileGoogleError < BaseGoogleError; end
end

module WhatsAppError
  class BaseWhatsappError < StandardError; end
  class SendMessageWhatsappError < BaseWhatsappError; end
end

module OpenaiError
  class BaseOpenaiError < StandardError; end
  class ChatAnswerOpenaiError < BaseOpenaiError; end
end
