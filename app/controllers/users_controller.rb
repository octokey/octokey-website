class UsersController < ApplicationController

  layout 'website'

  def index
    redirect_to :new_user
  end

  def new
  end

  def create
    email, public_key = octokey_signup
    user = User.create!(
      :email => email,
      :public_keys => public_key,
      :name => params[:name]
    )

    redirect_to user_url(user)
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
  end

  def challenge
    render :text => Octokey.new_challenge(:client_ip => client_ip)
  end
end
