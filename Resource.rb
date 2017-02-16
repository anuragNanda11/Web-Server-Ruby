#Author: Evgeny Stukalov
=begin
This object will help us figure out where and what the requested resource is.
methods: initialize( uri, httpd_conf, mime_types), resolve, mime_type, script?
=end
require_relative 'Utils'


class Resource

  attr_reader :absolute_path

  def initialize(uri, httpd_conf, mime_types)
    @uri=uri
    @httpd_conf=httpd_conf
    @mime_types=mime_types
    @absolute_path
    @is_script=false
    @exists=true

    uri_dir=""
    @filename = "" # empty string in case there is no filename
  end

  def get_directory_index_filename(directory)
    @httpd_conf.directory_index.each do |potential_index_file|
      if File.exist?(directory + potential_index_file)
        return potential_index_file
      end
    end
    ""
  end
  
  def resolve
    if (@uri[@uri.length-1]) == "/"
      #directory
      uri_dir = @uri
    else
      uri_parts = @uri.split("/")
      @filename = uri_parts.pop
      uri_dir = uri_parts.join("/") + "/"
    end

    if @httpd_conf.alias[uri_dir]
      uri_dir=Utils.remove_quotations(@httpd_conf.alias[uri_dir][0])
    elsif @httpd_conf.script_alias[uri_dir]
      uri_dir=Utils.remove_quotations(@httpd_conf.script_alias[uri_dir][0])
      @is_script=true
    else
      # non-aliased
      uri_dir[0] = "" # remove the leading slash
      uri_dir = @httpd_conf.document_root + uri_dir
    end

    if @filename == ""
      @filename = get_directory_index_filename(uri_dir)
    end

    @absolute_path = uri_dir + @filename

    if @filename == "" || ! File.exist?(@absolute_path)
      # if the filename is still blank,
      # or file at absolute path doesnt exist, then resource doesnt exist
      @exists = false
    end
  end
  
  def mime_type
    extension = @filename.split(".").pop
    @mime_types.get(extension)
  end
  
  def script?
    @is_script
  end
  
  def exists?
    @exists
  end


end

if __FILE__ == $0

  instance = Resource.new("")
  instance.read_config_file
  instance.start
end