	if not teather then teather = {} end
		
	local Version = 1.2
	local DriftTimer = 0
	local UIScale = InterfaceCore.GetScale()
    local ResolutionScale = InterfaceCore.GetResolutionScale()	
	local GlobalScale = SystemData.Settings.Interface.globalUiScale	
	local ScreenWidthX,ScreenHeightY = GetScreenResolution()	
	local LineLength = 60
	local OffLineLength = 60
	local NumberLines = 0
	local MaxLines = ((((ScreenWidthX+ScreenHeightY/2)/ResolutionScale)/GlobalScale)/LineLength)/2	
	local OffMaxLines = ((((ScreenWidthX+ScreenHeightY/2)/ResolutionScale)/GlobalScale)/OffLineLength)/2		
	local ObjecOffset = 1
	local LatestDir,LatestDir2,LatestDir3
	local G_Range_Out = "Close"
	local G_Range_In = "Close"
	
	
	local GUARDED_APPLY_ID = 1			--when another player add guard to you
	local GUARDED_REMOVE_ID = 2			--when another players guard removes from you
	local GUARDING_APPLY_ID = 3			--when you add guard to another player
	local GUARDING_REMOVE_ID = 4			--when your guard removes from another player
		
	local GuardTexture = {[true]="XGuardLine",[false]="TeatherLine"}
	local GuardIcons = {["Close"]="GuardIcon",["Mid"]="DistantIcon",["Far"]="DistantIcon",["Distant"]="DistantIcon"}	
	
	local TexturePack
	
