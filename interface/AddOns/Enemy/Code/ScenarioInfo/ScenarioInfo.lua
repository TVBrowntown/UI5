local Enemy = Enemy
local g = {}

local ipairs = ipairs
local pairs = pairs
local mfloor = math.floor
local tinsert = table.insert
local tsort = table.sort

local REALM_ORDER = 1
local REALM_DESTR = 2

local COLOR_ORDER = {r = 0, g = 180, b = 255}
local COLOR_DESTR = {r = 255, g = 100, b = 100}

local COLOR_SELECTION1 = {r = 190, g = 255, b = 0}
local COLOR_SELECTION2 = {r = 255, g = 190, b = 0}

local MACRO_TOGGLE = L"/script Enemy.ScenarioInfoToggle()"

function Enemy.ScenarioInfoInitialize ()

	Enemy.scenarioInfo = g

	g.selection = Enemy.Settings.scenarioInfoSelection
	g.players = Enemy.Settings.scenarioInfoPlayers or {}
	g.scenarioData = Enemy.Settings.scenarioInfoData or {}

	g.careerToArchetype =
	{
		[GameData.CareerLine.IRON_BREAKER] = "tanks",
		[GameData.CareerLine.SWORDMASTER] = "tanks",
		[GameData.CareerLine.CHOSEN] = "tanks",
		[GameData.CareerLine.BLACK_ORC] = "tanks",
		[GameData.CareerLine.KNIGHT] = "tanks",
		[GameData.CareerLine.BLACKGUARD] = "tanks",

		[GameData.CareerLine.WITCH_HUNTER] = "mdps",
		[GameData.CareerLine.WHITE_LION] = "mdps",
		[GameData.CareerLine.MARAUDER] = "mdps",
		[GameData.CareerLine.WITCH_ELF] = "mdps",
		[GameData.CareerLine.BRIGHT_WIZARD] = "rdps",
		[GameData.CareerLine.MAGUS] = "rdps",
		[GameData.CareerLine.SORCERER] = "rdps",
		[GameData.CareerLine.ENGINEER] = "rdps",
		[GameData.CareerLine.SHADOW_WARRIOR] = "rdps",
		[GameData.CareerLine.SQUIG_HERDER] = "rdps",
		[GameData.CareerLine.CHOPPA] = "mdps",
		[GameData.CareerLine.SLAYER or GameData.CareerLine.HAMMERER] = "mdps",

		[GameData.CareerLine.WARRIOR_PRIEST] = "healers",
		[GameData.CareerLine.DISCIPLE] = "healers",
		[GameData.CareerLine.ARCHMAGE] = "healers",
		[GameData.CareerLine.SHAMAN] = "healers",
		[GameData.CareerLine.RUNE_PRIEST] = "healers",
		[GameData.CareerLine.ZEALOT] = "healers"
	}

	g.careerToArchetype2 =
	{
		[GameData.CareerLine.SORCERER] = 1,
		[GameData.CareerLine.CHOPPA] = 2,
		[GameData.CareerLine.SQUIG_HERDER] = 3,
		[GameData.CareerLine.WITCH_ELF] = 4,
		[GameData.CareerLine.MARAUDER] = 5,
		[GameData.CareerLine.MAGUS] = 6,

		[GameData.CareerLine.BRIGHT_WIZARD] = 7,
		[GameData.CareerLine.SLAYER or GameData.CareerLine.HAMMERER] = 8,
		[GameData.CareerLine.WITCH_HUNTER] = 9,
		[GameData.CareerLine.WHITE_LION] = 10,
		[GameData.CareerLine.ENGINEER] = 11,
		[GameData.CareerLine.SHADOW_WARRIOR] = 12,

		[GameData.CareerLine.DISCIPLE] = 13,
		[GameData.CareerLine.SHAMAN] = 14,
		[GameData.CareerLine.ZEALOT] = 15,

		[GameData.CareerLine.WARRIOR_PRIEST] = 16,
		[GameData.CareerLine.ARCHMAGE] = 17,
		[GameData.CareerLine.RUNE_PRIEST] = 18,

		[GameData.CareerLine.CHOSEN] = 19,
		[GameData.CareerLine.BLACKGUARD] = 20,
		[GameData.CareerLine.BLACK_ORC] = 21,

		[GameData.CareerLine.IRON_BREAKER] = 22,
		[GameData.CareerLine.SWORDMASTER] = 23,
		[GameData.CareerLine.KNIGHT] = 24
	}

	g.careerIndexes =
	{
		[GameData.CareerLine.CHOPPA] = 1,
		[GameData.CareerLine.WITCH_ELF] = 2,			-- WE
		[GameData.CareerLine.MARAUDER] = 3,				-- MA
		[GameData.CareerLine.SLAYER or GameData.CareerLine.HAMMERER] = 4,
		[GameData.CareerLine.WITCH_HUNTER] = 5,
		[GameData.CareerLine.WHITE_LION] = 6,			-- WL

		[GameData.CareerLine.SORCERER] = 7,
		[GameData.CareerLine.SQUIG_HERDER] = 8,
		[GameData.CareerLine.MAGUS] = 9,
		[GameData.CareerLine.BRIGHT_WIZARD] = 10,
		[GameData.CareerLine.SHADOW_WARRIOR] = 11,
		[GameData.CareerLine.ENGINEER] = 12,

		[GameData.CareerLine.ZEALOT] = 13,
		[GameData.CareerLine.DISCIPLE] = 14,
		[GameData.CareerLine.SHAMAN] = 15,
		[GameData.CareerLine.WARRIOR_PRIEST] = 16,
		[GameData.CareerLine.ARCHMAGE] = 17,
		[GameData.CareerLine.RUNE_PRIEST] = 18,

		[GameData.CareerLine.CHOSEN] = 19,
		[GameData.CareerLine.BLACKGUARD] = 20,
		[GameData.CareerLine.BLACK_ORC] = 21,
		[GameData.CareerLine.KNIGHT] = 22,
		[GameData.CareerLine.IRON_BREAKER] = 23,
		[GameData.CareerLine.SWORDMASTER] = 24
	}

	g.sortColumns =
	{
		["archetype2"] =
		{
			title = L"",
			defaultSortDirection = true,
			isInternal = true
		},
		["level"] =
		{
			title = L"",
			defaultSortDirection = false,
			isInternal = true
		},
		["name"] =
		{
			title = L"Name",
			defaultSortDirection = true,
			isInternal = true
		},

		["damage"] =
		{
			title = L"Damage",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 1
		},
		["healing"] =
		{
			title = L"Healing",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 2
		},
		["soloKills"] =
		{
			title = L"Protection",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 3
		},
		["kills"] =
		{
			title = L"Kills",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 4
		},
		["db"] =
		{
			title = L"DB",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 5
		},
		["deaths"] =
		{
			title = L"Deaths",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 6
		},
		["renown"] =
		{
			title = L"MMR",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 7
		},
		["exp"] =
		{
			title = L"Objectives",
			defaultSortDirection = false,
			isInternal = false,
			orderNum = 8
		},
	}

	for k, v in pairs (g.sortColumns)
	do
		v.key = k
	end

	-- UI: info dialog
	local wn = "EnemyScenarioInfoDialog"
	CreateWindow (wn, false)
	WindowSetShowing (wn, false)
	WindowSetDimensions (wn, 1000, 860)
	WindowSetTintColor (wn.."Background", 0, 0, 0)
	ButtonSetText (wn.."CancelButton", L"Close")
	ButtonSetText (wn.."Cancel2Button", L"Close")
	ButtonSetText (wn.."SwitchToStandardButton", L"Switch to standard scenario info")
	ButtonSetText (wn.."LeaveButton", GetString (StringTables.Default.LABEL_LEAVE_NOW))

	WindowSetTintColor (wn.."Selection1", Enemy.UnpackRGB (COLOR_SELECTION1))
	WindowSetAlpha (wn.."Selection1", 0.8)
	LabelSetTextColor (wn.."List1TitleLabel", Enemy.UnpackRGB (COLOR_SELECTION1))
	WindowSetTintColor (wn.."Selection2", Enemy.UnpackRGB (COLOR_SELECTION2))
	WindowSetAlpha (wn.."Selection2", 0.8)
	LabelSetTextColor (wn.."List2TitleLabel", Enemy.UnpackRGB (COLOR_SELECTION2))

	local careers = {}
	for k, _ in pairs (g.careerIndexes)
	do
		tinsert (careers, k)
	end

	tsort (careers, function (a, b)
		return g.careerIndexes[a] < g.careerIndexes[b]
	end)

	for k, v in ipairs (careers)
	do
		local wnr = wn.."StatsCareer"..k
		local icon, icon_x, icon_y = GetIconData (Icons.GetCareerIconIDFromCareerLine (v))
		DynamicImageSetTexture (wnr.."Icon", icon, icon_x, icon_y)
	end

	wn = "EnemyScenarioInfoToggleButton"
	CreateWindowFromTemplate (wn, "EnemyScenarioInfoToggleButtonTemplate", "ScenarioSummaryWindow")
	WindowAddAnchor (wn, "topright", "ScenarioSummaryWindow", "topright", -100, 5)
	ButtonSetText (wn, L"Switch to extended scenario info")

	wn = "EnemyScenarioInfoToggleButton2"
	CreateWindowFromTemplate (wn, "EnemyScenarioInfoToggleButtonTemplate", "ScenarioSummaryWindow")
	WindowAddAnchor (wn, "bottomright", "ScenarioSummaryWindow", "bottomright", -100, -5)
	ButtonSetText (wn, L"Switch to extended scenario info")

	-- static events
	Enemy.AddEventHandler ("ScenarioInfo", "SettingsChanged", Enemy.ScenarioInfo_OnSettingsChanged)

	Enemy.AddEventHandler ("ScenarioInfo", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections,
		{
			name = "ScenarioInfo",
			title = L"Scenario info",
			templateName = "EnemyScenarioInfoConfiguration",
			onInitialize = Enemy.ScenarioInfoUI_ConfigDialog_OnInitialize,
			onLoad = Enemy.ScenarioInfoUI_ConfigDialog_OnLoad,
			onSave = Enemy.ScenarioInfoUI_ConfigDialog_OnSave
		})
	end)

	Enemy.AddEventHandler ("ScenarioInfo", "IconCreateContextMenu", function (data)

		table.insert (data, { text = L"", callback = nil })

		if (Enemy.ScenarioInfoUI_ScenarioInfoDialog_IsOpen ())
		then
			table.insert (data,
				{
					text = L"Hide scenario info",
					callback = Enemy.ScenarioInfoUI_ScenarioInfoDialog_Hide
				})
		else
			Enemy.ScenarioInfoUpdateData ()

			table.insert (data,
				{
					text = L"Show scenario info",
					callback = Enemy.ScenarioInfoUI_ScenarioInfoDialog_Open,
					disabled = (not g.isPluginEnabled or #g.players == 0)
				})
		end
	end)

	-- hooks
	if (not g.hook_ScenarioSummaryWindow_SetDisplayMode)
	then
		g.hook_ScenarioSummaryWindow_SetDisplayMode = ScenarioSummaryWindow.SetDisplayMode
		ScenarioSummaryWindow.SetDisplayMode = Enemy.Hook_ScenarioSummaryWindow_SetDisplayMode
	end

	Enemy.CreateMacro (L"Enemy: toggle scenario info", MACRO_TOGGLE, 205)

	Enemy.TriggerEvent ("ScenarioInfoInitialized")
end


function Enemy._ScenarioInfoEnabledChanged (enable)

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable

	if (g.isPluginEnabled)
	then
		RegisterEventHandler (SystemData.Events.SCENARIO_BEGIN, "Enemy.ScenarioInfoUpdate")
	    RegisterEventHandler (SystemData.Events.LOADING_END,  "Enemy.ScenarioInfoUpdate" )
	    RegisterEventHandler (SystemData.Events.SCENARIO_UPDATE_POINTS, "Enemy.ScenarioInfoUpdate")
	    RegisterEventHandler (SystemData.Events.CITY_SCENARIO_UPDATE_POINTS, "Enemy.ScenarioInfoUpdate")
	    RegisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED, "Enemy.ScenarioInfoUpdate")
	    RegisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_STATS_UPDATED, "Enemy.ScenarioInfoUpdate")
	    RegisterEventHandler (SystemData.Events.SCENARIO_POST_MODE, "Enemy.ScenarioInfoUpdate" )

	    RegisterEventHandler (SystemData.Events.SCENARIO_STOP_UPDATING_PLAYERS_STATS, "Enemy.ScenarioInfoCheckBroadcast")

	    if (not WindowGetShowing ("ScenarioSummaryWindow") and Enemy.ScenarioInfoUI_ScenarioInfoDialog_IsOpen ())
	    then
	    	Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnShown ()
	    end

	    g.wasEnabled = true
	else
		if (g.wasEnabled)
		then
			UnregisterEventHandler (SystemData.Events.SCENARIO_BEGIN, "Enemy.ScenarioInfoUpdate")
		    UnregisterEventHandler (SystemData.Events.LOADING_END,  "Enemy.ScenarioInfoUpdate" )
		    UnregisterEventHandler (SystemData.Events.SCENARIO_UPDATE_POINTS, "Enemy.ScenarioInfoUpdate")
		    UnregisterEventHandler (SystemData.Events.CITY_SCENARIO_UPDATE_POINTS, "Enemy.ScenarioInfoUpdate")
		    UnregisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED, "Enemy.ScenarioInfoUpdate")
		    UnregisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_STATS_UPDATED, "Enemy.ScenarioInfoUpdate")
		    UnregisterEventHandler (SystemData.Events.SCENARIO_POST_MODE, "Enemy.ScenarioInfoUpdate" )

		    UnregisterEventHandler (SystemData.Events.SCENARIO_STOP_UPDATING_PLAYERS_STATS, "Enemy.ScenarioInfoCheckBroadcast")
		end

	    if (not WindowGetShowing ("ScenarioSummaryWindow"))
	    then
	    	Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnHidden ()
	    end
	end
