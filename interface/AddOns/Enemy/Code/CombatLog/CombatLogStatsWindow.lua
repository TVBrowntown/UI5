local Enemy = Enemy
local dlg = nil
local g = nil

local tinsert = table.insert
local tsort = table.sort
local pairs = pairs
local ipairs = ipairs
local mfloor = math.floor
local unpack = unpack


local MAX_SESSION_COMBO_BOX_NAME_LENGTH = 33


function Enemy.CombatLogUI_StatsWindow_Initialize ()

	g = Enemy.combatLog
		
	if (Enemy.Settings.prevVersion > 0)
	then
		if (math.modf (Enemy.Settings.prevVersion) < 278)
		then
			g.settings.combatLogStatsWindowColumns = nil
		end
	end
			

	Enemy.AddEventHandler ("CombatLogUI_StatsWindow", "IconCreateContextMenu", function (data)
		
		if (Enemy.CombatLogUI_StatsWindow_IsOpen ())
		then
			table.insert (data,
			{
				text = L"Hide combat log stats window",
				callback = Enemy.CombatLogUI_StatsWindow_Hide
			})
		else
			table.insert (data,
			{
				text = L"Show combat log stats window",
				callback = Enemy.CombatLogUI_StatsWindow_Open,
				disabled = (not Enemy.Settings.combatLogEnabled or not Enemy.Settings.combatLogStatisticsEnabled)
			})
		end
	end)
end
	

function Enemy.CombatLogStatsWindowToggle ()
	if (Enemy.CombatLogUI_StatsWindow_IsOpen ())
	then
		Enemy.CombatLogUI_StatsWindow_Hide ()
	else
		Enemy.CombatLogUI_StatsWindow_Open ()
	end
end


function Enemy.CombatLogUI_StatsWindow_IsOpen ()
	return dlg and WindowGetShowing ("EnemyCombatLogStatsWindow")
end


function Enemy.CombatLogUI_StatsWindow_Hide ()

	WindowSetShowing ("EnemyCombatLogStatsWindow", false)
	
	if (dlg)
	then
		Enemy.RemoveEventHandler ("CombatLogUI_StatsWindow", "CombatLogSessionsUpdated")
		Enemy.RemoveEventHandler ("CombatLogUI_StatsWindow", "CombatLogNewCombatEvent")
		
		dlg.isActive = false
	end
end


function Enemy.CombatLogUI_StatsWindow_GetObjectInfoTooltipString (object)
	if (not object) then return L"" end

	local res = object.name

	if (object.level)
	then
		res = res..L" lvl "..Enemy.toWString (object.level)
	end

	if (object.isNpc)
	then
		res = res..L" mob"
	elseif (object.career)
	then
		local n = CareerNames[object.career]
		if (not n)
		then
			res = res..L" mob"
		else
			res = res..L" "..n.name
		end
	end

	return res
