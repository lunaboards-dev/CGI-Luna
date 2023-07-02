local routes = {}
local cfg = require("config")
local utils = require("utils")
local lhp   = require("lhp")
local prefix = cfg.main.prefix

function routes:route(method, pattern, handler)
	if not self.routes[method] then
		self.routes[method] = {}
	end
	table.insert(self.routes[method], {
		pattern = pattern,
		handler = handler
	})
end

function routes:error(handler)
	self.errorhand = handler
end

function routes:get(pattern, handler)
	return self:route("GET", pattern, handler)
end

function routes:post(pattern, handler)
	return self:route("POST", pattern, handler)
end

function routes:__call(instance)
	utils.saferender(instance, function()
		local method, _path = instance:request()
		local path = _path
		if path:sub(1, #prefix) == prefix then
			path = _path:sub(#prefix+1)
		end
		local rts = self.routes[method]
		if not rts then
			self.errorhand(instance, {
				type = "http",
				status = 400,
				info = "Method not supported"
			})
		end
		for i=1, #rts do
			local rtv
			xpcall(function()
				local route = rts[i]
				local pattern = route.pattern
				local results = table.pack(path:match(pattern))
				if #results > 0 or pattern == "" then
					route.handler(instance, table.unpack(results))
					rtv = true
				end
			end, function(err)
				instance:clear()
				self.errorhand(instance, {
					type = "lua",
					info = debug.traceback(err)
				})
				rtv = true
			end)
			if rtv then return end
		end
		self.errorhand(instance, {
			type = "http",
			status = 400
		})
	end)
end

local function error_handler(instance, info)
	if info.type == "lua" then
		utils.render(instance, 500, {content_type = "text/html"}, lhp.loadfile("views/luaerror.lhp")(info.info))
	else
		utils.render(instance, info.status, {content_type = "text/plain"}, "HTTP "..info.status.." "..(info.info or ""))
	end
end

return function()
	return setmetatable({
		errorhand = error_handler,
		routes = {}
	}, {__index=routes, __call=routes.__call})
end