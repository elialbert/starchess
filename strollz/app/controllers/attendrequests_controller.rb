class AttendrequestsController < ApplicationController
   version 1

  def index
    expose Attendrequest.paginate(:page => params[:page])
  end
  def show
    expose Attendrequest.find(params[:id])
  end

  def create
    @attendrequest = Attendrequest.new(attendrequest_params)
    if @attendrequest.save
      expose({}, {status: :created})
    else
      expose(@attendrequest.errors, {status: 400})  
    end
  end

  def update
    @attendrequest = Attendrequest.find(params[:id])
    params = attendrequest_update_params
    if !Attendrequest.responses.values.include? params['response'].to_i
      error!(:invalid_resource, "response can only be 0, 1 or 2")
    end
    @attendrequest.change_response(params)
    expose({})
  end

  private
    def attendrequest_params
      params.require(:attendrequest).permit(:user_id, :event_id, :message, :response)
    end
    def attendrequest_update_params
      params.require(:attendrequest).permit(:response)  
    end
end
