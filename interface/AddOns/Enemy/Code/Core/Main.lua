local tinsert = table.insert
local g = {}

function Enemy.Initialize ()

	if (not Enemy.Settings) then
		Enemy.Settings = {}
	end

	Enemy.Settings.prevVersion = Enemy.isNil (Enemy.Settings.version, 0)
	Enemy.extendTable (Enemy.Settings, Enemy.DefaultSettings)
	Enemy.Settings.version = Enemy.DefaultSettings.version

	-- some global data
	Enemy.playerName = Enemy.FixString (GameData.Player.name)
	table.sort (Enemy.Fonts)

	Enemy.latestTargets = {}

	-- core initialization
	Enemy.EventsInitialize ()
	Enemy.LocalizationInitialize ()
	Enemy.StateMachineInitialize ()

	Enemy.initialized = false

	RegisterEventHandler (SystemData.Events.PLAYER_CAREER_LINE_UPDATED, "Enemy._PlayerCareerLineUpdated")
	RegisterEventHandler (SystemData.Events.INTERFACE_RELOADED, "Enemy._Initialize")
end


function Enemy._PlayerCareerLineUpdated ()

	if (not GameData.Player.career or not GameData.Player.career.line or GameData.Player.career.line < 1) then return end

	Enemy._Initialize ()
	UnregisterEventHandler (SystemData.Events.PLAYER_CAREER_LINE_UPDATED, "Enemy._PlayerCareerLineUpdated")
end


function Enemy._Initialize ()

	if (Enemy.initialized
		or not GameData.Player.career
		or not GameData.Player.career.line
		or GameData.Player.career.line < 1) then return end

	-- core initialization
	Enemy.ObjectWindowsInitialize ()
	Enemy.CommunicationInitialize ()
	Enemy.GroupsInitialize ()
	Enemy.ConfigurationWindowInitialize ()

	-- UI: icon window
	CreateWindow ("EnemyIcon", true)
	LayoutEditor.RegisterWindow ("EnemyIcon", L"Enemy icon", L"Enemy icon", false, false, true, nil)

	-- UI: choose icon dialog
	CreateWindow ("EnemyChooseIconDialog", false)

	-- UI: debug
	if (Enemy.Settings.debug)
	then
		g.debug = {}

		CreateWindow ("EnemyDebug", true)
		WindowSetTintColor ("EnemyDebugBackground", 0, 0, 0)
		WindowSetAlpha ("EnemyDebugBackground", 0.3)
		LayoutEditor.RegisterWindow ("EnemyDebug", L"Enemy debug", L"Enemy debug", false, false, true, nil)
	end

	-- plugins initialization
	--Enemy.IntercomInitialize ()
	--Enemy.AssistInitialize ()
	--Enemy.KillSpamInitialize ()
	Enemy.MarksInitialize ()
	Enemy.UnitFramesInitialize ()
	Enemy.GroupIconsInitialize ()
	--Enemy.GuardInitialize ()
	--Enemy.ScenarioAlerterInitialize ()
	--Enemy.ScenarioInfoInitialize ()
	--Enemy.TalismanAlerterInitialize ()
	--Enemy.TimerInitialize ()
	--Enemy.CombatLogInitialize ()


	-- events
	RegisterEventHandler (SystemData.Events.PLAYER_TARGET_UPDATED, "Enemy.OnPlayerTargetUpdated")

	-- some global game tune-up
	WindowSetMovable ("DeathWindow", true)
	WindowSetScale ("DeathWindow", 0.75)

	WindowSetMovable ("EA_Window_CityCaptureJoinPromptWindow", true)
	WindowSetScale ("EA_Window_CityCaptureJoinPromptWindow", 0.85)

	-- notify about initialization phase ended
	Enemy.initialized = true
	Enemy.TriggerEvent ("AllInitialized")

	-- run
	Enemy.UI_Icon_Switch (false)
	Enemy.TriggerEvent ("SettingsChanged", Enemy.Settings)

	if (Enemy.Settings.debug)
	then
		--Enemy.UI_ConfigDialog_Open ("CombatLog")

		--ScrollWindowSetOffset ("EnemyConfigDialogSectionsUnitFramesContent", 300)
		--ScrollWindowSetOffset ("EnemyConfigDialogSectionsUnitFramesContent", 600)
		--ScrollWindowSetOffset ("EnemyConfigDialogSectionsUnitFramesContent", 1800)
		--ScrollWindowSetOffset ("EnemyConfigDialogSectionsUnitFramesContent", 1300)

		--ScrollWindowSetOffset ("EnemyConfigDialogSectionsGroupIconsContent", 1800)

		--Enemy.CombatLogStatsWindowToggle ()

