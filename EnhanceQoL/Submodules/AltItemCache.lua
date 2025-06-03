local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local AceGUI = addon.AceGUI
local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL")

addon.AltItemCache = addon.AltItemCache or {}
local AIC = addon.AltItemCache

------------------------------------------------------------
-- SavedVariables
------------------------------------------------------------
EnhanceQoL_ItemDB = EnhanceQoL_ItemDB or {}

------------------------------------------------------------
-- Utility functions
------------------------------------------------------------
local function LinkKey(itemLink)
	if not itemLink then return nil end
	return itemLink:match("|H(item:[^|]+)|h")
end

local function CacheItem(link)
	local key = LinkKey(link)
	if not key or EnhanceQoL_ItemDB[key] then return key end
	local itm = Item:CreateFromItemLink(link)
	itm:ContinueOnItemLoad(function()
		local itemID = itm:GetItemID()
		local ilvl = itm:GetCurrentItemLevel()
		local quality = itm:GetItemQuality()
		local equipLoc = select(9, GetItemInfo(link))
		local classID, subClassID = select(12, GetItemInfo(link))
		local stats = GetItemStats(link)
		local hasSockets = false
		if stats then
			for k in pairs(stats) do
				if k:find("SOCKET", 1, true) then
					hasSockets = true
					break
				end
			end
		end

		EnhanceQoL_ItemDB[key] = {
			link = link,
			itemID = itemID,
			ilvl = ilvl,
			quality = quality,
			equipLoc = equipLoc,
			classID = classID,
			subClassID = subClassID,
			socketed = hasSockets,
		}
	end)
	return key
end

local function ensureChar()
	EnhanceQoL_ItemCache = EnhanceQoL_ItemCache or {}
	local guid = UnitGUID("player")
	if not EnhanceQoL_ItemCache[guid] then
		EnhanceQoL_ItemCache[guid] = {
			name = UnitName("player"),
			realm = GetRealmName(),
			class = select(2, UnitClass("player")),
			items = {},
			itemsByID = {},
			index = { name = {}, id = {}, type = {} },
		}
	end
	return EnhanceQoL_ItemCache[guid]
end

local function addItem(char, link, count)
	local key = CacheItem(link)
	if not key then return end
	char.items[key] = (char.items[key] or 0) + (count or 1)
	local meta = EnhanceQoL_ItemDB[key]
	if not meta then return end
	local itemID = meta.itemID
	if itemID then char.itemsByID[itemID] = (char.itemsByID[itemID] or 0) + (count or 1) end
	local name = GetItemInfo(link)
	local itemType = select(6, GetItemInfo(link))
	if name then
		local nkey = strlower(name)
		char.index.name[nkey] = char.index.name[nkey] or {}
		char.index.name[nkey][key] = true
	end
	if itemID then
		char.index.id[itemID] = char.index.id[itemID] or {}
		char.index.id[itemID][key] = true
	end
	if itemType then
		char.index.type[itemType] = char.index.type[itemType] or {}
		char.index.type[itemType][key] = true
	end
end

local function scanBags(includeBank)
	if not addon.db["enableAltItemTracker"] then return end
	local char = ensureChar()
	wipe(char.items)
	wipe(char.itemsByID)
	char.index = { name = {}, id = {}, type = {} }
	for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.hyperlink then addItem(char, info.hyperlink, info.stackCount) end
		end
	end
	if includeBank then
		for slot = 1, NUM_BANKGENERIC_SLOTS do
			local info = C_Container.GetContainerItemInfo(-1, slot)
			if info and info.hyperlink then addItem(char, info.hyperlink, info.stackCount) end
		end
		for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			for slot = 1, C_Container.GetContainerNumSlots(bag) do
				local info = C_Container.GetContainerItemInfo(bag, slot)
				if info and info.hyperlink then addItem(char, info.hyperlink, info.stackCount) end
			end
		end
		if IsReagentBankUnlocked() then
			for slot = 1, C_Container.GetContainerNumSlots(REAGENTBANK_CONTAINER) do
				local info = C_Container.GetContainerItemInfo(REAGENTBANK_CONTAINER, slot)
				if info and info.hyperlink then addItem(char, info.hyperlink, info.stackCount) end
			end
		end
	end
	char.name = UnitName("player")
	char.realm = GetRealmName()
	char.class = select(2, UnitClass("player"))
end

local eventFrame = CreateFrame("Frame")
AIC.eventFrame = eventFrame

