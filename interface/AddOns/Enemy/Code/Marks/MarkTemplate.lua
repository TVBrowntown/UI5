local Enemy = Enemy
local MAX_SCALE = 5

local tinsert = table.insert
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local tostring = tostring

local MARK_WIDTH = 100
local MARK_HEIGHT = 200


EnemyMarkTemplate = {}
EnemyMarkTemplate.__index = EnemyMarkTemplate


function EnemyMarkTemplate.New (data)
	local obj = {}
	setmetatable (obj, EnemyMarkTemplate)

	obj.id = Enemy.NewId ()
	obj.name = L""
	obj.color = { 255, 255, 255 }
	obj.alpha = 1.0
	obj.scale = 1.0
	obj.showCareerIcon = true
	obj.layer = Window.Layers.POPUP
	obj.offsetY = 50
	obj.targetOnClick = true
	obj.display = 2
	obj.text = L""
	obj.firstLetters = 4
	obj.font = "font_clear_large_bold"
	obj.canClearOnClick = true
	obj.neverExpire = false
	obj.unique = false

	obj.permanent = false
	obj.permanentTargets = {}

	obj._activeMarks = {}

	if (data)
	then
		obj:Load (data)
	end

	return obj
end


function EnemyMarkTemplate:Load (data)

	self.name = data.name

	if (data.color) then self.color = Enemy.clone (data.color) end
	self.alpha = data.alpha
	self.scale = data.scale
	self.showCareerIcon = data.showCareerIcon
	self.layer = data.layer
	self.offsetY = data.offsetY
	self.targetOnClick = data.targetOnClick
	self.display = data.display
	self.text = data.text
	self.firstLetters = data.firstLetters
	self.font = data.font or self.font
	self.canClearOnClick = data.canClearOnClick
	self.neverExpire = data.neverExpire
	self.unique = data.unique

	self.permanent = data.permanent
	if (data.permanentTargets) then self.permanentTargets = Enemy.clone (data.permanentTargets) end

	for k,v in pairs (self.permanentTargets)
	do
		self.permanentTargets[k] = false
	end

	self:Update ()
end


