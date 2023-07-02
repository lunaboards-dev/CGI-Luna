local lhp = require("lhp")
local cfg = require("config")
local utils = require("utils")
local routes = require("routing")()

routes:get("^/([^/]+)$", function(inst, board)
	utils.redirect(inst, 308, cfg.main.prefix.."/"..board.."/")
end)

routes:get("^/([^/]+)/$", function(inst, board)
	--utils.render(inst, 200, {content_type="text/html"}, board)
	utils.saferender(inst, function()
		utils.render(inst, 200, {content_type="text/html"}, utils.layout("views.board", nil, {
			pagetitle = "Luna/"..board.."/ - " .. utils.random_entry(cfg.boards[board].title),
			rand_entry = utils.random_entry,
			board = board
		}))
	end)
end)

routes:get("", function(inst)
	utils.render(inst, 200, {content_type = "text/html"}, utils.layout("env", nil, {}))
end)

require("backend")(routes)