end
			
			
function Enemy.CombatLogUI_StatsWindow_Open (selectType)
	
	if (not g.settings.combatLogEnabled or not g.settings.combatLogStatisticsEnabled) then return end
		
	if (not dlg)
	then
		-- initialize
		CreateWindow ("EnemyCombatLogStatsWindow", false)
		LabelSetText ("EnemyCombatLogStatsWindowTitleBarText", L"Combat log statistics")
		
		LabelSetText ("EnemyCombatLogStatsWindowSessionLabel", L"Session")
		ButtonSetText ("EnemyCombatLogStatsWindowSessionAddButton", L"New")
		ButtonSetText ("EnemyCombatLogStatsWindowSessionRenameButton", L"Rename")
		LabelSetText ("EnemyCombatLogStatsWindowTypeLabel", L"Type")

		dlg = {}

		dlg.types =
		{
			[1] =
			{
				text = Enemy.CombatLogTypeNames[Enemy.CombatLogTypes.OutgoingDamage],
				epsText = Enemy.CombatLogTypeEpsNames[Enemy.CombatLogTypes.OutgoingDamage],
				value = Enemy.CombatLogTypes.OutgoingDamage,
				defaultColumns = { "name", "totalPercent", "critPercent", "maxNormal", "maxCrit", "mitPercent" },
				defaultSortColumn = 2,
				defaultSortDirection = false
			},
			
			[2] =
			{
				text = Enemy.CombatLogTypeNames[Enemy.CombatLogTypes.IncommingDamage],
				epsText = Enemy.CombatLogTypeEpsNames[Enemy.CombatLogTypes.IncommingDamage],
				value = Enemy.CombatLogTypes.IncommingDamage,
				defaultColumns = { "name", "totalPercent", "critPercent", "maxNormal", "maxCrit", "mitPercent" },
				defaultSortColumn = 2,
				defaultSortDirection = false
			},
					
			[3] =
			{
				text = Enemy.CombatLogTypeNames[Enemy.CombatLogTypes.OutgoingHeal],
				epsText = Enemy.CombatLogTypeEpsNames[Enemy.CombatLogTypes.OutgoingHeal],
				value = Enemy.CombatLogTypes.OutgoingHeal,
				defaultColumns = { "name", "totalPercent", "critPercent", "maxNormal", "maxCrit", "overhealPercent" },
				defaultSortColumn = 2,
				defaultSortDirection = false
			},
			
			[4] =
			{
				text = Enemy.CombatLogTypeNames[Enemy.CombatLogTypes.IncommingHeal],
				epsText = Enemy.CombatLogTypeEpsNames[Enemy.CombatLogTypes.IncommingHeal],
				value = Enemy.CombatLogTypes.IncommingHeal,
				defaultColumns = { "name", "totalPercent", "critPercent", "maxNormal", "maxCrit", "overhealPercent" },
				defaultSortColumn = 2,
				defaultSortDirection = false
			}
		}
		
		local order_number = 0
		local getNextOrder = function () order_number = order_number + 1; return order_number; end
		
		dlg.columns =
		{
			name =
			{
				key = "name",
				name = L"Name",
				title = L"Name",
				color = { 255, 204, 102 },
				getValue = function(item) return item.name end,
				getValueString = function (item) return item.name end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = false, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = false, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = true,
				order = getNextOrder ()
			},
					
			count =
			{
				key = "count",
				name = L"Count",
				title = L"Count",
				color = { 150, 150, 150 },
				getValue = function (item) return item.count end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.count, true) end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},

			normalPercent =
			{
				key = "normalPercent",
				name = L"Normal %",
				title = L"Normal",
				getValue = function (item) return item.normal.percent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.normal.percent, true)..L" %" end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			avgNormal =
			{
				key = "avgNormal",
				name = L"Average (normal)",
				tooltipName = L"Average",
				title = L"Avg N",
				getValue = function (item) return item.normal.avg end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.normal.avg, true) end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			--[[
			minNormal =
			{
				key = "minNormal",
				name = L"Min (normal)",
				tooltipName = L"Min",
				title = L"Min N",
				getValue = function (item) return item.normal.min end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.normal.min, true) end,
				getObjectString = function (item) return Enemy.CombatLogUI_StatsWindow_GetObjectInfoTooltipString (item.normal.minObject) end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			]]--
			maxNormal =
			{
				key = "maxNormal",
				name = L"Max (normal)",
				tooltipName = L"Max",
				title = L"Max N",
				getValue = function (item) return item.normal.max end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.normal.max, true) end,
				getObjectString = function (item) return Enemy.CombatLogUI_StatsWindow_GetObjectInfoTooltipString (item.normal.maxObject) end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			mitNormal =
			{
				key = "mitNormal",
				name = L"Mitigation (normal)",
				tooltipName = L"Mitigation",
				title = L"Mit N",
				getValue = function (item) return item.normal.mitPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.normal.mitPercent, true)..L" %" end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			absNormal =
			{
				key = "absNormal",
				name = L"Absorb (normal)",
				tooltipName = L"Absorb",
				title = L"Abs N",
				getValue = function (item) return item.normal.absPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.normal.absPercent, true)..L" %" end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			},


			
			critPercent =
			{
				key = "critPercent",
				name = L"Crit %",
				title = L"Crit",
				getValue = function (item) return item.crit.percent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.crit.percent, true)..L" %" end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				color = { 150, 255, 50 },
				order = getNextOrder ()
			},
			avgCrit =
			{
				key = "avgCrit",
				name = L"Average (crit)",
				tooltipName = L"Average",
				title = L"Avg C",
				getValue = function (item) return item.crit.avg end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.crit.avg, true) end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				color = { 150, 255, 50 },
				order = getNextOrder ()
			},
			--[[
			minCrit =
			{
				key = "minCrit",
				name = L"Min (crit)",
				tooltipName = L"Min",
				title = L"Min C",
				getValue = function (item) return item.crit.min end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.crit.min, true) end,
				getObjectString = function (item) return Enemy.CombatLogUI_StatsWindow_GetObjectInfoTooltipString (item.crit.minObject) end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				color = { 150, 255, 50 },
				order = getNextOrder ()
			},
			]]--
			maxCrit =
			{
				key = "maxCrit",
				name = L"Max (crit)",
				tooltipName = L"Max",
				title = L"Max C",
				getValue = function (item) return item.crit.max end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.crit.max, true) end,
				getObjectString = function (item) return Enemy.CombatLogUI_StatsWindow_GetObjectInfoTooltipString (item.crit.maxObject) end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				color = { 150, 255, 50 },
				order = getNextOrder ()
			},
			mitCrit =
			{
				key = "mitCrit",
				name = L"Mitigation (crit)",
				tooltipName = L"Mitigation",
				title = L"Mit C",
				getValue = function (item) return item.crit.mitPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.crit.mitPercent, true)..L" %" end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				color = { 150, 255, 50 },
				order = getNextOrder ()
			},
			absCrit =
			{
				key = "absCrit",
				name = L"Absorb (crit)",
				tooltipName = L"Absorb",
				title = L"Abs C",
				getValue = function (item) return item.crit.absPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.crit.absPercent, true)..L" %" end,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				color = { 150, 255, 50 },
				order = getNextOrder ()
			},
					
					
					

			totalPercent =
			{
				key = "totalPercent",
				name = L"Total %",
				title = L"Total",
				getValue = function (item) return item.totalPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.totalPercent)..L" %" end,
				color = { 255, 255, 150 },
				isPercent = true,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			average =
			{
				key = "average",
				name = L"Average",
				title = L"Average",
				getValue = function (item) return item.avg end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.avg, true) end,
				color = { 255, 255, 150 },
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
						
			totalWithOverheal =
			{
				key = "totalWithOverheal",
				name = L"Total with overheal",
				title = L"Total WO",
				getValue = function (item) return item.totalWithOverheal end,
				getValueString = function (item) return Enemy.FormatNumberShort (item.totalWithOverheal, true) end,
				color = { 255, 255, 150 },
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = false, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = false, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			totalWithOverhealPercent =
			{
				key = "totalWithOverhealPercent",
				name = L"Total with overheal %",
				title = L"Total WO",
				getValue = function (item) return item.totalWithOverhealPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.totalWithOverhealPercent)..L" %" end,
				color = { 255, 255, 150 },
				isPercent = true,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = false, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = false, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			overhealPercent =
			{
				key = "overhealPercent",
				name = L"Overheal %",
				title = L"Overheal",
				getValue = function (item) return item.overhealPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.overhealPercent)..L" %" end,
				color = { 255, 255, 150 },
				isPercent = true,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = false, [Enemy.CombatLogTypes.OutgoingHeal] = true, [Enemy.CombatLogTypes.IncommingDamage] = false, [Enemy.CombatLogTypes.IncommingHeal] = true },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			
			mitPercent =
			{
				key = "mitPercent",
				name = L"Mitigation %",
				title = L"Mitigation",
				getValue = function (item) return item.mitPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.mitPercent)..L" %" end,
				color = { 140, 186, 255 },
				isPercent = true,
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			absPercent =
			{
				key = "absPercent",
				name = L"Absorb %",
				title = L"Absorb",
				getValue = function (item) return item.absPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.absPercent)..L" %" end,
				isPercent = true,
				color = { 140, 186, 255 },
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			
			blockPercent =
			{
				key = "blockPercent",
				name = L"Block %",
				title = L"Block",
				getValue = function (item) return item.blockPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.blockPercent)..L" %" end,
				isPercent = true,
				color = { 225, 145, 235 },
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			parryPercent =
			{
				key = "parryPercent",
				name = L"Parry %",
				title = L"Parry",
				getValue = function (item) return item.parryPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.parryPercent)..L" %" end,
				isPercent = true,
				color = { 225, 145, 235 },
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			disruptPercent =
			{
				key = "disruptPercent",
				name = L"Disrupt %",
				title = L"Disrupt",
				getValue = function (item) return item.disruptPercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.disruptPercent)..L" %" end,
				isPercent = true,
				color = { 225, 145, 235 },
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			},
			dodgePercent =
			{
				key = "dodgePercent",
				name = L"Dodge %",
				title = L"Dodge",
				getValue = function (item) return item.dodgePercent end,
				getValueString = function (item) return Enemy.toWStringOrEmpty (item.dodgePercent)..L" %" end,
				isPercent = true,
				color = { 225, 145, 235 },
				types = { [Enemy.CombatLogTypes.OutgoingDamage] = true, [Enemy.CombatLogTypes.OutgoingHeal] = false, [Enemy.CombatLogTypes.IncommingDamage] = true, [Enemy.CombatLogTypes.IncommingHeal] = false },
				defaultSortDirection = false,
				order = getNextOrder ()
			 }
		}
		
		dlg.columnsSorted = {}
		for _, column in pairs (dlg.columns)
		do
			tinsert (dlg.columnsSorted, column)
		end
		
		tsort (dlg.columnsSorted, function (a, b)
			return a.order < b.order
		end)
		
		for _, t in ipairs (dlg.types)
		do
			ComboBoxAddMenuItem ("EnemyCombatLogStatsWindowType", t.text)
		end

		ComboBoxSetSelectedMenuItem ("EnemyCombatLogStatsWindowType", g.settings.combatLogStatsWindowType or 1)

		dlg.initialized = true
	end
			
	if (selectType)
	then
		ComboBoxSetSelectedMenuItem ("EnemyCombatLogStatsWindowType", selectType)
	end

	WindowSetShowing ("EnemyCombatLogStatsWindow", true)
	
	Enemy.AddEventHandler ("CombatLogUI_StatsWindow", "CombatLogSessionsUpdated", Enemy.CombatLogUI_StatsWindow_UpdateSessionsList)
	Enemy.AddEventHandler ("CombatLogUI_StatsWindow", "CombatLogNewCombatEvent", Enemy.CombatLogUI_StatsWindow_OnNewCombatEvent)
	dlg.isActive = true
		
	Enemy.CombatLogUI_StatsWindow_UpdateSessionsList ()
