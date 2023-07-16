local hook = {}

local hooks = {}

function hook.add(name, func)
    if not hooks[name] then
        hooks[name] = {}
    end
    table.insert(hooks[name], func)
end

function hook.call(name, ...)
    local h = hooks[name]
    if h then
        for i=1, #h do
            local r = table.pack(h(...))
            if r.n > 0 then
                return table.unpack(r)
            end
        end
    end
end

function hook.run(name, ...)
    local h = hooks[name]
    if h then
        for i=1, #h do
            h(...)
        end
        return true
    end
end

return hook