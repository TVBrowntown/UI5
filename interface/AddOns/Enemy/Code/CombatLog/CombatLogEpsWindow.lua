local Enemy = Enemy
local g = nil

local tinsert = table.insert
local tsort = table.sort
local pairs = pairs
local ipairs = ipairs
local mfloor = math.floor
local unpack = unpack


function Enemy.CombatLogUI_EpsWindow_Initialize ()
	
	g = Enemy.combatLog
	
	CreateWindow ("EnemyCombatLogEpsWindow", true)
	LayoutEditor.RegisterWindow ("EnemyCombatLogEpsWindow", L"DPS", L"Current DPS", false, false, true, nil)
		
	LabelSetText ("EnemyCombatLogEpsWindowOutDpsLabel", L"Out DPS")
	LabelSetText ("EnemyCombatLogEpsWindowOutDpsAoeLabel", L"with AoE")
	LabelSetText ("EnemyCombatLogEpsWindowInDpsLabel", L"In DPS")
	LabelSetText ("EnemyCombatLogEpsWindowOutHpsLabel", L"Out HPS")
	LabelSetText ("EnemyCombatLogEpsWindowOutHpsAoeLabel", L"with AoE")
	LabelSetText ("EnemyCombatLogEpsWindowInHpsLabel", L"In HPS")
		
	
	Enemy.AddEventHandler ("CombatLogUI_EpsWindow", "IconCreateContextMenu", function (data)
		
		if (Enemy.CombatLogUI_EpsWindow_IsOpen ())
		then
			table.insert (data,
			{
				text = L"Hide combat log DPS window",
				callback = Enemy.CombatLogUI_EpsWindow_Hide
			})
		else
			table.insert (data,
			{
				text = L"Show combat log DPS window",
				callback = Enemy.CombatLogUI_EpsWindow_Open,
				disabled = (not Enemy.Settings.combatLogEnabled or not Enemy.Settings.combatLogStatisticsEnabled)
			})
		end
	end)
					
	Enemy.AddEventHandler ("CombatLogUI_EpsWindow", "CombatLogSessionsUpdated", Enemy.CombatLogUI_EpsWindow_Update)
	Enemy.AddEventHandler ("CombatLogUI_EpsWindow", "CombatLogNewCombatEvent", Enemy.CombatLogUI_EpsWindow_Update)
	Enemy.AddEventHandler ("CombatLogUI_EpsWindow", "CombatLogSettingsChanged", Enemy.CombatLogUI_EpsWindow_UpdateLayout)
end
		
		
function Enemy.CombatLogUI_EpsWindow_UpdateLayout ()
	
	if (not g.settings.combatLogEPSShow) then return end
		
	if (not g.settings.combatLogEnabled and Enemy.CombatLogUI_EpsWindow_IsOpen)
	then
		Enemy.CombatLogUI_EpsWindow_Hide ()
	end
	
	local wnp = "EnemyCombatLogEpsWindow"
	local anchor, dx, dy = "topleft", 5, 5
		
	if (g.settings.combatLogEPSShow[Enemy.CombatLogTypes.OutgoingDamage])
	then
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDpsLabel", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDps", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDpsAoeLabel", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDpsAoe", true)
		
		WindowClearAnchors ("EnemyCombatLogEpsWindowOutDpsLabel")
		WindowAddAnchor ("EnemyCombatLogEpsWindowOutDpsLabel", anchor, wnp, "topleft", dx, dy)

		wnp = "EnemyCombatLogEpsWindowOutDpsAoeLabel"
		anchor, dx, dy = "bottomleft", 0, 0
	else
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDpsLabel", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDps", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDpsAoeLabel", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutDpsAoe", false)
	end
	
	if (g.settings.combatLogEPSShow[Enemy.CombatLogTypes.IncommingDamage])
	then
		WindowSetShowing ("EnemyCombatLogEpsWindowInDpsLabel", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowInDps", true)
		
		WindowClearAnchors ("EnemyCombatLogEpsWindowInDpsLabel")
		WindowAddAnchor ("EnemyCombatLogEpsWindowInDpsLabel", anchor, wnp, "topleft", dx, dy)

		wnp = "EnemyCombatLogEpsWindowInDpsLabel"
		anchor, dx, dy = "bottomleft", 0, 0
	else
		WindowSetShowing ("EnemyCombatLogEpsWindowInDpsLabel", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowInDps", false)
	end
			
	if (g.settings.combatLogEPSShow[Enemy.CombatLogTypes.OutgoingHeal])
	then
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHpsLabel", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHps", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHpsAoeLabel", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHpsAoe", true)
		
		WindowClearAnchors ("EnemyCombatLogEpsWindowOutHpsLabel")
		WindowAddAnchor ("EnemyCombatLogEpsWindowOutHpsLabel", anchor, wnp, "topleft", dx, dy)

		wnp = "EnemyCombatLogEpsWindowOutHpsAoeLabel"
		anchor, dx, dy = "bottomleft", 0, 0
	else
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHpsLabel", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHps", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHpsAoeLabel", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowOutHpsAoe", false)
	end
	
	if (g.settings.combatLogEPSShow[Enemy.CombatLogTypes.IncommingHeal])
	then
		WindowSetShowing ("EnemyCombatLogEpsWindowInHpsLabel", true)
		WindowSetShowing ("EnemyCombatLogEpsWindowInHps", true)
		
		WindowClearAnchors ("EnemyCombatLogEpsWindowInHpsLabel")
		WindowAddAnchor ("EnemyCombatLogEpsWindowInHpsLabel", anchor, wnp, "topleft", dx, dy)

		wnp = "EnemyCombatLogEpsWindowInHpsLabel"
		anchor, dx, dy = "bottomleft", 0, 0
	else
		WindowSetShowing ("EnemyCombatLogEpsWindowInHpsLabel", false)
		WindowSetShowing ("EnemyCombatLogEpsWindowInHps", false)
	end
	
	Enemy.CombatLogUI_EpsWindow_Update ()
