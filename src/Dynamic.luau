local Symbols = require(script.Parent.Symbols)

return function(func: (any) -> (any))
    return {
        Type = Symbols.Dynamic,
        Value = func,
    }
end