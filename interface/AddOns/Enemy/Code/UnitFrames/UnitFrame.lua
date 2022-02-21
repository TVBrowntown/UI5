local Enemy = Enemy
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs
local mfloor = math.floor
local mceil = math.ceil
local mmin = math.min
local mmax = math.max
local InterfaceCore = InterfaceCore

Enemy.UnitFramePlayerUpdateFilters =
{
	Distance =
	{
		Parts = {}
	}
}


--------------------------------------------------------------- EnemyUnitFrame class
EnemyUnitFrame = {}
EnemyUnitFrame.__index = EnemyUnitFrame


function EnemyUnitFrame.New (groupIndex, index)
	local obj = {}
	setmetatable (obj, EnemyUnitFrame)

	obj.groupIndex = groupIndex
	obj.index = index

	obj.isEnabled = false
	obj.isSelected = false

	obj.parts = {}
	obj.effectsIndicators = {}
	obj.clickCastings = {}

	return obj
end


function EnemyUnitFrame:Reset (partial)

	self.playerCareer = nil
	self.playerIsOnline = nil
	self.playerHP = nil
	self.playerAP = nil
	self.playerName = nil
	self.playerLevel = nil
	self.playerIsDistant = nil
	self.playerGroupIndex = nil

	if (not partial)
	then
		self:_RemoveAllParts ()
		self:_RemoveAllEffectsIndicators ()
		self:_RemoveAllClickCastings ()
	end
end


function EnemyUnitFrame:Remove ()

	self:_RemoveAllParts ()
	self:_RemoveAllEffectsIndicators ()
	self:_RemoveAllClickCastings ()

	if (self.windowName)
	then
		DestroyWindow (self.windowName)
		self.windowName = nil
	end

	self:BoundingBoxSetShowing (false)
	self:Reset ()
end


function EnemyUnitFrame:BoundingBoxSetShowing (show)

	if (self._boundingBoxWindowName)
	then
		if (DoesWindowExist (self._boundingBoxWindowName)) then DestroyWindow (self._boundingBoxWindowName) end
		self._boundingBoxWindowName = nil
	end

	local global_scale = InterfaceCore.GetScale ()

	if (self.isEnabled and show)
	then
		self._boundingBoxWindowName = "BoundingBox"..Enemy.NewId ()
		CreateWindowFromTemplate (self._boundingBoxWindowName, "EnemyRectangleTemplate", self.windowName)
		WindowAddAnchor (self._boundingBoxWindowName, "topleft", self.windowName, "topleft", 0, 0)
		WindowAddAnchor (self._boundingBoxWindowName, "bottomright", self.windowName, "bottomright", 0, 0)
		WindowSetLayer (self._boundingBoxWindowName, Window.Layers.OVERLAY)
		WindowSetScale (self.windowName, self.settings.unitFramesScale * global_scale)
	end
end


function EnemyUnitFrame:IsEnabled ()
	return self.isEnabled
end


function EnemyUnitFrame:Disable ()

	if (not self.windowName) then return end
	WindowSetShowing (self.windowName, false)

	self.isEnabled = false
	self:Reset ()
end


function EnemyUnitFrame:Enable ()

	if (not self.windowName) then return end
	WindowSetShowing (self.windowName, true)
	self.isEnabled = true
end


function EnemyUnitFrame:_HideAllEffectsIndicators ()

	for _, effects_indicator in ipairs (self.effectsIndicators)
	do
		effects_indicator:Hide ()
	end
end

function EnemyUnitFrame:_ShowAllEffectsIndicators ()

	for _, effects_indicator in ipairs (self.effectsIndicators)
	do
		effects_indicator:Show ()
	end
end

function EnemyUnitFrame:_RemoveAllParts ()

	for _, v in ipairs (self.parts)
	do
		v:Remove ()
	end

	self.parts = {}
end

function EnemyUnitFrame:_RemoveAllEffectsIndicators ()

	for _, v in ipairs (self.effectsIndicators)
	do
		v:Remove ()
	end

	self.effectsIndicators = {}
end

function EnemyUnitFrame:_RemoveAllClickCastings ()

	for _, v in ipairs (self.clickCastings)
	do
		v:Remove ()
	end

	self.clickCastings = {}
