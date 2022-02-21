local MAJOR, MINOR = "PhantomLib", 18

local PhantomLib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not PhantomLib then return end

local strmatch = string.match
local WindowGetId = WindowGetId
local DoesWindowExist = DoesWindowExist
local ButtonGetPressedFlag = ButtonGetPressedFlag

local oWindowSetShowing = WindowSetShowing
local WindowSetShowing =
    function(window, show)
        -- Protect against non-existant windows
        if DoesWindowExist(window) then
            oWindowSetShowing(window, show)
        end
    end

local firstLoad = true

-- Initialize window display states
PhantomLib.windowStates = {
    --PlayerWindow = true,
    --GroupWindow = true,
    --BattlegroupHUD = true,
    --TargetWindow = true,
    --ScenarioGroupWindow = true,
    OpenPartySearchButton = true,
    PetWindow = true,
    --PetStance = true,
    --PetActionBar = true,
    MainAssist = true,
	ActionBarLockToggler = true,
	SocialWindowButton = true,
	--[[ActionBar1 = true,
	ActionBar2 = true,
	ActionBar3 = true,
	ActionBar4 = true,]]--
	OverheadMapArea = true,
	OverheadMapWorld = true,
	OverheadMapCity = true,
	OverheadMapZoom = true,
	OverheadMapScenario = true,
	OverheadMapMail = true,
	OverheadMapPins = true,
	OverheadMapFrame = true,
    OverheadMapRally = true,
    --InfluenceBar = true,
    --StanceBar = true,
}

PhantomLib.buffStates = {
    PlayerWindow = true,
    GroupWindow = true,
    TargetWindow = true,
}

PhantomLib.registerStates = {
    --PlayerWindow = true,
    --GroupWindow = true,
    --BattlegroupHUD = true,
    --TargetWindow = true,
    --ScenarioGroupWindow = true,
    OpenPartySearchButton = false,
    MainAssist = true,
	-- No entry needed for action bars, since we just hook the function to register them
}

PhantomLib.eventStates = {
    PlayerBuffs = true,
    GroupBuffs = true,
    TargetBuffs = true,
    WarbandUpdate = true,
}

local hooked = {}

function PhantomLib.InstallEA_Window_OverheadMapHooks()
	if not EA_Window_OverheadMap then return end
	if not hooked.EA_Window_OverheadMap then hooked.EA_Window_OverheadMap = {} end
	
	if not hooked.EA_Window_OverheadMap.UpdateScenarioButtons and EA_Window_OverheadMap.UpdateScenarioButtons then
		hooked.EA_Window_OverheadMap.UpdateScenarioButtons = EA_Window_OverheadMap.UpdateScenarioButtons
		EA_Window_OverheadMap.UpdateScenarioButtons =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateScenarioButtons(...)
				if not PhantomLib.windowStates.OverheadMapScenario then
					WindowSetShowing("EA_Window_OverheadMapScenarioSummaryButton", false)
					WindowSetShowing("EA_Window_OverheadMapMapScenarioQueue", false)
					WindowSetShowing("EA_Window_OverheadMapScenarioGroupButton", false)
				end
			end
	end
	
	if not hooked.EA_Window_OverheadMap.UpdateScenarioQueueButton and EA_Window_OverheadMap.UpdateScenarioQueueButton then
		hooked.EA_Window_OverheadMap.UpdateScenarioQueueButton = EA_Window_OverheadMap.UpdateScenarioQueueButton
		EA_Window_OverheadMap.UpdateScenarioQueueButton =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateScenarioQueueButton(...)
				if not PhantomLib.windowStates.OverheadMapScenario then
					WindowSetShowing("EA_Window_OverheadMapMapScenarioQueueGlowAnim", false)
				end
			end
	end
	
	if not hooked.EA_Window_OverheadMap.UpdateCityRating and EA_Window_OverheadMap.UpdateCityRating then
		hooked.EA_Window_OverheadMap.UpdateCityRating = EA_Window_OverheadMap.UpdateCityRating
		EA_Window_OverheadMap.UpdateCityRating =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateCityRating(...)
				if not PhantomLib.windowStates.OverheadMapCity then
					WindowSetShowing("EA_Window_OverheadMapCityRating", false)
				end
			end
	end
	
	if not hooked.EA_Window_OverheadMap.UpdateMailIcon and EA_Window_OverheadMap.UpdateMailIcon then
		hooked.EA_Window_OverheadMap.UpdateMailIcon = EA_Window_OverheadMap.UpdateMailIcon
		EA_Window_OverheadMap.UpdateMailIcon =
			function(...)
				hooked.EA_Window_OverheadMap.UpdateMailIcon(...)
				if not PhantomLib.windowStates.OverheadMapMail then
					WindowSetShowing("EA_Window_OverheadMapMailNotificationIcon", false)
				end
			end
	end
	
end

