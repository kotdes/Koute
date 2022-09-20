local function Route(routePath)
    return function(parameters)
        parameters.type = "Route"
        parameters.path = routePath
        return parameters
    end
end

return Route