end


function EnemyUnitFrame:_RecreateAllParts (player)

	self:_RemoveAllParts ()

	for _, data in pairs (self.settings.unitFramesParts)
	do
		local obj = EnemyUnitFramePart.New (data)

		if (not obj.isEnabled or not obj:CanMatch (player)) then continue end

		tinsert (self.parts, obj)
		obj:Bind (self)
	end
end


function EnemyUnitFrame:_RecreateAllEffectsIndicators (player)

	self:_RemoveAllEffectsIndicators ()

	for _, data in pairs (self.settings.effectsIndicators)
	do
		local obj = EnemyEffectsIndicator.New (data)

		if (not obj.isEnabled or (not self.settings.unitFramesTestMode and not obj:CanMatch (player))) then continue end

		tinsert (self.effectsIndicators, obj)
		obj:Update (self)
	end
end


function EnemyUnitFrame:_RecreateAllClickCastings (player)

	self:_RemoveAllClickCastings ()

	for _, data in pairs (self.settings.clickCastings)
	do
		local obj = EnemyClickCasting.New (data)

		if (not obj.isEnabled or not obj:CanMatch (player)) then continue end

		tinsert (self.clickCastings, obj)
		obj:Update (self)
	end
end


function EnemyUnitFrame:ApplySettings (settings)

	self.settings = settings

	if (not self.windowName)
	then
		self.windowName = "EnemyUnitFrame"..tostring (self.groupIndex).."_"..tostring (self.index)
		CreateWindowFromTemplate (self.windowName, "EnemyUnitFrame", "Root")

		self:Disable ()
	end

	local global_scale = InterfaceCore.GetScale ()

	WindowSetDimensions (self.windowName, self.settings.unitFramesSize[1], self.settings.unitFramesSize[2])
	WindowSetLayer (self.windowName, self.settings.unitFramesLayer)
	WindowSetScale (self.windowName, self.settings.unitFramesScale * global_scale)

	self:_RemoveAllParts ()
	self:_RemoveAllEffectsIndicators ()
	self:_RemoveAllClickCastings ()
	self.forcePlayerChanged = true
end


function EnemyUnitFrame:UpdatePosition ()

	if (not Enemy.unitFrames.positionMatrix or not self.windowName) then return end

	local pos_group = Enemy.unitFrames.positionMatrix[self.groupIndex]
	if (not pos_group) then return end

	local pos = pos_group[self.index]
	if (not pos) then return end

	WindowClearAnchors (self.windowName)
	WindowAddAnchor (self.windowName, "topleft", pos.anchorWindow.windowName, "topleft", mfloor (0.5 + pos.x), mfloor (0.5 + pos.y))
end


function EnemyUnitFrame:Update (player)

	if (not self.isEnabled) then return end

	if (self.forcePlayerChanged
		or
		(self.playerCareer ~= player.career and player.career > 0)
		or
		self.playerName ~= player.name
		or
		self.playerGroupIndex ~= player.groupIndex)
	then
		self.playerCareer = player.career
		self.playerName = player.name
		self.playerGroupIndex = player.groupIndex

		self:_RecreateAllParts (player)
		self:_RecreateAllEffectsIndicators (player)
		self:_RecreateAllClickCastings (player)
	end

	for _, part in ipairs (self.parts)
	do
		part:Update (player, self.settings.unitFramesTestMode)
	end

	self.forcePlayerChanged = false
end


function EnemyUnitFrame:UpdateDistance (player)

	local f = Enemy.UnitFramePlayerUpdateFilters.Distance.Parts

	for _, part in ipairs (self.parts)
	do
		if (f[part.type])
		then
			part:Update (player, self.settings.unitFramesTestMode)
		end
	end
end


function EnemyUnitFrame:UpdateEffects (player)

	for _, effects_indicator in ipairs (self.effectsIndicators)
	do
		effects_indicator:EffectsUpdated (player, self.settings.unitFramesTestMode)
	end
end


