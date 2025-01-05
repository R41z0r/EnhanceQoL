local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LAura

L["Aura"] = "Aura Tracker"
L["DragToPosition"] = "Drag me to position"