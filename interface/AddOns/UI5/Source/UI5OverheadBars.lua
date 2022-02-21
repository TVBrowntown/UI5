LibConfig = LibStub("LibConfig")

UI5.OverheadBars = {}

FriendlyFadeAnim = false
HostileFadeAnim = false

DEFAULTSETTINGS = {
	version = 1.1,
	Friendly 	= { enabled = true,
						scale = 1,
						alpha = 1,
						dx = 0,
						dy = -10,
					},
	Hostile 	= { enabled = true,
						scale = 1,
						alpha = 1,
						dx = 0,
						dy = -10,
						},
					}

local cur_eid = nil
local cur_fid = nil
local prevFadeAlpha

function UI5.CreateRing(ring)

	anchor = ring.."Anchor"
	settings = UI5.Settings[ring]

	if (DoesWindowExist(anchor)) then
		DestroyWindow(ring)
	else
		CreateWindowFromTemplate(anchor, "EA_DynamicImage_DefaultSeparatorRight", "Root")
		WindowSetDimensions(anchor, 1, 1)
	end

end

function UI5.Recreate()
	for unit, _ in pairs(UI5.Settings) do
		if (unit ~= "version") then
			UI5.CreateRing(unit)
		end
	end 
end

function UI5.InitializeOverhead()

	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "UI5.UpdateTargets")
	
	LibSlash.RegisterSlashCmd("UI5",function(msg) UI5.Slash(msg) end)
	
	if (not UI5.Settings) then
		UI5.Settings = DEFAULTSETTINGS
	elseif (UI5.Settings.version ~= DEFAULTSETTINGS.version) then
		UI5.Settings = DEFAULTSETTINGS
	end
	
	UI5.RotateTimer = 0
	UI5.Recreate()
end

function UI5.UpdateTargets()
	TargetInfo:UpdateFromClient()
	local fid = TargetInfo:UnitEntityId("selffriendlytarget")
	local fcolor = TargetInfo:UnitRelationshipColor("selffriendlytarget")

	if (fid ~= cur_fid) then
		if (cur_fid) then
			DetachWindowFromWorldObject("UI5_O_Friendly", cur_fid)
		end
		WindowSetShowing("UI5_O_Friendly",false)
		--
		if (fid > 0 and fid ~= GameData.Player.worldObjNum) then
			MoveWindowToWorldObject("UI5_O_Friendly",fid,1)
			AttachWindowToWorldObject("UI5_O_Friendly",fid)
		end
		cur_fid = fid
	end

	local eid = TargetInfo:UnitEntityId("selfhostiletarget")
	local ecolor = TargetInfo:UnitRelationshipColor("selfhostiletarget")
	if (eid ~= cur_eid) then
		if (cur_eid) then
			DetachWindowFromWorldObject("UI5_O_Hostile", cur_eid)
		end
		WindowSetShowing("UI5_O_Hostile",false)
		--
		if (eid > 0) then
			MoveWindowToWorldObject("UI5_O_Hostile",eid,1)
			AttachWindowToWorldObject("UI5_O_Hostile",eid)
		end
		cur_eid = eid
	end

end

function UI5.UpdateOverhead(targetHP, WindowCat, targetName, careerId, guID)
	--update HPbar of box
	local prevTargetName
	local prevGUID

	if DoesWindowExist("UI5_O_"..WindowCat.."Fill") then

		if careerId ~= 0 then
			DynamicImageSetTexture(WindowCat.."AvatarHUD", UI5.CareerIdToHDIcon[careerId], 64, 64)
			WindowSetScale(WindowCat.."AvatarHUD", 0.275)	
		else
			-- will need to do a thing for npcs	
			WindowSetScale(WindowCat.."AvatarHUD", 0.001)
		end

		local hpBar = hpBar

		hpBar = (targetHP / 100) * 150 - 10

		if hpBar > (150 - 10) then
			hpBar = 150 - 10
		end

		if hpBar < 0 then
			hpBar = 0
		end

		WindowSetDimensions("UI5_O_"..WindowCat.."Fill", hpBar, 14 - 6)

		local AnimWindowAlpha = WindowGetAlpha("UI5_O_"..WindowCat.."Fade")
		if AnimWindowAlpha == 0 then
			WindowSetDimensions("UI5_O_"..WindowCat.."Fade", hpBar, 14 - 6)
			WindowSetAlpha("UI5_O_"..WindowCat.."Fade", 1)
		elseif AnimWindowAlpha == 1 then
			WindowStopAlphaAnimation("UI5_O_"..WindowCat.."Fade")
			WindowStartAlphaAnimation("UI5_O_"..WindowCat.."Fade", Window.AnimationType.SINGLE_NO_RESET, 0.99, 0, 2, false, 0, 0)
		end	

		local prevTargetName = targetName
		if targetHP == 0 then
			WindowSetAlpha("UI5_O_"..WindowCat.."Fade", 0)
		end
	end