end


function Enemy.CombatLogUI_StatsWindow_UpdateSessionsList ()

	if (not dlg.initialized) then return end

	ComboBoxClearMenuItems ("EnemyCombatLogStatsWindowSession")
	dlg.sessions = {}
		
	for _, stats in ipairs (g.allStats)
	do
		local session =
		{
			stats = stats,
			order = stats.dt.totalSeconds
		}
		
		session.name = Enemy.DateTimeToString (stats.dt)
		if (stats.name) then session.name = session.name..L" - "..stats.name end
		
		tinsert (dlg.sessions, session)
	end
	
	tsort (dlg.sessions, function (a, b)
		return a.order < b.order
	end)
	
	local index = #dlg.sessions
	for k, v in ipairs (dlg.sessions)
	do
		ComboBoxAddMenuItem ("EnemyCombatLogStatsWindowSession", Enemy.TruncateString (v.name, MAX_SESSION_COMBO_BOX_NAME_LENGTH, L"..."))
		if (v.stats == g.stats)
		then
			index = k
		end
	end
	
	ComboBoxSetSelectedMenuItem ("EnemyCombatLogStatsWindowSession", index)
	Enemy.CombatLogUI_StatsWindow_OnSessionSelChanged ()
end


function Enemy.CombatLogUI_StatsWindow_GetCurrentSession ()
	return dlg.sessions[ComboBoxGetSelectedMenuItem ("EnemyCombatLogStatsWindowSession")]
