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
L["landingPageHide"] = "Activa esta opción para ocultar el  botón de la página de expansión en el minimapa."
L["automaticallyOpenContainer"] = "Abrir automáticamente los objetos contenedores en la bolsa"

L["showIlvlOnBankFrame"] = "Mostrar el nivel de objeto en el banco"
L["showIlvlOnMerchantframe"] = "Mostrar el nivel de objeto en la ventana del comerciante"
L["showIlvlOnCharframe"] = "Mostrar el nivel de objeto en el marco de equipo del personaje"
L["showGemsOnCharframe"] = "Mostrar ranuras de gemas en el marco de equipo del personaje"
L["showGemsTooltipOnCharframe"] = "Mostrar los huecos de gemas en el marco de equipamiento del personaje"
L["showEnchantOnCharframe"] = "Mostrar encantamientos en el marco de equipo del personaje"
L["showCatalystChargesOnCharframe"] = "Mostrar cargas del catalizador en el marco del equipo del personaje"
L["showIlvlOnBagItems"] = "Mostrar el nivel de objeto en el equipo en todas las bolsas"
L["showDurabilityOnCharframe"] = "Mostrar durabilidad en el marco de equipo del personaje"
L["hideOrderHallBar"] = "Ocultar barra de comandos de la sede"
L["showInfoOnInspectFrame"] = "Mostrar información adicional en el marco de inspección (Experimental)"
L["MissingEnchant"] = "Encantamiento"
L["hideHitIndicatorPlayer"] = "Ocultar el texto flotante de combate (daño y curación) sobre tu personaje"
L["hideHitIndicatorPet"] = "Ocultar el texto flotante de combate (daño y curación) sobre tu mascota"
L["UnitFrame"] = "Marco de unidad"

L["deleteItemFillDialog"] = 'Agregar "' .. DELETE_ITEM_CONFIRM_STRING .. '" al "Popup de confirmación de eliminación"'
L["confirmPatronOrderDialog"] = "Confirma automáticamente el uso de materiales propios en los pedidos de " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC
L["autoChooseQuest"] = "Aceptar y completar misiones automáticamente"

L["General"] = "General"
L["Character"] = "Personaje"
L["Dungeon"] = "Mazmorra"
L["Misc"] = "Varios"
L["Quest"] = "Misión"

L["hideBagsBar"] = "Ocultar barra de bolsas"

-- Dungeon
L["autoChooseDelvePower"] = "Seleccionar poder de incursión automáticamente  cuando solo hay 1 opción"
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

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- Chamán
L["shaman_HideTotem"] = "Ocultar barra de tótems"

-- Brujo
L["warlock_HideSoulShardBar"] = "Ocultar barra de fragmentos de alma"

L["questAddNPCToExclude"] = "Añadir el PNJ objetivo/ventana de diálogo abierta a la lista de exclusión"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Recarga de interfaz requerida"
L["bReloadInterface"] = "Debes recargar tu interfaz para aplicar los cambios"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "Habilitar desmontaje automático al usar habilidades" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "Habilitar desmontaje automático al volar" },
	["chatMouseScroll"] = { description = "Habilitar desplazamiento del ratón en el chat", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "Desactivar efectos de muerte", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "Habilitar desvanecimiento del mapa al moverse" },
	["scriptErrors"] = { description = "Mostrar errores de LUA en la interfaz", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "Mostrar colores de clase en las placas de nombre", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "Mostrar la barra de lanzamiento de tu objetivo" },
	["showTutorials"] = { description = "Desactivar tutoriales", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "Habilitar tooltips avanzados", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "Mostrar la guilda en los jugadores" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "Mostrar el título en los jugadores" },
	["WholeChatWindowClickable"] = { description = "Hacer que toda la ventana de chat sea clicable", trueValue = "1", falseValue = "0" },
}
