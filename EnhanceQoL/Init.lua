local addonName, addon = ...
_G[addonName] = addon
addon.saveVariables = {} -- Cross-Module variables for DB Save

addon.variables = {}
addon.variables.numOfTabs = 0
addon.general = {}
addon.general.variables = {}
addon.general.variables.numOfTabs = 0
addon.L = {} -- Language

addon.variables.catalystID = 2813 -- Change to get the actual cataclyst charges in char frame

addon.variables.enchantString = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')

addon.variables.itemSlots = {[1] = CharacterHeadSlot, [2] = CharacterNeckSlot, [3] = CharacterShoulderSlot,
                             [15] = CharacterBackSlot, [5] = CharacterChestSlot, [9] = CharacterWristSlot,
                             [10] = CharacterHandsSlot, [6] = CharacterWaistSlot, [7] = CharacterLegsSlot,
                             [8] = CharacterFeetSlot, [11] = CharacterFinger0Slot, [12] = CharacterFinger1Slot,
                             [13] = CharacterTrinket0Slot, [14] = CharacterTrinket1Slot, [16] = CharacterMainHandSlot,
                             [17] = CharacterSecondaryHandSlot}

addon.variables.itemSlotSide = { -- 0 = Text to right side, 1 = Text to left side
[1] = 0, [2] = 0, [3] = 0, [15] = 0, [5] = 0, [9] = 0, [10] = 1, [6] = 1, [7] = 1, [8] = 1, [11] = 1, [12] = 1,
[13] = 1, [14] = 1, [16] = 1, [17] = 0}

addon.variables.allowedSockets = {["EMPTY_SOCKET_BLUE"] = true, ["EMPTY_SOCKET_COGWHEEL"] = true,
                                  ["EMPTY_SOCKET_CYPHER"] = true, ["EMPTY_SOCKET_DOMINATION"] = true,
                                  ["EMPTY_SOCKET_HYDRAULIC"] = true, ["EMPTY_SOCKET_META"] = true,
                                  ["EMPTY_SOCKET_NO_COLOR"] = true, ["EMPTY_SOCKET_PRIMORDIAL"] = true,
                                  ["EMPTY_SOCKET_PRISMATIC"] = true, ["EMPTY_SOCKET_PUNCHCARDBLUE"] = true,
                                  ["EMPTY_SOCKET_PUNCHCARDRED"] = true, ["EMPTY_SOCKET_PUNCHCARDYELLOW"] = true,
                                  ["EMPTY_SOCKET_RED"] = true, ["EMPTY_SOCKET_TINKER"] = true,
                                  ["EMPTY_SOCKET_YELLOW"] = true}

addon.variables.allowBagIlvlClassID = {[2] = true, [4] = true}
addon.variables.denyBagIlvlClassSubClassID = {[4] = {[5] = true}}
addon.variables.allowedEquipSlotsBagIlvl = { -- ["INVTYPE_NON_EQUIP_IGNORE"] = true,
["INVTYPE_HEAD"] = true, ["INVTYPE_NECK"] = true, ["INVTYPE_SHOULDER"] = true, ["INVTYPE_BODY"] = true,
["INVTYPE_CHEST"] = true, ["INVTYPE_WAIST"] = true, ["INVTYPE_LEGS"] = true, ["INVTYPE_FEET"] = true,
["INVTYPE_WRIST"] = true, ["INVTYPE_HAND"] = true, ["INVTYPE_FINGER"] = true, ["INVTYPE_TRINKET"] = true,
["INVTYPE_WEAPON"] = true, ["INVTYPE_SHIELD"] = true, ["INVTYPE_RANGED"] = true, ["INVTYPE_CLOAK"] = true,
["INVTYPE_2HWEAPON"] = true, -- ["INVTYPE_BAG"] = true,
-- ["INVTYPE_TABARD"] = true,
-- ["INVTYPE_ROBE"] = true,
["INVTYPE_WEAPONMAINHAND"] = true, ["INVTYPE_WEAPONOFFHAND"] = true, ["INVTYPE_HOLDABLE"] = true,
-- ["INVTYPE_AMMO"] = true,
-- ["INVTYPE_THROWN"] = true,
-- ["INVTYPE_RANGEDRIGHT"] = true,
-- ["INVTYPE_QUIVER"] = true,
-- ["INVTYPE_RELIC"] = true,
["INVTYPE_PROFESSION_TOOL"] = true, ["INVTYPE_PROFESSION_GEAR"] = true}
