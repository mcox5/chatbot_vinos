class GoogleSheetsClient < GoogleClient
  def initialize
    super
  end

  def create_spreadsheet(title)
    spreadsheet = {
      properties: {
        title: title
      }
    }

    begin
      sheets_service.create_spreadsheet(spreadsheet).spreadsheet_id
    rescue StandardError => e
      raise GoogleError::CreateSpreadsheetGoogleError, "Error creating spreadsheet: #{e.message}"
    end
  end

  def write_to_sheet(spreadsheet_id, range, values)
    value_range_object = Google::Apis::SheetsV4::ValueRange.new(values: values)

    begin
      sheets_service.update_spreadsheet_value(spreadsheet_id, range, value_range_object, value_input_option: 'RAW')
    rescue StandardError => e
      raise GoogleError::WriteToSheetGoogleError, "Error writing to sheet: #{e.message}"
    end
  end

  def read_last_row(spreadsheet_id, sheet_name)
    range = "#{sheet_name}!A2:P"

    begin
      response = sheets_service.get_spreadsheet_values(spreadsheet_id, range)
      response.values ? response.values.last : nil
    rescue StandardError => e
      raise GoogleError::ReadSheetGoogleError, "Error reading last row: #{e.message}"
    end
  end

  def get_last_row_index(spreadsheet_id, sheet_name)
    range = "#{sheet_name}!A:A"

    begin
      response = sheets_service.get_spreadsheet_values(spreadsheet_id, range)
      response.values ? response.values.size + 1 : 1
    rescue StandardError => e
      raise GoogleError::ReadSheetGoogleError, "Error getting last row index: #{e.message}"
    end
  end

  private

  def sheets_service
    @sheets_service ||= begin
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = GoogleLib::Google.application_name
      service.authorization = @credentials
      Rails.logger.info 'Google Sheets client created'
      service
    end
  end
end
