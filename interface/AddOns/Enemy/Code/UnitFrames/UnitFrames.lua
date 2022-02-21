local Enemy = Enemy
local g = {}
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local mceil = math.ceil
local mmin = math.min
local mmax = math.max
local InterfaceCore = InterfaceCore

local MAX_SCALE = 3

--------------------------------------------------------------- Main
function Enemy.UnitFramesInitialize ()

	Enemy.UnitFramesPartsInitialize ()
	Enemy.unitFrames = g

	g.anchorWindows = {}

	-- UI
	local wn = "EnemyUnitFramesAnchor1"
	g.anchorWindows[1] = { windowName = wn }
	CreateWindow (wn, true)
	WindowSetTintColor (wn.."Background", 0, 0, 0)
	WindowSetAlpha (wn, 0)
	LayoutEditor.RegisterWindow (wn, L"Enemy unit frames anchor 1", L"Enemy unit frames anchor 1", false, false, false, nil)

	wn = "EnemyUnitFramesAnchor2"
	g.anchorWindows[2] = { windowName = wn }
	CreateWindow (wn, true)
	WindowSetTintColor (wn.."Background", 0, 0, 0)
	WindowSetAlpha (wn, 0)
	LayoutEditor.RegisterWindow (wn, L"Enemy unit frames anchor 2", L"Enemy unit frames anchor 2", false, false, false, nil)

	if (Enemy.Settings.prevVersion > 0)
	then
		if (Enemy.Settings.prevVersion < 37)
		then
			DialogManager.MakeTwoButtonDialog (L"Enemy addon\n\nCause of considerable changes in unit frames code it's recommended to reset unit frames settings to default values. Only unit frames settings will be affected.\n\nDo you want to reset it now (you will have to wait for game interface to reload)?\n\nRecommended - yes",
	                                       L"Yes", Enemy.UnitFramesResetSettings,
	                                       L"No")

	    elseif (Enemy.Settings.prevVersion < 51)
		then
			DialogManager.MakeTwoButtonDialog (L"Enemy addon\n\nThere are new fancy default unit frames settings implemented. If you haven't configured unit frames by yourself it's recommended to reset setting now to apply those new defaults. Only unit frames settings will be affected.\n\nIf you already configured unit frames feel free to press 'No'.\n\nDo you want to reset it now (you will have to wait for game interface to reload)?\n\nRecommended - yes (you will loose your current unit frames settings)",
	                                       L"Yes", Enemy.UnitFramesResetSettings,
	                                       L"No")

	    elseif (Enemy.Settings.prevVersion < 76)
		then
			DialogManager.MakeTwoButtonDialog (L"Enemy addon\n\nA default list of effects indicators for unit frames has been improved and it's recommended to reset unit frames effects indicators settings now to apply those new defaults. Only unit frames effects indicators list settings will be affected.\n\nIf you already configured your unit frames effects indicators then it's better to press now 'No', go to unit frames configuration, export your custom settings to some safe place, press 'reset' under the effects indicators list and then import your custom settings back.\n\nDo you want to reset it now (you will have to wait for game interface to reload)?\n\nRecommended - yes (you will loose your current unit frames effects indicators settings)",
	                                       L"Yes", function ()

	                                       		Enemy.Settings.effectsIndicators = nil
												Enemy.Print ("Unit frames effects indicators settings has been reset")
												InterfaceCore.ReloadUI ()
	                                       end,
	                                       L"No")
		end

		if (Enemy.Settings.prevVersion < 44)
		then
			for _, v in pairs (Enemy.Settings.unitFramesParts)
			do
				v.isEnabled = true
			end

			for _, v in pairs (Enemy.Settings.effectsIndicators)
			do
				v.isEnabled = true
			end

			for _, v in pairs (Enemy.Settings.clickCastings)
			do
				v.isEnabled = true
			end
		end

		if (Enemy.Settings.prevVersion < 49)
		then
			local old_icons = { "effect", "effect2", "guard", "question", "stagger", "heal", "disabled", "other" }

			for _, v in pairs (Enemy.Settings.effectsIndicators)
			do
				if (type (v.icon) == "number")
				then
					v.icon = old_icons[v.icon]
				end
			end
		end

		if (Enemy.Settings.prevVersion < 73)
		then
			local old_effect_filter_types = { "all", "isDebuff", "isAilment", "isHex", "isCurse", "isOffensive", "isDamaging", "isDefensive", "isHealing", "isBuff", "isBlessing", "isStatsBuff", "isGranted", "isPassive", "healDebuffIn50", "healDebuffIn25", "healDebuffIn", "healDebuffOut", "stagger", "guard" }

			for _, effect_indicator in pairs (Enemy.Settings.effectsIndicators)
			do
				for _, effect_filter in pairs (effect_indicator.effectFilters)
				do
					if (type (effect_filter.type) == "number")
					then
						effect_filter.type = old_effect_filter_types[effect_filter.type]

						if (effect_filter.type == "all")
						then
							effect_filter.type = nil
						end
					end
				end
			end
		end

		if (Enemy.Settings.prevVersion < 274)
		then
			for k, effect_indicator in pairs (Enemy.DefaultSettings.effectsIndicators)
			do
				if (effect_indicator.name == L"Gift of Life")
				then
					tinsert (Enemy.Settings.effectsIndicators, k, Enemy.clone (effect_indicator))
				end
			end
		end
	end

	g.frames = {}

	for group_index = 1, Enemy.MaxGroups
	do
		local group_frames = {}
		tinsert (g.frames, group_frames)

		for index = 1, 6
		do
			local frame = EnemyUnitFrame.New (group_index, index)
			tinsert (group_frames, frame)
		end
	end

	-- static events
	Enemy.AddEventHandler ("UnitFrames", "SettingsChanged", Enemy.UnitFrames_OnSettingsChanged)

	Enemy.AddEventHandler ("UnitFrames", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections,
		{
			name = "UnitFrames",
			title = L"Unit frames",
			templateName = "EnemyUnitFramesConfiguration",
			onInitialize = Enemy.UnitFramesUI_ConfigDialog_OnInitialize,
			onLoad = Enemy.UnitFramesUI_ConfigDialog_OnLoad,
			onSave = Enemy.UnitFramesUI_ConfigDialog_OnSave,
			onClose = Enemy.UnitFramesUI_ConfigDialog_OnClose,
			onReset = Enemy.UnitFramesUI_ConfigDialog_OnReset
		})
	end)

	Enemy.TriggerEvent ("UnitFramesInitialized")
end


function Enemy.UnitFramesGetMaxGroups ()
	if (g.settings.unitFramesTestMode) then return Enemy.MaxGroups end
	return Enemy.GroupsGetMaxGroups ()
end


function Enemy._UnitFramesDisableAll ()

	for group_index = 1, Enemy.MaxGroups
	do
		for index = 1, 6
		do
			g.frames[group_index][index]:Disable ()
		end
	end
end


function Enemy._UnitFramesEnabledChanged (enable)

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable

	if (g.isPluginEnabled)
	then
		Enemy.AddEventHandler ("UnitFrames", "GroupsTypeUpdated", Enemy.UnitFrames_GroupsTypeUpdated)
		Enemy.AddEventHandler ("UnitFrames", "GroupsUpdated", Enemy.UnitFrames_OnGroupsUpdated)
		Enemy.AddEventHandler ("UnitFrames", "GroupsPlayerUpdated", Enemy.UnitFrames_OnGroupsPlayerUpdated)
		Enemy.AddEventHandler ("UnitFrames", "GroupsPlayerDistanceUpdated", Enemy.UnitFrames_OnGroupsPlayerDistanceUpdated)
		Enemy.AddEventHandler ("UnitFrames", "GroupsPlayerEffectsUpdated", Enemy.UnitFrames_OnGroupsPlayerEffectsUpdated)
		Enemy.AddEventHandler ("UnitFrames", "GroupsTargetChanged", Enemy.UnitFrames_OnGroupsTargetChanged)
	else
		Enemy.RemoveEventHandler ("UnitFrames", "GroupsTypeUpdated")
		Enemy.RemoveEventHandler ("UnitFrames", "GroupsUpdated")
		Enemy.RemoveEventHandler ("UnitFrames", "GroupsPlayerUpdated")
		Enemy.RemoveEventHandler ("UnitFrames", "GroupsPlayerDistanceUpdated")
		Enemy.RemoveEventHandler ("UnitFrames", "GroupsPlayerEffectsUpdated")
		Enemy.RemoveEventHandler ("UnitFrames", "GroupsTargetChanged")

		for group_index = 1, Enemy.MaxGroups
		do
			for index = 1, 6
			do
				g.frames[group_index][index]:Disable ()
			end
		end
	end
end


function Enemy.UnitFrames_OnSettingsChanged (settings)

	g.positionMatrix = nil
	g.settings = settings

	Enemy._UnitFramesEnabledChanged (g.settings.unitFramesEnabled)
	Enemy._UnitFramesDisableAll ()

	WindowSetShowing (g.anchorWindows[2].windowName, g.settings.unitFramesDetachMyGroup)

	if (g.settings.unitFramesEnabled)
	then
		for group_index = 1, Enemy.MaxGroups
		do
			for index = 1, 6
			do
				g.frames[group_index][index]:ApplySettings (settings)
			end
		end

		Enemy.UnitFrames_OnGroupsUpdated (true)
		Enemy.UpdateEffects ()
	end
