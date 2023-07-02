#!%CONTEXT_DOCUMENT_ROOT%/native/bin/lua.exe
local root = os.getenv("CONTEXT_DOCUMENT_ROOT")
package.path = package.path .. ";" .. root .."/luna/libs/?.lua;" .. root .."/luna/libs/?/init.lua"
package.cpath = package.cpath .. ";" .. root .."/luna/native/lib/lua/?.dll;" .. root .."/luna/native/lib/lua/?/init.dll"

require("core") -- Loads main script