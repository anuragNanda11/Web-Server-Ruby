#author: Anurag Nanda
=begin
The response factory encapsulates the logic that is responsible for determining the
appropriate response to send to the client (following the workflow diagram discussed in class).
The ResponseFactory will have a single static (class) method,
create( request, resource ) that will return a properly constructed Response object.
=end
require_relative 'Response'
require_relative 'Resource'
require_relative 'HtaccessChecker'
require 'time'

class ResponseFactory





  def self.create(request, resource, checker)
    response = Response.new
    username = nil
    if(checker.protected?)
      if !(checker.can_authorize?)

        response.code = 401
        return response
      end

      if !(checker.authorized?)
        response.code  = 403
        response.headers['Content-Length'] = 0
        return response
      end
      username = checker.username
    end

    if request.bad_request
      response.code = 400
      return response
    end

    if resource.script?
      puts "its a script"
      return scripted_response(request, resource,username)
    end
    return(send(request.verb.downcase,*[request, resource]))
  end #self.create

  def self.head(request, resource)
      response = Response.new
      if !(File.file?(resource.absolute_path))
        response.code = 404
        return response
      end
      response.code = 200
      response.headers["Content-Type"] = resource.mime_type
      mod_date = File.stat(resource.absolute_path).mtime
      response.headers["Age"] = (Time.now - mod_date).to_i
      date = DateTime.strptime('2020-02-03T04:05:06+07:00', '%Y-%m-%dT%H:%M:%S%z')
      response.headers["Expires"] = date
      response.headers["Last-Modified"] = mod_date.httpdate
      return response
  end #end head


  def self.get(request, resource)


    response = self.head(request, resource)
    rq_headers = request.headers

    mod_date = File.stat(resource.absolute_path).mtime.httpdate

    if rq_headers["If-Modified-Since"]== mod_date
      response.code = 304
      return response
    end

    response.headers['Content-Length'] = File.size(resource.absolute_path)
    response.body = IO.read(resource.absolute_path)
    return response
  end #self.get


  def self.delete(request, resource)
    if !(File.file?(resource.absolute_path))
      response.code = 404
      return response
    end
    response = Response.new
    File.delete(resource.absolute_path)
    response.code = 204
    return response
  end

  def self.put(request, resource)
    response = Response.new
    File.open(resource.absolute_path, 'a+'){|f| f.write(request.body)}
    response.code = 201
    return response
  end


  def self.post(request, resource)
    put(request, resource)
  end


  def self.scripted_response(request, resource, username)
    response = Response.new
    response.code = 200
    response.script = true
    env_v  = Hash.new
    env_v['REQUEST_METHOD'] = request.verb
    env_v['DOCUMENT_ROOT'] = '\public'
    env_v.store('REMOTE_USER',username) if !username.nil?
    env_v.store('QUERY_STRING',request.query_string)

    request.headers.each do |key, value|
      env_v["HTTP_#{key.upcase}"] = value
    end
    IO.popen([env_v,resource.absolute_path]) {|io| response.body = io.read}
    return response
  end





end #ResponseFactory




if __FILE__ == $0

end