function PhantomLib.InstallEA_ChatWindowHooks()
	if not EA_ChatWindow then return end
	if not hooked.EA_ChatWindow then hooked.EA_ChatWindow = {} end
	
	if not hooked.EA_ChatWindow.UpdateSocialWindowButton and EA_ChatWindow.UpdateSocialWindowButton then
		hooked.EA_ChatWindow.UpdateSocialWindowButton = EA_ChatWindow.UpdateSocialWindowButton
		EA_ChatWindow.UpdateSocialWindowButton =
			function(...)
				hooked.EA_ChatWindow.UpdateSocialWindowButton(...)
				if not PhantomLib.windowStates.SocialWindowButton then
					WindowSetShowing("ChatWindowSocialWindowButton", false)
				end
			end
	end
end

--[[function PhantomLib.InstallActionBarHooks()
    if not ActionBar then return end
	if not hooked.ActionBar then hooked.ActionBar = {} end
    
    if not hooked.ActionBar.UpdateShownSlots and ActionBar.UpdateShownSlots then
		hooked.ActionBar.UpdateShownSlots = ActionBar.UpdateShownSlots
		ActionBar.UpdateShownSlots =
			function(...)
				hooked.ActionBar.UpdateShownSlots(...)
				for i=1,4 do
					if not PhantomLib.windowStates["ActionBar"..i] then
                        if DoesWindowExist(ACTION_BAR_NAME..i) then
                            GetFrame(ACTION_BAR_NAME..i):Show(false)
                        end
					end
				end
			end
	end
end]]--

function PhantomLib.InstallActionBarClusterManagerHooks()
	if not ActionBarClusterManager then return end
	if not hooked.ActionBarClusterManager then hooked.ActionBarClusterManager = {} end
	
	if not hooked.ActionBarClusterManager.SpawnActionBars and ActionBarClusterManager.SpawnActionBars then
		hooked.ActionBarClusterManager.SpawnActionBars = ActionBarClusterManager.SpawnActionBars
		ActionBarClusterManager.SpawnActionBars =
			function(...)
				hooked.ActionBarClusterManager.SpawnActionBars(...)
				if not PhantomLib.windowStates.ActionBarLockToggler then
                    if QUICK_LOCK_NAME and DoesWindowExist(QUICK_LOCK_NAME) then
                        WindowSetShowing(QUICK_LOCK_NAME, false)
                    end
				end
			end
	end
	
	--[[if not hooked.ActionBarClusterManager.SetLayoutMode and ActionBarClusterManager.SetLayoutMode then
		hooked.ActionBarClusterManager.SetLayoutMode = ActionBarClusterManager.SetLayoutMode
		ActionBarClusterManager.SetLayoutMode =
			function(...)
                for i=1,4 do
                    -- Force these back to a known state
                    if DoesWindowExist(ACTION_BAR_NAME..i) then
                        GetFrame(ACTION_BAR_NAME..i):Show(true)
                    end
                end
				hooked.ActionBarClusterManager.SetLayoutMode(...)
				for i=1,4 do
					if not PhantomLib.windowStates["ActionBar"..i] then
                        if DoesWindowExist(ACTION_BAR_NAME..i) then
                            GetFrame(ACTION_BAR_NAME..i):Show(false)
                        end
					end
				end
                if not PhantomLib.windowStates.StanceBar then
                    if STANCE_ABILITY_BAR_NAME and DoesWindowExist(STANCE_ABILITY_BAR_NAME) then
                        GetFrame(STANCE_ABILITY_BAR_NAME):Show(false)
                    end
                end
			end
	end]]--
	
	--[[if not hooked.ActionBarClusterManager.RegisterClusterWithLayoutEditor
	  and ActionBarClusterManager.RegisterClusterWithLayoutEditor then
		hooked.ActionBarClusterManager.RegisterClusterWithLayoutEditor = ActionBarClusterManager.RegisterClusterWithLayoutEditor
		ActionBarClusterManager.RegisterClusterWithLayoutEditor =
			function(...)
				hooked.ActionBarClusterManager.RegisterClusterWithLayoutEditor(...)
				for i=1,4 do
					if not PhantomLib.windowStates["ActionBar"..i] then
						LayoutEditor.UnregisterWindow("EA_ActionBar"..i)
					end
				end
                if not PhantomLib.windowStates.PetActionBar then
                    if PET_STANCE_BAR_NAME and DoesWindowExist(PET_STANCE_BAR_NAME) then
                        pcall(LayoutEditor.UnregisterWindow, PET_STANCE_BAR_NAME)
                    end
                end
                if not PhantomLib.windowStates.PetStance then
                    -- Only hide the career resource window if this is a pet class
                    if GameData.Player.career.line == GameData.CareerLine.SEER or
                       GameData.Player.career.line == GameData.CareerLine.SQUIG_HERDER or
                       GameData.Player.career.line == GameData.CareerLine.ENGINEER or
                       GameData.Player.career.line == GameData.CareerLine.MAGUS then
                        if CAREER_WINDOW_NAME and DoesWindowExist(CAREER_WINDOW_NAME) then
                            pcall(LayoutEditor.UnregisterWindow, CAREER_WINDOW_NAME)
                        end
                    end
                end
                if not PhantomLib.windowStates.StanceBar then
                    if STANCE_ABILITY_BAR_NAME and DoesWindowExist(STANCE_ABILITY_BAR_NAME) then
                        pcall(LayoutEditor.UnregisterWindow, STANCE_ABILITY_BAR_NAME)
                    end
                end
			end
	end]]--
