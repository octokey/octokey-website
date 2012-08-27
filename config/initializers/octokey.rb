Octokey::Config.hmac_secret = ENV["OCTOKEY_HMAC_SECRET"] or raise "no OCTOKEY_HMAC_SECRET set"
Octokey::Config.valid_hostnames = ["thinkpad.jelzo.com"]
Octokey::Config.public_keys{ |username, opts|
  User.where(:email => username).map(&:public_keys)
}