end


function Enemy._UnitFramesRecalculatePosititionMatrix (isTestMode)

	local max_groups = Enemy.UnitFramesGetMaxGroups ()
	local doGroups = isTestMode

	local archetype_sorting = {}
	if (g.settings.unitFramesSortingEnabled)
	then
		for k = 1, 3
		do
			archetype_sorting[g.settings.unitFramesSorting[k]] = k
		end
	end

	local global_scale = InterfaceCore.GetScale ()

	local group_pos_matrix, group_max_x, group_max_y = Enemy.CalculatePositioningMatrix (
		0, 0,
		g.settings.unitFramesSize[1] * g.settings.unitFramesScale,
		g.settings.unitFramesSize[2] * g.settings.unitFramesScale,
		g.settings.unitFramesDirection1, g.settings.unitFramesPadding1, g.settings.unitFramesCount1,
		g.settings.unitFramesDirection2, g.settings.unitFramesPadding2, mmax (1, mceil (6 / g.settings.unitFramesCount1))
	)

	local groups_pos_matrix, groups_max_x, groups_max_y = Enemy.CalculatePositioningMatrix (
		0, 0,
		group_max_x, group_max_y,
		g.settings.unitFramesGroupsDirection1, g.settings.unitFramesGroupsPadding1, g.settings.unitFramesGroupsCount1,
		g.settings.unitFramesGroupsDirection2, g.settings.unitFramesGroupsPadding2, mmax (1, mceil (max_groups / g.settings.unitFramesGroupsCount1))
	)

	g.positionMatrix = {}

	local base_x = 10
	local base_y = 10

	local groups_indexes = {}
	for _idx = 1, max_groups do tinsert (groups_indexes, _idx) end

	local me = Enemy.groups.player

	if (me and me:IsInGroup())
	then
		if (g.settings.unitFramesDetachMyGroup)
		then
			-- make our group last (prepare for detach)
			tremove (groups_indexes, me.groupIndex)
			tinsert (groups_indexes, max_groups, me.groupIndex)
		else
			if (g.settings.unitFramesMyGroupFirst and me.groupIndex ~= 1)
			then
				tremove (groups_indexes, me.groupIndex)
				tinsert (groups_indexes, 1, me.groupIndex)
			end
		end
	end

	local pos_matrix_group_index = 1

	for k = 1, max_groups
	do
		local group_index = groups_indexes[k]
		local frames_group = g.frames[group_index]
		local frames_group_pos = {}

		doGroups = isTestMode
		if not doGroups then
			doGroups = (Enemy.groups.groupsPlayersCount[group_index] > 0 and g.groupFilter[group_index])
		end

		if (doGroups)
		then
			local group_base_pos = nil

			if (group_index == me.groupIndex and g.settings.unitFramesDetachMyGroup)
			then
				group_base_pos =
				{
					x = 0,
					y = 0,
					anchorWindow = g.anchorWindows[2]
				}
			else
				group_base_pos = groups_pos_matrix[pos_matrix_group_index]
				pos_matrix_group_index = pos_matrix_group_index + 1
			end

			local frames_indexes = { 1, 2, 3, 4, 5, 6 }

			if (g.settings.unitFramesSortingEnabled)
			then
				tsort (frames_indexes, function (index1, index2)

					local frame1 = frames_group[index1]
					local frame2 = frames_group[index2]
					local frame1_ok = frame1 and frame1:IsEnabled ()
					local frame2_ok = frame2 and frame2:IsEnabled ()

					if (frame1_ok and frame2_ok)
					then
						local a = archetype_sorting[Enemy.careerArchetypes[frame1.playerCareer]]
						local b = archetype_sorting[Enemy.careerArchetypes[frame2.playerCareer]]

						if (a == b)
						then
							return frame1.playerName < frame2.playerName
						end

						return a < b

					elseif (not frame1_ok and not frame2_ok)
					then
						return index1 < index2

					elseif (frame1_ok)
					then
						return true
					end

					return false
				end)
			end

			for index = 1, 6
			do
				frames_group_pos[frames_indexes[index]] =
				{
					x = group_base_pos.x + base_x + group_pos_matrix[index].x,
					y = group_base_pos.y + base_y + group_pos_matrix[index].y,
					anchorWindow = group_base_pos.anchorWindow or g.anchorWindows[1]
				}
			end
		end

		g.positionMatrix[group_index] = frames_group_pos
	end

	for group_index = 1, max_groups
	do
		doGroups = isTestMode
		if not doGroups then
			doGroups = (Enemy.groups.groupsPlayersCount[group_index] > 0)
		end

		if (doGroups)
		then
			for index = 1, 6
			do
				g.frames[group_index][index]:UpdatePosition ()
			end
		end
	end
end


function Enemy.UnitFrames_GroupsTypeUpdated ()
	Enemy._UnitFramesDisableAll ()
end


function Enemy.UnitFrames_OnGroupsUpdated (playerGroupChanged)

	if (playerGroupChanged)
	then
		Enemy._UnitFramesDisableAll ()
	end

	g.groupFilter = { true, true, true, true, true, true }
	if (g.settings.unitFramesHideWhenSolo and Enemy.groups.groupType == Enemy.GroupTypes.Solo)
	then
		g.groupFilter = { false, false, false, false, false, false }

	elseif (g.settings.unitFramesMyGroupOnly and Enemy.groups.player and Enemy.groups.player.groupIndex)
	then
		g.groupFilter = { false, false, false, false, false, false }
		g.groupFilter[Enemy.groups.player.groupIndex] = true
	end

	if (g.settings.unitFramesHideMyGroup and Enemy.groups.player and Enemy.groups.player.groupIndex)
	then
		g.groupFilter[Enemy.groups.player.groupIndex] = false
	end

	local max_groups = Enemy.UnitFramesGetMaxGroups ()
	for group_index = 1, max_groups
	do
		local group = Enemy.groups.groups[group_index]

		for index = 1, 6
		do
			local player = group[index]
			local frame = g.frames[group_index][index]

			if (not player or not g.groupFilter[group_index])
			then
				frame:Disable ()
			else
				frame:Enable ()
				frame:Update (player)
			end
		end
	end

	Enemy._UnitFramesRecalculatePosititionMatrix ()
end


function Enemy.UnitFrames_OnGroupsPlayerUpdated (player)
	if (not player:IsInGroup ()) then return end
	g.frames[player.groupIndex][player.index]:Update (player)
end


function Enemy.UnitFrames_OnGroupsPlayerDistanceUpdated (player)
	if (not player:IsInGroup ()) then return end
	g.frames[player.groupIndex][player.index]:UpdateDistance (player)
end


function Enemy.UnitFrames_OnGroupsPlayerEffectsUpdated (player)
	if (not player:IsInGroup ()) then return end
	g.frames[player.groupIndex][player.index]:UpdateEffects (player)
end


function Enemy.UnitFrames_OnGroupsTargetChanged (oldTarget, newTarget)

	if (g.selectedFrame)
	then
		--g.selectedFrame:Unselect ()

		if (oldTarget and g.selectedFrame.playerName == oldTarget.name)
		then
			g.selectedFrame:Update (oldTarget)
		end

		g.selectedFrame = nil
	end

	if (not newTarget or not newTarget:IsInGroup ()) then return end

	g.selectedFrame = g.frames[newTarget.groupIndex][newTarget.index]
	--g.selectedFrame:Select ()
end


function Enemy._DebugUnitFrame (playerName)

	local frame = nil

	local max_groups = Enemy.UnitFramesGetMaxGroups ()
	for group_index = 1, max_groups
	do
		for index = 1, 6
		do
			local f = g.frames[group_index][index]
			if (f.isEnabled and f.playerName == playerName)
			then
				frame = f
				break
			end
		end
	end

	if (not frame) then return end

	DebugWindow.ClearTextLog()
	d (frame.effectsIndicators)
	d ("-------------------------------------------")
end


--------------------------------------------------------------- UI: Anchor window
local function GetAnchorWindowData (wn)

	local awn = wn or SystemData.MouseOverWindow.name
	if (not awn) then return nil end

	local index = awn:match ("EnemyUnitFramesAnchor(%d+)")
	if (not index) then return nil end

	return g.anchorWindows[tonumber (index)]
end

function Enemy.UnitFramesUI_Anchor_OnLButtonDown ()
	local aw = GetAnchorWindowData (SystemData.ActiveWindow.name)
	if (not aw) then return end
	aw.isDragged = true
end

function Enemy.UnitFramesUI_Anchor_OnLButtonUp ()
	local aw = GetAnchorWindowData (SystemData.ActiveWindow.name)
	if (not aw) then return end
	aw.isDragged = false
end

function Enemy.UnitFramesUI_Anchor_OnMouseOver ()
	local aw = GetAnchorWindowData ()
	if (not aw or aw.isDragged) then return end
	WindowStartAlphaAnimation (aw.windowName, Window.AnimationType.SINGLE_NO_RESET, 0, 0.5, 0.3, true, 0, 1)
