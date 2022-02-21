local Enemy = Enemy
local g = {}
local tinsert = table.insert
--local EnemyGroupIconPart = EnemyUnitFramePart

--------------------------------------------------------------- Main
function Enemy.GroupIconsInitialize ()

	Enemy.groupIcons = g

	g.icons = {}
	g.windowNameToCustomTargetEvents = {}

	for group_index = 1, Enemy.MaxGroups
	do
		local group_icons = {}
		tinsert (g.icons, group_icons)

		for index = 1, 6
		do
			local icon = EnemyGroupIcon.New (group_index, index)
			tinsert (group_icons, icon)
		end
	end

	g.petIcon = EnemyGroupIcon.New (0, 0, true)

	-- static events
	Enemy.AddEventHandler ("GroupIcons", "SettingsChanged", Enemy.GroupIcons_OnSettingsChanged)
	Enemy.AddEventHandler ("GroupIcons", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections,
		{
			name = "GroupIcons",
			title = L"Group icons",
			templateName = "EnemyGroupIconsConfiguration",
			onInitialize = Enemy.GroupIconsUI_ConfigDialog_OnInitialize,
			onLoad = Enemy.GroupIconsUI_ConfigDialog_OnLoad,
			onSave = Enemy.GroupIconsUI_ConfigDialog_OnSave,
			onReset = Enemy.GroupIconsUI_ConfigDialog_OnReset,
		})
	end)

	Enemy.TriggerEvent ("GroupIconsInitialized")
end


function Enemy._GroupIconsDisableAll ()

	for group_index = 1, Enemy.MaxGroups
	do
		for index = 1, 6
		do
			local icon = g.icons[group_index][index]
			icon:Disable ()
		end
	end

	g.petIcon:Disable()
end


