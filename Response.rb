#author: Anurag Nanda
require_relative 'Request'

=begin
Response Object

Generates a generic OK response to send to the client

members: version, response code, response phrase, headers, body
methods: to_s



  HTTP/1.x 200 OK
  Transfer-Encoding: chunked
  Date: Sat, 28 Nov 2009 04:36:25 GMT
  Server: LiteSpeed
  Connection: close
  X-Powered-By: W3 Total Cache/0.8
  Pragma: public
  Expires: Sat, 28 Nov 2009 05:36:25 GMT
  Etag: "pub1259380237;gz"
  Cache-Control: max-age=3600, public
  Content-Type: text/html; charset=UTF-8
  Last-Modified: Sat, 28 Nov 2009 03:50:37 GMT
  X-Pingback: http://net.tutsplus.com/xmlrpc.php
  Content-Encoding: gzip
  Vary: Accept-Encoding, Cookie, User-Agentreq


=end
require 'time'
class Response

  PHRASES = {
      200 => 'OK',
      201 => 'Created',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found'
  }

  HEADER_COL = {
      'Server'=> 'Team9server',
      'Content Language' => 'en',
      'Connection' => 'close',
      'WWW-Authenticate'=>'Basic realm="server9Realm"'

  }


  attr_accessor :headers, :script, :content_length, :code
  attr_reader :response_line, :body

  def initialize(*args)
    @code
    @ver = '1.1'
    @headers = Hash.new()
    @content_type
    @body
    @content_length = 0
    time = Time.now
    @date = time.httpdate
    @script = false
  end

  def get_response_line
    "HTTP/#{@ver} #{@code} #{PHRASES[@code]}"
  end



  def write_to_Socket(socket)
    socket.print "HTTP/#{@ver} #{@code} #{PHRASES[@code]}\r\n"
    if !@script
      socket.print "Date: #{@date}\r\n"
                     #"Content-Type: #{@content_type}\r\n"
      @headers.each do |key, value|
        socket.print "#{key} : #{value}\r\n"
      end
      HEADER_COL.each do |key,value|
        socket.print "#{key} : #{value}\r\n"
      end
    end
    socket.print "\r\n"
    socket.print @body
  end #end write_to_socket

# custom setter method
  def body=(new_body)
    @body = new_body
    @content_length = @body.bytesize
  end


end





  if __FILE__ == $0
    instance = Response.new
    instance.code = 200
  end