end


function Enemy.Hook_ScenarioSummaryWindow_SetDisplayMode (mode)

	g.hook_ScenarioSummaryWindow_SetDisplayMode (mode)

	if (not g.isPluginEnabled or not g.settings.scenarioInfoReplaceStandardWindow) then return end

	WindowSetShowing("ScenarioSummaryWindow", false)
	Enemy.ScenarioInfoUI_ScenarioInfoDialog_Open ()
end


function Enemy.ScenarioInfo_OnSettingsChanged (settings)

	g.settings = settings
	Enemy._ScenarioInfoEnabledChanged (g.settings.scenarioInfoEnabled);
end


function Enemy.ScenarioInfoUpdate ()
	Enemy.ScenarioInfoUpdateData ()
end


function Enemy.ScenarioInfoCheckBroadcast ()

	if (g.isActive)
	then
    	BroadcastEvent (SystemData.Events.SCENARIO_START_UPDATING_PLAYERS_STATS)
    end
end


function Enemy.ScenarioInfoToggle ()

	if (Enemy.ScenarioInfoUI_ScenarioInfoDialog_IsOpen ())
	then
		Enemy.ScenarioInfoUI_ScenarioInfoDialog_Hide ()
	else
		Enemy.ScenarioInfoUI_ScenarioInfoDialog_Open ()
	end
