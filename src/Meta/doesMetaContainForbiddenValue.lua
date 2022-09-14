local FORBIDDEN_META_VALUES = {"Instance", "Function"}

local function doesMetaContainForbiddenValue(value)
    local forbiddenMetaType = table.find(FORBIDDEN_META_VALUES, typeof(value))
    assert(forbiddenMetaType, typeof(forbiddenMetaType) .. " is unacceptable in Koute.Meta")
end

return doesMetaContainForbiddenValue