--		Enemy.AddEventHandler ("debug", "GroupsPlayerInitialized", function ()
--			EnemyTimer.New ("debug", 1, function ()
--				Enemy.UnitFramesUI_ConfigDialog_Debug ()
--				return true
--			end)
--		end)
	end
end


function Enemy.Shutdown ()
	Enemy.TriggerEvent ("Shutdown")
	Enemy.FixSettings ()
end


--
-- remove all functions from settings since otherwise game sometimes fails to correctly save settings
-- also remove all internal helper fields starting with _
--
function Enemy.FixSettings ()

	for k, v in pairs (Enemy.Settings)
	do
		if (type (v) == "table")
		then
			Enemy.Settings[k] = Enemy.clone (v)
		end
	end

	Enemy.each (Enemy.Settings, function (t, k, v)

		if (
				type (v) == "function"
				or
				(type (k) == "string" and k:sub (1, 1) == "_")
				or
				(type (k) == "wstring" and k:sub (1, 1) == L"_")
				or
				(type (v) == "number" and (v == math.huge or v == -math.huge))
			)
		then
			t[k] = nil
		end
	end)
end


function Enemy.ResetSettings ()
	Enemy.Settings = nil
	Enemy.Print ("All settings has been reset")
	InterfaceCore.ReloadUI ()
end

--------------------------------------------------------------- Global event handlers

function Enemy.OnPlayerTargetUpdated (targetClassification, targetId, targetType)

	TargetInfo:UpdateFromClient ()

	local target_info =
	{
		id = targetId,
		name = Enemy.FixString (TargetInfo:UnitName (targetClassification)),
		type = targetClassification,
		isFriendly = TargetInfo:UnitIsFriendly (targetClassification),	--(targetClassification == TargetInfo.FRIENDLY_TARGET)
		isNpc = TargetInfo:UnitIsNPC (targetClassification),
		career = TargetInfo:UnitCareer (targetClassification),
		level = TargetInfo:UnitLevel (targetClassification),
		hp = TargetInfo:UnitHealth (targetClassification)
	}

	if (not target_info.career or target_info.career == 0)
	then
		target_info.isNpc = true
	end


	if (targetClassification == TargetInfo.FRIENDLY_TARGET or targetClassification == TargetInfo.HOSTILE_TARGET)
	then
		local last_target = Enemy.latestTargets[targetClassification]
		local target_changed = false

		if (not last_target or last_target.id ~= targetId)
		then
			target_changed = true

			if (targetId == 0)
			then
				Enemy.latestTargets[targetClassification] = nil
				Enemy.latestTarget = nil
			else
				Enemy.latestTargets[targetClassification] = target_info
				Enemy.latestTarget = target_info
			end
		end

		Enemy.TriggerEvent ("TargetChanged", targetClassification, Enemy.latestTarget, target_changed)
	end

	Enemy.TriggerEvent ("PlayerTargetUpdated", target_info)
end

--------------------------------------------------------------- UI: Icon

function Enemy.UI_Icon_Switch (on)
	if (on) then
		DynamicImageSetTexture ("EnemyIcon", "enemy_icon_active", 0, 0)
	else
		DynamicImageSetTexture ("EnemyIcon", "enemy_icon_inactive", 0, 0)
	end
