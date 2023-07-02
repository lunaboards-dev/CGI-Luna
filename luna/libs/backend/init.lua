return function(routes)
	if os.getenv("GATEWAY_INTERFACE") then
		routes(require("backend.cgi"))
		goto continue
	else
		-- fcgi init
	end
	error("what, how?")
	::continue::
end