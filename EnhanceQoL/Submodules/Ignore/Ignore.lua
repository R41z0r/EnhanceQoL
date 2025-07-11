local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.L

-- luacheck: globals EQOLIgnoreFrame EQOLIgnoreFrame_OnLoad HybridScrollFrame_CreateButtons DeclineGuildInvite
local AceGUI = addon.AceGUI
local Ignore = addon.Ignore or {}
addon.Ignore = Ignore

local function ensureFriendsFrame()
	if not addon.db or not (addon.db.ignoreAnchorFriendsFrame or addon.db.ignoreAttachFriendsFrame) then return end
	if not FriendsFrame then
		local loaded = false
		if C_AddOns and C_AddOns.LoadAddOn then
			loaded = C_AddOns.LoadAddOn("Blizzard_FriendsFrame")
		elseif LoadAddOn then
			loaded = LoadAddOn("Blizzard_FriendsFrame")
		end
		if not loaded then return end
	end
	if FriendsFrame and not Ignore.friendsHookInstalled then
		FriendsFrame:HookScript("OnShow", function()
			if addon.db.ignoreAttachFriendsFrame and Ignore.enabled then
				EQOLIgnoreFrame:Show()
				Ignore:UpdateAnchor()
			end
		end)
		FriendsFrame:HookScript("OnHide", function()
			if addon.db.ignoreAttachFriendsFrame then EQOLIgnoreFrame:Hide() end
		end)
		Ignore.friendsHookInstalled = true
	end
end

function Ignore:SavePosition()
	if not self.frame or not addon or not addon.db then return end
	if addon.db.ignoreAnchorFriendsFrame then return end
	local point, _, _, xOfs, yOfs = self.frame:GetPoint()
	addon.db.ignoreFramePoint = point
	addon.db.ignoreFrameX = xOfs
	addon.db.ignoreFrameY = yOfs
end
-- will be replaced with the saved table once the addon is fully loaded
Ignore.entries = Ignore.entries or {}
Ignore.entryLookup = Ignore.entryLookup or {}
Ignore.selectedIndex = nil
Ignore.searchText = Ignore.searchText or ""
Ignore.addFrame = Ignore.addFrame or nil

Ignore.enabled = Ignore.enabled or false
Ignore.registeredFilters = Ignore.registeredFilters or {}
Ignore.hooksInstalled = Ignore.hooksInstalled or false
Ignore.friendsHookInstalled = Ignore.friendsHookInstalled or false

-- load the saved ignore database when the addon has fully loaded
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, event, arg1)
	if arg1 == parentAddonName then
		EnhanceQoL_IgnoreDB = EnhanceQoL_IgnoreDB or {}
		Ignore.entries = EnhanceQoL_IgnoreDB
		Ignore:RebuildLookup()
		if addon and addon.db and addon.db.enableIgnore ~= nil then Ignore:SetEnabled(addon.db.enableIgnore) end
		loader:UnregisterEvent("ADDON_LOADED")
	end
end)

local LOGIN_FRAME = CreateFrame("Frame")
local CHAT_EVENTS = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
}
local INTERACTION_EVENTS = {
	"PARTY_INVITE_REQUEST",
	"DUEL_REQUESTED",
	"PET_BATTLE_PVP_DUEL_REQUESTED",
	"TRADE_SHOW",
	"GUILD_INVITE_REQUEST",
}

Ignore.filtered = {}

function Ignore:NormalizeName(name)
	if not name or name == "" then return nil end
	local player, server = strsplit("-", name)
	player = player or name
	server = server or (GetRealmName()):gsub("%s", "")
	return player:lower() .. "-" .. server:lower()
end

function Ignore:RebuildLookup()
	wipe(self.entryLookup)
	for _, entry in ipairs(self.entries) do
		local key = self:NormalizeName(entry.player .. "-" .. entry.server)
		if key then self.entryLookup[key] = entry end
	end
end

local IsIgnored = IsIgnored or C_FriendList.IsIgnored

function Ignore:CheckIgnore(name)
	local key = self:NormalizeName(name)
	if not key then return nil end
	return self.entryLookup[key]
end

function Ignore:IsPlayerIgnored(name)
	if not name or name == "" then return false end
	if self:CheckIgnore(name) then return true end
	local player, server = strsplit("-", name)
	if IsIgnored then
		if IsIgnored(name) then return true end
		if server == (GetRealmName()):gsub("%s", "") and IsIgnored(player) then return true end
	end
	return false
end

