local parentAddonName = "Raizor"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local function newItem(id, name)
    local self = {}

    self.id = id
    self.name = name

    local function setName()
        local itemInfoName = GetItemInfo(self.id)
        if itemInfoName ~= nil then
            self.name = itemInfoName
        end
    end

    function self.getId()
        return self.id
    end

    function self.getName()
        return self.name
    end

    function self.getCount()
        return GetItemCount(self.id, false, false)
    end

    return self
end

function addon.updateAllowedDrinks()
    local playerLevel = UnitLevel("Player")
    local mana = UnitPowerMax("player", 0)
    if mana <= 0 then return end

    local minManaValue = mana * (addon.db["minManaFoodValue"] / 100)

    addon.Drinks = {}
    addon.Drinks.filteredDrinks = {} --Used for the filtered List later

    addon.Drinks.drinkList = {
        --Dragonflight
        { key = "ConjuredManaBun", id = 113509, requiredLevel = 40, mana = mana, isMageFood = true }, 
        { key = "GorlocFinSoup", id = 197847, requiredLevel = 70, mana = 240000 },

        --Raizor Query
        { key = "AzureLeywine", id = 194684, requiredLevel = 65, mana = 375000 },
        { key = "Crusader'sWaterskin", id = 42777, requiredLevel = 27, mana = 28343 },
        { key = "ApexisAsiago", id = 201419, requiredLevel = 65, mana = 240000 },
        { key = "BlackrockFortifiedWater", id = 38431, requiredLevel = 27, mana = 3542 },
        { key = "BreakfastofDraconicChampions", id = 197763, requiredLevel = 65, mana = 428571 },
        { key = "BiscuitsandCaviar", id = 172046, requiredLevel = 50, mana = 36000 },
        { key = "Buttermilk", id = 194683, requiredLevel = 65, mana = 375000 },
        { key = "'Bottled'Ley-EnrichedWater", id = 140204, requiredLevel = 42, mana = 20000 },
        { key = "ChunTianSpringRolls", id = 74656, requiredLevel = 35, mana = 5500 },
        { key = "BanquetoftheBrew", id = 87246, requiredLevel = 35, mana = 20000 },
        { key = "AcornMilk", id = 196584, requiredLevel = 60, mana = 225000 },
        { key = "Bil'Tong", id = 168314, requiredLevel = 45, mana = 30769 },
        { key = "BlackCoffee", id = 33042, requiredLevel = 27, mana = 3542 },
        { key = "BioluminescentOceanPunch", id = 169949, requiredLevel = 45, mana = 24000 },
        { key = "BlackrockMineralWater", id = 38430, requiredLevel = 25, mana = 5037 },
        { key = "ClefthoofMilk", id = 117475, requiredLevel = 35, mana = 8500 },
        { key = "CrocoliskAuGratin", id = 62664, requiredLevel = 30, mana = 3840 },
        { key = "BlackDragonRedEye", id = 201698, requiredLevel = 65, mana = 375000 },
        { key = "CoboCola", id = 81923, requiredLevel = 35, mana = 5500 },
        { key = "BlackenedDragonfin", id = 42999, requiredLevel = 27, mana = 4267 },
        { key = "BananaBeefPudding", id = 172069, requiredLevel = 55, mana = 120000 },
        { key = "BarracudaMrglgagh", id = 133567, requiredLevel = 40, mana = 14423 },
        { key = "BakedVoidfin", id = 174352, requiredLevel = 0, mana = 30769 },
        { key = "BakedRockfish", id = 62661, requiredLevel = 30, mana = 3840 },
        { key = "BanquetofthePot", id = 87234, requiredLevel = 35, mana = 20000 },
        { key = "BubblingWater", id = 9451, requiredLevel = 7, mana = 216 },
        { key = "BeetleJuice", id = 205794, requiredLevel = 65, mana = 375000 },
        { key = "BlackrockHam", id = 111433, requiredLevel = 35, mana = 8500 },
        { key = "BearTartare", id = 133576, requiredLevel = 40, mana = 14423 },
        { key = "ColdarraColdbrew", id = 201697, requiredLevel = 65, mana = 375000 },
        { key = "AmbroriaDew", id = 177040, requiredLevel = 55, mana = 120000 },
        { key = "ClefthoofSausages", id = 111438, requiredLevel = 35, mana = 8500 },
        { key = "BanquetoftheGrill", id = 87226, requiredLevel = 30, mana = 20000 },
        { key = "ChurnbellyTea", id = 197772, requiredLevel = 60, mana = 428571 },
        { key = "CriticalCatfish", id = 143634, requiredLevel = 40, mana = 14423 },
        { key = "CranialConcoction", id = 178542, requiredLevel = 50, mana = 50000 },
        { key = "AzuremystWaterFlask", id = 152717, requiredLevel = 45, mana = 20000 },
        { key = "CalamariCrepes", id = 111453, requiredLevel = 35, mana = 8500 },
        { key = "BanquetoftheWok", id = 87230, requiredLevel = 35, mana = 20000 },
        { key = "ChilledConjuredWater", id = 128850, requiredLevel = 42, mana = 20000 },
        { key = "BanquetoftheOven", id = 87242, requiredLevel = 35, mana = 20000 },
        { key = "CinnamonBonefishStew", id = 172044, requiredLevel = 50, mana = 36000 },
        { key = "BraisedRiverbeast", id = 111436, requiredLevel = 35, mana = 8500 },
        { key = "BasiliskLiverdog", id = 62665, requiredLevel = 30, mana = 3840 },
        { key = "BoralusBloodSausage", id = 166804, requiredLevel = 45, mana = 23076 },
        { key = "Bottled-CarbonatedWater", id = 140340, requiredLevel = 32, mana = 3666 },
        { key = "CorpiniSlurry", id = 178534, requiredLevel = 50, mana = 50000 },
        { key = "BeetleJuice", id = 178538, requiredLevel = 50, mana = 50000 },
        { key = "BottledMaelstrom", id = 140629, requiredLevel = 42, mana = 20000 },
        { key = "BoneAppleTea", id = 178545, requiredLevel = 55, mana = 120000 },
        { key = "BraisedTurtle", id = 74649, requiredLevel = 33, mana = 20000 },
        { key = "AzurebloomTea", id = 178217, requiredLevel = 55, mana = 120000 },
        { key = "ButteredSturgeon", id = 122348, requiredLevel = 35, mana = 8500 },
        { key = "ArtisanalBerryJuice", id = 194691, requiredLevel = 60, mana = 225000 },
        { key = "CandiedAmberjackCakes", id = 172047, requiredLevel = 55, mana = 120000 },
        { key = "BlackPepperRibsandShrimp", id = 74646, requiredLevel = 35, mana = 5500 },
        { key = "BlackTea", id = 90660, requiredLevel = 7, mana = 216 },
        { key = "BlackbellySushi", id = 62668, requiredLevel = 30, mana = 3840 },
        { key = "Abyssal-FriedRissole", id = 168311, requiredLevel = 0, mana = 30769 },
        { key = "CanteenofRivermarshRainwater", id = 163785, requiredLevel = 25, mana = 24000 },
        { key = "BlackrockSpringWater", id = 38429, requiredLevel = 20, mana = 1350 },
        { key = "ArgaliMilk", id = 195459, requiredLevel = 60, mana = 225000 },
        { key = "Beer-BastedCrocolisk", id = 62670, requiredLevel = 30, mana = 3840 },
        { key = "BitterPlasma", id = 38698, requiredLevel = 25, mana = 5036 },
        { key = "CookedCrabClaw", id = 2682, requiredLevel = 3, mana = 212 },
        { key = "BlendedBeanBrew", id = 17404, requiredLevel = 3, mana = 378 },
        { key = "BottledStillwater", id = 155909, requiredLevel = 7, mana = 216 },
        { key = "AzshariSalad", id = 133571, requiredLevel = 40, mana = 14423 },
        { key = "BlackJelly", id = 45932, requiredLevel = 28, mana = 8534 },
        { key = "BakedMantaRay", id = 42942, requiredLevel = 27, mana = 4267 },
        { key = "'Natural'HighmountainSpringWater", id = 140203, requiredLevel = 37, mana = 8500 },
        { key = "CarbonatedWater", id = 81924, requiredLevel = 32, mana = 3666 },
        { key = "BakedPortTato", id = 168313, requiredLevel = 45, mana = 30769 },
        { key = "Barter-B-Q", id = 205690, requiredLevel = 65, mana = 240000 },
        { key = "ArcberryJuice", id = 141215, requiredLevel = 42, mana = 15000 },
        { key = "ArcanostabilizedProvisions", id = 201047, requiredLevel = 65, mana = 240000 },
        { key = "CharbroiledTigerSteak", id = 74642, requiredLevel = 32, mana = 2236 },
        { key = "BottledWinterspringWater", id = 19300, requiredLevel = 15, mana = 630 },
        { key = "AncientFirewine", id = 197849, requiredLevel = 60, mana = 225000 },
        { key = "BanquetoftheSteamer", id = 87238, requiredLevel = 35, mana = 20000 },
        { key = "ButterscotchMarinatedRibs", id = 172040, requiredLevel = 50, mana = 36000 },
        { key = "BountifulCaptain'sFeast", id = 156526, requiredLevel = 45, mana = 23076 },
        { key = "BroiledMountainTrout", id = 62655, requiredLevel = 30, mana = 1800 },
        { key = "CatalyzedApplePie", id = 190880, requiredLevel = 55, mana = 120000 },
        { key = "BlackrockBarbecue", id = 111449, requiredLevel = 35, mana = 8500 },
        { key = "Cupo'Wakeup", id = 197856, requiredLevel = 65, mana = 375000 },
        { key = "CircleofSubsistence", id = 190881, requiredLevel = 55, mana = 120000 },
        { key = "EnchantedArgaliTenderloin", id = 197854, requiredLevel = 65, mana = 240000 },
        { key = "FieryCalamari", id = 111445, requiredLevel = 35, mana = 8500 },
        { key = "FaronaarFizz", id = 133563, requiredLevel = 40, mana = 14423 },
        { key = "FrostyStew", id = 111450, requiredLevel = 35, mana = 8500 },
        { key = "DracthyrWaterRations", id = 200305, requiredLevel = 58, mana = 225000 },
        { key = "Freeze-DriedHyenaJerky", id = 98116, requiredLevel = 32, mana = 4473 },
        { key = "FreshAppleJuice", id = 43086, requiredLevel = 25, mana = 5036 },
        { key = "DrustvarDarkRoast", id = 163101, requiredLevel = 35, mana = 18000 },
        { key = "EternalBlossomFish", id = 74645, requiredLevel = 33, mana = 20000 },
        { key = "DubiousDelight", id = 174350, requiredLevel = 0, mana = 30769 },
        { key = "ExtraFancyDarkmoonFeast", id = 184690, requiredLevel = 1, mana = 138461 },
        { key = "Elemental-DistilledWater", id = 128385, requiredLevel = 35, mana = 8500 },
        { key = "DelectableOgreQueasine", id = 104196, requiredLevel = 35, mana = 4473 },
        { key = "FamineEvaluatorAndSnackTable", id = 168315, requiredLevel = 45, mana = 30769 },
        { key = "FreshWater", id = 58274, requiredLevel = 27, mana = 28343 },
        { key = "FeastoftheWaters", id = 111458, requiredLevel = 35, mana = 8500 },
        { key = "FreshlySqueezedMosswater", id = 204729, requiredLevel = 65, mana = 375000 },
        { key = "DalaranClamChowder", id = 43268, requiredLevel = 27, mana = 4267 },
        { key = "DeliciousDragonSpittle", id = 197771, requiredLevel = 65, mana = 428571 },
        { key = "FrenzyandChips", id = 195466, requiredLevel = 65, mana = 240000 },
        { key = "EnrichedTeroconeJuice", id = 32722, requiredLevel = 26, mana = 5037 },
        { key = "EmpyreanFruitSalad", id = 174284, requiredLevel = 55, mana = 120000 },
        { key = "FighterChow", id = 133577, requiredLevel = 40, mana = 14423 },
        { key = "FizzyFaireDrink", id = 19299, requiredLevel = 7, mana = 216 },
        { key = "DeepFriedSeraphTenders", id = 182737, requiredLevel = 55, mana = 120000 },
        { key = "Free-RangeGoat'sMilk", id = 159868, requiredLevel = 35, mana = 18000 },
        { key = "DriedMackerelStrips", id = 133575, requiredLevel = 40, mana = 15000 },
        { key = "FrozenSolidTea", id = 202315, requiredLevel = 65, mana = 375000 },
        { key = "Eternity-InfusedBurrata", id = 201413, requiredLevel = 65, mana = 240000 },
        { key = "FortuneCookie", id = 62649, requiredLevel = 30, mana = 3840 },
        { key = "EmptyKettleofStoneSoup", id = 187648, requiredLevel = 60, mana = 138461 },
        { key = "FeastoftheFishes", id = 152564, requiredLevel = 1, mana = 14423 },
        { key = "GalleyBanquet", id = 156525, requiredLevel = 45, mana = 11538 },
        { key = "FeastofGluttonousHedonism", id = 172043, requiredLevel = 60, mana = 138461 },
        { key = "EmeraldGreenApple", id = 201469, requiredLevel = 65, mana = 240000 },
        { key = "Farmer'sDelight", id = 101747, requiredLevel = 35, mana = 5500 },
        { key = "FilteredDraenicWater", id = 28399, requiredLevel = 10, mana = 5037 },
        { key = "FragrantKakavia", id = 168312, requiredLevel = 45, mana = 30769 },
        { key = "FilteredGloomwater", id = 163786, requiredLevel = 35, mana = 24000 },
        { key = "FilteredZanj'irWater", id = 169948, requiredLevel = 45, mana = 18000 },
        { key = "EtherealPomegranate", id = 173859, requiredLevel = 55, mana = 120000 },
        { key = "DosOgris", id = 32668, requiredLevel = 27, mana = 3542 },
        { key = "FatSleeperCakes", id = 111444, requiredLevel = 35, mana = 8500 },
        { key = "Fresh-SqueezedLimeade", id = 44941, requiredLevel = 25, mana = 5036 },
        { key = "FungusSqueezings", id = 59230, requiredLevel = 30, mana = 6710 },
        { key = "GhastlyGoulash", id = 174349, requiredLevel = 0, mana = 30769 },
        { key = "Flappuccino", id = 201725, requiredLevel = 65, mana = 375000 },
        { key = "FishFeast", id = 43015, requiredLevel = 27, mana = 4267 },
        { key = "DeluxeNoodleCartKit", id = 101661, requiredLevel = 35, mana = 5500 },
        { key = "DreamwardingDripbrew", id = 201046, requiredLevel = 65, mana = 375000 },
        { key = "DistilledFishJuice", id = 194692, requiredLevel = 60, mana = 225000 },
        { key = "Enhancement-FreeWater", id = 169120, requiredLevel = 45, mana = 18000 },
        { key = "DragonspringWater", id = 194685, requiredLevel = 65, mana = 375000 },
        { key = "FeastofBlood", id = 111457, requiredLevel = 35, mana = 8500 },
        { key = "EnhancedWater", id = 169119, requiredLevel = 45, mana = 18000 },
        { key = "FriedTurtleBits", id = 158926, requiredLevel = 45, mana = 12000 },
        { key = "FishbrulSpecial", id = 133574, requiredLevel = 40, mana = 14423 },
        { key = "FunkyMonkeyBrew", id = 105711, requiredLevel = 32, mana = 5500 },
        { key = "FishRoe", id = 118416, requiredLevel = 35, mana = 8500 },
        { key = "DragonfinFilet", id = 43000, requiredLevel = 27, mana = 4267 },
        { key = "FireSpiritSalmon", id = 74652, requiredLevel = 33, mana = 20000 },
        { key = "EarlBlackTea", id = 49602, requiredLevel = 3, mana = 378 },
        { key = "FrostberryJuice", id = 37253, requiredLevel = 27, mana = 3542 },
        { key = "EnchantedWater", id = 4791, requiredLevel = 11, mana = 270 },
        { key = "FlaskofArdendew", id = 173762, requiredLevel = 50, mana = 50000 },
        { key = "DeliciousSagefishTail", id = 62666, requiredLevel = 30, mana = 3840 },
        { key = "FluffySilkfeatherOmelet", id = 101750, requiredLevel = 35, mana = 5500 },
        { key = "Deep-FriedMossgill", id = 133561, requiredLevel = 40, mana = 14423 },
        { key = "Ethermead", id = 29395, requiredLevel = 27, mana = 3542 },
        { key = "EnrichedMannaBiscuit", id = 13724, requiredLevel = 20, mana = 1927 },
        { key = "FirecrackerSalmon", id = 34767, requiredLevel = 27, mana = 4267 },
        { key = "Cuttlesteak", id = 42998, requiredLevel = 27, mana = 4267 },
        { key = "FriedBonefish", id = 172063, requiredLevel = 55, mana = 120000 },
        { key = "Drogbar-StyleSalmon", id = 133569, requiredLevel = 40, mana = 14423 }
    }

    table.sort(addon.Drinks.drinkList, function(a, b)
        return a.mana > b.mana
    end)

    for _, drink in ipairs(addon.Drinks.drinkList) do
        if (drink.requiredLevel >= 0 and drink.requiredLevel <= playerLevel) and (drink.mana >= minManaValue) then
            if drink.isMageFood and nil ~= addon.db["preferMageFood"] and addon.db["preferMageFood"] == true then
                table.insert(addon.Drinks.filteredDrinks, 1, newItem(drink.id, drink.desc)) 
            else
                table.insert(addon.Drinks.filteredDrinks, newItem(drink.id, drink.desc)) 
            end
        end
    end
end