end


function Enemy.ScenarioInfoUpdateData ()

	if (not Enemy.Settings.debug and Enemy.groups.groupType ~= Enemy.GroupTypes.Scenario)
	then
		return
	end

	g.scenarioData = Enemy.clone (GameData.ScenarioData)
	g.players = {}
	g.playersByName = {}

	Enemy.Settings.scenarioInfoData = g.scenarioData
	Enemy.Settings.scenarioInfoPlayers = g.players

	if (Enemy.Settings.debug and Enemy.groups.groupType ~= Enemy.GroupTypes.Scenario)
	then
		g.scenarioData = Enemy.clone (Enemy.ScenarioInfoTestData.scenarioData)
		g.players = Enemy.clone (Enemy.ScenarioInfoTestData.players)
	else
		local scenario_players = GameData.GetScenarioPlayers ()
		if (not scenario_players) then return end

		for _, player_data in ipairs (scenario_players)
		do
			local player =
			{
				realm = player_data.realm,
				level = player_data.rank,
				name = Enemy.FixString (player_data.name),
				career = Enemy.ScenarioCareerIdToLine[player_data.careerId],

				damage = player_data.damagedealt,
				healing = player_data.healingdealt,
				soloKills = player_data.solokills,
				kills = player_data.groupkills,
				db = player_data.deathblows,
				deaths = player_data.deaths,

				renown = player_data.renown,
				exp = player_data.experience
			}

			tinsert (g.players, player)
			g.playersByName[player.name] = player
		end
	end
end


local function NewId ()
	g.maxId = g.maxId + 1
	return g.maxId
end


local function NewTooltip (content)

	local id = NewId ()

	g.tooltips[tostring (id)] = content
	return id
end


local function StatsAddPlayer (stats, player, value)

	if (not value)
	then
		value = 1
	end

	local s = stats[player.realm]

	s.all = s.all + value
	tinsert (s.allPlayers, player)

	if (player.level >= g.highPlayerMinLevel)
	then
		s.high = s.high + value
		tinsert (s.highPlayers, player)
	else
		s.low = s.low + value
		tinsert (s.lowPlayers, player)
	end
end


--------------------------------------------------------------- UI: Info dialog