function Ignore.daysFromToday(dateStr)
	if not dateStr then return 0 end
	local y, m, d = dateStr:match("(%d+)%-(%d+)%-(%d+)")
	if not y then return 0 end
	local t = time({ year = y, month = m, day = d, hour = 0 })
	return math.floor((time() - t) / 86400)
end

function Ignore:GetExpireText(entry)
	if not entry or not entry.expires or entry.expires == NEVER then return NEVER end
	local exp = tonumber(entry.expires)
	if not exp then return tostring(entry.expires) end
	local left = exp - self.daysFromToday(entry.date)
	if left <= 0 then return "TODAY" end
	return left .. "d"
end

function Ignore:Expire()
	local removed = false
	local me, realm = UnitFullName("player")
	realm = realm or (GetRealmName()):gsub("%s", "")
	local selfKey = self:NormalizeName(me .. "-" .. realm)
	for i = #self.entries, 1, -1 do
		local e = self.entries[i]
		local key = self:NormalizeName(e.player .. "-" .. e.server)
		if key == selfKey then
			table.remove(self.entries, i)
			self.entryLookup[key] = nil
			removed = true
		else
			local exp = tonumber(e.expires)
			if exp and exp > 0 and self.daysFromToday(e.date) >= exp then
				local name = e.player
				if e.server and e.server ~= "" then name = name .. "-" .. e.server end
				if self.origDelIgnore and IsIgnored and IsIgnored(name) then self.origDelIgnore(name) end
				table.remove(self.entries, i)
				self.entryLookup[key] = nil
				print(L["IgnoreExpiredRemoved"]:format(name))
				removed = true
			end
		end
	end
	if removed then self:RebuildLookup() end
end

local ROW_HEIGHT = 20

local widths = { 130, 150, 60, 60, 210 }
local titles = {
	L["IgnorePlayer"],
	L["IgnoreServer"],
	L["IgnoreListed"],
	L["IgnoreExpires"],
	L["IgnoreNote"],
}
local DOUBLE_CLICK_TIME = 0.5

Ignore.currentSort = "player"
Ignore.sortAsc = true

local NUM_ROWS = 14
Ignore.rows = {}

local IgnoreRowTemplate = {}

function IgnoreRowTemplate:OnAcquired()
	if not self.initialized then
		self.bg = self:CreateTexture(nil, "BACKGROUND")
		self.bg:SetAllPoints(self)
		self.bg:SetColorTexture(0, 0, 0, 0)

		self.cols = {}
		local x = 0
		for i, width in ipairs(widths) do
			local fs = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			fs:SetPoint("LEFT", x, 0)
			fs:SetWidth(width)
			fs:SetJustifyH("LEFT")
			self.cols[i] = fs
			x = x + width
		end

		self:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight")
		self:RegisterForClicks("LeftButtonUp")
		self.initialized = true
	end
	self:SetHeight(ROW_HEIGHT)
end

function IgnoreRowTemplate:Init(elementData)
	self.index = elementData.index
	self.cols[1]:SetText(elementData.player or "")
	self.cols[2]:SetText(elementData.server or "")
	self.cols[3]:SetText(elementData.listed or "")
	self.cols[4]:SetText(elementData.expire or "")
	do
		local noteText = elementData.note or ""
		local maxLen = 30
		if #noteText > maxLen then noteText = noteText:sub(1, maxLen - 3) .. "..." end
		self.cols[5]:SetText(noteText)
	end

	if self.index == Ignore.selectedIndex then
		self.bg:SetColorTexture(1, 1, 0, 0.3)
	else
		self.bg:SetColorTexture(0, 0, 0, 0)
	end
end

function IgnoreRowTemplate:OnClick()
	Ignore.selectedIndex = self.index
	for _, frame in ipairs(Ignore.rows) do
		if frame.bg then
			if frame.index == Ignore.selectedIndex then
				frame.bg:SetColorTexture(1, 1, 0, 0.3)
			else
				frame.bg:SetColorTexture(0, 0, 0, 0)
			end
		end
	end

	local now = GetTime()
	if self.lastClick and (now - self.lastClick) < DOUBLE_CLICK_TIME then
		local entry = Ignore.filtered[self.index]
		if entry then
			local fullName = entry.player
			if entry.server and entry.server ~= "" then fullName = fullName .. "-" .. entry.server end
			Ignore:ShowAddFrame(fullName, entry.note, entry.expires)
		end
	end
	self.lastClick = now
end

local removeEntry
local removeEntryByIndex

