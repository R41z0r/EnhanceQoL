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
if nil == addon.db["preferMageFood"] then
    addon.db["preferMageFood"] = true
end
if nil == addon.db["ignoreBuffFood"] then
    addon.db["ignoreBuffFood"] = true
end

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Drink Macro"])

local header = addon.functions.createHeader(frame, L[addonName], 0, -10)

local cbPreferMage = addon.functions.createCheckbox("preferMageFood", frame, L["Prefer mage food"], 10,
    (addon.functions.getHeightOffset(header) - 10))

local cbBuffFood = addon.functions.createCheckbox("ignoreBuffFood", frame, L["Ignore bufffood"], 10,
    (addon.functions.getHeightOffset(cbPreferMage)))

addon.functions.createSlider("minManaFoodValue", frame, L["Minimum mana restore for food"], 15,
    (addon.functions.getHeightOffset(cbBuffFood) - 20), initialValue, 0, 100, "%")

addon.functions.updateAllowedDrinks()
