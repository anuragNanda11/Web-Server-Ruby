=begin
MimeTypes Object

Parses and stores the information from the mime.types file.  Sample instantiation:
mime_types = MimeTypes.new( lines )
mime_types.load # or, return a reference to self from load,
so you can chain these in the line above
members: mime_types (hash with extension keys, and mime type values)
methods: process_lines, for( extension )
=end

require_relative 'ConfigFile'
class MimeTypes < ConfigFile


	def load
		@mime_types = process_lines()
	end

	def get(extension)
		@mime_types[extension]
	end
end
