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

function addon.LayoutTools.functions.addTalentsSpellsFrame(container)
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
			var = "uiScalerPlayerSpellsFrameEnabled",
			text = L["uiScalerPlayerSpellsFrameEnabled"],
			type = "CheckBox",
			func = function(self, _, value)
				db["uiScalerPlayerSpellsFrameEnabled"] = value
				if PlayerSpellsFrame and PlayerSpellsFrame:IsShown() then
					PlayerSpellsFrame:Hide()
					PlayerSpellsFrame:Show()
				end
				container:ReleaseChildren()
				addon.LayoutTools.functions.addTalentsSpellsFrame(container)
			end,
		},
		{
			var = "uiScalerPlayerSpellsFrameMove",
			text = L["uiScalerPlayerSpellsFrameMove"],
			type = "CheckBox",
			func = function(self, _, value)
				db["uiScalerPlayerSpellsFrameMove"] = value
				if PlayerSpellsFrame and PlayerSpellsFrame:IsShown() then
					PlayerSpellsFrame:Hide()
					PlayerSpellsFrame:Show()
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

	if db["uiScalerPlayerSpellsFrameEnabled"] then
		local groupCoreSpell = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCoreSpell)
		groupCore:SetTitle(UI_SCALE)

		local sliderUITalents = addon.functions.createSliderAce(L["talentFrameUIScale"], db["uiScalerPlayerSpellsFrameFrame"] or 1, 0.3, 1, 0.05, function(self, _, value2)
			db["uiScalerPlayerSpellsFrameFrame"] = value2
			if PlayerSpellsFrame and PlayerSpellsFrame:IsShown() then PlayerSpellsFrame:SetScale(value2) end
		end)
		groupCoreSpell:AddChild(sliderUITalents)
	end
end
