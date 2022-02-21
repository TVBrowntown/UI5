local Enemy = Enemy
local g = {}

local pairs = pairs

function Enemy.GuardInitialize ()

	Enemy.guard = g

	local career = GameData.Player.career.line
	g.imGuarder = (career == GameData.CareerLine.CHOSEN or career == GameData.CareerLine.BLACK_ORC or career == GameData.CareerLine.BLACKGUARD or
					career == GameData.CareerLine.KNIGHT or career == GameData.CareerLine.SWORDMASTER or career == GameData.CareerLine.IRON_BREAKER)

	g.guardPlayers = {}
	g.canAskWhoIsGuardingMe = true

	if (not Enemy.Settings.guardMarkTemplate)
	then
		g.guardMarkTemplate = EnemyMarkTemplate.New ()
		g.guardMarkTemplate.color = { 65, 150, 255 }
		g.guardMarkTemplate.showCareerIcon = false
		g.guardMarkTemplate.display = 1
		g.guardMarkTemplate.text = L"G"
		g.guardMarkTemplate.font = "font_default_text_giant"
		g.guardMarkTemplate.scale = 0.8
		g.guardMarkTemplate.canClearOnClick = false
		g.guardMarkTemplate.neverExpire = true
		g.guardMarkTemplate.offsetY = 75

		Enemy.Settings.guardMarkTemplate = Enemy.clone (g.guardMarkTemplate)
	end

	-- UI: distance indicator
	CreateWindow ("EnemyGuardDistanceIndicator", true)
	LayoutEditor.RegisterWindow ("EnemyGuardDistanceIndicator", L"Enemy guard distance", L"Enemy guard distance indicator", false, false, false, nil)

	-- static events
	Enemy.AddEventHandler ("Guard", "SettingsChanged", Enemy.Guard_OnSettingsChanged)

	Enemy.AddEventHandler ("Guard", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections,
		{
			name = "Guard",
			title = L"Guard",
			templateName = "EnemyGuardConfiguration",
			onInitialize = Enemy.GuardUI_ConfigDialog_OnInitialize,
			onLoad = Enemy.GuardUI_ConfigDialog_OnLoad,
			onSave = Enemy.GuardUI_ConfigDialog_OnSave,
			onReset = Enemy.GuardUI_ConfigDialog_OnReset
		})
	end)

	Enemy.TriggerEvent ("GuardInitialized")
end


function Enemy._GuardEnabledChanged (enable)

	if (enable)
	then
		if (g.guardMarkTemplate)
		then
			g.guardMarkTemplate:Load (g.settings.guardMarkTemplate)
		else
			g.guardMarkTemplate = EnemyMarkTemplate.New (g.settings.guardMarkTemplate)
		end

		g.guardMarkPlayerName = nil
	end

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable

	if (g.isPluginEnabled)
	then
		Enemy.AddEventHandler ("Guard", "GroupsPlayerEffectsUpdated", Enemy.Guard_OnGroupsPlayerEffectsUpdated)
		Enemy.AddEventHandler ("Guard", "GroupsUpdated", Enemy.Guard_OnGroupsUpdated)
		Enemy.AddEventHandler ("Guard", "GroupsPlayerUpdated", Enemy.Guard_OnGroupsPlayerUpdated)
		Enemy.AddEventHandler ("Guard", "GroupsPlayerDistanceUpdated", Enemy.Guard_OnGroupsPlayerDistanceUpdated)
		Enemy.AddEventHandler ("Guard", "IntercomMessageGuard", Enemy.Guard_OnIntercomMessageGuard)
	else
		Enemy.RemoveEventHandler ("Guard", "GroupsPlayerEffectsUpdated")
		Enemy.RemoveEventHandler ("Guard", "GroupsUpdated")
		Enemy.RemoveEventHandler ("Guard", "GroupsPlayerUpdated")
		Enemy.RemoveEventHandler ("Guard", "GroupsPlayerDistanceUpdated")
		Enemy.RemoveEventHandler ("Guard", "IntercomMessageGuard")
	end
