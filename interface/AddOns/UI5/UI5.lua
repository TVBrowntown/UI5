UI5 = {}

function decimals(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end

function fixString(str)
	if (str == nil) then return nil end
	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end	
	return str
end

function round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function UI5.CompareString(stringToCompare, stringToCheck)
  local stringBoundary = '%f[%w%p]%'..stringToCompare..'%f[%A]'
  local isMatch = stringToCheck:match(stringBoundary)
  return isMatch
end

function UI5.OnInit()
		RegisterEventHandler(SystemData.Events.ENTER_WORLD, "UI5.GetPlayerInfo")
		RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "UI5.GetPlayerInfo")
		if SplashGFXToggle == true then
			UI5.ActionBG()
		end
		--
		if oldUIMode == true then
			UI5.oldUISetup()
			UI5.WindowDraw(tostring("Player"), wstring.sub(GameData.Player.name,1,-3), playerCareerId)
			RegisterEventHandler(SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "UI5.UpdatePlayerHP")
			RegisterEventHandler(SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED, "UI5.UpdatePlayerHP")
			RegisterEventHandler(SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED, "UI5.UpdatePlayerAP")
			RegisterEventHandler(SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED, "UI5.UpdatePlayerAP")
			UI5.SetupOverheadBars()

		else
			UI5.NewUI()
		end

		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "UI5.TargetUpdate")
		--RegisterEventHandler(SystemData.Events.PLAYER_TARGET_HIT_POINTS_UPDATED, "UI5.TargetEnemyHPUpdate")
		RegisterEventHandler(SystemData.Events.PLAYER_RENOWN_UPDATED, "UI5.RenownUpdate")

		if MechanicToggle == true then
			RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "UI5.BuildMechanics")
			RegisterEventHandler(SystemData.Events.ENTER_WORLD, "UI5.BuildMechanics")
			RegisterEventHandler(SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "UI5.UpdateMechanics")
		end



		if DebugToggle == true then
			RegisterEventHandler(TextLogGetUpdateEventId(SystemData.ChatLogFilters.MISC), "UI5.DEBUG")
			--RegisterEventHandler(SystemData.Events.SOCIAL_FRIENDS_UPDATED, "UI5.Debug")
		end

		if ShitlistToggle == true then
			--call shitlist setup
			UI5.ShitlistSetup()
		end

		if DangerToggle == true then
			--call danger setup
			UI5.DangerSetup()
		end

		if SpellSuggesterToggle == true then
			--call danger setup
			UI5.SpellSuggester()
		end

		if ChallengerDeepToggle == true then
			UI5.ChallengerDeepSetup()
			--challenge log
		end

		if extendedAudioToggle == true then
			UI5.extendedAudioSetup()
			--extended Audio Applet
		end

		if CNCToggle == true then
			-- hides NPC names while in combat
			RegisterEventHandler(SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "UI5.CombatCheck")
		end

		if SoloQueuingToggle == true then 
			-- only ever queue for pug queue because fuck getting smashed by premades. 
			d("not active atm")
		end

		if StatDisplayToggle == true then
			d("display stats")
		end

		if DefensivesToggle == true then
			d("display defensive stats vs your current target")
			-- works from within target update
			-- bones are in but its a bit of work :P
			
		end

		if PeaceOutToggle == true then
			PeaceOut_M.Init()
		end

		if FunLogoutToggle == true then
			-- fun logout
			-- GameData.Player.RvRStats
			RegisterEventHandler(SystemData.Events.LOG_OUT, "UI5.FunStatsLogout")
			RegisterEventHandler(SystemData.Events.EXIT_GAME, "UI5.FunStatsLogout")
		end
	
		TextLogAddEntry("Chat", 0, L"<icon57> UI5, beh-beh!")
		UI5.Fixes()
		UI5.DrawSettingsButtons()
end

function UI5.FunStatsLogout()
	-- GameData.Player.RvRStats
			local LTKs = GameData.Player.RvRStats.LifetimeKills
			local LTDs = GameData.Player.RvRStats.LifetimeDeaths
			local LTDBs = GameData.Player.RvRStats.LifetimeDeathBlows
			local curRenPercentage = (GameData.Player.Renown.curRenownEarned / GameData.Player.Renown.curRenownNeeded) * 100
			-- KDA = (kills + assists) / deaths
			local LTKDA = (LTDBs + (LTKs - LTDBs)) / LTDBs
			TextLogAddEntry("Chat", 0, L"")
			TextLogAddEntry("Chat", 0, L"")
			TextLogAddEntry("Chat", 0, L"<icon57> UI5: Your lifetime KDA is.. "..decimals(LTKDA, 2)..L"!")
			TextLogAddEntry("Chat", 0, L"<icon57> UI5: You are "..decimals(curRenPercentage, 2)..L"% through RR"..GameData.Player.Renown.curRank..L"!")
			if biccestDmg ~= 0 then TextLogAddEntry("Chat", 0, L"<icon57> UI5: Biggest Crit This Session: "..biccestDmg..L"!") else TextLogAddEntry("Chat", 0, L"") end
			TextLogAddEntry("Chat", 0, L"")
			TextLogAddEntry("Chat", 0, L"")
