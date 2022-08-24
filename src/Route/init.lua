local function Route(routePath: string)
    return function(parameters: {any})
        parameters.type = "Route"
        parameters.path = routePath
        return parameters
    end
end

return Route