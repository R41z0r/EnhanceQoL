local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Automatically insert keystone"] = "Automatically insert keystone"
L["Mythic Plus"] = "Mythic Plus"
L[addonName] = "Mythic Plus"