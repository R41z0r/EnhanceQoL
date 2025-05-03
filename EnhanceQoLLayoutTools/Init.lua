local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.LayoutTools = {}
addon.LLayoutTools = {} -- Locales for MythicPlus
addon.LayoutTools.functions = {}

addon.LayoutTools.variables = {}

addon.functions.InitDBValue("eqolLayoutTools", {})

function addon.LayoutTools.functions.InitDBValue(key, defaultValue)
	if addon.db["eqolLayoutTools"][key] == nil then addon.db["eqolLayoutTools"][key] = defaultValue end
end
addon.LayoutTools.functions.InitDBValue("uiScalerTalentFrameEnabled", false)
addon.LayoutTools.functions.InitDBValue("uiScalerSpecFrameEnabled", false)
addon.LayoutTools.functions.InitDBValue("uiScalerSpellFrameEnabled", false)
addon.LayoutTools.functions.InitDBValue("uiScalerTalentFrame", 1)
addon.LayoutTools.functions.InitDBValue("uiScalerSpecFrame", 1)
addon.LayoutTools.functions.InitDBValue("uiScalerSpellFrame", 1)
local db = addon.db["eqolLayoutTools"]

function addon.LayoutTools.functions.createHooks(frame, dbVar)
	if frame then
		if db[dbVar] == nil then db[dbVar] = {} end

		if db[dbVar] then
			frame:SetMovable(true)
			frame:RegisterForDrag("LeftButton")
			frame:SetScript("OnDragStart", frame.StartMoving)
			frame:SetScript("OnDragStop", function(self)
				if InCombatLockdown() and self:IsProtected() then return end
				self:StopMovingOrSizing()
				local point, _, _, xOfs, yOfs = self:GetPoint()
				db[dbVar].point = point
				db[dbVar].x = xOfs
				db[dbVar].y = yOfs
			end)
		end

		hooksecurefunc(frame, "SetPoint", function(self)
			if not db["uiScaler" .. frame:GetName() .. "Enabled"] then return end
			if InCombatLockdown() and self:IsProtected() then return end
			if self.isRunningPoint then return end
			self.isRunningPoint = true
			if db[dbVar].point and db[dbVar].x and db[dbVar].y then
				self:ClearAllPoints()
				self:SetPoint(db[dbVar].point, UIParent, db[dbVar].point, db[dbVar].x, db[dbVar].y)
			end
			self.isRunningPoint = nil
		end)
		hooksecurefunc(frame, "SetScale", function(self)
			if not db["uiScaler" .. frame:GetName() .. "Enabled"] then return end
			if InCombatLockdown() and self:IsProtected() then return end
			if self.isRunningScale then return end
			self.isRunningScale = true
			if db["uiScaler" .. frame:GetName() .. "Enabled"] and db["uiScaler" .. frame:GetName() .. "Frame"] then frame:SetScale(db["uiScaler" .. frame:GetName() .. "Frame"]) end
			self.isRunningScale = nil
		end)
	end
end

addon.LayoutTools.variables.knownFrames = {
	CharacterFrame,
}