end


function Enemy.Guard_OnSettingsChanged (settings)
	g.settings = settings
	Enemy._GuardEnabledChanged (g.settings.guardEnabled)

	WindowSetShowing ("EnemyGuardDistanceIndicator", false)
	g.guardDistanceIndicatorAnimated = false

	Enemy.Guard_UpdateData ()
	Enemy.Guard_GuardMark_Update ()
	Enemy.Guard_GuardIndicator_Update ()
end


function Enemy.Guard_SetGuardPlayerName (playerName)
	g.guardPlayerName = playerName
	WindowSetGameActionData ("EnemyGuardDistanceIndicator", GameData.PlayerActions.SET_TARGET, 0, Enemy.isNil (g.guardPlayerName, L""))
end


function Enemy.Guard_OnGroupsUpdated ()

	local player_self = Enemy.groups.player
	if (not player_self:IsInGroup ()) then return end

	local guarded_player_present = false

	for k = 1, 6
	do
		local player = player_self.group[k]
		if (not player) then continue end

		if (g.guardPlayerName == player.name)
		then
			guarded_player_present = true
		end

		Enemy.Guard_OnGroupsPlayerEffectsUpdated (player)
	end

	if (not guarded_player_present)
	then
		Enemy.Guard_StopGuarding ()
	end
end


function Enemy.Guard_OnGroupsPlayerEffectsUpdated (player)

	if (player.isSelf)
	then
		if (Enemy.CanSendIntercomMessage () and not g.imGuarder and not g.guardPlayerName and g.canAskWhoIsGuardingMe)
		then
			for _, effect in pairs (player.effects)
			do
				if (Enemy.GuardAbilityIds[effect.abilityId])
				then
					-- we're guarded by someone - lets ask who is guarding us
					--Enemy.IntercomSendMessage ("guard", L"EnemyAddon:Guard:WhoGuardingMe")

					g.canAskWhoIsGuardingMe = false

					EnemyTimer.New ("guard can ask who guarding me", 10, function ()
						g.canAskWhoIsGuardingMe = true
						return true
					end)

					return
				end
			end
		end

		return
	end

	if (not player.isInPlayerGroup or player.worldObjectId == 0) then return end

	local has_guard = false

	for _, effect in pairs (player.effects)
	do
		if (effect.castByPlayer and Enemy.GuardAbilityIds[effect.abilityId])
		then
			has_guard = true
			break
		end
	end

	if (g.guardPlayerName == player.name and has_guard) then return end

	if (has_guard)
	then
		Enemy.Guard_StartGuarding (player)

	elseif (g.imGuarder and g.guardPlayerName == player.name)
	then
		Enemy.Guard_StopGuarding ()
	end
end


function Enemy.Guard_GuardMark_Update ()

	if (not g.guardMarkTemplate) then return end

	if (not g.guardPlayerName or not g.settings.guardMarkEnabled)
	then
		g.guardMarkTemplate:ClearMarks ()
		g.guardMarkPlayerName = nil

	elseif (g.guardMarkPlayerName ~= g.guardPlayerName)
	then
		g.guardMarkTemplate:ClearMarks ()
		g.guardMarkPlayerName = g.guardPlayerName

		local player = Enemy.groups.players[g.guardMarkPlayerName]

		g.guardMarkTemplate:ToggleMark (
			player.worldObjectId,
			player.name,
			true,
			true,
			player.career)
	end
end


function Enemy.Guard_StartGuarding (player)

	g.guardPlayers[player.name] = true
	Enemy.Guard_SetGuardPlayerName (player.name)

	Enemy.Guard_UpdateData ()
	Enemy.Guard_GuardMark_Update ()
	Enemy.Guard_GuardIndicator_Update ()

	--Enemy.IntercomSendMessage ("guard", L"EnemyAddon:Guard:Start:"..g.guardPlayerName)