end
	

function Enemy.CombatLogEpsWindowToggle ()
	if (Enemy.CombatLogUI_EpsWindow_IsOpen ())
	then
		Enemy.CombatLogUI_EpsWindow_Hide ()
	else
		Enemy.CombatLogUI_EpsWindow_Open ()
	end
end


function Enemy.CombatLogUI_EpsWindow_IsOpen ()
	return WindowGetShowing ("EnemyCombatLogEpsWindow")
end


function Enemy.CombatLogUI_EpsWindow_Hide ()
	WindowSetShowing ("EnemyCombatLogEpsWindow", false)
end


function Enemy.CombatLogUI_EpsWindow_Open ()
	if (not g.settings.combatLogEnabled or not g.settings.combatLogStatisticsEnabled) then return end
	WindowSetShowing ("EnemyCombatLogEpsWindow", true)
	Enemy.CombatLogUI_EpsWindow_Update ()
end
	
	
local function FormatEpsValue (v)
	if (v == nil or v <= 0) then return L"" end
	return Enemy.toWString (v)
end


function Enemy.CombatLogUI_EpsWindow_Update ()
	
	if (not Enemy.CombatLogUI_EpsWindow_IsOpen () or not g.stats.eps) then return end
		
	if (g.settings.combatLogEPSEnabled[Enemy.CombatLogTypes.OutgoingDamage])
	then
		local eps = g.stats.eps[Enemy.CombatLogTypes.OutgoingDamage] or {}
		LabelSetText ("EnemyCombatLogEpsWindowOutDps", FormatEpsValue (eps.value))
		LabelSetText ("EnemyCombatLogEpsWindowOutDpsAoe", FormatEpsValue (eps.valueAoe))
	end
		
	if (g.settings.combatLogEPSEnabled[Enemy.CombatLogTypes.IncommingDamage])
	then
		local eps = g.stats.eps[Enemy.CombatLogTypes.IncommingDamage] or {}
		LabelSetText ("EnemyCombatLogEpsWindowInDps", FormatEpsValue (eps.value))
	end
	
	if (g.settings.combatLogEPSEnabled[Enemy.CombatLogTypes.OutgoingHeal])
	then
		local eps = g.stats.eps[Enemy.CombatLogTypes.OutgoingHeal] or {}
		LabelSetText ("EnemyCombatLogEpsWindowOutHps", FormatEpsValue (eps.value))
		LabelSetText ("EnemyCombatLogEpsWindowOutHpsAoe", FormatEpsValue (eps.valueAoe))
	end
		
	if (g.settings.combatLogEPSEnabled[Enemy.CombatLogTypes.IncommingHeal])
	then
		local eps = g.stats.eps[Enemy.CombatLogTypes.IncommingHeal] or {}
		LabelSetText ("EnemyCombatLogEpsWindowInHps", FormatEpsValue (eps.value))
	end
