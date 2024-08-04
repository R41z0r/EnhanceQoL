local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

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