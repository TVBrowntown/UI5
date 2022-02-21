LibConfig = LibStub("LibConfig")

WoHReticle = {}

DEFAULTSETTINGS = {
	version = 1.1,
	FriendlyReticle = { enabled = true,
						scale = 1,
						alpha = 1,
						dx = 0,
						dy = -10,
					},
	EnemyReticle =	{ enabled = true,
						scale = 1,
						alpha = 1,
						dx = 0,
						dy = -10,
						},
					}

local cur_eid = nil
local cur_fid = nil
local GUI
local RotateFactor = 25

function WoHReticle.OnUpdate(timeElapsed)
	if WoHReticle.RotateTimer <= 360 then
		WoHReticle.RotateTimer = WoHReticle.RotateTimer + (timeElapsed * RotateFactor)
	else
		WoHReticle.RotateTimer = 0
	end

	for unit, _ in pairs(WoHReticle.Settings) do
		if (unit ~= "version") then
			DynamicImageSetRotation(unit, WoHReticle.RotateTimer)
		end
	end 
end

function WoHReticle.CreateRing(ring)
	anchor = ring.."Anchor"
	settings = WoHReticle.Settings[ring]

	if (DoesWindowExist(anchor)) then
		DestroyWindow(ring)
	else
		CreateWindowFromTemplate(anchor, "EA_DynamicImage_DefaultSeparatorRight", "Root")
		WindowSetDimensions(anchor, 1, 1)
	end
	
	CreateWindowFromTemplate(ring, "EA_DynamicImage_DefaultSeparatorRight", anchor)
	WindowClearAnchors(ring)
	WindowAddAnchor(ring, "top", anchor, "top", settings.dx, settings.dy)
	DynamicImageSetTexture(ring, "Reticle", 0, 0)
	DynamicImageSetTextureDimensions(ring, 256, 256)
	WindowSetDimensions(ring,100,100)
	WindowSetScale(ring, settings.scale)
	WindowSetAlpha(ring, settings.alpha)
	WindowSetShowing(ring, false)
end

function WoHReticle.Recreate()
	for unit, _ in pairs(WoHReticle.Settings) do
		if (unit ~= "version") then
			WoHReticle.CreateRing(unit)
		end
	end 
end

function WoHReticle.Initialize()

	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "WoHReticle.UpdateTargets")
	
	LibSlash.RegisterSlashCmd("wohreticle",function(msg) WoHReticle.Slash(msg) end)
	
	if (not WoHReticle.Settings) then
		WoHReticle.Settings = DEFAULTSETTINGS
	elseif (WoHReticle.Settings.version ~= DEFAULTSETTINGS.version) then
		WoHReticle.Settings = DEFAULTSETTINGS
	end
	
	WoHReticle.RotateTimer = 0
	WoHReticle.Recreate()
end

function WoHReticle.Slash(msg)
	if (not GUI) then
		GUI = LibConfig("WoHReticle Settings", WoHReticle.Settings, true, WoHReticle.Recreate)

		for unit, _ in pairs(WoHReticle.Settings) do
			if (unit ~= "version") then
				GUI:AddTab(unit)
				GUI("checkbox", "enabled", {unit, "enabled"})
				GUI("textbox", "scale", {unit, "scale"}, function(i) return math.max(math.min(i, 10), 0.1) end)
				GUI("textbox", "alpha", {unit, "alpha"})
				GUI("textbox", "x offset", {unit, "dx"})
				GUI("textbox", "y offset", {unit, "dy"})
			end
		end
	end
	
	GUI:Show()
end

function WoHReticle.UpdateTargets()
	TargetInfo:UpdateFromClient()
	local fid = TargetInfo:UnitEntityId("selffriendlytarget")
	local fcolor = TargetInfo:UnitRelationshipColor("selffriendlytarget")
	if (fid ~= cur_fid) then
		if (cur_fid) then
			DetachWindowFromWorldObject("FriendlyReticleAnchor", cur_fid)
		end
		WindowSetShowing("FriendlyReticle",false)
		if (fid > 0 and fid ~= GameData.Player.worldObjNum) then
			MoveWindowToWorldObject("FriendlyReticleAnchor",fid,1)
			AttachWindowToWorldObject("FriendlyReticleAnchor",fid)
			if (WoHReticle.Settings.FriendlyReticle.enabled) then
				WindowSetTintColor("FriendlyReticle", fcolor.r, fcolor.g, fcolor.b)
				WindowSetShowing("FriendlyReticle",true)
			else
				WindowSetShowing("FriendlyReticle",false)
			end
		end
		cur_fid = fid
	end

	local eid = TargetInfo:UnitEntityId("selfhostiletarget")
	local ecolor = TargetInfo:UnitRelationshipColor("selfhostiletarget")
	if (eid ~= cur_eid) then
		if (cur_eid) then
			DetachWindowFromWorldObject("EnemyReticleAnchor", cur_eid)
		end
		WindowSetShowing("EnemyReticle",false)
		if (eid > 0) then
			MoveWindowToWorldObject("EnemyReticleAnchor",eid,1)
			AttachWindowToWorldObject("EnemyReticleAnchor",eid)
			if (WoHReticle.Settings.EnemyReticle.enabled) then
				WindowSetTintColor("EnemyReticle", ecolor.r, ecolor.g, ecolor.b)
				WindowSetShowing("EnemyReticle",true)
			else
				WindowSetShowing("EnemyReticle",false)
			end
		end
		cur_eid = eid
	end

end