function Enemy.ScenarioInfoUI_ScenarioInfoDialog_Open ()

	if (not g.isPluginEnabled) then return end

	g.isActive = true
	WindowSetShowing ("ScenarioSummaryWindow", false)
	WindowSetShowing ("EnemyScenarioInfoDialog", true)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_IsOpen ()
	return WindowGetShowing ("EnemyScenarioInfoDialog")
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_Hide ()
	g.isActive = false
	WindowSetShowing ("EnemyScenarioInfoDialog", false)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_SwitchToStandard ()
	Enemy.ScenarioInfoUI_ScenarioInfoDialog_Hide ()
	WindowSetShowing ("ScenarioSummaryWindow", true)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnShown ()

    BroadcastEvent (SystemData.Events.SCENARIO_START_UPDATING_PLAYERS_STATS)
	Enemy.ScenarioInfoUI_ScenarioInfoDialog_Update ()

    g.updateTimer = EnemyTimer.New ("scenario info sheduled update", 1, function ()
		Enemy.ScenarioInfoUI_ScenarioInfoDialog_Update ()
		return false
	end)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnHidden ()

    BroadcastEvent (SystemData.Events.SCENARIO_STOP_UPDATING_PLAYERS_STATS)

    if (g.updateTimer)
    then
    	g.updateTimer:Remove ()
    	g.updateTimer = nil
    end
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_ShowTooltip ()

	local id = WindowGetId (SystemData.MouseOverWindow.name)
	if (not id) then return end

	local tooltip = g.tooltips[tostring (id)]
	if (not tooltip) then return end

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)

	if (type (tooltip) == "function")
	then
		tooltip ()
	elseif (type (tooltip) == "table")
	then
		local k = 0

		for _, v in pairs (tooltip)
		do
			Tooltips.SetTooltipText (k, 1, towstring (v))
			k = k + 1
		end
	else
		Tooltips.SetTooltipText (1, 1, towstring (tooltip))
	end

	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end

local function SetStatsRow (data)

	LabelSetText ("EnemyScenarioInfoDialog"..data.windowName.."NameLabel", Enemy.isNil (data.name, L""))
	WindowSetId ("EnemyScenarioInfoDialog"..data.windowName.."NameLabel", NewTooltip (data.nameTooltip))

	for k, v in ipairs (data.values)
	do
		local wn = "EnemyScenarioInfoDialog"..data.windowName.."Value"..k.."Label"
		LabelSetText (wn, Enemy.FormatNumberShort (v.data))
		WindowSetId (wn, NewTooltip (v.tooltip))

		if (v.color)
		then
			LabelSetTextColor (wn, Enemy.UnpackRGB (v.color))
		else
			LabelSetTextColor (wn, 255, 255, 255)
		end
	end

	local max_bars = 2

	for k = 1, max_bars
	do
		local wn = "EnemyScenarioInfoDialog"..data.windowName.."Bar"..k

		if (data.bars and data.bars[k])
		then
			WindowSetShowing (wn, true)

			if (not g.statsRowTemplateBarDx)
			then
				g.statsRowTemplateBarDx, g.statsRowTemplateBarDy = WindowGetDimensions (wn)
			end

			local bar = data.bars[k]

			WindowSetDimensions (wn, mfloor (0.5 + g.statsRowTemplateBarDx * bar.value), g.statsRowTemplateBarDy)
			WindowSetTintColor (wn, Enemy.UnpackRGB (bar.color))
			WindowSetAlpha (wn, Enemy.isNil (bar.alpha, 1))

			WindowSetId (wn, NewTooltip (bar.tooltip))
		else
			WindowSetShowing (wn, false)
			WindowSetId (wn, NewTooltip (nil))
		end
	end
end

local function SetStatsRowByHighLow (data)

	local all = g.stats.all[data.realm].all

	local color
	if (data.realm == REALM_DESTR)
	then
		color = COLOR_DESTR
	else
		color = COLOR_ORDER
	end

	SetStatsRow (
	{
		windowName = data.windowName,

		name = data.name,
		nameTooltip = data.nameTooltip,

		values =
		{
			{ data = data.stats.high, tooltip = L"High level ("..towstring (g.highPlayerTooltipText)..L")", color = color },
			{ data = data.stats.low, tooltip = L"Low level", color = color },
			{ data = data.stats.all, tooltip = "Total count", color = color }
		},

		bars =
		{
			{
				value = data.stats.high / all,
				color = data.color,
				tooltip = function ()
					Tooltips.SetTooltipText (1, 1, L"High level ("..towstring (g.highPlayerTooltipText)..L")")
					Tooltips.SetTooltipText (2, 1, L"Total "..towstring (data.stats.high))
					Tooltips.SetTooltipText (3, 1, towstring (mfloor (0.5 + data.stats.high / all * 100.0))..L"%")
				end
			},
			{
				value = data.stats.low / all,
				color = data.color,
				alpha = 0.7,
				tooltip = function ()
					Tooltips.SetTooltipText (1, 1, L"Low level")
					Tooltips.SetTooltipText (2, 1, L"Total "..towstring (data.stats.low))
					Tooltips.SetTooltipText (3, 1, towstring (mfloor (0.5 + data.stats.low / all * 100.0))..L"%")
				end
			}
		}
	})
end

local function SetStatsRowByRealms (data)

	local all = data.stats[REALM_DESTR].all + data.stats[REALM_ORDER].all

	SetStatsRow (
	{
		windowName = data.windowName,

		name = data.name,
		nameTooltip = data.nameTooltip,

		values =
		{
			{ data = data.stats[REALM_DESTR].all, tooltip = L"Destruction", color = COLOR_DESTR },
			{ data = data.stats[REALM_ORDER].all, tooltip = L"Order", color = COLOR_ORDER },
			{ data = all, tooltip = L"Total" }
		},

		bars =
		{
			{
				value = data.stats[REALM_DESTR].all / all,
				color = COLOR_DESTR,
				tooltip = function ()
					Tooltips.SetTooltipText (1, 1, L"Destruction")
					Tooltips.SetTooltipText (2, 1, L"Total "..towstring (data.stats[REALM_DESTR].all))
					Tooltips.SetTooltipText (3, 1, towstring (mfloor (0.5 + data.stats[REALM_DESTR].all / all * 100.0))..L"%")
				end
			},
			{
				value = data.stats[REALM_ORDER].all / all,
				color = COLOR_ORDER,
				tooltip = function ()
					Tooltips.SetTooltipText (1, 1, L"Order")
					Tooltips.SetTooltipText (2, 1, L"Total "..towstring (data.stats[REALM_ORDER].all))
					Tooltips.SetTooltipText (3, 1, towstring (mfloor (0.5 + data.stats[REALM_ORDER].all / all * 100.0))..L"%")
				end
			}
		}
	})
end

