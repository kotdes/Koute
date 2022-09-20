local Koute = script.Parent.Parent
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local doesMetaContainForbiddenValue = require(Koute.Meta.doesMetaContainForbiddenValue)
local formatPath = require(script.Parent.formatPath)

local Children = Fusion.Children

local IGNORED_KEYS = {"view", "path", "meta", "type", Children}

local function deconstructRoute(route, prevPath: string?)
    assert(type(route.view) == "function", "Koute.Route.view expects a function")
    assert(type(route.path) == "string", "Koute.Route.path expects a string")
    assert(route._isProcessed ~= true, "this route is already processed and belongs to another route")
    if prevPath then
        route.path = prevPath .. route.path
    end
    route.path = formatPath(route.path)
    local toBind = {}

    for key, value in route do
        if table.find(IGNORED_KEYS, key) then
            continue
        -- leaving for future updates which may use Symbol
        elseif typeof(key) == "table" and key.type == "Symbol" then
            if key.name == "Meta" then
                doesMetaContainForbiddenValue(value)
                toBind[key.name] = value
                route[key] = nil
            else
                error(key.name .. " is not an acceptable symbol value in Koute.Route")
            end
        else
            error(typeof(key) .. " is not an acceptable value in Koute.Route")
        end
    end
    route.meta = toBind

    local children = route[Children]
    if children then
        for _, child in children do
            deconstructRoute(child, route.path)
        end
    end
end

return deconstructRoute
