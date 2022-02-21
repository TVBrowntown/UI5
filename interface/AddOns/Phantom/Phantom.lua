Phantom = {}

local PhantomLib = LibStub("PhantomLib")

local init = {
        windows = {
            --PlayerWindow = true,
            --GroupWindow = true,
            --BattlegroupHUD = true,
            --TargetWindow = true,
            --ScenarioGroupWindow = true,
            PetWindow = true,
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
            --[[InfluenceBar = true,
            PetStance = true,
            PetActionBar = true,
            StanceBar = true,]]--
        },
        buffs = {
            PlayerWindow = true,
            GroupWindow = true,
            TargetWindow = true,
        },
    }

if not Phantom.Settings then
    Phantom.Settings = init
else
    for k,v in pairs(init.windows) do
        if not Phantom.Settings.windows[k] then Phantom.Settings.windows[k] = v end
    end
    for k,v in pairs(init.buffs) do
        if not Phantom.Settings.buffs[k] then Phantom.Settings.buffs[k] = v end
    end
end

function Phantom.CloseSettingsWindow()
    WindowSetShowing("PhantomSettings", false)
end

function Phantom.ImplementSettings()
    
    for k,v in pairs(Phantom.Settings.windows) do
        if v then
            PhantomLib.SetWindowShowing(k)
        else
            PhantomLib.SetWindowHidden(k)
        end
    end
    
    for k,v in pairs(Phantom.Settings.buffs) do
        if v then
            PhantomLib.SetBuffsShowing(k)
        else
            PhantomLib.SetBuffsHidden(k)
        end
    end
    
    PhantomLib.Enforce()
    
end

function Phantom.SaveSettings()

    --Phantom.Settings.windows.PlayerWindow = ButtonGetPressedFlag("PhantomSettingsHidePlayer")
    --Phantom.Settings.windows.GroupWindow = ButtonGetPressedFlag("PhantomSettingsHideGroup")
    --Phantom.Settings.windows.TargetWindow = ButtonGetPressedFlag("PhantomSettingsHideTarget")
    --Phantom.Settings.windows.BattlegroupHUD = ButtonGetPressedFlag("PhantomSettingsHideWarband")
    --Phantom.Settings.windows.ScenarioGroupWindow = ButtonGetPressedFlag("PhantomSettingsHideScenario")
    Phantom.Settings.windows.PetWindow = ButtonGetPressedFlag("PhantomSettingsHidePet")
    Phantom.Settings.windows.MainAssist = ButtonGetPressedFlag("PhantomSettingsHideMainAssist")
	Phantom.Settings.windows.ActionBarLockToggler = ButtonGetPressedFlag("PhantomSettingsHideBarLock")
	Phantom.Settings.windows.SocialWindowButton = ButtonGetPressedFlag("PhantomSettingsHideSocial")
    --Phantom.Settings.windows.InfluenceBar = ButtonGetPressedFlag("PhantomSettingsHideInfluence")
    --Phantom.Settings.windows.StanceBar = ButtonGetPressedFlag("PhantomSettingsHideStanceBar")
    --Phantom.Settings.windows.PetStance = ButtonGetPressedFlag("PhantomSettingsHidePetStance")
    --Phantom.Settings.windows.PetActionBar = ButtonGetPressedFlag("PhantomSettingsHidePetAction")
	
	--[[Phantom.Settings.windows.ActionBar1 = ButtonGetPressedFlag("PhantomSettingsHideBar1")
	Phantom.Settings.windows.ActionBar2 = ButtonGetPressedFlag("PhantomSettingsHideBar2")
	Phantom.Settings.windows.ActionBar3 = ButtonGetPressedFlag("PhantomSettingsHideBar3")
	Phantom.Settings.windows.ActionBar4 = ButtonGetPressedFlag("PhantomSettingsHideBar4")]]--
	Phantom.Settings.windows.OverheadMapArea = ButtonGetPressedFlag("PhantomSettingsHideMapArea")
	Phantom.Settings.windows.OverheadMapWorld = ButtonGetPressedFlag("PhantomSettingsHideMapWorld")
	Phantom.Settings.windows.OverheadMapCity = ButtonGetPressedFlag("PhantomSettingsHideMapCity")
	Phantom.Settings.windows.OverheadMapZoom = ButtonGetPressedFlag("PhantomSettingsHideMapZoom")
	Phantom.Settings.windows.OverheadMapScenario = ButtonGetPressedFlag("PhantomSettingsHideMapScen")
	Phantom.Settings.windows.OverheadMapMail = ButtonGetPressedFlag("PhantomSettingsHideMapMail")
	Phantom.Settings.windows.OverheadMapPins = ButtonGetPressedFlag("PhantomSettingsHideMapPins")
	Phantom.Settings.windows.OverheadMapFrame = ButtonGetPressedFlag("PhantomSettingsHideMapFrame")
    Phantom.Settings.windows.OverheadMapRally = ButtonGetPressedFlag("PhantomSettingsHideMapRally")
	
    Phantom.Settings.buffs.PlayerWindow = ButtonGetPressedFlag("PhantomSettingsHidePlayerBuffs")
    Phantom.Settings.buffs.GroupWindow = ButtonGetPressedFlag("PhantomSettingsHideGroupBuffs")
    Phantom.Settings.buffs.TargetWindow = ButtonGetPressedFlag("PhantomSettingsHideTargetBuffs")
    
    Phantom.ImplementSettings()

