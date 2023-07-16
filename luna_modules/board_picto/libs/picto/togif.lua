local cpio = require("cpio")
local json = require("json")
local delta = require("picto.compression.delta")
local rle = require("picto.compression.rle")

return function(hash)
    local db = require("db")
    local file = db:get_file(hash)
    local f = io.open(file, "rb")
    local arc = cpio(f, "r")
    local files, meta = {}
    for stat, read in arc:files() do
        if stat.name == "meta" then
            meta = json.decode(files.meta)
        else
            files[tonumber(stat.name, 16)] = read(stat.fsize)
        end
    end
    
end