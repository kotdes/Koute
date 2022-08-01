local Fusion = require(script.Parent.Parent.Fusion)
local PathFormat = require(script.Parent.PathFormat)
local Symbols = require(script.Parent.Symbols)

local Children = Fusion.Children
local State = Fusion.State

local class = {}
class.__index = class

type RouteOptions = {
    noHistory: boolean?
}

type Route = {
    Type: typeof(Symbols.Route),
    Path: string,
    Meta: { [any]: any },
    View: (any) -> (GuiObject),
    [any]: any, -- this is painful to look at
}

local DEFAULT_ROUTER_OPTIONS = {
    DefaultPath = "/",
    MaxHistoryEntry = 3,
    UseInstanceForView = false,
}

local DEFAULT_ROUTE_OPTIONS = {
    DoNotSaveToHistory = false,
}

local function archive(tbl: { [any]: any })
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

local function compareAndMerge(toCompare, compareWith)
    for index, value in compareWith do
        if toCompare[index] then
            continue
        end
        toCompare[index] = value
    end
    return toCompare
end

    local prevPath = self.Serving.Path:get()
    route = table.clone(route)
    options = options or {}
    params = params or {}
    for index, value in route.Meta do
        if value.Type == Symbols.Dynamic then
            route.Meta[index] = value.Value(route, params)
        end
    end
    self.Serving.Params = params
    self.Serving.Params.Router = self
    for _, item in { "Meta", "Path", "View" } do
        self.Serving[item]:set(route[item])
    end
    if not options.noHistory and self.Serving.Path:get() ~= prevPath then
        local archived = archive(self.Serving)
        archived.Params.Router = nil
        table.insert(self._history, archived)
    end
    return true
end

function class:go(path: string, params: { [any]: any }?, options: RouteOptions?)
    assert(type(path) == "string", "Passing non-string value to :go(), malfunctioning")
    local match = self._routes[PathFormat(path)]
    if match then
        self:_set(match, params, options)
    end
end

function class:back(level: number?)
    level = level or 1
    local match = self._history[#self._history - level]
    if match then
        self:_set(match, match.Params, { noHistory = true })
    end
end

return function(params)
    local function destruct(node)
        local items = {}
        if node.Type == Symbols.Route then
            local newRoute = table.clone(node)
            newRoute[Children] = nil
            table.insert(items, newRoute)
        end
        for _, route in node[Children] or {} do
            for _, item in destruct(route) do
                item.Path = PathFormat((node.Path or "") .. item.Path)
                table.insert(items, item)
            end
        end
        return items
    end
    params = destruct(params)
    for index, route in params do
        params[index] = nil
        params[route.Path] = route
    end
    local router = setmetatable({
        _routes = params,
        _history = {},
        Type = Symbols.Router,
        Serving = {
            Path = State(),
            View = State(function() end),
            Meta = State({}),
            Params = {},
        }
    }, class)
    router:go(params.DefaultPath or "/")
    return router
end