function teather.init()
	if not teather.Settings or (teather.Settings.version < Version) then teather.ResetSettings() end


	TexturePack = teather.Settings.TexturePack
	
	SelfID = GameData.Player.worldObjNum
	CreateWindow("TeatherSelfWindow", false)
	CreateWindow("TeatherTargetWindow", false)
	CreateWindow("TeatherOffGuardSelfWindow", false)
	CreateWindow("TeatherOffGuardTargetWindow", false)

	LayoutEditor.RegisterWindow( "TeatherSelfWindow", L"Teather Window", L"Teather Window", false, false, false)
	LayoutEditor.RegisterEditCallback(teather.OnLayoutEditorFinished)
		
	IsTeathered = 0.1
	IsTeatheredOffGuard = 0.1	
	NumberOfGuards = 0	
	for i=1,MaxLines do	
		CreateWindowFromTemplate("TeatherLine"..i, "LineTemplate", "TeatherSelfWindow")	

		WindowSetShowing("TeatherLine"..i.."Line",true)
		WindowSetAlpha("TeatherLine"..i.."Line",0)
		
		
		CreateWindowFromTemplate("TeatherOffGuardLine"..i, "LineTemplate2", "TeatherOffGuardSelfWindow")	

		WindowSetShowing("TeatherOffGuardLine"..i.."Line",true)
		WindowSetAlpha("TeatherOffGuardLine"..i.."Line",0)	


	DynamicImageSetTexture("TeatherLine"..i.."Line",TexturePack.."_TeatherLine", 0,0)						

	DynamicImageSetTexture("TeatherOffGuardLine"..i.."Line",TexturePack.."_TeatherLine2", 0,0)						

		
	end	

	CreateWindowFromTemplate("TeatherLineEnd", "ArrowTemplate", "Root")	
	CreateWindowFromTemplate("TeatherLineStart", "ArrowTemplate", "Root")	
	
	CreateWindowFromTemplate("TeatherOffGuardLineEnd", "ArrowTemplate", "Root")	
	CreateWindowFromTemplate("TeatherOffGuardLineStart", "ArrowTemplate", "Root")	

	local texture, x, y, disabledTexture = GetIconData(tonumber(80))
	CircleImageSetTexture( "TeatherOffGuardTargetWindowIcon", "GuardIcon", 32, 32 )
	CircleImageSetTexture( "TeatherOffGuardSelfWindowIcon", "GuardIcon", 32, 32 )	

	UIScale = InterfaceCore.GetScale()
    ResolutionScale = InterfaceCore.GetResolutionScale()	
	GlobalScale = SystemData.Settings.Interface.globalUiScale	
	ScreenWidthX,ScreenHeightY = GetScreenResolution()	
	LineLength = 60
	OffLineLength = 60
	MaxLines = ((((ScreenWidthX+ScreenHeightY/2)/ResolutionScale)/GlobalScale)/LineLength)/2	
	OffMaxLines = ((((ScreenWidthX+ScreenHeightY/2)/ResolutionScale)/GlobalScale)/OffLineLength)/2	
	ObjecOffset = 1
	LatestDir = math.random(360)
	LatestDir2 = math.random(360)
	LatestDir3 = math.random(360)	
	teather.TargetID = 0
	teather.TargetName = L""
	teather.TargetInfo = {}
	teather.OffGuardID = 0
	teather.OffGuardName = L""
	teather.ClosestOffGuardID = 0
	teather.ClosestOffGuardName = L""
	
	WindowSetShowing("TeatherSelfWindow",false)
	WindowSetShowing("TeatherTargetWindow",false)		
	WindowSetShowing("TeatherOffGuardTargetWindow",false) 
	WindowSetShowing("TeatherOffGuardSelfWindow",false) 
	
	if LibGuard then 
		LibGuard.Register_Callback(teather.Libguard_Toggle)		
	end
	if LibSlash then
		LibSlash.RegisterSlashCmd("teather", function(input) teather.Command(input) end)
	end
	
	AnimatedImageStartAnimation ("TeatherSelfWindowGlow", 0, true, true, 0)	
	AnimatedImageStartAnimation ("TeatherTargetWindowGlow", 0, true, true, 0)		
	
	WindowSetScale("TeatherSelfWindow",UIScale*1.2)
	WindowSetScale("TeatherTargetWindow",UIScale*1.2)	
	WindowSetScale("TeatherLineEndLine",UIScale*1.2)
	WindowSetScale("TeatherLineStartLine",UIScale*1.2)

	WindowSetScale("TeatherOffGuardSelfWindowCircle",UIScale*0.8)
	WindowClearAnchors( "TeatherOffGuardSelfWindowCircle" )
	WindowAddAnchor( "TeatherOffGuardSelfWindowCircle" , "topleft", "TeatherOffGuardSelfWindow", "topleft", 7,7)	
	
	WindowSetScale("TeatherOffGuardSelfWindowIcon",UIScale*0.8)
	WindowClearAnchors( "TeatherOffGuardSelfWindowIcon" )
	WindowAddAnchor( "TeatherOffGuardSelfWindowIcon" , "topleft", "TeatherOffGuardSelfWindow", "topleft", 19,19)			
		
	WindowSetScale("TeatherOffGuardTargetWindowCircle",UIScale*0.8)
	WindowClearAnchors( "TeatherOffGuardTargetWindowCircle" )
	WindowAddAnchor( "TeatherOffGuardTargetWindowCircle" , "topleft", "TeatherOffGuardTargetWindow", "topleft", 7,0)		
	
	WindowSetScale("TeatherOffGuardTargetWindowIcon",UIScale*0.8)
	WindowClearAnchors( "TeatherOffGuardTargetWindowIcon" )
	WindowAddAnchor( "TeatherOffGuardTargetWindowIcon" , "topleft", "TeatherOffGuardTargetWindow", "topleft", 19,13)	
	
	WindowSetScale("TeatherOffGuardLineStartLine",UIScale*0.8)
	WindowSetScale("TeatherOffGuardLineEndLine",UIScale*0.8)
	
	WindowClearAnchors( "TeatherLineStartLine" )
	WindowAddAnchor( "TeatherLineStartLine" , "topleft", "TeatherSelfWindow", "topleft", 0,0)	
				
	WindowClearAnchors( "TeatherOffGuardLineStartLine" )
	WindowAddAnchor( "TeatherOffGuardLineStartLine" , "topleft", "TeatherOffGuardSelfWindow", "topleft", 7,7)	


end

function teather.OnLayoutEditorFinished( editorCode )
	if( editorCode == LayoutEditor.EDITING_END ) then
		WindowSetShowing("TeatherSelfWindow",false)
		WindowSetShowing("TeatherTargetWindow",false)		
		WindowSetShowing("TeatherOffGuardTargetWindow",false) 
		WindowSetShowing("TeatherOffGuardSelfWindow",false) 
	end
end


--Attach/deatach and Show/Hide the teather windows
function teather.GetIDs()
	local PlayerName = teather.FixString(GameData.Player.name)
	teather.TargetID = TargetInfo:UnitEntityId("selffriendlytarget")
	teather.TargetName = teather.FixString(TargetInfo:UnitName("selffriendlytarget"))

	if teather.TargetName ~= L"" and not (teather.TargetName == PlayerName) then 
	--	DetachWindowFromWorldObject("TeatherTargetWindow",TargetID)
		IsTeathered = 0.1
		WindowSetShowing("TeatherTargetWindow",true) 
		WindowSetShowing("TeatherSelfWindow",true) 

	else
	--	DetachWindowFromWorldObject("TeatherTargetWindow",TargetID)
		IsTeathered = 0.1
		WindowSetShowing("TeatherTargetWindow",false) 
		WindowSetShowing("TeatherSelfWindow",false)
		teather.TargetID = 0	
	end	
