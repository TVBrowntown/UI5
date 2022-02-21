local Enemy = Enemy
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs

--------------------------------------------------------------- EnemyClickCasting class
EnemyClickCasting = {}
EnemyClickCasting.__index = EnemyClickCasting

function EnemyClickCasting.New (data)
	local obj = {}
	setmetatable (obj, EnemyClickCasting)

	-- defaults
	obj.name = nil
	obj.isEnabled = true
	obj.playerTypeMatch = 1
	obj.playerType = 1
	obj.exceptMe = false
	obj.archetypeMatch = 1
	obj.archetypes = { false, false, false }
	obj.mouseButton = 1
	obj.keyModifiers = { false, false, false }
	obj.action = 1
	obj.abilityId = nil
	obj.command = nil

	if (data)
	then
		obj:Load (data)
	end

	return obj
end


function EnemyClickCasting:Load (data)

	self.name = data.name
	self.isEnabled = data.isEnabled
	self.playerTypeMatch = data.playerTypeMatch
	self.playerType = data.playerType
	self.exceptMe = data.exceptMe
	self.archetypeMatch = data.archetypeMatch

	if (data.archetypes)
	then
		self.archetypes =
		{
			data.archetypes[1] or false,
			data.archetypes[2] or false,
			data.archetypes[3] or false
		}
	end

	self.mouseButton = data.mouseButton

	if (data.keyModifiers)
	then
		self.keyModifiers =
		{
			data.keyModifiers[1] or false,
			data.keyModifiers[2] or false,
			data.keyModifiers[3] or false
		}
	end

	self.action = data.action
	self.abilityId = data.abilityId
	self.command = data.command

	self._archetypesFilterPresent = (self.archetypes[1] or self.archetypes[2] or self.archetypes[3])

	self._flags = 0
	if (self.keyModifiers[1]) then self._flags = self._flags + SystemData.ButtonFlags.SHIFT end
	if (self.keyModifiers[2]) then self._flags = self._flags + SystemData.ButtonFlags.CONTROL end
	if (self.keyModifiers[3]) then self._flags = self._flags + SystemData.ButtonFlags.ALT end
end


function EnemyClickCasting:Edit (settings, onOkCallback)

	Enemy.UnitFramesUI_UnitFrameClickCastingDialog_Open (self, settings, self.id, function (old, new)

		old:Load (new)

		if (onOkCallback)
		then
			onOkCallback (self)
		end
	end)
end


function EnemyClickCasting:Remove ()
end

function EnemyClickCasting:Update (frame)
	self.frame = frame
end

--
-- Check wherever specified player can possibly match this click casting
--
function EnemyClickCasting:CanMatch (player)

	return not
		(
			-- player type filter
			(
				(
					self.playerType == 2
					and not (player.isSelf == (self.playerTypeMatch == 1))
				)
				or
				(
					self.playerType == 3
					and not (player.isInPlayerGroup == (self.playerTypeMatch == 1))
				)
			)

			or

			-- except me
			(
				self.exceptMe and player.isSelf
			)

			or

			-- archetypes filter
			(
				self._archetypesFilterPresent
				and
				(self.archetypes[Enemy.careerArchetypes[player.career]] ~= (self.archetypeMatch == 1))
			)
		)
end


function EnemyClickCasting:IsMatch (mouseButton, flags)
	return (mouseButton == self.mouseButton and flags == self._flags)
end


function EnemyClickCasting:Proceed ()

	if (self.action == 1)
	then
		local player = Enemy.groups.players[self.frame.playerName]
		if (not player or not player:IsSelected ()) then return false end

        WindowSetGameActionData (self.frame.windowName, GameData.PlayerActions.DO_ABILITY, self.abilityId, self.frame.playerName)

	elseif (self.action == 2)
	then
		WindowSetGameActionData (self.frame.windowName, 0, 0, L"")

		local cmd = self.command
		local player = Enemy.groups.players[self.frame.playerName]

		if (player)
		then
			cmd = cmd:gsub (L"{name}", player.name)
			cmd = cmd:gsub (L"{class}", GetCareerLine (player.career))
			cmd = cmd:gsub (L"{level}", player.level)
			cmd = cmd:gsub (L"{zone}", GetZoneName (player.zoneId))
		end

		Enemy.SendChatMessage (cmd)

	elseif (self.action == 3)
	then
	--d("windowName")
	--d(self.frame.windowName)
	--d("playerName")
	--d(self.frame.playerName)
		WindowSetGameActionData (self.frame.windowName, GameData.PlayerActions.ASSIST_PLAYER, 0, self.frame.playerName)
	end

	return true
