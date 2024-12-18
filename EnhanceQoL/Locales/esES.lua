if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then return end

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
L["showCatalystChargesOnCharframe"] = "Mostrar cargas del catalizador en el marco del equipo del personaje"
L["showIlvlOnBagItems"] = "Mostrar el nivel de objeto en el equipo en todas las bolsas"
L["showDurabilityOnCharframe"] = "Mostrar durabilidad en el marco de equipo del personaje"
L["hideOrderHallBar"] = "Ocultar barra de comandos de la sede"

L["deleteItemFillDialog"] = "Agregar \"" .. DELETE_ITEM_CONFIRM_STRING ..
                                "\" al \"Popup de confirmación de eliminación\""
L["autoChooseQuest"] = "Aceptar y completar misiones automáticamente"

L["General"] = "General"
L["Character"] = "Personaje"
L["Dungeon"] = "Mazmorra"
L["Misc"] = "Varios"
L["Quest"] = "Misión"

L["hideBagsBar"] = "Ocultar barra de bolsas"

-- Dungeon
L["autoChooseDelvePower"] = "Seleccionar poder de incursión automáticamente\ncuando solo hay 1 opción"
L["lfgSortByRio"] = "Ordenar solicitantes de mazmorras míticas por puntuación mítica"

-- Quest
L["ignoreTrivialQuests"] = "Ignorar misiones triviales"
L["ignoreDailyQuests"] = "Ignorar misiones diarias/semanales"

L["autoQuickLoot"] = "Saqueo rápido de objetos"
L["openCharframeOnUpgrade"] = "Abrir el marco del personaje al mejorar objetos con el mercader"

L["headerClassInfo"] = "Estas configuraciones solo se aplican a " .. select(1, UnitClass("player"))

-- Caballero de la Muerte
L["deathknight_HideRuneFrame"] = "Ocultar barra de runas"

-- Devastador
L["evoker_HideEssence"] = "Ocultar barra de esencias"

-- Monje
L["monk_HideHarmonyBar"] = "Ocultar barra de armonía"

-- Paladín
L["paladin_HideHolyPower"] = "Ocultar barra de poder sagrado"

-- Pícaro
L["rogue_HideComboPoint"] = "Ocultar barra de puntos de combo"

-- Chamán
L["shaman_HideTotem"] = "Ocultar barra de tótems"

-- Brujo
L["warlock_HideSoulShardBar"] = "Ocultar barra de fragmentos de alma"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Recarga de interfaz requerida"
L["bReloadInterface"] = "Debes recargar tu interfaz para aplicar los cambios"

L["CVarOptions"] =
    {["ShowClassColorInNameplate"] = {description = "Mostrar colores de clase en las placas de nombre", -- Activado = 1
    trueValue = "1", falseValue = "0"},
     ["chatMouseScroll"] = {description = "Habilitar el desplazamiento del ratón en el chat", -- Activado = 1
    trueValue = "1", falseValue = "0"},
     ["WholeChatWindowClickable"] = {description = "Hacer que toda la ventana del chat sea clicable", -- Activado = 1
    trueValue = "1", falseValue = "0"},
     ["showTutorials"] = {description = "Desactivar los tutoriales", -- Desactivado = 0
    trueValue = "0", falseValue = "1"},
     ["UberTooltips"] = {description = "Habilitar tooltips mejorados", -- Activado = 1
    trueValue = "1", falseValue = "0"},
     ["ffxDeath"] = {description = "Desactivar los efectos de muerte", -- Desactivado = 0
    trueValue = "0", falseValue = "1"}}
