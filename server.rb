# 

require 'socket'
require 'json'
require './parser.rb'

# Handles newlines in client requests
# Loops #gets until double newline is encountered,
#   then read the body (if it exists) using Content-Length value
def read_client(client)
  request = ''
  while line = client.gets
    request += line
    break if request =~ /\n\r*\n/
  end

  message = Parser.new(request);
  if length = message.headers['Content-Length']
    return Parser.new(request + client.gets(length.to_i))
  else
    return message
  end
end

server = TCPServer.open(3000)
loop do
  client = server.accept
  message = read_client(client)
  version = "HTTP/1.0"

  case message.method
  when 'GET'
    if File.exist?(".#{message.path}")
      body = File.open(".#{message.path}").read
      client.puts("#{version} 200 OK\r\nContent-Length: #{body.bytesize}\r\n\r\n#{body}")
    else
      client.puts("#{version} 404 Not Found")
    end
  when 'POST'
    # JSON::parse converts symbols to strings by default
    params = JSON.parse(message.body, {:symbolize_names => true})
    if File.exist?(".#{message.path}")
      body = File.open(".#{message.path}").read
      list = "<li>Name: #{params[:poster][:name]}</li>\n\t<li>Email: #{params[:poster][:email]}</li>"
      client.puts("#{version} 200 OK\r\nContent-Length: #{body.bytesize}\r\n\r\n#{body.sub('<%= yield %>', list)}")
    else
      client.puts("#{version} 404 Not Found")
    end
  when 'OPTIONS', 'HEAD', 'PUT', 'DELETE', 'TRACE', 'CONNECT'
    client.puts("#{version} 501 Not Implemented")
  else
    client.puts("#{version} 400 Bad Request")
  end

  client.close
end