end


function Enemy.CombatLogUI_StatsWindow_OnSessionSelChanged ()

	if (not dlg.initialized) then return end

	local session = Enemy.CombatLogUI_StatsWindow_GetCurrentSession ()
	if (not session) then return end
	
	if (session.stats == g.stats)
	then
		ButtonSetText ("EnemyCombatLogStatsWindowSessionDeleteButton", L"Reset")
	else
		ButtonSetText ("EnemyCombatLogStatsWindowSessionDeleteButton", L"Delete")
	end
	
	if (session.name:len () > MAX_SESSION_COMBO_BOX_NAME_LENGTH)
	then
		LabelSetText ("EnemyCombatLogStatsWindowSessionFullNameLabel", session.stats.name)
	else
		LabelSetText ("EnemyCombatLogStatsWindowSessionFullNameLabel", L"")
	end

	Enemy.CombatLogUI_StatsWindow_OnTypeSelChanged ()
end


function Enemy.CombatLogUI_StatsWindow_SessionAdd ()

	DialogManager.MakeTextEntryDialog (L"New combat log session", L"Enter session name", L"Default", function (text)
		Enemy.CombatLog_StatsSessionAdd (Enemy.trim (text))
	end,
	nil,
	250,
	false)
end


function Enemy.CombatLogUI_StatsWindow_SessionDelete ()

	local session = Enemy.CombatLogUI_StatsWindow_GetCurrentSession ()
	if (not session) then return end

	if (session.stats == g.stats)
	then
		DialogManager.MakeTwoButtonDialog (L"Reset session '"..session.name..L"' ?",
	                                       L"Yes", function ()
	                                       		Enemy.CombatLog_ResetStatsCurrentSession ()
	                                       end,
	                                       L"No")
	else
		DialogManager.MakeTwoButtonDialog (L"Delete session '"..session.name..L"' ?",
	                                       L"Yes", function ()
	                                       		Enemy.CombatLog_StatsSessionDelete (session.stats)
	                                       end,
	                                       L"No")
	end
