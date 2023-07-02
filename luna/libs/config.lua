local cfg = loadfile("conf.lua")()

cfg.boards = {}

local sections = cfg.main.boards
for i=1, #sections do
	local section = sections[i]
	for i=1, #section do
		cfg.boards[section[i].id] = section[i]
	end
end

return cfg