--	teather.update()
end

function teather.GetIDs2()
	local PlayerName = teather.FixString(GameData.Player.name)
	teather.OffGuardID = TargetInfo:UnitEntityId("selffriendlytarget")
	teather.OffGuardName = teather.FixString(TargetInfo:UnitName("selffriendlytarget"))

	if teather.OffGuardName ~= L"" and not (teather.OffGuardName == PlayerName) then 
	--	DetachWindowFromWorldObject("TeatherTargetWindow",TargetID)
		IsTeatheredOffGuard = 0.1
		WindowSetShowing("TeatherOffGuardTargetWindow",true) 
		WindowSetShowing("TeatherOffGuardSelfWindow",true) 
	else
	--	DetachWindowFromWorldObject("TeatherTargetWindow",TargetID)
		IsTeatheredOffGuard = 0.1
		WindowSetShowing("TeatherOffGuardTargetWindow",false) 
		WindowSetShowing("TeatherOffGuardSelfWindow",false) 
		teather.OffGuardID = 0
	end
	
--	teather.update()
end



function teather.update(timeElapsed)
	if DriftTimer > 60 then DriftTimer = 0 else
		DriftTimer = DriftTimer + (timeElapsed)*100
	end
	
	local IsTargetGuarded = LibGuard.GuarderData.Name == teather.TargetName
	local distance = 0

	TexturePack = teather.Settings.TexturePack
	
	if teather.TargetName ~= nil and teather.TargetName ~= L"" then
	local IsXguard = Check_XGuard()
		--Did i mentioned i hate math? because im just so terrible at it...
		--Only check for distance if in a party,warband or scenario
		if IsWarBandActive() or PartyUtils.IsPartyActive() or GameData.Player.isInScenario or GameData.Player.isInSiege then
			distance = LibGuard.GuarderData.distance
			teather.TargetID = LibGuard.GuarderData.ID
			teather.TargetInfo = LibGuard.GuarderData.Info
		end
		
			WindowClearAnchors( "TeatherLineEndLine" )
			WindowAddAnchor( "TeatherLineEndLine" , "topleft", "TeatherTargetWindow", "topleft", 0,(teather.Settings.AnchorOffset)*1.2)
					
			WindowClearAnchors( "TeatherTargetWindowCircle" )
			WindowAddAnchor( "TeatherTargetWindowCircle" , "topleft", "TeatherTargetWindow", "topleft", 0,teather.Settings.AnchorOffset)	
			WindowClearAnchors( "TeatherTargetWindowIcon" )
			WindowAddAnchor( "TeatherTargetWindowIcon" , "topleft", "TeatherTargetWindow", "topleft", 15,15+(teather.Settings.AnchorOffset))	
					
		--WindowSetScale("TeatherTargetWindow",UIScale*(1-(distance/700)))
		--WindowSetScale("TeatherLineEndLine",UIScale)
			
			local IsDistant = true
			if LibGuard.GuarderData.Info ~= nil and LibGuard.GuarderData.Info ~= 0 then
				IsDistant = LibGuard.GuarderData.Info.isDistant
			end
			local Color = teather.Settings.Colors.Default
			
			if IsDistant == true then 
				Color = teather.Settings.Colors.Distant
				G_Range_Out = "Distant"
			else
				if distance <= 30 and distance >= 0 then
					Color = teather.Settings.Colors.Close
					G_Range_Out = "Close"
				elseif distance > 30 and distance <= 50 then
					Color = teather.Settings.Colors.Mid
					G_Range_Out = "Mid"
				elseif distance > 50 then
					Color = teather.Settings.Colors.Far
					G_Range_Out = "Far"
				else
					Color = teather.Settings.Colors.Distant
					G_Range_Out = "Distant"
				end
			end
		
		
			for i=1,MaxLines do
				WindowSetAlpha("TeatherLine"..i.."Line",0)
			end
				WindowSetAlpha("TeatherLineEndLine",0)
				WindowSetAlpha("TeatherLineStartLine",0)
				local ShowLines = 0
				if WindowGetShowing("TeatherTargetWindow") == true then ShowLines = 1 end
				
				if  teather.TargetID ~= nil then
					MoveWindowToWorldObject("TeatherTargetWindow", teather.TargetID, ObjecOffset)--0.9962 for player 0.9975
					ForceUpdateWorldObjectWindow(teather.TargetID,"TeatherTargetWindow")
				end
				--WindowSetOffsetFromParent("TeatherTargetWindow",0,AnchorOffset)	
					
				local TargetTempWindowX,TargetTempWindowY = WindowGetScreenPosition("TeatherTargetWindowIcon")
				local PlayerTempWindowX,PlayerTempWindowY = WindowGetScreenPosition("TeatherSelfWindowIcon")
				local xDiff = PlayerTempWindowX-TargetTempWindowX
				local yDiff = PlayerTempWindowY-TargetTempWindowY
				local Degrees = (math.atan2(yDiff,xDiff)*(180 / math.pi)-90)
				local DistX = 	(PlayerTempWindowX - TargetTempWindowX)
				local DistY = 	(PlayerTempWindowY - TargetTempWindowY)
				local TestDistance = (math.sqrt(DistX*DistX+DistY*DistY))/UIScale		
				NumberLines = math.floor(TestDistance/(LineLength*1.2))+1
		
				for i=1,NumberLines do
					local xDiff2 = PlayerTempWindowX-TargetTempWindowX
					local yDiff2 = PlayerTempWindowY-TargetTempWindowY
					local Degrees2 = (math.atan2(yDiff2,xDiff2)*(180 / math.pi)-90)

					--only do a sprite roation if there is change in the direction
					if LatestDir2 ~= Degrees2 then				
						local radius2 = (LineLength*i)-35
						local xPos2 = radius2 * math.cos(math.rad(Degrees2-90)) 
						local yPos2 = radius2 * math.sin(math.rad(Degrees2-90))
					DynamicImageSetTexture("TeatherLine"..i.."Line",TexturePack..tostring(GuardTexture[IsXguard]), 0, DriftTimer)						
						DynamicImageSetRotation("TeatherLine"..i.."Line",Degrees2)				
						WindowClearAnchors( "TeatherLine"..i )
						WindowAddAnchor( "TeatherLine"..i , "topleft", "TeatherSelfWindow", "topleft", xPos2+34,yPos2+3)			
					end					
				
					WindowSetTintColor("TeatherLine"..i.."Line",Color.r,Color.g,Color.b)
					if IsTeathered <= 0 then 
						WindowSetAlpha("TeatherLine"..i.."Line",ShowLines)
					end				
				end	
				
				LatestDir2 = Degrees2
	--Why Alpha the lines instead of Hiding/showing?, Becasue Hiding/showing is slower that doing Alpha (perhaps it has to redo the drawing routine and go throu eventhandler?), took me a while to figure this out because it casued a lot of sprite artifacts when rotating
				
				for a=(NumberLines),MaxLines do	
					WindowSetAlpha("TeatherLine"..a.."Line",0)
				end
				

				DynamicImageSetTexture("TeatherLineEndLine",TexturePack.."TeatherArrow", 0,0)
				DynamicImageSetTexture("TeatherLineStartLine",TexturePack.."TeatherArrow", 0,0)			


				DynamicImageSetRotation("TeatherLineEndLine",Degrees)
				DynamicImageSetRotation("TeatherLineStartLine",Degrees+180)

				WindowSetTintColor("TeatherLineStartLine",Color.r,Color.g,Color.b)			
				WindowSetTintColor("TeatherLineEndLine",Color.r,Color.g,Color.b)
				WindowSetTintColor("TeatherSelfWindowCircle",Color.r,Color.g,Color.b)
				WindowSetTintColor("TeatherTargetWindowCircle",Color.r,Color.g,Color.b)						
				
				WindowSetTintColor("TeatherSelfWindowIcon",Color.r,Color.g,Color.b)
				WindowSetTintColor("TeatherTargetWindowIcon",Color.r,Color.g,Color.b)						

				WindowSetTintColor("TeatherSelfWindowGlow",Color.r,Color.g,Color.b)
				WindowSetTintColor("TeatherTargetWindowGlow",Color.r,Color.g,Color.b)			

				if IsTeathered > 0 then 
					IsTeathered = IsTeathered-timeElapsed
				else
					if TestDistance <= (LineLength+15) then
						WindowSetAlpha("TeatherLineEndLine",0)
						WindowSetAlpha("TeatherLineStartLine",0)			
						WindowSetAlpha("TeatherLine1Line",0)
					else
						WindowSetAlpha("TeatherLineEndLine",ShowLines)
						WindowSetAlpha("TeatherLineStartLine",ShowLines)			
						WindowSetAlpha("TeatherLine1Line",ShowLines)
					end
				end	

		
		local S_x,S_y = WindowGetScreenPosition("TeatherTargetWindow")	
		if  (S_x+ S_y) == 0 or (WindowGetShowing("TeatherSelfWindow")) == false or (IsDistant == true) then WindowSetShowing("TeatherTargetWindow",false) end
			LatestDir2 = Degrees2
	--	end
			CircleImageSetTexture( "TeatherTargetWindowIcon", GuardIcons[G_Range_Out], 32, 32 )
			CircleImageSetTexture( "TeatherSelfWindowIcon", GuardIcons[G_Range_Out], 32, 32 )
	
	--[[
		if LibGuard.GuarderData.IsGuarding == true and IsTargetGuarded then
			local texture, x, y, disabledTexture = GetIconData(tonumber(80))
			CircleImageSetTexture( "TeatherTargetWindowIcon", "GuardIcon", 32, 32 )
			CircleImageSetTexture( "TeatherSelfWindowIcon", "GuardIcon", 32, 32 )
		else
			local texture, x, y, disabledTexture = GetIconData(tonumber(32))
			CircleImageSetTexture( "TeatherTargetWindowIcon", "GuardIcon", 32, 32 )
			CircleImageSetTexture( "TeatherSelfWindowIcon", "GuardIcon", 32, 32 )
		end
--]]

	local ShowGlow = ((tostring(LibGuard.GuarderData.Name) == tostring(teather.OffGuardName)) and (IsXguard) )
		WindowSetTintColor("TeatherSelfWindowGlow",Color.r,Color.g,Color.b)	
		WindowSetTintColor("TeatherTargetWindowGlow",Color.r,Color.g,Color.b)	
		WindowSetShowing("TeatherSelfWindowGlow",ShowGlow and IsTargetGuarded)	
		WindowSetShowing ("TeatherTargetWindowGlow", ShowGlow and IsTargetGuarded)	

	end

		WindowSetShowing("TeatherLineStart",WindowGetShowing("TeatherTargetWindow"))			
		WindowSetShowing("TeatherLineEnd",WindowGetShowing("TeatherTargetWindow"))		
		--WindowSetShowing("TeatherSelfWindowCircle",not WindowGetShowing("TeatherTargetWindow"))			

	teather.update2(timeElapsed)