end


function Enemy.CombatLogUI_EpsWindow_OnMouseOver ()

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	
	Tooltips.SetTooltipText (1, 1, L"Combat log DPS")
	Tooltips.SetTooltipText (2, 1, L"Left click on number to open current snapshot of combat log for that number (if available)")
	Tooltips.SetTooltipText (3, 1, L"Shift+Left click on number to open max value snapshot of combat log for that number (if available)")
	Tooltips.SetTooltipText (4, 1, L"Alt+Left click on number to open statistics window for that number")
	Tooltips.SetTooltipText (5, 1, L"Right click to open menu")
	
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.CombatLogUI_EpsWindow_OnRButtonUp (flags)
	
	EA_Window_ContextMenu.CreateContextMenu ("EnemyCombatLogEpsWindow")

	EA_Window_ContextMenu.AddMenuItem (L"Reset current session", Enemy.CombatLog_ResetStatsCurrentSession, false, true)    
    EA_Window_ContextMenu.AddMenuItem (L"Hide", Enemy.CombatLogUI_EpsWindow_Hide, false, true)
	EA_Window_ContextMenu.AddMenuDivider ()
	EA_Window_ContextMenu.AddMenuItem (L"Open configuration", function () Enemy.UI_ConfigDialog_Open ("CombatLog") end, false, true)
        
	EA_Window_ContextMenu.Finalize ()
end	


function Enemy.CombatLogUI_EpsWindow_OnOutDpsLButtonUp (flags)
	if (Enemy.IsShiftPressed(flags))
	then
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingDamage, Enemy.CombatLogSnapshotType.Max, false)
	elseif (Enemy.IsAltPressed(flags))
	then
		Enemy.CombatLogUI_StatsWindow_Open (1)
	else
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingDamage, Enemy.CombatLogSnapshotType.Current, false)
	end
end
	
	
function Enemy.CombatLogUI_EpsWindow_OnOutDpsAoeLButtonUp (flags)
	if (Enemy.IsShiftPressed(flags))
	then
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingDamage, Enemy.CombatLogSnapshotType.Max, true)
	elseif (Enemy.IsAltPressed(flags))
	then
		Enemy.CombatLogUI_StatsWindow_Open (1)
	else
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingDamage, Enemy.CombatLogSnapshotType.Current, true)
	end
end


function Enemy.CombatLogUI_EpsWindow_OnInDpsLButtonUp (flags)
	if (Enemy.IsShiftPressed(flags))
	then
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.IncommingDamage, Enemy.CombatLogSnapshotType.Max, false)
	elseif (Enemy.IsAltPressed(flags))
	then
		Enemy.CombatLogUI_StatsWindow_Open (2)
	else
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.IncommingDamage, Enemy.CombatLogSnapshotType.Current, false)
	end
end


function Enemy.CombatLogUI_EpsWindow_OnOutHpsLButtonUp (flags)
	if (Enemy.IsShiftPressed(flags))
	then
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingHeal, Enemy.CombatLogSnapshotType.Max, false)
	elseif (Enemy.IsAltPressed(flags))
	then
		Enemy.CombatLogUI_StatsWindow_Open (3)
	else
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingHeal, Enemy.CombatLogSnapshotType.Current, false)
	end
end
	
	
function Enemy.CombatLogUI_EpsWindow_OnOutHpsAoeLButtonUp (flags)
	if (Enemy.IsShiftPressed(flags))
	then
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingHeal, Enemy.CombatLogSnapshotType.Max, true)
	elseif (Enemy.IsAltPressed(flags))
	then
		Enemy.CombatLogUI_StatsWindow_Open (3)
	else
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.OutgoingHeal, Enemy.CombatLogSnapshotType.Current, true)
	end
end


function Enemy.CombatLogUI_EpsWindow_OnInHpsLButtonUp (flags)
	if (Enemy.IsShiftPressed(flags))
	then
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.IncommingHeal, Enemy.CombatLogSnapshotType.Max, false)
	elseif (Enemy.IsAltPressed(flags))
	then
		Enemy.CombatLogUI_StatsWindow_Open (4)
	else
		Enemy.CombatLogUI_SnapshotWindow_Open (nil, Enemy.CombatLogTypes.IncommingHeal, Enemy.CombatLogSnapshotType.Current, false)
	end
end


















