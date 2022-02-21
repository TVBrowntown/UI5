--[[ 
Queue Queuer
Warhammer Online: Age of Reckoning UI modification that simplifies warband
scenario queueing with other scenario-oriented features as well.
    
Copyright (C) 2008-2010  Dillon "Rhekua" DeLoss
rhekua@msn.com		    www.rhekua.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

QueueQueuer_GUI = {}
QueueQueuer_GUI_MapButtons = {}

local initialized = false
local TIME_DELAY = 1
local timeLeft = TIME_DELAY -- start in TIME_DELAY seconds

function QueueQueuer_GUI_MapButtons.OnInitialize()
	LayoutEditor.RegisterWindow( "QueueQueuer_GUI_MapButtons", L"QQ", L"Queue Queuer Button", false, false, true, nil )

	CreateWindow("QueueQueuer_GUI_MapButton_DISABLED", false)
	CreateWindow("QueueQueuer_GUI_MapButton_QUEUER", false)
	CreateWindow("QueueQueuer_GUI_MapButton_COOLDOWN", false)
end

function QueueQueuer_GUI_MapButtons.OnShutdown()
	LayoutEditor.UnregisterWindow( "QueueQueuer_GUI_MapButtons" )
end

function QueueQueuer_GUI.UpdateBlacklistCheckboxes()
	local i = 0
	local tierTab = ""
	for key, value in pairs(QueueQueuer_SavedVariables["blacklist"]) do
		--i = 0
		-- tier 1
		if ( key == "Gates of Ekrund"  ) then
			i = 1
		elseif ( key == "Nordenwatch" ) then
			i = 2
		elseif ( key == "Khaine's Embrace" ) then
			i = 3
		-- tier 2
		elseif ( key == "Mourkain Temple" ) then
			i = 4
		elseif ( key == "Phoenix Gate" ) then
			i = 5
		elseif ( key == "Stonetroll Crossing" ) then
			i = 6
		-- tier 3
		elseif ( key == "Black Fire Basin" ) then
			i = 7
		elseif ( key == "Doomfist Crater" ) then
			i = 8
		elseif ( key == "Talabec Dam" ) then
			i = 9
		elseif ( key == "Highpass Cemetery" ) then
			i = 10
		elseif ( key == "Tor Anroc" ) then
			i = 11
		elseif ( key == "Lost Temple of Isha" ) then
			i = 12
		-- tier 4
		elseif ( key == "Thunder Valley" ) then
			i = 13
		elseif ( key == "Logrin's Forge" ) then
			i = 14
		elseif (key == "Battle for Praag" ) then
			i = 15
		elseif ( key == "Grovod Caverns" ) then
			i = 16
		elseif ( key == "Serpent's Passage" ) then
			i = 17
		elseif ( key == "Dragon's Bane" ) then
			i = 18
		-- special scenarios
		-- tier 4
		elseif ( key == "Altdorf War Quarters" ) then
			i = 19
		elseif ( key == "The Undercroft" ) then
			i = 20
		elseif ( key == "Maw of Madness" ) then
			i = 21
		elseif ( key == "Reikland Hills" ) then
			i = 22
		elseif ( key == "Kadrin Valley Pass" ) then
			i = 23
		elseif ( key == "Gromril Crossing" ) then
			i = 24
		elseif ( key == "Black Crag Keep" ) then
			i = 25
		elseif ( key == "Howling Gorge" ) then
			i = 26
		elseif ( key == "Karaz-a-Karak Gates" ) then
			i = 27
		elseif ( key == "Eight Peaks Gates" ) then
			i = 28
		elseif ( key == "Twisting Tower" ) then
			i = 29
		elseif ( key == "Castle Fragendorf" ) then
			i = 30
		elseif ( key == "Altdorf" ) then
			i = 31
		elseif ( key == "Blood of the Black Cairn" ) then
			i = 32
		elseif ( key == "College of Corruption" ) then
			i = 33
      	elseif ( key == "The Eternal Citadel" ) then
			i = 34
		-- RoR specific SCs
		elseif ( key == "Caledor Woods (Ranked)" ) then
			i = 35
		elseif ( key == "Caledor Woods (Ranked Solo)" ) then
			i = 36
		elseif ( key == "The Ironclad" ) then
			i = 37
		elseif ( key == "Maw of Madness (Ranked)" ) then
			i = 38
		elseif ( key == "Maw of Madness (Ranked Solo)" ) then
			i = 39
		elseif ( key == "Thanquol's Stand: Ratnarök" ) then
			i = 40
		elseif ( key == "Ranked Solo" ) then
			i = 41
		elseif ( key == "Ranked" ) then
			i = 42
		end

		
		if ( i < 4 ) then
			tierTab = "TabTier1"
		elseif ( i < 7 ) then
			tierTab = "TabTier2"
		elseif ( i < 13 ) then
			tierTab = "TabTier3"
		else
			tierTab = "TabTier4"
		end

		LabelSetText( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. i .. "Label", QueueQueuer.FixName(QueueQueuer.ScenarioNames[key]) )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. i .. "Button", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. i .. "Button", value )
	end

end


function QueueQueuer_GUI.OnInitialize()
    
	LabelSetText( "QueueQueuer_GUI_TitleBarText", L"Queue Queuer" )
	ButtonSetText( "QueueQueuer_GUI_BlacklistAllButton", L"Blacklist All" )
	ButtonSetText( "QueueQueuer_GUI_BlacklistNoneButton", L"Blacklist None" )
	ButtonSetText( "QueueQueuer_GUI_QueuerCheckButton", L"Queuer Check" )
	ButtonSetText( "QueueQueuer_GUI_JoinButton", L"Join Queues" )
	ButtonSetText( "QueueQueuer_GUI_LeaveButton", L"Leave Queues" )

	ButtonSetText("QueueQueuer_GUI_TabsTier1", L"Tier 1")
	ButtonSetText("QueueQueuer_GUI_TabsTier2", L"Tier 2")
	ButtonSetText("QueueQueuer_GUI_TabsTier3", L"Tier 3")
	ButtonSetText("QueueQueuer_GUI_TabsTier4", L"Tier 4")
	ButtonSetText("QueueQueuer_GUI_TabsHelp", L"Help")
	ButtonSetText("QueueQueuer_GUI_TabsAbout", L"About")

	local tier = GetZoneTier()
	if ( tier ~= nil and tier > 0 ) then
		QueueQueuer_GUI.ChangeTab( tier )
	else
		QueueQueuer_GUI.ChangeTab( 1 )
	end

	QueueQueuer_GUI.UpdateBlacklistCheckboxes()

	LabelSetText( "QueueQueuer_GUI_OptionCheckBox1Label", L"Enabled" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_OptionCheckBox1Button", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox1Button", QueueQueuer_SavedVariables["enabled"] )
	LabelSetText( "QueueQueuer_GUI_OptionCheckBox2Label", L"Group Queuer (Resets each session)" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_OptionCheckBox2Button", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox2Button", QueueQueuer.IsQueuer() )
	LabelSetText( "QueueQueuer_GUI_OptionCheckBox3Label", L"Press 'Wait a minute' after 55 seconds" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_OptionCheckBox3Button", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox3Button", QueueQueuer_SavedVariables["autojoin"] )
	LabelSetText( "QueueQueuer_GUI_OptionCheckBox4Label", L"Queue for scenarios while solo" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_OptionCheckBox4Button", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox4Button", QueueQueuer_SavedVariables["autoqueue"] )

	-- make the context menus
	CreateWindowFromTemplate("QueueQueuer_GUI_Context1", "ChatContextMenuItemCheckBox", "Root")
		LabelSetText( "QueueQueuer_GUI_Context1CheckBoxLabel", L"Enabled" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_Context1CheckBox", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_Context1CheckBox", QueueQueuer_SavedVariables["enabled"] )
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context1", "OnLButtonUp", "QueueQueuer_GUI.ContextCheckBox_OnLButtonUp")
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context1", "OnMouseOver", "QueueQueuer_GUI.ContextCheckBox_OnMouseOver")
		WindowSetId("QueueQueuer_GUI_Context1", 1)
		WindowSetShowing("QueueQueuer_GUI_Context1", false)

	CreateWindowFromTemplate("QueueQueuer_GUI_Context2", "ChatContextMenuItemCheckBox", "Root")
		LabelSetText( "QueueQueuer_GUI_Context2CheckBoxLabel", L"Queuer" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_Context2CheckBox", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_Context2CheckBox", QueueQueuer.IsQueuer() )
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context2", "OnLButtonUp", "QueueQueuer_GUI.ContextCheckBox_OnLButtonUp")
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context2", "OnMouseOver", "QueueQueuer_GUI.ContextCheckBox_OnMouseOver")
		WindowSetId("QueueQueuer_GUI_Context2", 2)
		WindowSetShowing("QueueQueuer_GUI_Context2", false)

	CreateWindowFromTemplate("QueueQueuer_GUI_Context3", "ChatContextMenuItemCheckBox", "Root")
		LabelSetText( "QueueQueuer_GUI_Context3CheckBoxLabel", L"Autojoin" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_Context3CheckBox", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_Context3CheckBox", QueueQueuer_SavedVariables["autojoin"] )
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context3", "OnLButtonUp", "QueueQueuer_GUI.ContextCheckBox_OnLButtonUp")
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context3", "OnMouseOver", "QueueQueuer_GUI.ContextCheckBox_OnMouseOver")
		WindowSetId("QueueQueuer_GUI_Context3", 3)
		WindowSetShowing("QueueQueuer_GUI_Context3", false)

	CreateWindowFromTemplate("QueueQueuer_GUI_Context4", "ChatContextMenuItemCheckBox", "Root")
		LabelSetText( "QueueQueuer_GUI_Context4CheckBoxLabel", L"Autoqueue" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_Context4CheckBox", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_Context4CheckBox", QueueQueuer_SavedVariables["autoqueue"] )
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context4", "OnLButtonUp", "QueueQueuer_GUI.ContextCheckBox_OnLButtonUp")
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context4", "OnMouseOver", "QueueQueuer_GUI.ContextCheckBox_OnMouseOver")
		WindowSetId("QueueQueuer_GUI_Context4", 4)
		WindowSetShowing("QueueQueuer_GUI_Context4", false)

	CreateWindowFromTemplate("QueueQueuer_GUI_Context5", "ChatContextMenuItemCheckBox", "Root")
		LabelSetText( "QueueQueuer_GUI_Context5CheckBoxLabel", L"Autobalance" )
		ButtonSetStayDownFlag( "QueueQueuer_GUI_Context5CheckBox", true )
		ButtonSetPressedFlag( "QueueQueuer_GUI_Context5CheckBox", QueueQueuer_SavedVariables["autobalance"] )
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context5", "OnLButtonUp", "QueueQueuer_GUI.ContextCheckBox_OnLButtonUp")
		WindowRegisterCoreEventHandler("QueueQueuer_GUI_Context5", "OnMouseOver", "QueueQueuer_GUI.ContextCheckBox_OnMouseOver")
		WindowSetId("QueueQueuer_GUI_Context5", 5)
		WindowSetShowing("QueueQueuer_GUI_Context5", false)

	for i = 1, EA_Window_ScenarioLobby.MAX_SCENARIOS do
		CreateWindowFromTemplate("QueueQueuer_GUI_ContextScenario" .. i, "ChatContextMenuItemCheckBox", "Root")
			LabelSetText( "QueueQueuer_GUI_ContextScenario" .. i .. "CheckBoxLabel", L"Scenario #" .. towstring(i) )
			ButtonSetStayDownFlag( "QueueQueuer_GUI_ContextScenario" .. i .. "CheckBox", true )
			ButtonSetPressedFlag( "QueueQueuer_GUI_ContextScenario" .. i .. "CheckBox", false )
			WindowRegisterCoreEventHandler("QueueQueuer_GUI_ContextScenario" .. i, "OnLButtonUp", "QueueQueuer_GUI.ContextScenarioCheckBox_OnLButtonUp")
			WindowSetId("QueueQueuer_GUI_ContextScenario" .. i, 1)
			WindowSetShowing("QueueQueuer_GUI_ContextScenario" .. i, false)
	end

	initialized = true
end

function QueueQueuer_GUI.OnShutdown()
	initialized = false
end

function QueueQueuer_GUI.ReloadWindows()
	QueueQueuer_GUI.DestroyWindows()
	QueueQueuer_GUI.CreateWindows()
end

function QueueQueuer_GUI.CreateWindows()
 	CreateWindow("QueueQueuer_GUI_MapButtons", true)
	CreateWindow("QueueQueuer_GUI_MapButton_DISABLED", false)
	CreateWindow("QueueQueuer_GUI_MapButton_QUEUER", false)
	CreateWindow("QueueQueuer_GUI_MapButton_COOLDOWN", false)
	CreateWindow("QueueQueuer_GUI", false)
end

function QueueQueuer_GUI.DestroyWindows()
 	DestroyWindow("QueueQueuer_GUI_MapButtons")
 	DestroyWindow("QueueQueuer_GUI_MapButton_DISABLED")
 	DestroyWindow("QueueQueuer_GUI_MapButton_QUEUER")
 	DestroyWindow("QueueQueuer_GUI_MapButton_COOLDOWN")
      DestroyWindow("QueueQueuer_GUI")
end

function QueueQueuer_GUI.CreateContextMenu(anker)
	EA_Window_ContextMenu.CreateContextMenu( "QueueQueuer_GUI_ContextMenu", 1, L"Queue Queuer" )
	--EA_Window_ContextMenu.MIN_WIDTH = 300 -- Not sure how to handle this correctly
	EA_Window_ContextMenu.AddMenuDivider( 1 )
	EA_Window_ContextMenu.AddUserDefinedMenuItem( "QueueQueuer_GUI_Context1", 1 )
	EA_Window_ContextMenu.AddUserDefinedMenuItem( "QueueQueuer_GUI_Context2", 1 )
	EA_Window_ContextMenu.AddUserDefinedMenuItem( "QueueQueuer_GUI_Context3", 1 )
	EA_Window_ContextMenu.AddUserDefinedMenuItem( "QueueQueuer_GUI_Context4", 1 )
	EA_Window_ContextMenu.AddUserDefinedMenuItem( "QueueQueuer_GUI_Context5", 1 )
	EA_Window_ContextMenu.AddMenuDivider( 1 )
	EA_Window_ContextMenu.AddMenuItem( L"Blacklist", nil, true, false, 1 ) -- lazy way of making a title
	ButtonSetTextColor("EA_Window_ContextMenu1DefaultItem1", Button.ButtonState.DISABLED, 255, 255, 255)

	for id = 1, EA_Window_ScenarioLobby.MAX_SCENARIOS do
		if (GameData.ScenarioQueueData[id].id ~= 0) then


			local scName = GetScenarioName(GameData.ScenarioQueueData[id].id)--:gsub(L"Ranked", L"R"):gsub(L"Solo", L"S") --:sub(1,20)
			if (scName ~= L"Ranked" and scName ~= L"Ranked Solo") then
				scName = scName:gsub(L"Ranked", L"R"):gsub(L"Solo", L"S")
			end
			
			LabelSetText( "QueueQueuer_GUI_ContextScenario" .. id .. "CheckBoxLabel", scName)

			--d(GetScenarioName(GameData.ScenarioQueueData[id].id))
			--d(GameData.ScenarioQueueData[id].id)

			for key, value in pairs(QueueQueuer_SavedVariables["blacklist"]) do
				if ( QueueQueuer.ScenarioNames[key] == GetScenarioName(GameData.ScenarioQueueData[id].id) ) then
					ButtonSetPressedFlag( "QueueQueuer_GUI_ContextScenario" .. id .. "CheckBox", value )
					if ( value ) then
						LabelSetTextColor( "QueueQueuer_GUI_ContextScenario" .. id .. "CheckBoxLabel", 125, 125, 125 )
					else
						LabelSetTextColor( "QueueQueuer_GUI_ContextScenario" .. id .. "CheckBoxLabel", 255, 255, 255 )
					end
				end
			end

			EA_Window_ContextMenu.AddUserDefinedMenuItem( "QueueQueuer_GUI_ContextScenario" .. id, 1 )
		end
	end
	if ( GameData.ScenarioQueueData[1].id == 0 ) then
		EA_Window_ContextMenu.AddMenuItem( L"No Scenarios", nil, true, true, 1 )
	end

			
	EA_Window_ContextMenu.AddCascadingMenuItem( L"Cooldowns", QueueQueuer_GUI.CreateCooldownsContextMenu, false, 1 )
	EA_Window_ContextMenu.AddMenuDivider( 1 )
	EA_Window_ContextMenu.AddMenuItem( L"Options", QueueQueuer_GUI.OptionsButton_OnLButtonUp, false, true, 1 )
	EA_Window_ContextMenu.AddMenuItem( L"Queuer Check", QueueQueuer_GUI.QueuerCheckButton_OnLButtonUp, not QueueQueuer.IsQueuer(), true, 1 )
	EA_Window_ContextMenu.AddMenuItem( L"Leave Queues", QueueQueuer_GUI.LeaveButton_OnLButtonUp, false, true, 1 )
	EA_Window_ContextMenu.AddMenuItem( L"Join Queues", QueueQueuer_GUI.JoinButton_OnLButtonUp, false, true, 1 )
	EA_Window_ContextMenu.Finalize( 1, 
		{ 
			["XOffset"] = 0,
			["YOffset"] = -10,
			["Point"] = "top",
			["RelativePoint"] = "bottom",
			["RelativeTo"] = anker,
		} )

end

function QueueQueuer_GUI.CreateCooldownsContextMenu()
	EA_Window_ContextMenu.CreateContextMenu( "QueueQueuer_GUI_CooldownsContextMenu", 2, L"Scenario Cooldowns" )

	local cooldownsExist = false
	for k, v in pairs(QueueQueuer.GetCooldownBlacklist()) do
		local cooldownTime = v / 60
		if ( cooldownTime > 1 ) then
			cooldownTime = towstring(math.floor(cooldownTime + 0.5)) .. L"m"
		else
			cooldownTime = towstring(v) .. L"s"
		end
		EA_Window_ContextMenu.AddMenuItem( GetScenarioName(k) .. L" - " .. cooldownTime, QueueQueuer_GUI.CooldownsContextMenu_OnLButtonUp, false, false, 2 )
		cooldownsExist = true
	end
	
	if ( not cooldownsExist ) then
		EA_Window_ContextMenu.AddMenuItem( L"No Cooldowns", nil, true, false, 2 )
	end

	EA_Window_ContextMenu.Finalize( 2, nil )
end

function QueueQueuer_GUI.CooldownsContextMenu_OnLButtonUp()
	local windowName = SystemData.ActiveWindow.name
	local scenarioName = ButtonGetText( windowName )

	for k, v in pairs(QueueQueuer.GetCooldownBlacklist()) do
		if ( wstring.find(QueueQueuer.FixName(scenarioName), QueueQueuer.FixName(GetScenarioName(k)), 1, true) ~= nil ) then
			QueueQueuer.GetCooldownBlacklist()[k] = nil
			break
		end
	end
	
	ButtonSetText( windowName, L"Cooldown Removed" )
	ButtonSetDisabledFlag( windowName, true )
end

function QueueQueuer_GUI.ContextScenarioCheckBox_OnLButtonUp()
	local windowName = SystemData.ActiveWindow.name
	local toggle = ButtonGetPressedFlag( windowName .. "CheckBox" ) == false

	--get real scenario id
	local menuId = tonumber(string.match(SystemData.ActiveWindow.name, "%d"))
	local scId = -1
	for id = 1, EA_Window_ScenarioLobby.MAX_SCENARIOS do
		if (GameData.ScenarioQueueData[id].id ~= 0) then
			if (id == menuId) then
				scId = GameData.ScenarioQueueData[id].id
			end
		end	
	end
	local scenarioName = GetScenarioName(scId)

	--d(scenarioName)
	--d(scId)
			
	for key, value in pairs(QueueQueuer_SavedVariables["blacklist"]) do
		if ( QueueQueuer.CompareWStrings(QueueQueuer.ScenarioNames[key], scenarioName) ) then
			QueueQueuer_SavedVariables["blacklist"][key] = toggle
			ButtonSetPressedFlag( windowName .. "CheckBox", toggle )
			if ( toggle ) then
				LabelSetTextColor( SystemData.ActiveWindow.name .. "CheckBoxLabel", 125, 125, 125 )
			else
				LabelSetTextColor( SystemData.ActiveWindow.name .. "CheckBoxLabel", 255, 255, 255 )
			end
			QueueQueuer_GUI.UpdateBlacklistCheckboxes()
			break
		end		
	end
end

function QueueQueuer_GUI.BlacklistScenarioCheck()
	if ( GetZoneTier() ~= 4 ) then
		return
	end

	local tierTab = "TabTier4"
	for i = 13, 42 do
		ButtonSetDisabledFlag( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. i .. "Button", true )
	end
	for i = 1, EA_Window_ScenarioLobby.MAX_SCENARIOS do
		for j = 13, 42 do
		
			if ( QueueQueuer.CompareWStrings( LabelGetText( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. j .. "Label" ),
							 	GetScenarioName(GameData.ScenarioQueueData[i].id) ) ) then

				ButtonSetDisabledFlag( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. j .. "Button", false )
			end
		end
	end
end

function QueueQueuer_GUI.OnUpdate(elapsed)
-- update settings every second just in-case a command was fired

	if ( initialized == false ) then
		return
	end

	timeLeft = timeLeft - elapsed
	if timeLeft > 0 then
		return -- cut out early
	end
	timeLeft = TIME_DELAY -- reset to TIME_DELAY seconds
	-- this will run roughly every second. If TIME_DELAY were 2, it'd run every 2 seconds.

	QueueQueuer_GUI.BlacklistScenarioCheck()

	ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox1Button", QueueQueuer_SavedVariables["enabled"] )
	ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox2Button", QueueQueuer.IsQueuer() )
	ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox3Button", QueueQueuer_SavedVariables["autojoin"] )
	ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox4Button", QueueQueuer_SavedVariables["autoqueue"] )
end

function QueueQueuer_GUI.MapButton_OnUpdate(elapsed)
-- update settings every second just in-case a command was fired

	if ( initialized == false ) then
		return
	end

	timeLeft = timeLeft - elapsed
	if timeLeft > 0 then
		return -- cut out early
	end
	timeLeft = TIME_DELAY -- reset to TIME_DELAY seconds
	-- this will run roughly every second. If TIME_DELAY were 2, it'd run every 2 seconds.

	if ( QueueQueuer_SavedVariables["enabled"] == true ) then
		if ( QueueQueuer.QueueCooldown() == true ) then
			QueueQueuer_GUI.ShowMapButton( "QueueQueuer_GUI_MapButton_COOLDOWN" )
		elseif ( QueueQueuer.IsQueuer() == true ) then
			QueueQueuer_GUI.ShowMapButton( "QueueQueuer_GUI_MapButton_QUEUER" )
		else
			QueueQueuer_GUI.ShowMapButton( "QueueQueuer_GUI_MapButton" )
		end
	else
		QueueQueuer_GUI.ShowMapButton( "QueueQueuer_GUI_MapButton_DISABLED" )
	end
end

function QueueQueuer_GUI.Close_OnLButtonUp()
	WindowSetShowing("QueueQueuer_GUI", false )
end

function QueueQueuer_GUI.MapButton_OnLButtonUp()
	if ( GetScenarioQueueData() ~= nil 
		or WindowGetShowing("EA_Window_ScenarioStarting")
		or WindowGetShowing("EA_Window_ScenarioJoinPrompt") ) then
			
		QueueQueuer_GUI.LeaveButton_OnLButtonUp()
	else
		QueueQueuer_GUI.JoinButton_OnLButtonUp()
	end
	--[[
	local showing = WindowGetShowing( "QueueQueuer_GUI" )
	WindowSetShowing("QueueQueuer_GUI", showing == false )

	if ( showing == false ) then
		local tier = GetZoneTier()
		if ( tier ~= nil and tier > 0 ) then
			QueueQueuer_GUI.ChangeTab( tier )
		end
	end
	]]--
end

function QueueQueuer_GUI.MapButton_OnRButtonUp()
	QueueQueuer_GUI.CreateContextMenu("QueueQueuer_GUI_MapButtons")
	--PlaySound(GameData.Sound.BETA_WARNING)
end

function QueueQueuer_GUI.MapButton_OnMouseOver()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
	local row = 1
	local column = 1
	local tiptext = L"Queue Queuer v" .. towstring(QueueQueuer.GetVersion())
	if ( QueueQueuer_SavedVariables["enabled"] == true ) then
		tiptext = tiptext .. L":\nENABLED"
		if ( QueueQueuer.QueueCooldown() == true  ) then
			tiptext = tiptext .. L", ON COOLDOWN"
		elseif ( QueueQueuer.IsQueuer() == true ) then
			tiptext = tiptext .. L", GROUP QUEUER"
		end
	else
		tiptext = tiptext .. L":\nDISABLED"
	end

	if ( QueueQueuer_SavedVariables["autojoin"] == true ) then
		tiptext = tiptext .. L", AUTOJOIN"
	end
	if ( QueueQueuer_SavedVariables["autoqueue"] == true ) then
		tiptext = tiptext .. L", SOLO AUTOQUEUE"
	end
	if ( QueueQueuer_SavedVariables["autobalance"] == true ) then
		tiptext = tiptext .. L", AUTOBALANCE"
	end
	
	-- print out info for the warband leader
	local warbandLeader = PartyUtils.GetWarbandLeader()
	if ( warbandLeader ~= nil and QueueQueuer.CompareWStrings( warbandLeader["name"], GameData.Player.name ) ) then
		tiptext = tiptext .. L"\n\nGroup Queuers:"
		local numBros = 0
		for k, v in pairs(QueueQueuer.GetQueuerList()) do
			tiptext = tiptext .. L"\n     " .. k .. L" - Group " .. towstring(v)
			numBros = numBros + 1
		end
		if ( numBros == 0 ) then
			tiptext = tiptext .. L"\n     Please press Queuer Check."
		end
	end
		
	tiptext = tiptext .. L"\n\nLeft click to join/leave queues.\nRight click to view options."
	Tooltips.SetTooltipText( row, column, tiptext )
	
	Tooltips.Finalize()
	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function QueueQueuer_GUI.BlacklistCheckBox_OnLButtonUp()
	local buttonId = WindowGetId(SystemData.ActiveWindow.name)
	local tierTab = ""
	if ( buttonId < 4 ) then
		tierTab = "TabTier1"
	elseif ( buttonId < 7 ) then
		tierTab = "TabTier2"
	elseif ( buttonId < 13 ) then
		tierTab = "TabTier3"
	else
		tierTab = "TabTier4"
	end
	local toggle = ButtonGetPressedFlag("QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. buttonId .. "Button") == false 
	
	for key,value in pairs(QueueQueuer_SavedVariables["blacklist"]) do
	-- laziest way I could possibly handle this
		if ( QueueQueuer.CompareWStrings(QueueQueuer.ScenarioNames[key], LabelGetText( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. buttonId .. "Label" )) ) then
			ButtonSetPressedFlag( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. buttonId .. "Button", toggle )
			QueueQueuer_SavedVariables["blacklist"][key] = toggle
			break -- found it, leave
		end
	end
end

function QueueQueuer_GUI.ShowMapButton( buttonName )
	if ( buttonName == nil or WindowGetShowing( buttonName ) == true ) then
		return
	end 
	WindowSetShowing("QueueQueuer_GUI_MapButton", false )
	WindowSetShowing("QueueQueuer_GUI_MapButton_DISABLED", false )
	WindowSetShowing("QueueQueuer_GUI_MapButton_QUEUER", false )
	WindowSetShowing("QueueQueuer_GUI_MapButton_COOLDOWN", false )

	WindowSetShowing(buttonName, true )
end

function QueueQueuer_GUI.OnMouseOverTab()
end

function QueueQueuer_GUI.OnLButtonUpTab()
	local buttonId = WindowGetId(SystemData.ActiveWindow.name)
	QueueQueuer_GUI.ChangeTab( buttonId )
end

function QueueQueuer_GUI.BlacklistAll( toggle )

	local iteratorStart = 0
	local iteratorEnd = 0
	local tierTab = ""

	if ( WindowGetShowing("QueueQueuer_GUI_TabTier1") ) then
		-- 1-3
		iteratorStart = 1
		iteratorEnd = 3
		tierTab = "TabTier1"
	elseif ( WindowGetShowing("QueueQueuer_GUI_TabTier2") ) then
		-- 4-6
		iteratorStart = 4
		iteratorEnd = 6
		tierTab = "TabTier2"
	elseif ( WindowGetShowing("QueueQueuer_GUI_TabTier3") ) then
		-- 7-12
		iteratorStart = 7
		iteratorEnd = 12
		tierTab = "TabTier3"
	elseif ( WindowGetShowing("QueueQueuer_GUI_TabTier4") ) then
		-- 13-42
		iteratorStart = 13
		iteratorEnd = 42
		tierTab = "TabTier4"
	else
		return
	end

	for buttonId=iteratorStart,iteratorEnd do
		for key,value in pairs(QueueQueuer_SavedVariables["blacklist"]) do
		-- laziest way I could possibly handle this
			if ( QueueQueuer.CompareWStrings(QueueQueuer.ScenarioNames[key], LabelGetText( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. buttonId .. "Label" )) ) then
				ButtonSetPressedFlag( "QueueQueuer_GUI_" .. tierTab .. "_BlacklistCheckBox" .. buttonId .. "Button", toggle )
				QueueQueuer_SavedVariables["blacklist"][key] = toggle
				break -- found it, leave
			end
		end
	end
end

function QueueQueuer_GUI.ChangeTab( tabId )

	ButtonSetPressedFlag("QueueQueuer_GUI_TabsTier1", false )
	ButtonSetPressedFlag("QueueQueuer_GUI_TabsTier2", false )
	ButtonSetPressedFlag("QueueQueuer_GUI_TabsTier3", false )
	ButtonSetPressedFlag("QueueQueuer_GUI_TabsTier4", false )
	ButtonSetPressedFlag("QueueQueuer_GUI_TabsHelp", false )
	ButtonSetPressedFlag("QueueQueuer_GUI_TabsAbout", false )

	WindowSetShowing("QueueQueuer_GUI_TabTier1", false )
	WindowSetShowing("QueueQueuer_GUI_TabTier2", false )
	WindowSetShowing("QueueQueuer_GUI_TabTier3", false )
	WindowSetShowing("QueueQueuer_GUI_TabTier4", false )
	WindowSetShowing("QueueQueuer_GUI_TabHelp", false )
	WindowSetShowing("QueueQueuer_GUI_TabAbout", false )

	if ( tabId < 5 ) then
		WindowSetShowing("QueueQueuer_GUI_TabTier" .. tabId, true )
		ButtonSetPressedFlag("QueueQueuer_GUI_TabsTier" .. tabId, true  )
	elseif ( tabId == 5 ) then
		WindowSetShowing("QueueQueuer_GUI_TabHelp", true  )
		ButtonSetPressedFlag("QueueQueuer_GUI_TabsHelp", true  )
	else
		WindowSetShowing("QueueQueuer_GUI_TabAbout", true  )
		ButtonSetPressedFlag("QueueQueuer_GUI_TabsAbout", true  )
	end
	
end

function QueueQueuer_GUI.ContextCheckBox_OnLButtonUp()
	local buttonId = WindowGetId(SystemData.ActiveWindow.name)
	local toggle = ButtonGetPressedFlag("QueueQueuer_GUI_Context" .. buttonId .. "CheckBox") == false 
	
	ButtonSetPressedFlag( "QueueQueuer_GUI_Context" .. buttonId .. "CheckBox", toggle )
	if ( buttonId == 1 ) then
	-- enabled
		if ( toggle == true ) then
			QueueQueuer.HandleSlashCmd("enable")
		else
			QueueQueuer.HandleSlashCmd("disable")
		end
	elseif ( buttonId == 2 ) then
	-- queuer
		QueueQueuer.HandleSlashCmd("queuer")
		QueueQueuer_GUI.CreateContextMenu("QueueQueuer_GUI_MapButtons")
	elseif ( buttonId == 3 ) then
	-- autojoin
		QueueQueuer.HandleSlashCmd("autojoin")
	elseif ( buttonId == 4 ) then
	-- autoqueue
		QueueQueuer.HandleSlashCmd("autoqueue")
	elseif ( buttonId == 5 ) then
	-- autobalance
		QueueQueuer.HandleSlashCmd("autobalance")
	end
end

function QueueQueuer_GUI.ContextCheckBox_OnMouseOver()
	local buttonId = WindowGetId(SystemData.ActiveWindow.name)
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil ) 
    
	local row = 1
	local column = 1
	local tiptext = LabelGetText("QueueQueuer_GUI_Context" .. buttonId .. "CheckBoxLabel") .. L": "
	if ( buttonId == 1 ) then
	-- enabled
		tiptext = tiptext .. L"Enables or disables Queue Queuer."
	elseif ( buttonId == 2 ) then
	-- queuer
		tiptext = tiptext .. L"Whether or not you are queuer for your group."
	elseif ( buttonId == 3 ) then
	-- autojoin
		tiptext = tiptext .. L"When a scenario 'pops', Queue Queuer automatically presses 'wait a minute' after 55 seconds."
	elseif ( buttonId == 4 ) then
	-- autoqueue
		tiptext = tiptext .. L"Automatically joins available scenario queues based on your current scenario blacklist and cooldowns."
	elseif ( buttonId == 5 ) then
	-- autobalance
		tiptext = tiptext .. L"Automatically balances group queuers to their own warband group when you press Queuer Check.\nAlso sets group queuers as warband assistants.\nGenerates a randomized one-time use key to prevent unauthorized access."
	end
	Tooltips.SetTooltipText( row, column, tiptext )
	
	Tooltips.Finalize()
	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT)
