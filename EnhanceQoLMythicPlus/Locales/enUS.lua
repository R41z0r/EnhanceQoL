local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Keystone"
L["Automatically insert keystone"] = "Automatically insert keystone"
L["Mythic Plus"] = "Mythic+"
L[addonName] = "Mythic+"
L["Close all bags on keystone insert"] = "Close all bags on keystone insert"
L["ReadyCheck"] = "Ready Check"
L["ReadyCheckWaiting"] = "Checking Readiness..."
L["PullTimer"] = "Pull Timer"
L["Pull"] = "Pull"
L["Cancel"] = "Cancel"
L["Cancel Pull Timer on click"] = "Cancel Pull Timer on click"
L["noChatOnPullTimer"] = "No chatmessage on Pull Timer"
L["sliderShortTime"] = "Pull Timer rightclick"
L["sliderLongTime"] = "Pull Timer"
L["Stating"] = "Starting..."
L["autoKeyStart"] = "Start key automatically after Pull Timer"
L["mythicPlusTruePercent"] = "Show decimal value of Enemy Forces"
L["mythicPlusChestTimer"] = "Show chest timers"

L["None"] = "No Pull Timer"
L["Blizzard Pull Timer"] = "Blizzard Pull Timer"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs Pull Timer"
L["Both"] = "Blizzard and DBM / BigWigs"
L["Pull Timer Type"] = "Pull Timer Type"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "Drag me to position Cooldownbars"
L["Potion Tracker"] = "Potion tracker"
L["Toggle Anchor"] = "Toggle anchor"
L["Save Anchor"] = "Save anchor"
L["potionTrackerHeadline"] = "This enables you to track the CD of the combat potions of your party members as a moveable bar"
L["potionTracker"] = "Enable potion cooldown tracker"
L["potionTrackerUpwardsBar"] = "Grow upwards"
L["potionTrackerClassColor"] = "Use class colors for bars"
L["potionTrackerDisableRaid"] = "Disable potion tracker in raid"

L["Tinker"] = "Tinker"
L["InvisPotion"] = "Invis"
L["potionTrackerShowTooltip"] = "Show tooltip on icon"
L["HealingPotion"] = "Heal"
L["potionTrackerHealingPotions"] = "Track health pot CD"
L["potionTrackerOffhealing"] = "Track Offhealing CD usage"
-- LFG Tools

L["DungeonBrowser"] = "Dungeonbrowser"
L["groupfinderAppText"] = 'Hide the group finder text "Your group is currently forming"'
L["groupfinderSkipRolecheck"] = "Skip Role Check and use current role"
L["groupfinderMoveResetButton"] = "Shift the 'Reset Filter' button in the Dungeon Browser to the left side."
L["groupfinderShowDungeonScoreFrame"] = "Show " .. DUNGEON_SCORE .. " frame next to the Dungeon Finder"

-- Misc Frame
L["Misc"] = "Misc."
L["autoMarkTankInDungeon"] = "Automatically mark the " .. TANK .. " in dungeons"
L["autoMarkTankInDungeonMarker"] = "Tank marker"
L["Disabled"] = "Disabled"
L["autoMarkTankExplanation"] = "It will mark the " .. TANK .. " when he has no mark and only changes the mark, when you are either " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " or " .. TANK

L["mythicPlusIgnoreMythic"] = "Do not apply a raid marker in " .. PLAYER_DIFFICULTY6 .. " dungeons"
L["mythicPlusIgnoreHeroic"] = "Do not apply a raid marker in " .. PLAYER_DIFFICULTY2 .. " dungeons"
L["mythicPlusIgnoreEvent"] = "Do not apply a raid marker in " .. BATTLE_PET_SOURCE_7 .. " dungeons"
L["mythicPlusIgnoreNormal"] = "Do not apply a raid marker in " .. PLAYER_DIFFICULTY1 .. " dungeons"
L["mythicPlusIgnoreTimewalking"] = "Do not apply a raid marker in " .. PLAYER_DIFFICULTY_TIMEWALKER .. " dungeons"

-- Teleports
L["Teleports"] = "Teleports"
L["teleportEnabled"] = "Enable Teleport Frame"
L["DungeonCompendium"] = "Teleport Compendium"
L["teleportsEnableCompendium"] = "Enable Teleport Compendium"

L["teleportsHeadline"] = "This adds a frame with Dungeon Teleports to your PVEFrame"
L["teleportCompendiumHeadline"] = "Hide teleports from specific expansions"
L["portalHideMissing"] = "Hide missing Teleports"
L["portalShowTooltip"] = "Show tooltip on Teleport buttons"
L["hideActualSeason"] = "Hide Teleports from actual Season in " .. L["DungeonCompendium"]
