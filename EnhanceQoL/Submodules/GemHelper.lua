local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL")

local GEM_TYPE_INFO = {}
GEM_TYPE_INFO["Yellow"] = 9
GEM_TYPE_INFO["Red"] = 9
GEM_TYPE_INFO["Blue"] = 9
GEM_TYPE_INFO["Hydraulic"] = 9
GEM_TYPE_INFO["Cogwheel"] = 9
GEM_TYPE_INFO["Meta"] = 9
GEM_TYPE_INFO["Prismatic"] = 10
GEM_TYPE_INFO["SingingThunder"] = 9
GEM_TYPE_INFO["SingingWind"] = 9
GEM_TYPE_INFO["SingingSea"] = 9

local frame = CreateFrame("Frame")

local gemButtons = {}
-- helper to refresh / clear buttons
local function clearGemButtons()
	if not gemButtons then return end
	for _, btn in ipairs(gemButtons) do
		btn:ClearAllPoints()
		btn:Hide()
	end
	wipe(gemButtons)
end

local function createGemHelper()
	if EnhanceQoLGemHelper then return end
	-- backdrop anchor so we get the nice border you already had
	local frameAnchor = CreateFrame("Frame", "EnhanceQoLGemHelper", ItemSocketingFrame, "BackdropTemplate")
	frameAnchor:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frameAnchor:SetBackdropColor(0, 0, 0, 0.8)
	frameAnchor:SetPoint("TOPLEFT", ItemSocketingFrame, "BOTTOMLEFT", 0, -2)
	local width, height = ItemSocketingFrame:GetSize()
	frameAnchor:SetSize(width, 100)
end

local function createButton(parent, itemTexture, itemLink, bag, slot, locked)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(32, 32) -- position will be applied later in layoutButtons()

	-- Hintergrund
	local bg = button:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(button)
	bg:SetColorTexture(0, 0, 0, 0.8)

	-- Icon
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(button)
	icon:SetTexture(itemTexture)
	button.icon = icon

	button:RegisterForClicks("AnyUp", "AnyDown")

	if locked then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.5)
		button:EnableMouse(false)
	else
		icon:SetDesaturated(false)
		icon:SetAlpha(1)
		button:EnableMouse(true)
	end
	-- Tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(itemLink)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	button:SetScript("OnClick", function(self)
		ClearCursor()
		C_Container.PickupContainerItem(bag, slot)

		icon:SetDesaturated(true)
		icon:SetAlpha(0.5)
		button:EnableMouse(false)
	end)

	return button
end

local function layoutButtons()
	if not EnhanceQoLGemHelper then return end
	local PAD = 4 -- spacing between icons
	local BW, BH = 32, 32 -- button width / height
	local maxW = (EnhanceQoLGemHelper:GetWidth() or 220) - PAD

	local x, y = PAD, -PAD -- start offsets (negative y for TOPLEFT anchoring)

	table.sort(gemButtons, function(a, b) return a.itemName < b.itemName end)
	local usedRows = 1
	for _, btn in ipairs(gemButtons) do
		btn:ClearAllPoints()

		-- new row if the next button would overflow
		if x + BW > maxW then
			x = PAD
			y = y - BH - PAD
			usedRows = usedRows + 1
		end

		btn:SetPoint("TOPLEFT", EnhanceQoLGemHelper, "TOPLEFT", x, y)
		btn:Show()

		x = x + BW + PAD
	end

	local neededHeight = usedRows * (BH + PAD) + PAD
	if neededHeight > EnhanceQoLGemHelper:GetHeight() then EnhanceQoLGemHelper:SetHeight(neededHeight) end
end

local function checkGems()
	clearGemButtons()

	local aSockets = {}
	local numSockets = GetNumSockets()
	for i = 1, numSockets do
		local gemColor = GetSocketTypes(i)
		if GEM_TYPE_INFO[gemColor] then aSockets[GEM_TYPE_INFO[gemColor]] = true end
	end

	for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
			if containerInfo then
				local eItem = Item:CreateFromBagAndSlot(bag, slot)
				if eItem and not eItem:IsItemEmpty() then
					eItem:ContinueOnItemLoad(function()
						local itemLink = eItem:GetItemLink()
						if not itemLink then return end
						local itemID = eItem:GetItemID()
						local itemName, _, _, _, _, _, _, _, _, icon, _, classID, subClassID = C_Item.GetItemInfo(itemID)
						if classID ~= 3 then return end

						if nil == aSockets[subClassID] then return end

						local locked = false
						if C_Item.IsLocked(eItem:GetItemLocation()) then locked = true end

						local btn = createButton(EnhanceQoLGemHelper, icon, itemLink, bag, slot, locked)
						btn.itemName = itemName
						tinsert(gemButtons, btn)
					end)
				end
			end
		end
	end
	layoutButtons()
end

local function eventHandler(self, event, unit, arg1, arg2, ...)
	if addon.db["enableGemHelper"] then
		if event == "SOCKET_INFO_UPDATE" then
			if ItemSocketingFrame then
				createGemHelper()
				checkGems()
			end
		elseif event == "CURSOR_CHANGED" then
			if ItemSocketingFrame and ItemSocketingFrame:IsShown() and arg2 == 1 then checkGems() end
		end
	end
end

frame:RegisterEvent("SOCKET_INFO_UPDATE")
frame:RegisterEvent("CURSOR_CHANGED")
frame:SetScript("OnEvent", eventHandler)
frame:Hide()
