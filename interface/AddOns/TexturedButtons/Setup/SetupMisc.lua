TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.Misc = 
{
	WindowName = "TexturedButtonsSetupMiscWindow",
};

local windowName = TexturedButtons.Setup.Misc.WindowName;
local localization = TexturedButtons.Localization.GetMapping();

local actionButtonPickUpModifiers = { nil, SystemData.ButtonFlags.ALT, SystemData.ButtonFlags.CONTROL, SystemData.ButtonFlags.SHIFT };

function TexturedButtons.Setup.Misc.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Misc.Title"]);
	LabelSetText(windowName .. "HideActiveCheckboxLabel", localization["Setup.Misc.HideActive"]);
	LabelSetText(windowName .. "HideGlowCheckboxLabel", localization["Setup.Misc.HideGlow"]);
	LabelSetText(windowName .. "SaveQuicklockCheckboxLabel", localization["Setup.Misc.SaveQuicklock"]);
	LabelSetText(windowName .. "MovableCheckboxLabel", localization["Setup.Misc.MovableQuicklock"]);
	LabelSetText(windowName .. "HideQuicklockCheckboxLabel", localization["Setup.Misc.HideQuicklock"]);
	LabelSetText(windowName .. "EnableCooldownPulseCheckboxLabel", localization["Setup.Misc.CooldownPulse"]);
	
	LabelSetText(windowName .. "CustomGlowLabel", localization["Setup.Misc.CustomGlow"]);
	ComboBoxClearMenuItems(windowName .. "CustomGlowComboBox");
	ComboBoxAddMenuItem(windowName .. "CustomGlowComboBox", localization["Setup.Misc.CustomGlow.None"]);
	ComboBoxAddMenuItem(windowName .. "CustomGlowComboBox", localization["Setup.Misc.CustomGlow.CustomSize"]);
	ComboBoxAddMenuItem(windowName .. "CustomGlowComboBox", localization["Setup.Misc.CustomGlow.All"]);
	
	LabelSetText(windowName .. "ActionButtonPickUpModifierLabel", localization["Setup.Misc.ActionButtonPickUpModifier"]);
	ComboBoxClearMenuItems(windowName .. "ActionButtonPickUpModifierComboBox");
	ComboBoxAddMenuItem(windowName .. "ActionButtonPickUpModifierComboBox", localization["Setup.Misc.ActionButtonPickUpModifier.None"]);
	ComboBoxAddMenuItem(windowName .. "ActionButtonPickUpModifierComboBox", localization["Setup.Misc.ActionButtonPickUpModifier.Alt"]);
	ComboBoxAddMenuItem(windowName .. "ActionButtonPickUpModifierComboBox", localization["Setup.Misc.ActionButtonPickUpModifier.Ctrl"]);
	ComboBoxAddMenuItem(windowName .. "ActionButtonPickUpModifierComboBox", localization["Setup.Misc.ActionButtonPickUpModifier.Shift"]);
	
	TexturedButtons.Setup.Misc.LoadSettings();
	
end

function TexturedButtons.Setup.Misc.LoadSettings()

	local settings = TexturedButtons.Settings;
	ButtonSetPressedFlag(windowName .. "HideActive" .. "Button", (settings.Misc.HideActive == true));
	ButtonSetPressedFlag(windowName .. "HideGlow" .. "Button", (settings.Misc.HideGlow == true));
	ButtonSetPressedFlag(windowName .. "SaveQuicklock" .. "Button", (settings.Misc.SaveQuicklock == true));
	ButtonSetPressedFlag(windowName .. "HideQuicklock" .. "Button", (settings.Misc.HideQuicklock == true));
	ButtonSetPressedFlag(windowName .. "EnableCooldownPulse" .. "Button", (settings.Misc.CooldownPulse == true));
	ComboBoxSetSelectedMenuItem(windowName .. "CustomGlowComboBox", settings.Misc.CustomGlow or 1);
	
	local modifierIndex = nil;
	for index, value in pairs(actionButtonPickUpModifiers) do
		if (settings.Misc.ActionButtonPickUpModifier == value) then
			modifierIndex = index;
			break;
		end
	end
	ComboBoxSetSelectedMenuItem(windowName .. "ActionButtonPickUpModifierComboBox", modifierIndex or 1);
	
end

function TexturedButtons.Setup.Misc.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.Misc.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.Misc.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.Misc.OnHidden()

	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.Misc.OnCloseLUp()

	TexturedButtons.Setup.Misc.Hide();

end

function TexturedButtons.Setup.Misc.OnHideActiveLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideActive" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideActive" .. "Button", isChecked);
	
	TexturedButtons.Settings.Misc.HideActive = isChecked;
	
end

function TexturedButtons.Setup.Misc.OnHideGlowLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideGlow" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideGlow" .. "Button", isChecked);
	
	TexturedButtons.Settings.Misc.HideGlow = isChecked;
	TexturedButtons.UpdateTints();
	
end

local function SaveQuicklock(saveQuicklock)

	if (saveQuicklock) then
		TexturedButtons.SaveQuicklock();
	else
		ActionBarClusterPositions[ActionBarClusterManager.m_Settings:Get("layoutMode")][QUICK_LOCK_NAME] = nil;
	end

end

function TexturedButtons.Setup.Misc.OnSaveQuicklockLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "SaveQuicklock" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "SaveQuicklock" .. "Button", isChecked);
	
	SaveQuicklock(isChecked);
	TexturedButtons.Settings.Misc.SaveQuicklock = isChecked;
	TexturedButtons.RegisterLayoutEditorQuicklock();

end

function TexturedButtons.Setup.Misc.OnMovableQuicklockLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "MovableQuicklock" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "MovableQuicklock" .. "Button", isChecked);
	local saveQuicklock = TexturedButtons.Settings.Misc.SaveQuicklock;
	
	WindowSetMovable(QUICK_LOCK_NAME, isChecked);
	
	if (saveQuicklock) then
		SaveQuicklock(true);
	end

end

function TexturedButtons.Setup.Misc.OnHideQuicklockLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideQuicklock" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideQuicklock" .. "Button", isChecked);
	local saveQuicklock = TexturedButtons.Settings.Misc.SaveQuicklock;
	
	WindowSetShowing(QUICK_LOCK_NAME, not isChecked);
	TexturedButtons.Settings.Misc.HideQuicklock = isChecked;
	
	if (saveQuicklock) then
		SaveQuicklock(true);
	end

end

function TexturedButtons.Setup.Misc.OnActionButtonPickUpModifierChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ActionButtonPickUpModifierComboBox");
	
	TexturedButtons.Settings.Misc.ActionButtonPickUpModifier = actionButtonPickUpModifiers[value];

end

function TexturedButtons.Setup.Misc.OnEnableCooldownPulseLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "EnableCooldownPulse" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnableCooldownPulse" .. "Button", isChecked);
	
	TexturedButtons.Settings.Misc.CooldownPulse = isChecked;

end

function TexturedButtons.Setup.Misc.OnCustomGlowChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CustomGlowComboBox");
	
	TexturedButtons.Settings.Misc.CustomGlow = value;
	TexturedButtons.UpdateCustomGlow()

end