class UsersController < RocketPants::Base
  version 1
  caches :index, :show, :cache_for => 5.seconds

  def index
    expose User.paginate(:page => params[:page]), :include => :ratings
  end
  def show
    expose User.find(params[:id]), :include => [:ratings, :attending, :created_events, :attend_requests]
  end

  def create
    @user = User.new(user_params)
    @user.save
    expose({}, {status: :created})
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    expose({})
  end

  private
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name)
    end
end