end

function QueueQueuer_GUI.OptionCheckBox_OnLButtonUp()
	local buttonId = WindowGetId(SystemData.ActiveWindow.name)
	local toggle = ButtonGetPressedFlag("QueueQueuer_GUI_OptionCheckBox" .. buttonId .. "Button") == false 
	
	ButtonSetPressedFlag( "QueueQueuer_GUI_OptionCheckBox" .. buttonId .. "Button", toggle )
	if ( DoesWindowExist("QueueQueuer_GUI_Context1") ) then
		ButtonSetPressedFlag( "QueueQueuer_GUI_Context" .. buttonId .. "CheckBox", toggle )
	end
	if ( buttonId == 1 ) then
	-- enabled
		if ( toggle == true ) then
			QueueQueuer.HandleSlashCmd("enable")
		else
			QueueQueuer.HandleSlashCmd("disable")
		end
	elseif ( buttonId == 2 ) then
	-- queuer
		QueueQueuer.HandleSlashCmd("queuer")
	elseif ( buttonId == 3 ) then
	-- autojoin
		QueueQueuer.HandleSlashCmd("autojoin")
	elseif ( buttonId == 4 ) then
	-- autoqueue
		QueueQueuer.HandleSlashCmd("autoqueue")
	end
end

function QueueQueuer_GUI.JoinButton_OnLButtonUp()
	-- LAZY
	QueueQueuer.HandleSlashCmd("join")
end


function QueueQueuer_GUI.QueuerCheckButton_OnLButtonUp()
	-- SO LAZY
	QueueQueuer.HandleSlashCmd("check")
end

function QueueQueuer_GUI.LeaveButton_OnLButtonUp()
	-- SO VERY LAZY
	QueueQueuer.HandleSlashCmd("leave")
end

function QueueQueuer_GUI.OptionsButton_OnLButtonUp()
	-- New way to show the old options menu
	local showing = WindowGetShowing( "QueueQueuer_GUI" )
	WindowSetShowing("QueueQueuer_GUI", showing == false )

	if ( showing == false ) then
		local tier = GetZoneTier()
		if ( tier ~= nil and tier > 0 ) then
			QueueQueuer_GUI.ChangeTab( tier )
		end
	end
end

function QueueQueuer_GUI.BlacklistAllButton_OnLButtonUp()
	QueueQueuer_GUI.BlacklistAll( true )
end

function QueueQueuer_GUI.BlacklistNoneButton_OnLButtonUp()
	QueueQueuer_GUI.BlacklistAll( false )
end
