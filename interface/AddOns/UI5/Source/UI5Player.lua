UI5Player = {}

local UnitWidth = 210 --310
local UnitHeight = 40 --80
local UnitBuffer = 4

local PlayerMaxHP = GameData.Player.hitPoints.current
local PlayerCurHP = GameData.Player.hitPoints.maximum

function UI5.GetPlayerInfo()
	playerName 				= wstring.sub(GameData.Player.name,1,-3)
	playerCareer 			= WStringToString(GameData.Player.career.name)
	playerCareerId 			= GameData.Player.career.id
	UI5HPper 				= (GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum) * 100
	UI5APper 				= (GameData.Player.actionPoints.current / GameData.Player.actionPoints.maximum) * 100
	playerCareerId 			= GameData.Player.career.line
	
	if oldUIMode == true then
		if playerCareerId ~= 0 then
			if DoesWindowExist("PlayerAvatar") then
				DynamicImageSetTexture("PlayerAvatar", UI5.CareerIdToHDIcon[playerCareerId], 64, 64)
				if UI5.CareerIdToHDIcon[playerCareerId] == nil then return end
				DynamicImageSetTextureDimensions("PlayerAvatar", 64, 64)
			end
		end
	end

end

function UI5.UpdatePlayerHP()
	local UI5HPper = (GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum) * 100
	UI5.UpdateHP(UI5HPper, "Player", playerName, playerCareerId)
end

function UI5.UpdatePlayerAP()
	if apBar == nil then
		APfadeBar = 512
	else
		APfadeBar = apBar
	end

	apBar = (GameData.Player.actionPoints.current / GameData.Player.actionPoints.maximum) * 512
	UI5APper = (GameData.Player.actionPoints.current / GameData.Player.actionPoints.maximum) * 100
	
	if apBar >= 512 then
		apBar = 512
	end

	if apBar <= 0 then
		apBar = 0
	end

	WindowSetDimensions("PlayerAPBar", apBar, 43)
	LabelSetText("PlayerAPText", round(UI5APper)..L"%")
end

--[[

Window.AnimationType.SINGLE_NO_RESET

DynamicImageClearCustomShader()
DynamicImageHasTexture()
DynamicImageSetCustomShader()
DynamicImageSetRotation()
DynamicImageSetTexture()
DynamicImageSetTextureDimensions()
DynamicImageSetTextureScale()
DynamicImageSetTextureSlice()

DynamicImage.SetExtents()
DynamicImage.SetTextureDimensions()
DynamicImage.SetTexture()
DynamicImage.SetTextureSlice()


StatusBarGetCurrentValue()
StatusBarGetMaximumValue()
StatusBarSetCurrentValue()
StatusBarSetMaximumValue()
StatusBarStopInterpolating()


TargetInfo:UnitHealth( "selfhostiletarget" )
TargetInfo:UnitHealth( "selffriendlytarget" )

GameData.Player.hitPoints.current
GameData.Player.hitPoints.maximum

Frame.ClearAnchors()
Frame.CreateFromTemplate()
Frame.Destroy()
Frame.ForceProcessAnchors()
Frame.GetDimensions()
Frame.GetId()
Frame.GetName()
Frame.GetParent()
Frame.GetScale()
Frame.GetUnscaledScreenPosition()
Frame.IsShowing()
Frame.OnMouseOver()
Frame.SetAlpha()
Frame.SetAnchor()
Frame.SetDimensions()
Frame.SetMovable()
Frame.SetParent()
Frame.SetRelativeScale()
Frame.SetScale()
Frame.SetTintColor()
Frame.SetTint()
Frame.Show()






WindowAddAnchor()
WindowAssignFocus()
WindowBatchDraw()
WindowBreakPoint()
WindowClearAnchors()
WindowForceProcessAnchors()
WindowGetAlpha()
WindowGetFontAlpha()
WindowGetHandleInput()
WindowGetId()
WindowGetLayer()
WindowGetMovable()
WindowGetMoving()
WindowGetOffsetFromParent()
WindowGetParent()
WindowGetPopable()
WindowGetResizing()
WindowGetScale()
WindowGetScreenPosition()
WindowGetState()
WindowGetTintColor()
WindowIsGameActionLocked()
WindowRegisterEventHandler()
WindowResizeOnChildren()
WindowSetAlpha()
WindowSetDimensions()
WindowSetFontAlpha()
WindowSetGameActionData()
WindowSetGameActionTrigger()
WindowSetHandleInput()
WindowSetId()
WindowSetLayer()
WindowSetMovable()
WindowSetMoving()
WindowSetOffsetFromParent()
WindowSetParent()
WindowSetPopable()
WindowSetResizing()
WindowSetScale()
WindowSetShowing() - Sets the visibility for Windows
WindowSetTintColor()
WindowSetUpdateFrequency()
WindowStartAlphaAnimation()
WindowStartPositionAnimation()
WindowStartScaleAnimation()
WindowStopAlphaAnimation()
WindowStopPositionAnimation()
WindowStopScaleAnimation()
WindowUnregisterEventHandler()

UnitFrameFriendlyStatusBar.Create()


UnitFrameFriendlyStatusBar.Create()
UnitFrameFriendlyStatusBar.SetBackgroundTint()
UnitFrameFriendlyStatusBar.SetForegroundTint()
UnitFrameFriendlyStatusBar.SetValue()
UnitFrameFriendlyStatusBar.StopInterpolating()
UnitFrameHostileStatusBar.Create()
UnitFrameHostileStatusBar.SetBackgroundTint()
UnitFrameHostileStatusBar.SetForegroundTint()
UnitFrameHostileStatusBar.SetValue()
UnitFrameHostileStatusBar.StopInterpolating()




]]