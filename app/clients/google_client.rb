require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

OOB_URI = 'http://127.0.0.1:3000/'.freeze
CLIENT_SECRETS_PATH = Rails.root.join('config', 'google', 'client_secret.json').freeze
TOKEN_PATH = Rails.root.join('config', 'google', 'token.yaml').freeze
SCOPE = [
  Google::Apis::SheetsV4::AUTH_SPREADSHEETS,
  Google::Apis::GmailV1::AUTH_GMAIL_SEND,
  Google::Apis::DriveV3::AUTH_DRIVE
].freeze

class GoogleClient < BaseClient
  def initialize
    @credentials = authorize
  end

  def authorize
    client_id = Google::Auth::ClientId.from_file CLIENT_SECRETS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = "default"
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " \
           "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end
end
