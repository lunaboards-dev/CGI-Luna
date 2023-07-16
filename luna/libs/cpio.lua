local cpio_read = {}
local cpio_write = {}

local hdr = "HHHHHHHHHHHHH"
local magic = 0x71c7
--local magic = 0xc771
local trailer = "TRAILER!!!\0"

local function cpio_hdr(dat)
	if type(dat) == "table" then
		return hdr:pack(
			magic,
			dat.dev,
			dat.ino,
			dat.mode,
			dat.uid,
			dat.gid,
			dat.nlink,
			dat.rdev,
			dat.mtime >> 16,
			dat.mtime & 0xFFFF,
			#dat.name+1,
			dat.fsize >> 16,
			dat.fsize & 0xFFFF
		)
	elseif type(dat) == "string" then
		local r = {}
		local _, mtime_lo, mtime_hi, fsize_lo, fsize_hi
		local e = "<"
		if string.unpack("<H", dat) ~= magic then e = ">" end
		r.magic, r.dev, r.ino, r.mode, r.uid, r.gid, r.nlink, r.rdev, mtime_hi, mtime_lo, r.namesize, fsize_hi, fsize_lo = string.unpack(e..hdr, dat)
		r.mtime = mtime_lo | (mtime_hi << 8)
		r.fsize = fsize_lo | (fsize_hi << 8)
		
		return r
	else
		error("expected table or string, got "..type(dat))
	end
end

 function cpio_write:write_file(stat)
	local d = cpio_hdr(stat)
	self.pos = self.pos + #d + #stat.name + 1
	self.file:write(d, stat.name, "\0")
	self:align(true)
	self.remaining = stat.fsize
 end

 function cpio_write:write_data(dat)
	self.pos = self.pos + #dat
	self.remaining = self.remaining - #dat
	self.file:write(dat)
 end

 function cpio_write:align(nofill)
	if not nofill then
		self.file:write(string.rep("\0", self.remaining))
		self.pos = self.pos + self.remaining
		self.remaining = 0
	end
	if self.pos & 1 > 0 then
		self.file:write("\0")
		self.pos = self.pos + 1
	end
 end

 function cpio_write:write_out(dat)
	self:write_file {
		dev = 0,
		ino = 0,
		mode = 0,
		uid = 0,
		gid = 0,
		nlink = 0,
		rdev = 0,
		mtime = 0,
		name = "TRAILER!!!",
		fsize = (dat and #dat) or 0
	}
	if dat then
		self:write_data(dat)
		self:align()
	end
 end

 function cpio_read:read_file()
	local size = hdr:packsize()
	local start = self.file:seek("cur", 0)
	local dat = self.file:read(size)
	self.hdr_start = start
	self.body_start = self.file:seek("cur", 0)
	self.pos = self.pos + size
	local stat = cpio_hdr(dat)
	local name = self.file:read(stat.namesize)
	io.stderr:write("["..stat.namesize..": "..name.."]\n")
	--[[for k, v in pairs(stat) do
		io.stderr:write(k, ": ", ((type(v) == "number") and string.format("%x", v)) or tostring(v), "\n")
	end]]
	self.remaining = stat.fsize
	stat.name = name:sub(1, #name-1)
	self.pos = self.pos + stat.namesize
	self:align(true)
	if name == trailer then return end
	return stat
 end

 function cpio_read:read_data(amt)
	self.pos = self.pos + amt
	self.remaining = self.remaining - amt
	return self.file:read(amt)
 end

 function cpio_read:align(nofill)
	if not nofill then
		--io.stderr:write(string.format("skipping %x...\n", self.remaining))
		--local rtv = self.file:read(self.remaining)
		self.file:read(self.remaining)
		--[[if #rtv > 0 then
			io.stderr:write(string.format("First two bytes: %.2x%.2x\n", rtv:byte(1, 2)))
		end]]
		self.pos = self.pos + self.remaining
		self.remaining = 0
	end
	if self.pos & 1 > 0 then
		self.file:read(1)
		self.pos = self.pos + 1
	end
 end

function cpio_read:files()
	return function()
		self:align()
		local stat = self:read_file()
		if stat then
			return stat, function(amt)
				return self:read_data(amt)
			end
		end
	end
end

 return function(hand, mode)
	if mode ~= "r" and mode ~= "w" then error("bad mode "..mode) end
	return setmetatable({
		file = hand,
		pos = 0,
		remaining = 0
	}, {__index = (mode == "r" and cpio_read) or cpio_write})
 end