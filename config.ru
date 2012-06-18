require 'sinatra'
require 'active_support/core_ext'
require 'pusher'

require 'base64'
require 'ipaddr'

Pusher.app_id ='22446'
Pusher.key = '427a8908c6541ab6f357'
Pusher.secret = ENV["PUSHER_SECRET_KEY"]
CHALLENGE_HMAC_SECRET = Base64.decode64(ENV["CHALLENGE_HMAC_SECRET"])

auths = {}

get '/remote/:handshake_id' do
  [200, {'Content-Type' => 'application/json; charset=utf-8'}, auths[params[:handshake_id]].to_json]
end

post '/remote/:handshake_id' do
  Pusher['remote-response'].trigger(params[:handshake_id], {:auth_request => request.body.read})
  [200, {'Content-Type' => 'application/json; charset=utf-8'}, ""]
end

post '/local/:handshake_id' do
  auths[params[:handshake_id]] = {
    :username => params[:username],
    :challenge => params[:challenge],
    :request_url => params[:request_url]
  }

  [200, {'Content-Type' => 'application/json; charset=utf-8'}, ""]
end

get '/' do
  [200, {'Content-Type' => 'text/html'}, %{

<!DOCTYPE html>

<html>
    <head>
        <title>Hello Octokey!</title>
        <script src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
        <script>
           jQuery(function () {
               $('form').submit(function (e) {
                   alert('foo');
                   e.stopPropagation();
                   e.preventDefault();
               });
           });
        </script>
    </head>
    <body>
        <form class="octokey ajax-form">
            <input type="text" name="session_key" class="octokey-username"/>
            <input type="text" name="session_password" class="octokey-password"/>
            <input type="hidden" class="octokey-challenge-url" value="/challenge"/>
            <input type="hidden" class="octokey-api-url" value="/octokey"/>
            <input type="submit" value="Go!">
        </form>
    </body>
</html>
  }]

end

get '/challenge' do

  # TODO: blindly trusting X-Forwarded-For headers is a bad idea.
  # HACK using quick-deploy stack IP for now
  remote_ip = IPAddr.new("172.18.158.41" || request.env['HTTP_X_FORWARDED_FOR'] || request.env['REMOTE_ADDR'])

  buffer = "".force_encoding('BINARY')

  buffer << "\x01" # protocol version 1.

  # milliseconds since the epoch
  time = (Time.now.to_f * 1000).to_i

  # 64-bit number in network ordering
  # (not possible to use Q> because it doesn't exist in ruby-1.9.2)
  buffer << [time >> 32 & 0xffffffff, time & 0xffffffff].pack("NN")

  if remote_ip.ipv4?
    buffer << "\x04" # IP version 4
    buffer << [remote_ip.to_i].pack("N")
  else
    raise "Only IPv4 addresses are supported"
  end

  buffer << SecureRandom.random_bytes(32)

  buffer << OpenSSL::HMAC.digest("sha1", CHALLENGE_HMAC_SECRET, buffer)

  [200, {}, Base64.encode64(buffer).gsub("\n", "")]
end

run Sinatra::Application