end

--This is for OffGuard Tethering
function teather.update2(timeElapsed)

	local IsDistant = true
	if teather.OffGuardInfo ~= nil and teather.OffGuardInfo ~= 0 then
		IsDistant = teather.OffGuardInfo.isDistant
	end
	
	if teather.OffGuardName ~= nil and teather.OffGuardName ~= L"" then
	local IsTargetGuarded = LibGuard.GuarderData.Name == teather.TargetName
	local distance = 0 
	local Color = teather.Settings.Colors.Default

		if LibGuard.registeredGuards[tostring(teather.OffGuardName)] ~= nil then
			distance = LibGuard.registeredGuards[tostring(teather.OffGuardName)].distance
			
		if IsDistant == true then
			Color = teather.Settings.Colors.Distant
			G_Range_In = "Distant"
		else
			if distance <= 30 and distance >= 0 then
				Color = teather.Settings.Colors.Close
				G_Range_In = "Close"
			elseif distance > 30 and distance <= 50 then
				Color = teather.Settings.Colors.Mid
				G_Range_In = "Mid"
			elseif distance > 50 then
				Color = teather.Settings.Colors.Far
				G_Range_In = "Far"
			else
				Color = teather.Settings.Colors.Distant
				G_Range_In = "Distant"
			end
		end	

			else
				WindowSetShowing("TeatherOffGuardSelfWindowLabel",false)
				WindowSetShowing("TeatherOffGuardSelfWindowLabelBG",false)						
			end

		
			teather.OffGuardInfo = LibGuard.GetIdFromName(tostring(teather.OffGuardName),3)
			
			WindowClearAnchors( "TeatherOffGuardLineEndLine" )
			WindowAddAnchor( "TeatherOffGuardLineEndLine" , "topleft", "TeatherOffGuardTargetWindow", "topleft",7,(teather.Settings.AnchorOffset)*1.2)	
					
			WindowClearAnchors( "TeatherOffGuardTargetWindowCircle" )
			WindowAddAnchor( "TeatherOffGuardTargetWindowCircle" , "topleft", "TeatherOffGuardTargetWindow", "topleft", 7,(teather.Settings.AnchorOffset)*1.2)	
			WindowClearAnchors( "TeatherOffGuardTargetWindowIcon" )
			WindowAddAnchor( "TeatherOffGuardTargetWindowIcon" , "topleft", "TeatherOffGuardTargetWindow", "topleft", 19,13+(teather.Settings.AnchorOffset*1.2))	
		
		
			for i=1,OffMaxLines do
				WindowSetAlpha("TeatherOffGuardLine"..i.."Line",0)
			end
				WindowSetAlpha("TeatherOffGuardLineEndLine",0)
				WindowSetAlpha("TeatherOffGuardLineStartLine",0)			
				local ShowLines = 0
				if WindowGetShowing("TeatherOffGuardTargetWindow") == true and (Check_XGuard() == false) then ShowLines = 1 end
				if teather.OffGuardID ~= nil then
					MoveWindowToWorldObject("TeatherOffGuardTargetWindow", teather.OffGuardID, ObjecOffset)--0.9962 for player 0.9975
					ForceUpdateWorldObjectWindow(teather.OffGuardID,"TeatherOffGuardTargetWindow")
				end
				--WindowSetOffsetFromParent("TeatherTargetWindow",0,AnchorOffset)	
					
				local TargetTempWindowX,TargetTempWindowY = WindowGetScreenPosition("TeatherOffGuardTargetWindowIcon")
				local PlayerTempWindowX,PlayerTempWindowY = WindowGetScreenPosition("TeatherOffGuardSelfWindowIcon")
				local xDiff = PlayerTempWindowX-TargetTempWindowX
				local yDiff = PlayerTempWindowY-TargetTempWindowY
				local Degrees = (math.atan2(yDiff,xDiff)*(180 / math.pi)-90)
				local DistX = 	(PlayerTempWindowX - TargetTempWindowX)
				local DistY = 	(PlayerTempWindowY - TargetTempWindowY)
				local TestDistance = (math.sqrt(DistX*DistX+DistY*DistY))/UIScale		
				NumberLines = math.floor(TestDistance/OffLineLength)+1
		
				for i=1,NumberLines do
					local xDiff2 = PlayerTempWindowX-TargetTempWindowX
					local yDiff2 = PlayerTempWindowY-TargetTempWindowY
					local Degrees2 = (math.atan2(yDiff2,xDiff2)*(180 / math.pi)-90)

					--only do a sprite roation if there is change in the direction
					if LatestDir3 ~= Degrees2 then				
						local radius2 = (OffLineLength*i)-40
						local xPos2 = radius2 * math.cos(math.rad(Degrees2-90)) 
						local yPos2 = radius2 * math.sin(math.rad(Degrees2-90)) 
						DynamicImageSetTexture("TeatherOffGuardLine"..i.."Line",TexturePack.."TeatherLine2", 0, -DriftTimer)	
						DynamicImageSetRotation("TeatherOffGuardLine"..i.."Line",Degrees2)				
						WindowClearAnchors( "TeatherOffGuardLine"..i )
						WindowAddAnchor( "TeatherOffGuardLine"..i , "topleft", "TeatherOffGuardSelfWindow", "topleft", xPos2+33,yPos2+3)			
					end	
				
					WindowSetTintColor("TeatherOffGuardLine"..i.."Line",Color.r,Color.g,Color.b)
					if IsTeatheredOffGuard <= 0 then 
						WindowSetAlpha("TeatherOffGuardLine"..i.."Line",ShowLines)
					end				
				end	
				
				LatestDir3 = Degrees2
	--Why Alpha the lines instead of Hiding/showing?, Becasue Hiding/showing is slower that doing Alpha (perhaps it has to redo the drawing routine and go throu eventhandler?), took me a while to figure this out because it casued a lot of sprite artifacts when rotating
				
				for a=(NumberLines),OffMaxLines do	
					WindowSetAlpha("TeatherOffGuardLine"..a.."Line",0)
				end
				
				DynamicImageSetTexture("TeatherOffGuardLineStartLine",TexturePack.."TeatherArrow", 0,0)						
				DynamicImageSetTexture("TeatherOffGuardLineEndLine",TexturePack.."TeatherArrow", 0,0)		
				
				DynamicImageSetRotation("TeatherOffGuardLineEndLine",Degrees)
				DynamicImageSetRotation("TeatherOffGuardLineStartLine",Degrees+180)
				
				WindowSetTintColor("TeatherOffGuardLineEndLine",Color.r,Color.g,Color.b)
				WindowSetTintColor("TeatherOffGuardLineStartLine",Color.r,Color.g,Color.b)
				
				WindowSetTintColor("TeatherOffGuardSelfWindowCircle",Color.r,Color.g,Color.b)
				WindowSetTintColor("TeatherOffGuardTargetWindowCircle",Color.r,Color.g,Color.b)						
				WindowSetTintColor("TeatherOffGuardSelfWindowIcon",Color.r,Color.g,Color.b)
				WindowSetTintColor("TeatherOffGuardTargetWindowIcon",Color.r,Color.g,Color.b)		


				if IsTeatheredOffGuard > 0 then 
					IsTeatheredOffGuard = IsTeatheredOffGuard-timeElapsed
				else
					if TestDistance <= (OffLineLength+5) then
						WindowSetAlpha("TeatherOffGuardLineEndLine",0)
						WindowSetAlpha("TeatherOffGuardLineStartLine",0)			
						WindowSetAlpha("TeatherOffGuardLine1Line",0)
					else
						WindowSetAlpha("TeatherOffGuardLineEndLine",ShowLines)
						WindowSetAlpha("TeatherOffGuardLineStartLine",ShowLines)			
						WindowSetAlpha("TeatherOffGuardLine1Line",ShowLines)
					end
				end	
			

					LatestDir3 = Degrees2	
	end
	if (LibGuard.registeredGuards == nil or (NumberOfGuards == 0) or (tostring(LibGuard.GuarderData.Name) == tostring(teather.OffGuardName))) and (IsTargetGuarded) then
		WindowSetShowing("TeatherOffGuardSelfWindow",false)
	else
		WindowSetShowing("TeatherOffGuardSelfWindow",true)
		teather.OffTarget()
	end	

	local S_x,S_y = WindowGetScreenPosition("TeatherOffGuardTargetWindow")	
	if  ((S_x+ S_y) == 0 or (WindowGetShowing("TeatherOffGuardSelfWindow")) == false) or (IsDistant == true) then WindowSetShowing("TeatherOffGuardTargetWindow",false) end

			CircleImageSetTexture( "TeatherOffGuardTargetWindowIcon", GuardIcons[G_Range_In], 32, 32 )
			CircleImageSetTexture( "TeatherOffGuardSelfWindowIcon", GuardIcons[G_Range_In], 32, 32 )
