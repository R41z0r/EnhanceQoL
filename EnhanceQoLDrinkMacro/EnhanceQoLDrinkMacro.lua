local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
local drinkMacroName = "EnhanceQoLDrinkMacro"

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LDrinkMacro

local function createMacroIfMissing()
	if GetMacroInfo(drinkMacroName) == nil then CreateMacro(drinkMacroName, "INV_Misc_QuestionMark") end
end

local function buildMacroString(item)
	local resetType = "combat"
	local itemsString = ""
	if item == nil then
		return "#showtooltip"
	else
		return "#showtooltip \n/castsequence reset=" .. resetType .. " " .. item
	end
end

local function unitHasMana()
	local maxMana = UnitPowerMax("Player", Enum.PowerType.Mana)
	return maxMana > 0
end

local function addDrinks()
	foundItem = nil
	for _, value in ipairs(addon.Drinks.filteredDrinks) do
		if value.getCount() > 0 then
			foundItem = value.getId()
			break
			-- We only need the highest manadrink
		end
	end
	EditMacro(drinkMacroName, drinkMacroName, nil, buildMacroString(foundItem))
end

function addon.functions.updateAvailableDrinks(ignoreCombat)
	if (UnitAffectingCombat("Player") and ignoreCombat == false) or unitHasMana() == false then -- on Combat do nothing, when no manaclass do nothing
		return
	end
	createMacroIfMissing()
	addDrinks()
end

local initialValue = 50
if addon.db["minManaFoodValue"] then
	initialValue = addon.db["minManaFoodValue"]
else
	addon.db["minManaFoodValue"] = initialValue
end

addon.functions.InitDBValue("preferMageFood", true)
addon.functions.InitDBValue("ignoreBuffFood", true)
addon.functions.InitDBValue("ignoreGemsEarthen", true)
addon.functions.updateAllowedDrinks()

local frameLoad = CreateFrame("Frame")
-- Registriere das Event
frameLoad:RegisterEvent("PLAYER_LOGIN")
frameLoad:RegisterEvent("PLAYER_REGEN_ENABLED")
frameLoad:RegisterEvent("PLAYER_LEVEL_UP")
frameLoad:RegisterEvent("BAG_UPDATE_DELAYED")
-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1, arg2, arg3, arg4)
	if event == "BAG_UPDATE_DELAYED" then
		addon.functions.updateAvailableDrinks(false)
	elseif event == "PLAYER_LOGIN" then
		-- on login always load the macro
		addon.functions.updateAllowedDrinks()
		addon.functions.updateAvailableDrinks(false)
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- PLAYER_REGEN_ENABLED always load, because we don't know if something changed in Combat
		addon.functions.updateAvailableDrinks(true)
	elseif event == "PLAYER_LEVEL_UP" and UnitAffectingCombat("player") == false then
		-- on level up, reload the complete list of allowed drinks
		addon.functions.updateAllowedDrinks()
		addon.functions.updateAvailableDrinks(true)
	end
end
-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

addon.functions.addToTree(nil, {
	value = "drink",
	text = L["Drink Macro"],
})

local function addDrinkFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{ text = L["Prefer mage food"], var = "preferMageFood" },
		{ text = L["Ignore bufffood"], var = "ignoreBuffFood" },
		{ text = L["ignoreGemsEarthen"], var = "ignoreGemsEarthen" },
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value)
			addon.db[cbData.var] = value
			addon.functions.updateAllowedDrinks()
			addon.functions.updateAvailableDrinks(false)
		end)
		groupCore:AddChild(cbElement)
	end

	local sliderManaMinimum = addon.functions.createSliderAce(L["Minimum mana restore for food"] .. ": " .. addon.db["minManaFoodValue"] .. "%", addon.db["minManaFoodValue"], 0, 100, 1, function(self, _, value2)
		addon.db["minManaFoodValue"] = value2
		addon.functions.updateAllowedDrinks()
		addon.functions.updateAvailableDrinks(false)
		self:SetLabel(L["Minimum mana restore for food"] .. ": " .. value2 .. "%")
	end)
	groupCore:AddChild(sliderManaMinimum)
end

function addon.Drinks.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	-- Prüfen, welche Gruppe ausgewählt wurde
	if group == "drink" then addDrinkFrame(container) end
end