end

function Enemy.UI_Icon_OnLButtonUp ()
	Enemy.TriggerEvent ("IconLButtonUp")
end

function Enemy.UI_Icon_OnRButtonUp ()

	EA_Window_ContextMenu.CreateContextMenu ("EnemyIcon")

	local data = {}
	Enemy.TriggerEvent ("IconCreateContextMenu", data)

	table.insert (data, {text = L"", callback = nil})
	table.insert (data, {text = L"Configuration", callback = Enemy.UI_ConfigDialog_Open})

	for _, d in pairs (data)
	do
		if (d.text == L"")
		then
			EA_Window_ContextMenu.AddMenuDivider ()
		else
			EA_Window_ContextMenu.AddMenuItem (d.text, d.callback, d.disabled or false, true)
		end
	end

	EA_Window_ContextMenu.Finalize ()
end

function Enemy.UI_Icon_OnMouseOver ()

	Tooltips.CreateTextOnlyTooltip ("EnemyIcon")
	Tooltips.SetTooltipText (1, 1, L"Enemy Addon")

	local data = {}
	Enemy.TriggerEvent ("IconCreateTooltip", data)

	table.insert (data, L"Right-click to open menu.")

	local k = 2
	for _, d in pairs (data)
	do
		Tooltips.SetTooltipText (k, 1, d)
		k = k + 1
	end

	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


--------------------------------------------------------------- UI: Config dialog
local config_dlg = nil

function Enemy.UI_ConfigDialog_Hide ()

	for _, section in ipairs (config_dlg.sections)
	do
		section.isActive = false

		if (not section.isInitialized
			or not section.isLoaded
			or not section.onClose) then continue end

		section.onClose (section)
	end

	WindowSetShowing ("EnemyConfigDialog", false)
	Enemy.TriggerEvent ("SettingsChanged", Enemy.Settings)
end

function Enemy.UI_ConfigDialog_Open (openSection, scroll)

	if (not config_dlg)
	then
		config_dlg =
		{
			sections = {}
		}

		CreateWindow ("EnemyConfigDialog", false)
		LabelSetText ("EnemyConfigDialogTitleBarText", L"Enemy addon configuration")
		ButtonSetText ("EnemyConfigDialogOkButton", L"OK")
		ButtonSetText ("EnemyConfigDialogCancelButton", L"Cancel")
		ButtonSetText ("EnemyConfigDialogResetButton", L"Reset")
		ButtonSetText ("EnemyConfigDialogResetAllButton", L"Reset all")

		LabelSetText ("EnemyConfigDialogSectionLabel", L"Section")
		config_dlg.sections = {}

		Enemy.TriggerEvent ("ConfigDialogInitializeSections", config_dlg.sections)

		for _, section in ipairs (config_dlg.sections)
		do
			section.isInitialized = false
			ComboBoxAddMenuItem ("EnemyConfigDialogSection", section.title)
		end
	end

	local open_section_index = ComboBoxGetSelectedMenuItem ("EnemyConfigDialogSection")
	for section_index, section in ipairs (config_dlg.sections)
	do
		section.isActive = false

		if (section.name == openSection)
		then
			open_section_index = section_index
		end

		section.index = section_index
		section.isLoaded = false
	end

	WindowSetShowing ("EnemyConfigDialog", true)

	if (open_section_index == 0) then open_section_index = 1 end
	ComboBoxSetSelectedMenuItem ("EnemyConfigDialogSection", open_section_index)

	Enemy.UI_ConfigDialog_OnSectionSelChanged ()
	if (scroll ~= nil) then ScrollWindowSetOffset (config_dlg.currentSection.windowName.."Content", scroll) end
end

