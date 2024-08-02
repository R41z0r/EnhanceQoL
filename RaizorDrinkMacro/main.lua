local parentAddonName = "Raizor"
local addonName, addon = ...
local drinkMacroName = "RaizorDrinkMacro"

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end


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