function Enemy.ScenarioInfoUI_ScenarioInfoDialog_Update ()

	if (not Enemy.ScenarioInfoUI_ScenarioInfoDialog_IsOpen ()) then return end

	Enemy.ScenarioInfoUpdateData ()

	-- reset statistics
	g.maxId = 0
	g.tooltips = {}

	local stats_names = { "all", "high", "dps", "rdps", "mdps", "healers", "tanks", "damage", "healing", "db", "deaths", "solokills", "soloKills", "exp", "experience", }

	for _, v in pairs (g.careerIndexes)
	do
		tinsert (stats_names, "career"..v)
	end

	g.stats = {}

	for _, v in pairs (stats_names)
	do
		g.stats[v] =
		{
			[REALM_DESTR] = { all = 0, high = 0, low = 0, allPlayers = {}, highPlayers = {}, lowPlayers = {} },
			[REALM_ORDER] = { all = 0, high = 0, low = 0, allPlayers = {}, highPlayers = {}, lowPlayers = {} }
		}
	end

	-- determine high level player min level
	if (GameData.Player.level <= 11)
	then
		g.highPlayerMinLevel = 10
		g.highPlayerTooltipText = L"10+"
	elseif (GameData.Player.level <= 21)
	then
		g.highPlayerMinLevel = 20
		g.highPlayerTooltipText = L"20+"
	elseif (GameData.Player.level <= 31)
	then
		g.highPlayerMinLevel = 30
		g.highPlayerTooltipText = L"30+"
	else
		g.highPlayerMinLevel = 40
		g.highPlayerTooltipText = L"40"
	end

	-- calculate statistics
	for _, player in ipairs (g.players)
	do
		StatsAddPlayer (g.stats.all, player)

		if (player.level >= g.highPlayerMinLevel)
		then
			StatsAddPlayer (g.stats.high, player)
		end

		player.archetype = g.careerToArchetype[player.career]
		player.archetype2 = g.careerToArchetype2[player.career]

		StatsAddPlayer (g.stats[player.archetype], player)
		StatsAddPlayer (g.stats["career"..g.careerIndexes[player.career]], player)

		if (player.archetype == "rdps" or player.archetype == "mdps")
		then
			StatsAddPlayer (g.stats.dps, player)
		end


		StatsAddPlayer (g.stats.damage, player, player.damage)
		StatsAddPlayer (g.stats.healing, player, player.healing)
		StatsAddPlayer (g.stats.solokills, player, player.soloKills)
		StatsAddPlayer (g.stats.db, player, player.db)
		StatsAddPlayer (g.stats.deaths, player, player.deaths)
		StatsAddPlayer (g.stats.soloKills, player, player.soloKills)
		StatsAddPlayer (g.stats.exp, player, player.exp)
		StatsAddPlayer (g.stats.experience, player, player.experience)


	end

	for _, v in pairs (g.careerIndexes)
	do
		LabelSetText ("EnemyScenarioInfoDialogStatsCareer"..v.."Value", Enemy.toWStringOrEmpty (g.stats["career"..v][REALM_DESTR].all + g.stats["career"..v][REALM_ORDER].all))
	end

	SetStatsRowByRealms (
	{
		windowName = "StatsAll",
		name = L"All",
		nameTooltip = L"Total numbers of all players",
		stats = g.stats.all
	})
	SetStatsRowByRealms (
	{
		windowName = "StatsHigh",
		name = L"High level",
		nameTooltip = L"Total numbers of all high level players ("..g.highPlayerTooltipText..L")",
		stats = g.stats.high
	})


	SetStatsRowByRealms (
	{
		windowName = "StatsDps",
		name = L"DPS",
		nameTooltip = L"DPS",
		stats = g.stats.dps
	})
	SetStatsRowByRealms (
	{
		windowName = "StatsMdps",
		name = L"MDPS",
		nameTooltip = L"MDPS",
		stats = g.stats.mdps
	})
	SetStatsRowByRealms (
	{
		windowName = "StatsRdps",
		name = L"RDPS",
		nameTooltip = L"RDPS",
		stats = g.stats.rdps
	})
	SetStatsRowByRealms (
	{
		windowName = "StatsHealers",
		name = L"Healers",
		nameTooltip = L"Healers",
		stats = g.stats.healers
	})
	SetStatsRowByRealms (
	{
		windowName = "StatsTanks",
		name = L"Tanks",
		nameTooltip = L"Tanks",
		stats = g.stats.tanks
	})


	SetStatsRowByRealms (
	{
		windowName = "StatsDamage",
		name = L"Damage",
		nameTooltip = L"Total damage done",
		stats = g.stats.damage,
	})
	SetStatsRowByRealms (
	{
		windowName = "StatsHealing",
		name = L"Healing",
		nameTooltip = L"Total healing done",
		stats = g.stats.healing
	})

	SetStatsRowByRealms (
	{
		windowName = "StatssoloKills",
		name = L"Protection",
		nameTooltip = L"Total protection given",
		stats = g.stats.soloKills
	})


	SetStatsRowByRealms (
	{
		windowName = "StatsDB",
		name = L"DB",
		nameTooltip = L"Total death blows done",
		stats = g.stats.db
	})
	SetStatsRowByRealms (
	{
		windowName = "StatsDeaths",
		name = L"Deaths",
		nameTooltip = L"Total deaths",
		stats = g.stats.deaths
	})
	SetStatsRowByRealms (
	{
		windowName = "Statsexp",
		name = L"Objectives",
		nameTooltip = L"Total objectives score",
		stats = g.stats.exp
	})


	LabelSetTextColor ("EnemyScenarioInfoDialogScoreDestrLabel", Enemy.UnpackRGB (COLOR_DESTR))
	LabelSetText ("EnemyScenarioInfoDialogScoreDestrLabel", towstring (g.scenarioData.destructionPoints))
	WindowSetId ("EnemyScenarioInfoDialogScoreDestrLabel", NewTooltip (L"Destruction points"))
	LabelSetTextColor ("EnemyScenarioInfoDialogScoreOrderLabel", Enemy.UnpackRGB (COLOR_ORDER))
	LabelSetText ("EnemyScenarioInfoDialogScoreOrderLabel", towstring (g.scenarioData.orderPoints))
	WindowSetId ("EnemyScenarioInfoDialogScoreOrderLabel", NewTooltip (L"Order points"))

	local standard_scenario_info_visible = WindowGetShowing ("ScenarioSummaryWindow")
	if (standard_scenario_info_visible)
	then
		WindowSetAlpha ("EnemyScenarioInfoDialogBackground", 1)
	else
		WindowSetAlpha ("EnemyScenarioInfoDialogBackground", 0.8)
	end

	if (GameData.ScenarioData.mode == GameData.ScenarioMode.PRE_MODE)
	then
		WindowSetShowing ("EnemyScenarioInfoDialogTimerLabel", true)
		WindowSetShowing ("EnemyScenarioInfoDialogCancelButton", true)
		WindowSetShowing ("EnemyScenarioInfoDialogCancel2Button", true)
		WindowSetShowing ("EnemyScenarioInfoDialogLeaveButton", false)

		LabelSetText ("EnemyScenarioInfoDialogTimerLabel", TimeUtils.FormatClock (g.scenarioData.timeLeft))
		WindowSetId ("EnemyScenarioInfoDialogTimerLabel", NewTooltip (L"Time till start"))

	elseif (GameData.ScenarioData.mode == GameData.ScenarioMode.RUNNING)
	then
		WindowSetShowing ("EnemyScenarioInfoDialogTimerLabel", true)
		WindowSetShowing ("EnemyScenarioInfoDialogCancelButton", true)
		WindowSetShowing ("EnemyScenarioInfoDialogCancel2Button", true)
		WindowSetShowing ("EnemyScenarioInfoDialogLeaveButton", false)

		g.timePlayed = g.scenarioData.maxTimer - g.scenarioData.timeLeft
		LabelSetText ("EnemyScenarioInfoDialogTimerLabel", TimeUtils.FormatClock (g.timePlayed))
		WindowSetId ("EnemyScenarioInfoDialogTimerLabel", NewTooltip (L"Time played"))

	elseif (GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE)
	then
		WindowSetShowing ("EnemyScenarioInfoDialogCancelButton", standard_scenario_info_visible)
		WindowSetShowing ("EnemyScenarioInfoDialogCancel2Button", standard_scenario_info_visible)

		if (ScenarioSummaryWindow.currentMode ~= ScenarioSummaryWindow.MODE_LOADING_SCREEN)
		then
			WindowSetShowing ("EnemyScenarioInfoDialogLeaveButton", true)
			WindowSetShowing ("EnemyScenarioInfoDialogTimerLabel", false)
		else
			WindowSetShowing ("EnemyScenarioInfoDialogLeaveButton", false)
			WindowSetShowing ("EnemyScenarioInfoDialogTimerLabel", true)
			LabelSetText ("EnemyScenarioInfoDialogTimerLabel", TimeUtils.FormatClock (g.timePlayed))
			WindowSetId ("EnemyScenarioInfoDialogTimerLabel", NewTooltip (L"Time played"))
		end

	else
		WindowSetShowing ("EnemyScenarioInfoDialogCancelButton", true)
		WindowSetShowing ("EnemyScenarioInfoDialogCancel2Button", true)
		WindowSetShowing ("EnemyScenarioInfoDialogLeaveButton", false)

		if (g.timePlayed)
		then
			WindowSetShowing ("EnemyScenarioInfoDialogTimerLabel", true)
			LabelSetText ("EnemyScenarioInfoDialogTimerLabel", TimeUtils.FormatClock (g.timePlayed))
			WindowSetId ("EnemyScenarioInfoDialogTimerLabel", NewTooltip (L"Time played"))
		else
			WindowSetShowing ("EnemyScenarioInfoDialogTimerLabel", false)
		end
	end

	Enemy.ScenarioInfoUI_ScenarioInfoDialog_UpdateSelection ()
