if (GAME_LOCALE or GetLocale()) ~= "itIT" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "Descrizione comandi"
L[addonName] = "Descrizione comandi"
L["None"] = "Nessuno"
L["Enemies"] = "Nemici"
L["Friendly"] = "Amichevole"
L["Both"] = "Entrambi"
L["TooltipOFF"] = "SPENTO"
L["TooltipON"] = "ACCESO"
L["TooltipAnchorType"] = "Posizione Tooltip"
L["CursorCenter"] = "Centrato sul cursore"
L["CursorLeft"] = "A sinistra del cursore"
L["CursorRight"] = "A destra del cursore"
L["TooltipAnchorOffsetX"] = "Offset orizzontale"
L["TooltipAnchorOffsetY"] = "Offset verticale"

-- Tabs
L["Unit"] = "Unità"
L["Spell"] = "Incantesimo"
L["Item"] = "Oggetto"
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"
L["Buff_Debuff"] = L["Buff"] .. "/" .. L["Debuff"]

-- Buff
L["TooltipBuffHideType"] = "Nascondi tooltip su " .. L["Buff_Debuff"]
L["TooltipBuffHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipBuffHideInDungeon"] = "Nascondi solo nei dungeon"

-- Debuff
L["TooltipDebuffHideType"] = "Nascondi tooltip su debuff"
L["TooltipDebuffHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipDebuffHideInDungeon"] = "Nascondi solo nei dungeon"

-- Unit
L["TooltipUnitHideType"] = "Nascondi tooltip su unità"
L["TooltipUnitHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipUnitHideInDungeon"] = "Nascondi solo nei dungeon"
L["Mythic+ Score"] = "Punteggio Mitico+"
L["BestMythic+run"] = "Miglior corsa"
L["TooltipShowMythicScore"] = "Mostra il Punteggio Mitico+ nel Tooltip"
L["TooltipShowClassColor"] = "Mostra il colore della classe nel tooltip"
L["TooltipShowNPCID"] = "Mostra ID NPC"
L["NPCID"] = "ID"

-- Spell
L["TooltipSpellHideType"] = "Nascondi tooltip su incantesimi"

L["TooltipSpellHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipSpellHideInDungeon"] = "Nascondi solo nei dungeon"

L["TooltipShowSpellID"] = "Mostra l'ID dell'incantesimo nel tooltip"
L["SpellID"] = "ID Incantesimo"
L["MacroID"] = "ID Macro"

-- Item
L["TooltipItemHideType"] = "Nascondi tooltip su oggetti"

L["TooltipItemHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipItemHideInDungeon"] = "Nascondi solo nei dungeon"

L["ItemID"] = "ID Oggetto"
L["TooltipShowItemID"] = "Mostra l'ID dell'oggetto nel tooltip"

L["TooltipShowItemCount"] = "Mostra il conteggio degli oggetti nel tooltip"
L["TooltipShowSeperateItemCount"] = "Mostra il conteggio degli oggetti separato per posizione"
L["Reagentbank"] = "Banca dei reagenti"
L["Bank"] = "Banca"
L["Bag"] = "Borsa"
L["Itemcount"] = "Conteggio oggetti"
