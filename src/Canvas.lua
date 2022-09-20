local Packages = script.Parent.Parent
local Fusion = require(Packages.Fusion)

local isUsingNewFusionKeywords = Fusion.version.minor >= 2
local New = Fusion.New
local State = isUsingNewFusionKeywords and Fusion.Value or Fusion.State
local Compat = isUsingNewFusionKeywords and Fusion.Observer or Fusion.Compat
local Children = Fusion.Children

local function isDeprecated(props)
    for i, v in {Source = "source", PostRender = "postRender", PreRender = "preRender"} do
        if props[i] then
            warn(("props.%s is deprecated and will soon be removed, please use props.%s"):format(i, v))
            props[v] = props[i]
        end
    end
end

local function Canvas(props)
    isDeprecated(props)
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
