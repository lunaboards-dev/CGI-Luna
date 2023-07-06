local lfs = require("lfs")
local utils = require("utils")
local cfg = require("config")
local blake2b = require("plc.blake2b")
local files = {}

function files.randname() return utils.hex(utils.random_data(10)) end

function files.temporary(ext)
	local name = files.randname()
	while lfs.attributes(utils.path_join(cfg.uploads.fspath, "tmp", name.."."..ext)) do
		name = files.randname()
	end
	return utils.path_join(cfg.uploads.fspath, "tmp", name.."."..ext)
end

function files.hash_and_store(instream, outstream)
	local inst = blake2b.init()
	local blk = cfg.uploads.blocksize or 1*1024*1024
	while true do
		local chunk = instream:read(blk)
		if not chunk then break end
		blake2b.update(inst, chunk)
		outstream:write(chunk)
	end
	return blake2b.final(inst)
end

function files.commit(tmpfile, hash, ext)
	os.rename(tmpfile, utils.path_join(cfg.uploads.fspath, "files", hash.."."..ext))
	os.remove(tmpfile)
end

function files.stream(data)

end

return files