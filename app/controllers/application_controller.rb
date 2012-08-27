class ApplicationController < ActionController::Base
  protect_from_forgery

  around_filter :pry_rescue if Rails.env == 'development'

  def pry_rescue
    Pry::rescue{ yield }
  end

  private

  def octokey_username
    Octokey.login(params[:auth_request], :client_ip => client_ip, :valid_hostnames => valid_hostnames) do |username|
      User.find_by_email(username).public_keys.split("\n")
    end
  end

  def octokey_signup
    Octokey.signup(params[:auth_request], :client_ip => client_ip, :valid_hostnames => valid_hostnames) { }
  end

  def valid_hostnames
    ["localhost", "octokey.herokuapp.com", "octokey.com"]
  end


  def client_ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.env['REMOTE_ADDR']
  end
end
