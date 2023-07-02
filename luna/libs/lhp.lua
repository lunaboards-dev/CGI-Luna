local lhp = {}

lhp.version = "lhp 0.1"
lhp.openstring = "(<%?lua=?)%f[%s]"
lhp.shortopen = "<%?=?"
lhp.closestring = "%?>"
lhp.argsstring = "<%?args%s"
lhp.lhppath = "./?.lhp;./?/index.lhp"
lhp.addedenv = {}

function lhp.searcher(package)
	local checked = {}
	for path in lhp.lhppath:gmatch("[^;]+") do
		local fpath = path:gsub("%?", (package:gsub("%.", "/")))
		local h = io.open(fpath, "r")
		if h then
			h:close()
			return lhp.loadfile(fpath), fpath
		end
		table.insert(checked, "no such file '"..fpath.."'")
	end
	--print("e", table.concat(checked, "\n\t"), "a")
	return table.concat(checked, "\n\t")
end

function lhp.compile(str)
	local code = ""
	local start = 1
	local function escape(s)
		return s:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\\n"):gsub("\r", "\\r")
	end
	local function append(s)
		--if s:gsub("^%s+", ""):gsub("%s+$", "") ~= "" then
		if s ~= "" then
			code = code .. "echo(\""..escape(s).."\") "
		end
	end
	local function getline()
		return select(2, str:sub(1, start):gsub("\n", ""))+1
	end
	while true do
		local chunk
		local st, en = str:find(lhp.openstring, start)
		local sta, ena = str:find(lhp.argsstring, start)
		local sts, ens = str:find(lhp.shortopen, start)
		if not sts then
			chunk = str:sub(start)
			append(chunk)
			break
		end
		if not st or sts < st then
			st, en = sts, ens
		end
		if sta then
			if getline() ~= 1 then
				error("arguments must be on first line of file")
			end
			st, en = sta, ena
		end
		local echo = str:sub(en, en) == "="
		--io.stderr:write("[", str:sub(st, en),"]", "\n")
		local st2, en2 = str:find(lhp.closestring, en+1)
		if not st2 then
			error("'?>' expected near <eof>")
		end
		chunk = str:sub(start, st-1)
		append(chunk)
		chunk = str:sub(en+1, st2-1)
		if echo then
			code = code .. " echo("..chunk..") "
		elseif sta then
			code = code .. "local "..chunk.." = ... "
		else
			code = code .. chunk .. " "
		end
		start = en2+1
	end
	return code
end

local function pathprint(path)
	local parts = {}
	for i=1, #path do
		parts[i] = tostring(path[i])
	end
	return table.concat(parts, ".")
end

local function deepcopy(from, to)
	to = to or {}
	local tocopy = {{path={"_G"}, from=from, to=to}}
	local copied = {}
	local cop_path = {}
	while #tocopy > 0 do
		local f, t = tocopy[1].from, tocopy[1].to
		for k, v in pairs(f) do
			if type(v) == "table" then
				if copied[v] then
					t[k] = copied[v]
					--print("already copied "..pathprint(tocopy[1].path).."."..k)
				else
					local dest = t[k] or setmetatable({}, getmetatable(v))
					local p = table.pack(table.unpack(tocopy[1].path))
					table.insert(p, k)
					table.insert(tocopy, {path=p, from=v, to=dest})
					copied[v] = dest
					t[k] = dest
				end
			else
				t[k] = v
			end
		end
		--print("copied "..pathprint(tocopy[1].path))
		table.remove(tocopy, 1)
	end
	return to
end

lhp.basenv = deepcopy(_G)
lhp.deepcopy = deepcopy

local function preprint(...)
	local args = table.pack(...)
	for i=1, #args do
		args[i] = tostring(args[i])
	end
	return table.concat(args, "\t")
end

function lhp.env(env)
	local inst = deepcopy(lhp.basenv)
	deepcopy(lhp.addedenv, inst)
	if env then
		deepcopy(env, inst)
	end
	inst._OUTPUT = {}
	inst.lhp = deepcopy(lhp)
	function inst.echo(...)
		table.insert(inst._OUTPUT, preprint(...))
	end

	function inst.writeln(...)
		table.insert(inst._OUTPUT, preprint(...).."\n")
	end

	function inst.print(...)
		io.stderr:write(preprint(...).."\n")
	end
	
	inst.include = lhp.include
	table.insert(inst.package.searchers, lhp.searcher)

	return inst
end

function lhp.load(str, env, chunkname)
	local code = lhp.compile(str)
	local inst = lhp.env(env)
	local func = assert(load(code, chunkname or "=[string].lhp", "t", inst))
	return function(...)
		func(...)
		return table.concat(inst._OUTPUT, "")
	end
end

function lhp.loadfile(file, env)
	local f = assert(io.open(file, "r"))
	local d = f:read("*a")
	f:close()
	return lhp.load(d, env, "="..file)
end

function lhp.parse(str, env, chunkname)
	return lhp.load(str, env, chunkname)()
end

function lhp.parsefile(file, env)
	return lhp.loadfile(file, env)()
end

local function getenv(f)
	local di = debug.getinfo(f, "u")
	for i=1, di.nups do
		local k, v = debug.getupvalue(f, i)
		if k == "_ENV" then
			return v
		end
	end
end

local function getcallerenv()
	local di = debug.getinfo(3, "f")
	return getenv(di.func)
end

function lhp.include(pkg)
	-- acts like the normal `include` but sets the _ENV var to the current _ENV and only caches to the current instance's _OUTPUT var
	local env = getcallerenv()
	if not env or not env._OUTPUT then return require(pkg) end
	local cache = env._OUTPUT.loaded
	if not cache then
		cache = {}
		env._OUTPUT.loaded = cache
	end
	if cache[pkg] then return cache[pkg] end
	local errmsg = ""
	for i=1, #env.package.searchers do
		--print(env.package.searchers[i](pkg))
		local retv, path = env.package.searchers[i](pkg)
		if type(retv) == "function" then
			local renv = getenv(retv)
			setmetatable(renv, {__index = env})
			cache[pkg] = retv
			return retv
		elseif retv then
			errmsg = errmsg .. "\n\t" .. retv
		end
	end
	error("module '"..pkg.."' not found:"..errmsg, 2)
end

return lhp