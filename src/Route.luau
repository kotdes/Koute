local Fusion = require(script.Parent.Parent.Fusion)
local PathFormat = require(script.Parent.PathFormat)
local Symbols = require(script.Parent.Symbols)

local Children = Fusion.Children

return function(path)
    return function(params)
        local route = {
            Type = Symbols.Route,
            Path = PathFormat(path),
            View = params.View,
            Meta = params.Meta or {},
            [Children] = params[Children],
        }
        return route
    end
end