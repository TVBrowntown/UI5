local Enemy = Enemy
local dlg = nil


local tinsert = table.insert
local tsort = table.sort
local pairs = pairs
local ipairs = ipairs
local mfloor = math.floor
local unpack = unpack


Enemy.CombatLogSnapshotType =
{
	Current = 1,
	Max = 2
}


function Enemy.CombatLogUI_SnapshotWindow_Initialize ()
	g = Enemy.combatLog
end


function Enemy.CombatLogUI_SnapshotWindow_Hide ()
	if (not dlg) then return end
	WindowSetShowing (dlg.wn, false)
end


function Enemy.CombatLogUI_SnapshotWindow_Open (session, type, snapshotType, isAoe)

	session = session or g.stats
	if (not session) then return end

	if (not dlg)
	then
		dlg = {}
		dlg.wn = "EnemyCombatLogSnapshotWindow"
		
		CreateWindow (dlg.wn, false)
		LabelSetText (dlg.wn.."TitleBarText", L"Combat log snapshot")
		
		dlg.initialized = true
	end


	dlg.type = type
	dlg.snapshotType = snapshotType
	dlg.isAoe = isAoe


	local eps = session.eps[dlg.type]
	if (not eps) then return end


	local data, value
	local title = Enemy.CombatLogTypeNames[dlg.type]

	if (dlg.snapshotType == Enemy.CombatLogSnapshotType.Current)
	then
		title = title..L" current "

		if (dlg.isAoe)
		then
			data = eps.data
			value = eps.valueAoe
		else
			data = eps.data
			value = eps.value
		end

	elseif (dlg.snapshotType == Enemy.CombatLogSnapshotType.Max)
	then
		title = title..L" max "

		if (dlg.isAoe)
		then
			data = eps.valueAoeMaxData
			value = eps.valueAoeMax
		else
			data = eps.valueMaxData
			value = eps.valueMax
		end
	end

	if (not data or #data < 1) then return end

	dlg.value = value
	dlg.data = Enemy.clone (data)


	title = title..Enemy.CombatLogTypeEpsNames[type]
	if (dlg.isAoe) then title = title..L" with AoE" end
	title = title..L": "..Enemy.toWStringOrEmpty (dlg.value)
	
	LabelSetText (dlg.wn.."Title", title)
	
	Enemy.combatLogSnapshotWindowListIndexes = {}
	
	
	dlg.indexes = {}
	local idx = 1
	for k, v in ipairs (dlg.data)
	do
		if (
				v.type ~= Enemy.CombatLogTypes.IncommingDamage
				and
				v.type ~= Enemy.CombatLogTypes.IncommingHeal
				and
				not dlg.isAoe
				and
				(
					not v.currentTarget
					or
					v.object ~= eps.object
					or
					v.time < eps.objectTime
				)
		) then continue end
		
		dlg.indexes[idx] = k
		idx = idx + 1
	end
		
	Enemy.combatLogSnapshotWindowListIndexes = dlg.indexes
	Enemy.combatLogSnapshotWindowListData = dlg.data

	
	WindowSetShowing (dlg.wn, true)
	Enemy.CombatLogUI_SnapshotWindow_RedrawList ()
end


function Enemy.CombatLogUI_SnapshotWindow_RedrawList ()
	dlg.hoverRow = nil
	ListBoxSetDisplayOrder (dlg.wn.."List", Enemy.combatLogSnapshotWindowListIndexes)
end


function Enemy.CombatLogUI_SnapshotWindow_OnListPopulate ()
	
	for k, index in ipairs (EnemyCombatLogSnapshotWindowList.PopulatorIndices)
	do
		local wnr = "EnemyCombatLogSnapshotWindowListRow"..k
		local item = dlg.data[index]

		WindowSetId (wnr, index)
	
		LabelSetText (wnr.."Time", TimeUtils.FormatClock (item.time % 86400))
		LabelSetText (wnr.."Object", item.object)
		LabelSetText (wnr.."Ability", item.ability)
		if (item.crit) then LabelSetText (wnr.."Crit", L"crit") else LabelSetText (wnr.."Crit", L"") end
		LabelSetText (wnr.."Value", Enemy.toWString (item.value))

		local info = {}
		if (item.mit ~= nil and item.mit > 0) then tinsert (info, Enemy.toWString (item.mit)..L" mit") end
		if (item.abs ~= nil and item.abs > 0) then tinsert (info, Enemy.toWString (item.abs)..L" abs") end
		if (item.overheal ~= nil and item.overheal > 0) then tinsert (info, Enemy.toWString (item.overheal)..L" overheal") end
		
		LabelSetText (wnr.."Info", Enemy.JoinWStrings (info))

		if (wnr ~= dlg.hoverRow)
		then
			WindowSetShowing (wnr.."Background", false)
		end
	end
end	


function Enemy.CombatLogUI_SnapshotWindow_ListRowMouseOver ()

	local wnr = SystemData.ActiveWindow.name

	if (dlg.hoverRow)
	then
		WindowSetShowing (dlg.hoverRow.."Background", false)
	end

	dlg.hoverRow = SystemData.ActiveWindow.name
	WindowSetShowing (dlg.hoverRow.."Background", true)
	WindowSetAlpha (dlg.hoverRow.."Background", 0.5)
	WindowSetTintColor (dlg.hoverRow.."Background", 255, 204, 102)

	local data_index = WindowGetId (SystemData.ActiveWindow.name)
	if (data_index)
	then
		Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	
		Tooltips.SetTooltipText (1, 1, L"")
		Tooltips.SetTooltipText (2, 1, Enemy.combatLogSnapshotWindowListData[data_index].str)
		
		Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
		Tooltips.Finalize()
	end
end







