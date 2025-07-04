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

local function shouldShowToast(item)
	local show = false
	if addon.db.lootToastCheckIlvl and item:GetCurrentItemLevel() >= addon.db.lootToastItemLevel then show = true end
	if not show and addon.db.lootToastCheckRarity then
		local quality = select(3, C_Item.GetItemInfo(item:GetItemLink()))
		if addon.db.lootToastRarities and addon.db.lootToastRarities[quality] then show = true end
	end
	if not show and addon.db.lootToastIncludeMounts then
		local classID, subClassID = select(12, C_Item.GetItemInfo(item:GetItemLink()))
		if classID == 15 and subClassID == 5 then show = true end
	end
	if not show and addon.db.lootToastIncludePets then
		local classID = select(12, C_Item.GetItemInfo(item:GetItemLink()))
		if classID == 17 then show = true end
	end
	if not show and addon.db.lootToastIncludeLegendaries then
		local quality = select(3, C_Item.GetItemInfo(item:GetItemLink()))
		if quality == Enum.ItemQuality.Legendary then show = true end
	end
	return show
end

function LootToast:OnEvent(_, _, ...)
	local typeIdentifier, itemLink, quantity, specID, _, _, _, lessAwesome, isUpgraded, isCorrupted = ...
	if typeIdentifier ~= "item" then return end
	local item = Item:CreateFromItemLink(itemLink)
	if not item or item:IsItemEmpty() then return end
	item:ContinueOnItemLoad(function()
		if shouldShowToast(item) then LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded, isCorrupted) end
	end)
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
	self.frame:SetScript("OnEvent", nil)
	AlertFrame:RegisterEvent("SHOW_LOOT_TOAST")
end