--or (NumberOfGuards == 1 and (Check_XGuard()))

--local ShowGlow = ((tostring(LibGuard.GuarderData.Name) == tostring(teather.OffGuardName)) and (Check_XGuard()) )

--	WindowSetShowing("TeatherOffGuardSelfWindowGlow",ShowGlow and not IsTargetGuarded)	
--	WindowSetShowing ("TeatherOffGuardTargetWindowGlow", ShowGlow and not IsTargetGuarded)	

		WindowSetShowing("TeatherOffGuardLineStartLine",WindowGetShowing("TeatherOffGuardTargetWindow"))			
		WindowSetShowing("TeatherOffGuardLineEndLine",WindowGetShowing("TeatherOffGuardTargetWindow"))

--	end

end

function teather.OffTarget()
NumberOfGuards = 0
local Range = 999999
teather.OffGuardName = L""
			
	for key, value in pairs( LibGuard.registeredGuards ) do	
	NumberOfGuards = NumberOfGuards+1
	
		if LibGuard.registeredGuards[key].distance ~= nil and LibGuard.registeredGuards[key].distance < Range then
			Range = LibGuard.registeredGuards[key].distance		
			teather.OffGuardID = LibGuard.registeredGuards[key].ID
			teather.OffGuardName = towstring(key)	
			
			if Check_XGuard() == true and (towstring(LibGuard.GuarderData.Name) ~= towstring(key)) then
				teather.ClosestOffGuardName = towstring(key)
				teather.ClosestOffGuardID = LibGuard.registeredGuards[key].ID
			else
				teather.ClosestOffGuardName = towstring(key)
				teather.ClosestOffGuardID = LibGuard.registeredGuards[key].ID
			end

			
		end		
	end			
	
	if (NumberOfGuards == 0) then	
			IsTeatheredOffGuard = 0.1
			WindowSetShowing("TeatherOffGuardTargetWindow",false) 
			WindowSetShowing("TeatherOffGuardSelfWindow",false)
			teather.OffGuardID = 0	
			teather.OffGuardName = L""
			teather.ClosestOffGuardName = L""
			teather.ClosestOffGuardID = 0
	end	
