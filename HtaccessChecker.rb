#author: Maximilian Fischer
=begin
HtaccessChecker object
The HtaccessChecker is responsible for determining if a given resource is 
protected, if it can be authorized (the username and password were included), 
and if authorization succeeded (the username and password were correct).
	
initialize(path, request_headers)
protected?
can_authorize? (have the authorization headers)
authorized? (have the headers and it’s a valid username and password)
	
=end

require "base64"
require "digest"

class HtaccessChecker
	attr_reader :username

	def initialize(path, headers)
		# relative path with format "firstdirectory/seconddirectory/.../lastdirectory"
		@path = path
		@headers = headers
	end

	def protected?
		return File.exist?("#{@path}/.htaccess")
	end

	def authorized?

		@usrpswd = getProvidedUsernamePassword()
		@username = @usrpswd[0]


		@password = @usrpswd[1]


		@savedPasswords = getSavedPasswords()

		if !@savedPasswords.key?(@username)
			return false
		end


		@compare_string = @savedPasswords[@username].gsub(/{SHA}/, '')

		return Digest::SHA1.base64digest(@password) == @compare_string
	end

	def can_authorize?
		return @headers.key?("Authorization")
	end

	def getProvidedUsernamePassword()
		@AuthorizationHeader = @headers["Authorization"]
		#get rid of the "Basic" in front of the encoded username & password
		@encryptedUsernamePassword = @AuthorizationHeader.split(" ")[1]
		@usernamepassword = Base64.decode64(@encryptedUsernamePassword)
		return @usernamepassword.split(":")
	end

	def getSavedPasswords()
		htaccess_file = readFile("#{@path}/.htaccess", " ")
		htpasswd_path = htaccess_file["AuthUserFile"]
		htpasswd_file = readFile(htpasswd_path, ":")
		return htpasswd_file
	end

	def readFile(path, separator) # returns array with the lines of the file
		path.delete! '"'
		File.chmod(0755, path) # allowed?

		file = {}
		File.open(path) do |filepath|
  			filepath.each do |line|
    			key, value = line.chomp.split(separator)
		    	file[key] = value
  			end
		end
		# change file permissions back?
		return file
	end

end