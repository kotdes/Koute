local Fusion = require(script.Parent.Parent.Fusion)
local PathAnalyzer = require(script.Parent.PathAnalyzer)

local Children = Fusion.Children

return function(path)
    return function(params)
        local route = {
            Path = PathAnalyzer.format(path),
            View = params.View,
            Meta = params.Meta or {},
            [Children] = params[Children],
        }

        route._compile = function()
            if params[Children] then
                for _, children in route[Children] do
                    repeat task.wait() until children._isOk
                    children.Parent = route
                    children.Path = PathAnalyzer.format(path .. children.Path)
                    children._compile()
                end
            end
            if not route.Parent then
                route._compiled = true
            end
        end
        route._isOk = true

        return route
    end
end