function EnemyUnitFrame:ProceedClickCasting (mouseButton, flags)

	for _, click_casting in pairs (self.clickCastings)
	do
		if (click_casting:IsMatch (mouseButton, flags))
		then
			return click_casting:Proceed ()
		end
	end

	WindowSetGameActionData (self.windowName, 0, 0, L"")

	return false
end


function Enemy._GetUnitFrameFromWindowName (name)
	local group_index, index = name:match ("EnemyUnitFrame(%d+)_(%d+)")
	if (group_index == nil or index == nil) then return nil end

	local frame_group = Enemy.unitFrames.frames[tonumber (group_index)]
	if (not frame_group) then return nil end

	local frame = frame_group[tonumber (index)]
	if (not frame) then return nil end

	return group_index, index, frame
end


function Enemy.UnitFramesUI_UnitFrame_OnLButtonDown (flags)

	local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
	if (not frame) then return end

	local e = { cancel = false }
	Enemy.TriggerEvent ("UnitFramesOnMouse", e, 1, true, flags, frame)
	if (e.cancel) then return end

	frame.lButtonProceeded = frame:ProceedClickCasting (1, flags)

	if (not frame.lButtonProceeded)
	then
		WindowSetGameActionData (frame.windowName, GameData.PlayerActions.SET_TARGET, 0, frame.playerName)
	end
end


function Enemy.UnitFramesUI_UnitFrame_OnMButtonDown (flags)

	local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
	if (not frame) then return end

	local e = { cancel = false }
	Enemy.TriggerEvent ("UnitFramesOnMouse", e, 2, true, flags, frame)
	if (e.cancel) then return end

	frame.mButtonProceeded = frame:ProceedClickCasting (2, flags)
end


function Enemy.UnitFramesUI_UnitFrame_OnRButtonDown (flags)

	local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
	if (not frame) then return end

	local e = { cancel = false }
	Enemy.TriggerEvent ("UnitFramesOnMouse", e, 3, true, flags, frame)
	if (e.cancel) then return end

	frame.rButtonProceeded = frame:ProceedClickCasting (3, flags)
end


function Enemy.UnitFramesUI_UnitFrame_OnLButtonUp (flags)

	local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
	if (not frame) then return end

	local e = { cancel = false }
	Enemy.TriggerEvent ("UnitFramesOnMouse", e, 1, false, flags, frame)

	if (GetDesiredInteractAction () == SystemData.InteractActions.TELEPORT)
	then
		UseItemTargeting.SendTeleport ()
	end
end


function Enemy.UnitFramesUI_UnitFrame_OnMButtonUp (flags)

	local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
	if (not frame) then return end

	local e = { cancel = false }
	Enemy.TriggerEvent ("UnitFramesOnMouse", e, 2, false, flags, frame)
end


function Enemy.UnitFramesUI_UnitFrame_OnRButtonUp (flags)

	local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
	if (not frame or frame.rButtonProceeded) then return end

	local e = { cancel = false }
	Enemy.TriggerEvent ("UnitFramesOnMouse", e, 3, false, flags, frame)
	if (e.cancel) then return end

	local player = Enemy.groups.players[frame.playerName]
	local self_player = Enemy.groups.player
	if (not player or not self_player) then return end

	SystemData.UserInput.selectedGroupMember = player.name

	local custom_menu_items = {}
	local is_in_group_or_warband = (Enemy.groups.groupType == Enemy.GroupTypes.Group or Enemy.groups.groupType == Enemy.GroupTypes.Warband)

	table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_GROUP_OPTIONS), EA_Window_OpenParty.OpenToManageTab, false))
	table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (L"Unit frames options", function () Enemy.UI_ConfigDialog_Open ("UnitFrames") end, false))
	table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (L"Group icons options", function () Enemy.UI_ConfigDialog_Open ("GroupIcons") end, false))

	if (is_in_group_or_warband)
	then
		if (self_player.isGroupLeader)
		then
			table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_PARTY_FORM_WARPARTY), GroupWindow.OnFormWarparty, Enemy.groups.groupType == Enemy.GroupTypes.Warband))

			if (Enemy.groups.groupType == Enemy.GroupTypes.Group)
			then
				table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_MAKE_LEADER), GroupWindow.OnMakeLeader, player.isSelf or not player.isOnline))
			else
				table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_MAKE_LEADER), BattlegroupHUD.OnMenuClickMakeLeader, player.isSelf or not player.isOnline))
			end
		end

		if (Enemy.groups.groupType == Enemy.GroupTypes.Group)
		then
			table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_LEAVE_GROUP), GroupWindow.OnLeaveGroup, false))
		else
			table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_LEAVE_GROUP), BattlegroupHUD.OnMenuClickLeaveGroup, false))
		end
	end

	if (self_player.isGroupLeader or self_player:IsMainAssist ())
	then
		if (Enemy.groups.groupType == Enemy.GroupTypes.Group)
		then
			table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_MAKE_MAIN_ASSIST), GroupWindow.OnMakeMainAssist,
				player:IsMainAssist () or not player.isOnline))
		else
			table.insert (custom_menu_items, PlayerMenuWindow.NewCustomItem (GetString (StringTables.Default.LABEL_MAKE_MAIN_ASSIST), BattlegroupHUD.OnMenuClickMakeMainAssist,
				player:IsMainAssist () or not player.isOnline))
		end
	end

	PlayerMenuWindow.ShowMenu (player.name, 0, custom_menu_items)
