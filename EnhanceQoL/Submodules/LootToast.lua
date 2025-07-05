-- luacheck: globals AlertFrame LootAlertSystem
local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local LootToast = addon.LootToast or {}
addon.LootToast = LootToast
LootToast.enabled = false
LootToast.frame = LootToast.frame or CreateFrame("Frame")

local function passesFilters(item)
	local quality = select(3, C_Item.GetItemInfo(item:GetItemLink()))
	local filter = addon.db.lootToastFilters and addon.db.lootToastFilters[quality]
	if not filter then return false end

	local has = filter.ilvl or filter.mounts or filter.pets
	if not has then return true end

	if filter.mounts and isMount(item) then return true end
	if filter.pets and isPet(item) then return true end

	if filter.ilvl and item:GetCurrentItemLevel() >= addon.db.lootToastItemLevel then return true end

	return false
end

local function isMount(item)
	local classID, subClassID = select(12, C_Item.GetItemInfo(item:GetItemLink()))
	return classID == 15 and subClassID == 5
end

local function isPet(item)
	local classID = select(12, C_Item.GetItemInfo(item:GetItemLink()))
	return classID == 17
end

local function shouldShowToast(item) return passesFilters(item) end

function LootToast:OnEvent(event, ...)
	if event == "SHOW_LOOT_TOAST" then
		local typeIdentifier, itemLink, quantity, specID, _, _, _, lessAwesome, isUpgraded, isCorrupted = ...
		if typeIdentifier ~= "item" then return end
		local item = Item:CreateFromItemLink(itemLink)
		if not item or item:IsItemEmpty() then return end
		item:ContinueOnItemLoad(function()
			if shouldShowToast(item) then LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded, isCorrupted) end
		end)
	elseif event == "LOOT_ITEM_SELF" or event == "LOOT_ITEM_PUSHED_SELF" then
		local itemLink, quantity = ...
		local item = Item:CreateFromItemLink(itemLink)
		if not item or item:IsItemEmpty() then return end
		item:ContinueOnItemLoad(function()
			if addon.db.lootToastIncludeIDs and addon.db.lootToastIncludeIDs[item:GetItemID()] then LootAlertSystem:AddAlert(itemLink, quantity) end
		end)
	end
end

local BLACKLISTED_EVENTS = {
	LOOT_ITEM_ROLL_WON = false,
	LOOT_ITEM_ROLL_SELF = false,
	LOOT_ITEM_ROLL_NEED = false,
	LOOT_ITEM_ROLL_GREED = false,
	LOOT_ITEM_ROLL_PASS = false,
	LOOT_ITEM_SELF = false,
	LOOT_ITEM_PUSHED_SELF = false,
	SHOW_LOOT_TOAST = true,
	SHOW_LOOT_TOAST_UPGRADE = false,
	SHOW_LOOT_TOAST_LEGENDARY = false,
}

function LootToast:Enable()
	if self.enabled then return end
	self.enabled = true
	self.frame:RegisterEvent("SHOW_LOOT_TOAST")
	self.frame:RegisterEvent("LOOT_ITEM_SELF")
	self.frame:RegisterEvent("LOOT_ITEM_PUSHED_SELF")
	self.frame:SetScript("OnEvent", function(...) self:OnEvent(...) end)
	-- disable default toast

	for event, state in pairs(BLACKLISTED_EVENTS) do
		if state and AlertFrame:IsEventRegistered(event) then AlertFrame:UnregisterEvent(event) end
	end
	hooksecurefunc(AlertFrame, "RegisterEvent", function(self, event)
		if BLACKLISTED_EVENTS[event] then xpcall(self.UnregisterEvent, self, event) end
	end)
end

function LootToast:Disable()
	if not self.enabled then return end
	self.enabled = false
	self.frame:UnregisterEvent("SHOW_LOOT_TOAST")
	self.frame:UnregisterEvent("LOOT_ITEM_SELF")
	self.frame:UnregisterEvent("LOOT_ITEM_PUSHED_SELF")
	self.frame:SetScript("OnEvent", nil)
	AlertFrame:RegisterEvent("SHOW_LOOT_TOAST")
end
