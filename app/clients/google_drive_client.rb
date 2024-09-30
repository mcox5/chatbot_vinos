class GoogleDriveClient < GoogleClient
  def initialize
    super
  end

  def move_file(file_id, new_folder_id)
    file = drive_service.get_file(file_id, fields: 'parents')
    previous_parents = file.parents.join(',')
    drive_service.update_file(file_id, add_parents: new_folder_id, remove_parents: previous_parents)
  end

  def download_file(file_id, mime_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    file = StringIO.new
    drive_service.export_file(file_id, mime_type, download_dest: file)
    file.string
  end

  private

  def drive_service
    @drive_service ||= begin
      service = Google::Apis::DriveV3::DriveService.new
      service.client_options.application_name = Google.application_name
      service.authorization = @credentials
      Rails.logger.info 'Google Drive client created'
      service
    end
  end
end
