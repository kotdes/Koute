local function formatPath(path: string): string
    if path:sub(-1, -1) == "/" then
        path = path:sub(1, -2)
    end
    if path:sub(1, 1) ~= "/" then
        path ..= "/" .. path
    end
    return path
end

return formatPath
