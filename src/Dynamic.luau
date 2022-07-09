return function(func: (any) -> (any))
    return {
        Type = "$k-dynamic",
        Value = func,
    }
end