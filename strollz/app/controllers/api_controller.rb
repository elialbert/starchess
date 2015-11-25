class ApiController < RocketPants::Base
  version 1
  include Devise::Controllers::Helpers
  before_filter :authenticate_user!
end