end

function Phantom.PopulateWindow()

    --ButtonSetPressedFlag("PhantomSettingsHidePlayer", Phantom.Settings.windows.PlayerWindow)
    --ButtonSetPressedFlag("PhantomSettingsHideGroup", Phantom.Settings.windows.GroupWindow)
    --ButtonSetPressedFlag("PhantomSettingsHideTarget", Phantom.Settings.windows.TargetWindow)
    --ButtonSetPressedFlag("PhantomSettingsHideWarband", Phantom.Settings.windows.BattlegroupHUD)
    --ButtonSetPressedFlag("PhantomSettingsHideScenario", Phantom.Settings.windows.ScenarioGroupWindow)
    ButtonSetPressedFlag("PhantomSettingsHidePet", Phantom.Settings.windows.PetWindow)
    ButtonSetPressedFlag("PhantomSettingsHideMainAssist", Phantom.Settings.windows.MainAssist)
	ButtonSetPressedFlag("PhantomSettingsHideBarLock", Phantom.Settings.windows.ActionBarLockToggler)
	ButtonSetPressedFlag("PhantomSettingsHideSocial", Phantom.Settings.windows.SocialWindowButton)
    --[[ButtonSetPressedFlag("PhantomSettingsHideInfluence", Phantom.Settings.windows.InfluenceBar)
    ButtonSetPressedFlag("PhantomSettingsHideStanceBar", Phantom.Settings.windows.StanceBar)
    ButtonSetPressedFlag("PhantomSettingsHidePetStance", Phantom.Settings.windows.PetStance)
    ButtonSetPressedFlag("PhantomSettingsHidePetAction", Phantom.Settings.windows.PetActionBar)]]--
	
	--[[ButtonSetPressedFlag("PhantomSettingsHideBar1", Phantom.Settings.windows.ActionBar1)
	ButtonSetPressedFlag("PhantomSettingsHideBar2", Phantom.Settings.windows.ActionBar2)
	ButtonSetPressedFlag("PhantomSettingsHideBar3", Phantom.Settings.windows.ActionBar3)
	ButtonSetPressedFlag("PhantomSettingsHideBar4", Phantom.Settings.windows.ActionBar4)]]--
	ButtonSetPressedFlag("PhantomSettingsHideMapArea", Phantom.Settings.windows.OverheadMapArea)
	ButtonSetPressedFlag("PhantomSettingsHideMapWorld", Phantom.Settings.windows.OverheadMapWorld)
	ButtonSetPressedFlag("PhantomSettingsHideMapCity", Phantom.Settings.windows.OverheadMapCity)
	ButtonSetPressedFlag("PhantomSettingsHideMapZoom", Phantom.Settings.windows.OverheadMapZoom)
	ButtonSetPressedFlag("PhantomSettingsHideMapScen", Phantom.Settings.windows.OverheadMapScenario)
	ButtonSetPressedFlag("PhantomSettingsHideMapMail", Phantom.Settings.windows.OverheadMapMail)
	ButtonSetPressedFlag("PhantomSettingsHideMapPins", Phantom.Settings.windows.OverheadMapPins)
	ButtonSetPressedFlag("PhantomSettingsHideMapFrame", Phantom.Settings.windows.OverheadMapFrame)
    ButtonSetPressedFlag("PhantomSettingsHideMapRally", Phantom.Settings.windows.OverheadMapRally)

    if DoesWindowExist("EA_Window_OverheadMapMapRallyCall") then
        WindowSetShowing("PhantomSettingsHideMapRally", true)
        WindowSetShowing("PhantomSettingsHideMapRallyLabel", true)
    else
        WindowSetShowing("PhantomSettingsHideMapRally", false)
        WindowSetShowing("PhantomSettingsHideMapRallyLabel", false)
    end
    
	ButtonSetPressedFlag("PhantomSettingsHidePlayerBuffs", Phantom.Settings.buffs.PlayerWindow)
    ButtonSetPressedFlag("PhantomSettingsHideGroupBuffs", Phantom.Settings.buffs.GroupWindow)
    ButtonSetPressedFlag("PhantomSettingsHideTargetBuffs", Phantom.Settings.buffs.TargetWindow)
    
end

function Phantom.Show()
    WindowSetShowing("PhantomSettings", true)
end

function Phantom.OnLoad()    
    Phantom.ImplementSettings()
    
    if LibSlash and not LibSlash.IsSlashCmdRegistered("phantom") then
        LibSlash.RegisterSlashCmd("phantom", Phantom.Show)
    end
