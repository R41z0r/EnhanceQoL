if (GAME_LOCALE or GetLocale()) ~= "deDE" then return end
local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "Tooltip"
L[addonName] = "Tooltip"
L["None"] = "Keine"
L["Enemies"] = "Feinde"
L["Friendly"] = "Freundlich"
L["Both"] = "Beide"
L["TooltipOFF"] = "AUS"
L["TooltipON"] = "AN"
L["TooltipAnchorType"] = "Tooltip Position"
L["CursorCenter"] = "Zentriert am Cursor"
L["CursorLeft"] = "Links vom Cursor"
L["CursorRight"] = "Rechts vom Cursor"
L["TooltipAnchorOffsetX"] = "Horizontaler Versatz"
L["TooltipAnchorOffsetY"] = "Vertikaler Versatz"

-- Tabs
L["Unit"] = "Einheit"
L["Spell"] = "Zauber"
L["Item"] = "Gegenstand"
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"
L["Buff_Debuff"] = L["Buff"] .. "/" .. L["Debuff"]

-- Buff
L["TooltipBuffHideType"] = "Tooltip bei " .. L["Buff_Debuff"] .. " ausblenden"
L["TooltipBuffHideInCombat"] = "Nur im Kampf ausblenden"
L["TooltipBuffHideInDungeon"] = "Nur in Dungeons ausblenden"

-- Debuff
L["TooltipDebuffHideType"] = "Tooltip bei Debuffs ausblenden"
L["TooltipDebuffHideInCombat"] = "Nur im Kampf ausblenden"
L["TooltipDebuffHideInDungeon"] = "Nur in Dungeons ausblenden"

-- Unit
L["TooltipUnitHideType"] = "Tooltip bei Einheiten ausblenden"
L["TooltipUnitHideInCombat"] = "Nur im Kampf ausblenden"
L["TooltipUnitHideInDungeon"] = "Nur in Dungeons ausblenden"
L["BestMythic+run"] = "Bester Lauf"
L["TooltipShowMythicScore"] = DUNGEON_SCORE .. " im Tooltip anzeigen"
L["TooltipShowClassColor"] = "Klassenfarbe im Tooltip anzeigen"
L["TooltipShowNPCID"] = "NPC-ID anzeigen"
L["NPCID"] = "ID"

-- Spell
L["TooltipSpellHideType"] = "Tooltip bei Zaubern ausblenden"

L["TooltipSpellHideInCombat"] = "Nur im Kampf ausblenden"
L["TooltipSpellHideInDungeon"] = "Nur in Dungeons ausblenden"

L["TooltipShowSpellID"] = "Zauber-ID im Tooltip anzeigen"
L["SpellID"] = "Zauber-ID"
L["MacroID"] = "Makro-ID"

-- Item
L["TooltipItemHideType"] = "Tooltip bei Gegenständen ausblenden"

L["TooltipItemHideInCombat"] = "Nur im Kampf ausblenden"
L["TooltipItemHideInDungeon"] = "Nur in Dungeons ausblenden"

L["ItemID"] = "Item-ID"
L["TooltipShowItemID"] = "Item-ID im Tooltip anzeigen"

L["TooltipShowItemCount"] = "Gegenstandszahl im Tooltip anzeigen"
L["TooltipShowSeperateItemCount"] = "Gegenstandszahl pro Standort getrennt anzeigen"
L["Reagentbank"] = "Materiallager"
L["Bank"] = "Bank"
L["Bag"] = "Tasche"
L["Itemcount"] = "Gegenstandszahl"

L["TooltipShowQuestID"] = "Quest-ID anzeigen"

L["TooltipShowCurrencyAccountWide"] = "Accountweite Währungen im Tooltip anzeigen"