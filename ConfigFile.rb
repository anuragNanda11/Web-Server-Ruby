#author: Maximilian Fischer
=begin
ConfigFile super class
parent class for HttpdConfig.rb and MimeTypes.rb
contains process_lines method which parses configuration files 
and returns a hash with its content
=end

class ConfigFile

	def initialize(file_string)
		@lines = file_string
	end

	def process_lines
	#file_string is a string array,
		needed_lines = []
		@lines.each do |line|
			#filters empty lines and comments
			unless line.strip.length == 0 || line[0] == '#' 
				needed_lines << line
			end
		end

		@hash = {}
		@hash["Alias"] = {}
		@hash["ScriptAlias"] = {}

		needed_lines.map do |line| #splits every line at empty spaces
			line = line.split(" ")

			if line[0] ==  "Alias"
				# hash entry for 'Alias' is another hash; 
				#add symbolic path as key for absolute path
				@hash["Alias"][line[1]] = line.drop(2)

			elsif line[0] ==  "ScriptAlias" # ScriptAlias has index 0, just like Alias
				# hash entry for 'ScriptAlias' is another hash; 
				#add symbolic path as key for absolute path
				@hash["ScriptAlias"][line[1]] = line.drop(2)
				  
      elsif line[0] ==  "DirectoryIndex"
        @hash["DirectoryIndex"] = line.drop(1)

			else
				# other configuration options
				@hash[line[0]] = line[1] 
				# we only need one value for everything except Alias, ScriptAlias, and DirectoryIndex
				# otherwise if we use "drop" we get an array
			end

		end

		return @hash
	end
end
