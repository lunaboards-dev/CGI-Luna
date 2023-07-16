local layouts = {}
local boards = {}
local config = require("config")

function layouts.register(type, prototype)
    boards[type] = prototype
end

function layouts.display_threads(args)
    boards[config.boards[args.board]]:display_threads(args)
end

return layouts