return		
end

--This is just for debugging Info
function teather.GetInfo()
	local TargetParentX,TargetParentY = WindowGetScreenPosition("TeatherTargetWindow")
	local SelfParentX,SelfParentY = WindowGetScreenPosition("TeatherSelfWindow")
	local xDiff = SelfParentX-TargetParentX
	local yDiff = SelfParentY-TargetParentY
	teather.Degrees = (math.atan2(yDiff,xDiff)*(180 / math.pi)-90)
	local DistX = 	SelfParentX - TargetParentX
	local DistY = 	SelfParentY - TargetParentY		
	teather.Distance = math.sqrt(DistX*DistX+DistY*DistY)
	d(L"X:"..towstring(SelfParentX-TargetParentX)..L" Y:"..towstring(SelfParentY-TargetParentY))
	d(L"Deg: "..towstring(teather.Degrees))
	d(L"Dist: "..towstring(teather.Distance))
	d(L"GlobalScale: "..towstring(GlobalScale))
	d(L"ResolutionScale: "..towstring(ResolutionScale))
	d(L"Screen Width: "..towstring(ScreenWidthX))	
	d(L"Screen Height: "..towstring(ScreenHeightY))	
	d(L"Lines? "..towstring(((((ScreenWidthX+ScreenHeightY/2)/ResolutionScale)/GlobalScale)/55)/2))
