local cgi = {
	buffer = "",
	headers = {}
}

function cgi:body()
	if self.body then return self.body end
	self.body = io.stdin:read("*a")
	return self.body
end

function cgi:getheader(key)
	return os.getenv("HTTP_"..key:upper():gsub("%-", "_"))
end

function cgi:setheader(key, value)
	self.headers[key] = value
end

function cgi:write(data)
	self.buffer = self.buffer .. data
end

function cgi:clear()
	self.buffer = ""
	self.headers = {}
end

function cgi:send(status)
	if self.closed then
		--error("cannot send on closed connection")
		print("<br>")
		print("==========================================================<br>")
		print("ERROR: send after close<br>")
		print(debug.traceback():gsub("\n", "<br>\n").."<br>")
		print("==========================================================<br>\n<br>")
	end
	print("Status: "..status)
	for k, v in pairs(self.headers) do
		print(k..": "..v)
	end
	print("")
	print(self.buffer)
	self.closed = true
	self:clear()
end

function cgi:request()
	return os.getenv("REQUEST_METHOD"), os.getenv("REQUEST_URI")
end

return cgi