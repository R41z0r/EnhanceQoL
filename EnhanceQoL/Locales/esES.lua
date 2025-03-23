if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Inscripción rápida"
L["interruptWithShift"] = "Mantén presionada la tecla Shift para interrumpir esta función"

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
L["showBindOnBagItems"] = "Muestra "
	.. _G.ITEM_BIND_ON_EQUIP
	.. " (BoE), "
	.. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP
	.. " (WuE) y "
	.. _G.ITEM_BNETACCOUNTBOUND
	.. " (WB) como añadido al nivel de objeto en los objetos"
L["showGemsTooltipOnCharframe"] = "Mostrar los huecos de gemas en el marco de equipamiento del personaje"
L["showEnchantOnCharframe"] = "Mostrar encantamientos en el marco de equipo del personaje"
L["showCatalystChargesOnCharframe"] = "Mostrar cargas del catalizador en el marco del equipo del personaje"
L["showIlvlOnBagItems"] = "Mostrar el nivel de objeto en el equipo en todas las bolsas"
L["showDurabilityOnCharframe"] = "Mostrar durabilidad en el marco de equipo del personaje"
L["hideOrderHallBar"] = "Ocultar barra de comandos de la sede"
L["showInfoOnInspectFrame"] = "Mostrar información adicional en el marco de inspección"
L["MissingEnchant"] = "Encantamiento"
L["hideHitIndicatorPlayer"] = "Ocultar el texto flotante de combate (daño y curación) sobre tu personaje"
L["hideHitIndicatorPet"] = "Ocultar el texto flotante de combate (daño y curación) sobre tu mascota"
L["UnitFrame"] = "Marco de unidad"
L["SellJunkIgnoredBag"] = "Has desactivado la venta de chatarra en %d bolsas.\nEsto puede impedir la venta automática de todos los objetos basura."

L["deleteItemFillDialog"] = 'Agregar "' .. DELETE_ITEM_CONFIRM_STRING .. '" al "Popup de confirmación de eliminación"'
L["confirmPatronOrderDialog"] = "Confirma automáticamente el uso de materiales propios en los pedidos de " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC
L["autoChooseQuest"] = "Aceptar y completar misiones automáticamente"
L["confirmTimerRemovalTrade"] = "Confirmar automáticamente la venta de botín comerciable durante el período de intercambio"

L["General"] = "General"
L["Character"] = "Personaje"
L["Dungeon"] = "Mazmorra"
L["Misc"] = "Varios"
L["Quest"] = "Misión"

L["hideBagsBar"] = "Ocultar barra de bolsas"
L["hideMicroMenu"] = "Ocultar micromenú"
-- Dungeon
L["autoChooseDelvePower"] = "Seleccionar poder de incursión automáticamente  cuando solo hay 1 opción"
L["lfgSortByRio"] = "Ordenar solicitantes de mazmorras míticas por puntuación mítica"
L["DungeonBrowser"] = "Explorador de mazmorras"
L["groupfinderAppText"] = 'Ocultar el texto del buscador de grupos "Tu grupo se está formando actualmente"'
L["groupfinderMoveResetButton"] = "Mueve el botón de restablecer filtro del buscador de mazmorras al lado izquierdo."
L["groupfinderSkipRoleSelect"] = "Omitir selección de rol"
L["groupfinderSkipRolecheckHeadline"] = "Asignación automática de rol"
L["groupfinderSkipRolecheckUseSpec"] = "Usar el rol de tu especialización actual (p. ej. Caballero de la Muerte (Sangre) = Tanque)"
L["groupfinderSkipRolecheckUseLFD"] = "Usar los roles seleccionados en el buscador"

-- Quest
L["ignoreTrivialQuests"] = "No gestionar automáticamente las " .. QUESTS_LABEL .. " triviales"
L["ignoreDailyQuests"] = "No gestionar automáticamente las " .. QUESTS_LABEL .. " diarias/semanales"
L["ignoreWarbandCompleted"] = "No gestionar automáticamente las " .. ACCOUNT_COMPLETED_QUEST_LABEL .. " " .. QUESTS_LABEL

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

L["autoAcceptGroupInvite"] = "Aceptar automáticamente las invitaciones de grupo"
L["autoAcceptGroupInviteGuildOnly"] = "Miembros de la hermandad"
L["autoAcceptGroupInviteFriendOnly"] = "Amigos"
L["autoAcceptGroupInviteOptions"] = "Aceptar invitaciones de..."

L["showLeaderIconRaidFrame"] = "Mostrar el icono de líder en los marcos de grupo con estilo de banda"

L["ActionbarHideExplain"] = 'Configura la barra de acción para que esté oculta y se muestre al pasar el ratón. Esto solo funciona si tu barra de acción está configurada en "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS"]
	.. '" y "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS"]
	.. '" en '
	.. _G["HUD_EDIT_MODE_MENU"]
	.. "."
