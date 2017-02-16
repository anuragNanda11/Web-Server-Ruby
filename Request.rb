#author: Anurag Nanda
=begin
Receives a stream (? for now, this is just to get us started...) in the constructor,
and parses the content of the stream into its members
members: verb/method, uri, version, headers (hash - key/value pairs of header name and header value), body (if it exists)
methods: parse
use: Request.new( stream ).parse
=end

require 'socket'
require 'uri'


class Request
  VERBS = ['PUT', 'POST' , "DELETE", "GET", "HEAD"]
  attr_reader :path, :request_line, :uri, :verb, :headers, :body, :bad_request,
              :query_string

  def initialize(socket)
    @socket   = socket
    @request_line
    @verb
    @uri
    @version
    @headers = Hash.new
    @bad_request = false
    @username = nil
    @ip = nil
  end



  #TODO need to figure out how to get the body
  #TODO need to make sure what is the story with '\r\n'

  def parse_internal


    line = @socket.gets
    puts line
    @request_line = line #store the request line for logging purposes.
    parts = line.split(' ')
    @verb = parts[0]
    temp = parts[1].split('?')
    @uri = temp[0]
    @query_string = temp[1]
    @protocol = parts[2].split('/')[0]
    @version = parts[2].split('/')[1]
    while (line = @socket.gets) && line.chomp != ''

      parts = line.split(':',2)
      @headers[parts[0]] = parts[1].strip
    end

    if @headers.key?("Content-Length")
      @body = @socket.recv(@headers["Content-Length"].to_i)
    end
  end #parse_internal

  def parse
    begin
      parse_internal
    rescue StandardError => error
      @bad_request = true
    else
      bad_request?
    end
  end #end parse




    def bad_request?
      if !VERBS.include? @verb || @protocol != 'HTTP' || @version != /[1]\.\d/ || @uri.nil?
        @bad_request = true
      end
    end




  def to_s
    return request_line
  end


  def requested_file()
    request_uri = @request_line.split(" ")[1]
    path =  URI.unescape(URI(request_uri).path)

    clean = []

    parts = path.split("/")

    parts.each do |part|
      next if part.empty? || part == '.'
      part == '..'?clean.pop : clean << part
    end

    File.join(WEB_ROOT, *clean)
  end #end requested_file

end #end class

if __FILE__ == $0
  x.testTime
end


