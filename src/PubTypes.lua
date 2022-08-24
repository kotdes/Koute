export type Koute = {
    _version: string,
    Route: (string) -> (({any}) -> {any}),
    Meta: (string) -> ({any}),
    Router: ({any}) -> {any},
}

return {}