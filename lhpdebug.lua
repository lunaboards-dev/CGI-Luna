local lhp = require("luna.libs.lhp")

local f = io.open(arg[1], "r")
local d = f:read("*a")
f:close()
print(lhp.compile(d))