end

function PhantomLib.InstallPlayerAssistHooks()
    if not EA_Button_PlayerAssist then return end
    if not hooked.EA_Button_PlayerAssist then hooked.EA_Button_PlayerAssist = {} end
    
    if not hooked.EA_Button_PlayerAssist.UpdateButtonVisibility and EA_Button_PlayerAssist.UpdateButtonVisibility then
        hooked.EA_Button_PlayerAssist.UpdateButtonVisibility = EA_Button_PlayerAssist.UpdateButtonVisibility
        EA_Button_PlayerAssist.UpdateButtonVisibility =
            function(self, ...)
                hooked.EA_Button_PlayerAssist.UpdateButtonVisibility(self, ...)
                if not PhantomLib.windowStates.MainAssist then
                    if DoesWindowExist("EA_AssistWindowMainAssist") then
                        WindowSetShowing("EA_AssistWindowMainAssist", false)
                    elseif DoesWindowExist("MainAssist") then
                        WindowSetShowing("MainAssist", false)
                    end
                end
            end
    end
end

function PhantomLib.InstallPetWindowHooks()
    if not PetWindow then return end
    if not hooked.PetWindow then hooked.PetWindow = {} end
    
    if not hooked.PetWindow.UpdatePet and PetWindow.UpdatePet then
        hooked.PetWindow.UpdatePet = PetWindow.UpdatePet
        PetWindow.UpdatePet =
            function(self, ...)
                hooked.PetWindow.UpdatePet(self, ...)
                if self.m_UnitFrame and not PhantomLib.windowStates.PetWindow then
                    self.m_UnitFrame:Show(false)
                end
                --[[if not PhantomLib.windowStates.PetStance then
                    self:Show(false)
                end
                if self.m_Actionbar and not PhantomLib.windowStates.PetActionBar and self.m_Actionbar then
                    self.m_Actionbar:Show(false)
                end]]--
            end
    end
    
    --[[if PetWindow.m_Actionbar then
        if not hooked.PetWindow.ActionBarShow then
            hooked.PetWindow.ActionBarShow = PetWindow.m_Actionbar.Show or Frame.Show
            PetWindow.m_Actionbar.Show =
                function(self, ...)
                    if not PhantomLib.windowStates.PetActionBar then
                        hooked.PetWindow.ActionBarShow(self, false)
                    else
    					hooked.PetWindow.ActionBarShow(self, ...)
    				end
                end
        end
    else
        if not hooked.PetWindow.CreateActionBar and PetWindow.CreateActionBar then
            hooked.PetWindow.CreateActionBar = PetWindow.CreateActionBar
            PetWindow.CreateActionBar =
                function(...)
                    hooked.PetWindow.CreateActionBar(...)
                    -- Re-run this hook installation (won't loop, since the hooked table will be updated after)
                    PhantomLib.InstallPetWindowHooks()
                end
        end
    end]]--
end

function PhantomLib.InstallOpenPartyWindowHooks()
    if not OpenPartyWindow then return end
    if not hooked.OpenPartyWindow then hooked.OpenPartyWindow = {} end
    
    if not hooked.OpenPartyWindow.ShowOpenPartyButton and OpenPartyWindow.ShowOpenPartyButton then
        hooked.OpenPartyWindow.ShowOpenPartyButton = OpenPartyWindow.ShowOpenPartyButton
        OpenPartyWindow.ShowOpenPartyButton =
            function(...)
                hooked.OpenPartyWindow.ShowOpenPartyButton(...)
                if not PhantomLib.windowStates.OpenPartySearchButton then
                    WindowSetShowing("OpenPartySearchButton", false)
                end
            end
    end
end

--[[function PhantomLib.InstallPlayerWindowHooks()
    if not PlayerWindow then return end
    if not hooked.PlayerWindow then hooked.PlayerWindow = {} end
    
    if not hooked.PlayerWindow.UpdatePlayer and PlayerWindow.UpdatePlayer then
        hooked.PlayerWindow.UpdatePlayer = PlayerWindow.UpdatePlayer
        PlayerWindow.UpdatePlayer =
            function(...)
                hooked.PlayerWindow.UpdatePlayer(...)
                WindowSetShowing("PlayerWindow", PhantomLib.windowStates.PlayerWindow)
            end
    end
end]]--

--[[function PhantomLib.InstallGroupWindowHooks()
    if not GroupPetUnitFrame then return end
    if not hooked.GroupPetUnitFrame then hooked.GroupPetUnitFrame = {} end
    
    if not hooked.GroupPetUnitFrame.Show and GroupPetUnitFrame.Show then
        hooked.GroupPetUnitFrame.Show = GroupPetUnitFrame.Show
        GroupPetUnitFrame.Show =
            function(self, ...)
                if not PhantomLib.windowStates.GroupWindow then
					hooked.GroupPetUnitFrame.Show(self, false)
                else
					hooked.GroupPetUnitFrame.Show(self, ...)
                end
            end
    end
end]]--

--[[function PhantomLib.InstallWarbandWindowHooks()
    if not BattlegroupHUD then return end
    if not hooked.BattlegroupHUD then hooked.BattlegroupHUD = {} end
    
    if not hooked.BattlegroupHUD.Show and BattlegroupHUD.Show then
        hooked.BattlegroupHUD.Show = BattlegroupHUD.Show
        BattlegroupHUD.Show =
            function(...)
                hooked.BattlegroupHUD.Show(...)
                if not PhantomLib.windowStates.BattlegroupHUD then
                    BattlegroupHUD.Hide()
                end
            end
    end
    
    if not hooked.BattlegroupHUD.Update and BattlegroupHUD.Update then
        hooked.BattlegroupHUD.Update = BattlegroupHUD.Update
        BattlegroupHUD.Update = 
            function(...)
                -- This isn't technically a post-hook, but the Update() function is so processing-intensive
                -- that it'd be nice to not have to run it if we're not going to show the purely visual results.
                if PhantomLib.windowStates.BattlegroupHUD then
                    hooked.BattlegroupHUD.Update(...)
                else
                    BattlegroupHUD.Hide()
                end
            end
    end
	
	if not hooked.BattlegroupHUD.SingleMemberUpdate and BattlegroupHUD.SingleMemberUpdate then
        hooked.BattlegroupHUD.SingleMemberUpdate = BattlegroupHUD.SingleMemberUpdate
        BattlegroupHUD.SingleMemberUpdate = 
            function(...)
                -- This isn't technically a post-hook, but the Update() function is so processing-intensive
                -- that it'd be nice to not have to run it if we're not going to show the purely visual results.
                if PhantomLib.windowStates.BattlegroupHUD then
                    hooked.BattlegroupHUD.SingleMemberUpdate(...)
                else
                    BattlegroupHUD.Hide()
                end
            end
    end
end]]--

--[[function PhantomLib.InstallTargetWindowHooks()
    if not TargetWindow then return end
    if not hooked.TargetWindow then hooked.TargetWindow = {} end
    
    if not hooked.TargetWindow.UpdateLayoutForTargets and TargetWindow.UpdateLayoutForTargets then
        hooked.TargetWindow.UpdateLayoutForTargets = TargetWindow.UpdateLayoutForTargets
        TargetWindow.UpdateLayoutForTargets =
            function(...)
                hooked.TargetWindow.UpdateLayoutForTargets(...)
                if not PhantomLib.windowStates.TargetWindow then
                    WindowSetShowing("PrimaryTargetLayoutWindow", false)
                    WindowSetShowing("SecondaryTargetLayoutWindow", false)
                end
            end
    end
end]]--

--[[function PhantomLib.InstallScenarioGroupWindowHooks()
    if not ScenarioGroupWindow then return end
    if not hooked.ScenarioGroupWindow then hooked.ScenarioGroupWindow = {} end
    
    if not hooked.ScenarioGroupWindow.ToggleVisibility and ScenarioGroupWindow.ToggleVisibility then
        hooked.ScenarioGroupWindow.ToggleVisibility = ScenarioGroupWindow.ToggleVisibility
        ScenarioGroupWindow.ToggleVisibility =
            function(...)
                hooked.ScenarioGroupWindow.ToggleVisibility(...)
                if not PhantomLib.windowStates.ScenarioGroupWindow then
                    local index = WindowGetId( SystemData.ActiveWindow.name )
                    WindowSetShowing("FloatingScenarioGroup"..index.."Window", false)
                end
            end
    end
    
    if not hooked.ScenarioGroupWindow.OnScenarioBegin and ScenarioGroupWindow.OnScenarioBegin then
        hooked.ScenarioGroupWindow.OnScenarioBegin = ScenarioGroupWindow.OnScenarioBegin
        ScenarioGroupWindow.OnScenarioBegin =
            function(...)
                hooked.ScenarioGroupWindow.OnScenarioBegin(...)
                if not PhantomLib.windowStates.ScenarioGroupWindow then
                    for i=1,ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
                        WindowSetShowing("FloatingScenarioGroup"..i.."Window", false)
                    end
                end
            end
    end
end]]--

function PhantomLib.InstallBuffHooks()
    if not BuffFrame then return end
    if not hooked.BuffFrame then hooked.BuffFrame = {} end
    
    if not hooked.BuffFrame.Show and BuffFrame.Show then
        hooked.BuffFrame.Show = BuffFrame.Show
        BuffFrame.Show =
            function(self, ...)
                if not self then return end
                local name = self:GetName()
                local alpha1,num1,alpha2 = strmatch(name, "([a-zA-Z]+)([0-9]*)([a-zA-Z]*)Buffs")
                if alpha1 == "Player" then
                    --if PhantomLib.windowStates.PlayerWindow and PhantomLib.buffStates.PlayerWindow then
					if PhantomLib.buffStates.PlayerWindow then
                        hooked.BuffFrame.Show(self, ...)
                    else
                        hooked.BuffFrame.Show(self, false)
                    end
                elseif alpha1 == "Group" and num1 ~= "" then
                    --if PhantomLib.windowStates.GroupWindow and PhantomLib.buffStates.GroupWindow then
					if PhantomLib.buffStates.GroupWindow then
                        hooked.BuffFrame.Show(self, ...)
                    else
                        hooked.BuffFrame.Show(self, false)
                    end
                elseif alpha1 == "TargetWindow" or alpha1 == "FriendlyTargetWindow" then
                    --if PhantomLib.windowStates.TargetWindow and PhantomLib.buffStates.TargetWindow then
					if PhantomLib.buffStates.TargetWindow then
                        hooked.BuffFrame.Show(self, ...)
                    else
                        hooked.BuffFrame.Show(self, false)
                    end
                else
                    hooked.BuffFrame.Show(self, ...)
                end
            end
    end
end

--[[function PhantomLib.InstallPQTrackerHooks()
    if not EA_Window_PublicQuestTracker then return end
    if not hooked.EA_Window_PublicQuestTracker then hooked.EA_Window_PublicQuestTracker = {} end
    
    if not hooked.EA_Window_PublicQuestTracker.UpdateInfluenceBar and
       EA_Window_PublicQuestTracker.UpdateInfluenceBar then
        hooked.EA_Window_PublicQuestTracker.UpdateInfluenceBar = EA_Window_PublicQuestTracker.UpdateInfluenceBar
        EA_Window_PublicQuestTracker.UpdateInfluenceBar =
            function(...)
                hooked.EA_Window_PublicQuestTracker.UpdateInfluenceBar(...)
                WindowSetShowing("EA_Window_PublicQuestTrackerInfluenceBar", PhantomLib.windowStates.InfluenceBar)
                WindowSetShowing("EA_Window_PublicQuestTrackerLocation", PhantomLib.windowStates.InfluenceBar)
            end
    end
end]]--

function PhantomLib.InstallHooks()
    --PhantomLib.InstallPlayerWindowHooks()
    --PhantomLib.InstallGroupWindowHooks()
    --PhantomLib.InstallWarbandWindowHooks()
    --PhantomLib.InstallTargetWindowHooks()
    PhantomLib.InstallBuffHooks()
    PhantomLib.InstallOpenPartyWindowHooks()
    PhantomLib.InstallPlayerAssistHooks()
    --PhantomLib.InstallActionBarHooks()
	PhantomLib.InstallActionBarClusterManagerHooks()
	PhantomLib.InstallEA_ChatWindowHooks()
	PhantomLib.InstallEA_Window_OverheadMapHooks()
    PhantomLib.InstallPetWindowHooks()
    --PhantomLib.InstallPQTrackerHooks()
end

function PhantomLib.EnforceWindowStates()
    --WindowSetShowing("PlayerWindow", PhantomLib.windowStates.PlayerWindow)
	
	-- Force group window hook to activate (hide the pesky pet frames)
	--GroupWindow.PositionGroupMemberWindows(false)
    --WindowSetShowing("GroupWindow", PhantomLib.windowStates.GroupWindow)
    
    --[[if PhantomLib.windowStates.BattlegroupHUD then
        if BattlegroupHUD.Show then BattlegroupHUD.Show() end
    else
        BattlegroupHUD.Hide()
    end
    
    if PhantomLib.windowStates.TargetWindow then
        TargetWindow.UpdateLayoutForTargets()
    else
        WindowSetShowing("PrimaryTargetLayoutWindow", false)
        WindowSetShowing("SecondaryTargetLayoutWindow", false)
    end
    
    if PhantomLib.windowStates.ScenarioGroupWindow then
        for i=1,ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
            local isPressed = ButtonGetPressedFlag("ScenarioGroupWindowGroup"..i.."VisibleButton")
            WindowSetShowing("FloatingScenarioGroup"..i.."Window", isPressed)
        end
    else
        for i=1,ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
            WindowSetShowing("FloatingScenarioGroup"..i.."Window", false)
        end
    end]]--
    
    if OpenPartyWindow then
        if PhantomLib.windowStates.OpenPartySearchButton then
            OpenPartyWindow.UpdateOpenPartyButton()
        else
            WindowSetShowing("OpenPartySearchButton", false)
        end
    end
    
    if PhantomLib.windowStates.MainAssist then
        EA_Button_PlayerAssist.UpdateButtonVisibility()
    else
        if DoesWindowExist("EA_AssistWindowMainAssist") then
            WindowSetShowing("EA_AssistWindowMainAssist", false)
        elseif DoesWindowExist("MainAssist") then
            WindowSetShowing("MainAssist", false)
        end
    end
	
	if QUICK_LOCK_NAME and DoesWindowExist(QUICK_LOCK_NAME) then
		WindowSetShowing(QUICK_LOCK_NAME, PhantomLib.windowStates.ActionBarLockToggler)
	end
	
    if DoesWindowExist("ChatWindowSocialWindowButton") then
        WindowSetShowing("ChatWindowSocialWindowButton", PhantomLib.windowStates.SocialWindowButton)
    end
    
	-- Overhead map components
	WindowSetShowing("EA_Window_OverheadMapAreaNameBackground", PhantomLib.windowStates.OverheadMapArea)
	WindowSetShowing("EA_Window_OverheadMapAreaNameText", PhantomLib.windowStates.OverheadMapArea)
	
	WindowSetShowing("EA_Window_OverheadMapCityRating", PhantomLib.windowStates.OverheadMapCity)
	
	WindowSetShowing("EA_Window_OverheadMapCityRating", PhantomLib.windowStates.OverheadMapCity)
	
	WindowSetShowing("EA_Window_OverheadMapZoomSlider", PhantomLib.windowStates.OverheadMapZoom)
	WindowSetShowing("EA_Window_OverheadMapZoomSliderBackground", PhantomLib.windowStates.OverheadMapZoom)
	
	WindowSetShowing("EA_Window_OverheadMapMapWorldMapButton", PhantomLib.windowStates.OverheadMapWorld)
	
	-- Force scenario buttons to update as necessary
	EA_Window_OverheadMap.UpdateScenarioButtons()
	EA_Window_OverheadMap.UpdateScenarioQueueButton()
	
	-- And the mail icon
	EA_Window_OverheadMap.UpdateMailIcon()
	
	WindowSetShowing("EA_Window_OverheadMapMapFrame", PhantomLib.windowStates.OverheadMapFrame)
	
	WindowSetShowing("EA_Window_OverheadMapFilterMenuButton", PhantomLib.windowStates.OverheadMapPins)
    
    --WindowSetShowing("EA_Window_PublicQuestTrackerInfluenceBar", PhantomLib.windowStates.InfluenceBar)
    --WindowSetShowing("EA_Window_PublicQuestTrackerLocation", PhantomLib.windowStates.InfluenceBar)
    
    -- Update pet window if necessary
    BroadcastEvent(SystemData.Events.PLAYER_PET_UPDATED)
	
	-- Force action bars to relayout as necessary.
	--[[local FORCE_LAYOUT = 42
	ActionBarClusterManager:SetLayoutMode(ActionBarClusterManager:GetLayoutMode(), FORCE_LAYOUT)]]--
	
	-- Force full updates of buff trackers
	-- Group
	for i=GameData.BuffTargetType.GROUP_MEMBER_START,GameData.BuffTargetType.GROUP_MEMBER_END do
		if GroupWindow.Buffs[i+1] then
			GroupWindow.OnEffectsUpdated(i, GetBuffs(i), true)
		end
	end
	-- Player
	PlayerWindow.OnEffectsUpdated(GetBuffs(GameData.BuffTargetType.SELF), true)
	-- Hostile Target
	TargetWindow.OnEffectsUpdated(GameData.BuffTargetType.TARGET_HOSTILE, GetBuffs(GameData.BuffTargetType.TARGET_HOSTILE), true)
	-- Friendly Target
	TargetWindow.OnEffectsUpdated(GameData.BuffTargetType.TARGET_FRIENDLY, GetBuffs(GameData.BuffTargetType.TARGET_FRIENDLY), true)
    
    if DoesWindowExist("EA_Window_OverheadMapMapRallyCall") then
        WindowSetShowing("EA_Window_OverheadMapMapRallyCall", PhantomLib.windowStates.OverheadMapRally)
    end
end

function PhantomLib.EnforceRegisterStates()
    -- Player window
    --[[if PhantomLib.windowStates.PlayerWindow and not PhantomLib.registerStates.PlayerWindow then
        LayoutEditor.RegisterWindow("PlayerWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PLAYER_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PLAYER_WINDOW_DESC ),
                                false, false,
                                true, nil)
        PhantomLib.registerStates.PlayerWindow = true
    elseif not PhantomLib.windowStates.PlayerWindow and PhantomLib.registerStates.PlayerWindow then
        LayoutEditor.UnregisterWindow("PlayerWindow")
        PhantomLib.registerStates.PlayerWindow = false
    end
    
    -- Group window
    if PhantomLib.windowStates.GroupWindow and not PhantomLib.registerStates.GroupWindow then
        LayoutEditor.RegisterWindow("GroupWindow",  
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PARTY_MEMBERS_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PARTY_MEMBERS_DESC ),
                                false, false,
                                true, nil)
        PhantomLib.registerStates.GroupWindow = true
    elseif not PhantomLib.windowStates.GroupWindow and PhantomLib.registerStates.GroupWindow then
        LayoutEditor.UnregisterWindow("GroupWindow")
        PhantomLib.registerStates.GroupWindow = false
    end
    
    -- BattlegroupHUD windows
    if PhantomLib.windowStates.BattlegroupHUD and not PhantomLib.registerStates.BattlegroupHUD then
        for i=1,BattlegroupHUD.NUM_GROUPS do
            LayoutEditor.RegisterWindow("BattlegroupHUDGroup"..i.."LayoutWindow",
                                GetFormatStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_WB_MEMBERS_NAME, { i } ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_WB_MEMBERS_DESC),
                                false, false,
                                false, nil)
        end
        PhantomLib.registerStates.BattlegroupHUD = true
    elseif not PhantomLib.windowStates.BattlegroupHUD and PhantomLib.registerStates.BattlegroupHUD then
        for i=1,BattlegroupHUD.NUM_GROUPS do
            LayoutEditor.UnregisterWindow("BattlegroupHUDGroup"..i.."LayoutWindow")
        end
        PhantomLib.registerStates.BattlegroupHUD = false
    end
    
    -- Target windows
    if PhantomLib.windowStates.TargetWindow and not PhantomLib.registerStates.TargetWindow then
        LayoutEditor.RegisterWindow("PrimaryTargetLayoutWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PRIMARY_TARGET_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_PRIMARY_TARGET_WINDOW_DESC ),
                                false, false,
                                false, nil)
        LayoutEditor.RegisterWindow("SecondaryTargetLayoutWindow",
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SECONDARY_TARGET_WINDOW_NAME ),
                                GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SECONDARY_TARGET_WINDOW_DESC ),
                                false, false,
                                false, nil)
        PhantomLib.registerStates.TargetWindow = true
    elseif not PhantomLib.windowStates.TargetWindow and PhantomLib.registerStates.TargetWindow then
        LayoutEditor.UnregisterWindow("PrimaryTargetLayoutWindow")
        LayoutEditor.UnregisterWindow("SecondaryTargetLayoutWindow")
        PhantomLib.registerStates.TargetWindow = false
    end
    
    -- Scenario group windows
    if PhantomLib.windowStates.ScenarioGroupWindow and not PhantomLib.registerStates.ScenarioGroupWindow then
        for i=1,ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
            LayoutEditor.RegisterWindow("FloatingScenarioGroup"..i.."Window",
            GetFormatStringFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SP_MEMBERS_NAME, {i}),
            GetStringFromTable("HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_SP_MEMBERS_DESC),
            false, false,
            false, nil)
        end
        PhantomLib.registerStates.ScenarioGroupWindow = true
    elseif not PhantomLib.windowStates.ScenarioGroupWindow and PhantomLib.registerStates.ScenarioGroupWindow then
        for i=1,ScenarioGroupWindow.MAX_SCENARIO_GROUPS do
            LayoutEditor.UnregisterWindow("FloatingScenarioGroup"..i.."Window")
        end
        PhantomLib.registerStates.ScenarioGroupWindow = false
    end]]--
    
    -- Open party search button
    if OpenPartyWindow then
        if PhantomLib.windowStates.OpenPartySearchButton and not PhantomLib.registerStates.OpenPartySearchButton then
            LayoutEditor.RegisterWindow("OpenPartySearchButton", L"Open Party Button", L"Open Party Search Button",
                false, false, false, nil)
            PhantomLib.registerStates.OpenPartySearchButton = true
        elseif not PhantomLib.windowStates.OpenPartySearchButton and PhantomLib.registerStates.OpenPartySearchButton then
            LayoutEditor.UnregisterWindow("OpenPartySearchButton")
            PhantomLib.registerStates.OpenPartySearchButton = false
        end
    end
    
    -- Main assist button
    local assistWin = nil
    if DoesWindowExist("EA_AssistWindowMainAssist") then
        assistWin = "EA_AssistWindowMainAssist"
    elseif DoesWindowExist("MainAssist") then
        assistWin = "MainAssist"
    end
    if assistWin then
        if PhantomLib.windowStates.MainAssist and not PhantomLib.registerStates.MainAssist then
            LayoutEditor.RegisterWindow(assistWin,
                        GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ASSIST_WINDOW_NAME ),
                        GetStringFromTable( "HUDStrings", StringTables.HUD.LABEL_HUD_EDIT_ASSIST_WINDOW_DESC ),
                        false, false,
                        true, nil )
            PhantomLib.registerStates.MainAssist = true
        elseif not PhantomLib.windowStates.MainAssist and PhantomLib.registerStates.MainAssist then
            LayoutEditor.UnregisterWindow(assistWin)
            PhantomLib.registerStates.MainAssist = false
        end
    end
	
	-- Force the action bars to unregister and then re-register (so our hook can take effect)
	--[[ActionBarClusterManager:UnregisterClusterWithLayoutEditor()
	ActionBarClusterManager:RegisterClusterWithLayoutEditor()]]--
