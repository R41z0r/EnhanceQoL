local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local AceGUI = addon.AceGUI
local Ignore = addon.Ignore or {}
addon.Ignore = Ignore

Ignore.entries = Ignore.entries or {}
Ignore.selectedIndex = nil
Ignore.searchText = Ignore.searchText or ""
Ignore.addFrame = Ignore.addFrame or nil

Ignore.filtered = {}

function Ignore.daysFromToday(dateStr)
	if not dateStr then return 0 end
	local y, m, d = dateStr:match("(%d+)%-(%d+)%-(%d+)")
	if not y then return 0 end
	local t = time({ year = y, month = m, day = d, hour = 0 })
	return math.floor((time() - t) / 86400)
end

function Ignore:GetExpireText(entry)
	if not entry or not entry.expires or entry.expires == "NEVER" then return "NEVER" end
	local exp = tonumber(entry.expires)
	if not exp then return tostring(entry.expires) end
	local left = exp - self.daysFromToday(entry.date)
	if left <= 0 then return "TODAY" end
	return left .. "d"
end

local ROW_HEIGHT = 20

local widths = { 130, 150, 60, 60, 230 }
local titles = { "Player", "Server", "Listed", "Expires", "Note" }
local DOUBLE_CLICK_TIME = 0.5

Ignore.currentSort = nil
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

