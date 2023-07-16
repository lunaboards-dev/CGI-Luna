local cpio = require("luna.libs.cpio")
local lfs = require("lfs")

local f = io.open(arg[2], "wb")
local arc = cpio(f, "w")

local ino = 0
local function write_file(file, data)
    arc:write_file {
        dev = 0,
        ino = ino,
        mode = 0x81a4,
        uid = 1000,
        gid = 1000,
        nlink = 1,
        rdev = 0,
        mtime = os.time() & 0xFFFFFFFF,
        name = file,
        fsize = #data
    }
    arc:write_data(data)
    arc:align()
end

local function write_dir(dir)
    arc:write_file {
        dev = 0,
        ino = ino,
        mode = 0x41ed,
        uid = 1000,
        gid = 1000,
        nlink = 2,
        rdev = 0,
        mtime = os.time(),
        name = dir,
        fsize = 0
    }
    arc:align()
end

local function recurse_explore(dir, prefix, dirlist)
    prefix = prefix or ""
    dirlist = dirlist or {}
    for ent in lfs.dir(dir) do
        if ent == "." or ent == ".." then goto continue end
        table.insert(dirlist, prefix..ent)
        if lfs.attributes(dir.."/"..ent, "mode") == "directory" then
            recurse_explore(dir.."/"..ent, prefix..ent.."/", dirlist)
        end
        ::continue::
    end
    return dirlist
end

local entries = recurse_explore(arg[1])
for i=1, #entries do
    local e = entries[i]
    local epath = arg[1] .. "/" .. e
    if lfs.attributes(epath, "mode") == "directory" then
        write_dir(e)
    else
        local fi = io.open(epath, "rb")
        local data = fi:read("*a")
        fi:close()
        write_file(e, data)
    end
end

arc:write_out()
f:close()