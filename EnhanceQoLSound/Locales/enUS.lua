local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LSounds

L["monk"] = "Monk"

L["affix"] = "Affix"
L["xalatath"] = "Mute Xal'atath in Dungeons"
L["train"] = "Mute all Train-Emotes"

L["open"] = "Mute open-sound"
L["close"] = "Mute close-sound"
L["changeTab"] = "Mute UI Tabs switch"
L["enterQueue"] = "Mute Enter Queue (PVP/Dungeon)"
L["readycheck"] = "Mute " .. READY_CHECK
L["coinsound"] = "Mute coin sound (looting/buying)"
L["mailboxopen"] = "Mute Mailbox open"
L["repair"] = "Mute " .. MINIMAP_TRACKING_REPAIR

-- Dungeon
L["tww"] = EXPANSION_NAME10
L["stonevault"] = "Stonevault"
L["dagran_thaurissan_ii"] = "Mute Dagran Thaurissan II (Talking Head)"

-- Mounts
L["banlu"] = "Mute Ban-Lu"
L["grand_expedition_yak"] = "Mute Grand Expedition Yak Merchants"
L["peafowl"] = "Mute Peafowl cry"
L["wonderwing_20"] = "Mute Wonderwing 2.0 squeak"

-- Spells
L["bloodlust"] = "Mute Bloodlust/Heroism sounds"