end


----------------------------------------------------------------- UI: Click casting dialog
local click_casting_dlg =
{
	isInitialized = false
}


function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_IsOpen ()
	return WindowGetShowing ("EnemyClickCastingDialog")
end


function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_Hide ()
	WindowSetShowing ("EnemyClickCastingDialog", false)
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_Open (data, settings, ignoreId, onOkCallback)

	click_casting_dlg.isLoading = true

	if (not click_casting_dlg.isInitialized)
	then
		-- initialize dialog UI
		CreateWindow ("EnemyClickCastingDialog", false)

		LabelSetText ("EnemyClickCastingDialogTitleBarText", L"Click casting")
		ButtonSetText ("EnemyClickCastingDialogOkButton", L"OK")
		ButtonSetText ("EnemyClickCastingDialogCancelButton", L"Cancel")

		LabelSetText ("EnemyClickCastingDialogContentScrollChildNameLabel", L"Name")

		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerTypeMatch", L"Only on")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerTypeMatch", L"Except for")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerType", L"all")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerType", L"me")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerType", L"my group")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildExceptMeLabel", L"except me")

		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildArchetypeMatch", L"Only on")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildArchetypeMatch", L"Except for")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildArchetype1Label", L"tanks")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildArchetype2Label", L"dps")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildArchetype3Label", L"healers")

		LabelSetText ("EnemyClickCastingDialogContentScrollChildMouseButtonLabel", L"Mouse button")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildMouseButton", L"left")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildMouseButton", L"middle")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildMouseButton", L"right")

		LabelSetText ("EnemyClickCastingDialogContentScrollChildKeyModifiersLabel", L"With")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildKeyModifier1Label", L"shift")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildKeyModifier2Label", L"ctrl")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildKeyModifier3Label", L"alt")

		LabelSetText ("EnemyClickCastingDialogContentScrollChildActionLabel", L"Action")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildAction", L"Ability")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildAction", L"Slash command")
		ComboBoxAddMenuItem ("EnemyClickCastingDialogContentScrollChildAction", L"Assist")
		click_casting_dlg.maxActions = 3

		LabelSetText ("EnemyClickCastingDialogContentScrollChildActionConfig1Label", L"Drag & drop ability here")
		LabelSetText ("EnemyClickCastingDialogContentScrollChildActionConfig2Label", L"Command")

		click_casting_dlg.isInitialized = true
	end

	-- proceed parameters
	click_casting_dlg.oldData = data
	click_casting_dlg.onOkCallback = onOkCallback

	click_casting_dlg.data = EnemyClickCasting.New (data)

	-- fill form

	TextEditBoxSetText ("EnemyClickCastingDialogContentScrollChildName", Enemy.isNil (click_casting_dlg.data.name, L""))

	ComboBoxSetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerTypeMatch", click_casting_dlg.data.playerTypeMatch)
	ComboBoxSetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerType", click_casting_dlg.data.playerType)
	ButtonSetPressedFlag ("EnemyClickCastingDialogContentScrollChildExceptMe", click_casting_dlg.data.exceptMe)

	ComboBoxSetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildArchetypeMatch", click_casting_dlg.data.archetypeMatch)
	for k, a in pairs(click_casting_dlg.data.archetypes)
	do
		ButtonSetPressedFlag ("EnemyClickCastingDialogContentScrollChildArchetype"..k, a)
	end

	ComboBoxSetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildMouseButton", click_casting_dlg.data.mouseButton)
	for k, v in pairs(click_casting_dlg.data.keyModifiers)
	do
		ButtonSetPressedFlag ("EnemyClickCastingDialogContentScrollChildKeyModifier"..k, v)
	end

	ComboBoxSetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildAction", click_casting_dlg.data.action)

	Enemy.UnitFramesUI_UnitFrameClickCastingDialog_UpdateAbilityIcon ()
	TextEditBoxSetText ("EnemyClickCastingDialogContentScrollChildActionConfig2Command", Enemy.isNil (click_casting_dlg.data.command, L""))

	click_casting_dlg.isLoading = false
	WindowSetShowing ("EnemyClickCastingDialog", true)

	Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionSelChanged ()

	ScrollWindowSetOffset ("EnemyClickCastingDialogContent", 0)
	ScrollWindowUpdateScrollRect ("EnemyClickCastingDialogContent")
