local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.Sounds = {}
addon.Sounds.functions = {}
addon.Sounds.variables = {}
addon.LSounds = {} -- Locales for aura

addon.functions.InitDBValue("soundMutedSounds", {})

addon.Sounds.soundFiles = {
	["class"] = {
		["class_warlock"] = {
			["class_warlock_summon_imp"] = {
				-- 1255429,
				-- 1255430,
				-- 1255431,
				-- 1255432,
				-- 1255433,
				551168,
			},
			["class_warlock_succubus_butt_slap"] = {
				561144,
				1466150,
			},
			["class_warlock_summon_felguard"] = {
				547320,
				547328,
				547335,
				547332,
			},
			["class_warlock_summon_succubus"] = {
				561163,
				561168,
				561157,
				561154,
			},
			["class_warlock_summon"] = {
				2068351,
				2068352,
			},
		},
	},
	["dungeon"] = {
		["affix"] = {
			["xalatath"] = {
				5835214, -- And now you learn the true lesson of the void
				5770084, -- your ascension
				5834619, -- *laughing*
				5770087, -- is complete
				5834623, -- Oh he's alone
				5835726, -- The void consumes everything
				5835725, -- Inevitable

				5854706, -- Haha
				5835195, -- So Easily Overlooked
				5835215, -- Only The Strongest Survive
				2530811, -- Do You See It?
				2530835, -- A Stone To Call Forth The Darkness
				2530794, -- Open Your Mind To The Whispers
				5834632, -- Embrace Who You Truly Are
			},
		},
		["tww"] = {
			["stonevault"] = {
				["dagran_thaurissan_ii"] = {
					5835282, -- So here we are. High Speaker Eirich... or is it just Eirich now?
					5835283, -- He's fled from the Hall of Awakening into the Stonevault
					5835268, -- He's probably running like a frightened mouse. Wee, sleekit, cowering, timorous beastie!
				},
			},
		},
	},
	["mounts"] = {
		["banlu"] = {
			1593212, --Good to see you again, Grandmaster.
			1593213, --Lay off the manabuns.
			1593214, --Good luck, Grandmaster.
			1593215, --Farewell.
			1593216, --The lazy yak never gets washed.
			1593217, --Listen to all voices, Grandmaster. .
			1593218, --Idleness rarely leads to success, Grandmaster.
			1593219, --Is it much further, Grandmaster.
			1593220, --Remember to finish crossing the river
			1593221, --To speak of change without being willing taking action
			1593222, --A kite can not fly without the wind blowing against it.
			1593223, --The wise monk chooses their own style
			1593224, --The best time to plant a tree
			1593225, --Do not concern yourself
			1593226, --The wise brewmaster
			1593227, --Have a told you the tale of the hozen
			1593228, --Ah, a refreshing swim
			1593229, --Don't worry about me, Grandmanster
			1593230, --Filled with sorry
			1593231, --But in the mists of that reflection
			1593232, --You have show patience
			1593233, --It is clear you embody
			1593234, --Your skils are impressive
			1593236, --Where are we going today, Grandmaster
		},
		["grand_expedition_yak"] = {
			--Cousing Slowhands --
			--Greetings
			640336,
			640338,
			640340,
			--Farewell
			640314,
			640316,
			640318,
			640320,
			--Mystic Birdhat --
			--Greetings
			640180,
			640182,
			640184,
			--Farewell
			640158,
			640160,
			640162,
			640164,
		},
		["peafowl"] = {
			5546937,
			5546939,
			5546941,
			5546943,
		},
		["wonderwing_20"] = {
			2148660,
			2148661,
			2148662,
			2148663,
			2148664,
		},
		["mount_chopper"] = {
			569859,
			569858,
			569855,
			569857,
			569863,
			569856,
			569860,
			569862,
			569861,
			569854,
			569845,
			569852,
			598736,
			598745,
			598748,
			568252,
		},
		["mount_mimiron_head"] = {
			555364,
			595097,
			595100,
			595103,
		},
	},
	["spells"] = {
		["bloodlust"] = {
			568812, -- Bloodlust
			569013, -- Heroism
			569578, -- Timewarp
			569379, -- Timewarp
			568818, -- Timewarp
			569126, -- Timewarp
			568451, -- Timewarp
			4558551,
			4558553,
			4558555,
			4558557,
			4558559,
		},
	},
	["emotes"] = {
		["train"] = {
			--Orc --
			541239, --Male
			541157, --Female

			--Undead --
			542600, --Male
			542526, --Female

			--Tauren --
			542896, --Male
			542818, --Female

			--Troll --
			543093, --Male
			543085, --Female

			--Blood Elf --
			539203, --Male
			539219, --Female
			1306531, --Male Demon Hunter
			1313588, --Female Demon Hunter

			--Goblin --
			542017, --Male
			541769, --Female

			--Nightborne --
			1732405, --Male
			1732030, --Female

			--Highmountain Tauren --
			1730908, --Male
			1730534, --Female

			--Mag'har Orc --
			1951458, --Male
			1951457, --Female

			--Zandalari Troll --
			1903522, --Male
			1903049, --Female

			--Vulpera --
			3106717, --Male
			3106252, --Female

			--Pandaren --
			630296, --Male Train 01
			630298, --Male Train 02
			636621, --Female

			--Dracthyr --
			4737561, --Male Visage
			4738601, --Male Dragonkin
			4741007, --Female Visage
			4739531, --Female Dragonkin

			--Earthen --
			6021052, -- Female
			6021067, -- Male

			--Human --
			540734, --Male
			540535, --Female

			--Dwarf --
			539881, --Male
			539802, --Female

			--Night Elf --
			540947, --Male
			540870, --Female
			1304872, --Male Demon Hunter
			1316209, --Female Demon Hunter

			--Gnome --
			540275, --Male
			540271, --Female

			--Draenei --
			539730, --Male
			539516, --Female

			--Worgen --
			541601, --Male (Human Form)
			542206, --Male (Worgen Form)
			541463, --Female (Human Form)
			542035, --Female (Worgen Form)

			--Void Elf --
			1733163, --Male
			1732785, --Female

			--Lightforged Draenei --
			1731656, --Male
			1731282, --Female

			--Dark Iron Dwarf --
			1902543, --Male
			1902030, --Female

			--Kul Tiran Human --
			2491898, --Male
			2531204, --Female

			--Mechagnome --
			3107182, --Male
			3107651, --Female
		},
	},
	["interface"] = {
		["general"] = {
			["changeTab"] = {
				567422,
				567507,
				567433,
			},
			["enterQueue"] = {
				568587,
			},
			["readycheck"] = {
				567478,
			},
			["coinsound"] = {
				567428,
			},
			["mailboxopen"] = {
				567440,
			},
			["repair"] = {
				569801,
				569811,
				569792,
				569794,
				569821,
			},
		},
		["ping"] = {
			["ping_minimap"] = {
				567416,
			},
			["ping_warning"] = {
				5342387,
			},
			["ping_ping"] = {
				5339002,
			},
			["ping_assist"] = {
				5339006,
			},
			["ping_omw"] = {
				5340605,
			},
			["ping_attack"] = {
				5350036,
			},
		},
		["auctionhouse"] = {
			["open"] = {
				567482,
			},
			["close"] = { 567499 },
		},
	},
}
