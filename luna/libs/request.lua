local headers = setmetatable({}, {__index=function(_, index)
	local name = index:upper():gsub("%-", "_")
	return os.getenv("HTTP_"..name)
end})

local function url_unescape(str)
	return str:gsub("%%%x%x", function(match)
		return string.char(match:sub(2), 16)
	end)
end

local function decode_query(str)
	local args = {}
	for key, value in str:gmatch("(.+)+=([^&]+)") do
		args[key] = url_unescape(value)
	end
end

local req = {
	_SERVER = {
		software = os.getenv("SERVER_SOFTWARE"),
		hostname = os.getenv("SERVER_NAME"),
		gateway_interface = os.getenv("GATEWAY_INTERFACE"),
		protocol = os.getenv("SERVER_PROTOCOL"),
		port = tonumber(os.getenv("SERVER_PORT") or "", 10)
	},
	REQUEST = {
		headers = headers,
		method = os.getenv("REQUEST_METHOD"),
		path_info = os.getenv("PATH_INFO"),
		path_translated = os.getenv("PATH_TRANSLATED"),
		script_name = os.getenv("SCRIPT_NAME"),
		remote_host = os.getenv("REMOTE_HOST"),
		remote_addr = os.getenv("REMOTE_ADDR"),
		auth_type = os.getenv("AUTH_TYPE"),
		remote_user = os.getenv("REMOTE_USER"),
		remote_ident = os.getenv("REMOTE_IDENT"),
		content_type = os.getenv("CONTENT_TYPE"),
		content_length = tonumber(os.getenv("CONTENT_LENGTH") or "", 10),
		body = io.stdin
	},
	RESULT = {
		status = 200,
		headers = {
			["Content-Type"] = "text/html"
		}
	}
}

if os.getenv("QUERY_STRING") then
	req.REQUEST.query_args = decode_query(os.getenv("QUERY_STRING"))
end

if req.REQUEST.method == "GET" and req.REQUEST.content_type =="application/x-www-form-urlencoded" then
	local d = io.stdin:read("*a")
	req.REQUEST.form_args = decode_query(d)
end

return req