end


function Enemy.Guard_StopGuarding ()

	if (not g.guardPlayerName) then return end

	--Enemy.IntercomSendMessage ("guard", L"EnemyAddon:Guard:Stop:"..g.guardPlayerName)

	g.guardPlayers[g.guardPlayerName] = nil
	Enemy.Guard_SetGuardPlayerName (nil)

	Enemy.Guard_UpdateData ()
	Enemy.Guard_GuardMark_Update ()
	Enemy.Guard_GuardIndicator_Update ()
end


function Enemy.Guard_OnIntercomMessageGuard (from, command, playerName)

	--d (Enemy.toWStringOrEmpty (from)..L" -> "..Enemy.toWStringOrEmpty (command)..L" -> "..Enemy.toWStringOrEmpty (playerName))

	from = Enemy.groups.players[from]
	local player = Enemy.groups.players[playerName]

	if (not from or from.isSelf) then return end

	if (g.imGuarder)
	then
		if (command == L"WhoGuardingMe" and g.guardPlayerName == from.name)
		then
			--Enemy.IntercomSendMessage ("guard", L"EnemyAddon:Guard:Start:"..g.guardPlayerName)
		end

	elseif (player)
	then
		if (not player.isSelf)
		then
			g.guardPlayers[from.name] = nil
		else
			if (command == L"Start")
			then
				g.guardPlayers[from.name] = true

			elseif (command == L"Stop")
			then
				g.guardPlayers[from.name] = nil
			end
		end

		Enemy.Guard_UpdateData ()
		Enemy.Guard_GuardMark_Update ()
		Enemy.Guard_GuardIndicator_Update ()
	end
end


function Enemy.Guard_UpdateData ()

	g.available = false
	g.guardDistance = nil

	local guard_player_name = nil

	for player_name, _ in pairs (g.guardPlayers)
	do
		g.available = true

		local player = Enemy.groups.players[player_name]
		if (g.guardDistance == nil or g.guardDistance > player.distance)
		then
			g.guardDistance = player.distance
			guard_player_name = player.name
		end
	end

	if (guard_player_name ~= g.guardPlayerName)
	then
		Enemy.Guard_SetGuardPlayerName (guard_player_name)
	end
end


function Enemy.Guard_OnGroupsPlayerUpdated (player)
	if (not player.isSelf) then return end
	Enemy.Guard_GuardIndicator_Update ()
end


function Enemy.Guard_OnGroupsPlayerDistanceUpdated (player)
	if (not g.guardPlayers[player.name]) then return end
	Enemy.Guard_UpdateData ()
	Enemy.Guard_GuardIndicator_Update ()
end


