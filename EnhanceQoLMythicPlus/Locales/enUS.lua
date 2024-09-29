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
L["potionTrackerHeadline"] =
    "This enables you to track the CD of the\ncombat potions of your party members as a moveable bar"
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
L["groupfinderAppText"] = "Hide the group finder text \"Your group is currently forming\""
L["groupfinderSkipRolecheck"] = "Skip Role Check and use current role"