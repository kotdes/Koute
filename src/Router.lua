local Fusion = require(script.Parent.Parent.Fusion)
local PathAnalyzer = require(script.Parent.PathAnalyzer)

local Children = Fusion.Children
local State = Fusion.State

local class = {}
class.__index = class

function class:set(route, params, options)
    local prevPath = self.Serving.Path:get()
    route = table.clone(route)
    options = options or {}
    for index, value in route.Meta do
        if type(value) == "table" and value.Type == "$k-dynamic" then
            route.Meta[index] = value(self)
        end
    end
    self.Serving.Meta:set(route.Meta or {})
    self.Serving.Path:set(route.Path)
    self.Serving.Params = params or {}
    self.Serving.Params.Router = self
    self.Serving.View:set(route.View)
    if not options.noHistory and self.Serving.Path:get() ~= prevPath then
        local params = table.clone(self.Serving.Params)
        params.Router = nil
        table.insert(self.History, {
            Path = self.Serving.Path:get(),
            View = self.Serving.View:get(),
            Meta = self.Serving.Meta:get(),
            Params = params
        })
    end
end

function class:go(path: string, params, options)
    local match = nil
    path = PathAnalyzer.format(path)
    for _, route in self.Routes do
        if route.Path == path then
            match = route
            break
        end
    end
    if match then
        self:set(match, params, options)
        return true
    end
    return false
end

function class:back(level: number?)
    level = level or 1
    local match = self.History[#self.History - level]
    if match then
        self:set(match, match.Params, { noHistory = true })
    end
end

return function(params)
    local function destruct(node)
        local nodes = { node }
        if node[Children] then
            for _, children in node[Children] do
                for _, item in destruct(children) do
                    table.insert(nodes, item)
                end
            end
        end
        return nodes
    end
    if not params[Children].compiled then
        params[Children]._compile()
    end
    local router = setmetatable({
        Routes = destruct(params[Children]),
        History = {},
        Serving = {
            Path = State(),
            View = State(),
            Meta = State({}),
            Params = {},
        }
    }, class)
    router:go("/")
    return router
end