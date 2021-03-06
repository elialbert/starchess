class UsersController < ApiController
 
  def index
    expose User.where(id:current_user.id).paginate(:page => params[:page]), :include => :ratings
  end
  
  def show
    if current_user.id != params[:id].to_i
      error!(:forbidden)
    end
    expose User.find(params[:id]), :include => [:ratings, :attending, :created_events, :attend_requests]
  end

  def create
    @user = User.new(user_params)
    @user.save
    expose({}, {status: :created})
  end

  def update
    if current_user.id != params[:id].to_i
      error!(:forbidden)
    end
    @user = User.find(params[:id])
    @user.update(user_params)
    expose({})
  end

  private
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name)
    end
end
