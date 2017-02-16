class HeadersCollection
	def initialize
		@headers = {}
	end

	def add(key, value)
		@headers[key] = value
	end

	def to_s
		@headers.map do |key, value|
			"#{key}: #{value}"
		end
	end
end