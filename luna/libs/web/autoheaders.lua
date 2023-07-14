local autoheader = {
	headers = {}
}

function autoheader:add(key, func)
	self.headers[key] = func
end

function autoheader:__call(inst)
	for k, v in pairs(self.headers) do
		inst:setheader(k, v(inst))
	end
end

autoheader:add("Date", function()
	return os.date("%a, %d %b %Y %H:%M:%S GMT", os.time(os.date("!*t")))
end)

return setmetatable(autoheader, {__call=autoheader.__call})