function Enemy.UI_ConfigDialog_OnSectionSelChanged ()

	local index = ComboBoxGetSelectedMenuItem ("EnemyConfigDialogSection")
	if (index < 1) then return end

	local section = config_dlg.sections[index]

	if (config_dlg.currentSection)
	then
		config_dlg.currentSection.isActive = false
	end

	if (not section.isInitialized)
	then
		section.windowName = "EnemyConfigDialogSections"..section.name
		CreateWindowFromTemplate (section.windowName, section.templateName, "EnemyConfigDialogSections")

		WindowClearAnchors (section.windowName)
		WindowAddAnchor (section.windowName, "topleft", "EnemyConfigDialogSections", "topleft", 0, 0)
		WindowAddAnchor (section.windowName, "bottomright", "EnemyConfigDialogSections", "bottomright", 0, 0)

		if (section.onInitialize) then section.onInitialize (section) end
		section.isInitialized = true
	end

	if (not section.isLoaded and section.onLoad)
	then
		section.onLoad (section)
	end

	for section_index, section in ipairs (config_dlg.sections)
	do
		if (not section.isInitialized) then continue end
		WindowSetShowing (section.windowName, section_index == index)
	end

	section.isActive = true
	section.isLoaded = true
	config_dlg.currentSection = section

	ButtonSetDisabledFlag ("EnemyConfigDialogResetButton", section.onReset == nil)
end

function Enemy.UI_ConfigDialog_Ok ()

	for _, section in ipairs (config_dlg.sections)
	do
		section.isActive = false

		if (not section.isInitialized
			or not section.isLoaded
			or not section.onSave) then continue end

		if (not section.onSave (section))
		then
			ComboBoxSetSelectedMenuItem ("EnemyConfigDialogSection", section.index)
			Enemy.UI_ConfigDialog_OnSectionSelChanged ()
			return
		end
	end

	Enemy.UI_ConfigDialog_Hide ()
	Enemy.FixSettings ()
end


function Enemy.UI_ConfigDialog_ResetCurrentSection ()
	config_dlg.currentSection.onReset (config_dlg.currentSection)
end


function Enemy.UI_ConfigDialog_Reset ()

	if (ButtonGetDisabledFlag ("EnemyConfigDialogResetButton") or not config_dlg.currentSection) then return end

	DialogManager.MakeTwoButtonDialog (L"Enemy addon\n\nThis will reset "..config_dlg.currentSection.title:lower ()..L" section settings.\n\nContinue?\n\n(you may have to wait for game interface to reload)",
                                       L"Yes", Enemy.UI_ConfigDialog_ResetCurrentSection,
                                       L"No")
end