end

function PhantomLib.EnforceEventStates()
    -- If needbe, register or unregister the player buff update event if buffs aren't being shown.
    --[[if (PhantomLib.buffStates.PlayerWindow and PhantomLib.windowStates.PlayerWindow)
      and not PhantomLib.eventStates.PlayerBuffs then]]--
	if PhantomLib.buffStates.PlayerWindow and not PhantomLib.eventStates.PlayerBuffs then
        WindowRegisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_EFFECTS_UPDATED, "PlayerWindow.OnEffectsUpdated")
        PhantomLib.eventStates.PlayerBuffs = false
    --[[elseif not (PhantomLib.buffStates.PlayerWindow and PhantomLib.windowStates.PlayerWindow)
      and PhantomLib.eventStates.PlayerBuffs then]]--
	elseif not (PhantomLib.buffStates.PlayerWindow) and PhantomLib.eventStates.PlayerBuffs then
        WindowUnregisterEventHandler( "PlayerWindow", SystemData.Events.PLAYER_EFFECTS_UPDATED)
        PhantomLib.eventStates.PlayerBuffs = true
    end
    
    -- If needbe, register or unregister the group buff update event if buffs aren't being shown.
    --[[if (PhantomLib.buffStates.GroupWindow and PhantomLib.windowStates.GroupWindow)
      and not PhantomLib.eventStates.GroupBuffs then]]--
	if PhantomLib.buffStates.GroupWindow and not PhantomLib.eventStates.GroupBuffs then
        RegisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED, "GroupWindow.OnEffectsUpdated")
        PhantomLib.eventStates.GroupBuffs = true
    --[[elseif not (PhantomLib.buffStates.GroupWindow and PhantomLib.windowStates.GroupWindow)
      and PhantomLib.eventStates.GroupBuffs then]]--
	elseif not (PhantomLib.buffStates.GroupWindow) and PhantomLib.eventStates.GroupBuffs then
        UnregisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED, "GroupWindow.OnEffectsUpdated")
        PhantomLib.eventStates.GroupBuffs = false
    end
    
    -- If needbe, register or unregister the target buff update event if buffs aren't being shown.
    --[[if (PhantomLib.buffStates.TargetWindow and PhantomLib.windowStates.TargetWindow)
      and not PhantomLib.eventStates.TargetBuffs then]]--
	if (PhantomLib.buffStates.TargetWindow) and not PhantomLib.eventStates.TargetBuffs then
        WindowRegisterEventHandler("TargetWindow", SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "TargetWindow.OnEffectsUpdated")
        PhantomLib.eventStates.TargetBuffs = false
    --[[elseif not (PhantomLib.buffStates.TargetWindow and PhantomLib.windowStates.TargetWindow)
      and PhantomLib.eventStates.TargetBuffs then]]--
	elseif not (PhantomLib.buffStates.TargetWindow) and PhantomLib.eventStates.TargetBuffs then
        WindowUnregisterEventHandler("TargetWindow", SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED)
        PhantomLib.eventStates.TargetBuffs = true
    end
    
    -- Unfortunately, we can't disable the scenario group events or else the scenario management window wouldn't update properly, and we don't hide that.
