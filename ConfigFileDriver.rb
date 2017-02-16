# we can use this to test HttpdConfig.rb and MimeTypes.rb
require_relative 'HttpdConfig'
require_relative 'MimeTypes'
require_relative 'Resource'
class ConfigFileDriver

    def start
        lines_from_mime_types = IO.readlines "config/mime.types"
        lines_from_httpd_config = IO.readlines "config/httpd.config"

        #lines_from_httpd_config.each { |line| puts line }

        httpd_config = HttpdConfig.new( lines_from_httpd_config )
        httpd_config.load
#        puts httpd_config.get("DocumentRoot")

        mime_types = MimeTypes.new( lines_from_mime_types )
        mime_types.load
        assert_equal(mime_types.get("html"), "text/html")
        # puts mime_types.get("html")
        
        resource = Resource.new("/" ,httpd_config,mime_types)
        puts resource.resolve
        puts resource.mime_type()
        puts resource.script?()
          
        resource = Resource.new("/index.html" ,httpd_config,mime_types)
        puts resource.resolve 
        puts resource.mime_type()
        puts resource.script?()
        
        resource = Resource.new("/dir/" ,httpd_config,mime_types)
        puts resource.resolve
        
        resource = Resource.new("/dir/index.html" ,httpd_config,mime_types)
        puts resource.resolve
        puts resource.exists?
        
        resource = Resource.new("/aliastest/" ,httpd_config,mime_types)
        puts resource.resolve
        puts resource.exists?
              
        resource = Resource.new("/aliastest/index.html" ,httpd_config,mime_types)
        puts resource.resolve
      
        
        resource = Resource.new("/ab/index.html" ,httpd_config,mime_types)
        puts resource.resolve 
    
        resource = Resource.new("/ab/" ,httpd_config,mime_types)
        puts resource.resolve 
        
        resource = Resource.new("/~traciely/" ,httpd_config,mime_types)
        puts resource.resolve 
        
        resource = Resource.new("/cgi-bing/" ,httpd_config,mime_types)
        puts resource.resolve 
              
        resource = Resource.new("/cgi-bin/" ,httpd_config,mime_types)
        puts resource.resolve 
              
        resource = Resource.new("/cgi-bin/script.sh" ,httpd_config,mime_types)
        puts resource.resolve 
        puts resource.mime_type()
        puts resource.script?()
          
    end

    ConfigFileDriver.new().start
end
