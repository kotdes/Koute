local Packages = script.Parent.Parent
local Fusion = require(Packages.Fusion)

local New = Fusion.New
local State = Fusion.State
local Compat = Fusion.Compat
local Children = Fusion.Children

local function Canvas(props)
    -- Fusion.Computed lacks destructor function atm, will switch to Fusion.Computed implementation in the future
    local children = State(nil)
    Compat(props.source.serving.view):onChange(function()
        if props.preRender then
            props.preRender()
        end
        -- Fusion.State is not equipped with destructor function, must be cleaned up manually for now
        if typeof(children:get()) == "Instance" then
            children:get():Destroy()
        end
        children:set(props.source.serving.view:get()(props.source, props.source.serving))
        if props.postRender then
            props.postRender()
        end
    end)

    return New "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),

        [Children] = children
    }
end

return Canvas
