local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LSounds

addon.variables.statusTable.groups["sound"] = true

local dungeonChildren = {}

for i, v in pairs(addon.Sounds.soundFiles["dungeon"]) do
	if i == "affix" then
		table.insert(dungeonChildren, { text = L[i], value = i })
	else
		local subChilden = {}
		for dungeon in pairs(v) do
			print(dungeon)
			if L[dungeon] then table.insert(subChilden, { text = L[dungeon], value = dungeon }) end
		end
		if #subChilden and L[i] then table.insert(dungeonChildren, { text = L[i], value = i, children = subChilden }) end
	end
end

addon.functions.addToTree(nil, {
	value = "sound",
	text = SOUND,
	children = {
		-- { value = "general", text = ACCESSIBILITY_GENERAL_LABEL },
		-- { value = "toy", text = TOY },
		--@debug@
		{ value = "debug", text = "Debug" },
		--@end-debug@
		{ value = "mounts", text = MOUNT },
		{ value = "spells", text = SPELLS },
		{ value = "interface", text = INTERFACE_LABEL, children = { { value = "auctionhouse", text = BUTTON_LAG_AUCTIONHOUSE }, { value = "general", text = GENERAL } } },
		{ value = "emotes", text = CHAT_MSG_EMOTE },
		{ value = "dungeon", text = LFG_TYPE_DUNGEON, children = dungeonChildren },
		-- { value = "class", text = CLASS, children = { { value = "monk", text = "Monk" }, { value = "deathknight", text = "Death Knight" } } },
	},
}, true)

local AceGUI = addon.AceGUI

local function addDrinkFrame(container) end

local function toggleSounds(sounds, state)
	if type(sounds) == "table" then
		for _, v in pairs(sounds) do
			if state then
				MuteSoundFile(v)
			else
				UnmuteSoundFile(v)
			end
		end
	end
end

local function addClassFrame(container, group, sounds)
	if sounds then
		local sortedKeys = {}
		for key in pairs(sounds) do
			table.insert(sortedKeys, key)
		end
		table.sort(sortedKeys, function(a, b) return L[a] < L[b] end) -- Alphabetisch sortieren

		local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
		container:AddChild(wrapper)

		local groupCore = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCore)

		for _, key in ipairs(sortedKeys) do
			if L[key] then
				local cbElement = addon.functions.createCheckboxAce(L[key], addon.db["sounds_" .. group .. "_" .. key], function(self, _, value)
					addon.db["sounds_" .. group .. "_" .. key] = value
					toggleSounds(sounds[key], value)
				end)
				groupCore:AddChild(cbElement)
			end
		end
	end
end

--@debug@
local function addDebugFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local cbElement = addon.functions.createCheckboxAce("Enable Debug", addon.db["sounds_DebugEnabled"], function(self, _, value) addon.db["sounds_DebugEnabled"] = value end)
	groupCore:AddChild(cbElement)
end
--@end-debug@

local function addTWWFrame(container, group) addClassFrame() end

function addon.Sounds.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	if group == "sound\001class\001monk" then
		addClassFrame(container, "class_monk", addon.Sounds.soundFiles["class"]["monk"])
	elseif group == "sound\001debug" then
		addDebugFrame(container)
	elseif group == "sound\001dungeon\001affix" then
		addClassFrame(container, "dungeon_affix", addon.Sounds.soundFiles["dungeon"]["affix"])
	elseif string.match(group, "^sound\001dungeon\001") then
		local formattedGroup = string.gsub(string.gsub(group, "^sound\001", ""), "\001", "_")
		local segments = {}
		for segment in string.gmatch(formattedGroup, "[^_]+") do
			table.insert(segments, segment)
		end

		if #segments == 2 then return end
		local soundFileTable = addon.Sounds.soundFiles
		for _, segment in ipairs(segments) do
			if soundFileTable[segment] then
				soundFileTable = soundFileTable[segment]
			else
				soundFileTable = nil
				break
			end
		end

		if soundFileTable then addClassFrame(container, formattedGroup, soundFileTable) end
	elseif group == "sound\001toy" then
		addClassFrame(container, "toy")
	elseif group == "sound\001emotes" then
		addClassFrame(container, "emotes", addon.Sounds.soundFiles["emotes"])
	elseif group == "sound\001interface\001auctionhouse" then
		addClassFrame(container, "interface_auctionhouse", addon.Sounds.soundFiles["interface"]["auctionhouse"])
	elseif group == "sound\001interface\001general" then
		addClassFrame(container, "interface_general", addon.Sounds.soundFiles["interface"]["general"])
	elseif group == "sound\001mounts" then
		addClassFrame(container, "mounts", addon.Sounds.soundFiles["mounts"])
	elseif group == "sound\001spells" then
		addClassFrame(container, "spells", addon.Sounds.soundFiles["spells"])
	end
end

hooksecurefunc("PlaySound", function(soundID, channel, forceNoDuplicates)
	if addon.db["sounds_DebugEnabled"] then print("Sound played:", soundID, "on channel:", channel) end
end)

-- Hook für PlaySoundFile
hooksecurefunc("PlaySoundFile", function(soundFile, channel)
	if addon.db["sounds_DebugEnabled"] then print("Sound file played:", soundFile, "on channel:", channel) end
end)

for topic in pairs(addon.Sounds.soundFiles) do
	if topic == "emotes" then
	elseif topic == "spells" then
		for spell in pairs(addon.Sounds.soundFiles[topic]) do
			if addon.db["sounds_mounts_" .. spell] then toggleSounds(addon.Sounds.soundFiles[topic][spell], true) end
		end
	elseif topic == "mounts" then
		for mount in pairs(addon.Sounds.soundFiles[topic]) do
			if addon.db["sounds_mounts_" .. mount] then toggleSounds(addon.Sounds.soundFiles[topic][mount], true) end
		end
	else
		for class in pairs(addon.Sounds.soundFiles[topic]) do
			for key in pairs(addon.Sounds.soundFiles[topic][class]) do
				if addon.db["sounds_" .. topic .. "_" .. class .. "_" .. key] then toggleSounds(addon.Sounds.soundFiles[topic][class][key], true) end
			end
		end
	end
end