local function FilterEntries()
	wipe(Ignore.filtered)

	local search = Ignore.searchText and Ignore.searchText:lower() or ""
	local filtering = search ~= ""

	for _, data in ipairs(Ignore.entries) do
		if
			not filtering
			or (data.player and data.player:lower():find(search, 1, true))
			or (data.server and data.server:lower():find(search, 1, true))
			or (data.note and data.note:lower():find(search, 1, true))
		then
			table.insert(Ignore.filtered, data)
		end
	end
end

local function SortFiltered()
	if not Ignore.currentSort then return end
	local key = Ignore.currentSort
	table.sort(Ignore.filtered, function(a, b)
		local av, bv
		if key == "listed" then
			av = Ignore.daysFromToday(a.date or "")
			bv = Ignore.daysFromToday(b.date or "")
		elseif key == "expire" then
			av = Ignore:GetExpireText(a)
			bv = Ignore:GetExpireText(b)
		else
			av = tostring(a[key] or "")
			bv = tostring(b[key] or "")
		end
		if Ignore.sortAsc then
			return av < bv
		else
			return av > bv
		end
	end)
end

local function RefreshList()
	Ignore:Expire()
	FilterEntries()
	SortFiltered()
	if Ignore.counter then Ignore.counter:SetText(format(L["IgnoreEntries"], #Ignore.filtered)) end
	if Ignore.scrollFrame then
		HybridScrollFrame_Update(Ignore.scrollFrame, #Ignore.filtered * ROW_HEIGHT, NUM_ROWS * ROW_HEIGHT)
		Ignore:UpdateRows()
	end
end

function Ignore:UpdateRows()
	if not self.scrollFrame then return end
	local offset = HybridScrollFrame_GetOffset(self.scrollFrame)
	for i, row in ipairs(self.rows) do
		local idx = i + offset
		local e = self.filtered[idx]
		if e then
			row:Init({
				index = idx,
				player = e.player,
				server = e.server,
				listed = e.date and (self.daysFromToday(e.date) .. "d") or "",
				expire = self:GetExpireText(e),
				note = e.note,
			})
			row:Show()
		else
			row:Hide()
		end
	end
end

-- Frame created from XML
function EQOLIgnoreFrame_OnLoad(frame)
	Ignore.frame = frame
	frame:SetFrameStrata("DIALOG")
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, -6)
	frame.title:SetText(L["IgnoreWindowTitle"])
	local fn = frame:GetName()
	Ignore.counter = _G[fn .. "Counter"]
	Ignore.searchBox = _G[fn .. "SearchBox"]
	frame.searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.searchLabel:SetPoint("RIGHT", Ignore.searchBox, "LEFT", -5, 0)
	frame.searchLabel:SetText(SEARCH .. ":")
	Ignore.header = _G[fn .. "Header"]
	Ignore.scrollFrame = _G[fn .. "ScrollFrame"]
	-- Ensure scrollFrame.scrollBar references the XML-declared slider
	Ignore.scrollFrame.scrollBar = _G[fn .. "ScrollFrameScrollBar"]
	Ignore.removeBtn = _G[fn .. "RemoveButton"]
	Ignore.removeBtn:SetText(REMOVE)

	local listWidth = 0
	for _, w in ipairs(widths) do
		listWidth = listWidth + w
	end

	local x = 0
	local c = 1
	for idx, col in ipairs({
		{ text = L["IgnorePlayer"], width = widths[1], key = "player" },
		{ text = L["IgnoreServer"], width = widths[2], key = "server" },
		{ text = L["IgnoreListed"], width = widths[3], key = "listed" },
		{ text = L["IgnoreExpires"], width = widths[4], key = "expire" },
		{ text = L["IgnoreNote"], width = widths[5], key = "note" },
	}) do
		local colH = _G[fn .. "HeaderCol" .. c]
		if colH then
			colH:SetWidth(col.width)
			_G[fn .. "HeaderCol" .. c .. "Middle"]:SetWidth(col.width - 9)
			colH:SetText(col.text)
			colH.sortKey = col.key
			colH:SetScript("OnClick", function(self)
				Ignore.sortAsc = (Ignore.currentSort ~= self.sortKey) and true or not Ignore.sortAsc
				Ignore.currentSort = self.sortKey
				SortFiltered()
				Ignore:UpdateRows()
			end)
		end
		c = c + 1
	end

	-- Create buttons and retrieve them from the scrollFrame.buttons table
	HybridScrollFrame_CreateButtons(Ignore.scrollFrame, "EQOLIgnoreRowTemplate", 5, -2)
	local rows = Ignore.scrollFrame.buttons or {}
	Ignore.rows = rows

	-- Initialize each button via our template mixin
	for _, row in ipairs(rows) do
		Mixin(row, IgnoreRowTemplate)
		row:OnAcquired()
	end
	Ignore.scrollFrame.update = function() Ignore:UpdateRows() end

	Ignore.searchBox:SetScript("OnTextChanged", function(self)
		Ignore.searchText = self:GetText() or ""
		Ignore.selectedIndex = nil
		RefreshList()
	end)

	Ignore.removeBtn:SetScript("OnClick", function()
		local entry = Ignore.filtered[Ignore.selectedIndex]
		if entry then
			local name = entry.player
			if entry.server and entry.server ~= "" then name = name .. "-" .. entry.server end
			removeEntry(name)
		end
		Ignore.selectedIndex = nil
		RefreshList()
	end)

	RefreshList()

	frame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
		Ignore:SavePosition()
	end)
	frame:SetScript("OnHide", function() Ignore:SavePosition() end)

	ensureFriendsFrame()
	Ignore:UpdateAnchor()
end

function Ignore:Toggle()
	ensureFriendsFrame()
	Ignore:UpdateAnchor()
	if EQOLIgnoreFrame:IsShown() then
		EQOLIgnoreFrame:Hide()
	else
		EQOLIgnoreFrame:Show()
	end
end

Ignore.origAddIgnore = Ignore.origAddIgnore or (C_FriendList and C_FriendList.AddIgnore)
Ignore.origDelIgnoreByIndex = Ignore.origDelIgnoreByIndex or (C_FriendList and C_FriendList.DelIgnoreByIndex)
Ignore.origDelIgnore = Ignore.origDelIgnore or (C_FriendList and C_FriendList.DelIgnore)
Ignore.origAddOrDelIgnore = Ignore.origAddOrDelIgnore or (C_FriendList and C_FriendList.AddOrDelIgnore)

function Ignore:HasFreeSlot()
	local num = 0
	if C_FriendList and C_FriendList.GetNumIgnores then
		num = C_FriendList.GetNumIgnores()
	elseif GetNumIgnores then
		num = GetNumIgnores()
	end
	if MAX_IGNORE then return num < MAX_IGNORE end
	return true
end

local function addEntry(name, note, expires)
	local player, server = strsplit("-", name)
	local myServer = (GetRealmName()):gsub("%s", "")
	local sameRealm = not server or server == myServer
	player = player or name
	server = server or myServer
	local myName, myRealm = UnitFullName("player")
	myRealm = myRealm or myServer
	if player:lower() == (myName and myName:lower() or "") and server:lower() == myRealm:lower() then return end
	local key = Ignore:NormalizeName(player .. "-" .. server)
	local entry = Ignore.entryLookup[key]
	if entry then
		if note ~= nil then entry.note = note end
		if expires ~= nil then entry.expires = expires > 0 and expires or NEVER end
		RefreshList()
		return
	end
	--if Ignore.origAddIgnore and sameRealm and Ignore:HasFreeSlot() then Ignore.origAddIgnore(name) end
	local newEntry = {
		player = player,
		server = server,
		date = date("%Y-%m-%d"),
		expires = expires > 0 and expires or NEVER,
		note = note or "",
	}
	table.insert(Ignore.entries, newEntry)
	Ignore.entryLookup[key] = newEntry
	print(L["IgnoreAdded"]:format(name))
	RefreshList()
end

removeEntryByIndex = function(index)
	local entry = Ignore.entries[index]
	if entry then
		local fullName = entry.player .. "-" .. entry.server
		Ignore.entryLookup[Ignore:NormalizeName(fullName)] = nil
		table.remove(Ignore.entries, index)
		print(L["IgnoreRemoved"]:format(fullName))
	end
	RefreshList()
end

removeEntry = function(name)
	local player, server = strsplit("-", name)
	if server == (GetRealmName()):gsub("%s", "") then name = player end

	if Ignore.origDelIgnore and IsIgnored and IsIgnored(name) then Ignore.origDelIgnore(name) end
	local key = Ignore:NormalizeName(player .. "-" .. (server or ""))
	local entry = Ignore.entryLookup[key]
	if entry then
		for i, e in ipairs(Ignore.entries) do
			if e == entry then
				table.remove(Ignore.entries, i)
				break
			end
		end
		Ignore.entryLookup[key] = nil
	end
	print(L["IgnoreRemoved"]:format(name))
	RefreshList()
end

local function addOrRemove(name)
	local player, server = strsplit("-", name)
	player = player or name
	server = server or (GetRealmName()):gsub("%s", "")
	if Ignore.entryLookup[Ignore:NormalizeName(player .. "-" .. server)] then
		removeEntry(name)
		return
	end
	if IsIgnored and IsIgnored(name) then
		removeEntry(name)
	else
		C_FriendList.AddIgnore(name)
	end
end

function Ignore:ShowAddFrame(name, note, expires)
	if not name then return end

	if self.addFrame then
		AceGUI:Release(self.addFrame)
		self.addFrame = nil
	end

	local frame = AceGUI:Create("Window")
	frame:SetTitle(L["IgnoreWindowTitle"])
	frame:SetWidth(420)
	frame:SetHeight(220)
	frame:SetLayout("List")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		Ignore.addFrame = nil
	end)

	local nameLabel = AceGUI:Create("Label")
	nameLabel:SetText("|cffffd200" .. name .. "|r")
	nameLabel:SetFullWidth(true)
	frame:AddChild(nameLabel)

	local editBox = AceGUI:Create("MultiLineEditBox")
	editBox:SetFullWidth(true)
	editBox:SetLabel(L["IgnoreNote"])
	editBox:SetNumLines(4)
	editBox:DisableButton(true)
	if note then editBox:SetText(note) end
	frame:AddChild(editBox)

	local expGroup = AceGUI:Create("SimpleGroup")
	expGroup:SetFullWidth(true)
	expGroup:SetLayout("Flow")
	frame:AddChild(expGroup)

	local check = AceGUI:Create("CheckBox")
	check:SetLabel(L["IgnoreExpiresDays"])
	expGroup:AddChild(check)

	local numBox = AceGUI:Create("EditBox")
	numBox:SetWidth(60)
	numBox:SetDisabled(true)
	expGroup:AddChild(numBox)

	check:SetCallback("OnValueChanged", function(_, _, value)
		numBox:SetDisabled(not value)
		numBox.frame:SetShown(value)
		if not value then numBox:SetText("") end
	end)

	if expires and expires ~= NEVER then
		check:SetValue(true)
		numBox:SetDisabled(false)
		numBox.frame:Show()
		numBox:SetText(tostring(expires))
	else
		check:SetValue(false)
		numBox:SetText("")
		numBox:SetDisabled(true)
		numBox.frame:Hide()
	end

	local btnGroup = AceGUI:Create("SimpleGroup")
	btnGroup:SetFullWidth(true)
	btnGroup:SetLayout("Flow")
	frame:AddChild(btnGroup)

	local addBtn = AceGUI:Create("Button")
	addBtn:SetText(L["IgnoreAddSave"])
	addBtn:SetWidth(120)
	addBtn:SetCallback("OnClick", function()
		local n = editBox:GetText()
		local exp = 0
		if check:GetValue() then
			exp = tonumber(numBox:GetText())
			if not exp then exp = 0 end
		end
		addEntry(name, n, exp)
		frame:Hide()
	end)
	btnGroup:AddChild(addBtn)

	editBox:SetFocus()
	if editBox.editBox and addBtn.frame then editBox.editBox:SetScript("OnEnterPressed", function() addBtn.frame:Click() end) end

	local cancelBtn = AceGUI:Create("Button")
	cancelBtn:SetText(CANCEL)
	cancelBtn:SetWidth(120)
	cancelBtn:SetCallback("OnClick", function() frame:Hide() end)
	btnGroup:AddChild(cancelBtn)

	self.addFrame = frame
