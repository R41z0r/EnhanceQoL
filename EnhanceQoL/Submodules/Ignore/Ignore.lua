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
Ignore.rows = {}
Ignore.searchText = Ignore.searchText or ""
Ignore.addFrame = Ignore.addFrame or nil

local widths = { 120, 120, 70, 90, 90, 150 }
local titles = { "Player Name", "Server Name", "Date", "Expires", "Note" }

local removeEntryByIndex
local DOUBLE_CLICK_TIME = 0.5

local function updateCounter()
	if Ignore.counter then Ignore.counter:SetText("Entries: " .. #Ignore.entries) end
end

local function refreshList()
	if not Ignore.scrollFrame then return end
	Ignore.scrollFrame:ReleaseChildren()
	wipe(Ignore.rows)

	local search = Ignore.searchText and Ignore.searchText:lower() or ""
	local filtering = search ~= ""

	local header = AceGUI:Create("SimpleGroup")
	header:SetFullWidth(true)
	header:SetLayout("Flow")
	for i, col in ipairs(titles) do
		local lbl = AceGUI:Create("Label")
		lbl:SetText("|cffffd200" .. col .. "|r")
		lbl:SetWidth(widths[i])
		header:AddChild(lbl)
	end
	Ignore.scrollFrame:AddChild(header)

	for idx, data in ipairs(Ignore.entries) do
		if
			not filtering
			or (data.player and data.player:lower():find(search, 1, true))
			or (data.server and data.server:lower():find(search, 1, true))
			or (data.note and data.note:lower():find(search, 1, true))
		then
			local row = AceGUI:Create("SimpleGroup")
			row:SetFullWidth(true)
			row:SetLayout("Flow")
			row.index = idx
			row.frame:EnableMouse(true)
			local bg = row.frame:CreateTexture(nil, "BACKGROUND")
			bg:SetAllPoints(row.frame)
			row.bg = bg
			if idx == Ignore.selectedIndex then
				bg:SetColorTexture(1, 1, 0, 0.3)
			else
				bg:SetColorTexture(0, 0, 0, 0)
			end
			row.frame:SetScript("OnMouseDown", function(frame)
				local widget = frame.obj
				if Ignore.selectedIndex and Ignore.rows[Ignore.selectedIndex] then
					local prev = Ignore.rows[Ignore.selectedIndex]
					if prev.bg then prev.bg:SetColorTexture(0, 0, 0, 0) end
				end
				Ignore.selectedIndex = widget.index
				widget.bg:SetColorTexture(1, 1, 0, 0.3)

				local now = GetTime()
				if widget.lastClick and (now - widget.lastClick) < DOUBLE_CLICK_TIME then
					local entry = Ignore.entries[widget.index]
					if entry then
						local fullName = entry.player .. "-" .. entry.server
						Ignore:ShowAddFrame(fullName, entry.note, entry.expires)
					end
				end
				widget.lastClick = now
			end)
			local values = {
				data.player or "",
				data.server or "",
				data.date or "",
				data.expires or "",
				data.note or "",
			}
			for i, val in ipairs(values) do
				local lbl = AceGUI:Create("Label")
				lbl:SetText(val)
				lbl:SetWidth(widths[i])
				row:AddChild(lbl)
			end
			Ignore.rows[idx] = row
			Ignore.scrollFrame:AddChild(row)
		end
	end
	updateCounter()
end

function Ignore:CreateUI()
	if self.window then return end
	local frame = AceGUI:Create("Window")
	frame:SetTitle("Enhanced Ignore")
	frame:SetWidth(650)
	frame:SetHeight(400)
	frame:SetLayout("List")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		if self.searchBox then
			AceGUI:Release(self.searchBox)
			self.searchBox = nil
		end
		self.window = nil
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
	search.frame:SetParent(frame.frame)
	search.frame:ClearAllPoints()
	search.frame:SetPoint("TOPRIGHT", frame.frame, "TOPRIGHT", -40, -32)
	search:SetCallback("OnTextChanged", function(_, _, text)
		Ignore.searchText = text or ""
		Ignore.selectedIndex = nil
		refreshList()
	end)
	self.searchBox = search

	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("List")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	frame:AddChild(scroll)
	self.scrollFrame = scroll

	local remove = AceGUI:Create("Button")
	remove:SetText("Remove")
	remove:SetWidth(120)
	remove:SetCallback("OnClick", function()
		if Ignore.selectedIndex then
			removeEntryByIndex(Ignore.selectedIndex)
			Ignore.selectedIndex = nil
		end
	end)
	frame:AddChild(remove)

	self.window = frame
	refreshList()
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
			entry.note = note or entry.note
			entry.expires = expires or entry.expires
			refreshList()
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
	refreshList()
end

removeEntryByIndex = function(index)
        local entry = Ignore.entries[index]
        if entry then
                local fullName = entry.player
                if entry.server and entry.server ~= "" then
                        fullName = fullName .. "-" .. entry.server
                end
                removeEntry(fullName)
        end
        table.remove(Ignore.entries, index)
        refreshList()
end

local function removeEntry(name)
	if origDelIgnore then origDelIgnore(name) end
	local player, server = strsplit("-", name)
	for i, entry in ipairs(Ignore.entries) do
		if entry.player == player and entry.server == (server or "") then
			table.remove(Ignore.entries, i)
			break
		end
	end
	refreshList()
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

	check:SetCallback("OnValueChanged", function(_, _, value) numBox:SetDisabled(not value) end)

	if expires and expires ~= "NEVER" then
		check:SetValue(true)
		numBox:SetDisabled(false)
		numBox:SetText(tostring(expires))
	else
		check:SetValue(false)
		numBox:SetText("")
		numBox:SetDisabled(true)
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
		local exp
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
                       if not found then
                               table.insert(Ignore.entries, {
                                       player = player,
                                       server = server,
                                       date = date("%Y-%m-%d"),
                                       expires = "NEVER",
                                       note = "",
                               })
                       end
               end
       end
       refreshList()
end)
