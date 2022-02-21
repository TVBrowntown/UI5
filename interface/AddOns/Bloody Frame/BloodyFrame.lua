BloodyFrame = {}
BloodyFrameLevel = {0.1, 0.2, 0.3, 0.4, 0.5}

function BloodyFrame.OnInit()
	RegisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "BloodyFrame.SetAlpha")
	--rez
	--dead
	CreateWindowFromTemplate("BloodyFrame", "EA_DynamicImage_DefaultSeparatorRight", "Root")
	WindowClearAnchors("BloodyFrame")
	DynamicImageSetTexture("BloodyFrame", "BloodyFrame", 0, 0)
	DynamicImageSetTextureDimensions("BloodyFrame", 1024, 588)
	WindowSetDimensions("BloodyFrame", 1920, 1080)
	WindowSetScale("BloodyFrame", BloodyFrame.GetResolutionScale())
	WindowSetAlpha("BloodyFrame", 0)
	WindowSetShowing("BloodyFrame", false)
end

function BloodyFrame.SetAlpha()
	if 100 * ( GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum ) <= 10 then
		BFSetAlpha = BloodyFrameLevel[5]
			else
		if 100 * ( GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum )  <= 20 then
			BFSetAlpha = BloodyFrameLevel[4]
		else
			if 100 * ( GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum )  <= 30 then
				BFSetAlpha = BloodyFrameLevel[3]
			else
				if 100 * ( GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum )  <= 40 then
					BFSetAlpha = BloodyFrameLevel[2]
				else
					if 100 * ( GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum )  <= 50 then
						BFSetAlpha = BloodyFrameLevel[1]
					else
						BFSetAlpha = 0
					end
				end
			end
		end
	end
	BloodyFrame.Animate()
end

function BloodyFrame.Shutdown()
	DestroyWindow("BloodyFrame")
end

function BloodyFrame.Test()
	BFSetAlpha = 1
	BloodyFrame.Animate()
end

function BloodyFrame.Clear()
	WindowSetShowing("BloodyFrame", false)
	WindowSetAlpha("BloodyFrame", 0)
	BFSetAlpha = 0
end

function BloodyFrame.Animate()
	--LATER: animates from current alpha value to the new one via 10 steps.
	if BFSetAlpha > 0 then
		WindowSetShowing("BloodyFrame", true)
		WindowSetAlpha("BloodyFrame", BFSetAlpha)
	else
		WindowSetShowing("BloodyFrame", false)
	end
end

function BloodyFrame.GetResolutionScale()
	return ((SystemData.screenResolution.x/1920)+(SystemData.screenResolution.y/1080))/2
	--doesnt work with ultra wide
end