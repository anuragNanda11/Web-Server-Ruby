require_relative 'HtaccessChecker.rb'

headers = {"Authorization" => "Basic dXNlcm5hbWU6cGFzc3dvcmQ=", "WWW-Authenticate" => "Basic"}
# dXNlcm5hbWU6cGFzc3dvcmQ is 'username:password' but Base64 encoded
@hta = HtaccessChecker.new("public/public_html/protected", headers)

if @hta.protected?
	puts "hta is protected"
    if !@hta.can_authorize?
        puts "cannot authorize: 401"
    elsif !@hta.authorized?
        puts "cannot authorize user: 403"
    else
    	puts "authorized"
    end
end