end


function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnExceptMeChanged ()

	if (click_casting_dlg.isLoading) then return end

	click_casting_dlg.data.exceptMe = not click_casting_dlg.data.exceptMe
	ButtonSetPressedFlag ("EnemyClickCastingDialogContentScrollChildExceptMe", click_casting_dlg.data.exceptMe)
end


local function _OnArchetypeChanged (n)

	if (click_casting_dlg.isLoading) then return end

	click_casting_dlg.data.archetypes[n] = not click_casting_dlg.data.archetypes[n]
	ButtonSetPressedFlag ("EnemyClickCastingDialogContentScrollChildArchetype"..n, click_casting_dlg.data.archetypes[n])
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnArchetype1Changed ()
	_OnArchetypeChanged (1)
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnArchetype2Changed ()
	_OnArchetypeChanged (2)
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnArchetype3Changed ()
	_OnArchetypeChanged (3)
end



local function _OnKeyModifierChanged (n)

	if (click_casting_dlg.isLoading) then return end

	click_casting_dlg.data.keyModifiers[n] = not click_casting_dlg.data.keyModifiers[n]
	ButtonSetPressedFlag ("EnemyClickCastingDialogContentScrollChildKeyModifier"..n, click_casting_dlg.data.keyModifiers[n])
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnKeyModifier1Changed ()
	_OnKeyModifierChanged (1)
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnKeyModifier2Changed ()
	_OnKeyModifierChanged (2)
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnKeyModifier3Changed ()
	_OnKeyModifierChanged (3)
end



function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionSelChanged ()

	if (click_casting_dlg.isLoading) then return end

	local value = ComboBoxGetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildAction")
	for k = 1, click_casting_dlg.maxActions
	do
		local show = false
		if (k == value)
		then
			show = true
		end

		WindowSetShowing ("EnemyClickCastingDialogContentScrollChildActionConfig"..k, show)
	end
end


function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_UpdateAbilityIcon ()

	if (not click_casting_dlg.data.abilityId)
	then
		DynamicImageSetTexture ("EnemyClickCastingDialogContentScrollChildActionConfig1Ability", "icon-0001", 0, 0)
		LabelSetText ("EnemyClickCastingDialogContentScrollChildActionConfig1Name", L"")
		return
	end

	local ability = GetAbilityData (click_casting_dlg.data.abilityId)
	local texture, tx, ty = GetIconData (ability.iconNum)
	DynamicImageSetTexture ("EnemyClickCastingDialogContentScrollChildActionConfig1Ability", texture, tx, ty)
	LabelSetText ("EnemyClickCastingDialogContentScrollChildActionConfig1Name", ability.name)
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionConfig1ActionLButtonUp ()
	if (click_casting_dlg.isLoading) then return end

	if (Cursor.IconOnCursor())
	then
		local ability = Player.GetAbilityData (Cursor.Data.ObjectId)
	    if (ability == nil or ability.abilityType == GameData.AbilityType.TACTIC) then return end

		Cursor.Clear ()
		click_casting_dlg.data.abilityId = ability.id
		Enemy.UnitFramesUI_UnitFrameClickCastingDialog_UpdateAbilityIcon ()
		Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionConfig1ActionMouseOver ()
	else
		 WindowSetShowing ("AbilitiesWindow", true)
	end
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionConfig1ActionRButtonUp ()
	if (click_casting_dlg.isLoading) then return end

	click_casting_dlg.data.abilityId = nil
	Enemy.UnitFramesUI_UnitFrameClickCastingDialog_UpdateAbilityIcon ()
	Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionConfig1ActionMouseOver ()
end

