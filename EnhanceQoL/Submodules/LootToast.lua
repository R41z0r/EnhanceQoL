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

local function passesRarity(item)
	if not addon.db.lootToastCheckRarity then return true end
	local quality = select(3, C_Item.GetItemInfo(item:GetItemLink()))
	return addon.db.lootToastRarities and addon.db.lootToastRarities[quality]
end

local function isMount(item)
	local classID, subClassID = select(12, C_Item.GetItemInfo(item:GetItemLink()))
	return classID == 15 and subClassID == 5
end

local function isPet(item)
	local classID = select(12, C_Item.GetItemInfo(item:GetItemLink()))
	return classID == 17
end

local function shouldShowToast(item)
	if addon.db.lootToastIncludeLegendaries then
		local quality = select(3, C_Item.GetItemInfo(item:GetItemLink()))
		if quality == Enum.ItemQuality.Legendary then return true end
	end

	if addon.db.lootToastIncludeMounts and isMount(item) then return passesRarity(item) end
	if addon.db.lootToastIncludePets and isPet(item) then return passesRarity(item) end

	if addon.db.lootToastCheckIlvl and item:GetCurrentItemLevel() >= addon.db.lootToastItemLevel then return true end

	if addon.db.lootToastCheckRarity and passesRarity(item) then return true end

	return false
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

function LootToast:Enable()
	if self.enabled then return end
	self.enabled = true
	self.frame:RegisterEvent("SHOW_LOOT_TOAST")
	self.frame:SetScript("OnEvent", function(...) self:OnEvent(...) end)
	-- disable default toast
	if AlertFrame:IsEventRegistered("SHOW_LOOT_TOAST") then AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST") end
end

function LootToast:Disable()
	if not self.enabled then return end
	self.enabled = false
	self.frame:UnregisterEvent("SHOW_LOOT_TOAST")
	self.frame:SetScript("OnEvent", nil)
	AlertFrame:RegisterEvent("SHOW_LOOT_TOAST")
end
