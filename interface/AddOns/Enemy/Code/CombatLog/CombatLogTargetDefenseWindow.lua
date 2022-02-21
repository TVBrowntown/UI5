local Enemy = Enemy
local g = nil

local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local pairs = pairs
local ipairs = ipairs
local mfloor = math.floor


local tooltips =
{
	["EnemyCombatLogTargetDefeseWindowMitigation"] = L"Target mitigation",
	["EnemyCombatLogTargetDefeseWindowAbsorb"] = L"Target absorb",
	["EnemyCombatLogTargetDefeseWindowParry"] = L"Target parry",
	["EnemyCombatLogTargetDefeseWindowBlock"] = L"Target block",
	["EnemyCombatLogTargetDefeseWindowDisrupt"] = L"Target disrupt",
	["EnemyCombatLogTargetDefeseWindowDodge"] = L"Target dodge"
}


function Enemy.CombatLogUI_TargetDefenseWindow_Initialize ()
	
	g = Enemy.combatLog
	
	CreateWindow ("EnemyCombatLogTargetDefeseWindow", true)
	LayoutEditor.RegisterWindow ("EnemyCombatLogTargetDefeseWindow", L"Target defense", L"Target defense", false, false, true, nil)

	CreateWindow ("EnemyCombatLogTargetDefeseTotalWindow", true)
	LayoutEditor.RegisterWindow ("EnemyCombatLogTargetDefeseTotalWindow", L"Target total defense", L"Target total defense", false, false, true, nil)

		
	--[[
	Enemy.AddEventHandler ("CombatLogUI_TargetDefenseWindow", "IconCreateContextMenu", function (data)
		
		if (Enemy.CombatLogUI_TargetDefenseWindow_IsOpen ())
		then
			table.insert (data,
			{
				text = L"Hide target defense window",
				callback = Enemy.CombatLogUI_TargetDefenseWindow_Hide
			})
		else
			table.insert (data,
			{
				text = L"Show target defense window",
				callback = Enemy.CombatLogUI_TargetDefenseWindow_Open,
				disabled = (not Enemy.Settings.combatLogEnabled or not Enemy.Settings.combatLogTargetDefenseEnabled)
			})
		end
	end)
	]]--
	
	Enemy.AddEventHandler ("CombatLogUI_TargetDefenseWindow", "CombatLogSettingsChanged", Enemy.CombatLogUI_TargetDefenseWindow_OnSettingsChanged)
	Enemy.CombatLogUI_TargetDefenseWindow_UpdateLayout ()
	Enemy.CombatLogUI_TargetDefenseWindow_Reset ()
	Enemy.CombatLogUI_TargetDefenseWindow_Hide ()
	Enemy.CombatLogUI_TargetDefenseTotalWindow_Hide ()
end
		

function Enemy.CombatLogUI_TargetDefenseWindow_OnSettingsChanged (settings)
	
	Enemy.CombatLogUI_TargetDefenseWindow_Hide ()
	Enemy.CombatLogUI_TargetDefenseTotalWindow_Hide ()
	
	if (settings.combatLogTargetDefenseEnabled)
	then
		Enemy.AddEventHandler ("CombatLogUI_TargetDefenseWindow", "TargetChanged", Enemy.CombatLogUI_TargetDefenseWindow_TargetChanged)
		Enemy.AddEventHandler ("CombatLogUI_TargetDefenseWindow", "CombatLogNewCombatEvent", Enemy.CombatLogUI_TargetDefenseWindow_OnCombatLogEvent)
		
		Enemy.CombatLogUI_TargetDefenseWindow_UpdateLayout (settings)
		Enemy.CombatLogUI_TargetDefenseWindow_Update (settings)
		Enemy.CombatLogUI_TargetDefenseTotalWindow_UpdateLayout (settings)
		Enemy.CombatLogUI_TargetDefenseTotalWindow_Update (settings)
		Enemy.CombatLogUI_TargetDefenseWindow_TargetChanged (nil, nil, true)
	else
		Enemy.RemoveEventHandler ("CombatLogUI_TargetDefenseWindow", "TargetChanged")
		Enemy.RemoveEventHandler ("CombatLogUI_TargetDefenseWindow", "CombatLogNewCombatEvent")
	end
