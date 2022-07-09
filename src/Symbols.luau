local function Symbol(name: string)
	local self = newproxy(true)
	local wrappedName = ("Symbol (%s)"):format(name)
	getmetatable(self).__tostring = function()
		return wrappedName
	end
	return self
end

return {
    Dynamic = Symbol "$k-dynamic",
    Lazy = Symbol "$k-lazy",
    Route = Symbol "$k-route",
	Router = Symbol "$k-router",
}