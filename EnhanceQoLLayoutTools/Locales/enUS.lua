local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LLayoutTools

L["Move"] = "Layout Tools"

L["uiScalerPlayerSpellsFrameMove"] = "Enable to move " .. PLAYERSPELLS_BUTTON
L["uiScalerPlayerSpellsFrameEnabled"] = "Enable to Scale the " .. PLAYERSPELLS_BUTTON


L["uiScalerCharacterFrameMove"] = "Enable to move " .. CHARACTER_BUTTON
L["uiScalerCharacterFrameEnabled"] = "Enable to Scale the " .. CHARACTER_BUTTON
