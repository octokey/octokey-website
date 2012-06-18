require 'sinatra'
require 'active_support/core_ext'
require 'pusher'

Pusher.app_id ='22446'
Pusher.key = '427a8908c6541ab6f357'
Pusher.secret = ENV["PUSHER_SECRET_KEY"]

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
  [200, {}, '{"challenge":"super-secret"}']
end

run Sinatra::Application