function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionConfig1ActionMouseOver ()
	if (click_casting_dlg.isLoading) then return end

	if (not click_casting_dlg.data.abilityId)
	then
		Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
		Tooltips.SetTooltipText (1, 1, L"Drag and drop ability here")
		Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
		Tooltips.Finalize()
	else
		local ability = GetAbilityData (click_casting_dlg.data.abilityId);
		local text = AbilitiesWindow.AbilityTypeDesc [AbilitiesWindow.currentMode];
		Tooltips.CreateAbilityTooltip (ability, SystemData.ActiveWindow.name, AbilitiesWindow.TOOLTIP_ANCHOR, text);
	end
end



function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_OnActionConfig2CommandMouseOver ()
	if (click_casting_dlg.isLoading) then return end

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, L"Enter the command here")
	Tooltips.SetTooltipText (2, 1, L" ")
	Tooltips.SetTooltipText (3, 1, L"You can use this substitutions:")
	Tooltips.SetTooltipText (4, 1, L"{name} - player name")
	Tooltips.SetTooltipText (5, 1, L"{class} - player class")
	Tooltips.SetTooltipText (6, 1, L"{level} - player level")
	Tooltips.SetTooltipText (7, 1, L"{zone} - player location zone")
	Tooltips.SetTooltipText (8, 1, L" ")
	Tooltips.SetTooltipText (9, 1, L"Example:")
	Tooltips.SetTooltipText (10, 1, L"/who {name}")
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.UnitFramesUI_UnitFrameClickCastingDialog_Ok ()

	if (click_casting_dlg.isLoading or not Enemy.UnitFramesUI_UnitFrameClickCastingDialog_IsOpen ()) then return end

	click_casting_dlg.data.name = Enemy.isEmpty (TextEditBoxGetText ("EnemyClickCastingDialogContentScrollChildName"), nil)

	click_casting_dlg.data.playerTypeMatch = ComboBoxGetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerTypeMatch")
	click_casting_dlg.data.playerType = ComboBoxGetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildPlayerType")

	click_casting_dlg.data.archetypeMatch = ComboBoxGetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildArchetypeMatch")
	click_casting_dlg.data.archetypes =
	{
		ButtonGetPressedFlag ("EnemyClickCastingDialogContentScrollChildArchetype1"),
		ButtonGetPressedFlag ("EnemyClickCastingDialogContentScrollChildArchetype2"),
		ButtonGetPressedFlag ("EnemyClickCastingDialogContentScrollChildArchetype3")
	}

	click_casting_dlg.data.mouseButton = ComboBoxGetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildMouseButton")
	click_casting_dlg.data.keyModifiers =
	{
		ButtonGetPressedFlag ("EnemyClickCastingDialogContentScrollChildKeyModifier1"),
		ButtonGetPressedFlag ("EnemyClickCastingDialogContentScrollChildKeyModifier2"),
		ButtonGetPressedFlag ("EnemyClickCastingDialogContentScrollChildKeyModifier3")
	}

	click_casting_dlg.data.action = ComboBoxGetSelectedMenuItem ("EnemyClickCastingDialogContentScrollChildAction")
	click_casting_dlg.data.command = Enemy.isEmpty (TextEditBoxGetText ("EnemyClickCastingDialogContentScrollChildActionConfig2Command"), nil)

	if (not click_casting_dlg.data.name)
	then
		DialogManager.MakeOneButtonDialog (L"You must enter a name.", L"Ok")
		return
	end

--	if (not click_casting_dlg.data.keyModifiers[1]
--		and not click_casting_dlg.data.keyModifiers[2]
--		and not click_casting_dlg.data.keyModifiers[3])
--	then
--		DialogManager.MakeOneButtonDialog (L"You must select key modifiers.", L"Ok")
--		return
--	end

	if (click_casting_dlg.data.action == 1 and not click_casting_dlg.data.abilityId)
	then
		DialogManager.MakeOneButtonDialog (L"You must select the ability.", L"Ok")
		return
	end

	if (click_casting_dlg.data.action == 2 and not click_casting_dlg.data.command)
	then
		DialogManager.MakeOneButtonDialog (L"You must enter the command.", L"Ok")
		return
	end

	if (click_casting_dlg.onOkCallback)
	then
		click_casting_dlg.onOkCallback (click_casting_dlg.oldData, click_casting_dlg.data)
	end

	Enemy.UnitFramesUI_UnitFrameClickCastingDialog_Hide ()
end
