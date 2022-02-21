local Enemy = Enemy
local g = {}

local pairs = pairs
local GameData = GameData

function Enemy.TalismanAlerterInitialize ()

	Enemy.talismanAlerter = g
	
	-- UI: indicator
	CreateWindow ("EnemyTalismanAlerterIndicator", true)
	LayoutEditor.RegisterWindow ("EnemyTalismanAlerterIndicator", L"Enemy talisman alerter", L"Enemy talisman alerter indicator", false, false, true, nil)
	
	-- UI: config
	g.configDlgSection =
	{
		name = "TalismanAlerter",
		title = L"Talisman alerter",
		templateName = "EnemyTalismanAlerterConfiguration",
		onInitialize = Enemy.TalismanAlerterUI_ConfigDialog_OnInitialize,
		onLoad = Enemy.TalismanAlerterUI_ConfigDialog_OnLoad,
		onSave = Enemy.TalismanAlerterUI_ConfigDialog_OnSave
	};
	
	-- static events
	Enemy.AddEventHandler ("TalismanAlerter", "SettingsChanged", Enemy.TalismanAlerter_OnSettingsChanged)
	
	Enemy.AddEventHandler ("TalismanAlerter", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections, g.configDlgSection)
	end)
	
	Enemy.TriggerEvent ("TalismanAlerterInitialized")
end


function Enemy._TalismanAlerterEnabledChanged (enable)

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable
	
	if (g.isPluginEnabled)
	then
		RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.TalismanAlerter_Update")
		RegisterEventHandler(SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "Enemy.TalismanAlerter_Update")
		RegisterEventHandler(SystemData.Events.UPDATE_ITEM_ENHANCEMENT, "Enemy.TalismanAlerter_Update")
		RegisterEventHandler(SystemData.Events.END_ITEM_ENHANCEMENT, "Enemy.TalismanAlerter_Update")
		
		Enemy.AddEventHandler ("TalismanAlerter", "GroupsPlayerInitialized", Enemy.TalismanAlerter_Update)
		g.wasEnabled = true
	else
		if (g.wasEnabled)
		then
			UnregisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.TalismanAlerter_Update")
			UnregisterEventHandler(SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "Enemy.TalismanAlerter_Update")
			UnregisterEventHandler(SystemData.Events.UPDATE_ITEM_ENHANCEMENT, "Enemy.TalismanAlerter_Update")
			UnregisterEventHandler(SystemData.Events.END_ITEM_ENHANCEMENT, "Enemy.TalismanAlerter_Update")
		end
		
		Enemy.RemoveEventHandler ("TalismanAlerter", "GroupsPlayerInitialized")
	end
end


function Enemy.TalismanAlerter_OnSettingsChanged (settings)

	g.settings = settings
	Enemy._TalismanAlerterEnabledChanged (g.settings.talismanAlerterEnabled);
	
	WindowSetShowing ("EnemyTalismanAlerterIndicator", false)
	g.indicatorAnimated = false
	
	Enemy.TalismanAlerter_Update ()
end


function Enemy.TalismanAlerter_Update ()

	if (not g.isPluginEnabled or not Enemy.groups.player) then return end
	
	local has_empty_slots = (g.configDlgSection.isActive)
	local equipment_data = DataUtils.GetEquipmentData()
	
	if (not has_empty_slots)
	then
		for k,v in pairs (GameData.EquipSlots)
		do
			local item = equipment_data[v]
			
			if (item.numEnhancementSlots > 0 and #item.enhSlot == 0)
			then
				has_empty_slots = true
				break
			end
		end
	end
	
	if (not has_empty_slots or (g.settings.talismanAlerterDisplayMode == 2 and Enemy.groups.player.isInCombat))
	then
		WindowStopAlphaAnimation ("EnemyTalismanAlerterIndicator")
		WindowSetShowing ("EnemyTalismanAlerterIndicator", false)
		g.indicatorAnimated = false
	else
		WindowSetShowing ("EnemyTalismanAlerterIndicator", true)
		WindowSetTintColor ("EnemyTalismanAlerterIndicator", unpack (g.settings.talismanAlerterColorWarning))
		
		if (g.settings.talismanAlerterAnimation and not Enemy.groups.player.isInCombat)
		then
			if (not g.indicatorAnimated)
			then
				WindowStartAlphaAnimation ("EnemyTalismanAlerterIndicator", Window.AnimationType.LOOP, 0.5, 1, 0.5, true, 0, 0)
				g.indicatorAnimated = true
			end
		else
			WindowStopAlphaAnimation ("EnemyTalismanAlerterIndicator")
			WindowSetAlpha ("EnemyTalismanAlerterIndicator", 1)
			g.indicatorAnimated = false
		end
	end
end


--------------------------------------------------------------- UI: Alert indicator
function Enemy.TalismanAlerter_TalismanAlerterIndicator_OnMouseOver ()

	if (not g.isPluginEnabled) then return end

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, L"You have equiped items with empty talisman slots")
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


