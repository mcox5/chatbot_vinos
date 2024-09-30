class GoogleAuthController < ApplicationController
  def callback
    @code = params[:code]
  end
end
