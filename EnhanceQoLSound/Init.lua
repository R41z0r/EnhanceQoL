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
		["class_general"] = {
			["T33_Jackpot_Sound"] = { -- SoundID 283499
				6421997,
				6421999,
				6422001,
				6422003,
				6422005,
			},
		},
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
				2530794, -- Open your mind to the whispers
				2530811, -- Do you see it?
				2530835, -- A stone to call forth the darkness
				5770084, -- Your ascension
				5770087, -- Is complete
				5834619, -- *laughing* / haha #1
				5834623, -- Oh, he's alone / always alone
				5834632, -- Embrace who you truly are
				5835195, -- So easily overlooked
				5835211, -- Your survival wasn't necessary
				5835212, -- I simply wish you'd lasted a little longer
				5835214, -- And now you learn the true lesson of the void
				5835215, -- Only the strongest survive
				5835725, -- Inevitable
				5835726, -- The void consumes everything
				5835729, -- Deeper in the darkness
				5854705, -- Too late (timer over)
				5854706, -- Haha #2
				6178494, -- My emissary brings you power
				6178497, -- A willing sacrifice
				6178498, -- Yes, feed
				6178500, -- Shred of control
				6178502, -- Resist
				6178504, -- Overcome this trial
				6178506, -- My power is transcendent
				6178508, -- A gift of power
			},
		},
		["tww"] = {
			["rookery_npc"] = {
				-- Stormrider Vokmar
				5858404,
				5858470,
				5858471,
				5858472,
				5858473,
				5858474,
				5858478,
				5858481,
				5858482,
				5858485,
			},
			["priory_of_the_sacred_flame_npc"] = {
				-- Sister Etna Blayze
				5839837,
				5839839,
				5839840,
				5839841,
				5839846,
				5839847,
				5839853,
				5839854,
				5839855,
				5839860,
				5839861,
			},
			["cinderbrew_meadery_npc"] = {
				5769388,
				5769390,
				5769391,
				5769395,
				5769396,
				5769397,
				5769400,
				5779635,
				5858873,
				5858874,
				5858875,
				5858882,
				5858888,
				5858889,
				5858890,
				5858891,
				5858892,
				5858893,
				5858894,
				5858895,
				5858896,
				5858897,
				5858898,
			},
			["mechagon_npc"] = {
				-- Prince Erazmin
				2931350,
				2931351,
				2931352,
				2931353,
				2931356, --
				2931435, -- In order to stop my father, we need to infiltrate
				2931438, -- Do not allow these bots to detect you
				2931439, -- Remaining within their steam
				2931441, -- You are no longer my father

				-- Gazlowe
				2931354,
				2931355,

				-- Tussle Tonks Announcer
				2925336,
				2925337,
				2925338,
				2925339,
				2925340,
				2925341,
				2925342,
				2925343,
				2925345,
				2925346,
				2925347,
				2925348,
				2925351,
				2925352,
				2925353,
				2925354,
				2925355,
				2925356,
				2925357,
				2925358,
				2925359,
				2925360,
			},
			["stonevault"] = {
				5835282, -- So here we are. High Speaker Eirich... or is it just Eirich now?
				5835283, -- He's fled from the Hall of Awakening into the Stonevault
				5835268, -- He's probably running like a frightened mouse. Wee, sleekit, cowering, timorous beastie!
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
			1593235, --Let us return to the wandering
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
		["mount_the_dreadwake"] = {
			-- Horn
			566064,

			-- Bell
			1838477,

			-- WaterSplash Dismount
			2066773,
			2066774,
			2066775,
			2066776,
			2066777,

			-- WaterSplash Mount
			2066768,
			2066769,
			2066770,
			2066771,
			2066772,
		},
		["mount_storm_gryphon"] = {
			-- Mount
			5356559,
			5356561,
			5356563,
			5356565,
			5356567,
			5356569,
			5356571,

			-- Thunder
			3088094,

			-- Mountspecial
			5357752,
			5357769,
			5357771,
			5357773,
			5357775,
		},
		["mount_g99_breakneck"] = {
			-- Movement
			2431461,
			2431464,
			2431465,

			-- Summon
			1487173,
			1487174,
			1487175,
			1487176,
			1487177,
			1487178,
			1487179,
			1487180,
			1487181,
			1487182,

			-- Engine start
			1659508,
			1659509,
			1659510,
			1659511,

			-- Gear shift broken
			2138705,

			-- Engine running
			6254769,
			6382128,
			6382130,
			6382181,
			6382183,
			6382185,
			6382187,
			6382189,
			6382191,
			6382193,

			-- Drifting
			6654849,
			6654851,
			6654853,
			6654855,
			6654857,
			6654859,
			6654861,
			6654863,
			6654865,
			6654867,
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
			4567038, -- Timewarp
			4567040, -- Timewarp
			4567042, -- Timewarp
			1416760, -- Timewarp
			1416761, -- Timewarp
			1416762, -- Timewarp
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
	["professions"] = {
		["skinning"] = {
			-- Soundkit 3781
			567454,
			567494,
			567417,
		},
		["herbalism"] = {
			-- Soundkit 1142
			569824,
			569825,
			569797,
			569818,
		},
		["mining"] = {
			-- Soundkit 1143
			569801,
			569811,
			569792,
			569794,
			569821,
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
			["summoning_stone"] = {
				-- Soundkit 3136 for loop sound
				568938,
				-- Soundkit 119083 for first Sound on portal open
				1684459,
				1684460,
				1684461,
				1684462,
				1684463,
			},
		},
		["chat"] = {
			["whisper"] = {
				-- Soundkit 3081
				567421,
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
		["quest"] = {
			["quest_complete"] = {
				-- Soundkit 619
				567439,
			},
		},
		["auctionhouse"] = {
			["open"] = {
				567482,
			},
			["close"] = { 567499 },
		},
	},
	["misc"] = {
		["eating"] = {
			-- Soundkit 45
			567612,
		},
	},
}