end

local function hookedAddIgnore(name)
	if not name or name == "" then
		if UnitExists("target") and UnitIsPlayer("target") then
			local n, realm = UnitName("target")
			if n then
				if realm and realm ~= "" then
					name = n .. "-" .. realm
				else
					name = n
				end
			end
		end
	end
	if not name or name == "" then return end
	Ignore:ShowAddFrame(name)
end

local function hookedDelIgnoreByIndex(index) removeEntryByIndex(index) end

local function hookedDelIgnore(name) removeEntry(name) end

local function hookedAddOrDelIgnore(name) addOrRemove(name) end

local monthMap = {
	Jan = 1,
	Feb = 2,
	Mar = 3,
	Apr = 4,
	May = 5,
	Jun = 6,
	Jul = 7,
	Aug = 8,
	Sep = 9,
	Oct = 10,
	Nov = 11,
	Dec = 12,
}

--- Wandelt einen String "DD Mon YYYY" in "YYYY-MM-DD" um.
-- @param dateStr  String im Format "26 Sep 2024"
-- @return String im Format "2024-09-26" oder nil bei Fehler
local function normalizeDate(dateStr)
	-- Extrahiere Tag, Monatskürzel und Jahr
	local day, monStr, year = dateStr:match("^(%d%d?)%s+(%a+)%s+(%d%d%d%d)$")
	if not (day and monStr and year) then return nil, "Ungültiges Datumsformat" end

	local month = monthMap[monStr]
	if not month then return nil, "Unbekannter Monat: " .. tostring(monStr) end

	-- Erzeuge einen Zeitstempel für Mitternacht dieses Tages
	local ts = time({ year = tonumber(year), month = month, day = tonumber(day), hour = 0 })

	-- Formatiere mit date()
	return date("%Y-%m-%d", ts)