end


function teather.FixString (str)
	if (str == nil) then return nil end
	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end	
	return str
end


function teather.Libguard_Toggle(state,GuardedName,GuardedID)
--d(L"State:"..towstring(state)..L" Name:"..towstring(GuardedName)..L" ID:"..towstring(GuardedID))
		if state == GUARDED_APPLY_ID then
		teather.OffGuardID = GuardedID
		teather.OffGuardName = towstring(GuardedName)		
		IsTeatheredOffGuard = 0.1
		WindowSetShowing("TeatherOffGuardTargetWindow",true) 
		WindowSetShowing("TeatherOffGuardSelfWindow",true) 
		teather.OffTarget()		
		elseif state == GUARDED_REMOVE_ID then
		teather.OffTarget()		
		elseif state == GUARDING_REMOVE_ID then
			teather.TargetName = L""
			IsTeathered = 0.1
			WindowSetShowing("TeatherTargetWindow",false) 
			WindowSetShowing("TeatherSelfWindow",false)
			teather.TargetID = 0			
		elseif state == GUARDING_APPLY_ID then
			teather.TargetName = towstring(GuardedName)
			IsTeathered = 0.1
			WindowSetShowing("TeatherTargetWindow",true) 
			WindowSetShowing("TeatherSelfWindow",true) 
			teather.GetIDs()			
		end			
