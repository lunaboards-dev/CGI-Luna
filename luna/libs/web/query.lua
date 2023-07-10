local utils = require("utils")
return function(str)
	local args = {}
	for key, value in str:gmatch("(.+)+=([^&]+)") do
		args[key] = utils.url_unescape(value)
	end
	return args
end