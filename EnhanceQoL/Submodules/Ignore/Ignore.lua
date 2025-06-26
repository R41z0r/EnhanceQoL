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

Ignore.filtered = {}

local ROW_HEIGHT = 20

local widths = { 120, 120, 70, 90, 150 }
local titles = { "Player Name", "Server Name", "Date", "Expires", "Note" }
local DOUBLE_CLICK_TIME = 0.5

local IgnoreRowMixin = {}

function IgnoreRowMixin:Init()
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

    self:SetHeight(ROW_HEIGHT)
    self:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight")
    self:RegisterForClicks("LeftButtonUp")
end

function IgnoreRowMixin:Populate(data, index)
    self.index = index
    self.cols[1]:SetText(data.player or "")
    self.cols[2]:SetText(data.server or "")
    self.cols[3]:SetText(data.date or "")
    self.cols[4]:SetText(data.expires or "")
    self.cols[5]:SetText(data.note or "")
end

function IgnoreRowMixin:OnClick()
    if Ignore.selectedIndex and Ignore.rows[Ignore.selectedIndex] then
        local prev = Ignore.rows[Ignore.selectedIndex]
        if prev.bg then prev.bg:SetColorTexture(0, 0, 0, 0) end
    end

    Ignore.selectedIndex = self.index
    self.bg:SetColorTexture(1, 1, 0, 0.3)

    local now = GetTime()
    if self.lastClick and (now - self.lastClick) < DOUBLE_CLICK_TIME then
        local entry = Ignore.filtered[self.index]
        if entry then
            local fullName = entry.player
            if entry.server and entry.server ~= "" then
                fullName = fullName .. "-" .. entry.server
            end
            Ignore:ShowAddFrame(fullName, entry.note, entry.expires)
        end
    end
    self.lastClick = now
end

local removeEntry
local removeEntryByIndex

local function updateCounter()
	if Ignore.counter then Ignore.counter:SetText("Entries: " .. #Ignore.entries) end
end

local function refreshList()
    if not Ignore.scrollFrame then return end

    wipe(Ignore.rows)
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

    local scrollFrame = Ignore.scrollFrame
    local buttons = scrollFrame.buttons or {}
    local numButtons = math.floor(scrollFrame:GetHeight() / ROW_HEIGHT) + 1
    local scrollChild = scrollFrame.scrollChild
    if not scrollChild then
        scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(1,1)
        scrollFrame:SetScrollChild(scrollChild)
        scrollFrame.scrollChild = scrollChild
    end
    for i = #buttons + 1, numButtons do
        local btn = CreateFrame("Button", nil, scrollChild)
        Mixin(btn, IgnoreRowMixin)
        btn:Init()
        if i == 1 then
            btn:SetPoint("TOPLEFT")
        else
            btn:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT")
        end
        btn:SetPoint("RIGHT", scrollChild)
        btn:SetScript("OnClick", function(b) IgnoreRowMixin.OnClick(b) end)
        buttons[i] = btn
    end
    scrollFrame.buttons = buttons

    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    for i, button in ipairs(buttons) do
        local idx = i + offset
        local data = Ignore.filtered[idx]
        if data then
            button:Show()
            button:Populate(data, idx)
            Ignore.rows[idx] = button
            if idx == Ignore.selectedIndex then
                button.bg:SetColorTexture(1, 1, 0, 0.3)
            else
                button.bg:SetColorTexture(0, 0, 0, 0)
            end
        else
            button:Hide()
        end
    end

    local contentHeight = #Ignore.filtered * ROW_HEIGHT
    scrollChild:SetHeight(contentHeight)
    HybridScrollFrame_Update(scrollFrame, contentHeight, scrollFrame:GetHeight())
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
                refreshList()
        end)
        frame:AddChild(search)
        search.frame:ClearAllPoints()
        search.frame:SetPoint("TOPRIGHT", frame.frame, "TOPRIGHT", -40, -32)
        self.searchBox = search

        local scroll = CreateFrame("ScrollFrame", nil, frame.frame, "HybridScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", frame.frame, "TOPLEFT", 20, -90)
        scroll:SetPoint("BOTTOMRIGHT", frame.frame, "BOTTOMRIGHT", -45, 50)
        scroll.scrollBar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 0, -16)
        scroll.scrollBar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 0, 16)
        scroll.update = refreshList
        self.scrollFrame = scroll

        local header = CreateFrame("Frame", nil, scroll)
        header:SetPoint("BOTTOMLEFT", scroll, "TOPLEFT", 0, 2)
        header:SetHeight(ROW_HEIGHT)
        header:SetWidth(550)
        local x = 0
        for i, col in ipairs(titles) do
                local lbl = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                lbl:SetPoint("LEFT", x, 0)
                lbl:SetWidth(widths[i])
                lbl:SetJustifyH("LEFT")
                lbl:SetText(col)
                x = x + widths[i]
        end

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
                       if note ~= nil then entry.note = note end
                       if expires ~= nil then
                               entry.expires = expires ~= "" and expires or "NEVER"
                       end
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
                if entry.server and entry.server ~= "" then fullName = fullName .. "-" .. entry.server end
                removeEntry(fullName)
        end
        refreshList()
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
	refreshList()
end)