end

function Enemy.UnitFramesUI_Anchor_OnMouseOverEnd ()
	local aw = GetAnchorWindowData ()
	if (not aw or aw.isDragged) then return end
	WindowStartAlphaAnimation (aw.windowName, Window.AnimationType.SINGLE_NO_RESET, 0.5, 0, 0.3, true, 0, 1)
end



--------------------------------------------------------------- UI: Configuration
local config_dlg

function Enemy.UnitFramesResetSettings ()

	for k, v in pairs (Enemy.Settings)
	do
		if (not k:match("^unitFrames.*")) then continue end
		Enemy.Settings[k] = nil
	end

	Enemy.Settings.effectsIndicators = nil
	Enemy.Settings.clickCastings = nil

	Enemy.Print ("Unit frames settings has been reset")
	InterfaceCore.ReloadUI ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnReset (section)
	Enemy.UnitFramesResetSettings ()
end


function Enemy.UnitFramesUI_ConfigDialog_Export ()

	Enemy.ConfigurationWindowSaveData (config_dlg.cwnImportExport, config_dlg.importExportSettings)

	local data = {}

	if (config_dlg.importExportSettings.core)
	then
		data.core =
		{
			unitFramesEnabled = config_dlg.unitFramesEnabled,
			unitFramesSortingEnabled = config_dlg.unitFramesSortingEnabled,
			unitFramesSorting = config_dlg.unitFramesSorting,
			unitFramesMyGroupOnly = config_dlg.unitFramesMyGroupOnly,
			unitFramesHideWhenSolo = config_dlg.unitFramesHideWhenSolo
		}
	end

	if (config_dlg.importExportSettings.effectsIndicators)
	then
		data.effectsIndicators = config_dlg.effectsIndicators
	end

	if (config_dlg.importExportSettings.clickCasting)
	then
		data.clickCastings = config_dlg.clickCastings
	end

	if (config_dlg.importExportSettings.coreAppearance)
	then
		data.coreAppearance =
		{
			unitFramesSize = config_dlg.unitFramesSize,
			unitFramesLayer = config_dlg.unitFramesLayer,
			unitFramesScale = config_dlg.unitFramesScale,

			unitFramesDirection1 = config_dlg.unitFramesDirection1,
			unitFramesPadding1 = config_dlg.unitFramesPadding1,
			unitFramesCount1 = config_dlg.unitFramesCount1,
			unitFramesDirection2 = config_dlg.unitFramesDirection2,
			unitFramesPadding2 = config_dlg.unitFramesPadding2,

			unitFramesMyGroupFirst = config_dlg.unitFramesMyGroupFirst,
			unitFramesDetachMyGroup = config_dlg.unitFramesDetachMyGroup,
			unitFramesGroupsDirection1 = config_dlg.unitFramesGroupsDirection1,
			unitFramesGroupsPadding1 = config_dlg.unitFramesGroupsPadding1,
			unitFramesGroupsCount1 = config_dlg.unitFramesGroupsCount1,
			unitFramesGroupsDirection2 = config_dlg.unitFramesGroupsDirection2,
			unitFramesGroupsPadding2 = config_dlg.unitFramesGroupsPadding2
		}
	end

	if (config_dlg.importExportSettings.visualParts)
	then
		data.unitFramesParts = config_dlg.unitFramesParts
	end

	data.version = Enemy.Settings.version
	data = Enemy.clone2 (data)

	local str = Enemy.SerializeTable (data)

	Enemy.UI_TextEntryDialog_Open (L"Export", L"Copy (Ctrl+C) this data string", str)
end


function Enemy.UnitFramesUI_ConfigDialog_Import ()

	Enemy.UI_TextEntryDialog_Open (L"Import", L"Paste (Ctrl+V) data string", L"",
		function (str)

			cls()
			d (str)

			local data = Enemy.DeserializeTable (str)
			if (not data) then return end

			--d (data)

			Enemy.ConfigurationWindowSaveData (config_dlg.cwnImportExport, config_dlg.importExportSettings)

			if (config_dlg.importExportSettings.core and data.core)
			then
				config_dlg.unitFramesEnabled = data.core.unitFramesEnabled
				config_dlg.unitFramesSortingEnabled = data.core.unitFramesSortingEnabled
				config_dlg.unitFramesSorting = Enemy.clone (data.core.unitFramesSorting)
				config_dlg.unitFramesMyGroupOnly = data.core.unitFramesMyGroupOnly
				config_dlg.unitFramesHideWhenSolo = data.core.unitFramesHideWhenSolo
			end

			if (config_dlg.importExportSettings.effectsIndicators and data.effectsIndicators)
			then
				config_dlg.effectsIndicators = Enemy.clone (data.effectsIndicators)
			end

			if (config_dlg.importExportSettings.clickCasting and data.clickCastings)
			then
				config_dlg.clickCastings = Enemy.clone (data.clickCastings)
			end

			if (config_dlg.importExportSettings.coreAppearance and data.coreAppearance)
			then
				config_dlg.unitFramesSize = data.coreAppearance.unitFramesSize
				config_dlg.unitFramesLayer = data.coreAppearance.unitFramesLayer
				config_dlg.unitFramesScale = data.coreAppearance.unitFramesScale

				config_dlg.unitFramesDirection1 = data.coreAppearance.unitFramesDirection1
				config_dlg.unitFramesPadding1 = data.coreAppearance.unitFramesPadding1
				config_dlg.unitFramesCount1 = data.coreAppearance.unitFramesCount1
				config_dlg.unitFramesDirection2 = data.coreAppearance.unitFramesDirection2
				config_dlg.unitFramesPadding2 = data.coreAppearance.unitFramesPadding2

				config_dlg.unitFramesMyGroupFirst = data.coreAppearance.unitFramesMyGroupFirst
				config_dlg.unitFramesDetachMyGroup = data.coreAppearance.unitFramesDetachMyGroup
				config_dlg.unitFramesGroupsDirection1 = data.coreAppearance.unitFramesGroupsDirection1
				config_dlg.unitFramesGroupsPadding1 = data.coreAppearance.unitFramesGroupsPadding1
				config_dlg.unitFramesGroupsCount1 = data.coreAppearance.unitFramesGroupsCount1
				config_dlg.unitFramesGroupsDirection2 = data.coreAppearance.unitFramesGroupsDirection2
				config_dlg.unitFramesGroupsPadding2 = data.coreAppearance.unitFramesGroupsPadding2
			end

			if (config_dlg.importExportSettings.visualParts and data.unitFramesParts)
			then
				config_dlg.unitFramesParts = Enemy.clone (data.unitFramesParts)
			end

			Enemy._UnitFramesUI_ConfigDialog_OnLoad ()
			ScrollWindowSetOffset ("EnemyConfigDialogSectionsUnitFramesContent", 0)
		end)
end


local directionsSelectData =
{
	{ text = L"up", value = 1 },
	{ text = L"down", value = 2 },
	{ text = L"left", value = 3 },
	{ text = L"right", value = 4 }
}


