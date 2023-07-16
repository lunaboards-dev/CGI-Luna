local rle = {}

local MIN_MATCH = 3

local function getsize(mt, size)
    local iv = size & 0x3F
    size = size >> 6
    local v = string.char(
        ((mt and 1 or 0) << 7) |
        (((size > 0) and 1 or 0) << 6) |
        iv
    )
    while size > 0 do
        iv = size & 0x7F
        size = size >> 7
        v = v .. string.char(
            (((size > 0) and 1 or 0) << 7) |
            iv
        )
    end
    return v
end

function rle.compress(str)
    local out = {}
    local off = 1
    local tmp = ""
    while off < #str-MIN_MATCH do
        local m = str:sub(off,off+MIN_MATCH-1)
        local c = m:sub(1,1)
        if m:find("[^%"..c.."]") then
            tmp = tmp .. c
        else
            local mlen = MIN_MATCH
            while not str:sub(off, off+mlen-1):find("[^%"..c.."]") do
                mlen = mlen + 1
            end
            if (tmp ~= "") then
                table.insert(out, getsize(false, #tmp)..tmp)
            end
            table.insert(out, getsize(true, mlen)..c)
            tmp = ""
        end
        off = off + 1
    end
    if (tmp ~= "") then
        table.insert(out, getsize(false, #tmp)..tmp)
    end
    return table.concat(out, "")
end

function rle.decompress(str)
    local out = {}
    local off = 1
    while off < #str do
        local c = str:byte(off)
        local match, ext = (c & 0x80) > 0, (c & 0x40) > 0
        local val = c & 0x3F
        local shl = 5
        off = off + 1
        while ext do
            local v = str:byte(off)
            ext = (v & 0x80) > 0
            val = val | (v << shl)
            shl = shl + 7
            off = off + 1
        end
        if match then
            table.insert(out, str:sub(off, off):rep(val))
            off = off + 1
        else
            table.insert(out, str:sub(off, off+val-1))
            off = off + val
        end
    end
    return table.concat(out)
end

return rle