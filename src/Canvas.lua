local Fusion = require(script.Parent.Parent.Fusion)

local Children = Fusion.Children
local State = Fusion.State
local Compat = Fusion.Compat
local New = Fusion.New
local OnEvent = Fusion.OnEvent

return function(params)
    local page = State()
    local function render()
        if params.PreRender then params.PreRender() end
        page:set(params.Source.Serving.View:get()(params.Source.Serving.Params))
        if params.Rendered then params.Rendered() end
    end
    local disconnectRenderer = Compat(params.Source.Serving.View):onChange(function()
        render()
    end)
    render()

    return New "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,
        [Children] = page,
        [OnEvent "Destroying"] = function()
            disconnectRenderer()
        end,
    }
end