end


function Enemy.CombatLogUI_StatsWindow_SessionRename ()

	local session = Enemy.CombatLogUI_StatsWindow_GetCurrentSession ()
	if (not session) then return end

	DialogManager.MakeTextEntryDialog (L"Rename combat log session", L"Enter new session name", session.stats.name, function (text)
		
		local index = ComboBoxGetSelectedMenuItem ("EnemyCombatLogStatsWindowSession")

		session.stats.name = Enemy.trim (text)
		Enemy.CombatLogUI_StatsWindow_UpdateSessionsList ()

		ComboBoxSetSelectedMenuItem ("EnemyCombatLogStatsWindowSession", index)
		Enemy.CombatLogUI_StatsWindow_OnSessionSelChanged ()
	end,
	nil,
	250,
	false)
end


function Enemy.CombatLogUI_StatsWindow_GetCurrentType ()
	return dlg.types[ComboBoxGetSelectedMenuItem ("EnemyCombatLogStatsWindowType")]
end


function Enemy.CombatLogUI_StatsWindow_OnTypeSelChanged ()

	if (not dlg.initialized) then return end

	local t = Enemy.CombatLogUI_StatsWindow_GetCurrentType ()
	if (not t) then return end
	
	g.settings.combatLogStatsWindowType = ComboBoxGetSelectedMenuItem ("EnemyCombatLogStatsWindowType")
	
	-- prepare columns
	local columns_settings = g.settings.combatLogStatsWindowColumns
	if (not columns_settings)
	then
		columns_settings = {}
		g.settings.combatLogStatsWindowColumns = columns_settings
	end
	
	dlg.column_settings = columns_settings[t.value]
	if (not dlg.column_settings)
	then
		dlg.column_settings =
		{
			sortColumn = t.defaultSortColumn,
			sortDirection = t.defaultSortDirection,
			columns = Enemy.clone (t.defaultColumns)
		}
		columns_settings[t.value] = dlg.column_settings
	end
	
	Enemy.CombatLogUI_StatsWindow_UpdateColumns ()
	Enemy.CombatLogUI_StatsWindow_UpdateList ()
end


function Enemy.CombatLogUI_StatsWindow_OnNewCombatEvent (combatEvent)
	
	local t = Enemy.CombatLogUI_StatsWindow_GetCurrentType ()
	if (not t or combatEvent.type ~= t.value) then return end

	Enemy.CombatLogUI_StatsWindow_UpdateList ()
end


function Enemy.CombatLogUI_StatsWindow_UpdateColumns ()

	local t = Enemy.CombatLogUI_StatsWindow_GetCurrentType ()
	if (not t) then return end
	
	for k, v in ipairs (dlg.column_settings.columns)
	do
		local wn = "EnemyCombatLogStatsWindowListHeaderSortColumn"..k
		local column_info = dlg.columns[v]
		
		ButtonSetText (wn, column_info.title)		
		WindowSetShowing (wn.."UpArrow", k == dlg.column_settings.sortColumn and dlg.column_settings.sortDirection)
		WindowSetShowing (wn.."DownArrow", k == dlg.column_settings.sortColumn and not dlg.column_settings.sortDirection)
	end
end


