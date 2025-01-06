local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "Enable visible ring around the mouse cursor"
L["mouseTrailEnabled"] = "Enable visible trail while moving the mouse cursor"
L["Trailinfo"] = "Depending on your Hardware this could have a performance impact"
L["mouseTrailDensity"] = "Mouse trail density"