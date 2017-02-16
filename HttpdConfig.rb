#author: Maximilian Fischer
=begin
HttpdFile object
A file that provides configuration options for the server in a 
key value formate=, 
where the first entry on each line is the configuration option, 
and the second is the configuration value. 
=end

require_relative 'ConfigFile'
require_relative 'Utils'
class HttpdConfig < ConfigFile

	attr_reader :server_root, :listen, :document_root, :log_file, :alias
	attr_reader :script_alias, :access_file_name, :directory_index

	def load
		@config = process_lines()
		@server_root = @config["ServerRoot"]
		@listen = @config["Listen"]
		  
		  
		  
		@document_root = Utils.remove_quotations(@config["DocumentRoot"])
		@log_file = @config["LogFile"]
		@alias = @config["Alias"] # => hash
		@script_alias = @config["ScriptAlias"] # => hash
		@access_file_name = @config["AccessFileName"]
		@directory_index = @config["DirectoryIndex"]
	end
end