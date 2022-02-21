UI5TargetEnemyHP = {}

local UnitWidth = 210 --310
local UnitHeight = 40 --80
local UnitBuffer = 4
local InnerBarWidth = UnitWidth - UnitBuffer
local InnerBarHeight = UnitHeight - UnitBuffer
local UFrontColour	= {210, 210, 210}

local towstring = towstring

function UI5.WindowDraw(WindowCat, targetName, targetClassification)
	TargetInfo:UpdateFromClient()
--[[

	Draws all Windows but doesn't update HP, Name, Icons, Danger level or Shitter status.

]]
	if targetClassification == UI5.isFoe then
		UIanchor = "topright"
	else
		UIanchor = "topleft"
	end

	for k, v in pairs(UI5.WinNames) do
		if UIanchor == "topright" then
			if UI5.WinOffsetsY[k] < 0 then 
				UI5.WinOffsetsY[k] = UI5.WinOffsetsY[k] * -1
			else
				UI5.WinOffsetsY[k] = UI5.WinOffsetsY[k] * 1
			end
			if UI5.WinOffsetsX[k] < 0 then 
				UI5.WinOffsetsX[k] = UI5.WinOffsetsX[k] * -1
			else
				UI5.WinOffsetsX[k] = UI5.WinOffsetsX[k] * 1
			end
		end

		if UIanchor == "topleft" then
			UI5.WinOffsetsY[k] = UI5.WinOffsetsY[k]
			UI5.WinOffsetsX[k] = UI5.WinOffsetsX[k]
		end
		-- above inverts the dimensions, etc so that the frame mirrors correctly
		CreateWindowFromTemplate(WindowCat..UI5.WinNames[k], "EA_DynamicImage_DefaultSeparatorRight", "Root")
		if k == 2 and UIanchor == "topright" then
			WindowAddAnchor (WindowCat..UI5.WinNames[k], UIanchor, "TargetUI5_"..WindowCat, UIanchor, -82, UI5.WinOffsetsY[k])
		else
			WindowAddAnchor (WindowCat..UI5.WinNames[k], UIanchor, "TargetUI5_"..WindowCat, UIanchor, UI5.WinOffsetsX[k], UI5.WinOffsetsY[k])
		end
		-- because the HPBar texture is wack this does an extra correct - bit lame.

		DynamicImageSetTexture(WindowCat..UI5.WinNames[k], UI5.WinTextures[k], UI5.FramesX[k], UI5.FramesY[k])
		WindowSetDimensions(WindowCat..UI5.WinNames[k], UI5.FramesX[k], UI5.FramesY[k])
		WindowSetScale(WindowCat..UI5.WinNames[k], UI5.WinScales[k] / UI5.UIScale)
		if targetClassification == UI5.isFoe then 
			DynamicImageSetTextureOrientation(WindowCat..UI5.WinNames[k], true)
			AoffsetX = 16
		else
			DynamicImageSetTextureOrientation(WindowCat..UI5.WinNames[k], false)
			AoffsetX = -16
		end
		if UI5.WinNames[k] ~= "MainBar" then WindowSetParent(WindowCat..UI5.WinNames[k], WindowCat.."MainBar") end
	end

		if DoesWindowExist(WindowCat.."AvatarFrame") == false then CreateWindowFromTemplate(WindowCat.."AvatarFrame", WindowCat.."AvatarFrame", WindowCat.."MainBar") end
		if DoesWindowExist(WindowCat.."Avatar") == false then CreateWindowFromTemplate(WindowCat.."Avatar", WindowCat.."Avatar", WindowCat.."MainBar") end
		
		WindowSetScale(WindowCat.."Avatar", .475 / UI5.UIScale)
		WindowSetScale(WindowCat.."AvatarFrame", .475 / UI5.UIScale)

		WindowClearAnchors(WindowCat.."AvatarFrame")
		WindowAddAnchor(WindowCat.."AvatarFrame", UIanchor, "TargetUI5_"..WindowCat, UIanchor, AoffsetX, 14)

		WindowSetParent(WindowCat.."Avatar", WindowCat.."MainBar")
		WindowSetParent(WindowCat.."AvatarFrame", WindowCat.."MainBar")

		--[[

			GLOW FRAME

		]]


	-- UnitFrame Name
	if targetName == wstring.sub(GameData.Player.name,1,-3) then
		-- setups up the player specific stuff

		-- UnitFrame AP bar
		CreateWindowFromTemplate(WindowCat.."APBar", "EA_DynamicImage_DefaultSeparatorRight", "Root")
		WindowAddAnchor (WindowCat.."APBar", UIanchor, "TargetUI5_"..WindowCat, UIanchor, 98, 68)
		DynamicImageSetTexture(WindowCat.."APBar", "UF_Bars_SecondaryBar", 512, 43)
		WindowSetDimensions(WindowCat.."APBar", 512, 43)
		WindowSetScale(WindowCat.."APBar", .5 / UI5.UIScale)
		WindowSetTintColor(WindowCat.."APBar", APColour[1], APColour[2], APColour[3])
		WindowSetParent(WindowCat.."APBar", WindowCat.."MainBar")

		-- UnitFrame AP Text
		CreateWindowFromTemplate(WindowCat.."APText", "PlayerBotText", "TargetUI5_"..WindowCat)
		LabelSetFont(WindowCat.."APText", "font_journal_small_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
		LabelSetText(WindowCat.."APText", L"100%")
		WindowSetParent(WindowCat.."APText", WindowCat.."MainBar")
	else
		-- not player, so needs a name instead of AP
		CreateWindowFromTemplate(WindowCat.."Name", WindowCat.."BotText", "TargetUI5_"..WindowCat)
		LabelSetFont(WindowCat.."Name", "font_journal_small_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
		LabelSetText(WindowCat.."Name", towstring(targetName))
		WindowSetParent(WindowCat.."Name", WindowCat.."MainBar")
		--WindowAddAnchor (WindowCat.."Name", UIanchor, "TargetUI5_"..WindowCat, UIanchor, -115, 72)
		--WindowAddAnchor (WindowCat.."Name", UIanchor, "TargetUI5_"..WindowCat, UIanchor, -215, 72)
	end
	
	-- UnitFrame HP
	CreateWindowFromTemplate(WindowCat.."HPText", WindowCat.."TopText", "TargetUI5_"..WindowCat)
	LabelSetFont(WindowCat.."HPText", "font_journal_small_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetText(WindowCat.."HPText", L"100%")
	WindowSetParent(WindowCat.."HPText", WindowCat.."MainBar")
	-- UnitFrame Danger Anims
--[[
	if DoesWindowExist(WindowCat.."Glow") == false then
		CreateWindowFromTemplate(WindowCat.."Glow", "DangerGlow"..WindowCat, "Root")
	else
		DestroyWindow(WindowCat.."Glow")
		CreateWindowFromTemplate(WindowCat.."Glow", "DangerGlow"..WindowCat, "Root")
	end
	]]
--[[
	if DangerToggle == true then
		local dangerScore = UI5.DangerSilentCheck(targetName)
		UI5.DrawGlow(WindowCat, dangerScore)
	end
]]
	WindowStartAlphaAnimation(WindowCat.."MainBar", Window.AnimationType.SINGLE, 0, 1, .20, false, 0, 0)
end


function UI5.UpdateHP(targetHP, WindowCat, targetName, careerId, targetClassification)
-- set career icon ------ 
	if careerId ~= 0 then
		DynamicImageSetTexture(WindowCat.."Avatar", UI5.CareerIdToHDIcon[careerId], 64, 64)
		DynamicImageSetTextureDimensions(WindowCat.."Avatar", 64, 64)
	end

	if DoesWindowExist(WindowCat.."MainBar") then
		local hpBar = (targetHP / 100) * 512
		--healthWidth gets the percent of HP left
		--hpBar gets the pixelswidth that hp is equal to
		if hpBar > 512 then
			hpBar = 512
		end

		if hpBar < 0 then
			hpBar = 0
		end

		WindowSetDimensions(WindowCat.."HPBar", hpBar, 48)
		LabelSetText(WindowCat.."HPText", round(targetHP)..L"%")
		-- update hp text
		if WindowCat ~= "Player" then 
			LabelSetText(WindowCat.."Name", targetName)
		end
	end

	if DangerToggle == true then
		local dangerScore = UI5.DangerSilentCheck(targetName)
		UI5.DrawGlow(WindowCat, dangerScore)
	end
end