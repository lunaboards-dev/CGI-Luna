local utils = require("utils")
local board = {}

function board:display_threads(args)
	local inst = args.instance
	local db = inst.db
	db:list_threads(args.board, args.pagesize or 30, args.page or 0)
	utils.render(inst, 200, {}, utils.layout("views.generic.board", {
		board = args.board
	}))
end

function board:display_posts(args)
	utils.render(args.inst, 200, {

	}, utils.layout("views.generic.display", nil, {
		board = args.board,
		thread = args.thread
	}))
end

return board