end

function UI5.Debug()
	-- whats going on when someone logs in?
	PlaySound(215)
	TextLogAddEntry("Chat", 0, L"<icon57> UI5: Debug TRIGGERED!")
end

function UI5.ActionBG()
	CreateWindowFromTemplate("UF_ActionBar_BG", "EA_DynamicImage_DefaultSeparatorRight", "Root")
	WindowAddAnchor ("UF_ActionBar_BG", "bottom", "Root", "bottom", 0, 0)
	DynamicImageSetTexture("UF_ActionBar_BG", "UF_AB_BG", 1024, 190)
	WindowSetDimensions("UF_ActionBar_BG", 1024, 190)
	WindowSetScale("UF_ActionBar_BG", .7)
	WindowSetAlpha ("UF_ActionBar_BG", 1)
end

function UI5.NewUI()
	local boxType 		= "Player"
	local frontColor1 = PlayerColour1[1]
	local frontColor2 = PlayerColour1[2]
	local frontColor3 = PlayerColour1[3]
	local box1				= 280 
	local box2 				= 12
	local hasLabel 		= false
	local labAmounts  = 0
	local BosPos			= {10, 10}

	UI5.CreateBox(boxType, frontColor1, frontColor2, frontColor3, box1, box2, hasLabel, labAmounts, BosPos)
	-- creates a window named UI6_PlayerBar

	local boxType 		= "ActionPoints"
	local frontColor1 = RenownColour[1]
	local frontColor2 = RenownColour[2]
	local frontColor3 = RenownColour[3]
	local box1				= 310 
	local box2 				= 12
	local hasLabel 		= false
	local labAmounts  = 0
	local BosPos			= {10, 10}

	UI5.CreateBox(boxType, frontColor1, frontColor2, frontColor3, box1, box2, hasLabel, labelAmounts, labAmounts, BosPos)
	-- creates a window named UI6_ActionPointsBar

--250
	local boxType 		= "Mechanic"
	local frontColor1 = MoraleColour[1]
	local frontColor2 = MoraleColour[2]
	local frontColor3 = MoraleColour[3]
	local box1				= 360 
	local box2 				= 16
	local hasLabel 		= false
	local labAmounts  = 0
	local BosPos			= {10, 10}

	UI5.CreateBox(boxType, frontColor1, frontColor2, frontColor3, box1, box2, hasLabel, labelAmounts, labAmounts, BosPos)

	WindowAddAnchor ("UI6_ActionPointsBar", "top", "UI6_PlayerBar", "bottom", 0, -4)
	d("DONE")
end

function UI5.SetupOverheadBars()
	UI5.DrawOverheadBars("Friendly")
	UI5.DrawOverheadBars("Hostile")
end

function UI5.oldUISetup()
-- UnitFrame Hostile Anchor
	CreateWindow(tostring("TargetUI5_Hostile"), true)
	WindowSetDimensions("TargetUI5_Hostile", 362, 88)
	WindowSetAlpha ("TargetUI5_Hostile", 0)
	LayoutEditor.RegisterWindow ("TargetUI5_Hostile", L"UI5: Hostile", L"TargetUI5_Hostile", false, false, false, nil)

-- UnitFrame Friendly
	CreateWindow(tostring("TargetUI5_Friendly"), true)
	WindowSetDimensions("TargetUI5_Friendly", 362, 88)
	WindowSetAlpha ("TargetUI5_Friendly", 0)
	LayoutEditor.RegisterWindow ("TargetUI5_Friendly", L"UI5: Friendly", L"TargetUI5_Friendly", false, false, false, nil)

