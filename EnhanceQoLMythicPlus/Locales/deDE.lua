if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    return
end

local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Automatically insert keystone"] = "Schlüsselstein automatisch einsetzen"
L["Mythic Plus"] = "Mythisch Plus"
L[addonName] = "Mythisch Plus"