--------------------------------------------------------------- UI: Configuration
local config_dlg = {}

config_dlg.properties =
{
	talismanAlerterEnabled =
	{
		key = "talismanAlerterEnabled",
		order = 10,
		name = L"Enable alertering on expired talismans",
		type = "bool",
		default = Enemy.DefaultSettings.talismanAlerterEnabled
	},
	
	talismanAlerterDisplayMode =
	{
		key = "talismanAlerterDisplayMode",
		order = 20,
		name = L"Warning indicator",
		type = "select",
		default = Enemy.DefaultSettings.talismanAlerterDisplayMode,
		values =
		{
			{ text = L"show always", value = 1 },
			{ text = L"show only out of combat", value = 2 }
		},
		paddingTop = 40
	},
	talismanAlerterColorWarning =
	{
		key = "talismanAlerterColorWarning",
		order = 30,
		name = L"Warning color",
		type = "color",
		default = Enemy.DefaultSettings.talismanAlerterColorWarning
	},
	talismanAlerterAnimation =
	{
		key = "talismanAlerterAnimation",
		order = 40,
		name = L"Enable warning animation (only out of combat)",
		type = "bool",
		default = Enemy.DefaultSettings.talismanAlerterAnimation
	}
}


function Enemy.TalismanAlerterUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section
	
	local root = config_dlg.section.windowName.."ContentScrollChild"
	config_dlg.cwn = root.."Config"
	Enemy.CreateConfigurationWindow (config_dlg.cwn, root, config_dlg.properties, Enemy.TalismanAlerterUI_ConfigDialog_TestSettings)
	
	ScrollWindowUpdateScrollRect (config_dlg.section.windowName.."Content")
end


function Enemy.TalismanAlerterUI_ConfigDialog_OnLoad (section)

	config_dlg.isLoading = true
	
	config_dlg.talismanAlerterEnabled = Enemy.Settings.talismanAlerterEnabled
	config_dlg.talismanAlerterDisplayMode = Enemy.Settings.talismanAlerterDisplayMode
	config_dlg.talismanAlerterColorWarning = Enemy.clone (Enemy.Settings.talismanAlerterColorWarning)
	config_dlg.talismanAlerterAnimation = Enemy.Settings.talismanAlerterAnimation
	
	Enemy.ConfigurationWindowLoadData (config_dlg.cwn, config_dlg)
	
	config_dlg.isLoading = false
	
	Enemy.TalismanAlerterUI_ConfigDialog_TestSettings ()
end


function Enemy.TalismanAlerterUI_ConfigDialog_OnReset (section)

	for k, v in pairs (Enemy.Settings)
	do
		if (not k:match("^talismanAlerter.*")) then continue end
		Enemy.Settings[k] = nil
	end
	
	Enemy.Print ("Talisman alerter settings has been reset")
	InterfaceCore.ReloadUI ()
end


function Enemy.TalismanAlerterUI_ConfigDialog_TestSettings ()

	if (config_dlg.isLoading) then return end
	
	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, config_dlg)
	Enemy.TalismanAlerter_OnSettingsChanged (config_dlg)
end


function Enemy.TalismanAlerterUI_ConfigDialog_OnSave (section)

	Enemy.TalismanAlerterUI_ConfigDialog_TestSettings ()
	
	Enemy.Settings.talismanAlerterEnabled = config_dlg.talismanAlerterEnabled
	Enemy.Settings.talismanAlerterDisplayMode = config_dlg.talismanAlerterDisplayMode
	Enemy.Settings.talismanAlerterColorWarning = Enemy.clone (config_dlg.talismanAlerterColorWarning)
	Enemy.Settings.talismanAlerterAnimation = config_dlg.talismanAlerterAnimation
	
	return true
end