config_dlg =
{
	needTestSettings = false,

	mainProperties =
	{
		unitFramesMyGroupOnly =
		{
			key = "unitFramesMyGroupOnly",
			order = 10,
			name = L"My group only",
			type = "bool",
			default = Enemy.DefaultSettings.unitFramesMyGroupOnly,
			paddingTop = 40,
			tooltip = L"Show unitframes only for your group"
		},

		unitFramesMyGroupFirst =
		{
			key = "unitFramesMyGroupFirst",
			order = 20,
			name = L"My group first",
			type = "bool",
			default = Enemy.DefaultSettings.unitFramesMyGroupFirst,
			tooltip = L"Show my group first then all other groups (scroll futher down to change groups stack direction)"
		},

		unitFramesDetachMyGroup =
		{
			key = "unitFramesDetachMyGroup",
			order = 30,
			name = L"Detach my group",
			type = "bool",
			default = Enemy.DefaultSettings.unitFramesDetachMyGroup,
			tooltip = L"Checking this will create sepparate anchor window for your group to be bind uppon. You can freely drag your group window sepparately from other groups unit frames."
		},

		unitFramesHideMyGroup =
		{
			key = "unitFramesHideMyGroup",
			order = 40,
			name = L"Hide my group",
			type = "bool",
			default = Enemy.DefaultSettings.unitFramesHideMyGroup
		},

		unitFramesHideWhenSolo =
		{
			key = "unitFramesHideWhenSolo",
			order = 50,
			name = L"Hide when solo",
			type = "bool",
			default = Enemy.DefaultSettings.unitFramesHideWhenSolo,
			tooltip = L"Hide your unitframe when you feeling lonely :("
		},

		unitFramesTooltipMode =
		{
			key = "unitFramesTooltipMode",
			order = 60,
			name = L"Tooltip display mode",
			type = "select",
			default = Enemy.DefaultSettings.unitFramesTooltipMode,
			values =
			{
				{ text = L"always", value = "always" },
				{ text = L"never", value = "never" },
				{ text = L"when holding shift", value = "shift" },
				{ text = L"when holding alt", value = "alt" },
				{ text = L"when holding ctrl", value = "ctrl" }
			}
		}
	},

	appearanceProperties =
	{
		appearanceTitle =
		{
			key = "appearanceTitle",
			order = 10,
			name = L"Appearance",
			type = "title",
			paddingTop = 60
		},

		unitFramesTestMode =
		{
			key = "unitFramesTestMode",
			order = 20,
			name = L"Test mode",
			type = "bool",
			default = false,
			tooltip = L"Check this on several times to get new example data."
		},

		unitFramesSize =
		{
			key = "unitFramesSize",
			order = 30,
			name = L"Size (XY)",
			type = "int[]",
			size = 2,
			default = Enemy.DefaultSettings.unitFramesSize,
			min = {0, 0},
			max = {5000, 5000},
			tooltip = L"This is the size of virtual box where all visual parts will be placed (click on checkbox below to see it). Changing this will change the size of the area where unit frame will react on mouse clicks. To change HP bar size scroll down and edit HP visual part.",
			paddingTop = 40
		},
		unitFramesShowBoundingBox =
		{
			key = "unitFramesShowBoundingBox",
			order = 40,
			name = L"Show virtual box",
			type = "bool",
			default = false,
			tooltip = L"Enable this to see unit frames virtual box where all visual parts will be placed. This area responsible for mouse clicks processing."
		},

		unitFramesLayer =
		{
			key = "unitFramesLayer",
			order = 50,
			name = L"Layer",
			type = "select",
			default = Enemy.DefaultSettings.unitFramesLayer,
			values = Enemy.ConfigurationWindowGetLayersSelectValues,
			paddingTop = 40,
		},
		unitFramesScale =
		{
			key = "unitFramesScale",
			order = 55,
			name = L"Scale",
			type = "float",
			default = Enemy.DefaultSettings.unitFramesScale,
			min = 0,
			max = 5
		},

		unitFramesDirection1 =
		{
			key = "unitFramesDirection1",
			order = 60,
			name = L"Direction 1",
			type = "select",
			default = Enemy.DefaultSettings.unitFramesDirection1,
			values = directionsSelectData,
			paddingTop = 40
		},
		unitFramesPadding1 =
		{
			key = "unitFramesPadding1",
			order = 70,
			name = L"Padding 1",
			type = "int",
			default = Enemy.DefaultSettings.unitFramesPadding1,
			min = 0,
			max = 1000
		},
		unitFramesCount1 =
		{
			key = "unitFramesCount1",
			order = 80,
			name = L"Count 1",
			type = "int",
			default = Enemy.DefaultSettings.unitFramesCount1,
			min = 1,
			max = 6
		},

		unitFramesDirection2 =
		{
			key = "unitFramesDirection2",
			order = 90,
			name = L"Direction 2",
			type = "select",
			default = Enemy.DefaultSettings.unitFramesDirection2,
			values = directionsSelectData,
			paddingTop = 40
		},
		unitFramesPadding2 =
		{
			key = "unitFramesPadding2",
			order = 100,
			name = L"Padding 2",
			type = "int",
			default = Enemy.DefaultSettings.unitFramesPadding2,
			min = 0,
			max = 1000
		},
		unitFramesCount2 =
		{
			key = "unitFramesCount2",
			order = 110,
			name = L"Count 2",
			type = "int",
			default = Enemy.DefaultSettings.unitFramesCount2,
			min = 1,
			max = Enemy.MaxGroups
		},

		unitFramesGroupsDirection1 =
		{
			key = "unitFramesGroupsDirection1",
			order = 130,
			name = L"Groups direction 1",
			type = "select",
			default = Enemy.DefaultSettings.unitFramesGroupsDirection1,
			values = directionsSelectData
		},
		unitFramesGroupsPadding1 =
		{
			key = "unitFramesGroupsPadding1",
			order = 140,
			name = L"Groups padding 1",
			type = "int",
			default = Enemy.DefaultSettings.unitFramesGroupsPadding1,
			min = 0,
			max = 1000
		},
		unitFramesGroupsCount1 =
		{
			key = "unitFramesGroupsCount1",
			order = 150,
			name = L"Groups count 1",
			type = "int",
			default = Enemy.DefaultSettings.unitFramesGroupsCount1,
			min = 1,
			max = Enemy.MaxGroups
		},

		unitFramesGroupsDirection2 =
		{
			key = "unitFramesGroupsDirection2",
			order = 160,
			name = L"Groups direction 2",
			type = "select",
			default = Enemy.DefaultSettings.unitFramesGroupsDirection2,
			values = directionsSelectData,
			paddingTop = 40
		},
		unitFramesGroupsPadding2 =
		{
			key = "unitFramesGroupsPadding2",
			order = 170,
			name = L"Groups padding 2",
			type = "int",
			default = Enemy.DefaultSettings.unitFramesGroupsPadding2,
			min = 0,
			max = 1000
		}
	},

	importExportProperties =
	{
		title =
		{
			key = "title",
			order = 10,
			name = L"Import / export settings",
			type = "title",
			paddingTop = 100
		},

		core =
		{
			key = "core",
			order = 20,
			name = L"Core settings",
			type = "bool",
			default = true
		},

		effectsIndicators =
		{
			key = "effectsIndicators",
			order = 30,
			name = L"Effects indicators settings",
			type = "bool",
			default = true
		},

		clickCasting =
		{
			key = "clickCasting",
			order = 30,
			name = L"Click casting settings",
			type = "bool",
			default = true
		},

		coreAppearance =
		{
			key = "coreAppearance",
			order = 40,
			name = L"Core appearance settings",
			type = "bool",
			default = true
		},

		visualParts =
		{
			key = "visualParts",
			order = 50,
			name = L"Visual parts settings",
			type = "bool",
			default = true
		},

		importOk =
		{
			key = "importOk",
			order = 60,
			name = L"Import",
			type = "button",
			onClick = Enemy.UnitFramesUI_ConfigDialog_Import,
			paddingTop = 20,
			windowWidth = 150
		},

		exportOk =
		{
			key = "exportOk",
			order = 70,
			name = L"Export",
			type = "button",
			onClick = Enemy.UnitFramesUI_ConfigDialog_Export,
			windowWidth = 150
		}
	},

	importExportSettings = {}
}


function Enemy.UnitFramesUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section

	LabelSetText (config_dlg.section.windowName.."ContentScrollChildEnabledLabel", L"Enable unit frames")
	LabelSetText (config_dlg.section.windowName.."ContentScrollChildSortingEnabledLabel", L"Enable group sorting")

	for k = 1, 3
	do
		ComboBoxAddMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting"..k, L"Tanks")
		ComboBoxAddMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting"..k, L"Dps")
		ComboBoxAddMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting"..k, L"Healers")
	end

	LabelSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsLabel", L"Effects indicators")
	WindowSetTintColor (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsListBackground", 100, 100, 100)
	WindowSetAlpha (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsListBackground", 0.5)
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsAddButton", L"Add")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsEditButton", L"Edit")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsDeleteButton", L"Delete")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsUpButton", L"Up")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsDownButton", L"Down")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsImportButton", L"Import")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsExportButton", L"Export")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsResetButton", L"Reset")

	LabelSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsLabel", L"Click casting")
	WindowSetTintColor (config_dlg.section.windowName.."ContentScrollChildClickCastingsListBackground", 100, 100, 100)
	WindowSetAlpha (config_dlg.section.windowName.."ContentScrollChildClickCastingsListBackground", 0.5)
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsAddButton", L"Add")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsEditButton", L"Edit")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsDeleteButton", L"Delete")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsUpButton", L"Up")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsDownButton", L"Down")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsImportButton", L"Import")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsExportButton", L"Export")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsResetButton", L"Reset")

	LabelSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsLabel", L"Visual parts")
	WindowSetTintColor (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsListBackground", 100, 100, 100)
	WindowSetAlpha (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsListBackground", 0.5)
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsAddButton", L"Add")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsEditButton", L"Edit")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsDeleteButton", L"Delete")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsUpButton", L"Up")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsDownButton", L"Down")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsImportButton", L"Import")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsExportButton", L"Export")
	ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsResetButton", L"Reset")

	local root = config_dlg.section.windowName.."ContentScrollChildApr"
	config_dlg.cwnAppearance = root.."C"
	local width, height = Enemy.CreateConfigurationWindow (config_dlg.cwnAppearance, root, config_dlg.appearanceProperties, Enemy.UnitFramesUI_ConfigDialog_TestSettings)
	WindowSetDimensions (root, width, height)

	local root = config_dlg.section.windowName.."ContentScrollChildMain"
	config_dlg.cwnMain = root.."C"
	local width, height = Enemy.CreateConfigurationWindow (config_dlg.cwnMain, root, config_dlg.mainProperties, Enemy.UnitFramesUI_ConfigDialog_TestSettings)
	WindowSetDimensions (root, width, height)