function Enemy.Guard_GuardIndicator_Update ()

	if (not g.isPluginEnabled or
		g.settings.guardDistanceIndicator == 1 or
		(g.settings.guardDistanceIndicator == 3 and not Enemy.groups.player.isRVRFlagged)) then return end

	if (not g.available or g.guardDistance == nil)
	then
		WindowSetShowing ("EnemyGuardDistanceIndicator", false)
		g.guardDistanceIndicatorAnimated = false
		return
	end

	WindowSetShowing ("EnemyGuardDistanceIndicator", true)
	WindowSetHandleInput ("EnemyGuardDistanceIndicator", not g.settings.guardDistanceIndicatorClickThrough)
	WindowSetMovable("EnemyGuardDistanceIndicator", g.settings.guardDistanceIndicatorMovable)

	if (g.guardDistance < g.settings.guardDistanceIndicatorWarningDistance)
	then
		WindowSetTintColor ("EnemyGuardDistanceIndicator", unpack (g.settings.guardDistanceIndicatorColorNormal))
		WindowSetScale ("EnemyGuardDistanceIndicator", g.settings.guardDistanceIndicatorScaleNormal)

		WindowStopAlphaAnimation ("EnemyGuardDistanceIndicator")
		WindowSetAlpha ("EnemyGuardDistanceIndicator", g.settings.guardDistanceIndicatorAlphaNormal)
		g.guardDistanceIndicatorAnimated = false
	else
		WindowSetTintColor ("EnemyGuardDistanceIndicator", unpack (g.settings.guardDistanceIndicatorColorWarning))
		WindowSetScale ("EnemyGuardDistanceIndicator", g.settings.guardDistanceIndicatorScaleWarning)

		if (g.settings.guardDistanceIndicatorAnimation and Enemy.groups.player.isInCombat)
		then
			if (not g.guardDistanceIndicatorAnimated)
			then
				WindowStartAlphaAnimation ("EnemyGuardDistanceIndicator", Window.AnimationType.LOOP, g.settings.guardDistanceIndicatorAlphaWarning / 4, g.settings.guardDistanceIndicatorAlphaWarning, 0.3, true, 0, 0)
				g.guardDistanceIndicatorAnimated = true
			end
		else
			WindowStopAlphaAnimation ("EnemyGuardDistanceIndicator")
			WindowSetAlpha ("EnemyGuardDistanceIndicator", g.settings.guardDistanceIndicatorAlphaWarning)
			g.guardDistanceIndicatorAnimated = false
		end
	end

	if (g.guardDistance > 300)
	then
		LabelSetText ("EnemyGuardDistanceIndicatorText", L"FAR")
	else
		LabelSetText ("EnemyGuardDistanceIndicatorText", towstring (g.guardDistance))
	end
end


function Enemy.Guard_GuardIndicator_OnMouseOver ()

	if (not g.isPluginEnabled or not g.guardPlayerName) then return end

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)

	if (g.imGuarder)
	then
		Tooltips.SetTooltipText (1, 1, L"Distance to guarded player")
	else
		Tooltips.SetTooltipText (1, 1, L"Distance to the closest guarder")
	end

	Tooltips.SetTooltipText (1, 3, g.guardPlayerName)
	Tooltips.SetTooltipColor (1, 3, 150, 150, 255)

	Tooltips.SetTooltipText (3, 1, L"Click to target")

	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.Guard_GuardIndicator_OnLButtonUp ()
end


--------------------------------------------------------------- UI: Configuration
local config_dlg = {}