end

local function showImportPopup()
	if not addon.db.enableIgnore then return end
	if not C_AddOns.IsAddOnLoaded("GlobalIgnoreList") then return end
	local gDB = GlobalIgnoreDB
	if not (gDB and gDB.ignoreList and #gDB.ignoreList > 0) then return end
	if StaticPopup_Visible("EQOL_IMPORT_GIL") then return end

	StaticPopupDialogs["EQOL_IMPORT_GIL"] = {
		text = L["ImportGILDialog"],
		button1 = L["ImportGILAccept"],
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		OnAccept = function()
			for i = 1, #gDB.ignoreList do
				local name = gDB.ignoreList[i]
				if name then
					local player, server = strsplit("-", name)
					player = player or name
					server = server or (GetRealmName()):gsub("%s", "")
					local nDate = normalizeDate(gDB.dateList[i])
					if not nDate then nDate = date("%Y-%m-%d") end
					local expires = gDB.expList[i]
					expires = expires > 0 and expires or NEVER
					local key = Ignore:NormalizeName(player .. "-" .. server)
					if key and not Ignore.entryLookup[key] then
						local e = {
							player = player,
							server = server,
							date = nDate,
							expires = expires,
							note = gDB.notes[i],
						}
						table.insert(Ignore.entries, e)
						Ignore.entryLookup[key] = e
					end
				end
			end
			C_AddOns.DisableAddOn("GlobalIgnoreList")
			ReloadUI()
		end,
		OnCancel = function()
			addon.db.enableIgnore = false
			Ignore.pendingImport = nil
			Ignore:SetEnabled(false)
			StaticPopupDialogs["EQOL_GIL_ACTIVE"] = {
				text = L["GILActivePopup"],
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("EQOL_GIL_ACTIVE")
		end,
	}
	StaticPopup_Show("EQOL_IMPORT_GIL")
end

LOGIN_FRAME:SetScript("OnEvent", function()
	if Ignore.pendingImport then
		showImportPopup()
		Ignore.pendingImport = nil
		return
	end
	if not Ignore.enabled then return end
	ensureFriendsFrame()
	local numIgnores = 0
	if C_FriendList and C_FriendList.GetNumIgnores then
		numIgnores = C_FriendList.GetNumIgnores()
	elseif GetNumIgnores then
		numIgnores = GetNumIgnores()
	end
	for i = 1, numIgnores do
		local name
		if C_FriendList and C_FriendList.GetIgnoreName then
			name = C_FriendList.GetIgnoreName(i)
		elseif GetIgnoreName then
			name = GetIgnoreName(i)
		end
		if name then
			local player, server = strsplit("-", name)
			player = player or name
			server = server or (GetRealmName()):gsub("%s", "")
			local key = Ignore:NormalizeName(player .. "-" .. server)
			if key and not Ignore.entryLookup[key] then
				local e = {
					player = player,
					server = server,
					date = date("%Y-%m-%d"),
					expires = NEVER,
					note = "",
				}
				table.insert(Ignore.entries, e)
				Ignore.entryLookup[key] = e
			end
		end
	end
	RefreshList()
end)

local SLASH_NAME = "EQOLIGNORE"
local SLASH_CMD = "/eil"

-- chat message filter to block messages from ignored players
local function ignoreChatFilter(_, _, _, sender)
	if not Ignore.enabled then return end
	if Ignore:CheckIgnore(sender) then return true end
	return false
end

local function hookIgnoreApi()
	if C_FriendList and not Ignore.hooksInstalled then
		Ignore.origAddIgnore = Ignore.origAddIgnore or C_FriendList.AddIgnore
		Ignore.origDelIgnoreByIndex = Ignore.origDelIgnoreByIndex or C_FriendList.DelIgnoreByIndex
		Ignore.origDelIgnore = Ignore.origDelIgnore or C_FriendList.DelIgnore
		Ignore.origAddOrDelIgnore = Ignore.origAddOrDelIgnore or C_FriendList.AddOrDelIgnore

		C_FriendList.AddIgnore = hookedAddIgnore
		C_FriendList.DelIgnoreByIndex = hookedDelIgnoreByIndex
		C_FriendList.DelIgnore = hookedDelIgnore
		C_FriendList.AddOrDelIgnore = hookedAddOrDelIgnore
		Ignore.hooksInstalled = true
	end
end

local function unhookIgnoreApi()
	if C_FriendList and Ignore.hooksInstalled then
		if Ignore.origAddIgnore then C_FriendList.AddIgnore = Ignore.origAddIgnore end
		if Ignore.origDelIgnoreByIndex then C_FriendList.DelIgnoreByIndex = Ignore.origDelIgnoreByIndex end
		if Ignore.origDelIgnore then C_FriendList.DelIgnore = Ignore.origDelIgnore end
		if Ignore.origAddOrDelIgnore then C_FriendList.AddOrDelIgnore = Ignore.origAddOrDelIgnore end
		Ignore.hooksInstalled = false
	end
end

local function updateRegistration()
	LOGIN_FRAME:UnregisterAllEvents()
	if Ignore.enabled then
		hookIgnoreApi()
		LOGIN_FRAME:RegisterEvent("PLAYER_LOGIN")
		for _, e in ipairs(CHAT_EVENTS) do
			if not Ignore.registeredFilters[e] then
				ChatFrame_AddMessageEventFilter(e, ignoreChatFilter)
				Ignore.registeredFilters[e] = true
			end
		end
		for _, evt in ipairs(INTERACTION_EVENTS) do
			Ignore.interactionBlocker:RegisterEvent(evt)
		end
		Ignore.groupCheckFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		_G["SLASH_" .. SLASH_NAME .. "1"] = SLASH_CMD
		SlashCmdList[SLASH_NAME] = function() Ignore:Toggle() end
	else
		for _, e in ipairs(CHAT_EVENTS) do
			if Ignore.registeredFilters[e] then
				ChatFrame_RemoveMessageEventFilter(e, ignoreChatFilter)
				Ignore.registeredFilters[e] = nil
			end
		end
		for _, evt in ipairs(INTERACTION_EVENTS) do
			Ignore.interactionBlocker:UnregisterEvent(evt)
		end
		Ignore.groupCheckFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		if EQOLIgnoreFrame then EQOLIgnoreFrame:Hide() end
		SlashCmdList[SLASH_NAME] = nil
		_G["SLASH_" .. SLASH_NAME .. "1"] = nil
		unhookIgnoreApi()
	end
end

function Ignore:SetEnabled(val)
	addon.db.enableIgnore = val and true or false
	Ignore.pendingImport = nil
	if val then
		if C_AddOns.IsAddOnLoaded("GlobalIgnoreList") then
			Ignore.enabled = false
			Ignore.pendingImport = true
			showImportPopup()
			updateRegistration()
			return
		end
		Ignore.enabled = true
	else
		Ignore.enabled = false
	end
	updateRegistration()
end

function Ignore:UpdateAnchor()
	if not self.frame then return end
	self.frame:ClearAllPoints()
	if addon and addon.db and addon.db.ignoreAnchorFriendsFrame and FriendsFrame then
		self.frame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 5, 0)
		self.frame:SetMovable(false)
	else
		local p = addon and addon.db and addon.db.ignoreFramePoint or "CENTER"
		local x = addon and addon.db and addon.db.ignoreFrameX or 0
		local y = addon and addon.db and addon.db.ignoreFrameY or 0
		self.frame:SetPoint(p, UIParent, p, x, y)
		self.frame:SetMovable(true)
	end
end

-- frame to check ignored members in current group
Ignore.groupCheckFrame = Ignore.groupCheckFrame or CreateFrame("Frame")
Ignore.groupCheckFrame.members = {}
Ignore.groupCheckFrame.lastPartySize = 0
Ignore.groupCheckFrame.lastIgnored = 0
Ignore.groupCheckFrame:SetScript("OnEvent", function()
	if not Ignore.enabled then return end
	local partyMembers = Ignore.groupCheckFrame.members
	wipe(partyMembers)

	local size = GetNumGroupMembers()
	if size == 0 then
		Ignore.groupCheckFrame.lastPartySize = 0
		Ignore.groupCheckFrame.lastIgnored = 0
		return
	end

	local prefix = IsInRaid() and "raid" or "party"
	local loops = IsInRaid() and size or (size - 1)
	for i = 1, loops do
		local unit = prefix .. i
		if UnitExists(unit) then
			local n, r = UnitFullName(unit)
			if n then
				r = r or (GetRealmName()):gsub("%s", "")
				partyMembers[n .. "-" .. r] = true
			end
		end
	end

	local pn, pr = UnitFullName("player")
	pr = pr or (GetRealmName()):gsub("%s", "")
	if pn then partyMembers[pn .. "-" .. pr] = true end

	local ignored = {}
	local count = 0
	for name in pairs(partyMembers) do
		if Ignore:CheckIgnore(name) then
			table.insert(ignored, name)
			count = count + 1
		end
	end

	if count > Ignore.groupCheckFrame.lastIgnored then
		local names = table.concat(ignored, "\n")
		StaticPopupDialogs["EQOL_IGNORE_GROUP"] = {
			text = L["IgnoreGroupPopupText"]:format(names),
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EQOL_IGNORE_GROUP")
	end

	Ignore.groupCheckFrame.lastPartySize = size
	Ignore.groupCheckFrame.lastIgnored = count
end)

Ignore.interactionBlocker = Ignore.interactionBlocker or CreateFrame("Frame")
Ignore.interactionBlocker:SetScript("OnEvent", function(_, event, ...)
	if not Ignore.enabled then return end
	local name = ...
	if event == "TRADE_SHOW" then name = UnitFullName("npc") end
	if Ignore:CheckIgnore(name or "") then
		if event == "PARTY_INVITE_REQUEST" then
			DeclineGroup()
			StaticPopup_Hide("PARTY_INVITE")
		elseif event == "GUILD_INVITE_REQUEST" then
			DeclineGuildInvite()
			StaticPopup_Hide("GUILD_INVITE")
		elseif event == "DUEL_REQUESTED" then
			CancelDuel()
			StaticPopup_Hide("DUEL_REQUESTED")
		elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" then
			C_PetBattles.CancelPVPDuel()
			StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
		elseif event == "TRADE_SHOW" then
			CancelTrade()
			StaticPopup_Hide("TRADE")
		end
	end
end)

-- frame to check ignored members in current group
Ignore.groupCheckFrame = Ignore.groupCheckFrame or CreateFrame("Frame")
Ignore.groupCheckFrame.members = {}
Ignore.groupCheckFrame.lastPartySize = 0
Ignore.groupCheckFrame.lastIgnored = 0
Ignore.groupCheckFrame:SetScript("OnEvent", function()
	if not Ignore.enabled then return end
	local partyMembers = Ignore.groupCheckFrame.members
	wipe(partyMembers)

	local size = GetNumGroupMembers()
	if size == 0 then
		Ignore.groupCheckFrame.lastPartySize = 0
		Ignore.groupCheckFrame.lastIgnored = 0
		return
	end

	local prefix = IsInRaid() and "raid" or "party"
	local loops = IsInRaid() and size or (size - 1)
	for i = 1, loops do
		local unit = prefix .. i
		if UnitExists(unit) then
			local n, r = UnitFullName(unit)
			if n then
				r = r or (GetRealmName()):gsub("%s", "")
				partyMembers[n .. "-" .. r] = true
			end
		end
	end

	local pn, pr = UnitFullName("player")
	pr = pr or (GetRealmName()):gsub("%s", "")
	if pn then partyMembers[pn .. "-" .. pr] = true end

	local ignored = {}
	local count = 0
	for _, entry in ipairs(Ignore.entries) do
		local full = entry.player .. "-" .. entry.server
		if partyMembers[full] then
			table.insert(ignored, full)
			count = count + 1
		end
	end

	if count > Ignore.groupCheckFrame.lastIgnored then
		local names = table.concat(ignored, "\n")
		StaticPopupDialogs["EQOL_IGNORE_GROUP"] = {
			text = L["IgnoreGroupPopupText"]:format(names),
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EQOL_IGNORE_GROUP", L["IgnoreGroupPopupTitle"])
	end

	Ignore.groupCheckFrame.lastPartySize = size
	Ignore.groupCheckFrame.lastIgnored = count
end)