local function RefreshList()
	FilterEntries()
	if Ignore.counter then Ignore.counter:SetText("Entries: " .. #Ignore.filtered) end
	if Ignore.scrollFrame then
		FauxScrollFrame_Update(Ignore.scrollFrame, #Ignore.filtered, NUM_ROWS, ROW_HEIGHT)
		Ignore:UpdateRows()
	end
end

function Ignore:UpdateRows()
	if not self.scrollFrame then return end
	local offset = FauxScrollFrame_GetOffset(self.scrollFrame)
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

function Ignore:CreateUI()
	if self.window then return end
	local frame = AceGUI:Create("Window")
	frame:SetTitle("Enhanced Ignore")
	frame:SetWidth(650)
	frame:SetHeight(440)
	frame:SetLayout("List")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		if self.searchBox then
			AceGUI:Release(self.searchBox)
			self.searchBox = nil
		end
		self.window = nil
		Ignore.searchText = ""
	end)

	local spacer = AceGUI:Create("Label")
	spacer:SetText(" ")
	spacer:SetFullWidth(true)
	spacer:SetHeight(15)
	frame:AddChild(spacer)

	local counter = AceGUI:Create("Heading")
	counter:SetText("Entries: 0")
	counter:SetFullWidth(true)
	frame:AddChild(counter)
	self.counter = counter

	local search = AceGUI:Create("EditBox")
	search:SetWidth(150)
	search:DisableButton(true)
	search:SetCallback("OnTextChanged", function(_, _, text)
		Ignore.searchText = text or ""
		Ignore.selectedIndex = nil
		RefreshList()
	end)
	frame:AddChild(search)
	search.frame:ClearAllPoints()
	search.frame:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", -20, -10)
	self.searchBox = search

	-- Create a dedicated container for custom UI within the AceGUI window
	local group = AceGUI:Create("SimpleGroup")
	group:SetFullWidth(true)
	group:SetFullHeight(true)
	group:SetLayout("Fill")
	frame:AddChild(group)
	-- Use this group's frame for manual CreateFrame parenting
	local container = group.frame

	local listWidth = 0
	for _, w in ipairs(widths) do
		listWidth = listWidth + w
	end

	-- Header container for column titles
	local header = CreateFrame("Frame", nil, container)
	header:SetParent(container) -- parent to the AceGUI content region
	header:Show()
	header:SetPoint("TOPLEFT", container, "TOPLEFT", 7, 0)
	header:SetHeight(ROW_HEIGHT)
	header:SetWidth(listWidth + 5) -- match total list width
	local x = 0
	for idx, col in ipairs({
		{ text = "Player", width = widths[1], key = "player" },
		{ text = "Server", width = widths[2], key = "server" },
		{ text = "Listed", width = widths[3], key = "listed" },
		{ text = "Expires", width = widths[4], key = "expire" },
		{ text = "Note", width = widths[5], key = "note" },
	}) do
		local h = CreateFrame("Button", "EQOLIgnoreHeader" .. idx, header, "WhoFrameColumnHeaderTemplate")
		h:SetWidth(col.width)
		if col.key == "note" then
			_G[h:GetName() .. "Middle"]:SetWidth(col.width - 60)
		else
			_G[h:GetName() .. "Middle"]:SetWidth(col.width - 9)
		end
		h:SetHeight(ROW_HEIGHT)
		h:SetPoint("LEFT", x, 0)
		if h.Text then
			h.Text:SetText(col.text)
		else
			h:SetText(col.text)
		end
		h.sortKey = col.key
		h:SetScript("OnClick", function(self)
			Ignore.sortAsc = (Ignore.currentSort ~= self.sortKey) and true or not Ignore.sortAsc
			Ignore.currentSort = self.sortKey
			table.sort(Ignore.filtered, function(a, b)
				local av, bv
				if self.sortKey == "listed" then
					av = Ignore.daysFromToday(a.date or "")
					bv = Ignore.daysFromToday(b.date or "")
				elseif self.sortKey == "expire" then
					av = Ignore:GetExpireText(a)
					bv = Ignore:GetExpireText(b)
				else
					av = tostring(a[self.sortKey] or "")
					bv = tostring(b[self.sortKey] or "")
				end
				if Ignore.sortAsc then
					return av < bv
				else
					return av > bv
				end
			end)
			Ignore:UpdateRows()
		end)
		x = x + col.width
	end

	local scrollFrame = CreateFrame("ScrollFrame", "EQOLIgnoreScrollFrame", container, "FauxScrollFrameTemplate")
	scrollFrame:SetParent(container) -- ensure proper AceGUI parenting
	scrollFrame:Show()

	scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
	scrollFrame:SetHeight((NUM_ROWS * ROW_HEIGHT))
	scrollFrame:SetWidth(listWidth - 50)
	-- Fill to bottom-right of container, leave space for Remove button
	-- scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -20, 50)
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() Ignore:UpdateRows() end)
	end)
	local bg = scrollFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(scrollFrame)
	bg:SetColorTexture(0, 0, 0, 0.7)
	Ignore.scrollFrame = scrollFrame

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(listWidth, NUM_ROWS * ROW_HEIGHT)
	scrollFrame:SetScrollChild(scrollChild)

	for i = 1, NUM_ROWS do
		local row = CreateFrame("Button", nil, scrollChild)
		row:SetParent(scrollChild)
		row:Show()
		Mixin(row, IgnoreRowTemplate)
		row:OnAcquired()
		row:SetWidth(listWidth)
		row:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 7, -((i - 1) * ROW_HEIGHT) - 5)
		Ignore.rows[i] = row
	end

	-- Manual Remove button inside container
	local removeBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
	removeBtn:SetSize(120, 22)
	removeBtn:SetPoint("BOTTOMLEFT", frame.frame, "BOTTOMLEFT", 10, 10)
	removeBtn:SetText("Remove")
	removeBtn:SetScript("OnClick", function()
		if Ignore.selectedIndex then
			removeEntryByIndex(Ignore.selectedIndex)
			Ignore.selectedIndex = nil
		end
		RefreshList()
	end)

	self.window = frame
	RefreshList()
end

function Ignore:Toggle()
	if self.window and self.window.frame:IsShown() then
		self.window:Hide()
	else
		self:CreateUI()
		self.window:Show()
	end
end

SLASH_EQOLIGNORE1 = "/eig"
SlashCmdList["EQOLIGNORE"] = function() Ignore:Toggle() end

