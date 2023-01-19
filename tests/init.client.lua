local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Packages = ReplicatedStorage.Packages
local Koute = require(Packages.Koute)
local Fusion = require(Packages.Fusion)

local Children = Fusion.Children
local New = Fusion.New
local Value = Fusion.Value
local Router = Koute.Router
local Route = Koute.Route
local Canvas = Koute.Canvas

local function createDemoFrame(props)
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        [Children] = {
            New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = props.PageName,
            }
        }
    }
end

local actionState = Value("None")
local router = Router {
    routes = {
        Route "/" {
            view = function(_, context)
                return createDemoFrame({ PageName = context.path:get()})
            end,
        },

        Route "/abc" {
            view = function(_, context)
                return createDemoFrame({ PageName = context.path:get()})
            end,
            [Children] = {
                Route "/def" {
                    view = function(_, context)
                        return createDemoFrame({ PageName = context.path:get()})
                    end,
                },

                Route "/hij" {
                    view = function(_, context)
                        return createDemoFrame({ PageName = context.path:get()})
                    end,
                },
            },
        },
    },
}

New "ScreenGui" {
    Parent = PlayerGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    [Children] = {
        New "TextLabel" {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 12),
            Size = UDim2.fromOffset(0, 14),
            Text = actionState,
            ZIndex = 2,
        },

        Canvas {
            source = router,
        }
    }
}

print(router.routes)
actionState:set("Goto /abc/")
router:go("/abc")
task.wait(1)
actionState:set("Goto /abc/hij")
router:go("/abc/hij")
task.wait(1)
router:go("/abc/hij")
actionState:set("Goto /abc/def/")
router:go("/abc/def")
task.wait(1)
actionState:set("Go back by 2")
router:back(2)
task.wait(1)
actionState:set("Goto /abc/def/")
router:go("/abc/def")
task.wait(1)
print(router.history)
router:go("/")
actionState:set("OK!")