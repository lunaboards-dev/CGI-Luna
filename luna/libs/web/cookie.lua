local utils = require("utils")
local cookie = {}

function cookie.parse(inst)
	local cookies = inst:getheader("Cookie")
	if not cookies then return {} end
	local map = {}
	for k, v in cookies:gmatch("([^=]+)=([^;]+)") do
		map[k] = utils.url_unescape(v)
	end
	return map
end

local translate = {
	domain = "Domain",
	expires = "Expires",
	http_only = "HttpOnly",
	max_age = "Max-Age",
	partitioned = "Partitioned",
	path = "Path",
	secure = "Secure",
	same_site = "SameSite"
}

function cookie.set(inst, key, value, params)
	local cookies = inst:getsentheader("Set-Cookie")
	if not cookies then
		cookies = {}
		inst:setheader("Set-Cookie", cookies)
		inst.cookies = {}
	end
	local str = string.format("%s=%s", key, utils.http_escape(tostring(value)))
	for k, v in pairs(params) do
		str = str .. "; " .. (translate[k] or k)
		if type(v) == "string" then
			str = str .. "=" .. v
		end
	end
	if not inst.cookies then
		table.insert(cookies, str)
	else
		cookies[inst.cookies] = str
	end
	inst.cookies[key] = #cookies
end

return cookie