--	local root = config_dlg.section.windowName.."ContentScrollChild"
--	config_dlg.cwnImportExport = root.."ImpExp"
--	local width, height = Enemy.CreateConfigurationWindow (config_dlg.cwnImportExport, root, config_dlg.importExportProperties)
--	WindowAddAnchor (config_dlg.cwnImportExport, "bottomleft", root.."UnitFramePartsAddButton", "topleft", 0, 0)
--	Enemy.ConfigurationWindowReset (config_dlg.cwnImportExport)

	ScrollWindowUpdateScrollRect (config_dlg.section.windowName.."Content")
end


function Enemy.UnitFramesUI_ConfigDialog_OnClose (section)
	Enemy.RemoveTask ("unitframes config test settings")

	for group_index = 1, Enemy.MaxGroups
	do
		for index = 1, 6
		do
			g.frames[group_index][index]:BoundingBoxSetShowing (false)
		end
	end
end


function Enemy.UnitFramesUI_ConfigDialog_OnLoad (section)

	config_dlg.unitFramesTestMode = false
	config_dlg.unitFramesShowBoundingBox = false

	config_dlg.unitFramesEnabled = Enemy.Settings.unitFramesEnabled
	config_dlg.unitFramesSortingEnabled = Enemy.Settings.unitFramesSortingEnabled
	config_dlg.unitFramesSorting = Enemy.clone (Enemy.Settings.unitFramesSorting)
	config_dlg.unitFramesMyGroupOnly = Enemy.Settings.unitFramesMyGroupOnly
	config_dlg.unitFramesMyGroupFirst = Enemy.Settings.unitFramesMyGroupFirst
	config_dlg.unitFramesDetachMyGroup = Enemy.Settings.unitFramesDetachMyGroup
	config_dlg.unitFramesHideMyGroup = Enemy.Settings.unitFramesHideMyGroup
	config_dlg.unitFramesHideWhenSolo = Enemy.Settings.unitFramesHideWhenSolo
	config_dlg.unitFramesTooltipMode = Enemy.Settings.unitFramesTooltipMode

	config_dlg.unitFramesSize = Enemy.Settings.unitFramesSize
	config_dlg.unitFramesLayer = Enemy.Settings.unitFramesLayer
	config_dlg.unitFramesScale = Enemy.Settings.unitFramesScale

	config_dlg.unitFramesDirection1 = Enemy.Settings.unitFramesDirection1
	config_dlg.unitFramesPadding1 = Enemy.Settings.unitFramesPadding1
	config_dlg.unitFramesCount1 = Enemy.Settings.unitFramesCount1
	config_dlg.unitFramesDirection2 = Enemy.Settings.unitFramesDirection2
	config_dlg.unitFramesPadding2 = Enemy.Settings.unitFramesPadding2

	config_dlg.unitFramesGroupsDirection1 = Enemy.Settings.unitFramesGroupsDirection1
	config_dlg.unitFramesGroupsPadding1 = Enemy.Settings.unitFramesGroupsPadding1
	config_dlg.unitFramesGroupsCount1 = Enemy.Settings.unitFramesGroupsCount1
	config_dlg.unitFramesGroupsDirection2 = Enemy.Settings.unitFramesGroupsDirection2
	config_dlg.unitFramesGroupsPadding2 = Enemy.Settings.unitFramesGroupsPadding2


	config_dlg.unitFramesParts = {}
	for _, v in pairs (Enemy.Settings.unitFramesParts)
	do
		tinsert (config_dlg.unitFramesParts, EnemyUnitFramePart.New (v))
	end


	config_dlg.effectsIndicators = {}
	for _, v in pairs (Enemy.Settings.effectsIndicators)
	do
		tinsert (config_dlg.effectsIndicators, EnemyEffectsIndicator.New (v))
	end


	config_dlg.clickCastings = {}
	for _, v in pairs (Enemy.Settings.clickCastings)
	do
		tinsert (config_dlg.clickCastings, EnemyClickCasting.New (v))
	end


	Enemy._UnitFramesUI_ConfigDialog_OnLoad ()
end


function Enemy._UnitFramesUI_ConfigDialog_OnLoad ()

	config_dlg.isLoaded = false

	ButtonSetPressedFlag (config_dlg.section.windowName.."ContentScrollChildEnabled", config_dlg.unitFramesEnabled)
	ButtonSetPressedFlag (config_dlg.section.windowName.."ContentScrollChildSortingEnabled", config_dlg.unitFramesSortingEnabled)

	for k = 1, 3
	do
		ComboBoxSetSelectedMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting"..k, config_dlg.unitFramesSorting[k])
		ComboBoxSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildSorting"..k, not config_dlg.unitFramesSortingEnabled)
	end

	Enemy.ConfigurationWindowLoadData (config_dlg.cwnMain, config_dlg)
	Enemy.ConfigurationWindowLoadData (config_dlg.cwnAppearance, config_dlg)

	config_dlg.unitFramesPartsListSelectedIndex = nil
	config_dlg.effectsIndicatorsListSelectedIndex = nil
	config_dlg.clickCastingsListSelectedIndex = nil

	Enemy.RemoveTask ("unitframes config test settings")
	Enemy.AddTaskAction ("unitframes config test settings", function ()

		if (config_dlg.needTestSettings and config_dlg.isLoaded)
		then
			Enemy._UnitFramesUI_ConfigDialog_TestSettings ()
			config_dlg.needTestSettings = false
		end

		return false
	end)

	config_dlg.isLoaded = true
	Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
	Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
	Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnPartPropertyBoolValueClick ()

	if (config_dlg.isLoading) then return end

	local wn = SystemData.ActiveWindow.name
	if (ButtonGetDisabledFlag (wn.."Value")) then return end

	local v = ButtonGetPressedFlag (wn.."Value")
	ButtonSetPressedFlag (wn.."Value", not v)

	Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnEnabledChanged ()

	if (not config_dlg.isLoaded) then return end

	config_dlg.unitFramesEnabled = not config_dlg.unitFramesEnabled
	ButtonSetPressedFlag (config_dlg.section.windowName.."ContentScrollChildEnabled", config_dlg.unitFramesEnabled)

	Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
end


local function UpdateTestMode ()

	if (config_dlg._prev_unitFramesTestMode == config_dlg.unitFramesTestMode) then return end

	config_dlg._prev_unitFramesTestMode = config_dlg.unitFramesTestMode
	config_dlg.testData = {}

	for group_index = 1, Enemy.MaxGroups
	do
		local test_group = {}
		tinsert (config_dlg.testData, test_group)

		for index = 1, 6
		do
			test_group[index] = EnemyPlayer.GetRandomExample (group_index, index)
			test_group[index].isInPlayerGroup = (group_index == Enemy.groups.player.groupIndex)
			test_group[index].isSelf = false
		end
	end
end


function Enemy.UnitFramesUI_ConfigDialog_OnSortingEnabledChanged ()

	if (not config_dlg.isLoaded) then return end

	config_dlg.unitFramesSortingEnabled = not config_dlg.unitFramesSortingEnabled
	ButtonSetPressedFlag (config_dlg.section.windowName.."ContentScrollChildSortingEnabled", config_dlg.unitFramesSortingEnabled)

	for k = 1, 3
	do
		ComboBoxSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildSorting"..k, not config_dlg.unitFramesSortingEnabled)
	end

	Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
end


local function UnitFramesUI_ConfigDialog_OnSortingNChanged (n)

	if (not config_dlg.isLoaded) then return end

	local old = config_dlg.unitFramesSorting[n]
	local new = ComboBoxGetSelectedMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting"..n)
	if (old == new) then return end

	for k = 1, 3
	do
		if (k ~= n and config_dlg.unitFramesSorting[k] == new)
		then
			ComboBoxSetSelectedMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting"..k, old)
			break
		end
	end

	Enemy.UnitFramesUI_ConfigDialog_OnSortingChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnSorting1Changed ()
	UnitFramesUI_ConfigDialog_OnSortingNChanged (1)
end


function Enemy.UnitFramesUI_ConfigDialog_OnSorting2Changed ()
	UnitFramesUI_ConfigDialog_OnSortingNChanged (2)
end


function Enemy.UnitFramesUI_ConfigDialog_OnSorting3Changed ()
	UnitFramesUI_ConfigDialog_OnSortingNChanged (3)
end


function Enemy.UnitFramesUI_ConfigDialog_OnSortingChanged ()

	if (not config_dlg.isLoaded) then return end

	config_dlg.unitFramesSorting =
	{
		ComboBoxGetSelectedMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting1"),
		ComboBoxGetSelectedMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting2"),
		ComboBoxGetSelectedMenuItem (config_dlg.section.windowName.."ContentScrollChildSorting3")
	}

	Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
end


-- =============================================================================== PARTS

function Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListPopulate ()

	if (not config_dlg.isLoaded) then return end

	local list = _G[config_dlg.section.windowName.."ContentScrollChildUnitFramePartsList"]
	if (list.PopulatorIndices == nil) then return end

	local row_window_name
	local data

	for k, v in ipairs (list.PopulatorIndices)
	do
		row_window_name = config_dlg.section.windowName.."ContentScrollChildUnitFramePartsListRow"..k
		data = Enemy.unitFramesPartsListData[v]

		if (v == config_dlg.unitFramesPartsListSelectedIndex)
		then
			WindowSetShowing (row_window_name.."Background", true)
			WindowSetAlpha (row_window_name.."Background", 0.5)
			WindowSetTintColor (row_window_name.."Background", 255, 204, 102)
		else
			WindowSetShowing (row_window_name.."Background", false)
		end

		if (data.isEnabled)
		then
			LabelSetText (row_window_name.."Text", data.name)
		else
			LabelSetText (row_window_name.."Text", L"[disabled] "..data.name)
		end
	end
