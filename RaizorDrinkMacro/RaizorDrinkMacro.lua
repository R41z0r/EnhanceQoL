local parentAddonName = "Raizor"
local addonName, addon = ...
local drinkMacroName = "RaizorDrinkMacro"

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LDrinkMacro

local function createMacroIfMissing()
    if GetMacroInfo(drinkMacroName) == nil then
        CreateMacro(drinkMacroName, "INV_Misc_QuestionMark")
    end
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

function addon.updateAvailableDrinks(ignoreCombat)
    if (UnitAffectingCombat("Player") and ignoreCombat == false) or unitHasMana() == false then --on Combat do nothing, when no manaclass do nothing
        return
    end
    createMacroIfMissing()
    addDrinks()
end

--Extend the option menu
header = addon.functions.createHeader(addon.frame, addonName, 0,(-30*#addon.checkboxes-50))
local _, _, _, _, headerY = header:GetPoint()
local initialValue = 50
if addon.db["minManaFoodValue"] then
    initialValue = addon.db["minManaFoodValue"]
else
    addon.db["minManaFoodValue"] = initialValue
end
if nil == addon.db["preferMageFood"] then
    addon.db["preferMageFood"] = true
end

cbPreferMage = addon.functions.createCheckbox("preferMageFood", addon.frame, L["Prefer mage food"], 10, (headerY - header:GetHeight() - 10))
cbPreferMage:SetChecked(addon.db["preferMageFood"])

local _, _, _, _, headerY = cbPreferMage:GetPoint()
addon.functions.createSlider("minManaFoodValue",addon.frame, L["Minimum mana restore for food"], 15, (headerY - cbPreferMage:GetHeight() - 20), initialValue)

addon.updateAllowedDrinks()