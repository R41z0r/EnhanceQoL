if (GAME_LOCALE or GetLocale()) ~= "ptBR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Preferir comida de mago"
L["Minimum mana restore for food"] = "Restauro mínimo de mana para comida"
L["Ignore bufffood"] = 'Ignorar comida com "Bem Alimentado"'
L["Drink Macro"] = "Macro de beber"
L[addonName] = "Macro de beber"
L["ignoreGemsEarthen"] = "Ignorar as gemas de Joalheria para a raça Terranos"
L["mageFoodReminder"] = "Mostrar lembrete para obter comida de mago na masmorra de seguidores"
L["mageFoodReminderDesc"] = "Clique no lembrete para entrar automaticamente na fila da masmorra de seguidores"
L["mageFoodReminderText"] = "Obter comida de mago da masmorra de seguidores\n\nClique para entrar automaticamente na fila"