end


local function UpdateList (index, manual)

	local wn = "EnemyScenarioInfoDialogList"..index
	local sel = g.selection[index]

	if (not manual)
	then
		-- override displaying columns
		local id = sel.id:lower ()

		if (id == "career")
		then
			for k, v in pairs (g.careerIndexes)
			do
				if (tonumber (sel.id2) == v)
				then
					id = g.careerToArchetype[k]
				end
			end
		end

		if (id == "dps" or id == "rdps" or id == "mdps" or id == "damage")
		then
			sel.columns[1] = "damage"

		elseif (id == "healers" or id == "healing")
		then
			sel.columns[1] = "healing"
			elseif ( id == "tanks" or id == "solokills")
			then
			sel.columns[1] = "soloKills"

		elseif (id == "deaths")
		then
			sel.columns[1] = "deaths"
		elseif (id == "exp")
		then
		sel.columns[1] = "exp"
			else
			sel.columns[1] = "db"
		end
	end

	if (not sel.sortColumn)
	then
		sel.sortColumn = "value1"
		sel.sortDirection = false

	elseif (sel.sortDirection == nil)
	then
		sel.sortDirection = true
	end

	local data = {}
	for _, player in ipairs (sel._players)
	do
		local value1 = player[sel.columns[1]]
		local value2 = player[sel.columns[2]]

