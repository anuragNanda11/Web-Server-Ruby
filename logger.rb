#Author: Anurag Nanda
=begin
The logger object records a single entry in the log file
(whose location is specified in the httpd.conf file), in the apache common log format.
members: file, filepath
methods: initialize( filepath ), write( request, response )
=end

require_relative 'Response'
require_relative 'Request'
require_relative 'HtaccessChecker'

class Logger

  def initialize(filepath)
    @filepath = filepath
    @filepath.tr!('"', '')
    if (File.file?(@filepath))
      @file = File.open(@filepath,'a')
    else
      raise "file not found"
    end
  end

  def log(request, response, ip, checker)
    ip.nil? ? ip_v ='-' : ip_v = ip
    rfc413Iden = '-'
    user_id= checker.username.nil?
    user_ id ='-' if user_id.nil?
    time = Time.now.strftime "%d/%m/%Y:%H:%M:%S %z"
    rqst = request.request_line.chomp


    size = response.content_length
    size = '-' if size.nil? || size == 0
    #"127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326"
   @file.puts %Q["#{ip_v} #{rfc413Iden} #{user_id} [#{time}] "#{rqst}" #{response.code} #{size}]
  end

end