function Enemy.UI_ConfigDialog_ResetAll ()

	if (ButtonGetDisabledFlag ("EnemyConfigDialogResetAllButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Enemy addon\n\nAre you sure you want to reset all settings to their default values?\n\n(you will have to wait for game interface to reload)",
                                       L"Yes", Enemy.ResetSettings,
                                       L"No")
end

--------------------------------------------------------------- UI: Debug
function Enemy.UI_Debug_OnListPopulate ()
--	if (EnemyDebugList.PopulatorIndices == nil) then return end
--
--	local row_window_name
--	local data
--
--	for k, v in ipairs (EnemyDebugList.PopulatorIndices)
--	do
--		row_window_name = "EnemyDebugListRow"..k
--	end
end


function Enemy.UI_Debug_OnRButtonUp ()
	Enemy.DebugClear ()
end


function Enemy.DebugClear ()
	if (not Enemy.Settings.debug) then return end
	g.debug = {}
	Enemy._DebugUpdate ()
end


function Enemy.DebugAdd (str)
	if (not Enemy.Settings.debug) then return end
	if (str == nil) then str = L"nil" end
	tinsert (g.debug, Enemy.toWString (str))
	Enemy._DebugUpdate ()
end


function Enemy._DebugUpdate ()

	if (not Enemy.Settings.debug) then return end

	Enemy.debugListData = {}
	Enemy.debugListIndexes = {}

	for k, data in ipairs (g.debug)
	do
		tinsert (Enemy.debugListData, { text = data })
		tinsert (Enemy.debugListIndexes, k)
	end

	ListBoxSetDisplayOrder ("EnemyDebugList", Enemy.debugListIndexes)
end


function Enemy._DebugTest ()

	local player = EnemyPlayer.New (L"Testplayer")
	player.zoneId = 138
	player.isOnline = true
	player.worldObjectId = 4987
	player.hp = 100
	player.isGroupLeader = false
	player.career = 22
	player.isDistant = false
	player.level = 40
	player.ap = 100

	player.groupIndex = Enemy.groups.player.groupIndex
	player.index = Enemy.groups.player.index + 1
	player.group = Enemy.groups.player.group

	player.effects =
	{
		[17] =
		{
			effectText_ = L"Armor increased by 594.",
			effectText = L"Armor increased by 594.",
			isHealing = false,
			effectIndex = 17,
			isStatsBuff = false,
			isOffensive = false,
			stackCount = 1,
			permanentUntilDispelled = false,
			isCasterDispellable = false,
			iconNum = 500,
			isDebuff = false,
			name_ = L"Lasting Bracing Unguent",
			duration = 3300,
			trackerPriority = 0,
			abilityId = 7936,
			isDamaging = false,
			name = L"Lasting Bracing Unguent^n",
			isDefensive = true,
			isBuff = true,
			castByPlayer = false,
			isGranted = false,
			isPassive = false,
		},
		[4] =
		{
			effectText_ = L"Taking 50% less Damage while guarded.\nCausing 35% less hate in monsters while guarded.",
			effectText = L"Taking 50% less Damage while guarded.\nCausing 35% less hate in monsters while guarded.",
			isHealing = false,
			effectIndex = 4,
			isStatsBuff = false,
			isOffensive = false,
			stackCount = 1,
			permanentUntilDispelled = true,
			isCasterDispellable = false,
			iconNum = 5172,
			isDebuff = false,
			name_ = L"Guard",
			duration = -458276,
			trackerPriority = 0,
			abilityId = 8325,
			isDamaging = false,
			name = L"Guard^n",
			isDefensive = true,
			isBuff = true,
			castByPlayer = true,
			isGranted = false,
			isPassive = false,
		},
		[16] =
		{
			effectText_ = L"Wounds increased by 60.\nMelee crit chance increased by 5%.",
			effectText = L"Wounds increased by 60.\nMelee crit chance increased by 5%.",
			isHealing = false,
			effectIndex = 16,
			isStatsBuff = false,
			isOffensive = false,
			stackCount = 1,
			permanentUntilDispelled = false,
			isCasterDispellable = false,
			iconNum = 488,
			isDebuff = false,
			name_ = L"War: Blood",
			duration = 1498,
			trackerPriority = 0,
			abilityId = 15623,
			isDamaging = false,
			name = L"War: Blood^n",
			isDefensive = true,
			isBuff = true,
			castByPlayer = false,
			isGranted = false,
			isPassive = false,
		},
		[14] =
		{
			effectText_ = L"25% chance to deal additional damage and reduce the victim's ability to heal.",
			effectText = L"25% chance to deal additional damage and reduce the victim's ability to heal.",
			isHealing = false,
			effectIndex = 14,
			isStatsBuff = false,
			isOffensive = false,
			stackCount = 1,
			permanentUntilDispelled = false,
			isCasterDispellable = false,
			iconNum = 11006,
			isDebuff = false,
			name_ = L"Kiss Of Death",
			duration = 1496,
			trackerPriority = 0,
			abilityId = 9407,
			isDamaging = false,
			name = L"Kiss Of Death^n",
			isDefensive = true,
			isBuff = true,
			castByPlayer = false,
			isGranted = false,
			isPassive = false,
		},
		[25] =
		{
			effectText_ = L"Experience gains increased by 100%\nExperience bonus increased by an additional 50% near Battlefield Objectives and Keeps!\nRenown gained increased by 150% near Battlefield Objectives and Keeps!",
			duration = 0,
			isHealing = false,
			effectIndex = 15,
			isStatsBuff = false,
			isOffensive = false,
			stackCount = 1,
			permanentUntilDispelled = true,
			isCasterDispellable = false,
			iconNum = 2456,
			isDebuff = false,
			name_ = L"Field of Glory",
			effectText = L"Experience gains increased by 100%\nExperience bonus increased by an additional 50% near Battlefield Objectives and Keeps!\nRenown gained increased by 150% near Battlefield Objectives and Keeps!",
			trackerPriority = 0,
			abilityId = 14318,
			isDamaging = false,
			name = L"Field of Glory^n",
			isDefensive = true,
			isBuff = false,
			castByPlayer = true,
			isGranted = false,
			isPassive = false,
		},
		[26] =
		{
			effectText_ = L"Incoming heals reduced by 50%.\nWill damage anyone attempting to heal though the flames.",
			duration = 6.8731069564819,
			typeColorRed = 184,
			effectIndex = 16,
			isStatsBuff = false,
			isOffensive = false,
			stackCount = 1,
			permanentUntilDispelled = false,
			isDefensive = true,
			isCasterDispellable = false,
			isHex = true,
			iconNum = 8022,
			typeColorBlue = 9,
			isDebuff = false,
			effectText = L"Incoming heals reduced by 50%.\nWill damage anyone attempting to heal though the flames.",
			name_ = L"Playing With Fire",
			typeColorGreen = 0,
			trackerPriority = 0,
			isBuff = false,
			isDamaging = true,
			name = L"Playing With Fire^n",
			abilityId = 8184,
			isHealing = false,
			castByPlayer = false,
			isGranted = false,
			isPassive = false,
		}
	}


--	local settings =
--	{
--		effectsIndicators = {}
--	}
--
--	for k, v in pairs (Enemy.Settings)
--	do
--		if (not k:match("unitFrames.*")) then continue end
--		settings[k] = v
--	end
--
--	for _, effect_indicator in pairs (Enemy.Settings.effectsIndicators)
--	do
--		if (effect_indicator.id == ignoreId) then continue end
--		tinsert (settings.effectsIndicators, Enemy.clone (effect_indicator))
--	end
--
--	settings.unitFramesTestMode = true

	local frame = EnemyUnitFrame.New (100, 100)
	frame:ApplySettings (Enemy.Settings)
	frame:Update (player)
	frame:UpdateEffects (player)

	WindowClearAnchors (frame.windowName)
	WindowAddAnchor (frame.windowName, "center", "Root", "center", -350, -300)

	DebugWindow.ClearTextLog ()
	d (frame.effectsIndicators[6].effectFilters[1]:IsMatch (player.effects[26]))
end



----------------------------------------------------------------- UI: Choose icon dialog
local choose_icon_dlg =
{
	isInitialized = false
}


function Enemy.UI_ChooseIconDialog_IsOpen ()
	return WindowGetShowing ("EnemyChooseIconDialog")
end


function Enemy.UI_ChooseIconDialog_Hide ()
	WindowSetShowing ("EnemyChooseIconDialog", false)
end


function Enemy.UI_ChooseIconDialog_Open (onOkCallback)

	if (not choose_icon_dlg.isInitialized)
	then
		-- initialize dialog UI
		LabelSetText ("EnemyChooseIconDialogTitleBarText", L"Choose icon")

		Enemy.UI_ChooseIconDialog_UpdateList ()

		choose_icon_dlg.isInitialized = true
	end

	-- proceed parameters
	choose_icon_dlg.onOkCallback = onOkCallback

	WindowSetShowing ("EnemyChooseIconDialog", true)
end


function Enemy.UI_ChooseIconDialog_UpdateList ()

	Enemy.chooseIconDialogListData = {}
	Enemy.chooseIconDialogListIndexes = {}

	local k = 1
	local id = 1
	local max_id = 50000

	while (id < max_id)
	do
		local data = {}

		while (id < max_id and #data < 8)
		do
			local texture, x, y = GetIconData (id)

			if (texture and texture ~= "icon-00001" and texture ~= "icon-00002")
			then
				tinsert (data, id)
			end

			id = id + 1
		end

		tinsert (Enemy.chooseIconDialogListData, data)
		tinsert (Enemy.chooseIconDialogListIndexes, k)
		k = k + 1
	end

	ListBoxSetDisplayOrder ("EnemyChooseIconDialogIcons", Enemy.chooseIconDialogListIndexes)
end


function Enemy.UI_ChooseIconDialog_OnIconsPopulate ()

	if (EnemyChooseIconDialogIcons.PopulatorIndices == nil) then return end

	local row_window_name
	local data

	for k, v in ipairs (EnemyChooseIconDialogIcons.PopulatorIndices)
	do
		row_window_name = "EnemyChooseIconDialogIconsRow"..k
		data = Enemy.chooseIconDialogListData[v]

		for i = 1, 8
		do
			local id = data[i]

			if (id)
			then
				WindowSetShowing (row_window_name.."Icon"..i, true)

				local texture, x, y = GetIconData (id)
				DynamicImageSetTexture (row_window_name.."Icon"..i.."Icon", texture, x, y)
			else
				WindowSetShowing (row_window_name.."Icon"..i, false)
			end
		end
	end
end


function Enemy.UI_ChooseIconDialog_OnListRowLButtonUp ()

	local data_index = ListBoxGetDataIndex ("EnemyChooseIconDialogIcons", WindowGetId (SystemData.ActiveWindow.name))
	local icon_index = tonumber (SystemData.ActiveWindow.name:match ("EnemyChooseIconDialogIconsRow%d+Icon(%d+)"))

	if (choose_icon_dlg.onOkCallback)
	then
		choose_icon_dlg.onOkCallback (Enemy.chooseIconDialogListData[data_index][icon_index])
	end

	Enemy.UI_ChooseIconDialog_Hide ()
end



----------------------------------------------------------------- UI: Text entry dialog
local text_entry_dialogs = {}

local function GetTextEntryDialogFromActiveWindowName ()

	local awn = SystemData.ActiveWindow.name
	if (not awn) then return nil end

	return awn:match ("(TextEntryDialog%d+).*")
end

function Enemy.UI_TextEntryDialog_Close (wn)

	if (not wn or type (wn) ~= "string")
	then
		wn = GetTextEntryDialogFromActiveWindowName ()
	end

	if (wn and DoesWindowExist (wn))
	then
		DestroyWindow (wn)
		text_entry_dialogs[wn] = nil
	end
end


function Enemy.UI_TextEntryDialog_Open (title, message, text, onOk)

	local wn = "TextEntryDialog"..Enemy.NewId ()

	local dlg = {}
	text_entry_dialogs[wn] = dlg

	dlg.wn = wn
	dlg.onOk = onOk

	CreateWindowFromTemplate (wn, "EnemyTextEntryDialog", "Root")

	ButtonSetText (wn.."OkButton", L"OK")
	ButtonSetText (wn.."CancelButton", L"Cancel")

	LabelSetText (wn.."TitleBarText", Enemy.toWStringOrEmpty (title))
	LabelSetText (wn.."Label", Enemy.toWStringOrEmpty (message))
	TextEditBoxSetText (wn.."Value", Enemy.toWStringOrEmpty (text))
	TextEditBoxSetMaxChars (wn.."Value", 1024 * 1024)

	WindowAssignFocus (wn.."Value", true)
	TextEditBoxSelectAll (wn.."Value")

	return wn
end


function Enemy.UI_TextEntryDialog_Ok ()

	wn = GetTextEntryDialogFromActiveWindowName ()
	if (not wn) then return end

	local dlg = text_entry_dialogs[wn]
	if (not dlg) then return end

	if (dlg.onOk)
	then
		dlg.onOk (TextEditBoxGetText (wn.."Value"))
	end

	Enemy.UI_TextEntryDialog_Close ()
end
