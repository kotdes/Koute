local Fusion = require(script.Parent.Parent.Fusion)
local PathAnalyzer = require(script.Parent.PathAnalyzer)

local Children = Fusion.Children
local State = Fusion.State

local class = {}
class.__index = class

local function archive(tbl)
    local newTbl = {}
    for index, value in tbl do
        if value.Type == "State" and value.get then
            newTbl[index] = value:get()
        elseif type(value) == "table" then
            newTbl[index] = table.clone(value)
        else
            newTbl[index] = value
        end
    end
    return newTbl
end

function class:set(route, params, options)
    local prevPath = self.Serving.Path:get()
    route = table.clone(route)
    options = options or {}
    for index, value in route.Meta do
        if value.Type == "$k-dynamic" and type(value.Value) == "function" then
            route.Meta[index] = value.Value(route, params)
        end
    end
    self.Serving.Meta:set(route.Meta or {})
    self.Serving.Path:set(route.Path)
    self.Serving.Params = params or {}
    self.Serving.Params.Router = self
    self.Serving.View:set(route.View)
    if not options.noHistory and self.Serving.Path:get() ~= prevPath then
        local archived = archive(self.Serving)
        archived.Params.Router = nil
        table.insert(self.History, archived)
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
        local items = {}
        if node.Type == "$k-route" then
            local newRoute = table.clone(node)
            newRoute._isHead = true
            newRoute[Children] = nil
            table.insert(items, newRoute)
                end
        for _, route in node[Children] or {} do
            for _, item in destruct(route) do
                item.Path = PathAnalyzer.format((node.Path or "") .. item.Path)
                table.insert(items, item)
            end
        end
        return items
    end
    local router = setmetatable({
        Routes = destruct(params),
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