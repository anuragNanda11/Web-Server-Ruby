#Author: Evgeny Stukalov
=begin
methods useful in various areas of the app
=end

class Utils
  def self.remove_quotations(str)
    if str[0] == '"'
      str = str.slice(1..-1)
    end
    if str[str.length-1] == '"'
      str = str.slice(0..-2)
    end
    str
  end
end