local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Sound")

addon.variables.statusTable.groups["sound"] = true

local dungeonChildren = {}

local function capitalize(str) return (str:gsub("^%l", string.upper)) end

local function isPureNumbersTable(tbl)
	local isRun = false
	for _, v in pairs(tbl) do
		isRun = true
		if type(v) ~= "number" then return false end
	end
	if isRun then
		return true
	else
		return false
	end
end

-- Prüfen, ob alle Einträge reine Nummern‐Tabellen sind
local function allChildrenArePureNumbersTbl(tbl)
	local isRun = false
	for _, childValue in pairs(tbl) do
		isRun = true
		if type(childValue) ~= "table" or not isPureNumbersTable(childValue) then return false end
	end
	if isRun then
		return true
	else
		return false
	end
end

-- Rekursive Funktion zum Erstellen der Baumstruktur
local function buildDynamicTree(sourceTable)
	local tree = {}

	for key, value in pairs(sourceTable) do
		local nodeText = L[key] or capitalize(key)
		local nodeValue = key
		local fullValue = nodeValue
		if type(value) == "table" then
			if isPureNumbersTable(value) then
				-- 1) Endknoten: Reines Zahlenarray
				table.insert(tree, {
					text = nodeText,
					value = fullValue,
				})
			elseif allChildrenArePureNumbersTbl(value) then
				-- 2) Sonderfall: Dieser Knoten hat N Untereinträge, die ALLE reine Zahlenarrays sind
				-- --> Wir behandeln DAS hier als "Endknoten".
				table.insert(tree, {
					text = nodeText,
					value = fullValue,
				})
			else
				-- 3) "Normale" Verschachtelung
				local subChildren = buildDynamicTree(value)
				if #subChildren > 0 then table.insert(tree, {
					text = nodeText,
					value = fullValue,
					children = subChildren,
				}) end
			end
		elseif type(value) == "number" then
			-- Single number
			table.insert(tree, {
				text = nodeText,
				value = fullValue,
			})
		end
	end

	return tree
end

-- Baue die dynamische Baumstruktur basierend auf soundFiles
local dynamicChildren = buildDynamicTree(addon.Sounds.soundFiles)

--@debug@
table.insert(dynamicChildren, { value = "debug", text = "Debug" })
--@end-debug@

-- Übergib die dynamische Baumstruktur an addToTree
addon.functions.addToTree(nil, {
	value = "sound",
	text = SOUND,
	children = dynamicChildren,
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
		table.sort(sortedKeys, function(a, b)
			local lA = L[a] or a
			local lB = L[b] or b
			return lA < lB
		end) -- Alphabetisch sortieren

		local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
		container:AddChild(wrapper)

		local groupCore = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCore)

		for _, key in ipairs(sortedKeys) do
			local lKey = L[key] or key

			local cbElement = addon.functions.createCheckboxAce(lKey, addon.db["sounds_" .. group .. "_" .. key], function(self, _, value)
				addon.db["sounds_" .. group .. "_" .. key] = value
				toggleSounds(sounds[key], value)
			end)
			groupCore:AddChild(cbElement)
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
	container:ReleaseChildren()
	if group == "sound\001debug" then
		addDebugFrame(container)
		return
	end
	local partialGroup = string.gsub(group, "^sound\001", "")
	local segments = {}
	for segment in string.gmatch(partialGroup, "([^\001]+)") do
		table.insert(segments, segment)
	end

	local soundFileTable = addon.Sounds.soundFiles
	for _, seg in ipairs(segments) do
		if type(soundFileTable[seg]) == "table" then
			soundFileTable = soundFileTable[seg]
		else
			soundFileTable = nil
			break
		end
	end

	if soundFileTable then
		if isPureNumbersTable(soundFileTable) or allChildrenArePureNumbersTbl(soundFileTable) then
			local formattedGroup = string.gsub(partialGroup, "\001", "_")
			addClassFrame(container, formattedGroup, soundFileTable)
		end
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
