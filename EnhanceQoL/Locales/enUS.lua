local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Quick signup"
L["Persist LFG signup note"] = "Persist LFG signup note"
L["Select an option"] = "Select an option"
L["Save"] = "Save"
L["Hide Minimap Button"] = "Hide Minimap Button"
L["Left-Click to show options"] = "Left-Click to show options"

L["Hide Raid Tools"] = "Hide Raid Tools in Party"
L["repairCost"] = "Repaired items for "
L["autoRepair"] = "Automatically repair all items"
L["sellAllJunk"] = "Automatically sell all junk items"
L["ignoreTalkingHead"] = "Automatically hide Talking Head Frame"
L["landingPageHide"] = "Enable this option to hide the Expansion Landing Page button on the minimap."
L["automaticallyOpenContainer"] = "Automatically open Container items in bag"

L["showIlvlOnBankFrame"] = "Display item level on the Bank Frame"
L["showIlvlOnMerchantframe"] = "Display item level on the Merchant Frame"
L["showIlvlOnCharframe"] = "Display item level on Character Equipment Frame"
L["showGemsOnCharframe"] = "Display gem slots on Character Equipment Frame"
L["showGemsTooltipOnCharframe"] = "Display gem slots tooltip on Character Equipment Frame"
L["showEnchantOnCharframe"] = "Display enchants on Character Equipment Frame"
L["showCatalystChargesOnCharframe"] = "Display Catalyst charges on Character Equipment Frame"
L["showIlvlOnBagItems"] = "Display ilvl on equipment in all bags"
L["showDurabilityOnCharframe"] = "Display Durability on Character Equipment Frame"
L["hideOrderHallBar"] = "Hide Order Hall Command Bar"
L["showInfoOnInspectFrame"] = "Show additional information on the Inspect Frame (Experimental)"
L["MissingEnchant"] = "Enchant"
L["hideHitIndicatorPlayer"] = "Hide floating combat text (damage and healing) over your character"
L["hideHitIndicatorPet"] = "Hide floating combat text (damage and healing) over your pet"
L["UnitFrame"] = "UnitFrame"
L["SellJunkIgnoredBag"] = "You have ignored junk on %d bags.\nThis may prevent selling all junk items automatically."

L["deleteItemFillDialog"] = 'Add "' .. DELETE_ITEM_CONFIRM_STRING .. '" to the "Delete confirmation Popup"'
L["confirmPatronOrderDialog"] = "Automatically confirm to use own materials on " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC .. " crafting orders"
L["autoChooseQuest"] = "Automatically accept and complete Quests"
L["confirmTimerRemovalTrade"] = "Automatically confirm to sell tradeable loot within the trade window time frame"

L["General"] = "General"
L["Character"] = "Character"
L["Dungeon"] = "Dungeon"
L["Misc"] = "Misc."
L["Quest"] = "Quest"

L["hideBagsBar"] = "Hide Bagsbar"
-- Dungeon
L["autoChooseDelvePower"] = "Automatically select delve power when only 1 option"
L["lfgSortByRio"] = "Sort Mythic Dungeon Applicants by Mythic Score"

-- Quest
L["ignoreTrivialQuests"] = "Ignore trivial quests"
L["ignoreDailyQuests"] = "Ignore daily/weekly quests"

L["autoQuickLoot"] = "Quick loot items"
L["openCharframeOnUpgrade"] = "Open the character frame when upgrading items at the vendor"

L["headerClassInfo"] = "These settings only apply to " .. select(1, UnitClass("player"))

-- Deathknight
L["deathknight_HideRuneFrame"] = "Hide Runeframe"

-- Evoker
L["evoker_HideEssence"] = "Hide Essencebar"

-- Monk
L["monk_HideHarmonyBar"] = "Hide Harmonybar"
L["monk_MuteBanlu"] = MUTE .. ": Ban-Lu"
-- Paladin
L["paladin_HideHolyPower"] = "Hide Holypowerbar"

-- Rogue
L["rogue_HideComboPoint"] = "Hide Combopointbar"

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- Shaman
L["shaman_HideTotem"] = "Hide Totembar"

-- Warlock
L["warlock_HideSoulShardBar"] = "Hide Soulshard Bar"

L["questAddNPCToExclude"] = "Add targetted NPC/opened Gossipwindow to exclude"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Interface Reload Required"
L["bReloadInterface"] = "You need to reload your interface to apply changes"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "Enable autodismount when using abilities" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "Enable autodismount when using abilities while flying" },
	["chatMouseScroll"] = { description = "Enable mouse scroll in chat", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "Disable death effects", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "Enable Map Fade while moving" },
	["scriptErrors"] = { description = "Show LUA-Error on UI", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "Show class colors on nameplates", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "Show the Castbar of your Target" },
	["showTutorials"] = { description = "Disable tutorials", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "Enable enhanced tooltips", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "Show the Guild on Players" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "Show the Title on Players" },
	["WholeChatWindowClickable"] = { description = "Make the entire chat window clickable", trueValue = "1", falseValue = "0" },
}