function EnemyMarkTemplate:Apply (windowName, objectName, isPlayer, isFriendly, careerId)

	WindowSetScale (windowName, self.scale)
	WindowSetLayer (windowName, self.layer)

	if (self.targetOnClick and isPlayer)
	then
		WindowSetHandleInput (windowName, true)

		if (isFriendly)
		then

			WindowSetGameActionData (windowName.."Content", GameData.PlayerActions.SET_TARGET, 0, objectName)
		end
	else
		WindowSetGameActionData (windowName.."Content", GameData.PlayerActions.SET_TARGET, 0, objectName)
		WindowSetHandleInput (windowName, false)
	end

	WindowSetAlpha (windowName.."Content", self.alpha)
	WindowSetTintColor (windowName.."ContentBackground", unpack (self.color))

	if (self.offsetY >= 0)
	then
		WindowSetDimensions (windowName, MARK_WIDTH, MARK_HEIGHT + self.offsetY)
		WindowClearAnchors (windowName.."Content")
		WindowAddAnchor (windowName.."Content", "topleft", windowName, "topleft", 0, 0)
	else
		WindowSetDimensions (windowName, MARK_WIDTH, MARK_HEIGHT)
		WindowClearAnchors (windowName.."Content")
		WindowAddAnchor (windowName.."Content", "topleft", windowName, "topleft", 0, -self.offsetY)
	end

	-- force position update
	local object_window = Enemy.GetObjectWindow (windowName)
	if (object_window ~= nil) then object_window:Attach () end

	if (self.showCareerIcon and careerId and careerId > 0)
	then
		local icon, icon_x, icon_y = GetIconData (Icons.GetCareerIconIDFromCareerLine (careerId))
		DynamicImageSetTexture (windowName.."ContentIcon", icon, icon_x, icon_y)
		WindowSetShowing (windowName.."ContentIcon", true)
	else
		WindowSetShowing (windowName.."ContentIcon", false)
	end

	LabelSetFont (windowName.."ContentText", self.font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetText (windowName.."ContentText", L"")
	WindowSetDimensions (windowName.."ContentText", 200, 200)

	if (self.display == 1)
	then
		LabelSetText (windowName.."ContentText", self.text)
	elseif (objectName)
	then
		LabelSetText (windowName.."ContentText", Enemy.toWString (objectName:sub (1, self.firstLetters)))
	end

	local text_real_dx, text_real_dy = LabelGetTextDimensions (windowName.."ContentText")
	WindowSetDimensions (windowName.."ContentText", text_real_dx, text_real_dy)
end


function EnemyMarkTemplate:ToggleMark (objectId, objectName, isPlayer, isFriendly, careerId)

	if (objectId == 0) then return end

	objectName = Enemy.FixString (objectName)

	local window_name = "EnemyMark"
	if (isPlayer)
	then
		window_name = window_name..tostring (objectName)
	else
		window_name = window_name..objectId
	end

	local object_window = Enemy.GetObjectWindow (window_name)

	if (object_window ~= nil)
	then
		object_window:Remove ()

		if (object_window.data.template == self)
		then
			if (self.permanent and isPlayer and self.permanentTargets[objectName] ~= nil)
			then
				self.permanentTargets[objectName] = nil
			end

			return
		end
	end

	if (self.unique)
	then
		self:ClearMarks (true)
	end

	-- create mark
	CreateWindowFromTemplate (window_name, "EnemyMark", "Root")
	WindowSetShowing (window_name, false)

	-- register it
	local active_mark =
	{
		objectId = objectId,
		objectName = objectName,
		isPlayer = isPlayer,
		isFriendly = isFriendly,
		careerId = careerId,
		windowName = window_name,
		t = Enemy.time
	}

	tinsert (self._activeMarks, active_mark)

	if (isPlayer and self.permanent)
	then
		self.permanentTargets[objectName] = true
	end

	-- apply
	self:Apply (window_name, objectName, isPlayer, isFriendly, careerId)

	-- attach to world object
	local ow_data =
	{
		windowName = window_name,
		id = objectId,

		data =
		{
			template = self,
			isMark = true,
			manualTargetOnClick = self.targetOnClick and isPlayer and not isFriendly,
			canClearOnClick = self.canClearOnClick
		},

		removeCallback = function (item)

			local template = item.data.template

			for k, mark in ipairs (template._activeMarks)
			do
				if (mark.objectId == item.id)
				then
					table.remove (template._activeMarks, k)
					break
				end
			end

			if (item.playerName and template.permanentTargets[item.playerName] == true)
			then
				template.permanentTargets[item.playerName] = false
			end

			if (DoesWindowExist (item.windowName))
			then
				DestroyWindow (item.windowName)
			end
		end
	}

	if (self.neverExpire)
	then
		ow_data.inactiveTimeout = -1
	end

	if (isPlayer)
	then
		ow_data.playerName = objectName
	end

	EnemyObjectWindow.New (ow_data)
	WindowSetShowing (window_name, false)
end


function Enemy.MarkUI_EnemyMark_OnRButtonUp (flags)

	if (not Enemy.IsShiftPressed(flags)) then return end

	local object_window = Enemy.GetObjectWindow (WindowGetParent (SystemData.MouseOverWindow.name))
	if (not object_window or not object_window.data.canClearOnClick) then return end

	local template = object_window.data.template
	if (template.permanent and object_window.playerName and template.permanentTargets[object_window.playerName] ~= nil)
	then
		template.permanentTargets[object_window.playerName] = nil
	end

	object_window:Remove ()
end


function Enemy.MarkUI_EnemyMark_OnLButtonDown ()

	local object_window = Enemy.GetObjectWindow (WindowGetParent (SystemData.MouseOverWindow.name))
	if (object_window == nil or not object_window.data.manualTargetOnClick) then return end

	Enemy.SendChatMessage (L"/target "..Enemy.FixString (object_window.playerName))
end


function EnemyMarkTemplate:Update ()

	for _, mark in ipairs (self._activeMarks)
	do
		self:Apply (mark.windowName, mark.objectName, mark.isPlayer, mark.isFriendly, mark.careerId)
	end
end


function EnemyMarkTemplate:ClearMarks (clearPermanentTargets)

	local object_windows_to_remove = {}

	for _, mark in ipairs (self._activeMarks)
	do
		tinsert (object_windows_to_remove, mark.windowName)
	end

	self._activeMarks = {}

	for _, v in ipairs (object_windows_to_remove)
	do
		local object_window = Enemy.GetObjectWindow (v)
		if (not object_window) then continue end

		object_window:Remove ()
	end

	if (clearPermanentTargets)
	then
		self.permanentTargets = {}
	end
end


function EnemyMarkTemplate:Edit (onOkCallback)
	Enemy.MarksUI_MarkConfigDialog_Open (self, onOkCallback)
end



----------------------------------------------------------------- UI: Mark config dialog
local config_dlg =
{
	isInitialized = false,
	properties =
	{
		name =
		{
			key = "name",
			order = 10,
			name = L"Name",
			type = "string"
		},
		color =
		{
			key = "color",
			order = 20,
			name = L"Color",
			type = "color",
			default = {255, 255, 255}
		},
		scale =
		{
			key = "scale",
			order = 25,
			name = L"Scale",
			type = "float",
			default = 1,
			min = 0,
			max = 5
		},
		alpha =
		{
			key = "alpha",
			order = 30,
			name = L"Opacity",
			type = "float",
			default = 1,
			min = 0,
			max = 1
		},
		layer =
		{
			key = "layer",
			order = 40,
			name = L"Layer",
			type = "select",
			default = Window.Layers.POPUP,
			values = Enemy.ConfigurationWindowGetLayersSelectValues
		},
		offsetY =
		{
			key = "offsetY",
			order = 50,
			name = L"Offset (Y)",
			type = "int",
			default = 50,
			min = 0,
			max = 1000
		},

		showCareerIcon =
		{
			key = "showCareerIcon",
			order = 60,
			name = L"Show career icon",
			type = "bool",
			default = true,
			paddingTop = 30
		},
		targetOnClick =
		{
			key = "targetOnClick",
			order = 70,
			name = L"Target on click",
			type = "bool",
			default = true,
			tooltip = L"If checked then clicking on mark will target the marked player. Will not work on mobs and will work on enemies with slight delay but only if they are close enough. With this checked on you can shift right-click on mark to remove it."
		},
		permanent =
		{
			key = "permanent",
			order = 75,
			name = L"Permanent",
			type = "bool",
			default = false,
			tooltip = L"Check to store all marked players even after relog. Will not work on mobs. Stored player will be automarked again when mouseovered or targeted."
		},
		unique =
		{
			key = "unique",
			order = 76,
			name = L"Unique",
			type = "bool",
			default = false,
			tooltip = L"If checked then this mark will be put only on one latest target."
		},

		font =
		{
			key = "font",
			order = 80,
			name = L"Font",
			type = "select",
			default = "font_clear_large_bold",
			values = Enemy.ConfigurationWindowGetFontsSelectValues,
			paddingTop = 30
		},
		display =
		{
			key = "display",
			order = 90,
			name = L"Display",
			type = "select",
			default = "font_clear_large_bold",
			values =
			{
				{ text = L"text", value = 1 },
				{ text = L"first N letters", value = 2 }
			}
		}
	},
	propertiesByDisplayType =
	{
		{
			text =
			{
				key = "text",
				order = 10,
				name = L"Text",
				type = "string"
			}
		},
		{
			firstLetters =
			{
				key = "firstLetters",
				order = 10,
				name = L"N",
				type = "integer",
				min = 1,
				max = 100,
				default = 4
			}
		}
	}
}

function Enemy.MarksUI_MarkConfigDialog_IsOpen ()
	return WindowGetShowing ("EnemyMarkConfigDialog")
end


function Enemy.MarksUI_MarkConfigDialog_Hide ()
	WindowSetShowing ("EnemyMarkConfigDialog", false)
end


local function OnDisplayPropertyChanged ()

	config_dlg.isLoading = true

	local root2 = "EnemyMarkConfigDialogConfig2"
	config_dlg.cwn2 = root2.."W"

	if (DoesWindowExist (config_dlg.cwn2))
	then
		Enemy.ConfigurationWindowSaveData (config_dlg.cwn2, config_dlg.data)
		DestroyWindow (config_dlg.cwn2)
	end

	local width, height = Enemy.CreateConfigurationWindow (config_dlg.cwn2, root2, config_dlg.propertiesByDisplayType[config_dlg.data.display], Enemy.MarksUI_MarkConfigDialog_TestSettings2)
	WindowSetDimensions (root2, width, height)

	Enemy.ConfigurationWindowLoadData (config_dlg.cwn2, config_dlg.data)

	config_dlg.isLoading = false
end


function Enemy.MarksUI_MarkConfigDialog_Open (template, onOkCallback)

	if (not config_dlg.isInitialized)
	then
		-- initialize dialog UI
		CreateWindow ("EnemyMarkConfigDialog", false)
		LabelSetText ("EnemyMarkConfigDialogTitleBarText", L"Edit mark template")
		ButtonSetText ("EnemyMarkConfigDialogOkButton", L"OK")
		ButtonSetText ("EnemyMarkConfigDialogCancelButton", L"Cancel")

		local root = "EnemyMarkConfigDialogConfig"
		config_dlg.cwn = root.."W"
		local width, height = Enemy.CreateConfigurationWindow (config_dlg.cwn, root, config_dlg.properties, Enemy.MarksUI_MarkConfigDialog_TestSettings)
		WindowSetDimensions (root, width, height)

		config_dlg.isInitialized = true
	end

	-- proceed parameters
	config_dlg.template = template
	config_dlg.onOkCallback = onOkCallback

	config_dlg.data = EnemyMarkTemplate.New (template)

	config_dlg.exampleCareerId = math.random (24)
	config_dlg.exampleObjectName = "Abcdefghijklmnopqrstuvwxyz"

	-- fill form
	config_dlg.isLoading = true

	Enemy.ConfigurationWindowLoadData (config_dlg.cwn, config_dlg.data)
	OnDisplayPropertyChanged ()

	config_dlg.isLoading = false

	WindowSetShowing ("EnemyMarkConfigDialog", true)
	Enemy.MarksUI_MarkConfigDialog_TestSettings ()
end

function Enemy.MarksUI_MarkConfigDialog_TestSettings ()

	if (config_dlg.isLoading) then return end

	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, config_dlg.data)
	OnDisplayPropertyChanged ()

	Enemy.MarksUI_MarkConfigDialog_UpdateExample ()
end


function Enemy.MarksUI_MarkConfigDialog_TestSettings2 ()
	Enemy.ConfigurationWindowSaveData (config_dlg.cwn2, config_dlg.data)
	Enemy.MarksUI_MarkConfigDialog_UpdateExample ()
end


function Enemy.MarksUI_MarkConfigDialog_UpdateExample ()
	config_dlg.data:Apply ("EnemyMarkConfigDialogExample",
								config_dlg.exampleObjectName,
								false,
								false,
								config_dlg.exampleCareerId)
end


function Enemy.MarksUI_MarkConfigDialog_Ok ()

	Enemy.MarksUI_MarkConfigDialog_TestSettings ()

	config_dlg.template:Load (config_dlg.data)

	if (config_dlg.onOkCallback)
	then
		config_dlg.onOkCallback (config_dlg.template)
	end

	Enemy.MarksUI_MarkConfigDialog_Hide ()
end