end
		
		
function Enemy.CombatLogUI_TargetDefenseWindow_TargetChanged (targetClassification, latestTarget, targetChanged)
	if (not targetChanged) then return end
	
	local target = Enemy.latestTargets[TargetInfo.HOSTILE_TARGET]
	if (target == nil) then return end

	Enemy.CombatLogUI_TargetDefenseWindow_Reset ()
	if (g.settings.combatLogTargetDefenseHideTimeout == 0)
	then
		Enemy.CombatLogUI_TargetDefenseWindow_Open ()
		Enemy.CombatLogUI_TargetDefenseTotalWindow_Open ()
	end
end

	
function Enemy.CombatLogUI_TargetDefenseWindow_Reset ()
	
	g.targetDefense =
	{
		data = {},
			
		total = 0,
		mit = 0,
		abs = 0,
			
		block = 0,
		parry = 0,
		dodge = 0,
		disrupt = 0
	}
	
	Enemy.CombatLogUI_TargetDefenseWindow_Update ()
	Enemy.CombatLogUI_TargetDefenseTotalWindow_Update ()
end
		
		
function Enemy.CombatLogUI_TargetDefenseWindow_OnCombatLogEvent (combatEvent)
	
	if (combatEvent.type ~= Enemy.CombatLogTypes.OutgoingDamage or not combatEvent.currentTarget) then return end
		
	local td = g.targetDefense
		
	local e =
	{
		time = combatEvent.time
	}
	
	if (combatEvent.damageIgnoreType == nil)
	then
		e.value = combatEvent.value
		
		local n = combatEvent.value + combatEvent.mit
		if (n > 0) then e.mit = combatEvent.mit * 100.0 / n else e.mit = 0 end
		if (e.mit < 0.001) then e.mit = 0 end
			
		n = combatEvent.value + combatEvent.abs
		if (n > 0) then e.abs = combatEvent.abs * 100.0 / n else e.abs = 0 end
		if (e.abs < 0.001) then e.abs = 0 end
		
		td.total = td.total + e.value
		td.mit = td.mit + e.mit
		td.abs = td.abs + e.abs
	else
		e.damageIgnoreType = combatEvent.damageIgnoreType
		td[e.damageIgnoreType] = td[e.damageIgnoreType] + 1
	end
			
	
	tinsert (td.data, e)
		
			
	local max_time = e.time - g.settings.combatLogTargetDefenseTimeframe
		
	while (#td.data > 0)
	do
		e = td.data[1]
		
		if (e.time >= max_time) then break end

		-- remove statistical data
		if (e.damageIgnoreType == nil)
		then
			td.total = td.total - e.value
			td.mit = td.mit - e.mit
			td.abs = td.abs - e.abs
		else
			td[e.damageIgnoreType] = td[e.damageIgnoreType] - 1
		end
	
		tremove (td.data, 1)
	end

	if (not Enemy.CombatLogUI_TargetDefenseWindow_IsOpen ()) then Enemy.CombatLogUI_TargetDefenseWindow_Open () end
	if (not Enemy.CombatLogUI_TargetDefenseTotalWindow_IsOpen ()) then Enemy.CombatLogUI_TargetDefenseTotalWindow_Open () end
		
	Enemy.CombatLogUI_TargetDefenseWindow_Update ()
	Enemy.CombatLogUI_TargetDefenseTotalWindow_Update ()
		
	if (g.settings.combatLogTargetDefenseHideTimeout > 0)
	then
		g.targetDefenseHideTimer = EnemyTimer.New ("TargetDefenseHide", g.settings.combatLogTargetDefenseHideTimeout, function ()
			Enemy.CombatLogUI_TargetDefenseWindow_Hide ()
			Enemy.CombatLogUI_TargetDefenseTotalWindow_Hide ()
			return true
		end)
	end
end


function Enemy.CombatLogTargetDefeseWindowToggle ()
	if (Enemy.CombatLogUI_TargetDefenseWindow_IsOpen ())
	then
		Enemy.CombatLogUI_TargetDefenseWindow_Hide ()
	else
		Enemy.CombatLogUI_TargetDefenseWindow_Open ()
	end
end




function Enemy.CombatLogUI_TargetDefenseWindow_IsOpen ()
	return WindowGetShowing ("EnemyCombatLogTargetDefeseWindow")
end


function Enemy.CombatLogUI_TargetDefenseWindow_Hide ()
	WindowSetShowing ("EnemyCombatLogTargetDefeseWindow", false)
end


function Enemy.CombatLogUI_TargetDefenseWindow_Open ()
	if (not g.settings.combatLogEnabled or (g.showCount ~= nil and g.showCount == 0)) then return end
	WindowSetShowing ("EnemyCombatLogTargetDefeseWindow", true)
	Enemy.CombatLogUI_TargetDefenseWindow_Update ()
end


function Enemy.CombatLogUI_TargetDefenseWindow_UpdateLayout (settings)

	settings = settings or g.settings
		
	if (not settings or not settings.combatLogTargetDefenseShow) then return end
	
	local wn = "EnemyCombatLogTargetDefeseWindow"
	local n = 0
	local data = {}
	for t, v in pairs (Enemy.CombatLogTargetDefenseTypes)
	do
		if (settings.combatLogTargetDefenseShow[v])
		then
			n = n + 1
			tinsert (data, { type = t, value = v })
			WindowSetShowing (wn..t, true)
		else
			WindowSetShowing (wn..t, false)
		end
	end

	g.showCount = n

	if (g.showCount > 0)
	then
		local m, width, height = Enemy.CalculatePositioningMatrix (5, 5, settings.combatLogTargetDefenseSize[1], settings.combatLogTargetDefenseSize[2], 4, 0, n, 2, 0, 1)
		WindowSetDimensions (wn, width + 10, height + 10)
		WindowSetScale (wn, settings.combatLogTargetDefenseScale)
		
		tsort (data, function (a, b)
			return a.value < b.value
		end)

		for k, d in ipairs (data)
		do
			local w = wn..d.type
			WindowClearAnchors (w)
			WindowAddAnchor (w, "topleft", wn, "topleft", m[k].x, m[k].y)
		end
	else
		Enemy.CombatLogUI_TargetDefenseWindow_Hide ()
	end


	local wn_background = wn.."Background"
	if (settings.combatLogTargetDefenseBackgroundAlpha > 0)
	then
		WindowSetTintColor (wn_background, unpack (settings.combatLogTargetDefenseBackground))
		WindowSetAlpha (wn_background, settings.combatLogTargetDefenseBackgroundAlpha)
		WindowSetShowing (wn_background, true)
	else
		WindowSetShowing (wn_background, false)
	end
end


local function FormatValue (v, n)
	if (v == nil or n == 0) then return L"0%" end
	
	v = mfloor (v / n + 0.5)
	if (v <= 0) then return L"0%" end
		
	return Enemy.toWString (v)..L"%"
end
			
			
function Enemy.CombatLogUI_TargetDefenseWindow_Update (settings)
	
	settings = settings or g.settings
	if (not settings.combatLogTargetDefenseEnabled or g.targetDefense == nil) then return end
		
	local td = g.targetDefense
	local n = #td.data
		
	LabelSetText ("EnemyCombatLogTargetDefeseWindowMitigation", FormatValue (td.mit, n))
	LabelSetText ("EnemyCombatLogTargetDefeseWindowAbsorb", FormatValue (td.abs, n))
	LabelSetText ("EnemyCombatLogTargetDefeseWindowParry", FormatValue (100 * td.parry, n))
	LabelSetText ("EnemyCombatLogTargetDefeseWindowBlock", FormatValue (100 * td.block, n))
	LabelSetText ("EnemyCombatLogTargetDefeseWindowDisrupt", FormatValue (100 * td.disrupt, n))
	LabelSetText ("EnemyCombatLogTargetDefeseWindowDodge", FormatValue (100 * td.dodge, n))
end


function Enemy.CombatLogUI_TargetDefenseWindow_OnMouseOver ()

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
		
	Tooltips.SetTooltipText (1, 1, tooltips[SystemData.MouseOverWindow.name] or L"Target defense")
	Tooltips.SetTooltipText (2, 1, L"Right click to open menu")
	
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.CombatLogUI_TargetDefenseWindow_OnRButtonUp (flags)
	
	EA_Window_ContextMenu.CreateContextMenu ("EnemyCombatLogTargetDefeseWindow")

	EA_Window_ContextMenu.AddMenuItem (L"Reset", Enemy.CombatLogUI_TargetDefenseWindow_Reset, false, true)    
	EA_Window_ContextMenu.AddMenuDivider ()
	EA_Window_ContextMenu.AddMenuItem (L"Open configuration", function () Enemy.UI_ConfigDialog_Open ("CombatLog", 1120) end, false, true)
        
	EA_Window_ContextMenu.Finalize ()
end






function Enemy.CombatLogTargetDefeseWindowToggle ()
	if (Enemy.CombatLogUI_TargetDefenseTotalWindow_IsOpen ())
	then
		Enemy.CombatLogUI_TargetDefenseTotalWindow_Hide ()
	else
		Enemy.CombatLogUI_TargetDefenseTotalWindow_Open ()
	end
end


function Enemy.CombatLogUI_TargetDefenseTotalWindow_IsOpen ()
	return WindowGetShowing ("EnemyCombatLogTargetDefeseTotalWindow")
end


function Enemy.CombatLogUI_TargetDefenseTotalWindow_Hide ()
	WindowSetShowing ("EnemyCombatLogTargetDefeseTotalWindow", false)
end


function Enemy.CombatLogUI_TargetDefenseTotalWindow_Open ()
	if (not g.settings.combatLogEnabled) then return end
	WindowSetShowing ("EnemyCombatLogTargetDefeseTotalWindow", true)
	Enemy.CombatLogUI_TargetDefenseTotalWindow_Update ()
end


function Enemy.CombatLogUI_TargetDefenseTotalWindow_UpdateLayout (settings)

	settings = settings or g.settings
		
	if (not settings or not settings.combatLogTargetDefenseShow) then return end
	
	local wn = "EnemyCombatLogTargetDefeseTotalWindow"
	local wn_background = wn.."Background"
	if (settings.combatLogTargetDefenseTotalBackgroundAlpha > 0)
	then
		WindowSetTintColor (wn_background, unpack (settings.combatLogTargetDefenseTotalBackground))
		WindowSetAlpha (wn_background, settings.combatLogTargetDefenseTotalBackgroundAlpha)
		WindowSetShowing (wn_background, true)
	else
		WindowSetShowing (wn_background, false)
	end
end


function Enemy.CombatLogUI_TargetDefenseTotalWindow_Update (settings)
	
	settings = settings or g.settings
	if (not settings.combatLogTargetDefenseEnabled or g.targetDefense == nil) then return end
		
	local td = g.targetDefense
	local n = #td.data
		
	local total_defense = 0
	local total_defense_count = 0
	if (n > 0)
	then
		if (settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Mitigation])
		then
			total_defense = total_defense + td.mit / n
			total_defense_count = total_defense_count + 1
		end

		if (settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Absorb])
		then
			total_defense = total_defense + td.abs / n
			total_defense_count = total_defense_count + 1
		end

		if (settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Block])
		then
			total_defense = total_defense + 100 * td.block / n
			total_defense_count = total_defense_count + 1
		end

		if (settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Parry])
		then
			total_defense = total_defense + 100 * td.parry / n
			total_defense_count = total_defense_count + 1
		end

		if (settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Disrupt])
		then
			total_defense = total_defense + 100 * td.disrupt / n
			total_defense_count = total_defense_count + 1
		end

		if (settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Dodge])
		then
			total_defense = total_defense + 100 * td.dodge / n
			total_defense_count = total_defense_count + 1
		end
	end

	LabelSetText ("EnemyCombatLogTargetDefeseTotalWindowText", FormatValue (total_defense, total_defense_count))
end



function Enemy.CombatLogUI_TargetDefenseTotalWindow_OnMouseOver ()

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
		
	Tooltips.SetTooltipText (1, 1, L"Target total defense")
	Tooltips.SetTooltipText (2, 1, L"Right click to open menu")
	
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.CombatLogUI_TargetDefenseTotalWindow_OnRButtonUp (flags)
	
	EA_Window_ContextMenu.CreateContextMenu ("EnemyCombatLogTargetDefeseWindow")

	EA_Window_ContextMenu.AddMenuItem (L"Reset", Enemy.CombatLogUI_TargetDefenseWindow_Reset, false, true)    
	EA_Window_ContextMenu.AddMenuDivider ()
	EA_Window_ContextMenu.AddMenuItem (L"Open configuration", function () Enemy.UI_ConfigDialog_Open ("CombatLog", 2000) end, false, true)
        
	EA_Window_ContextMenu.Finalize ()
end









