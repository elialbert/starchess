class RatingsController < ApplicationController
  version 1

  def index
    expose Rating.paginate(:page => params[:page])
  end
  def show
    expose Rating.find(params[:id])
  end

  def create
    @rating = Rating.new(rating_params)
    if @rating.save
      expose({}, {status: :created})
    else
      expose(@rating.errors, {status: 400})  
    end
  end

  def update
    @rating = Rating.find(params[:id])
    @rating.update(params.require(:rating).permit(:score, :blurb))
    expose({})
  end

  private
    def rating_params
      params.require(:rating).permit(:user_from_id, :user_to_id, :score, :blurb, :event_id)
    end
end