function Enemy.CombatLogUI_StatsWindow_UpdateList ()

	local session = Enemy.CombatLogUI_StatsWindow_GetCurrentSession ()
	if (not session or not session.stats.eps) then return end
	
	local t = Enemy.CombatLogUI_StatsWindow_GetCurrentType ()
	local stats_data = session.stats.data[t.value] or {}
	

	local eps = session.stats.eps[t.value]
	if (eps)
	then
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsLabel", true)
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeLabel", true)
		LabelSetText ("EnemyCombatLogStatsWindowEpsLabel", t.epsText)
		LabelSetText ("EnemyCombatLogStatsWindowEpsAoeLabel", t.epsText..L" with AoE")


		if (eps.value ~= nil and eps.value > 0)
		then
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsCurLabel", true)
			LabelSetText ("EnemyCombatLogStatsWindowEpsCurLabel", Enemy.toWString (eps.value))
		else
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsCurLabel", false)
		end

		if (eps.valueMax ~= nil and eps.valueMax > 0)
		then
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsMaxLabel", true)
			LabelSetText ("EnemyCombatLogStatsWindowEpsMaxLabel", L"max "..Enemy.toWString (eps.valueMax))
		else
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsMaxLabel", false)
		end
			

		if (eps.valueAoe ~= nil and eps.valueAoe > 0)
		then
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeCurLabel", true)
			LabelSetText ("EnemyCombatLogStatsWindowEpsAoeCurLabel", Enemy.toWString (eps.valueAoe))
		else
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeCurLabel", false)
		end

		if (eps.valueAoeMax ~= nil and eps.valueAoeMax > 0)
		then
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeMaxLabel", true)
			LabelSetText ("EnemyCombatLogStatsWindowEpsAoeMaxLabel", L"max "..Enemy.toWString (eps.valueAoeMax))
		else
			WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeMaxLabel", false)
		end
	else
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsLabel", false)
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeLabel", false)
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsCurLabel", false)
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsMaxLabel", false)
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeCurLabel", false)
		WindowSetShowing ("EnemyCombatLogStatsWindowEpsAoeMaxLabel", false)
	end

	
	-- prepare list data
	local data = {}
	local total_sum = 0
	local total_with_overheal_sum = 0
	
	for k, v in pairs (stats_data)
	do
		local item = Enemy.clone (v)
		
		item.name = Enemy.capitalize (k)
		
		item.count = item.normal.count + item.crit.count
		if (item.count <= 0) then continue end
			
		item.total = item.normal.total + item.crit.total
		item.normal.percent = mfloor (item.normal.count / item.count * 100.0 + 0.5)
		item.crit.percent = mfloor (item.crit.count / item.count * 100.0 + 0.5)
			
		-- average
		if (item.normal.count > 0)
		then
			item.normal.avg = mfloor (item.normal.total / item.normal.count + 0.5)
		else
			item.normal.avg = nil
		end
			
		if (item.crit.count > 0)
		then
			item.crit.avg = mfloor (item.crit.total / item.crit.count + 0.5)
		else
			item.crit.avg = nil
		end
			
		item.avg = mfloor (item.total / item.count + 0.5)
			
		-- raw
		item.normal.raw = item.normal.total + item.normal.mit + item.normal.abs
		item.crit.raw = item.crit.total + item.crit.mit + item.crit.abs
		item.raw = item.normal.raw + item.crit.raw
			
		-- mitigation
		if (item.normal.raw > 0)
		then
			item.normal.mitPercent = mfloor (item.normal.mit / item.normal.raw * 100.0 + 0.5)
		else
			item.normal.mitPercent = nil
		end
			
		if (item.crit.raw > 0)
		then
			item.crit.mitPercent = mfloor (item.crit.mit / item.crit.raw * 100.0 + 0.5)
		else
			item.crit.mitPercent = nil
		end
			
		-- absorb
		if (item.normal.raw > 0)
		then
			item.normal.absPercent = mfloor (item.normal.abs / item.normal.raw * 100.0 + 0.5)
		else
			item.normal.absPercent = nil
		end
			
		if (item.crit.raw > 0)
		then
			item.crit.absPercent = mfloor (item.crit.abs / item.crit.raw * 100.0 + 0.5)
		else
			item.crit.absPercent = nil
		end
			
			
		item.mit = item.normal.mit + item.crit.mit
		item.abs = item.normal.abs + item.crit.abs
			
		if (item.raw > 0)
		then
			item.mitPercent = mfloor (item.mit / item.raw * 100.0 + 0.5)
			item.absPercent = mfloor (item.abs / item.raw * 100.0 + 0.5)
		end

		-- overheal
		item.overheal = item.normal.overheal + item.crit.overheal
		item.totalWithOverheal = item.total + item.normal.overheal
		
		if (item.totalWithOverheal == 0)
		then
			item.overhealPercent = 0
		else
			item.overhealPercent = mfloor (item.overheal / item.totalWithOverheal * 100.0 + 0.5)
		end

					
		item.blockPercent = mfloor (item.block / item.count * 100.0 + 0.5)
		item.parryPercent = mfloor (item.parry / item.count * 100.0 + 0.5)
		item.disruptPercent = mfloor (item.disrupt / item.count * 100.0 + 0.5)
		item.dodgePercent = mfloor (item.dodge / item.count * 100.0 + 0.5)
		
		total_sum = total_sum + item.total
		total_with_overheal_sum = total_with_overheal_sum + item.totalWithOverheal
		
		tinsert (data, item)
	end
	
	for _, item in ipairs (data)
	do
		if (total_sum == 0)
		then
			item.totalPercent = 0
		else
			item.totalPercent = mfloor (item.total / total_sum * 100.0 + 0.5)
		end
		
		if (total_with_overheal_sum == 0)
		then
			item.totalWithOverhealPercent = 0
		else
			item.totalWithOverhealPercent = mfloor (item.totalWithOverheal / total_with_overheal_sum * 100.0 + 0.5)
		end
	end
	
	-- sorting
	local sort_column = dlg.column_settings.columns[dlg.column_settings.sortColumn]
	local col = dlg.columns[sort_column]
	
	tsort (data, function (a, b)
		return (col.getValue (a) or 0) < (col.getValue (b) or 0)
	end)
	
	local indexes = {}
	local max = #data
	for index, _ in ipairs (data)
	do
		if (dlg.column_settings.sortDirection)
		then
			tinsert (indexes, index)
		else
			tinsert (indexes, max - index + 1)
		end
	end
	
	Enemy.combatLogStatsWindowListData = data
	Enemy.combatLogStatsWindowListIndexes = indexes
	Enemy.CombatLogUI_StatsWindow_RedrawList ()
