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

local widths = { 120, 120, 70, 90, 90, 150 }
local titles = { "Player Name", "Server Name", "Date", "Expires", "Note" }

local function updateCounter()
	if Ignore.counter then Ignore.counter:SetText("Entries: " .. #Ignore.entries) end
end

local function refreshList()
	if not Ignore.scrollFrame then return end
	Ignore.scrollFrame:ReleaseChildren()

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
		if #self.entries > 0 then
			table.remove(self.entries)
			refreshList()
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
