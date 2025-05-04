local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_MythicPlus")

local frameLoad = CreateFrame("Frame")
local hiddenElements = {}
local alreadyHooked = {}

function addon.MythicPlus.functions.setObjectiveFrames()
	if IsInInstance() and select(3, GetInstanceInfo()) == 8 and addon.db["mythicPlusEnableObjectiveTracker"] then
		for i, v in pairs(addon.MythicPlus.variables.collapseFrames) do
			if addon.db["mythicPlusObjectiveTrackerSetting"] == 1 and v.frame and v.frame:IsVisible() then
				v.frame:Hide()
				table.insert(hiddenElements, v)
				if not alreadyHooked[v.frame] then
					v.frame:HookScript("OnShow", function(self)
						if IsInInstance() and select(3, GetInstanceInfo()) == 8 and addon.db["mythicPlusEnableObjectiveTracker"] and addon.db["mythicPlusObjectiveTrackerSetting"] == 1 then
							self:Hide()
						end
					end)
					alreadyHooked[v.frame] = true
				end
			elseif addon.db["mythicPlusObjectiveTrackerSetting"] == 2 and v.frame and not v.frame:IsCollapsed() then
				if v.frame.Header and v.frame.Header.MinimizeButton then v.frame.Header.MinimizeButton:Click() end
			end
		end
	elseif #hiddenElements > 0 then
		for i, v in pairs(hiddenElements) do
			if v.frame and not v.frame:IsVisible() then v.frame:Show() end
			if v.frame:IsCollapsed() and v.frame.Header and v.frame.Header.MinimizeButton then v.frame.Header.MinimizeButton:Click() end
		end
		wipe(hiddenElements)
	end
end

local firstLoad = true
local eventHandlers = {
	["CHALLENGE_MODE_RESET"] = function() addon.MythicPlus.functions.setObjectiveFrames() end,
	["CHALLENGE_MODE_START"] = function() addon.MythicPlus.functions.setObjectiveFrames() end,
	["ZONE_CHANGED_NEW_AREA"] = function() addon.MythicPlus.functions.setObjectiveFrames() end,
	["PLAYER_ENTERING_WORLD"] = function()
		if firstLoad then
			firstLoad = false
			C_Timer.After(1, function()
				addon.MythicPlus.functions.setObjectiveFrames()
				frameLoad:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end)
		end
	end,
}

local function registerEvents(frame)
	for event in pairs(eventHandlers) do
		frame:RegisterEvent(event)
	end
end
local function eventHandler(self, event, ...)
	if addon.db["talentReminderEnabled"] then
		if eventHandlers[event] then eventHandlers[event](...) end
	end
end

registerEvents(frameLoad)
frameLoad:SetScript("OnEvent", eventHandler)
