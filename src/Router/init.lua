local Koute = script.Parent
local Packages = script.Parent.Parent

local Types = require(script.Parent.Types)
local Fusion = require(Packages.Fusion)
local deconstructRoute = require(Koute.Route.deconstructRoute)
local formatPath = require(Koute.Route.formatPath)
local doesMetaContainForbiddenValue = require(Koute.Meta.doesMetaContainForbiddenValue)

local Value = Fusion.Value
local Observer = Fusion.Observer
local Children = Fusion.Children

local class = {
	type = "router",
}
class.__index = class
local currentlyAt = 1

local function updateServing(class: Types.Router, route: Types.DeconstructedRoute, params: { any })
	class.serving.path:set(route.path)
	class.serving.meta:set(route.meta)
	class.serving.params = params
	class.serving.view:set(route.view)
end

local function unpackRoutes(route)
	local routes = {}
	table.insert(routes, route)

	if route[Children] then
		for _, child in route[Children] do
			for _, child in unpackRoutes(child) do
				table.insert(routes, child)
			end
		end
	end

	for _, route in routes do
		route[Children] = nil
	end
	
	return routes
end

function class:set(route: Types.DeconstructedRoute, params: { any }, direction: string)
	if direction == "go" and currentlyAt ~= #self.history then
		for i = currentlyAt + 1, #self.history do
			table.remove(self.history, i)
		end
		currentlyAt = #self.history
	end

	updateServing(self, route, params)

	if direction == "go" then
		currentlyAt += 1
		local archivedRoute = table.clone(route)
		archivedRoute.params = params
		table.insert(self.history, archivedRoute)
	end
end

function class:go(path: string, params: { any }?)
	local route = self.routes[formatPath(path)]
	assert(route, "this route does not exist")
	class:set(route, params or {}, "go")
end

function class:back(level: number?)
	level = level or 1
	local route = self.history[currentlyAt - level]
	assert(route, "history route does not exist")
	currentlyAt = #self.history - level
	class:set(route, route.params, "back")
end

return function(params)
	local router = setmetatable({
		history = {},
		serving = {
			path = Value(""),
			view = Value(),
			meta = Value({}),
			params = {},
		},
		routes = {},
	}, class)
	for _, route in params.routes do
		deconstructRoute(route)
		for _, route in unpackRoutes(route) do
			router.routes[route.path] = route
		end
	end

	Observer(router.serving.meta):onChange(function()
		for _, meta in router.serving.meta:get() do
			doesMetaContainForbiddenValue(meta)
		end
	end)

	return router
end