config_dlg.properties =
{
	guardEnabled =
	{
		key = "guardEnabled",
		order = 10,
		name = L"Enable guarding enhancements",
		type = "bool",
		default = Enemy.DefaultSettings.guardEnabled
	},

	guardDistanceIndicatorTitle =
	{
		key = "guardDistanceIndicatorTitle",
		order = 20,
		name = L"Guard distance indicator",
		type = "title",
		paddingTop = 30
	},
	guardDistanceIndicator =
	{
		key = "guardDistanceIndicator",
		order = 30,
		name = L"Distance indicator",
		type = "select",
		default = Enemy.DefaultSettings.guardDistanceIndicator,
		values =
		{
			{ text = L"hide", value = 1 },
			{ text = L"show when available", value = 2 },
			{ text = L"show when available and PvP flagged", value = 3 }
		}
	},
	guardDistanceIndicatorMovable =
	{
		key = "guardDistanceIndicatorMovable",
		order = 35,
		name = L"Movable",
		type = "bool",
		default = Enemy.DefaultSettings.guardDistanceIndicatorMovable
	},
	guardDistanceIndicatorClickThrough =
	{
		key = "guardDistanceIndicatorClickThrough",
		order = 36,
		name = L"Click through",
		type = "bool",
		default = Enemy.DefaultSettings.guardDistanceIndicatorClickThrough,
		tooltip = L"If checked guard indicator will not be clickable (and movable too)"
	},
	guardDistanceIndicatorWarningDistance =
	{
		key = "guardDistanceIndicatorWarningDistance",
		order = 40,
		name = L"Warning distance",
		type = "int",
		min = 0,
		max = 1000,
		default = Enemy.DefaultSettings.guardDistanceIndicatorWarningDistance,
		tooltip = L"If the distance between you and guarder (or guarded player) will be more than this value, the indicator will switch to 'warning' mode"
	},
	guardDistanceIndicatorColorNormal =
	{
		key = "guardDistanceIndicatorColorNormal",
		order = 50,
		name = L"Normal color",
		type = "color",
		default = Enemy.DefaultSettings.guardDistanceIndicatorColorNormal
	},
	guardDistanceIndicatorColorWarning =
	{
		key = "guardDistanceIndicatorColorWarning",
		order = 60,
		name = L"Warning color",
		type = "color",
		default = Enemy.DefaultSettings.guardDistanceIndicatorColorWarning
	},
	guardDistanceIndicatorAlphaNormal =
	{
		key = "guardDistanceIndicatorAlphaNormal",
		order = 70,
		name = L"Normal opacity",
		type = "float",
		default = Enemy.DefaultSettings.guardDistanceIndicatorAlphaNormal,
		min = 0,
		max = 1
	},
	guardDistanceIndicatorAlphaWarning =
	{
		key = "guardDistanceIndicatorAlphaWarning",
		order = 80,
		name = L"Warning opacity",
		type = "float",
		default = Enemy.DefaultSettings.guardDistanceIndicatorAlphaWarning,
		min = 0,
		max = 1
	},
	guardDistanceIndicatorScaleNormal =
	{
		key = "guardDistanceIndicatorScaleNormal",
		order = 84,
		name = L"Normal scaling",
		type = "float",
		default = Enemy.DefaultSettings.guardDistanceIndicatorScaleNormal,
		min = 0,
		max = 10
	},
	guardDistanceIndicatorScaleWarning =
	{
		key = "guardDistanceIndicatorScaleWarning",
		order = 85,
		name = L"Warning scaling",
		type = "float",
		default = Enemy.DefaultSettings.guardDistanceIndicatorScaleWarning,
		min = 0,
		max = 10
	},
	guardDistanceIndicatorAnimation =
	{
		key = "guardDistanceIndicatorAnimation",
		order = 90,
		name = L"Enable warning animation (only in combat)",
		type = "bool",
		default = Enemy.DefaultSettings.guardDistanceIndicatorAnimation
	},

	guardMarkTitle =
	{
		key = "guardMarkTitle",
		order = 100,
		name = L"Guard mark",
		type = "title",
		paddingTop = 30
	},
	guardMarkEnabled =
	{
		key = "guardMarkEnabled",
		order = 110,
		name = L"Enable marking guarder/guarded player",
		type = "bool",
		default = Enemy.DefaultSettings.guardMarkEnabled
	},
	editGuardTemplate =
	{
		key = "editGuardTemplate",
		order = 120,
		name = L"Edit guard mark template",
		type = "button",
		windowWidth = 300,
		onClick = function ()
			config_dlg.guardMarkTemplate:Edit ()
			Enemy.Guard_OnSettingsChanged (config_dlg)
		end
	}
}


function Enemy.GuardUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section

	local root = config_dlg.section.windowName.."ContentScrollChild"
	config_dlg.cwn = root.."Config"
	Enemy.CreateConfigurationWindow (config_dlg.cwn, root, config_dlg.properties, Enemy.GuardUI_ConfigDialog_TestSettings)

	ScrollWindowUpdateScrollRect (config_dlg.section.windowName.."Content")
end


