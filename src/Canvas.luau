local Fusion = require(script.Parent.Parent.Fusion)
local Symbols = require(script.Parent.Symbols)

local Children = Fusion.Children
local State = Fusion.State
local Compat = Fusion.Compat
local New = Fusion.New
local OnEvent = Fusion.OnEvent

return function(params)
    assert(params.Source and params.Source.Type == Symbols.Router, "Canvas.Source expects Router, got invalid datatype")
    local page = State()
    local function render()
        if params.PreRender then params.PreRender() end
        if typeof(params.Source.Serving.View:get()) == "Instance" then
            page:set(params.Source.Serving.View:get())
        else
        page:set(params.Source.Serving.View:get()(params.Source.Serving.Params))
        end
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