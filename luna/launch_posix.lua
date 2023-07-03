#!/usr/bin/env lua
local root = os.getenv("CONTEXT_DOCUMENT_ROOT")
package.path = package.path .. ";" .. root .."/luna/libs/?.lua;" .. root .."/luna/libs/?/init.lua"
package.cpath = package.cpath .. ";" .. root .."/luna/native/lib/lua/?.so;" .. root .."/luna/native/lib/lua/?/init.so"

if os.getenv("ENV_RUNNER") == "lua" then
	loadfile(os.getenv("REQUEST_PATH"))()
	goto shutdown
elseif os.getenv("ENV_RUNNER") == "lhp" then
	local html = require("lhp").parsefile(os.getenv("REQUEST_PATH"))
	print("Status: 200")
	print("Content-Type: text/html")
	print("")
	print(html)
	goto shutdown
end

require("core") -- Loads main script
::shutdown::