local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Koute = require(ReplicatedStorage.Packages.Koute)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Route = Koute.Route
local Router = Koute.Router
local Lazy = Koute.Lazy
local Dynamic = Koute.Dynamic
local Canvas = Koute.Canvas

local Children = Fusion.Children
local New = Fusion.New

local paths, current = {"/", "/a", "/b", "/a/b"}, 1
local appRouter = Router {
    [Children] = Route "/" {
        View = function(params)
            return New "TextLabel" {
                Size = UDim2.fromScale(1, 1),
                Text = params.Router.Serving.Path
            }
        end,
        [Children] = {
            Route "/a" {
                View = function(params)
                    return New "TextLabel" {
                        Size = UDim2.fromScale(1, 1),
                        Text = params.Router.Serving.Path
                    }
                end,
                [Children] = {
                    Route "/b" {
                        View = function(params)
                            return New "TextLabel" {
                                Size = UDim2.fromScale(1, 1),
                                Text = params.Router.Serving.Path
                            }
                        end,
                    }
                }
            },

            Route "/b" {
                View = function(params)
                    return New "TextLabel" {
                        Size = UDim2.fromScale(1, 1),
                        Text = params.Router.Serving.Path
                    }
                end,
            }
        }
    }
}

New "ScreenGui" {
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LocalPlayer.PlayerGui,
    [Children] = {
        Canvas {
            Source = appRouter,
        },
    },
}

while task.wait(5) do
    current += 1
    appRouter:go(paths[current])
end