return function(import: ModuleScript): () -> (any)
    return function(...)
        return require(import)(...)
    end
end