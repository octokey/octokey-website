class UsersController < ApplicationController

  def index
    redirect_to :new_user
  end

  def new
  end

  def create
    signup = Octokey.new(params['auth_request'],
                         :username => params['username'],
                         :client_ip => client_ip)

    if signup.can_sign_up?
      user = User.create!(
        :email => signup.username,
        :public_keys => signup.public_key,
        :name => params[:name]
      )

      redirect_to user_url(user)
    elsif signup.should_retry?
      redirect_to new_user_url
    else
      puts signup.errors
      raise "go away"
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    login = Octokey.new(params['auth_request'],
                         :username => params['username'],
                         :client_ip => client_ip)
    if login.can_log_in?
      @user = User.find(params[:id])
    elsif login.should_retry?
      redirect_to user_url(params[:id])
    else
      puts login.errors
      raise "go away"
    end
  end

  def challenge
    render :text => Octokey.new_challenge(:client_ip => client_ip)
  end
end
