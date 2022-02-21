UI5.Fixes = {}

function UI5.Fixes()

	RegisterEventHandler(SystemData.Events.PLAYER_PET_UPDATED, "UI5.PetFixes")
	RegisterEventHandler(SystemData.Events.PLAYER_PET_STATE_UPDATED, "UI5.PetFixes")
	RegisterEventHandler(SystemData.Events.ENTER_WORLD, "UI5.PetFixes")
	RegisterEventHandler(SystemData.Events.LOADING_END, "UI5.PetFixes")
	RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "UI5.PetFixes")
	RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "UI5.HidePages")
	RegisterEventHandler(SystemData.Events.ENTER_WORLD, "UI5.HidePages")
	RegisterEventHandler(SystemData.Events.LOADING_END, "UI5.HidePages")
	RegisterEventHandler(SystemData.Events.ENTER_WORLD, "UI5.TacticsWindow")
	
	--RegisterEventHandler(SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "UI5.InCombatFix")

	if DoesWindowExist("MenuBarWindow") then WindowSetShowing("MenuBarWindow", false) end
	if DoesWindowExist("PetHealthWindow") then WindowSetShowing("PetHealthWindow", false) end
end

function UI5.HidePages()
	if DoesWindowExist("EA_ActionBar1PageSelector") then WindowSetShowing("EA_ActionBar1PageSelector", false) end
	if DoesWindowExist("EA_ActionBar2PageSelector") then WindowSetShowing("EA_ActionBar2PageSelector", false) end
	if DoesWindowExist("EA_ActionBar3PageSelector") then WindowSetShowing("EA_ActionBar3PageSelector", false) end
	if DoesWindowExist("EA_ActionBar4PageSelector") then WindowSetShowing("EA_ActionBar4PageSelector", false) end
	if DoesWindowExist("EA_ActionBar5PageSelector") then WindowSetShowing("EA_ActionBar5PageSelector", false) end
	if DoesWindowExist("EA_ActionBar6PageSelector") then WindowSetShowing("EA_ActionBar6PageSelector", false) end
	if DoesWindowExist("EA_ActionBar7PageSelector") then WindowSetShowing("EA_ActionBar7PageSelector", false) end
	if DoesWindowExist("EA_ActionBar8PageSelector") then WindowSetShowing("EA_ActionBar8PageSelector", false) end
end

function UI5.TacticsWindow()
	if DoesWindowExist("EA_TacticsEditor") then
		local x, y = WindowGetDimensions("EA_TacticsEditor")
		WindowSetDimensions("EA_TacticsEditor", 300, 50)
	end
end

function UI5.PetFixes()
	if GameData.Player.Pet.healthPercent == 0 or nil then
		if DoesWindowExist("EA_CareerResourceWindowActionBar") then WindowSetShowing("EA_CareerResourceWindowActionBar", false) end
		if DoesWindowExist("PetHealthWindow") then WindowSetShowing("PetHealthWindow", false) end
	else
		if DoesWindowExist("EA_CareerResourceWindowActionBar") then WindowSetShowing("EA_CareerResourceWindowActionBar", true) end
		if DoesWindowExist("PetHealthWindow") then WindowSetShowing("PetHealthWindow", false) end
	end
	--if DoesWindowExist("PetHealthWindow") then WindowSetShowing("PetHealthWindow", false) end
end

function UI5.CombatCheck()
	if (GameData.Player.inCombat) then
		SystemData.Settings.Names.enemynpcs = false 						-- HIDE ENEMY NAMES
	else
		SystemData.Settings.Names.enemynpcs = true							-- SHOW ENEMY NAMES
	end
	BroadcastEvent( SystemData.Events.USER_SETTINGS_CHANGED )				-- APPLY CHANGES
end