end


function Enemy.UnitFramesUI_ConfigDialog_UpdateUnitFramePartsList ()

	if (not config_dlg.isLoaded) then return end

	Enemy.unitFramesPartsListData = {}
	Enemy.unitFramesPartsListIndexes = {}

	for k, data in ipairs(config_dlg.unitFramesParts)
	do
		tinsert (Enemy.unitFramesPartsListData, data)
		tinsert (Enemy.unitFramesPartsListIndexes, k)
	end

	ListBoxSetDisplayOrder (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsList", Enemy.unitFramesPartsListIndexes)
	Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListLButtonUp ()

	if (not config_dlg.isLoaded) then return end

	local data_index = ListBoxGetDataIndex (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsList", WindowGetId (SystemData.MouseOverWindow.name))

	if (data_index == nil)
	then
		config_dlg.unitFramesPartsListSelectedIndex = nil
	else
		config_dlg.unitFramesPartsListSelectedIndex = Enemy.unitFramesPartsListIndexes[data_index]
	end

	Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()

	if (not config_dlg.isLoaded) then return end

	local data = config_dlg.unitFramesParts[config_dlg.unitFramesPartsListSelectedIndex]
	if (not data)
	then
		config_dlg.unitFramesPartsListSelectedIndex = nil
	end

	Enemy.UnitFramesUI_ConfigDialog_UpdateUnitFramePartsList ()
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsEditButton", config_dlg.unitFramesPartsListSelectedIndex == nil)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsDeleteButton", config_dlg.unitFramesPartsListSelectedIndex == nil)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsUpButton", config_dlg.unitFramesPartsListSelectedIndex == nil or config_dlg.unitFramesPartsListSelectedIndex == 1)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsDownButton", config_dlg.unitFramesPartsListSelectedIndex == nil or config_dlg.unitFramesPartsListSelectedIndex == #config_dlg.unitFramesParts)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsExportButton", config_dlg.unitFramesPartsListSelectedIndex == nil)

	if (data and data.isEnabled)
	then
		ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsEnableButton", L"Disable")
	else
		ButtonSetText (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsEnableButton", L"Enable")
	end

	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsEnableButton", config_dlg.unitFramesPartsListSelectedIndex == nil)
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsAdd ()

	if (not config_dlg.isLoaded) then return end

	local obj = EnemyUnitFramePart.New ()

	obj:Edit (config_dlg, function (unitFramesPart)

		tinsert (config_dlg.unitFramesParts, unitFramesPart)

		config_dlg.unitFramesPartsListSelectedIndex = #config_dlg.unitFramesParts
		Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
	end)
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsEdit ()

	if (not config_dlg.isLoaded
		or not config_dlg.unitFramesPartsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsEditButton")) then return end

	local obj = config_dlg.unitFramesParts[config_dlg.unitFramesPartsListSelectedIndex]
	obj:Edit (config_dlg, function (unitFramesPart)
		Enemy.UnitFramesUI_ConfigDialog_UpdateUnitFramePartsList ()
	end)
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsDelete ()

	if (not config_dlg.isLoaded
		or not config_dlg.unitFramesPartsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsDeleteButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Delete part '"..Enemy.isNil (config_dlg.unitFramesParts[config_dlg.unitFramesPartsListSelectedIndex].name, L"")..L"' ?",
                                       L"Yes", function ()

                                       		table.remove (config_dlg.unitFramesParts, config_dlg.unitFramesPartsListSelectedIndex)
                                       		config_dlg.unitFramesPartsListSelectedIndex = nil
                                       		Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
                                       end,
                                       L"No")
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsUp ()

	if (not config_dlg.isLoaded
		or not config_dlg.unitFramesPartsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsUpButton")) then return end

	local index = config_dlg.unitFramesPartsListSelectedIndex

	local tmp = config_dlg.unitFramesParts[index - 1]
	config_dlg.unitFramesParts[index - 1] = config_dlg.unitFramesParts[index]
	config_dlg.unitFramesParts[index] = tmp

	config_dlg.unitFramesPartsListSelectedIndex = index - 1
	Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsDown ()

	if (not config_dlg.isLoaded
		or not config_dlg.unitFramesPartsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsDownButton")) then return end

	local index = config_dlg.unitFramesPartsListSelectedIndex

	local tmp = config_dlg.unitFramesParts[index + 1]
	config_dlg.unitFramesParts[index + 1] = config_dlg.unitFramesParts[index]
	config_dlg.unitFramesParts[index] = tmp

	config_dlg.unitFramesPartsListSelectedIndex = index + 1
	Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsImport ()

	if (not config_dlg.isLoaded) then return end

	Enemy.UI_TextEntryDialog_Open (L"Import", L"Paste (Ctrl+V) visual part data string", L"",
		function (str)

			local data = Enemy.DeserializeTable (str)
			if (not data) then return end

			local obj = EnemyUnitFramePart.New (data)

			obj:Edit (config_dlg, function (obj)

				tinsert (config_dlg.unitFramesParts, obj)

				config_dlg.unitFramesPartsListSelectedIndex = #config_dlg.unitFramesParts
				Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
			end)
		end)
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsExport ()

	if (not config_dlg.isLoaded
		or not config_dlg.unitFramesPartsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsExportButton")) then return end

	local obj = Enemy.clone2 (config_dlg.unitFramesParts[config_dlg.unitFramesPartsListSelectedIndex])

	obj.id = nil
	obj.version = Enemy.Settings.version

	local str = Enemy.SerializeTable (obj)

	Enemy.UI_TextEntryDialog_Open (L"Export", L"Select all (Ctrl+A) and copy (Ctrl+C) this visual part data string", str)
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsEnable ()

	if (not config_dlg.isLoaded
		or not config_dlg.unitFramesPartsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsEnableButton")) then return end

	local data = config_dlg.unitFramesParts[config_dlg.unitFramesPartsListSelectedIndex]
	data.isEnabled = not data.isEnabled

	Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_UnitFramePartsReset ()

	if (not config_dlg.isLoaded
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildUnitFramePartsResetButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Reset all visual parts list data to it's default predefined value?",
                                       L"Yes", function ()

                                       		config_dlg.unitFramesParts = {}
											for _, v in pairs (Enemy.DefaultSettings.unitFramesParts)
											do
												tinsert (config_dlg.unitFramesParts, EnemyUnitFramePart.New (v))
											end

                                       		config_dlg.unitFramesPartsListSelectedIndex = nil
                                       		Enemy.UnitFramesUI_ConfigDialog_OnUnitFramePartsListSelChanged ()
                                       end,
                                       L"No")
end


-- =============================================================================== EFFECTS INDICATORS

function Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListPopulate ()

	if (not config_dlg.isLoaded) then return end

	local list = _G[config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsList"]
	if (list.PopulatorIndices == nil) then return end

	local row_window_name
	local data

	for k, v in ipairs (list.PopulatorIndices)
	do
		row_window_name = config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsListRow"..k
		data = Enemy.effectsIndicatorsListData[v]

		if (v == config_dlg.effectsIndicatorsListSelectedIndex)
		then
			WindowSetShowing (row_window_name.."Background", true)
			WindowSetAlpha (row_window_name.."Background", 0.5)
			WindowSetTintColor (row_window_name.."Background", 255, 204, 102)
		else
			WindowSetShowing (row_window_name.."Background", false)
		end

		if (data.isEnabled)
		then
			LabelSetText (row_window_name.."Text", data.name)
		else
			LabelSetText (row_window_name.."Text", L"[disabled] "..data.name)
		end
	end
end


function Enemy.UnitFramesUI_ConfigDialog_UpdateEffectsIndicatorsList ()

	if (not config_dlg.isLoaded) then return end

	Enemy.effectsIndicatorsListData = {}
	Enemy.effectsIndicatorsListIndexes = {}

	for k, data in ipairs(config_dlg.effectsIndicators)
	do
		tinsert (Enemy.effectsIndicatorsListData, data)
		tinsert (Enemy.effectsIndicatorsListIndexes, k)
	end

	ListBoxSetDisplayOrder (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsList", Enemy.effectsIndicatorsListIndexes)
	Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListLButtonUp ()

	if (not config_dlg.isLoaded) then return end

	local data_index = ListBoxGetDataIndex (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsList", WindowGetId (SystemData.MouseOverWindow.name))

	if (data_index == nil)
	then
		config_dlg.effectsIndicatorsListSelectedIndex = nil
	else
		config_dlg.effectsIndicatorsListSelectedIndex = Enemy.effectsIndicatorsListIndexes[data_index]
	end

	Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()

	if (not config_dlg.isLoaded) then return end

	local data = config_dlg.effectsIndicators[config_dlg.effectsIndicatorsListSelectedIndex]
	if (not data)
	then
		config_dlg.effectsIndicatorsListSelectedIndex = nil
	end

	Enemy.UnitFramesUI_ConfigDialog_UpdateEffectsIndicatorsList ()
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsEditButton", config_dlg.effectsIndicatorsListSelectedIndex == nil)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsDeleteButton", config_dlg.effectsIndicatorsListSelectedIndex == nil)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsUpButton", config_dlg.effectsIndicatorsListSelectedIndex == nil or config_dlg.effectsIndicatorsListSelectedIndex == 1)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsDownButton", config_dlg.effectsIndicatorsListSelectedIndex == nil or config_dlg.effectsIndicatorsListSelectedIndex == #config_dlg.effectsIndicators)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsExportButton", config_dlg.effectsIndicatorsListSelectedIndex == nil)

	if (data and data.isEnabled)
	then
		ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsEnableButton", L"Disable")
	else
		ButtonSetText (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsEnableButton", L"Enable")
	end

	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsEnableButton", config_dlg.effectsIndicatorsListSelectedIndex == nil)
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsAdd ()

	if (not config_dlg.isLoaded) then return end

	local obj = EnemyEffectsIndicator.New ()

	obj:Edit (config_dlg, function (effectsIndicator)

		tinsert (config_dlg.effectsIndicators, effectsIndicator)

		config_dlg.effectsIndicatorsListSelectedIndex = #config_dlg.effectsIndicators
		Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
	end)
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsEdit ()

	if (not config_dlg.isLoaded
		or not config_dlg.effectsIndicatorsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsEditButton")) then return end

	local obj = config_dlg.effectsIndicators[config_dlg.effectsIndicatorsListSelectedIndex]
	obj:Edit (config_dlg, function (effectsIndicator)
		Enemy.UnitFramesUI_ConfigDialog_UpdateEffectsIndicatorsList ()
	end)
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsDelete ()

	if (not config_dlg.isLoaded
		or not config_dlg.effectsIndicatorsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsDeleteButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Delete effects indicator '"..Enemy.isNil (config_dlg.effectsIndicators[config_dlg.effectsIndicatorsListSelectedIndex].name, L"")..L"' ?",
                                       L"Yes", function ()

                                       		table.remove (config_dlg.effectsIndicators, config_dlg.effectsIndicatorsListSelectedIndex)
                                       		config_dlg.effectsIndicatorsListSelectedIndex = nil
                                       		Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
                                       end,
                                       L"No")
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsUp ()

	if (not config_dlg.isLoaded
		or not config_dlg.effectsIndicatorsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsUpButton")) then return end

	local index = config_dlg.effectsIndicatorsListSelectedIndex

	local tmp = config_dlg.effectsIndicators[index - 1]
	config_dlg.effectsIndicators[index - 1] = config_dlg.effectsIndicators[index]
	config_dlg.effectsIndicators[index] = tmp

	config_dlg.effectsIndicatorsListSelectedIndex = index - 1
	Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsDown ()

	if (not config_dlg.isLoaded
		or not config_dlg.effectsIndicatorsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsDownButton")) then return end

	local index = config_dlg.effectsIndicatorsListSelectedIndex

	local tmp = config_dlg.effectsIndicators[index + 1]
	config_dlg.effectsIndicators[index + 1] = config_dlg.effectsIndicators[index]
	config_dlg.effectsIndicators[index] = tmp

	config_dlg.effectsIndicatorsListSelectedIndex = index + 1
	Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsImport ()

	if (not config_dlg.isLoaded) then return end

	Enemy.UI_TextEntryDialog_Open (L"Import", L"Paste (Ctrl+V) an effect indicator data string", L"",
		function (str)

			local data = Enemy.DeserializeTable (str)
			if (not data) then return end

			local obj = EnemyEffectsIndicator.New (data)

			obj:Edit (config_dlg, function (effectsIndicator)

				tinsert (config_dlg.effectsIndicators, effectsIndicator)

				config_dlg.effectsIndicatorsListSelectedIndex = #config_dlg.effectsIndicators
				Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
			end)
		end)
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsExport ()

	if (not config_dlg.isLoaded
		or not config_dlg.effectsIndicatorsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsExportButton")) then return end

	local obj = Enemy.clone2 (config_dlg.effectsIndicators[config_dlg.effectsIndicatorsListSelectedIndex])

	obj.id = nil
	obj.version = Enemy.Settings.version

	local str = Enemy.SerializeTable (obj)

	Enemy.UI_TextEntryDialog_Open (L"Export", L"Select all (Ctrl+A) and copy (Ctrl+C) this effect indicator data string", str)
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsEnable ()

	if (not config_dlg.isLoaded
		or not config_dlg.effectsIndicatorsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsEnableButton")) then return end

	local data = config_dlg.effectsIndicators[config_dlg.effectsIndicatorsListSelectedIndex]
	data.isEnabled = not data.isEnabled

	Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_EffectsIndicatorsReset ()

	if (not config_dlg.isLoaded
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildEffectsIndicatorsResetButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Reset all effects indicators list data to it's default predefined value?",
                                       L"Yes", function ()

                                       		config_dlg.effectsIndicators = {}
											for _, v in pairs (Enemy.DefaultSettings.effectsIndicators)
											do
												tinsert (config_dlg.effectsIndicators, EnemyEffectsIndicator.New (v))
											end

                                       		config_dlg.effectsIndicatorsListSelectedIndex = nil
                                       		Enemy.UnitFramesUI_ConfigDialog_OnEffectsIndicatorsListSelChanged ()
                                       end,
                                       L"No")
end


-- =============================================================================== CLICK CASTING

function Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListPopulate ()

	if (not config_dlg.isLoaded) then return end

	local list = _G[config_dlg.section.windowName.."ContentScrollChildClickCastingsList"]
	if (list.PopulatorIndices == nil) then return end

	local row_window_name
	local data

	for k, v in ipairs (list.PopulatorIndices)
	do
		row_window_name = config_dlg.section.windowName.."ContentScrollChildClickCastingsListRow"..k
		data = Enemy.clickCastingsListData[v]

		if (v == config_dlg.clickCastingsListSelectedIndex)
		then
			WindowSetShowing (row_window_name.."Background", true)
			WindowSetAlpha (row_window_name.."Background", 0.5)
			WindowSetTintColor (row_window_name.."Background", 255, 204, 102)
		else
			WindowSetShowing (row_window_name.."Background", false)
		end

		if (data.isEnabled)
		then
			LabelSetText (row_window_name.."Text", data.name)
		else
			LabelSetText (row_window_name.."Text", L"[disabled] "..data.name)
		end
	end
end


function Enemy.UnitFramesUI_ConfigDialog_UpdateClickCastingsList ()

	if (not config_dlg.isLoaded) then return end

	Enemy.clickCastingsListData = {}
	Enemy.clickCastingsListIndexes = {}

	for k, data in ipairs(config_dlg.clickCastings)
	do
		tinsert (Enemy.clickCastingsListData, data)
		tinsert (Enemy.clickCastingsListIndexes, k)
	end

	ListBoxSetDisplayOrder (config_dlg.section.windowName.."ContentScrollChildClickCastingsList", Enemy.clickCastingsListIndexes)
	Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListLButtonUp ()

	if (not config_dlg.isLoaded) then return end

	local data_index = ListBoxGetDataIndex (config_dlg.section.windowName.."ContentScrollChildClickCastingsList", WindowGetId (SystemData.MouseOverWindow.name))

	if (data_index == nil)
	then
		config_dlg.clickCastingsListSelectedIndex = nil
	else
		config_dlg.clickCastingsListSelectedIndex = Enemy.clickCastingsListIndexes[data_index]
	end

	Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()

	if (not config_dlg.isLoaded) then return end

	local data = config_dlg.clickCastings[config_dlg.clickCastingsListSelectedIndex]
	if (not data)
	then
		config_dlg.clickCastingsListSelectedIndex = nil
	end

	Enemy.UnitFramesUI_ConfigDialog_UpdateClickCastingsList ()
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsEditButton", config_dlg.clickCastingsListSelectedIndex == nil)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsDeleteButton", config_dlg.clickCastingsListSelectedIndex == nil)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsUpButton", config_dlg.clickCastingsListSelectedIndex == nil or config_dlg.clickCastingsListSelectedIndex == 1)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsDownButton", config_dlg.clickCastingsListSelectedIndex == nil or config_dlg.clickCastingsListSelectedIndex == #config_dlg.clickCastings)
	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsExportButton", config_dlg.clickCastingsListSelectedIndex == nil)

	if (data and data.isEnabled)
	then
		ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsEnableButton", L"Disable")
	else
		ButtonSetText (config_dlg.section.windowName.."ContentScrollChildClickCastingsEnableButton", L"Enable")
	end

	ButtonSetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsEnableButton", config_dlg.clickCastingsListSelectedIndex == nil)
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsAdd ()

	if (not config_dlg.isLoaded) then return end

	local obj = EnemyClickCasting.New ()

	obj:Edit (config_dlg, function (clickCasting)

		tinsert (config_dlg.clickCastings, clickCasting)

		config_dlg.clickCastingsListSelectedIndex = #config_dlg.clickCastings
		Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
	end)
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsEdit ()

	if (not config_dlg.isLoaded
		or not config_dlg.clickCastingsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsEditButton")) then return end

	local obj = config_dlg.clickCastings[config_dlg.clickCastingsListSelectedIndex]
	obj:Edit (config_dlg, function (clickCasting)
		Enemy.UnitFramesUI_ConfigDialog_UpdateClickCastingsList ()
	end)
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsDelete ()

	if (not config_dlg.isLoaded
		or not config_dlg.clickCastingsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsDeleteButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Delete click casting '"..Enemy.isNil (config_dlg.clickCastings[config_dlg.clickCastingsListSelectedIndex].name, L"")..L"' ?",
                                       L"Yes", function ()

                                       		table.remove (config_dlg.clickCastings, config_dlg.clickCastingsListSelectedIndex)
                                       		config_dlg.clickCastingsListSelectedIndex = nil
                                       		Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
                                       end,
                                       L"No")
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsUp ()

	if (not config_dlg.isLoaded
		or not config_dlg.clickCastingsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsUpButton")) then return end

	local index = config_dlg.clickCastingsListSelectedIndex

	local tmp = config_dlg.clickCastings[index - 1]
	config_dlg.clickCastings[index - 1] = config_dlg.clickCastings[index]
	config_dlg.clickCastings[index] = tmp

	config_dlg.clickCastingsListSelectedIndex = index - 1
	Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsDown ()

	if (not config_dlg.isLoaded
		or not config_dlg.clickCastingsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsDownButton")) then return end

	local index = config_dlg.clickCastingsListSelectedIndex

	local tmp = config_dlg.clickCastings[index + 1]
	config_dlg.clickCastings[index + 1] = config_dlg.clickCastings[index]
	config_dlg.clickCastings[index] = tmp

	config_dlg.clickCastingsListSelectedIndex = index + 1
	Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsImport ()

	if (not config_dlg.isLoaded) then return end

	Enemy.UI_TextEntryDialog_Open (L"Import", L"Paste (Ctrl+V) a click casting data string", L"",
		function (str)

			local data = Enemy.DeserializeTable (str)
			if (not data) then return end

			local obj = EnemyClickCasting.New (data)

			obj:Edit (config_dlg, function (clickCasting)

				tinsert (config_dlg.clickCastings, clickCasting)

				config_dlg.clickCastingsListSelectedIndex = #config_dlg.clickCastings
				Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
			end)
		end)
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsExport ()

	if (not config_dlg.isLoaded
		or not config_dlg.clickCastingsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsExportButton")) then return end

	local obj = Enemy.clone2 (config_dlg.clickCastings[config_dlg.clickCastingsListSelectedIndex])

	obj.id = nil
	obj.version = Enemy.Settings.version

	local str = Enemy.SerializeTable (obj)

	Enemy.UI_TextEntryDialog_Open (L"Export", L"Select all (Ctrl+A) and copy (Ctrl+C) this click casting data string", str)
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsEnable ()

	if (not config_dlg.isLoaded
		or not config_dlg.clickCastingsListSelectedIndex
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsEnableButton")) then return end

	local data = config_dlg.clickCastings[config_dlg.clickCastingsListSelectedIndex]
	data.isEnabled = not data.isEnabled

	Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
end


function Enemy.UnitFramesUI_ConfigDialog_ClickCastingsReset ()

	if (not config_dlg.isLoaded
		or ButtonGetDisabledFlag (config_dlg.section.windowName.."ContentScrollChildClickCastingsResetButton")) then return end

	DialogManager.MakeTwoButtonDialog (L"Reset all click castings list data to it's default predefined value?",
                                       L"Yes", function ()

                                       		config_dlg.clickCastings = {}
											for _, v in pairs (Enemy.DefaultSettings.clickCastings)
											do
												tinsert (config_dlg.clickCastings, EnemyClickCasting.New (v))
											end

                                       		config_dlg.clickCastingsListSelectedIndex = nil
                                       		Enemy.UnitFramesUI_ConfigDialog_OnClickCastingsListSelChanged ()
                                       end,
                                       L"No")
end






function Enemy.UnitFramesUI_ConfigDialog_TestSettings ()
	config_dlg.needTestSettings = true
end


function Enemy._UnitFramesUI_ConfigDialog_TestSettings ()

	Enemy.ConfigurationWindowSaveData (config_dlg.cwnMain, config_dlg)
	Enemy.ConfigurationWindowSaveData (config_dlg.cwnAppearance, config_dlg)
	UpdateTestMode ()

	if (config_dlg.unitFramesEnabled)
	then
		for group_index = 1, Enemy.MaxGroups
		do
			for index = 1, 6
			do
				g.frames[group_index][index]:Reset (true)
			end
		end
	end

	Enemy.UnitFrames_OnSettingsChanged (config_dlg)

	if (config_dlg.unitFramesTestMode)
	then
		for group_index = 1, Enemy.MaxGroups
		do
			for index = 1, 6
			do
				local test_player = config_dlg.testData[group_index][index]
				if (not test_player) then continue end

				local frame = g.frames[group_index][index]

				frame:Enable ()
				frame:Update (test_player)
				if index == 1 then
					frame:_ShowAllEffectsIndicators ()
				end
			end
		end
	end

	for group_index = 1, Enemy.MaxGroups
	do
		for index = 1, 6
		do
			g.frames[group_index][index]:BoundingBoxSetShowing (config_dlg.unitFramesShowBoundingBox)
		end
	end

	Enemy._UnitFramesRecalculatePosititionMatrix (true)
end


function Enemy.UnitFramesUI_ConfigDialog_OnSave (section)

	Enemy._UnitFramesUI_ConfigDialog_TestSettings ()

	-- check dublicate parts names
	local names = {}
	for _, v in ipairs (config_dlg.unitFramesParts)
	do
		if (names[v.name])
		then
			DialogManager.MakeOneButtonDialog (L"Dublicate visual part name '"..Enemy.toWString (v.name)..L"'", L"Ok")
			return false
		end

		names[v.name] = true
	end

	-- check dublicate effect indicators names
	names = {}
	for _, v in ipairs (config_dlg.effectsIndicators)
	do
		if (names[v.name])
		then
			DialogManager.MakeOneButtonDialog (L"Dublicate effect indicator name '"..Enemy.toWString (v.name)..L"'", L"Ok")
			return false
		end

		names[v.name] = true
	end


	-- check dublicate click casting names
	names = {}
	for _, v in ipairs (config_dlg.clickCastings)
	do
		if (names[v.name])
		then
			DialogManager.MakeOneButtonDialog (L"Dublicate click casting name '"..Enemy.toWString (v.name)..L"'", L"Ok")
			return false
		end

		names[v.name] = true
	end

	-- save settings
	Enemy.Settings.unitFramesEnabled = config_dlg.unitFramesEnabled

	Enemy.Settings.unitFramesSortingEnabled = config_dlg.unitFramesSortingEnabled
	Enemy.Settings.unitFramesSorting = Enemy.clone (config_dlg.unitFramesSorting)
	Enemy.Settings.unitFramesMyGroupOnly = config_dlg.unitFramesMyGroupOnly
	Enemy.Settings.unitFramesMyGroupFirst = config_dlg.unitFramesMyGroupFirst
	Enemy.Settings.unitFramesDetachMyGroup = config_dlg.unitFramesDetachMyGroup
	Enemy.Settings.unitFramesHideMyGroup = config_dlg.unitFramesHideMyGroup
	Enemy.Settings.unitFramesHideWhenSolo = config_dlg.unitFramesHideWhenSolo
	Enemy.Settings.unitFramesTooltipMode = config_dlg.unitFramesTooltipMode

	Enemy.Settings.unitFramesSize[1] = config_dlg.unitFramesSize[1]
	Enemy.Settings.unitFramesSize[2] = config_dlg.unitFramesSize[2]
	Enemy.Settings.unitFramesLayer = config_dlg.unitFramesLayer
	Enemy.Settings.unitFramesScale = config_dlg.unitFramesScale

	Enemy.Settings.unitFramesDirection1 = config_dlg.unitFramesDirection1
	Enemy.Settings.unitFramesPadding1 = config_dlg.unitFramesPadding1
	Enemy.Settings.unitFramesCount1 = config_dlg.unitFramesCount1
	Enemy.Settings.unitFramesDirection2 = config_dlg.unitFramesDirection2
	Enemy.Settings.unitFramesPadding2 = config_dlg.unitFramesPadding2

	Enemy.Settings.unitFramesGroupsDirection1 = config_dlg.unitFramesGroupsDirection1
	Enemy.Settings.unitFramesGroupsPadding1 = config_dlg.unitFramesGroupsPadding1
	Enemy.Settings.unitFramesGroupsCount1 = config_dlg.unitFramesGroupsCount1
	Enemy.Settings.unitFramesGroupsDirection2 = config_dlg.unitFramesGroupsDirection2
	Enemy.Settings.unitFramesGroupsPadding2 = config_dlg.unitFramesGroupsPadding2

	Enemy.Settings.unitFramesParts = config_dlg.unitFramesParts
	Enemy.Settings.effectsIndicators = config_dlg.effectsIndicators
	Enemy.Settings.clickCastings = config_dlg.clickCastings

	return true
end
