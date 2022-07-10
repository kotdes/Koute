local function format(path: string): string
    path = if path:sub(1, 1) ~= "/" then "/" .. path else path
    path = if path:sub(-1, -1) == "/" and #path > 1 then path:sub(1, #path - 1) else path
    path = path:gsub("[/]+", "/"):lower()
	return path
end

return format