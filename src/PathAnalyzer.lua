local function join(fragments: { string }) : string
    return table.concat(fragments, "/"):lower()
end

local function split(path: string): { string }
    local fragments = {}
    path = if path:sub(1, 1) ~= "/" then "/" .. path else path
    path:gsub("/(%a*", function(fragment)
        table.insert(fragments, fragment:lower())
    end)
    return fragments
end

local function format(path: string): string
    path = if path:sub(1, 1) ~= "/" then "/" .. path else path
    path = if path:sub(-1, -1) == "/" and #path > 1 then path:sub(1, #path - 1) else path
    path = path:gsub("[/]+", "/"):lower()
	return path
end

return {
    join = join,
    split = split,
    format = format,
}