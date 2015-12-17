# Objects of this class will have a HTTP message parsed into instance variables
 
class Parser
  attr_reader :method, :path, :version, :headers, :body, :response_status_code, :reason_phrase

  def initialize(message)
    parts = message.split(/\n\r*\n/, 2)
    @body = parts[1]

    initial_line = parts[0].split("\n", 2)[0]
    if initial_line.split(' ')[0] =~ /HTTP\/\d/
      @method, @path = nil
      @version, @response_status_code, @reason_phrase = initial_line.split(' ', 3)
    else
      @response_status_code, @reason_phrase = nil
      @method, @path, @version = initial_line.split(' ')[0..2]
    end

    headers = parts[0].split("\n")[1..-1]
    @headers = Hash.new
    headers.each do |line|
      h_v = line.split(/\s+/)
      @headers[h_v[0].chop] = h_v[1]
    end
  end
end