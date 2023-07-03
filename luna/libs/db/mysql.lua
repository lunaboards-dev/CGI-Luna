local cfg = require("config")
local mysql = {}

local driver = require("luasql.mysql")
local env = driver.mysql()
local con = env:connect(cfg.db.database, cfg.db.username, cfg.db.password)

function mysql.uuidgen()
	con:execute("SELECT UUID();")
end

function mysql.insert(tbl, values)
	local keys = {}
	local vals = {}
	for k, v in pairs(values) do
		table.insert(keys)
		if (type(v) == "string") then
			table.insert(vals, "'"..con:escape(values).."'")
		else
			table.insert(vals, tostring(v))
		end
	end
	env:execute(string.format("INSERT INTO %s (%s) VALUES (%s)", tbl, table.concat(keys, ","), table.concat(vals, ",")))
end

function mysql.create_post(board, thread, body, ip)
	mysql.insert("luna.posts", {
		board = board,
		thread = thread,
		body = body,
		ip = ip
	})
end

function mysql.create_thread(board, name, body, etc)

end

function mysql.get_file(hash)

end

function mysql.new_file(hash)

end

function mysql.update_thread(board, thread)

end

function mysql.new_thread_id(board)

end

function mysql.list_board(board, pagesize, page)
	local cur = con:execute(string.format("SELECT * FROM %s WHERE board='%s"))
end

return mysql