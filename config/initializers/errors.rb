module GoogleError
  class BaseGoogleError < StandardError; end
  class AuthenticationGoogleError < BaseGoogleError; end
end