--		if (type (value1) == "number") then value1 = Enemy.RoundNumberShort (value1) end
--		if (type (value2) == "number") then value2 = Enemy.RoundNumberShort (value2) end

		tinsert (data,
		{
			value1 = value1,
			value2 = value2,
			player = player
		})
	end

	if (sel.sortColumn == "value1" or sel.sortColumn == "value2")
	then
		tsort (data, function (a, b)

			local aval = a[sel.sortColumn]
			local bval = b[sel.sortColumn]

			if (aval == bval)
			then
				aval = a.player.level
				bval = b.player.level

				if (aval == bval)
				then
					aval = a.player.archetype2
					bval = b.player.archetype2

					if (aval == bval)
					then
						return a.player.name < b.player.name
					end

					return aval < bval
				end

				return aval < bval
			end

			return aval < bval
		end)

	elseif (sel.sortColumn == "level")
	then
		tsort (data, function (a, b)

			local aval = a.player[sel.sortColumn]
			local bval = b.player[sel.sortColumn]

			if (aval == bval)
			then
				aval = a.player.archetype2
				bval = b.player.archetype2

				if (aval == bval)
				then
					return a.player.name < b.player.name
				end

				return aval < bval
			end

			return aval < bval
		end)

	else
		tsort (data, function (a, b)

			local aval = a.player[sel.sortColumn]
			local bval = b.player[sel.sortColumn]

			if (aval == bval)
			then
				aval = a.player.level
				bval = b.player.level

				if (aval == bval)
				then
					return a.player.name < b.player.name
				end

				return aval < bval
			end

			return aval < bval
		end)
	end

	local indexes = {}
	local max = #data
	for index, _ in ipairs (data)
	do
		if (sel.sortDirection)
		then
			tinsert (indexes, index)
		else
			tinsert (indexes, max - index + 1)
		end
	end

	Enemy["scenarioInfoList"..index.."Data"] = data
	Enemy["scenarioInfoList"..index.."Indexes"] = indexes

	ListBoxSetDisplayOrder (wn, indexes)

	WindowSetShowing (wn.."HeaderSortArchetype2UpArrow", false)
	WindowSetShowing (wn.."HeaderSortArchetype2DownArrow", false)
	WindowSetShowing (wn.."HeaderSortLevelUpArrow", false)
	WindowSetShowing (wn.."HeaderSortLevelDownArrow", false)
	WindowSetShowing (wn.."HeaderSortNameUpArrow", false)
	WindowSetShowing (wn.."HeaderSortNameDownArrow", false)
	WindowSetShowing (wn.."HeaderSortValue1UpArrow", false)
	WindowSetShowing (wn.."HeaderSortValue1DownArrow", false)
	WindowSetShowing (wn.."HeaderSortValue2UpArrow", false)
	WindowSetShowing (wn.."HeaderSortValue2DownArrow", false)

	ButtonSetText (wn.."HeaderSortName", L"Name")
	ButtonSetText (wn.."HeaderSortValue1", g.sortColumns[sel.columns[1]].title)
	ButtonSetText (wn.."HeaderSortValue2", g.sortColumns[sel.columns[2]].title)

	local sort_name = "Down"
	if (sel.sortDirection)
	then
		sort_name = "Up"
	end

	WindowSetShowing (wn.."HeaderSort"..Enemy.capitalize (sel.sortColumn)..sort_name.."Arrow", true)
end


local function PopulateList (index)

	local wn = "EnemyScenarioInfoDialogList"..index
	local list = _G[wn]
	if (list.PopulatorIndices == nil) then return end

	local data = Enemy["scenarioInfoList"..index.."Data"]

	local wnr
	local d

	for k, v in ipairs (list.PopulatorIndices)
	do
		wnr = wn.."Row"..k
		d = data[v]

		local icon, icon_x, icon_y = GetIconData (Icons.GetCareerIconIDFromCareerLine (d.player.career))
		DynamicImageSetTexture (wnr.."Icon", icon, icon_x, icon_y)

		LabelSetText (wnr.."Level", towstring (d.player.level))
		LabelSetText (wnr.."Name", d.player.name)
		LabelSetText (wnr.."Value1", Enemy.FormatNumberShort (d.value1))
		LabelSetText (wnr.."Value2", Enemy.FormatNumberShort (d.value2))
	end
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnList1Populate ()
	PopulateList (1)
end

function Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnList2Populate ()
	PopulateList (2)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_UpdateSelection ()

	local padding = 4

	for k, sel in ipairs (g.selection)
	do
		local wn = "EnemyScenarioInfoDialogSelection"..k

		if (not sel.id)
		then
			WindowSetShowing (wn, false)
		else
			local wn2
			local id = sel.id:lower ()

			if (id == "career")
			then
				wn2 = "EnemyScenarioInfoDialogStats"..sel.id..sel.id2
			else
				wn2 = "EnemyScenarioInfoDialogStats"..sel.id..Enemy.isNil (sel.id3, "").."Value"..sel.id2.."Label"
			end

			local dx, dy = WindowGetDimensions (wn2)

			WindowSetShowing (wn, true)
			WindowClearAnchors (wn)

			if (id == "career")
			then
				WindowSetDimensions (wn, dx, dy)
				WindowAddAnchor (wn, "topleft", wn2, "topleft", 0, 0)
			else
				WindowSetDimensions (wn, dx - 1, dy + padding * 2)
				WindowAddAnchor (wn, "topleft", wn2, "topleft", 1, -padding)
			end

			local wnl = "EnemyScenarioInfoDialogList"..k
			LabelSetText (wnl.."TitleLabel", L"")

			local realm = nil
			if (id ~= "career")
			then
				if (sel.id3 == "Destr")
				then
					realm = REALM_DESTR
				elseif (sel.id3 == "Order")
				then
					realm = REALM_ORDER
				elseif (sel.id2 == "1")
				then
					realm = REALM_DESTR
				elseif (sel.id2 == "2")
				then
					realm = REALM_ORDER
				end
			end

			if (id == "count")
			then
				id = "all"
			end

			local s
			if (id == "career")
			then
				s = g.stats[id..sel.id2]
			else
				s = g.stats[id]
			end

			local players_prefix = "all"
			if (sel.id3)
			then
				if (sel.id2 == "1")
				then
					players_prefix = "high"

				elseif (sel.id2 == "2")
				then
					players_prefix = "low"
				end
			end

			local players = nil

			if (realm)
			then
				players = s[realm][players_prefix.."Players"]
			else
				players = {}

				for _, player in ipairs(s[REALM_DESTR][players_prefix.."Players"])
				do
					tinsert (players, player)
				end

				for _, player in ipairs(s[REALM_ORDER][players_prefix.."Players"])
				do
					tinsert (players, player)
				end
			end

			sel._players = players

			UpdateList (k)
		end
	end
end


