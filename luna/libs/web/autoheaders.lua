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

return setmetatable(autoheader, {__call=autoheader.__call})