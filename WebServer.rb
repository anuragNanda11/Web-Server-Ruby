#author: Anurag Nanda
=begin
Webserver Object
Prior to beginning the infinite execution loop in start,
load mime and configuration files.
add members: mime_types, httpd_config
methods: read_config_file (should open, read lines from, and close a file
- this should get you the array
of lines to pass to the constructors of our config objects, defined below)
=end



class WebServer
  require 'socket'
  require_relative 'Response'
  require_relative 'Logger'
  require_relative 'Request'
  require_relative 'HttpdConfig'
  require_relative 'worker'
  require_relative 'MimeTypes'

  require 'java'

# 'java_import' is used to import java classes
  java_import 'java.util.concurrent.Callable'
  java_import 'java.util.concurrent.FutureTask'
  java_import 'java.util.concurrent.LinkedBlockingQueue'
  java_import 'java.util.concurrent.ThreadPoolExecutor'
  java_import 'java.util.concurrent.TimeUnit'

  def init
    @port
    @mime_types
    @httpd_config
    @logger
  end

  def read_config_file
    configs = IO.readlines("config/httpd.config").map(&:chomp)
    configs.select!{|line| line.index('#') != 0 && !line.empty?}
    @httpd_config = HttpdConfig.new(configs)
    @httpd_config.load
    @logger = Logger.new(@httpd_config.log_file)



    lines_from_mime_types = IO.readlines "config/mime.types"
    @mime_types = MimeTypes.new(lines_from_mime_types)
    @mime_types.load
  end



  def start
    read_config_file

    executor = ThreadPoolExecutor.new(10, # core_pool_treads
                                      10, # max_pool_threads
                                      10, # keep_alive_time
                                      TimeUnit::SECONDS,
                                      LinkedBlockingQueue.new)

    loop do
      puts 'server running'
      socket = server.accept
      task = FutureTask.new(Worker.new(socket, @httpd_config, @logger, @mime_types))
      executor.execute(task)
      #tasks = []
      #tasks<< task
      #worker = Worker.new(socket, @httpd_config, @logger, @mime_types)
      #worker.work
    end

  end

  def server
    @server ||= server = TCPServer.new('localhost',  @httpd_config.listen)
  end
end

if __FILE__ == $0
  instance = WebServer.new
  instance.read_config_file
  instance.start
end