end

function PhantomLib.SetWindowShowing(window)
    if window and PhantomLib.windowStates[window] ~= nil then
        PhantomLib.windowStates[window] = true
        return true
    else
        return false
    end
end

function PhantomLib.SetWindowHidden(window)
    if window and PhantomLib.windowStates[window] ~= nil then
        PhantomLib.windowStates[window] = false
        return true
    else
        return false
    end
end

function PhantomLib.SetBuffsShowing(window)
    if window and PhantomLib.buffStates[window] ~= nil then
        PhantomLib.buffStates[window] = true
        return true
    else
        return false
    end
end

function PhantomLib.SetBuffsHidden(window)
    if window and PhantomLib.buffStates[window] ~= nil then
        PhantomLib.buffStates[window] = false
        return true
    else
        return false
    end
end

function PhantomLib.Enforce()
    PhantomLib.EnforceEventStates()
    PhantomLib.EnforceWindowStates()
    PhantomLib.EnforceRegisterStates()
end

function PhantomLib.OnLoad()
	if firstLoad then
		firstLoad = false
		PhantomLib.InstallHooks()
	end
	
    PhantomLib.Enforce()
end

-- Finally, if it hasn't already been registered, set up PhantomLib to perform its duties once everything has loaded.
if not PhantomLib.loadHandlerRegistered then
    RegisterEventHandler(SystemData.Events.LOADING_END, "PhantomLib.OnLoad")
    RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "PhantomLib.OnLoad")
    PhantomLib.loadHandlerRegistered = true
end

--[[if not PhantomLib.scenHandlerRegistered then
	RegisterEventHandler(SystemData.Events.SCENARIO_BEGIN, "PhantomLib.OnLoad")
	PhantomLib.scenHandlerRegistered = true
end]]--

-- Finally, export this instance of PhantomLib to be global, so that event handlers will work
_G["PhantomLib"] = PhantomLib