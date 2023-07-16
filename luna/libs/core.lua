local lhp = require("lhp")
local cfg = require("config")
local utils = require("utils")
local routes = require("routing")()
local modules = require("modules")
local hook = require("hook")
local layouts = require("layouts")
local libmagic = require("libmagic")
local mimetyper = libmagic.open(libmagic.MIME_TYPE)
assert(mimetyper:load())

modules.init()

hook.run("init")

-- module serving
routes:get("^/modules/(.+%.cpio)/(.+)$", function(inst, module, file)
	local path = "static/"..file
	if modules.loaded(module) then
		local arc = modules.open(module)
		for stat, read in arc:files() do
			if stat.name == path then
				local dat = read(stat.fsize)
				inst:write(dat)
				local mime = mimetyper:buffer(dat)
				inst:setheader("Content-Type", mime)
				inst:send(200)
				return
			end
		end
	end
end)

-- hooks
routes:all("^/hook/([^/]+)", function(inst, hookname)
	if not hook.call("webhook", inst, routes, hookname) then
		routes.errorhand(inst, {
			type = "http",
			status = 404,
			info = "Not found"
		})
	end
end)

hook.run("register_routes", routes)

-- board redirect
routes:get("^/([^/]+)$", function(inst, board)
	utils.redirect(inst, 308, cfg.main.prefix.."/"..board.."/")
end)

-- board
routes:get("^/([^/]+)/$", function(inst, board)
	--utils.render(inst, 200, {content_type="text/html"}, board)
	utils.saferender(inst, function()
		layouts.display_threads {
			board = board,
			inst = inst,
			db = require("db")
		}
		--[[utils.render(inst, 200, {content_type="text/html"}, utils.layout("views.board", nil, {
			pagetitle = "Luna/"..board.."/ - " .. utils.random_entry(cfg.boards[board].title),
			rand_entry = utils.random_entry,
			board = board
		}))]]
	end)
end)

-- index
routes:get("", function(inst)
	utils.render(inst, 200, {content_type = "text/html"}, utils.layout("env", nil, {}))
end)

require("backend")(routes)