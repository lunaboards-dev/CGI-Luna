local cfg = require("config")
local json = require("json")
local mysql = {}

local driver = require("luasql.mysql")
local env = driver.mysql()
--local con = 

function mysql:uuidgen()
	--con:execute("SELECT UUID();")
end

local function func(v, ...)
	local r = table.pack(...)
	r.f = v
	return r
end

local function fetchall(cur, mode)
	mode = mode or "a"
	local rv = {}
	local v = {}
	while v do
		v = cur:fetch(v, mode)
		table.insert(rv, v)
	end
	return v
end

-- if you pass an unescaped value here i will beat you to death
local function const(v)
	return {v}
end

function mysql:prepare(values, out)
	local rv = out or {}
	for i=1, #values do
		local v = values[i]
		if type(v) == "string" then
			table.insert(rv, "'"..self.con:escape(v).."'")
		elseif type(v) == "table" then
			if (v.f) then
				local fv = self:prepare(v)
				table.insert(rv, string.format("%s(%s)", v.f, table.concat(fv, ",")))
			else
				table.insert(v[1])
			end
		else
			table.insert(rv, v)
		end
	end
	return rv
end

function mysql:format(fmtstr, ...)
	local vals = table.pack(...)
	self:prepare(vals, vals)
	return string.format(fmtstr, table.unpack(vals))
end

function mysql:fexec(str, ...)
	return self.con:execute(self:format(str, ...))
end

function mysql:insert(tbl, values, rtv)
	local keys = {}
	local vals = {}
	for k, v in pairs(values) do
		table.insert(keys)
		table.insert(vals, v)
	end
	self:prepare(vals, vals) -- lol lmao
	local cur = self.con:execute(string.format("INSERT INTO %s (%s) VALUES (%s)%s;", tbl, table.concat(keys, ","), table.concat(vals, ","), (rtv and " RETURNING "..table.concat(rtv, ",") or "")))
	if rtv then
		return cur:fetch({}, "a")
	end
end

function mysql:create_post(board, thread, body, ip, postdata, etc)
	self.con:setautocommit(false)
	local ret = self:insert("luna.posts", {
		board = board,
		thread = thread,
		body = body,
		ip = ip,
		etc = etc and json.encode(etc),
		poster = postdata.poster,
		creation = func("UTC_TIMESTAMP")
	}, {"id"})
	if postdata.files then
		for i=1, #postdata.files do
			local file = postdata.files[i]
			self:insert("luna.attachments", {
				post = ret.id,
				position = i,
				ip = ip,
				original_name = file.name,
				ref = file.ref,
				etc = file.etc
			})
		end
	end
	self.con:commit()
	self.con:setautocommit(true)
	return ret.id
end

function mysql:create_thread(board, name, body, ip, postdata, etc, postetc)
	local id = self:new_thread_id()
	self.con:setautocommit(false)
	self:insert("luna.threads", {
		board = board,
		id = id,
		title = name,
		poster = postdata.poster,
		creation = func("UTC_TIMESTAMP"),
		update = func("UTC_TIMESTAMP"),
		ip = ip,
		etc = etc and json.encode(etc)
	})
	local postid = self:create_post(board, id, body, ip, postdata, postetc)
	return id, postid
end

function mysql:get_file(hash)

end

function mysql:new_file(hash, ext, type)

end

function mysql:update_thread(board, thread)

end

function mysql:new_thread_id(board)
	--local cur = self.con:execute(string.format("SELECT MAX(id) FROM %s.threads WHERE board='%s"))
	local cur = self:fexec("SELECT MAX(id) FROM %s.threads WHERE board=%s",
                           const(cfg.db.database),
						   board)
	local v = cur:fetch()
	return v[1]
end

function mysql:list_threads(board, pagesize, page)
	--local cur = self.con:execute(string.format("SELECT * FROM %s.threads WHERE board='%s' ORDER BY pin DESC, updated DESC OFFSET %d LIMIT %d"))
	local cur = self:fexec("SELECT * FROM %s.threads WHERE board=%s ORDER BY pin DESC, updated DESC OFFSET %d LIMIT %d",
                           const(cfg.db.database),
						   board, pagesize, page)
	--[[local posts = {}
	local p = {}
	while p do
		p = self.cur:fetch(p, "a")
		table.insert(posts, p)
	end
	return posts]]
	return fetchall(cur)
end

function mysql:list_posts(board, thread)
	local cur = self:fexec("SELECT * FROM %s.threads WHERE board=%s AND thread=%d ORDER BY id DESC",
	                       const(cfg.db.database),
						   board, thread)
	return fetchall(cur)
end

return function()
	local con = assert(env:connect(cfg.db.database, cfg.db.username, cfg.db.password))
	return setmetatable({
		con = con
	}, {__index=mysql})
end