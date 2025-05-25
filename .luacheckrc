std = "wow"
max_line_length = false
exclude_files = {
	"EnhanceQoLAura/EnhanceQoLAura.lua",
	"EnhanceQoLLayoutTools/EnhanceQoLLayoutTools.lua",
	".luacheckrc",
	"LibDataBroker-1.1.lua",
	"LibStub.lua",
	"CallbackHandler-1.0.lua",
	"EnhanceQoLAura.lua",
	"EnhanceQoLMythicPlus/DungeonFilter.lua",
	"EnhanceQoL/libs/LibOpenRaid/LibOpenRaid.lua",
	"EnhanceQoL/libs/AceDB-3.0/AceDB-3.0.lua",
	"EnhanceQoL/libs/AceDBOptions-3.0/AceDBOptions-3.0.lua",
	"EnhanceQoL/libs/AceConfig-3.0/AceConfig-3.0.lua",
	"EnhanceQoL/libs/AceConfig-3.0/AceConfigCmd-3.0/AceConfigCmd-3.0.lua",
	"EnhanceQoL/libs/AceConfig-3.0/AceConfigDialog-3.0/AceConfigDialog-3.0.lua",
	"EnhanceQoL/libs/AceConfig-3.0/AceConfigRegistry-3.0/AceConfigRegistry-3.0.lua",
	"LibStub.lua",
	"EnhanceQoL/libs/AceLocale-3.0/AceLocale-3.0.lua",
	"EnhanceQoL/libs/LibOpenRaid/Deprecated.lua",
	"EnhanceQoL/libs/LibOpenRaid/Functions.lua",
	"EnhanceQoL/libs/LibOpenRaid/GetPlayerInformation.lua",
	"EnhanceQoL/libs/LibOpenRaid/ThingsToMantain_Wrath.lua",
	"EnhanceQoL/libs/LibOpenRaid/ThingsToMantain_WarWithin.lua",
	"EnhanceQoL/libs/LibOpenRaid/ThingsToMantain_Shadowlands.lua",
	"EnhanceQoL/libs/LibOpenRaid/ThingsToMantain_Dragonflight.lua",
	"EnhanceQoL/libs/LibOpenRaid/ThingsToMantain_Era.lua",
	"EnhanceQoL/libs/LibOpenRaid/ThingsToMantain_Cata.lua",
}
ignore = {
	"11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
	"11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
	"113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"211", -- Unused local variable
	"211/L", -- Unused local variable "L"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"213", -- Unused loop variable
	"214", -- unused hint
	-- "231", -- Set but never accessed
	"311", -- Value assigned to a local variable is unused
	"314", -- Value of a field in a table literal is unused
	"42.", -- Shadowing a local variable, an argument, a loop variable.
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
	"542", -- An empty if branch
	"581", --  error-prone operator orders
	"582", --  error-prone operator orders
}
globals = {
    "EnhanceQoL",
    "EnhanceQoLDB",
    "EQOLBuffTrackerAnchor",
    "EQOLResourceFrame",
    "EQOLHealthBar",
    "EQOLAbsorbBar",
    "EQOLDungeonScoreFrame",
    "LibStub",
}