end

function UI5.ResetFadeBars()
	HostileFadeAnim = false
	FriendlyFadeAnim = false
end

function UI5.fadeBarLogic(WindowCat)
	if WindowCat == "Hostile" then
		HostileFadeAnim = true
	elseif WindowCat == "Friendly" then
		FriendlyFadeAnim = true
	end
end

function UI5.DrawOverheadBars(WindowCat)

	local oBarColor = {}

	if WindowCat == "Hostile" then
		oBarColor = ChipColour
		fColor = {80, 0, 15}
	else
		oBarColor = ReadyColour
		fColor = {0, 90, 0}
	end

	fColor = {255, 240, 0}		-- temp so i can fkn see

-- Anchor
	CreateWindow("UI5_O_"..WindowCat, true)
	WindowSetDimensions("UI5_O_"..WindowCat, 1, 1)
	WindowSetScale("UI5_O_"..WindowCat, 0.001)
	--CreateWindowFromTemplate("UI5_O_"..WindowCat, "CastBar_BG_UI5", "Root") -- CastBar_BG_UI5
	--WindowAddAnchor ("UI5_O_"..WindowCat", "center", "Root", "center", 0, 0)
	--DynamicImageSetTexture("UI5_O_"..WindowCat, solidBlack[1], solidBlack[2], solidBlack[3])

	--DynamicImageSetTexture("UI5_O_"..WindowCat, "CastBar_BG_UI5", 512, 80)
	CreateWindowFromTemplate("UI5_O_"..WindowCat.."Bar", "EA_FullResizeImage_TintableSolidBackground", "UI5_O_"..WindowCat)
	WindowSetDimensions("UI5_O_"..WindowCat.."Bar", 150, 14) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetAlpha("UI5_O_"..WindowCat.."Bar", 1)
	WindowSetTintColor("UI5_O_"..WindowCat.."Bar", 0, 0, 0)
	WindowAddAnchor ("UI5_O_"..WindowCat.."Bar", "center", "UI5_O_"..WindowCat, "center", 0, 0)
	--WindowSetMovable("UI6_O_"..WindowCat", true)
-- BG
--[[
	CreateWindow("UI5_O_"..WindowCat.."", true)
	--WindowAddAnchor ("UI5_O_"..WindowCat", "center", "Root", "center", 0, 0)
	--DynamicImageSetTexture("UI5_O_"..WindowCat, solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI5_O_"..WindowCat.."", 150, 14) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	--WindowSetAlpha("UI5_O_"..WindowCat, 0.01)
	WindowSetTintColor("UI5_O_"..WindowCat.."", BGColour[1], BGColour[2], BGColour[3])
]]

-- UnitFrame Flare

	CreateWindowFromTemplate("UI5_O_"..WindowCat.."Flare", "EA_DynamicImage_DefaultSeparatorRight", "UI5_O_"..WindowCat)
	--WindowAddAnchor ("UI5_O_"..WindowCat.."Flare", "topleft", "UI5_O_"..WindowCat.."Bar", "topleft", 0, 0)
	WindowClearAnchors("UI5_O_"..WindowCat.."Flare")
	WindowAddAnchor ("UI5_O_"..WindowCat.."Flare", "center", "UI5_O_"..WindowCat, "center", 0, 0)
	DynamicImageSetTexture("UI5_O_"..WindowCat.."Flare", "Nameplate_Background", 487, 79)
	--DynamicImageSetTextureDimensions("UI5_O_"..WindowCat.."Flare", "Nameplate_Background", 212, 68) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetDimensions("UI5_O_"..WindowCat.."Flare", 487, 79)
	WindowSetScale("UI5_O_"..WindowCat.."Flare", .27)
	WindowSetParent("UI5_O_"..WindowCat.."Flare", "UI5_O_"..WindowCat)

-- UnitFrame EXP Fill_BG
	CreateWindowFromTemplate("UI5_O_"..WindowCat.."BG", "EA_FullResizeImage_TintableSolidBackground", "UI5_O_"..WindowCat)
	WindowAddAnchor ("UI5_O_"..WindowCat.."BG", "center", "UI5_O_"..WindowCat.."Bar", "center", 0, 0)
	--DynamicImageSetTexture("UI5_O_"..WindowCat.."BG", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI5_O_"..WindowCat.."BG", 150 - 10, 14 - 6) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI5_O_"..WindowCat.."BG", "UI5_O_"..WindowCat)
	WindowSetTintColor("UI5_O_"..WindowCat.."BG", GreyColour[1], GreyColour[2], GreyColour[3])
-- UnitFrame EXP Fade
	CreateWindowFromTemplate("UI5_O_"..WindowCat.."Fade", "EA_FullResizeImage_TintableSolidBackground", "Root")
	WindowAddAnchor ("UI5_O_"..WindowCat.."Fade", "topleft", "UI5_O_"..WindowCat.."BG", "topleft", 0, 0)
	WindowSetDimensions("UI5_O_"..WindowCat.."Fade", 150 - 10, 14 - 6) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI5_O_"..WindowCat.."Fade", "UI5_O_"..WindowCat)
	WindowSetTintColor("UI5_O_"..WindowCat.."Fade", fColor[1], fColor[2], fColor[3])
-- UnitFrame EXP Fill
	CreateWindowFromTemplate("UI5_O_"..WindowCat.."Fill", "EA_FullResizeImage_TintableSolidBackground", "Root")
	WindowAddAnchor ("UI5_O_"..WindowCat.."Fill", "topleft", "UI5_O_"..WindowCat.."BG", "topleft", 0, 0)
	--DynamicImageSetTexture("UI5_O_"..WindowCat.."Fill", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI5_O_"..WindowCat.."Fill", 150 - 10, 14 - 6) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI5_O_"..WindowCat.."Fill", "UI5_O_"..WindowCat)
	WindowSetTintColor("UI5_O_"..WindowCat.."Fill", oBarColor[1], oBarColor[2], oBarColor[3])
	-- FLASH FRAME
	CreateWindowFromTemplate("UI5_O_"..WindowCat.."Flash", "EA_FullResizeImage_TintableSolidBackground", "UI5_O_"..WindowCat)
	WindowSetDimensions("UI5_O_"..WindowCat.."Flash", 150, 14) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetAlpha("UI5_O_"..WindowCat.."Flash", 0)
	WindowSetTintColor("UI5_O_"..WindowCat.."Flash", 255, 255, 255)
	WindowAddAnchor ("UI5_O_"..WindowCat.."Flash", "center", "UI5_O_"..WindowCat, "center", 0, 0)
-- UnitFrame LAYER settings
	WindowSetLayer("UI5_O_"..WindowCat, Window.Layers.POPUP)
	WindowSetLayer("UI5_O_"..WindowCat.."Bar", Window.Layers.POPUP)
	WindowSetLayer("UI5_O_"..WindowCat.."Flare", Window.Layers.POPUP)
	WindowSetLayer("UI5_O_"..WindowCat.."BG", Window.Layers.POPUP)
	WindowSetLayer("UI5_O_"..WindowCat.."Fade", Window.Layers.POPUP)
	WindowSetLayer("UI5_O_"..WindowCat.."Fill", Window.Layers.POPUP)
	WindowSetLayer("UI5_O_"..WindowCat.."Flash", Window.Layers.POPUP)
--
	if DoesWindowExist(WindowCat.."AvatarFrameHUD") == false then 
		CreateWindowFromTemplate(WindowCat.."AvatarFrameHUD", WindowCat.."AvatarFrame", "UI5_O_"..WindowCat.."BG") 
	end

	if DoesWindowExist(WindowCat.."AvatarHUD") == false then 
		CreateWindowFromTemplate(WindowCat.."AvatarHUD", WindowCat.."Avatar", "UI5_O_"..WindowCat.."BG") 
	end
	
	WindowSetDimensions(WindowCat.."AvatarHUD", 64, 64)

	WindowSetScale(WindowCat.."AvatarHUD", 0.125)
	WindowSetScale(WindowCat.."AvatarFrameHUD", 0.125)	
	WindowClearAnchors(WindowCat.."AvatarFrameHUD")
	WindowClearAnchors(WindowCat.."AvatarHUD")

	WindowAddAnchor(WindowCat.."AvatarFrameHUD", "left", "UI5_O_"..WindowCat.."BG", "right", -4, 0)
	WindowAddAnchor(WindowCat.."AvatarHUD", "center", WindowCat.."AvatarFrameHUD", "center", 0, 0)
	WindowSetParent(WindowCat.."AvatarHUD", "UI5_O_"..WindowCat.."BG")
	WindowSetParent(WindowCat.."AvatarFrameHUD", "UI5_O_"..WindowCat.."BG")
end