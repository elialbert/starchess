class EventsController < ApplicationController
  version 1

  def index
    expose Event.paginate(:page => params[:page]), :include => :attendees
  end
  def show
    expose Event.find(params[:id]), :include => :attendees
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      expose({}, {status: :created})
    else
      expose(@event.errors, {status: 400})
    end
  end

  private
    def event_params
      params.require(:event).permit(:title,:description,:creator_id)
    end
end
