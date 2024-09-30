class GoogleGmailClient < GoogleClient
  def initialize
    super
  end

  def send_email(to, from, subject, body_text, attachment = nil, attachment_name = 'attachment.xlsx')
    message = RMail::Message.new
    message.header['To'] = to
    message.header['From'] = from
    message.header['Subject'] = subject

    # Crear la parte del cuerpo del mensaje
    body_part = RMail::Message.new
    body_part.body = body_text
    message.add_part(body_part)

    # Si hay un archivo adjunto, agregarlo como una parte del mensaje
    if attachment
      attachment_part = RMail::Message.new
      attachment_part.header.set('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      attachment_part.header.set('Content-Disposition', "attachment; filename=#{attachment_name}")
      attachment_part.body = attachment
      message.add_part(attachment_part)
    end

    # Enviar el mensaje usando GmailService
    gmail_service.send_user_message('me',
      upload_source: StringIO.new(message.to_s),
      content_type: 'message/rfc822')
  end

  private

  def gmail_service
    @gmail_service ||= begin
      service = Google::Apis::GmailV1::GmailService.new
      service.client_options.application_name = Google.application_name
      service.authorization = @credentials
      Rails.logger.info 'Google Gmail client created'
      service
    end
  end
end
