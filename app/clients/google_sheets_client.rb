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

    sheets_service.create_spreadsheet(spreadsheet).spreadsheet_id
  end

  def write_to_sheet(spreadsheet_id, range, values)
    value_range_object = Google::Apis::SheetsV4::ValueRange.new(values: values)
    sheets_service.update_spreadsheet_value(spreadsheet_id, range, value_range_object, value_input_option: 'RAW')
  end

  def read_last_row(spreadsheet_id, sheet_name)
    range = "#{sheet_name}!A2:P"
    response = sheets_service.get_spreadsheet_values(spreadsheet_id, range)
    response.values ? response.values.last : nil
  end

  def get_last_row_index(spreadsheet_id, sheet_name)
    range = "#{sheet_name}!A:A"
    response = sheets_service.get_spreadsheet_values(spreadsheet_id, range)
    response.values ? response.values.size + 1 : 1
  end

  private

  def sheets_service
    @sheets_service ||= begin
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = Google.application_name
      service.authorization = @credentials
      Rails.logger.info 'Google Sheets client created'
      service
    end
  end
end