function Enemy.GuardUI_ConfigDialog_OnLoad (section)

	config_dlg.isLoading = true

	config_dlg.guardEnabled = Enemy.Settings.guardEnabled
	config_dlg.guardMarkTemplate = EnemyMarkTemplate.New (Enemy.Settings.guardMarkTemplate)
	config_dlg.guardDistanceIndicator = Enemy.Settings.guardDistanceIndicator
	config_dlg.guardDistanceIndicatorMovable = Enemy.Settings.guardDistanceIndicatorMovable
	config_dlg.guardDistanceIndicatorClickThrough = Enemy.Settings.guardDistanceIndicatorClickThrough
	config_dlg.guardDistanceIndicatorWarningDistance = Enemy.Settings.guardDistanceIndicatorWarningDistance
	config_dlg.guardDistanceIndicatorColorNormal = Enemy.clone (Enemy.Settings.guardDistanceIndicatorColorNormal)
	config_dlg.guardDistanceIndicatorColorWarning = Enemy.clone (Enemy.Settings.guardDistanceIndicatorColorWarning)
	config_dlg.guardDistanceIndicatorAlphaNormal = Enemy.Settings.guardDistanceIndicatorAlphaNormal
	config_dlg.guardDistanceIndicatorAlphaWarning = Enemy.Settings.guardDistanceIndicatorAlphaWarning
	config_dlg.guardDistanceIndicatorScaleNormal = Enemy.Settings.guardDistanceIndicatorScaleNormal
	config_dlg.guardDistanceIndicatorScaleWarning = Enemy.Settings.guardDistanceIndicatorScaleWarning
	config_dlg.guardDistanceIndicatorAnimation = Enemy.Settings.guardDistanceIndicatorAnimation
	config_dlg.guardMarkEnabled = Enemy.Settings.guardMarkEnabled

	Enemy.ConfigurationWindowLoadData (config_dlg.cwn, config_dlg)

	config_dlg.isLoading = false

	Enemy.GuardUI_ConfigDialog_TestSettings ()
end


function Enemy.GuardUI_ConfigDialog_OnReset (section)

	for k, v in pairs (Enemy.Settings)
	do
		if (not k:match("^guard.*")) then continue end
		Enemy.Settings[k] = nil
	end

	Enemy.Print ("Guard mark settings has been reset")
	InterfaceCore.ReloadUI ()
end


function Enemy.GuardUI_ConfigDialog_TestSettings ()

	if (config_dlg.isLoading) then return end

	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, config_dlg)
	Enemy.Guard_OnSettingsChanged (config_dlg)
end


function Enemy.GuardUI_ConfigDialog_OnSave (section)

	Enemy.GuardUI_ConfigDialog_TestSettings ()
	config_dlg.guardMarkTemplate:ClearMarks ()

	Enemy.Settings.guardEnabled = config_dlg.guardEnabled
	Enemy.Settings.guardMarkTemplate = config_dlg.guardMarkTemplate
	Enemy.Settings.guardDistanceIndicator = config_dlg.guardDistanceIndicator
	Enemy.Settings.guardDistanceIndicatorWarningDistance = config_dlg.guardDistanceIndicatorWarningDistance
	Enemy.Settings.guardDistanceIndicatorMovable = config_dlg.guardDistanceIndicatorMovable
	Enemy.Settings.guardDistanceIndicatorClickThrough = config_dlg.guardDistanceIndicatorClickThrough
	Enemy.Settings.guardDistanceIndicatorColorNormal = Enemy.clone (config_dlg.guardDistanceIndicatorColorNormal)
	Enemy.Settings.guardDistanceIndicatorColorWarning = Enemy.clone (config_dlg.guardDistanceIndicatorColorWarning)
	Enemy.Settings.guardDistanceIndicatorAlphaNormal = config_dlg.guardDistanceIndicatorAlphaNormal
	Enemy.Settings.guardDistanceIndicatorAlphaWarning = config_dlg.guardDistanceIndicatorAlphaWarning
	Enemy.Settings.guardDistanceIndicatorScaleNormal = config_dlg.guardDistanceIndicatorScaleNormal
	Enemy.Settings.guardDistanceIndicatorScaleWarning = config_dlg.guardDistanceIndicatorScaleWarning
	Enemy.Settings.guardDistanceIndicatorAnimation = config_dlg.guardDistanceIndicatorAnimation
	Enemy.Settings.guardMarkEnabled = config_dlg.guardMarkEnabled

	return true
end
