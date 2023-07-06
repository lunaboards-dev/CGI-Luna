local lhp = require("lhp")
local utils = {}

function utils.saferender(instance, func)
	xpcall(function()
		func()
	end, function(err)
		local bt = debug.traceback(err)
		xpcall(function()
			instance:clear()
			instance:write(lhp.loadfile("views/luaerror.lhp", nil)(bt))
			instance:setheader("Content-Type", "text/html")
			instance:send(500)
		end, function(err)
			instance:clear()
			instance:write("Error rendering error page (lol):")
			instance:write(debug.traceback(err))
			instance:write("\n(^ FIX THIS FIRST, DUMBASS)\n\n")
			instance:write("Error rendering original page:")
			instance:write(bt)
			instance:setheader("Content-Type", "text/plain")
			instance:send(500)
		end)
	end)
end

function utils.render(instance, status, headers, body)
	for k, v in pairs(headers) do
		local key = k:gsub("^.", string.upper):gsub("_.", function(m) return "-"..m:sub(2,2):upper() end)
		instance:setheader(key, v)
	end
	instance:write(body)
	instance:send(status)
end

function utils.http_escape(str)
	return (str:gsub("%W", function(match)
		return string.format("%%%.2x", match:byte())
	end))
end

function utils.http_unescape(str)
	return str:gsub("%%%x%x", function(match)
		return string.char(match:sub(2), 16)
	end)
end

function utils.layout(inner, env, ...)
	return lhp.loadfile("views/layout.lhp", env)(inner, ...)
end

function utils.random_entry(list)
	return list[utils.random(#list)]
end

function utils.random_data(length)
	local s = ""
	for i=1, length do
		s = s .. string.char(math.random(0, 255))
	end
	return s
end

function utils.random(min, max)
	if not max then
		max = min
		min = 1
	end
	-- lol just return math.random for now
	return math.random(min, max)
end

function utils.hex(str)
	return string.format(string.rep("%.2x", #str), str:byte(1, #str)) -- fuck ya life, bing bong
end

function utils.redirect(instance, code, to)
	instance:setheader("Location", to)
	instance:send(code)
end

function utils.path_join(base, ...)
	local path_parts = table.pack(...)
	base = base:gsub("/$", "")
	for i=1, path_parts.n do
		path_parts[i] = path_parts[i]:gsub("^/", ""):gsub("/$", "")
	end
	local str = table.concat(path_parts, "/")
	return base .. (#str > 0 and "/" or "") .. str
end

return utils