end

function Phantom.Initialize()
    CreateWindow("PhantomSettings", false)
    
    LabelSetText("PhantomSettingsTitleBarText", L"Phantom")
    
    LabelSetText("PhantomSettingsHidePlayerLabel", L"Self (Player) Frame")
    --ButtonSetCheckButtonFlag("PhantomSettingsHidePlayer", true)
    ButtonSetCheckButtonFlag("PhantomSettingsHidePlayerBuffs", true)
    
    LabelSetText("PhantomSettingsHideGroupLabel", L"Group Members")
    --ButtonSetCheckButtonFlag("PhantomSettingsHideGroup", true)
    ButtonSetCheckButtonFlag("PhantomSettingsHideGroupBuffs", true)
    
    LabelSetText("PhantomSettingsHideTargetLabel", L"Target Frames")
    --ButtonSetCheckButtonFlag("PhantomSettingsHideTarget", true)
    ButtonSetCheckButtonFlag("PhantomSettingsHideTargetBuffs", true)
    
    --[[LabelSetText("PhantomSettingsHideWarbandLabel", L"Warband Groups")
    ButtonSetCheckButtonFlag("PhantomSettingsHideWarband", true)
    
    LabelSetText("PhantomSettingsHideScenarioLabel", L"Scenario Groups")
    ButtonSetCheckButtonFlag("PhantomSettingsHideScenario", true)]]--
    
    LabelSetText("PhantomSettingsHidePetLabel", L"Pet Status")
    ButtonSetCheckButtonFlag("PhantomSettingsHidePet", true)
    
    LabelSetText("PhantomSettingsHideMainAssistLabel", L"Main Assist Button")
    ButtonSetCheckButtonFlag("PhantomSettingsHideMainAssist", true)
    
	LabelSetText("PhantomSettingsHideBarLockLabel", L"Action Bar Lock Icon")
    ButtonSetCheckButtonFlag("PhantomSettingsHideBarLock", true)
	
	LabelSetText("PhantomSettingsHideSocialLabel", L"Social Window 'Heads'")
    ButtonSetCheckButtonFlag("PhantomSettingsHideSocial", true)
    
    --[[LabelSetText("PhantomSettingsHideInfluenceLabel", L"Influence Bar")
    ButtonSetCheckButtonFlag("PhantomSettingsHideInfluence", true)
    
    LabelSetText("PhantomSettingsHideStanceBarLabel", L"Stance Bar")
    ButtonSetCheckButtonFlag("PhantomSettingsHideStanceBar", true)
    
    LabelSetText("PhantomSettingsHidePetStanceLabel", L"Pet Stance Control")
    ButtonSetCheckButtonFlag("PhantomSettingsHidePetStance", true)
    
    LabelSetText("PhantomSettingsHidePetActionLabel", L"Pet Action Bar")
    ButtonSetCheckButtonFlag("PhantomSettingsHidePetAction", true)]]--
	
	--[[for i=1,4 do
		LabelSetText("PhantomSettingsHideBar"..i.."Label", L"Action Bar #"..towstring(i))
		ButtonSetCheckButtonFlag("PhantomSettingsHideBar"..i, true)
	end]]--
	
	LabelSetText("PhantomSettingsHideMapAreaLabel", L"Minimap Area Text")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapArea", true)
	
	LabelSetText("PhantomSettingsHideMapWorldLabel", L"Minimap Globe Button")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapWorld", true)
	
	LabelSetText("PhantomSettingsHideMapCityLabel", L"Minimap City Status")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapCity", true)
	
	LabelSetText("PhantomSettingsHideMapZoomLabel", L"Minimap Zoom Bar")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapZoom", true)
	
	LabelSetText("PhantomSettingsHideMapScenLabel", L"Minimap Scenario Buttons")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapScen", true)
	
	LabelSetText("PhantomSettingsHideMapMailLabel", L"Minimap Mail Icon")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapMail", true)
	
	LabelSetText("PhantomSettingsHideMapPinsLabel", L"Minimap Filters Pin")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapPins", true)
	
	LabelSetText("PhantomSettingsHideMapFrameLabel", L"Minimap Frame")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapFrame", true)
    
    LabelSetText("PhantomSettingsHideMapRallyLabel", L"Minimap Rally Button")
	ButtonSetCheckButtonFlag("PhantomSettingsHideMapRally", true)
	
    LabelSetWordWrap("PhantomSettingsInstructionsLabel", true)
    LabelSetText("PhantomSettingsInstructionsLabel",
        L"First checkbox is for window, second checkbox is for buffs.")
    
    LabelSetWordWrap("PhantomSettingsInstructions2Label", true)
    LabelSetText("PhantomSettingsInstructions2Label",
        L"Check a box to show that item, uncheck to hide. Settings save when window is closed.")
        
    RegisterEventHandler(SystemData.Events.LOADING_END, "Phantom.OnLoad")
    RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "Phantom.OnLoad")
end