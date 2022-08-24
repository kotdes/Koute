local function Meta(fieldName: string)
    return {
        type = "Symbol",
        name = "Meta",
        key = fieldName
    }
end

return Meta