end

function teather.Command(input)
	local input1 = nil
	local input2 = nil
	
	input1 = string.sub(input,0,string.find(input," "))
	if string.find(input," ") ~= nil then
		input1 = string.sub(input,0,string.find(input," ")-1)
		input2 = string.sub(input,string.find(input," ")+1,-1)
	end

	if (input1 == "offset") then
		if (input2 == "") or (input2 == nil) then
			EA_ChatWindow.Print(L"Input offset for Target Guard icon, (Current offset: "..towstring(teather.Settings.AnchorOffset)..L")")
			return		
		else
			teather.Settings.AnchorOffset = tonumber(input2)
		end	
	elseif (input1 == "frame") then
		if(input2 == "modern") then
			teather.Settings.TexturePack = "Modern_"
		elseif(input2 == "classic") then
			teather.Settings.TexturePack = "Classic_"
		else
			EA_ChatWindow.Print(L"Input frame for teather| options: modern, classic (Current frame: "..towstring(TexturePack)..L")")
			return
		end
	elseif (input1 == "reset") then
		teather.ResetSettings()
	else
		EA_ChatWindow.Print(L"Options for Teather: /teather frame <framename>, /teather offset <number>, /teather reset")
	return
	end
	
end

function teather.ResetSettings()
teather.Settings = {
	version = Version,
	AnchorOffset = 80,
	TexturePack = "Modern_",
	Colors = {
		Default = {r=255,g=255,b=255},
		Close = {r=50,g=255,b=50},
		Mid = {r=100,g=100,b=255},
		Far = {r=255,g=50,b=50},
		Distant = {r=125,g=125,b=125}
	}
}
end