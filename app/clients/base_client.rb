class BaseClient
  protected

  def net_http
    Net::HTTP
  end

  private

  def get_request(uri, error_to_raise, headers = {})
    req = Net::HTTP::Get.new(uri)
    add_headers(req, headers)
    response = make_request(req)
    log_request("GET", uri, response)
    check_response(response, error_to_raise)
  end

  def post_request(uri, request_body, error_to_raise, headers = {})
    req = create_post(uri, request_body)
    add_headers(req, headers)
    response = make_request(req)
    log_request("POST", uri, response)
    check_response(response, error_to_raise)
  end

  def create_post(uri, request_body)
    req = Net::HTTP::Post.new(
      uri,
      'Content-Type' => 'application/json'
    )
    req.body = request_body
    req
  end

  def put_request(uri, request_body, error_to_raise, headers = {})
    req = create_put(uri, request_body)
    add_headers(req, headers)
    response = make_request(req)
    log_request("PUT", uri, response)
    check_response(response, error_to_raise)
  end

  def create_put(uri, request_body)
    req = Net::HTTP::Put.new(
      uri,
      'Content-Type' => 'application/json'
    )
    req.body = (request_body || {}).to_json
    req
  end

  def log_request(method, url, response)
    Rails.logger.info(
      "[#{self.class.name}] #{method.upcase} request to url=#{url} " \
      "answered with status=#{response.code} and body=#{response.body}"
    )
  end

  def check_response(response, error_to_raise)
    return response if response.is_a?(Net::HTTPSuccess)

    raise error_to_raise,
          { error: error_to_raise, response_body: response.body, status: response.code }
  end

  def add_headers(req, headers)
    if headers.present?
      headers.each do |key, value|
        req[key] = value
      end
    end
  end

  def make_request(req)
    net_http.start(req.uri.hostname, req.uri.port, use_ssl: req.uri.scheme == 'https') do |http|
      http.request(req)
    end
  end
end