local function Select (index)

	local sel = g.selection[index]

	sel.id3 = "Destr"
	sel.id, sel.id2 = SystemData.ActiveWindow.name:match ("^EnemyScenarioInfoDialogStats(.-)DestrValue(%d)Label$")

	if (not sel.id)
	then
		sel.id3 = "Order"
		sel.id, sel.id2 = SystemData.ActiveWindow.name:match ("^EnemyScenarioInfoDialogStats(.-)OrderValue(%d)Label$")

		if (not sel.id)
		then
			sel.id3 = nil
			sel.id, sel.id2 = SystemData.ActiveWindow.name:match ("^EnemyScenarioInfoDialogStats(.-)Value(%d)Label$")

			if (not sel.id)
			then
				sel.id3 = nil
				sel.id, sel.id2 = SystemData.ActiveWindow.name:match ("^EnemyScenarioInfoDialogStats(Career)(%d+).*$")
			end
		end
	end

	Enemy.ScenarioInfoUI_ScenarioInfoDialog_UpdateSelection ()
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnValueLClick ()
	Select (1)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_OnValueRClick ()
	Select (2)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_SortColumnClick ()

	local index, sort_column = SystemData.ActiveWindow.name:match ("^EnemyScenarioInfoDialogList(%d)HeaderSort(.-)$")
	if (not index) then return end

	index = tonumber (index)
	sort_column = sort_column:lower()

	local sel = g.selection[index]

	if (sel.sortColumn ~= sort_column)
	then
		sel.sortColumn = sort_column

		if (sel.sortColumn == "value1")
		then
			sel.sortDirection = g.sortColumns[sel.columns[1]].defaultSortDirection

		elseif (sel.sortColumn == "value2")
		then
			sel.sortDirection = g.sortColumns[sel.columns[2]].defaultSortDirection

		else
			sel.sortDirection = g.sortColumns[sel.sortColumn].defaultSortDirection
		end
	else
		sel.sortDirection = not sel.sortDirection
	end

	UpdateList (index, true)
end


function Enemy.ScenarioInfoUI_ScenarioInfoDialog_SortColumnRClick ()

	local index, sv = SystemData.ActiveWindow.name:match ("^EnemyScenarioInfoDialogList(%d)HeaderSortValue(.-)$")
	index = tonumber (index)
	sv = tonumber (sv)

	EA_Window_ContextMenu.CreateContextMenu ("EnemyScenarioInfoDialogList"..index.."HeaderSortValue"..sv, 1)
	WindowSetLayer ("EA_Window_ContextMenu1", Window.Layers.OVERLAY)

	local data = {}
	for _, v in pairs (g.sortColumns)
	do
		if (v.isInternal) then continue end
		tinsert (data, v)
	end

	tsort (data, function (a, b)
		return (a.orderNum < b.orderNum)
	end)

	for _, v in ipairs (data)
	do
		EA_Window_ContextMenu.AddMenuItem (v.title, function ()

			g.selection[index].columns[sv] = v.key
			UpdateList (index, true)

		end, false, true)
	end

	EA_Window_ContextMenu.Finalize ()
end


--------------------------------------------------------------- UI: Configuration
local config_dlg =
{
	properties =
	{
		scenarioInfoEnabled =
		{
			key = "scenarioInfoEnabled",
			order = 10,
			name = L"Enable scenarion info",
			type = "bool",
			default = Enemy.DefaultSettings.scenarioInfoEnabled
		},
		scenarioInfoReplaceStandardWindow =
		{
			key = "scenarioInfoReplaceStandardWindow",
			order = 20,
			name = L"Replace standard scenario ending window",
			type = "bool",
			default = Enemy.DefaultSettings.scenarioInfoReplaceStandardWindow
		}
	}
}


function Enemy.ScenarioInfoUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section

	local root = config_dlg.section.windowName.."Config"
	config_dlg.cwn = root.."W"
	local width, height = Enemy.CreateConfigurationWindow (config_dlg.cwn, root, config_dlg.properties, Enemy.ScenarioInfoUI_ConfigDialog_TestSettings)
	WindowSetDimensions (root, width, height)


	LabelSetText (config_dlg.section.windowName.."MacrosLabel", L"Macroses (drag them to your hotbar)")

	local macros = DataUtils.GetMacros()

	local macro_id = Enemy.GetMacroId (MACRO_TOGGLE)
	if (macro_id)
	then
		local texture, x, y = GetIconData (macros[macro_id].iconNum)
    	DynamicImageSetTexture (config_dlg.section.windowName.."MacroToggleIconBase", texture, x, y)
	end
end


local function OnMacroMouseDrag (text)

	if (not Cursor.IconOnCursor())
	then
		local macro_id = Enemy.GetMacroId (text)
		local macros = DataUtils.GetMacros ()

		Cursor.PickUp (Cursor.SOURCE_MACRO, macro_id, macro_id, macros[macro_id].iconNum, false)
		EA_Window_Macro.UpdateDetails (macro_id)
	end
end


function Enemy.ScenarioInfoUI_ConfigDialog_OnMacroToggleMouseDrag ()
	OnMacroMouseDrag (MACRO_TOGGLE)
end


function Enemy.ScenarioInfoUI_ConfigDialog_OnMacroToggleMouseOver ()
	Tooltips.CreateTextOnlyTooltip (config_dlg.section.windowName.."MacroToggle")
	Tooltips.SetTooltipText (1, 1, L"Toggle")
	Tooltips.SetTooltipText (2, 1, L"Toggle visibility of scenario info window")
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.ScenarioInfoUI_ConfigDialog_OnLoad (section)

	config_dlg.isLoading = true

	config_dlg.scenarioInfoEnabled = Enemy.Settings.scenarioInfoEnabled
	config_dlg.scenarioInfoReplaceStandardWindow = Enemy.Settings.scenarioInfoReplaceStandardWindow

	Enemy.ConfigurationWindowLoadData (config_dlg.cwn, config_dlg)

	config_dlg.isLoading = false

	Enemy.ScenarioInfoUI_ConfigDialog_TestSettings ()
end


function Enemy.ScenarioInfoUI_ConfigDialog_TestSettings ()

	if (config_dlg.isLoading) then return end

	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, config_dlg)
	Enemy.ScenarioInfo_OnSettingsChanged (config_dlg)
end

function Enemy.ScenarioInfoUI_ConfigDialog_OnSave (section)

	Enemy.ScenarioInfoUI_ConfigDialog_TestSettings ()

	Enemy.Settings.scenarioInfoEnabled = config_dlg.scenarioInfoEnabled
	Enemy.Settings.scenarioInfoReplaceStandardWindow = config_dlg.scenarioInfoReplaceStandardWindow

	return true
end
