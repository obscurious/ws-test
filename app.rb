require_relative 'models'

require 'roda'
require 'faye/websocket'

class Wassal < Roda
  opts[:unsupported_block_result] = :raise
  opts[:unsupported_matcher] = :raise
  opts[:verbatim_string_matcher] = true

  plugin :default_headers,
    'Content-Type'=>'text/html',
    'Content-Security-Policy'=>"connect-src 'self' ws: default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com",
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'

  use Rack::Session::Cookie,
    :key => '_Wassal_session',
    #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    :secret=>File.read('.session_secret')

  plugin :csrf
  plugin :render, :escape=>:erubi
  plugin :multi_route
  plugin :websockets, :ping=>45

  Unreloader.require('routes'){}

  MUTEX = Mutex.new
  ROOMS = {}

  def sync
    MUTEX.synchronize{yield}
  end

  route do |r|
    r.multi_route
    r.get "room", :d do |room_id|
      room = sync{ROOMS[room_id] ||= []}

      r.websocket do |ws|
        # Routing block taken if request is a websocket request,
        # yields a Faye::WebSocket instance

        ws.on(:message) do |event|
          sync{room.dup}.each{|user| user.send(event.data)}
        end

        ws.on(:close) do |event|
          sync{room.delete(ws)}
          sync{room.dup}.each{|user| user.send("Someone left")}
        end

        sync{room.dup}.each{|user| user.send("Someone joined")}
        sync{room.push(ws)}
      end

      # If the request is not a websocket request, execution
      # continues, similar to how routing in general works.
      view 'index'
    end
    r.root do
      view 'index'
    end
  end

end
