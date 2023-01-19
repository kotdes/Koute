local Packages = script.Parent.Parent
local Fusion = require(Packages.Fusion)

type Value = Fusion.Value
type Children = Fusion.Children
type Symbol = Fusion.Symbol

type viewConstructor = ({ router, routerServing }) -> (GuiObject)
type meta = { [string]: any }
type routerServing = {
    path: Value<string>,
    view: Value<viewConstructor>,
    meta: Value<meta>,
    params: { any },
},

export type DeconstructedRoute = {
    type: string,
    path: string,
    view: viewConstructor,
    meta: meta,
}

export type Route = {
    type: string,
    path: string,
    view: viewConstructor,
    [Children]: { Route }?,
}

export type RouteParams = {
    view: viewConstructor
    [Children]: { Route }?,
}

export type Router = {
    type: string,
    history: {},
    serving: routerServing,
    routes: { DeconstructedRoute? },

    go: (Router, string, { any }) -> (),
    back: (Router, number?) -> (),
    set: (Router, DeconstructedRoute, { any }, string) -> (),
}

export type RouterParams = {
    routes: { Route },
}

export type CanvasParams = {
    source: Router,
    preRender: () -> ()?,
    postRender: () -> ()?,
}

export type Koute = {
    _version: string,
    Route: (string) -> ((RouteParams) -> Route),
    Meta: (string) -> (Symbol),
    Router: (RouterParams) -> (Router),
    Canvas: ({ Source: Router }) -> ( Frame ),
}

return {}
