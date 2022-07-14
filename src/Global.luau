local Fusion = require(script.Parent.Parent.Fusion)

local applet = {
    Name = "Global",
    Lifecycles = {},
    Public = {},
}

function applet.Public.new(name: string, value: any)
    assert(applet.Public[name], ("Got %s, a value that has been created"):format(name))
    applet.Public[name] = Fusion.State(value)
end

return function(router)
    router.Applet:attach(applet)
    return applet
end