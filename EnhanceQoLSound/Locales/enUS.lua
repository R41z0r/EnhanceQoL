local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LSounds

L["monk"] = "Monk"
L["banlu"] = "Mute Ban-Lu"

L["affix"] = "Affix"
L["xalatath"] = "Mute Xal'atath in Dungeons"
L["train"] = "Mute all Train-Emotes"

L["open"] = "Open"
L["close"] = "Close"
L["changeTab"] = "Switch UI Tabs"
L["enterQueue"] = "Enter Queue (PVP/Dungeon)"
L["readycheck"] = READY_CHECK
L["coinsound"] = "Coin sound (looting/buying)"
L["mailboxopen"] = "Mailbox open"
L["repair"] = MINIMAP_TRACKING_REPAIR