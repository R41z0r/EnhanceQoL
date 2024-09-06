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
        return "#showtooltip \n/castsequence reset=" .. resetType .. " " .. "item:" .. item
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
if nil == addon.db["preferMageFood"] then addon.db["preferMageFood"] = true end
if nil == addon.db["ignoreBuffFood"] then addon.db["ignoreBuffFood"] = true end
if nil == addon.db["ignoreGemsEarthen"] then addon.db["ignoreGemsEarthen"] = true end

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Drink Macro"])

local header = addon.functions.createHeader(frame, L[addonName], 0, -10)

local cbPreferMage = addon.functions.createCheckbox("preferMageFood", frame, L["Prefer mage food"], 10,
    (addon.functions.getHeightOffset(header) - 10))

cbPreferMage:SetScript("OnClick", function(self)
    addon.db["preferMageFood"] = self:GetChecked()
    addon.functions.updateAllowedDrinks()
    addon.functions.updateAvailableDrinks(false)
end)

local cbBuffFood = addon.functions.createCheckbox("ignoreBuffFood", frame, L["Ignore bufffood"], 10,
    (addon.functions.getHeightOffset(cbPreferMage)))

cbBuffFood:SetScript("OnClick", function(self)
    addon.db["ignoreBuffFood"] = self:GetChecked()
    addon.functions.updateAllowedDrinks()
    addon.functions.updateAvailableDrinks(false)
end)

local cbGemFoodEarthen = addon.functions.createCheckbox("ignoreGemsEarthen", frame, L["ignoreGemsEarthen"], 10,
    (addon.functions.getHeightOffset(cbBuffFood)))

cbGemFoodEarthen:SetScript("OnClick", function(self)
    addon.db["ignoreGemsEarthen"] = self:GetChecked()
    addon.functions.updateAllowedDrinks()
    addon.functions.updateAvailableDrinks(false)
end)

local sliderDrinkValue = addon.functions.createSlider("minManaFoodValue", frame, L["Minimum mana restore for food"], 15,
    (addon.functions.getHeightOffset(cbGemFoodEarthen) - 25), initialValue, 0, 100, "%")
sliderDrinkValue:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    _G[self:GetName() .. 'Text']:SetText(L["Minimum mana restore for food"] .. ': ' .. value .. "%")
    addon.db["minManaFoodValue"] = value
    addon.functions.updateAllowedDrinks()
    addon.functions.updateAvailableDrinks(false)
end)
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