function Enemy._GroupIconsEnabledChanged (enable)

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable

	if (g.isPluginEnabled)
	then
		Enemy.AddEventHandler ("GroupIcons", "GroupsTypeUpdated", Enemy.GroupIcons_OnGroupsTypeUpdated)
		Enemy.AddEventHandler ("GroupIcons", "GroupsUpdated", Enemy.GroupIcons_OnGroupsUpdated)
		Enemy.AddEventHandler ("GroupIcons", "GroupsPlayerUpdated", Enemy.GroupIcons_OnGroupsPlayerUpdated)
		Enemy.AddEventHandler ("GroupIcons", "GroupsPlayerPetUpdated", Enemy.GroupIcons_OnGroupsPlayerPetUpdated)
		Enemy.AddEventHandler ("GroupIcons", "PlayerObjectWindowsChanged", Enemy.GroupIcons_OnPlayerObjectWindowsChanged)
		RegisterEventHandler (SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.GroupIcons_OnPlayerZoneChanged")

		g.wasEnabled = true
	else
		Enemy.RemoveEventHandler ("GroupIcons", "GroupsTypeUpdated")
		Enemy.RemoveEventHandler ("GroupIcons", "GroupsUpdated")
		Enemy.RemoveEventHandler ("GroupIcons", "GroupsPlayerUpdated")
		Enemy.RemoveEventHandler ("GroupIcons", "GroupsPlayerPetUpdated")
		Enemy.RemoveEventHandler ("GroupIcons", "PlayerObjectWindowsChanged")

		if (g.wasEnabled)
		then
			UnregisterEventHandler (SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.GroupIcons_OnPlayerZoneChanged")
		end
	end
end


function Enemy.GroupIcons_OnSettingsChanged (settings)
	g.settings = settings
	Enemy._GroupIconsEnabledChanged (g.settings.groupIconsEnabled);

	if (g.isPluginEnabled)
	then
		for group_index = 1, Enemy.MaxGroups
		do
			for index = 1, 6
			do
				local icon = g.icons[group_index][index]
				icon:Reset (true)
				icon:ApplySettings (g.settings)
			end
		end

		g.petIcon:ApplySettings (g.settings)

		Enemy.GroupIcons_OnGroupsUpdated (true)
	else
		Enemy._GroupIconsDisableAll ()
	end
end


function Enemy.GroupIcons_OnPlayerZoneChanged ()
	Enemy.GroupIcons_OnGroupsUpdated (true)
end


function Enemy.GroupIcons_OnGroupsTypeUpdated ()
	Enemy._GroupIconsDisableAll ()
end


function Enemy.GroupIcons_OnGroupsUpdated (playerGroupChanged)

	if (playerGroupChanged)
	then
		Enemy._GroupIconsDisableAll ()
	end

	local max_groups = Enemy.GroupsGetMaxGroups ()
	for group_index = 1, max_groups
	do
		local group = Enemy.groups.groups[group_index]

		for index = 1, 6
		do
			local player = group[index]
			local icon = g.icons[group_index][index]

			if (
					not player
					or
					(g.settings.groupIconsHideOnSelf and player.isSelf)
					or
					(not g.settings.groupIconsShowOtherGroups and not player.isInPlayerGroup)
					or
					(not g.settings.groupIconsShowOnMarkedPlayers and Enemy.MarksIsPlayerHasMark (player.name))
					)
			then
				icon:Disable ()
			else
				icon:Enable ()
				icon:Update (player)
			end
		end
	end

	local me = Enemy.groups.player
	if (not me or not me.pet)
	then
		g.petIcon:Disable()
	else
		g.petIcon:Enable ()
		g.petIcon:Update (me.pet)
	end
end


function Enemy.GroupIcons_OnPlayerObjectWindowsChanged (name, objectWindow)

	--d (L"GroupIcons_OnPlayerObjectWindowsChanged: "..Enemy.toWStringOrEmpty (name))

	local player = Enemy.groups.players[name]
	if (not player or not player:IsInGroup ()) then return end

	Enemy.GroupIcons_OnGroupsUpdated ()
end


function Enemy.GroupIcons_OnGroupsPlayerUpdated (player)

	if (not player:IsInGroup ()) then return end

	local icon = g.icons[player.groupIndex][player.index]
	icon:Update (player)
end


function Enemy.GroupIcons_OnGroupsPlayerPetUpdated (player)

	if (not player.pet or not player.isSelf) then return end
	g.petIcon:Update (player.pet)
end


function Enemy.GroupIcons_GroupIcon_OnLButtonDown ()

	local custom_target_event = g.windowNameToCustomTargetEvents[SystemData.ActiveWindow.name]
	if (not custom_target_event) then return end

	BroadcastEvent (custom_target_event)
end


--------------------------------------------------------------- UI: Configuration
local dlg =
{
	properties =
	{
		groupIconsEnabled =
		{
			key = "groupIconsEnabled",
			order = 10,
			name = L"Enable group icons",
			type = "bool",
			default = Enemy.DefaultSettings.groupIconsEnabled,
			paddingLeft = 20
		},
		groupIconsTargetOnClick =
		{
			key = "groupIconsTargetOnClick",
			order = 20,
			name = L"Target on click",
			type = "bool",
			default = Enemy.DefaultSettings.groupIconsTargetOnClick
		},
		groupIconsHideOnSelf =
		{
			key = "groupIconsHideOnSelf",
			order = 30,
			name = L"Hide icon on self",
			type = "bool",
			default = Enemy.DefaultSettings.groupIconsHideOnSelf
		},
		groupIconsShowOtherGroups =
		{
			key = "groupIconsShowOtherGroups",
			order = 40,
			name = L"Show icons for other groups",
			type = "bool",
			default = Enemy.DefaultSettings.groupIconsShowOtherGroups
		},
		groupIconsShowOnMarkedPlayers =
		{
			key = "groupIconsShowOnMarkedPlayers",
			order = 50,
			name = L"Show icons on marked players",
			tooltip = L"Show icons the players you have marked with custom marks",
			type = "bool",
			default = Enemy.DefaultSettings.groupIconsShowOnMarkedPlayers
		},




		titleAppearance =
		{
			key = "titleAppearance",
			order = 60,
			name = L"Appearance",
			type = "title",
			paddingTop = 40
		},
		groupIconsScale =
		{
			key = "groupIconsScale",
			order = 70,
			name = L"Scale",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsScale,
			min = 0,
			max = 5
		},
		groupIconsLayer =
		{
			key = "groupIconsLayer",
			order = 80,
			name = L"Layer",
			type = "select",
			default = Enemy.DefaultSettings.groupIconsLayer,
			values = Enemy.ConfigurationWindowGetLayersSelectValues
		},
		groupIconsAlpha =
		{
			key = "groupIconsAlpha",
			order = 90,
			name = L"Alpha",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsAlpha,
			min = 0,
			max = 1
		},
		groupIconsOffset =
		{
			key = "groupIconsOffset",
			order = 100,
			name = L"Offset (XY)",
			type = "int[]",
			size = 2,
			default = Enemy.DefaultSettings.groupIconsOffset,
			min = { -1000, -1000 },
			max = { 1000, 1000 }
		},
		groupIconsHPColor =
		{
			key = "groupIconsHPColor",
			order = 110,
			name = L"HP color (RGB)",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsHPColor
		},
		groupIconsHPBGColor =
		{
			key = "groupIconsHPBGColor",
			order = 120,
			name = L"HP background color",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsHPBGColor
		},
		groupIconsBGColor =
		{
			key = "groupIconsBGColor",
			order = 130,
			name = L"Background color",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsBGColor
		},
		groupIconsBGAlpha =
		{
			key = "groupIconsBGAlpha",
			order = 140,
			name = L"Background alpha",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsBGAlpha,
			min = 0,
			max = 5
		},



		titleOtherGroups =
		{
			key = "titleOtherGroups",
			order = 150,
			name = L"Other groups (OG)",
			type = "title",
			paddingTop = 40
		},
		groupIconsOtherGroupsScale =
		{
			key = "groupIconsOtherGroupsScale",
			order = 160,
			name = L"Scale",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsOtherGroupsScale,
			min = 0,
			max = 5
		},
		groupIconsOtherGroupsLayer =
		{
			key = "groupIconsOtherGroupsLayer",
			order = 170,
			name = L"Layer",
			type = "select",
			default = Enemy.DefaultSettings.groupIconsOtherGroupsLayer,
			values = Enemy.ConfigurationWindowGetLayersSelectValues
		},
		groupIconsOtherGroupsAlpha =
		{
			key = "groupIconsOtherGroupsAlpha",
			order = 180,
			name = L"Alpha",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsOtherGroupsAlpha,
			min = 0,
			max = 1
		},
		groupIconsOtherGroupsOffset =
		{
			key = "groupIconsOtherGroupsOffset",
			order = 190,
			name = L"Offset (XY)",
			type = "int[]",
			size = 2,
			default = Enemy.DefaultSettings.groupIconsOtherGroupsOffset,
			min = { -1000, -1000 },
			max = { 1000, 1000 }
		},
		groupIconsOtherGroupsHPColor =
		{
			key = "groupIconsOtherGroupsHPColor",
			order = 200,
			name = L"HP color (RGB)",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsOtherGroupsHPColor
		},
		groupIconsOtherGroupsHPBGColor =
		{
			key = "groupIconsOtherGroupsHPBGColor",
			order = 210,
			name = L"HP background color",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsOtherGroupsHPBGColor
		},
		groupIconsOtherGroupsBGColor =
		{
			key = "groupIconsOtherGroupsBGColor",
			order = 220,
			name = L"Background color",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsOtherGroupsBGColor
		},
		groupIconsOtherGroupsBGAlpha =
		{
			key = "groupIconsOtherGroupsBGAlpha",
			order = 230,
			name = L"Background alpha",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsOtherGroupsBGAlpha,
			min = 0,
			max = 5
		},


		titlePet =
		{
			key = "titlePet",
			order = 240,
			name = L"Pet",
			type = "title",
			paddingTop = 40
		},
		groupIconsPetScale =
		{
			key = "groupIconsPetScale",
			order = 250,
			name = L"Scale",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsPetScale,
			min = 0,
			max = 5
		},
		groupIconsPetLayer =
		{
			key = "groupIconsPetLayer",
			order = 260,
			name = L"Layer",
			type = "select",
			default = Enemy.DefaultSettings.groupIconsPetLayer,
			values = Enemy.ConfigurationWindowGetLayersSelectValues
		},
		groupIconsPetAlpha =
		{
			key = "groupIconsPetAlpha",
			order = 270,
			name = L"Alpha",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsPetAlpha,
			min = 0,
			max = 1
		},
		groupIconsPetOffset =
		{
			key = "groupIconsPetOffset",
			order = 280,
			name = L"Offset (XY)",
			type = "int[]",
			size = 2,
			default = Enemy.DefaultSettings.groupIconsPetOffset,
			min = { -1000, -1000 },
			max = { 1000, 1000 }
		},
		groupIconsPetIconColor =
		{
			key = "groupIconsPetIconColor",
			order = 290,
			name = L"Icon color (RGB)",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsPetIconColor
		},
		groupIconsPetHPColor =
		{
			key = "groupIconsPetHPColor",
			order = 300,
			name = L"HP color (RGB)",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsPetHPColor
		},
		groupIconsPetHPBGColor =
		{
			key = "groupIconsPetHPBGColor",
			order = 310,
			name = L"HP background color",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsPetHPBGColor
		},
		groupIconsPetBGColor =
		{
			key = "groupIconsPetBGColor",
			order = 320,
			name = L"Background color",
			type = "color",
			default = Enemy.DefaultSettings.groupIconsPetBGColor
		},
		groupIconsPetBGAlpha =
		{
			key = "groupIconsPetBGAlpha",
			order = 330,
			name = L"Background alpha",
			type = "float",
			default = Enemy.DefaultSettings.groupIconsPetBGAlpha,
			min = 0,
			max = 5
		}
	}
}

function Enemy.GroupIconsUI_ConfigDialog_OnInitialize (section)

	dlg.section = section

	local root = dlg.section.windowName.."ContentScrollChild"
	dlg.cwn = root.."Config"
	local width, height = Enemy.CreateConfigurationWindow (dlg.cwn, root, dlg.properties, Enemy.GroupIconsUI_ConfigDialog_TestSettings)

--	WindowAddAnchor (dlg.section.windowName.."ContentScrollChildGroupIconPartsLabel", "bottomleft", dlg.cwn, "topleft", 40, 40)
--	LabelSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsLabel", L"Visual parts")
--	WindowSetTintColor (dlg.section.windowName.."ContentScrollChildGroupIconPartsListBackground", 100, 100, 100)
--	WindowSetAlpha (dlg.section.windowName.."ContentScrollChildGroupIconPartsListBackground", 0.5)
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsAddButton", L"Add")
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsEditButton", L"Edit")
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsDeleteButton", L"Delete")
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsUpButton", L"Up")
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsDownButton", L"Down")
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsImportButton", L"Import")
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsExportButton", L"Export")
--	ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsResetButton", L"Reset")

	ScrollWindowUpdateScrollRect (dlg.section.windowName.."Content")
end


function Enemy.GroupIconsUI_ConfigDialog_OnLoad (section)

	dlg.isLoaded = false

	dlg.groupIconsEnabled = Enemy.Settings.groupIconsEnabled
	dlg.groupIconsTargetOnClick = Enemy.Settings.groupIconsTargetOnClick
	dlg.groupIconsHideOnSelf = Enemy.Settings.groupIconsHideOnSelf
	dlg.groupIconsShowOtherGroups = Enemy.Settings.groupIconsShowOtherGroups
	dlg.groupIconsShowOnMarkedPlayers = Enemy.Settings.groupIconsShowOnMarkedPlayers

	dlg.groupIconsScale = Enemy.Settings.groupIconsScale
	dlg.groupIconsLayer = Enemy.Settings.groupIconsLayer
	dlg.groupIconsAlpha = Enemy.Settings.groupIconsAlpha
	dlg.groupIconsOffset = Enemy.clone (Enemy.Settings.groupIconsOffset)
	dlg.groupIconsHPColor = Enemy.clone (Enemy.Settings.groupIconsHPColor)
	dlg.groupIconsHPBGColor = Enemy.clone (Enemy.Settings.groupIconsHPBGColor)
	dlg.groupIconsBGColor = Enemy.clone (Enemy.Settings.groupIconsBGColor)
	dlg.groupIconsBGAlpha = Enemy.Settings.groupIconsBGAlpha

	dlg.groupIconsOtherGroupsScale = Enemy.Settings.groupIconsOtherGroupsScale
	dlg.groupIconsOtherGroupsLayer = Enemy.Settings.groupIconsOtherGroupsLayer
	dlg.groupIconsOtherGroupsAlpha = Enemy.Settings.groupIconsOtherGroupsAlpha
	dlg.groupIconsOtherGroupsOffset = Enemy.clone (Enemy.Settings.groupIconsOtherGroupsOffset)
	dlg.groupIconsOtherGroupsHPColor = Enemy.clone (Enemy.Settings.groupIconsOtherGroupsHPColor)
	dlg.groupIconsOtherGroupsHPBGColor = Enemy.clone (Enemy.Settings.groupIconsOtherGroupsHPBGColor)
	dlg.groupIconsOtherGroupsBGColor = Enemy.clone (Enemy.Settings.groupIconsOtherGroupsBGColor)
	dlg.groupIconsOtherGroupsBGAlpha = Enemy.Settings.groupIconsOtherGroupsBGAlpha

	dlg.groupIconsPetScale = Enemy.Settings.groupIconsPetScale
	dlg.groupIconsPetLayer = Enemy.Settings.groupIconsPetLayer
	dlg.groupIconsPetAlpha = Enemy.Settings.groupIconsPetAlpha
	dlg.groupIconsPetOffset = Enemy.clone (Enemy.Settings.groupIconsPetOffset)
	dlg.groupIconsPetIconColor = Enemy.clone (Enemy.Settings.groupIconsPetIconColor)
	dlg.groupIconsPetHPColor = Enemy.clone (Enemy.Settings.groupIconsPetHPColor)
	dlg.groupIconsPetHPBGColor = Enemy.clone (Enemy.Settings.groupIconsPetHPBGColor)
	dlg.groupIconsPetBGColor = Enemy.clone (Enemy.Settings.groupIconsPetBGColor)
	dlg.groupIconsPetBGAlpha = Enemy.Settings.groupIconsPetBGAlpha

--	dlg.groupIconsParts = {}
--	for _, v in pairs (Enemy.Settings.groupIconsParts)
--	do
--		tinsert (dlg.groupIconsParts, EnemyGroupIconPart.New (v))
--	end

	Enemy.ConfigurationWindowLoadData (dlg.cwn, dlg)
--	dlg.groupIconsPartsListSelectedIndex = nil

  dlg.isLoaded = true

--	Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
	Enemy.GroupIconsUI_ConfigDialog_TestSettings ()
end


function Enemy.GroupIconsUI_ConfigDialog_TestSettings ()

	if (not dlg.isLoaded) then return end

	Enemy.ConfigurationWindowSaveData (dlg.cwn, dlg)
	Enemy.GroupIcons_OnSettingsChanged (dlg)
end


function Enemy.GroupIconsUI_ConfigDialog_OnReset (section)

	for k, v in pairs (Enemy.Settings)
	do
		if (not k:match("^groupIcons.*")) then continue end
		Enemy.Settings[k] = nil
	end

	Enemy.Print ("Group icons settings has been reset")
	InterfaceCore.ReloadUI ()
end


-- =============================================================================== PARTS

--function Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListPopulate ()
--
--	if (not dlg.isLoaded) then return end
--
--	local list = _G[dlg.section.windowName.."ContentScrollChildGroupIconPartsList"]
--	if (list.PopulatorIndices == nil) then return end
--
--	local row_window_name
--	local data
--
--	for k, v in ipairs (list.PopulatorIndices)
--	do
--		row_window_name = dlg.section.windowName.."ContentScrollChildGroupIconPartsListRow"..k
--		data = Enemy.groupIconsPartsListData[v]
--
--		if (v == dlg.groupIconsPartsListSelectedIndex)
--		then
--			WindowSetShowing (row_window_name.."Background", true)
--			WindowSetAlpha (row_window_name.."Background", 0.5)
--			WindowSetTintColor (row_window_name.."Background", 255, 204, 102)
--		else
--			WindowSetShowing (row_window_name.."Background", false)
--		end
--
--		if (data.isEnabled)
--		then
--			LabelSetText (row_window_name.."Text", data.name)
--		else
--			LabelSetText (row_window_name.."Text", L"[disabled] "..data.name)
--		end
--	end
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_UpdateGroupIconPartsList ()
--
--	if (not dlg.isLoaded) then return end
--
--	Enemy.groupIconsPartsListData = {}
--	Enemy.groupIconsPartsListIndexes = {}
--
--	for k, data in ipairs(dlg.groupIconsParts)
--	do
--		tinsert (Enemy.groupIconsPartsListData, data)
--		tinsert (Enemy.groupIconsPartsListIndexes, k)
--	end
--
--	ListBoxSetDisplayOrder (dlg.section.windowName.."ContentScrollChildGroupIconPartsList", Enemy.groupIconsPartsListIndexes)
--	Enemy.GroupIconsUI_ConfigDialog_TestSettings ()
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListLButtonUp ()
--
--	if (not dlg.isLoaded) then return end
--
--	local data_index = ListBoxGetDataIndex (dlg.section.windowName.."ContentScrollChildGroupIconPartsList", WindowGetId (SystemData.MouseOverWindow.name))
--
--	if (data_index == nil)
--	then
--		dlg.groupIconsPartsListSelectedIndex = nil
--	else
--		dlg.groupIconsPartsListSelectedIndex = Enemy.groupIconsPartsListIndexes[data_index]
--	end
--
--	Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--
--	if (not dlg.isLoaded) then return end
--
--	local data = dlg.groupIconsParts[dlg.groupIconsPartsListSelectedIndex]
--	if (not data)
--	then
--		dlg.groupIconsPartsListSelectedIndex = nil
--	end
--
--	Enemy.GroupIconsUI_ConfigDialog_UpdateGroupIconPartsList ()
--	ButtonSetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsEditButton", dlg.groupIconsPartsListSelectedIndex == nil)
--	ButtonSetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsDeleteButton", dlg.groupIconsPartsListSelectedIndex == nil)
--	ButtonSetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsUpButton", dlg.groupIconsPartsListSelectedIndex == nil or dlg.groupIconsPartsListSelectedIndex == 1)
--	ButtonSetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsDownButton", dlg.groupIconsPartsListSelectedIndex == nil or dlg.groupIconsPartsListSelectedIndex == #dlg.groupIconsParts)
--	ButtonSetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsExportButton", dlg.groupIconsPartsListSelectedIndex == nil)
--
--	if (data and data.isEnabled)
--	then
--		ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsEnableButton", L"Disable")
--	else
--		ButtonSetText (dlg.section.windowName.."ContentScrollChildGroupIconPartsEnableButton", L"Enable")
--	end
--
--	ButtonSetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsEnableButton", dlg.groupIconsPartsListSelectedIndex == nil)
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsAdd ()
--
--	if (not dlg.isLoaded) then return end
--
--	local obj = EnemyGroupIconPart.New ()
--
--	obj:Edit (dlg, function (groupIconsPart)
--
--		tinsert (dlg.groupIconsParts, groupIconsPart)
--
--		dlg.groupIconsPartsListSelectedIndex = #dlg.groupIconsParts
--		Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--	end)
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsEdit ()
--
--	if (not dlg.isLoaded
--		or not dlg.groupIconsPartsListSelectedIndex
--		or ButtonGetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsEditButton")) then return end
--
--	local obj = dlg.groupIconsParts[dlg.groupIconsPartsListSelectedIndex]
--	obj:Edit (dlg, function (groupIconsPart)
--		Enemy.GroupIconsUI_ConfigDialog_UpdateGroupIconPartsList ()
--	end)
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsDelete ()
--
--	if (not dlg.isLoaded
--		or not dlg.groupIconsPartsListSelectedIndex
--		or ButtonGetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsDeleteButton")) then return end
--
--	DialogManager.MakeTwoButtonDialog (L"Delete part '"..Enemy.isNil (dlg.groupIconsParts[dlg.groupIconsPartsListSelectedIndex].name, L"")..L"' ?",
--                                       L"Yes", function ()
--
--                                       		table.remove (dlg.groupIconsParts, dlg.groupIconsPartsListSelectedIndex)
--                                       		dlg.groupIconsPartsListSelectedIndex = nil
--                                       		Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--                                       end,
--                                       L"No")
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsUp ()
--
--	if (not dlg.isLoaded
--		or not dlg.groupIconsPartsListSelectedIndex
--		or ButtonGetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsUpButton")) then return end
--
--	local index = dlg.groupIconsPartsListSelectedIndex
--
--	local tmp = dlg.groupIconsParts[index - 1]
--	dlg.groupIconsParts[index - 1] = dlg.groupIconsParts[index]
--	dlg.groupIconsParts[index] = tmp
--
--	dlg.groupIconsPartsListSelectedIndex = index - 1
--	Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsDown ()
--
--	if (not dlg.isLoaded
--		or not dlg.groupIconsPartsListSelectedIndex
--		or ButtonGetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsDownButton")) then return end
--
--	local index = dlg.groupIconsPartsListSelectedIndex
--
--	local tmp = dlg.groupIconsParts[index + 1]
--	dlg.groupIconsParts[index + 1] = dlg.groupIconsParts[index]
--	dlg.groupIconsParts[index] = tmp
--
--	dlg.groupIconsPartsListSelectedIndex = index + 1
--	Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsImport ()
--
--	if (not dlg.isLoaded) then return end
--
--	Enemy.UI_TextEntryDialog_Open (L"Import", L"Paste (Ctrl+V) visual part data string", L"",
--		function (str)
--
--			local data = Enemy.DeserializeTable (str)
--			if (not data) then return end
--
--			local obj = EnemyGroupIconPart.New (data)
--
--			obj:Edit (dlg, function (obj)
--
--				tinsert (dlg.groupIconsParts, obj)
--
--				dlg.groupIconsPartsListSelectedIndex = #dlg.groupIconsParts
--				Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--			end)
--		end)
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsExport ()
--
--	if (not dlg.isLoaded
--		or not dlg.groupIconsPartsListSelectedIndex
--		or ButtonGetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsExportButton")) then return end
--
--	local obj = Enemy.clone2 (dlg.groupIconsParts[dlg.groupIconsPartsListSelectedIndex])
--
--	obj.id = nil
--	obj.version = Enemy.Settings.version
--
--	local str = Enemy.SerializeTable (obj)
--
--	Enemy.UI_TextEntryDialog_Open (L"Export", L"Select all (Ctrl+A) and copy (Ctrl+C) this visual part data string", str)
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsEnable ()
--
--	if (not dlg.isLoaded
--		or not dlg.groupIconsPartsListSelectedIndex
--		or ButtonGetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsEnableButton")) then return end
--
--	local data = dlg.groupIconsParts[dlg.groupIconsPartsListSelectedIndex]
--	data.isEnabled = not data.isEnabled
--
--	Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--end
--
--
--function Enemy.GroupIconsUI_ConfigDialog_GroupIconPartsReset ()
--
--	if (not dlg.isLoaded
--		or ButtonGetDisabledFlag (dlg.section.windowName.."ContentScrollChildGroupIconPartsResetButton")) then return end
--
--	DialogManager.MakeTwoButtonDialog (L"Reset all visual parts list data to it's default predefined value?",
--                                       L"Yes", function ()
--
--                                       		dlg.groupIconsParts = {}
--											for _, v in pairs (Enemy.DefaultSettings.groupIconsParts)
--											do
--												tinsert (dlg.groupIconsParts, EnemyGroupIconPart.New (v))
--											end
--
--                                       		dlg.groupIconsPartsListSelectedIndex = nil
--                                       		Enemy.GroupIconsUI_ConfigDialog_OnGroupIconPartsListSelChanged ()
--                                       end,
--                                       L"No")
--end


function Enemy.GroupIconsUI_ConfigDialog_OnSave (section)

	Enemy.GroupIconsUI_ConfigDialog_TestSettings ()

	Enemy.Settings.groupIconsEnabled = dlg.groupIconsEnabled
	Enemy.Settings.groupIconsTargetOnClick = dlg.groupIconsTargetOnClick
	Enemy.Settings.groupIconsHideOnSelf = dlg.groupIconsHideOnSelf
	Enemy.Settings.groupIconsShowOtherGroups = dlg.groupIconsShowOtherGroups
  Enemy.Settings.groupIconsShowOnMarkedPlayers = dlg.groupIconsShowOnMarkedPlayers

	Enemy.Settings.groupIconsScale = dlg.groupIconsScale
	Enemy.Settings.groupIconsAlpha = dlg.groupIconsAlpha
	Enemy.Settings.groupIconsOffset = Enemy.clone (dlg.groupIconsOffset)
	Enemy.Settings.groupIconsHPColor = Enemy.clone (dlg.groupIconsHPColor)
	Enemy.Settings.groupIconsHPBGColor = Enemy.clone (dlg.groupIconsHPBGColor)
	Enemy.Settings.groupIconsBGColor = Enemy.clone (dlg.groupIconsBGColor)
	Enemy.Settings.groupIconsBGAlpha = dlg.groupIconsBGAlpha

	Enemy.Settings.groupIconsOtherGroupsScale = dlg.groupIconsOtherGroupsScale
	Enemy.Settings.groupIconsOtherGroupsAlpha = dlg.groupIconsOtherGroupsAlpha
	Enemy.Settings.groupIconsOtherGroupsOffset = Enemy.clone (dlg.groupIconsOtherGroupsOffset)
	Enemy.Settings.groupIconsOtherGroupsHPColor = Enemy.clone (dlg.groupIconsOtherGroupsHPColor)
	Enemy.Settings.groupIconsOtherGroupsHPBGColor = Enemy.clone (dlg.groupIconsOtherGroupsHPBGColor)
	Enemy.Settings.groupIconsOtherGroupsBGColor = Enemy.clone (dlg.groupIconsOtherGroupsBGColor)
	Enemy.Settings.groupIconsOtherGroupsBGAlpha = dlg.groupIconsOtherGroupsBGAlpha

	Enemy.Settings.groupIconsPetScale = dlg.groupIconsPetScale
	Enemy.Settings.groupIconsPetAlpha = dlg.groupIconsPetAlpha
	Enemy.Settings.groupIconsPetOffset = Enemy.clone (dlg.groupIconsPetOffset)
	Enemy.Settings.groupIconsPetIconColor = Enemy.clone (dlg.groupIconsPetIconColor)
	Enemy.Settings.groupIconsPetHPColor = Enemy.clone (dlg.groupIconsPetHPColor)
	Enemy.Settings.groupIconsPetHPBGColor = Enemy.clone (dlg.groupIconsPetHPBGColor)
	Enemy.Settings.groupIconsPetBGColor = Enemy.clone (dlg.groupIconsPetBGColor)
	Enemy.Settings.groupIconsPetBGAlpha = dlg.groupIconsPetBGAlpha

	return true
end
