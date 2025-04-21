local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Keystone"
L["NoKeystone"] = "No Info"
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
L["interruptWithShift"] = "Hold shift to interrupt that feature"

L["None"] = "No Pull Timer"
L["Blizzard Pull Timer"] = "Blizzard Pull Timer"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs Pull Timer"
L["Both"] = "Blizzard and DBM / BigWigs"
L["Pull Timer Type"] = "Pull Timer Type"

L["groupfinderShowDungeonScoreFrame"] = "Show " .. DUNGEON_SCORE .. " frame next to the Dungeon Finder"
-- Keystone
L["groupfinderShowPartyKeystone"] = "Display your party members Mythic+ Keystone info"
L["groupfinderShowPartyKeystoneDesc"] = "Allows you to click on the keyinfo icon to teleport to that dungeon"

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

-- Automark Frame
L["AutoMark"] = "Tank marker"
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
L["teleportCompendiumAdditionHeadline"] = "Additional Portal Options"
L["portalShowDungeonTeleports"] = "Show Dungeon Teleports"
L["portalShowRaidTeleports"] = "Show Raid Teleports"
L["portalShowToyHearthstones"] = "Show Teleport Items and Toys (e.g. Hearthstones)"
L["portalShowEngineering"] = "Show Engineering Teleports (Requires Engineering)"
L["portalShowClassTeleport"] = "Show Class-Specific Teleports (Only if this class has any)"
L["portalShowMagePortal"] = "Show Mage Portals (Mage only)"

-- BR Tracker
L["BRTracker"] = "Combat Resurrection"
L["brTrackerHeadline"] = "Adds a Combat Resurrection tracker in Mythic+ dungeons"
L["mythicPlusBRTrackerEnabled"] = "Enable Combat Resurrection tracker"
L["mythicPlusBRTrackerLocked"] = "Lock the tracker's position"
L["mythicPlusBRButtonSizeHeadline"] = "Button Size"

-- Talent Reminder
L["TalentReminder"] = "Talent Reminder"
L["talentReminderEnabled"] = "Enable Talent Reminder"
L["talentReminderEnabledDesc"] = "Only checks in " .. _G["PLAYER_DIFFICULTY6"] .. " difficulty in preparation for " .. _G["PLAYER_DIFFICULTY_MYTHIC_PLUS"]
L["talentReminderLoadOnReadyCheck"] = "Only check talents on " .. _G["READY_CHECK"]
L["talentReminderSoundOnDifference"] = "Play a sound if talents differ from the saved setup"
L["WrongTalents"] = "Wrong Talents"
L["ActualTalents"] = "Current Talents"
L["RequiredTalents"] = "Required Talents"
L["DeletedLoadout"] = "Deleted Talent Loadout"
L["MissingTalentLoadout"] = "Some Talent Loadouts used by Talent Reminder\nhave been removed and can no longer be used:"

L["groupFilter"] = "Group Filter"
L["mythicPlusEnableDungeonFilter"] = "Extend the default Blizzard Dungeon Group Filter with new filters"
L["mythicPlusEnableDungeonFilterClearReset"] = "Clear the extended filters when the default Blizzard filter is reset"
L["filteredTextEntries"] = "Filtered\n%d Entries"
L["Partyfit"] = "Party fits"
L["BloodlustAvailable"] = "Bloodlust available"
L["BattleResAvailable"] = "Battle Res available"
