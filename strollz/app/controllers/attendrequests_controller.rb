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
    @attendrequest.change_response(params.require(:attendrequest).permit(:response))
    expose({})
  end

  private
    def attendrequest_params
      params.require(:attendrequest).permit(:user_id, :event_id, :message, :response)
    end
end
