if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then
    return
end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Inscripción rápida"
L["Persist LFG signup note"] = "Persistir nota de inscripción LFG"
L["Select an option"] = "Seleccionar una opción"
L["Save"] = "Guardar"
L["Hide Minimap Button"] = "Ocultar botón del minimapa"
L["Left-Click to show options"] = "Clic izquierdo para mostrar opciones"

L["Hide Raid Tools"] = "Ocultar herramientas de banda en el grupo"
L["repairCost"] = "Objetos reparados por "
L["autoRepair"] = "Reparar automáticamente todos los objetos"
L["sellAllJunk"] = "Vender automáticamente todos los objetos basura"
L["ignoreTalkingHead"] = "Ocultar automáticamente el marco de Talking Head"

L["showIlvlOnCharframe"] = "Mostrar el nivel de objeto en el marco de equipo del personaje"
L["showGemsOnCharframe"] = "Mostrar ranuras de gemas en el marco de equipo del personaje"
L["showEnchantOnCharframe"] = "Mostrar encantamientos en el marco de equipo del personaje"

L["deleteItemFillDialog"] = "Agregar \"" .. COMMUNITIES_DELETE_CONFIRM_STRING ..
                                "\" al \"Popup de confirmación de eliminación\""
L["autoChooseQuest"] = "Aceptar y completar misiones automáticamente"

L["General"] = "General"
L["Character"] = "Personaje"
L["Dungeon"] = "Mazmorra"
L["Misc"] = "Varios"
L["Quest"] = "Misión"

-- Dungeon
L["autoChooseDelvePower"] = "Seleccionar poder de incursión automáticamente\ncuando solo hay 1 opción"

-- Quest
L["ignoreTrivialQuests"] = "Ignorar misiones triviales"
L["ignoreDailyQuests"] = "Ignorar misiones diarias/semanales"
