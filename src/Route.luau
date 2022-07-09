local Fusion = require(script.Parent.Parent.Fusion)
local PathAnalyzer = require(script.Parent.PathAnalyzer)
local Symbols = require(script.Parent.Symbols)

local Children = Fusion.Children

return function(path)
    return function(params)
        local route = {
            Type = Symbols.Route,
            Path = PathAnalyzer.format(path),
            View = params.View,
            Meta = params.Meta or {},
            [Children] = params[Children],
        }
        return route
    end
end