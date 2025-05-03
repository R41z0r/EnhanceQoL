local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LLayoutTools

local AceGUI = addon.AceGUI
local db = addon.db["eqolLayoutTools"]


function addon.LayoutTools.functions.addCharacterFrame(container)
    local f = CharacterFrame
    local fName = "CharacterFrame"

	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			var = "uiScaler" .. fName .. "Enabled",
			text = L["uiScaler" .. fName .. "Enabled"],
			type = "CheckBox",
			func = function(self, _, value)
				db["uiScaler" .. fName .. "Enabled"] = value
				if f and f:IsShown() then
					f:Hide()
					f:Show()
				end
				container:ReleaseChildren()
				addon.LayoutTools.functions.addCharacterFrame(container)
			end,
		},
		{
			var = "uiScaler" .. fName .. "Move",
			text = L["uiScaler" .. fName .. "Move"],
			type = "CheckBox",
			func = function(self, _, value)
				db["uiScaler" .. fName .. "Move"] = value
				if f and f:IsShown() then
					f:Hide()
					f:Show()
				end
			end,
		},
	}

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, db[cbData.var], cbData.func, desc)
		groupCore:AddChild(cbElement)
	end

	if db["uiScaler" .. fName .. "Enabled"] then
		local groupCoreSpell = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCoreSpell)
		groupCore:SetTitle(UI_SCALE)

		local sliderUITalents = addon.functions.createSliderAce("", db["uiScaler" .. fName .. "Frame"] or 1, 0.3, 1, 0.05, function(self, _, value2)
			db["uiScaler" .. fName .. "Frame"] = value2
			if f and f:IsShown() then f:SetScale(value2) end
		end)
		groupCoreSpell:AddChild(sliderUITalents)
	end
end