-- keep originals so we can still call Blizzard's ignore API
local origAddIgnore = C_FriendList and C_FriendList.AddIgnore
local origDelIgnoreByIndex = C_FriendList and C_FriendList.DelIgnoreByIndex
local origDelIgnore = C_FriendList and C_FriendList.DelIgnore
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
	for _, entry in ipairs(Ignore.entries) do
		if entry.player == player and entry.server == server then
			if note ~= nil then entry.note = note end
			if expires ~= nil then entry.expires = expires ~= "" and expires or "NEVER" end
			RefreshList()
			return
		end
	end
	if origAddIgnore and sameRealm and Ignore:HasFreeSlot() then origAddIgnore(name) end
	table.insert(Ignore.entries, {
		player = player,
		server = server,
		date = date("%Y-%m-%d"),
		expires = expires or "NEVER",
		note = note or "",
	})
	RefreshList()
end

removeEntryByIndex = function(index)
	local entry = Ignore.entries[index]
	if entry then
		local fullName = entry.player
		if entry.server and entry.server ~= "" then fullName = fullName .. "-" .. entry.server end
		removeEntry(fullName)
	end
	RefreshList()
end

removeEntry = function(name)
	if origDelIgnore and IsIgnored and IsIgnored(name) then origDelIgnore(name) end
	local player, server = strsplit("-", name)
	for i, entry in ipairs(Ignore.entries) do
		if entry.player == player and entry.server == (server or "") then
			table.remove(Ignore.entries, i)
			break
		end
	end
	RefreshList()
end

local function addOrRemove(name)
	local player, server = strsplit("-", name)
	player = player or name
	server = server or (GetRealmName()):gsub("%s", "")
	for _, entry in ipairs(Ignore.entries) do
		if entry.player == player and entry.server == server then
			removeEntry(name)
			return
		end
	end
	if C_FriendList and C_FriendList.IsIgnored and C_FriendList.IsIgnored(name) then
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
	frame:SetTitle("Enhanced Ignore")
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
	editBox:SetLabel("Note")
	editBox:SetNumLines(4)
	editBox:DisableButton(true)
	if note then editBox:SetText(note) end
	frame:AddChild(editBox)

	local expGroup = AceGUI:Create("SimpleGroup")
	expGroup:SetFullWidth(true)
	expGroup:SetLayout("Flow")
	frame:AddChild(expGroup)

	local check = AceGUI:Create("CheckBox")
	check:SetLabel("Expires (days)")
	expGroup:AddChild(check)

	local numBox = AceGUI:Create("EditBox")
	numBox:SetWidth(60)
	numBox:SetDisabled(true)
	expGroup:AddChild(numBox)

	check:SetCallback("OnValueChanged", function(_, _, value)
		numBox:SetDisabled(not value)
		numBox.frame:SetShown(value)
	end)

	if expires and expires ~= "NEVER" then
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
	addBtn:SetText("Add/Save")
	addBtn:SetWidth(120)
	addBtn:SetCallback("OnClick", function()
		local n = editBox:GetText()
		local exp = ""
		if check:GetValue() then exp = tonumber(numBox:GetText()) end
		addEntry(name, n, exp)
		frame:Hide()
	end)
	btnGroup:AddChild(addBtn)

	local cancelBtn = AceGUI:Create("Button")
	cancelBtn:SetText(CANCEL)
	cancelBtn:SetWidth(120)
	cancelBtn:SetCallback("OnClick", function() frame:Hide() end)
	btnGroup:AddChild(cancelBtn)

	self.addFrame = frame
end

function C_FriendList.AddIgnore(name) Ignore:ShowAddFrame(name) end

function C_FriendList.DelIgnoreByIndex(index) removeEntryByIndex(index) end

function C_FriendList.DelIgnore(name) removeEntry(name) end

function C_FriendList.AddOrDelIgnore(name) addOrRemove(name) end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
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
			local found
			for _, entry in ipairs(Ignore.entries) do
				if entry.player == player and entry.server == server then
					found = true
					break
				end
			end
			if not found then table.insert(Ignore.entries, {
				player = player,
				server = server,
				date = date("%Y-%m-%d"),
				expires = "NEVER",
				note = "",
			}) end
		end
	end
	RefreshList()
end)
