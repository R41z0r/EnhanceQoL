if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then
    return
end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Inscripción rápida"
L["Persist LFG signup note"] = "Persistir nota de inscripción LFG"
L["Select an option"] = "Seleccionar una opción"
L["Save"] = "Guardar"
