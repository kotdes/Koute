local Fusion = require(script.Parent.Parent.Fusion)
local PathFormat = require(script.Parent.PathFormat)
local Symbols = require(script.Parent.Symbols)

local Children = Fusion.Children
local State = Fusion.State

local AVAIL_LIFECYCLES = { "PreSet", "OnSet" }

local class = { Applet = { _index = {} }, _lifecycles = {} }
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

type Applet = {
    Name: string,
    Lifecycles: { [string]: (any) -> () },
    Public: { [string]: any },
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

function class:_fireLifecycle(lifecycleName: string, ...)
    assert(table.find(AVAIL_LIFECYCLES, lifecycleName), ("Got %s, invalid lifecycle method"):format(lifecycleName))
    local threads = table.create(#self._lifecycles, false)
    local currentThread = 1
    local function next()
        threads[currentThread] = true
    end
    for index, lifecycle in self._lifecycles do
        currentThread = index
        lifecycle(next, {...})
        if threads[currentThread] then
            continue
        else
            return false
        end
    end
    return true
end

function class:_set(route: Route, params: {[ any]: any }?, options: RouteOptions?)
    local prevPath = self.Serving.Path:get()
    route = table.clone(route)
    options = options or {}
    params = params or {}
    for index, value in route.Meta do
        if value.Type == Symbols.Dynamic then
            route.Meta[index] = value.Value(route, params)
        end
    end
    if not options.forceSet then
        if not self:_fireLifecycle("PreSet", route, params) then
            return false
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
    if not options.forceSet then
        task.spawn(self:_fireLifecycle("OnSet", route, params))
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

function class.Applet:attach(applet: Applet)
    assert(self.Applet._index[applet.Name], ("Got %s, an applet name that has been attached"):format(applet.Name))
    for name, func in applet.Lifecycles do
        assert(table.find(AVAIL_LIFECYCLES, name), ("Got %s, invalid lifecycle method"):format(name))
        table.insert(self._lifecycles, func)
    end
    self.Applet._index[applet.Name] = applet.Public
end

function class.Applet:use(appletName: string)
    assert(self.Applet._index[appletName], ("Got %s, unattached applet"):format(appletName))
    return self.Applet._index[appletName]
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