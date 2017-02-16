#Author: Anurag Nanda
=begin
Worker object
The worker is responsible for handling a single request/response cycle,
and logging that cycle. The request will be parsed from the stream
(as in previous deliverables), but the response will now be
generated using a ResponseFactory.
members: client(a reference to the stream that the server received a new request on),config, logger
=end
require_relative 'response_factory'
require_relative 'Resource'
require_relative 'Request'

require 'java'

# 'java_import' is used to import java classes
java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'

class Worker
  include Callable

  def call
    work
  end
  # @param [Socket] socket
  # @param [httpd_config] config
  # @param [Logger] logger
  def initialize(socket,config,logger,mime_types)
    @socket = socket
    @config = config
    @logger = logger
    @mime_types = mime_types
  end

  def work
    begin
    request = Request.new(@socket)
    request.parse
    resource = Resource.new(request.uri,@config, @mime_types)
    resource.resolve
    checker = HtaccessChecker.new(resource.absolute_path,request.headers)
    response = ResponseFactory.create(request, resource,checker)
    rescue StandardError => error
      STDERR.puts error
      socket.print 'HTTP/1.1 500 Internal Server Error'
      @socket.close
    else
      response.write_to_Socket(@socket)
      port, ip = Socket.unpack_sockaddr_in(@socket.getpeername)
      @logger.log(request, response, ip ,checker)
      @socket.close
      puts '--------------------------------------------'
    end



  end

end

if __FILE__ == $0

end