local Enemy = Enemy
local g = {}

function Enemy.ScenarioAlerterInitialize ()

	Enemy.scenarioAlerter = g
	
	-- static events
	Enemy.AddEventHandler ("ScenarioAlerter", "SettingsChanged", Enemy.ScenarioAlerter_OnSettingsChanged)
	
	Enemy.AddEventHandler ("ScenarioAlerter", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections,
		{
			name = "ScenarioAlerter",
			title = L"Scenarion alerter",
			templateName = "EnemyScenarioAlerterConfiguration",
			onInitialize = Enemy.ScenarioAlerterUI_ConfigDialog_OnInitialize,
			onLoad = Enemy.ScenarioAlerterUI_ConfigDialog_OnLoad,
			onSave = Enemy.ScenarioAlerterUI_ConfigDialog_OnSave
		})
	end)
	
	Enemy.TriggerEvent ("ScenarioAlerterInitialized")
end


function Enemy._ScenarioAlerterEnabledChanged (enable)

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable
	
	if (g.isPluginEnabled)
	then
		RegisterEventHandler (SystemData.Events.SCENARIO_SHOW_JOIN_PROMPT, "Enemy.ScenarioAlerter_OnScenarioShowJoinPrompt")
		RegisterEventHandler (SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW, "Enemy.ScenarioAlerter_OnScenarioInstanceJoinNow")
		RegisterEventHandler (SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "Enemy.ScenarioAlerter_OnInteractLeaveScenarioQueue")
		g.wasEnabled = true
	else
		if (g.wasEnabled)
		then
			UnregisterEventHandler (SystemData.Events.SCENARIO_SHOW_JOIN_PROMPT, "Enemy.ScenarioAlerter_OnScenarioShowJoinPrompt")
			UnregisterEventHandler (SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW, "Enemy.ScenarioAlerter_OnScenarioInstanceJoinNow")
			UnregisterEventHandler (SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "Enemy.ScenarioAlerter_OnInteractLeaveScenarioQueue")
		end
	end
end


function Enemy.ScenarioAlerter_OnSettingsChanged (settings)

	g.settings = settings
	Enemy._ScenarioAlerterEnabledChanged (g.settings.scenarioAlerterEnabled);
end




local function GetStartingScenarioName ()

	if (not GameData.ScenarioData or not GameData.ScenarioData.startingScenario) then return nil end
	
	local name = GetScenarioName (GameData.ScenarioData.startingScenario)
	if (name == L"")
	then
		name = L"Scenario #"..GameData.ScenarioData.startingScenario
	end
	
	return name
end


function Enemy.ScenarioAlerter_OnScenarioShowJoinPrompt ()

	if (not Enemy.IsPlayerInGroup ()) then return end
	
	local name = GetStartingScenarioName ()
	if (not name) then return end
	
	g.pop = name
	Enemy.SendChatMessage (L"/p Scenario pop "..name)
end


function Enemy.ScenarioAlerter_OnScenarioInstanceJoinNow ()

	if (not Enemy.IsPlayerInGroup ()) then return end
	
	local name = GetStartingScenarioName ()
	if (not name) then return end
	
	Enemy.SendChatMessage (L"/p I join scenario "..name)
	g.pop = nil
end


function Enemy.ScenarioAlerter_OnInteractLeaveScenarioQueue ()

	if (not Enemy.IsPlayerInGroup ()) then return end
	
	local name = GetStartingScenarioName ()
	if (not name or g.pop ~= name) then return end
	
	Enemy.SendChatMessage (L"/p I leave scenario "..name)
	g.pop = nil
end


--------------------------------------------------------------- UI: Configuration
local config_dlg = {}


function Enemy.ScenarioAlerterUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section
	LabelSetText (config_dlg.section.windowName.."EnabledLabel", L"Enable scenario alerts")
end


function Enemy.ScenarioAlerterUI_ConfigDialog_OnLoad (section)

	config_dlg.scenarioAlerterEnabled = Enemy.Settings.scenarioAlerterEnabled
	ButtonSetPressedFlag (config_dlg.section.windowName.."Enabled", config_dlg.scenarioAlerterEnabled)
end


function Enemy.ScenarioAlerterUI_ConfigDialog_OnEnabledChanged ()

	config_dlg.scenarioAlerterEnabled = not config_dlg.scenarioAlerterEnabled
	ButtonSetPressedFlag (config_dlg.section.windowName.."Enabled", config_dlg.scenarioAlerterEnabled)
	Enemy.ScenarioAlerter_OnSettingsChanged (config_dlg)
end


function Enemy.ScenarioAlerterUI_ConfigDialog_OnSave (section)

	Enemy.Settings.scenarioAlerterEnabled = config_dlg.scenarioAlerterEnabled
	
	return true
end






