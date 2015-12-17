# A simple command-line browser that can send POST or GET requests on two html files.

require 'socket'
require 'json'
require './parser.rb'

host = 'localhost'
port = 3000
get_path = '/index.html'
post_path = '/thanks.html'
version = 'HTTP/1.0'
request = ''

print "What kind of request do you want to send?: "
loop do
  command = gets.chomp
  case command
  when 'GET'
   request = "GET #{get_path} #{version}\r\n\r\n";
   break
  when 'POST'
    print "Enter name: "
    name = gets.chomp
    print "Enter email: "
    email = gets.chomp
    info = {:poster => {:name=>name, :email=>email}}.to_json
    request = "POST #{post_path} #{version}\r\nContent-Length: #{info.bytesize}\r\n\r\n#{info}"
    break
  else print "Sorry, you can only GET or POST. Try again: "
  end
end

socket = TCPSocket.open(host, port)
socket.print(request)
response = socket.read
message = Parser.new(response)
if message.response_status_code == '200'
  puts message.body
else
  puts "#{message.response_status_code} #{message.reason_phrase}"
end
