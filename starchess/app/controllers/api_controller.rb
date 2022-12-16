class ApiController < ApplicationController
  # version 1
  include Devise::Controllers::Helpers
  before_action :authenticate_request

  private
  def authenticate_request
    if request.filtered_parameters["starchess_game"] &&
       request.filtered_parameters["starchess_game"]["player1_id"] == -1 &&
       request.filtered_parameters["starchess_game"]["player2_id"] == -1
       return
    end
    # if request.fullpath == '/1/starchess_games' &&
    #   request.method == 'POST' &&
    #   return
    # end
    # request.env['warden'].authenticate! :scope => :user, :except => [:create]
  end
end
