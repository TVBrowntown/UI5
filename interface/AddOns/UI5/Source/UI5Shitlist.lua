UI5.Shitlist = {}

Shitlist = {}
ShitlistSettings = {}
ShitlistSettings.audioNotif = true

d("UI5 : loaded")

local BBplayers = {}
local BBscore = {}

local playerName = wstring.sub(GameData.Player.name,1,-3)
local modType = true
local pointsAmount = 1

local shitThrottle = 3

function UI5.ShitterAlert(targetName, targetClassification)
	for k, v in pairs(Shitlist) do
		if tostring(v) == WStringToString(fixString(targetName)) == true then
			d("Shitter: Found!")
			return true, targetClassification
		end
	end
	return false, targetClassification
end

function UI5.ShitlistSetup()
	LibSlash.RegisterWSlashCmd(L"shitter", function(args1) UI5.Shitlist(args1) end)
	LibSlash.RegisterWSlashCmd(L"noshit", function(args1) UI5.NoShit(args1) end)
	LibSlash.RegisterWSlashCmd(L"shitlist", function(args1) UI5.ExportShitters(args1) end)
	LibSlash.RegisterWSlashCmd(L"clearshitters", function(args1) UI5.ClearShitters() end)
	LibSlash.RegisterWSlashCmd(L"shitters", function(args1) UI5.PrintShitters() end)
end

function UI5.ShitterDraw(targetName, targetClassification)
	if UI5.ShitterAlert(targetName, targetClassification) == true then

		if targetClassification == UI5.isFriend then
			WindowCat = "Friendly"
		else
			WindowCat = "Hostile"
		end

		if DoesWindowExist("Shitter"..WindowCat) then return end
		-- above checks if we already have the shitter window, don't draw it again, fool!
		-- also, it sets the targetclassification and how to draw Window Name and Shitter Window Name

		CreateWindowFromTemplate("Shitter"..WindowCat, "EA_DynamicImage_DefaultSeparatorRight", "Root")
		WindowAddAnchor ("Shitter"..WindowCat, "bottomright", WindowCat.."Avatar", "bottomright", 30, 15)
		DynamicImageSetTexture("Shitter"..WindowCat, "Icon_Shitter", 100, 100)
		DynamicImageSetTextureDimensions("Shitter"..WindowCat, 100, 100)
		WindowSetDimensions("Shitter"..WindowCat, 100, 100)
		WindowSetScale("Shitter"..WindowCat, 0.5 / UI5.UIScale)
		WindowSetParent("Shitter"..WindowCat, WindowCat.."Avatar")
		DynamicImageSetTextureOrientation("Shitter"..WindowCat, true)

		if ShitlistSettings.audioNotif == true and targetHP ~= 0 and (currentEnemyTarget ~= previousEnemyTarget or currentFriendlyTarget ~= previousFriendlyTarget) then 
			PlaySound(215)
			--CustomSound() -- for use with my sideamp for scenario sounds,  
		end
		-- play sound
	else
		if DoesWindowExist("Shitter"..WindowCat) then DestroyWindow("Shitter"..WindowCat) end
	end
end

function UI5.Shitlist(args1)
	if args1 == nil then return end
		--[[
		Shitlist will keep track of players you've deemed jerks. just type /Shitlist <name> to add them
		an image of a turd will appear and can be moved around. if you are using UI5 then you will
		be able to see a turd on top of their class icon.

		if c variable has a space it will be deemed invalid, unless you are removing a shitter.
		]]
	for k, v in pairs(Shitlist) do
		if v == args1 then
			TextLogAddEntry("Chat", 0, L"<icon57> UI5: The shitter, "..StringToWString(tostring(args1))..L", already exists.")
		end
	end
	table.insert(Shitlist, args1)
	d(L"it's confirmed! "..StringToWString(tostring(args1))..L" is now a shitter.")
	TextLogAddEntry("Chat", 0, L"<icon57> UI5: It's confirmed! "..StringToWString(tostring(args1))..L" is a shitter.")
end

function UI5.ExportShitters()
	for k, v in pairs(Shitlist) do
		d(Shitlist[k])
	end
	d("...FINISHED")
end

function UI5.ClearShitters()
	Shitlist = {}
	d("...CLEARED")
end

function UI5.NoShit(args1)
	for k, v in pairs(Shitlist) do
		if tostring(v) == tostring(args1) then
			table.remove(Shitlist, k)
			TextLogAddEntry("Chat", 0, L"<icon57> UI5: "..StringToWString(tostring(args1))..L" ain't no shit no more!")
			return
		end
	end
	TextLogAddEntry("Chat", 0, L"<icon57> UI5: Player not found!")
end

function UI5.PrintShitters()
	TextLogAddEntry("Chat", 0, L"<icon57> UI5: Let's see who is on your shitlist!")
	for k, v in pairs(Shitlist) do
		TextLogAddEntry("Chat", 0, L"<icon57> UI5: "..Shitlist[k]..L"")
	end
	TextLogAddEntry("Chat", 0, L"<icon57> UI5: ...Finished!")
end