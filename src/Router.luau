local Fusion = require(script.Parent.Parent.Fusion)
local PathFormat = require(script.Parent.PathFormat)
local Symbols = require(script.Parent.Symbols)

local Children = Fusion.Children
local State = Fusion.State

local class = {}
class.__index = class

type RouteOptions = {
	noHistory: boolean?,
}

type Route = {
	Type: typeof(Symbols.Route),
	Path: string,
	Meta: { [any]: any },
	View: (any) -> (GuiObject) | GuiObject,
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
		if value.type == "State" and value.get then
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

function class:_set(route: Route, params: { [any]: any }, options: RouteOptions)
	local prevPath = self.Serving.Path:get()
	route = table.clone(route)
	for index, value in route.Meta do
		if value.Type == Symbols.Dynamic then
			route.Meta[index] = value.Value(route, params)
		end
	end
	self.Serving.Params = params
	self.Serving.Params.Router = self
	for _, item in { "Meta", "Path", "View" } do
        if item == "View" and self._private.options.UseInstanceForView then
            self.Serving[item]:set(route[item](self.Serving.Params))
            continue
        end
		self.Serving[item]:set(route[item])
	end
	if not options.DoNotSaveToHistory and self.Serving.Path:get() ~= prevPath then
		local archived = archive(self.Serving)
		archived.Params.Router = nil
		table.insert(self._private.history, archived)
        if #self._private.history > self._private.options.MaxHistoryEntry then
            if self._private.options.UseInstanceForView and self._private.history[1].View:get() then
                self._private.history[1].View:get():Destroy()
                self._private.history[1].View:set()
            end
            table.remove(self._private.history, 1)
        end
	end
end

function class:go(path: string, params: { [any]: any }?, options: RouteOptions?)
	assert(type(path) == "string", "Passing non-string value to :go(), malfunctioning")
	local match = self._private.routes[PathFormat(path)]
    assert(match, "No such route with path " .. path)
	self:_set(match, params or {}, compareAndMerge(options or {}, DEFAULT_ROUTE_OPTIONS))
end

function class:back(level: number?)
	level = level or 1
	local match = self._private.history[#self._private.history - level]
	assert(match, "Can not go back any more further")
	self:_set(match, match.Params, compareAndMerge({ DoNotSaveToHistory = true }, DEFAULT_ROUTE_OPTIONS))
end

return function(params)
	local function destruct(node)
		local items = {}
		if node.Type == Symbols.Route then
			local newRoute = table.clone(node)
			newRoute[Children] = nil
			table.insert(items, newRoute)
		end
		for _, route in node[Children] or node do
            if type(route) == "table" and route.Type == Symbols.Route then
                for _, item in destruct(route) do
                    item.Path = PathFormat((node.Path or "") .. item.Path)
                    table.insert(items, item)
                end
            end
		end
		return items
	end
	local router = setmetatable({
        _private = {
            routes = destruct(params[Children]),
            history = {},
            options = compareAndMerge(params, DEFAULT_ROUTER_OPTIONS),
        },
        Type = Symbols.Router,
		Serving = {
			Path = State(),
			View = State(function() end),
			Meta = State({}),
			Params = {},
		},
	}, class)
    router._private.options[Children] = nil

	local _tmp_tbl = {}
	for _, route in router._private.routes do
		_tmp_tbl[route.Path] = route
    end
	router._private.routes = _tmp_tbl

	router:go(router._private.options.DefaultPath)
	return router
end