end


function Enemy.CombatLogUI_StatsWindow_RedrawList ()
	ListBoxSetDisplayOrder ("EnemyCombatLogStatsWindowList", Enemy.combatLogStatsWindowListIndexes)
end


function Enemy.CombatLogUI_StatsWindow_OnListPopulate ()
	
	local data = Enemy.combatLogStatsWindowListData
	
	for k, index in ipairs (EnemyCombatLogStatsWindowList.PopulatorIndices)
	do
		local wnr = "EnemyCombatLogStatsWindowListRow"..k
		local item = data[index]
		
		for column_index, v in ipairs (dlg.column_settings.columns)
		do
			LabelSetText (wnr.."Value"..column_index, dlg.columns[v].getValueString (item))
		end

		local wnr_background = wnr.."Background"
				
		if (index == dlg.hoverRowIndex)
		then
			WindowSetTintColor (wnr_background, 255, 204, 102)
			WindowSetAlpha (wnr_background, 0.4)
			WindowSetShowing (wnr_background, true)
		else
			WindowSetShowing (wnr_background, false)
		end
	end
end


function Enemy.CombatLogUI_StatsWindow_SortColumnClick ()

	local sort_column = SystemData.ActiveWindow.name:match ("^EnemyCombatLogStatsWindowListHeaderSortColumn(%d+)$")
	if (not sort_column) then return end
	sort_column = tonumber (sort_column)
	
	if (dlg.column_settings.sortColumn ~= sort_column)
	then
		dlg.column_settings.sortColumn = sort_column
		
		local column_info = dlg.columns[dlg.column_settings.columns[dlg.column_settings.sortColumn]]
		dlg.column_settings.sortDirection = column_info.defaultSortDirection
	else
		dlg.column_settings.sortDirection = not dlg.column_settings.sortDirection
	end
	
	Enemy.CombatLogUI_StatsWindow_UpdateColumns ()
	Enemy.CombatLogUI_StatsWindow_UpdateList ()
end


function Enemy.CombatLogUI_StatsWindow_SortColumnRClick ()

	local sort_column = SystemData.ActiveWindow.name:match ("^EnemyCombatLogStatsWindowListHeaderSortColumn(%d+)$")
	if (not sort_column) then return end
	sort_column = tonumber (sort_column)
	
	local t = Enemy.CombatLogUI_StatsWindow_GetCurrentType ()
	if (not t) then return end
	
	EA_Window_ContextMenu.CreateContextMenu (SystemData.ActiveWindow.name, 1)
	WindowSetLayer ("EA_Window_ContextMenu1", Window.Layers.OVERLAY)
	
	for _, column_info in ipairs (dlg.columnsSorted)
	do
		if (not column_info.types[t.value]) then continue end
	
		EA_Window_ContextMenu.AddMenuItem (column_info.name, function ()
		
			dlg.column_settings.columns[sort_column] = column_info.key
			
			Enemy.CombatLogUI_StatsWindow_UpdateColumns ()
			Enemy.CombatLogUI_StatsWindow_UpdateList ()
			
		end, false, true)
	end
	
	EA_Window_ContextMenu.Finalize ()
end


