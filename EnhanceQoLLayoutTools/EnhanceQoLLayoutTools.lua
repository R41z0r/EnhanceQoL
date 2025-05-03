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

addon.variables.statusTable.groups["move"] = true

addon.functions.addToTree(nil, {
	value = "move",
	text = L["Move"],
	children = {
		{ value = "character", text = CHARACTER_BUTTON },
		{ value = "talentsspells", text = PLAYERSPELLS_BUTTON },
	},
})

function addon.LayoutTools.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	if group == "move\001talentsspells" then
		addon.LayoutTools.functions.addTalentsSpellsFrame(container)
	elseif group == "move\001character" then
		addon.LayoutTools.functions.addCharacterFrame(container)
	end
end

local eventHandlers = {
	["ADDON_LOADED"] = function(arg1)
		if arg1 == addonName then
			if C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then addon.LayoutTools.functions.createHooks(PlayerSpellsFrame, "playerSpellsFrame") end

			-- for i, v in pairs(addon.LayoutTools.variables.knownFrames) do
			-- 	if v then addon.LayoutTools.functions.createHooks(v, v:GetName()) end
			-- end
		elseif arg1 == "Blizzard_PlayerSpells" then
			addon.LayoutTools.functions.createHooks(PlayerSpellsFrame, "playerSpellsFrame")
		end
	end,
}

local function registerEvents(frame)
	for event in pairs(eventHandlers) do
		frame:RegisterEvent(event)
	end
end

local function eventHandler(self, event, ...)
	if eventHandlers[event] then eventHandlers[event](...) end
end
local frameLoad = CreateFrame("Frame")

registerEvents(frameLoad)
frameLoad:SetScript("OnEvent", eventHandler)
