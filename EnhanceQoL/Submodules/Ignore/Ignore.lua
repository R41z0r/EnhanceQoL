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

local widths = { 120, 120, 70, 90, 90, 150 }
local titles = { "Player Name", "Server Name", "Date", "Expires", "Note" }

local removeEntryByIndex

local function updateCounter()
	if Ignore.counter then Ignore.counter:SetText("Entries: " .. #Ignore.entries) end
end

local function refreshList()
	if not Ignore.scrollFrame then return end
        Ignore.scrollFrame:ReleaseChildren()
        wipe(Ignore.rows)

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

local function addEntry(name, note, expires)
    local player, server = strsplit("-", name)
    player = player or name
    server = server or (GetRealmName()):gsub("%s", "")
    for _, entry in ipairs(Ignore.entries) do
        if entry.player == player and entry.server == server then
            entry.note = note or entry.note
            entry.expires = expires or entry.expires
            refreshList()
            return
        end
    end
    if origAddIgnore then origAddIgnore(name) end
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
        if origDelIgnoreByIndex then origDelIgnoreByIndex(index) end
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

StaticPopupDialogs["EQOL_ADD_IGNORE"] = {
	text = "Add player to enhanced ignore list",
	button1 = ADD,
	button2 = CANCEL,
	hasEditBox = true,
	editBoxWidth = 350,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnShow = function(self, name)
		self:SetWidth(420)
		self:SetHeight(220)
		self.editBox:SetMultiLine(true)
		self.editBox:SetHeight(80)
		self.editBox:SetText("")
		self.editBox:SetFocus()
		if name then self.text:SetFormattedText("Add %s to enhanced ignore list?", "|cffffd200" .. name .. "|r") end
		if not self.expCheck then
			local check = CreateFrame("CheckButton", nil, self, "ChatConfigCheckButtonTemplate")
			check:SetPoint("TOPLEFT", self.editBox, "BOTTOMLEFT", -2, -4)

			check.Text:SetText("Expires (days)")
			local box = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
			box:SetAutoFocus(false)
			box:SetNumeric(true)
			box:SetWidth(50)
			box:SetPoint("LEFT", check.Text, "RIGHT", 4, 0)
			box:Disable()
			check:SetScript("OnClick", function(btn)
				if btn:GetChecked() then
					box:Enable()
				else
					box:Disable()
				end
			end)
			self.expCheck = check
			self.expBox = box
		end
		self.expCheck:ClearAllPoints()
		self.expCheck:SetPoint("TOPLEFT", self.editBox, "BOTTOMLEFT", -2, -4)
		self.expCheck:SetChecked(false)
		self.expBox:SetText("")
		self.expBox:SetPoint("LEFT", self.expCheck.Text, "RIGHT", 4, 0)
		self.expBox:Disable()
	end,
	OnAccept = function(self, name)
		local note = self.editBox:GetText()
		local expires
		if self.expCheck:GetChecked() then expires = tonumber(self.expBox:GetText()) end
		addEntry(name, note, expires)
	end,
}

function C_FriendList.AddIgnore(name) StaticPopup_Show("EQOL_ADD_IGNORE", nil, nil, name) end

function C_FriendList.DelIgnoreByIndex(index) removeEntryByIndex(index) end

function C_FriendList.DelIgnore(name) removeEntry(name) end

function C_FriendList.AddOrDelIgnore(name) addOrRemove(name) end
