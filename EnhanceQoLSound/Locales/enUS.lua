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

L["open"] = MUTE .. " open"
L["close"] = MUTE .. " " .. CLOSE
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

-- Interface
L["interface"] = INTERFACE_LABEL
L["general"] = GENERAL
--Auction House
L["auctionhouse"] = BUTTON_LAG_AUCTIONHOUSE
-- Pings
L["ping_attack"] = MUTE .. " " .. PING .. " " .. BINDING_NAME_PINGATTACK
L["ping_assist"] = MUTE .. " " .. PING .. " " .. BINDING_NAME_PINGASSIST
L["ping_omw"] = MUTE .. " " .. PING .. " " .. BINDING_NAME_PINGONMYWAY
L["ping_warning"] = MUTE .. " " .. PING .. " " .. BINDING_NAME_PINGWARNING
L["ping_ping"] = MUTE .. " " .. DEFAULT .. " " .. PING
L["ping_minimap"] = MUTE .. " " .. PING .. " " .. MINIMAP_LABEL
L["ping"] = PING
