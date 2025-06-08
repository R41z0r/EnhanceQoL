local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local IgnoreList = addon.IgnoreList or {}

StaticPopupDialogs["EQOL_ADD_IGNORE_NOTE"] = {
	text = IGNORE .. " %s",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnShow = function(self, data)
		self.editBox:SetText("")
		self.editBox:SetFocus()
		self.data = data
	end,
	OnAccept = function(self)
		if IgnoreList and IgnoreList.performAdd then IgnoreList.performAdd(self.data, self.editBox:GetText()) end
	end,
}

StaticPopupDialogs["EQOL_IGNORELIST_GROUP"] = {
	text = "Ignored players in group:\n%s",
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EQOL_EDIT_IGNORE_NOTE"] = {
	text = "Edit note for %s",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnShow = function(self, data)
		self.editBox:SetText(data.note or "")
		self.editBox:SetFocus()
		self.data = data.name
	end,
	OnAccept = function(self)
		if IgnoreList and IgnoreList.SetNote then IgnoreList.SetNote(self.data, self.editBox:GetText()) end
	end,
}

local AceGUI = addon.AceGUI

function IgnoreList.SetNote(name, note)
	if not name or not IgnoreList.db[name] then return end
	IgnoreList.db[name].note = note
end

local function splitName(name)
	if not name then return "", "" end
	local char, server = name:match("([^%-]+)%-(.+)")
	return char or name, server or ""
end

local function createTable(container)
	local group = AceGUI:Create("SimpleGroup")
	group:SetFullWidth(true)
	group:SetLayout("Table")
	group:SetUserData("table", { columns = { 1.5, 1, 1, 1, 2 } })
	container:AddChild(group)
	return group
end

local function addHeader(tableGroup)
	local headers = { "Name", "Server", "Faction", "IgnoredSince", "Note" }
	for _, text in ipairs(headers) do
		local label = AceGUI:Create("Label")
		label:SetText("|cffffd700" .. text .. "|r")
		tableGroup:AddChild(label)
	end
end

function IgnoreList.RefreshList(filter)
	if not IgnoreList.scroll then return end
	IgnoreList.scroll:ReleaseChildren()
	local tableGroup = createTable(IgnoreList.scroll)
	addHeader(tableGroup)
	local entries = {}
	for name, data in pairs(IgnoreList.db or {}) do
		table.insert(entries, data)
	end
	table.sort(entries, function(a, b) return a.name < b.name end)
	filter = filter and filter:lower() or ""
	for _, entry in ipairs(entries) do
		local lname = entry.name:lower()
		local note = (entry.note or ""):lower()
		if filter == "" or lname:find(filter, 1, true) or note:find(filter, 1, true) then
			local char, server = splitName(entry.name)
			local cb = AceGUI:Create("CheckBox")
			cb:SetValue(IgnoreList.selected == entry.name)
			cb:SetLabel(char)
			cb:SetUserData("name", entry.name)
			cb:SetCallback("OnValueChanged", function(widget, _, val)
				if val then
					IgnoreList.selected = widget:GetUserData("name")
				else
					IgnoreList.selected = nil
				end
				IgnoreList.RefreshList(filter)
			end)
			tableGroup:AddChild(cb)

			local lblServer = AceGUI:Create("Label")
			lblServer:SetText(server)
			tableGroup:AddChild(lblServer)

			local lblFaction = AceGUI:Create("Label")
			lblFaction:SetText(entry.faction or "")
			tableGroup:AddChild(lblFaction)

			local lblTime = AceGUI:Create("Label")
			local days = math.floor((time() - entry.time) / 86400)
			lblTime:SetText(days)
			tableGroup:AddChild(lblTime)

			local lblNote = AceGUI:Create("Label")
			lblNote:SetText(entry.note or "")
			tableGroup:AddChild(lblNote)
		end
	end
	IgnoreList.tableGroup = tableGroup
end

function IgnoreList.CreateUI()
	if IgnoreList.frame then return end
	local frame = AceGUI:Create("Window")
	frame:SetTitle("Ignore List")
	frame:SetLayout("Fill")
	frame:SetCallback("OnClose", function(widget) widget:Hide() end)
	IgnoreList.frame = frame

	local group = AceGUI:Create("SimpleGroup")
	group:SetLayout("Flow")
	group:SetFullWidth(true)
	group:SetFullHeight(true)
	frame:AddChild(group)

	local search = AceGUI:Create("EditBox")
	search:SetLabel(SEARCH)
	search:SetFullWidth(true)
	search:SetCallback("OnTextChanged", function(_, _, text) IgnoreList.RefreshList(text) end)
	group:AddChild(search)
	IgnoreList.search = search

	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	group:AddChild(scroll)
	IgnoreList.scroll = scroll

	local btnGroup = AceGUI:Create("SimpleGroup")
	btnGroup:SetLayout("Flow")
	btnGroup:SetFullWidth(true)
	group:AddChild(btnGroup)

	local btnRemove = addon.functions.createButtonAce(REMOVE, 100, function()
		if IgnoreList.selected then
			IgnoreList:DelIgnore(IgnoreList.selected)
			IgnoreList.selected = nil
			IgnoreList.RefreshList(IgnoreList.search:GetText())
		end
	end)
	btnGroup:AddChild(btnRemove)

	local btnEdit = addon.functions.createButtonAce(EDIT, 100, function()
		if IgnoreList.selected then
			local data = IgnoreList.db[IgnoreList.selected] or {}
			StaticPopup_Show("EQOL_EDIT_IGNORE_NOTE", IgnoreList.selected, nil, { name = IgnoreList.selected, note = data.note })
		end
	end)
	btnGroup:AddChild(btnEdit)

	IgnoreList.RefreshList()
end

function IgnoreList.ShowWindow()
	IgnoreList.CreateUI()
	if IgnoreList.frame.frame:IsShown() then
		IgnoreList.frame.frame:Hide()
	else
		IgnoreList.frame.frame:Show()
	end
end
