local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Koute = require(Packages.Koute)
local Fusion = require(Packages.Fusion)

local Children = Fusion.Children

local routes = {
    Koute.Route "/" {
        view = function()
            
        end
    },

    Koute.Route "/abc" {
        view = function()
            
        end,
        [Children] = {
            Koute.Route "/def" {
                view = function()
                    
                end,
            },

            Koute.Route "/hij" {
                view = function()
                    
                end
            }
        }
    }
}

local router = Koute.Router {
    routes = routes
}

print(router.routes)

router:go("/abc")
router:go("/abc/hij")
router:go("/abc/def")
print(router.history)
router:back(2)
router:go("/abc/def")
print(router.history)