local bankOpen = false

eventFrame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		scanBags(false)
	elseif event == "BAG_UPDATE_DELAYED" then
		scanBags(bankOpen)
	elseif event == "BANKFRAME_OPENED" then
		bankOpen = true
		scanBags(true)
	elseif event == "BANKFRAME_CLOSED" then
		bankOpen = false
	elseif event == "PLAYERBANKSLOTS_CHANGED" and bankOpen then
		scanBags(true)
	end
end)

for _, ev in ipairs({ "PLAYER_LOGIN", "BAG_UPDATE_DELAYED", "BANKFRAME_OPENED", "BANKFRAME_CLOSED", "PLAYERBANKSLOTS_CHANGED" }) do
	eventFrame:RegisterEvent(ev)
end

function AIC:ToggleWindow()
	if self.window and self.window.frame:IsShown() then
		self.window:Hide()
	else
		self:CreateWindow()
	end
end

function AIC:CreateWindow()
	if self.window then
		self.window:Show()
		return
	end
	local frame = AceGUI:Create("Window")
	frame:SetTitle(L["AltItemSearch"] or "Alt Item Search")
	frame:SetWidth(500)
	frame:SetHeight(400)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget) widget.frame:Hide() end)

	local edit = AceGUI:Create("EditBox")
	edit:SetLabel(L["Search"] or SEARCH)
	edit:SetFullWidth(true)
	frame:AddChild(edit)

	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	frame:AddChild(scroll)

	edit:SetCallback("OnTextChanged", function(_, _, txt) AIC:UpdateResults(txt) end)

	self.window = frame
	self.editBox = edit
	self.scroll = scroll

	self:UpdateResults("")
end

local function matchesQuery(key, count, query)
	local meta = EnhanceQoL_ItemDB[key]
	local name = meta and GetItemInfo(meta.link)
	local id = meta and meta.itemID
	local itemType = meta and select(6, GetItemInfo(meta.link))
	query = query and strlower(query) or ""
	if query == "" then return true end
	if name and strlower(name):find(query, 1, true) then return true end
	if id and tostring(id) == query then return true end
	if itemType and strlower(itemType):find(query, 1, true) then return true end
	return false
end

function AIC:UpdateResults(query)
	local scroll = self.scroll
	if not scroll then return end
	scroll:ReleaseChildren()
	query = query or ""
	for _, char in pairs(EnhanceQoL_ItemCache or {}) do
		local items = {}
		for key, count in pairs(char.items or {}) do
			if matchesQuery(key, count, query) then table.insert(items, { key = key, count = count }) end
		end
		if #items > 0 then
			table.sort(items, function(a, b)
				local na = (EnhanceQoL_ItemDB[a.key] and GetItemInfo(EnhanceQoL_ItemDB[a.key].link)) or ""
				local nb = (EnhanceQoL_ItemDB[b.key] and GetItemInfo(EnhanceQoL_ItemDB[b.key].link)) or ""
				return na < nb
			end)
			local heading = AceGUI:Create("Heading")
			local displayName = char.name
			if char.realm ~= GetRealmName() then displayName = displayName .. "-" .. char.realm end
			heading:SetText(displayName)
			heading:SetFullWidth(true)
			scroll:AddChild(heading)
			local group = AceGUI:Create("SimpleGroup")
			group:SetLayout("Flow")
			group:SetFullWidth(true)
			scroll:AddChild(group)
			for _, info in ipairs(items) do
				local meta = EnhanceQoL_ItemDB[info.key]
				if meta then
					local icon = AceGUI:Create("Icon")
					icon:SetImage(select(10, GetItemInfo(meta.link)) or "")
					icon:SetImageSize(32, 32)
					local itemName = GetItemInfo(meta.link) or "?"
					icon:SetLabel(string.format("%s x%d", itemName, info.count))
					icon:SetRelativeWidth(0.15)
					icon:SetCallback("OnEnter", function()
						GameTooltip:SetOwner(icon.frame, "ANCHOR_RIGHT")
						GameTooltip:SetHyperlink(meta.link)
						GameTooltip:Show()
					end)
					icon:SetCallback("OnLeave", function() GameTooltip:Hide() end)
					group:AddChild(icon)
				end
			end
		end
	end
end

SLASH_EQOLALTITEMS1 = "/eqolitems"
SlashCmdList["EQOLALTITEMS"] = function() AIC:ToggleWindow() end