-- UnitFrame Player Anchor
	CreateWindow(tostring("TargetUI5_Player"), true)
	WindowSetDimensions("TargetUI5_Player", 362, 88)
	WindowSetAlpha ("TargetUI5_Player", 0)
	LayoutEditor.RegisterWindow ("TargetUI5_Player", L"UI5: Player", L"TargetUI5_Player", false, false, false, nil)

	if DefensivesToggle == true then
		d("display defensive stats vs your current target")
		-- works from within target update
		UI5.DefensivesOnInit()
	end

	UI5.DrawRenownBar()
	UI5.InitializeOverhead()
end

function UI5.TargetDestroyWindows(targetType)
	if DoesWindowExist("UI5_O_HostileFade") then WindowSetAlpha("UI5_O_HostileFade", 0) end
	if DoesWindowExist("UI5_O_FriendlyFade") then WindowSetAlpha("UI5_O_FriendlyFade", 0) end

	if DoesWindowExist("FriendlyMainBar") then DestroyWindow("FriendlyMainBar") end
	if DoesWindowExist("HostileMainBar") then DestroyWindow("HostileMainBar") end
	
	if DoesWindowExist("FriendlyGlow") then DestroyWindow("FriendlyGlow") end
	if DoesWindowExist("HostileGlow") then DestroyWindow("HostileGlow") end

	previousEnemyTarget = nil
	previousFriendlyTarget = nil
end

function UI5.TargetUpdate(targetClassification, targetId, targetType)
	if( targetClassification ~= UI5.isFriend and targetClassification ~= UI5.isFoe ) then
		return
	end

	if ( targetType == SystemData.TargetObjectType.NONE ) then
		UI5.TargetDestroyWindows(targetType)
		UI5.ResetFadeBars()
		return
	end

	TargetInfo:UpdateFromClient()
	local targetName 	= TargetInfo:UnitName(targetClassification)
	local careerId 		= TargetInfo:UnitCareer(targetClassification)
	local targetHP 		= TargetInfo:UnitHealth(targetClassification)
	local guID 				= TargetInfo:UnitEntityId(targetClassification)

	if targetClassification == UI5.isFriend then
		WindowCat = "Friendly"
		currentFriendlyTarget = targetName
	else
		currentEnemyTarget = targetName
	 	WindowCat = "Hostile"
	end

	if oldUIMode == true then

		if DoesWindowExist(WindowCat.."MainBar") == false then
			UI5.WindowDraw(WindowCat, targetName, targetClassification)
		end
		UI5.UpdateHP(targetHP, WindowCat, targetName, careerId)
		
		--shitter check only on new target
		if targetClassification == UI5.isFriend then
			if previousFriendlyTarget ~= targetName then
				UI5.ShitterDraw(targetName, targetClassification, WindowCat)
			end
			--check shitter once on new target
			previousFriendlyTarget = targetName
		else
			if previousEnemyTarget ~= targetName then
				UI5.ShitterDraw(targetName, targetClassification, WindowCat)
			end
			--check shitter once on new target
			previousEnemyTarget = targetName
		end

		--set defensive stats if defensivetoggle is on
		if targetClassification == UI5.isFoe and DefensivesToggle == true then
			--call function to update/draw defensive stats
			UI5.DefensivesUpdate(careerId)
		end

	else
		-- THIS IS ALL NEW MODE
		d("NEW MODE IS ON, BUT I'M DOING NOTHING")
	end

	UI5.UpdateOverhead(targetHP, WindowCat, targetName, careerId, guID)

end

function UI5.DebugResources()
	-- this stupid function triggers twice sometimes and wipes your shit randomly.
	-- seriously, wtf mythic?
	-- so it'll send you the old value,. as the new one, and then the new value
	-- this means you can't really track the previous resource since it'll always wipe it.
	-- some seriously dumb shit.

	d("Current Resources: "..CareerResourceData:GetCurrent())
	d("Maximum Resources: "..CareerResourceData:GetMaximum())
end

function UI5.OnShutdown()

end

function UI5.TestBox()
	if DoesWindowExist("UI6_TestBar") then
		LayoutEditor.UnregisterWindow("UI6_TestBar", "UI6_TestBar", "UI6_TestBar", false, false, true, nil) 
		DestroyWindow("UI6_TestBar") 
	end

	local boxType 		= "Test"
	local frontColor1 = math.random(0,255)
	local frontColor2 = math.random(0,255)
	local frontColor3 = math.random(0,255)
	local box1				= 280 
	local box2 				= 100
	local hasLabel 		= false
	local labAmounts  = 3
	local BosPosX			= 0
	local BoxPosY			= 0
	
	UI5.CreateBox(boxType, frontColor1, frontColor2, frontColor3, box1, box2, hasLabel, labelAmounts, labAmounts, BosPosX, BoxPosY)
end