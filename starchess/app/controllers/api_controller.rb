class ApiController < RocketPants::Base
  version 1
  include Devise::Controllers::Helpers
  before_filter :authenticate_request

  private
  def authenticate_request
    request.env['warden'].authenticate! :scope => :user
  end
end