function Enemy.CombatLogUI_StatsWindow_ListRowMouseOver ()

	local row_index = SystemData.ActiveWindow.name:match ("^EnemyCombatLogStatsWindowListRow(%d+)Value%d+$")
	if (not row_index)
	then
		dlg.hoverRowIndex = nil
		return
	end
	
	row_index = ListBoxGetDataIndex ("EnemyCombatLogStatsWindowList", tonumber (row_index))
	
	local t = Enemy.CombatLogUI_StatsWindow_GetCurrentType ()
	if (not t) then return end
	
	dlg.hoverRowIndex = row_index
	Enemy.CombatLogUI_StatsWindow_RedrawList ()
	
	local item = Enemy.combatLogStatsWindowListData[dlg.hoverRowIndex]
	
	if (not item.tooltip)
	then
		item.tooltip = {}

		for _, column_info in ipairs (dlg.columnsSorted)
		do
			if (not column_info.types[t.value]) then continue end

			local info =
			{
				text = column_info.tooltipName or column_info.name,
				text2 = column_info.getValueString (item),
				color = column_info.color
			}

			if (column_info.getObjectString)
			then
				info.text3 = column_info.getObjectString (item)
			end

			tinsert (item.tooltip, info)
		end
	end

	
	if (not dlg.tooltipWindow)
	then
		dlg.tooltipWindow = "EnemyCombatLogStatsWindowTooltip"
		CreateWindow (dlg.tooltipWindow, false)

		local k = 1
		local prev_wn_row = nil

		for _, column_info in pairs (dlg.columns)
		do
			local wn_row = dlg.tooltipWindow.."Row"..tostring (k)
			CreateWindowFromTemplate (wn_row, "EnemyCombatLogStatsWindowTooltip_RowTemplate", dlg.tooltipWindow)

			if (prev_wn_row)
			then
				WindowAddAnchor (wn_row, "bottomleft", prev_wn_row, "topleft", 0, 0)
			else
				WindowAddAnchor (wn_row, "bottomleft", dlg.tooltipWindow.."Title", "topleft", 0, 0)
			end

			prev_wn_row = wn_row
			k = k + 1
		end
	end


	LabelSetText ("EnemyCombatLogStatsWindowTooltipTitle", item.name)

	for k, tp in ipairs (item.tooltip)
	do
		local wn_row = dlg.tooltipWindow.."Row"..tostring (k)

		LabelSetText (wn_row.."Label1", tp.text)
		LabelSetText (wn_row.."Label2", Enemy.isNil (tp.text2, L""))
		LabelSetText (wn_row.."Label3", Enemy.isNil (tp.text3, L""))

		local r, b, g = 255, 255, 255

		if (tp.color)
		then
			r, g, b = unpack (tp.color)
		end

		LabelSetTextColor (wn_row.."Label1", r, g, b)
		LabelSetTextColor (wn_row.."Label2", r, g, b)
		LabelSetTextColor (wn_row.."Label3", r, g, b)
	end

	Tooltips.CreateCustomTooltip (SystemData.MouseOverWindow.name, dlg.tooltipWindow)
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
end


function Enemy.CombatLogUI_StatsWindow_OnEpsMouseOver ()
	
	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, L"Click to open recorded combat log for this number")
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end
		
		
function Enemy.CombatLogUI_StatsWindow_OnEpsCurClick ()
	Enemy.CombatLogUI_SnapshotWindow_Open (Enemy.CombatLogUI_StatsWindow_GetCurrentSession ().stats, Enemy.CombatLogUI_StatsWindow_GetCurrentType ().value, Enemy.CombatLogSnapshotType.Current, false)
end
		
		
function Enemy.CombatLogUI_StatsWindow_OnEpsMaxClick ()
	Enemy.CombatLogUI_SnapshotWindow_Open (Enemy.CombatLogUI_StatsWindow_GetCurrentSession ().stats, Enemy.CombatLogUI_StatsWindow_GetCurrentType ().value, Enemy.CombatLogSnapshotType.Max, false)
end
		
		
function Enemy.CombatLogUI_StatsWindow_OnEpsAoeCurClick ()
	Enemy.CombatLogUI_SnapshotWindow_Open (Enemy.CombatLogUI_StatsWindow_GetCurrentSession ().stats, Enemy.CombatLogUI_StatsWindow_GetCurrentType ().value, Enemy.CombatLogSnapshotType.Current, true)
end
		
		
function Enemy.CombatLogUI_StatsWindow_OnEpsAoeMaxClick ()
	Enemy.CombatLogUI_SnapshotWindow_Open (Enemy.CombatLogUI_StatsWindow_GetCurrentSession ().stats, Enemy.CombatLogUI_StatsWindow_GetCurrentType ().value, Enemy.CombatLogSnapshotType.Max, true)
end
		