end



function Enemy.UnitFramesUI_UnitFrame_OnMouseOver (flags)

	local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
	if (not frame) then return end

	if (
		frame.settings.unitFramesTooltipMode == "never"
		or
		(frame.settings.unitFramesTooltipMode == "shift" and not Enemy.IsShiftPressed(flags))
		or
		(frame.settings.unitFramesTooltipMode == "alt" and not Enemy.IsAltPressed(flags))
		or
		(frame.settings.unitFramesTooltipMode == "ctrl" and not Enemy.IsCtrlPressed(flags))
		)
	then
		return
	end

	local player = Enemy.groups.players[frame.playerName]
	local self_player = Enemy.groups.player
	if (not player or not self_player) then return end

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)

	Tooltips.SetTooltipText (1, 1, player.name)
	Tooltips.SetTooltipColor (1, 1, 150, 150, 255)

	if (player.groupIndex)
	then
		Tooltips.SetTooltipText (1, 3, L"Group "..player.groupIndex)
		Tooltips.SetTooltipColor (1, 3, 100, 100, 100)
	end

	Tooltips.SetTooltipText (2, 1, GetCareerLine (player.career))
	Tooltips.SetTooltipText (2, 3, towstring (player.level)..L" lvl")

	local k = 2

	if (player.zoneId > 0)
	then
		k = k + 1
		Tooltips.SetTooltipText (k, 1, L"Location")
		Tooltips.SetTooltipText (k, 3, GetZoneName (player.zoneId))
		Tooltips.SetTooltipColor (k, 3, 200, 255, 100)
	end

	if (player.isGroupLeader or player.isDistant or player.isLOS or not player.isOnline)
	then
		k = k + 1
		Tooltips.SetTooltipText (k, 1, L" ")
	end

	if (player.isGroupLeader)
	then
		k = k + 1

		if (Enemy.groups.groupType == Enemy.GroupTypes.Warband)
		then
			Tooltips.SetTooltipText (k, 1, L"Warband leader")
		else
			Tooltips.SetTooltipText (k, 1, L"Group leader")
		end

		Tooltips.SetTooltipColor (k, 1, 200, 255, 100)
	end

	if (player.distance and not player.isSelf)
	then
		k = k + 1
		Tooltips.SetTooltipText (k, 1, L"Distance")
		Tooltips.SetTooltipText (k, 3, towstring (player.distance))
	end

	if (player.isDistant)
	then
		k = k + 1
		Tooltips.SetTooltipText (k, 1, L"Distant")
		Tooltips.SetTooltipColor (k, 1, 150, 150, 150)
	end

	if (player.isLOS)
	then
		k = k + 1
		Tooltips.SetTooltipText (k, 1, L"Out of LOS")
		Tooltips.SetTooltipColor (k, 1, 150, 150, 150)
	end

	if (not player.isOnline)
	then
		k = k + 1
		Tooltips.SetTooltipText (k, 1, L"Offline")
		Tooltips.SetTooltipColor (k, 1, 255, 150, 150)
	end

	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end
