local lfs = require("lfs")
local cpio = require("cpio")
local lhp = require("lhp")
local modules = {}
local modlist = {}
local files = {}

function modules.init()
    for mods in lfs.dir("luna/modules") do
        if mods:match("%.cpio$") then
            local f = io.open("luna/modules/"..mods, "rb")
            local arc = cpio(f, "r")
            modlist[mods] = {
                file = f,
                archive = arc
            }
            for stat, read in arc:files() do
                table.insert(modlist[mods], {
                    stat = stat,
                    read = read
                })
                if stat.name:lower() == "init.lua" then
                    local code = read(stat.fsize)
                    load(code, "=luna/modules/"..mods.."/init.lua")()
                end
            end
        --[[elseif lfs.attributes("luna/modules/"..mods, "mode") == "directory" and mods ~= "." and mods ~= ".." then
            for ent in lfs.dir("luna/modules/"..mods) do
                if ent:lower() == "init.lua" then
                    dofile("luna/modules/"..mods.."/init.lua")
                end
            end]]
        end
    end
end

function modules.loaded(mod)
    return not not modlist[mod]
end

function modules.open(mod)
    modlist[mod].file:seek("set", 1)
    return modlist[mod].archive
end

table.insert(package.searchers, function(pkg)
    local path = pkg:gsub("%.", "/")
    local script_path, pkg_path = "lib/"..path..".lua", "lib/"..path.."/init.lua"
    local template_path, index_path = path..".lhp", path.."/index.lhp"
    local checked = {}

    for module, mod_files in pairs(modlist) do
        for i=1, #mod_files do
            local file = mod_files[i]
            if file.stat.name == script_path or file.stat.name == pkg_path then
                mod_files.file:seek("set", file.stat.body_start)
                local code = mod_files.file:read(file.stat.fsize)
                return load(code, "=module["..module..".cpio]/"..file.stat.name), "module["..module..".cpio]/"..file.stat.name
            elseif file.stat.name == template_path or file.stat.name == index_path then
                mod_files.file:seek("set", file.stat.body_start)
                local code = mod_files.file:read(file.stat.fsize)
                return lhp.load(code, nil, "=module["..module..".cpio]/"..file.stat.name), "module["..module..".cpio]/"..file.stat.name
            end
        end
        table.insert(checked, "module["..module..".cpio]/"..script_path)
        table.insert(checked, "module["..module..".cpio]/"..pkg_path)
        table.insert(checked, "module["..module..".cpio]/"..template_path)
        table.insert(checked, "module["..module..".cpio]/"..index_path)
    end
    return table.concat(checked, "\n\t")
end)

return modules