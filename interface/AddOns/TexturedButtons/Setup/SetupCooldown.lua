TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.Cooldown = 
{
	WindowName = "TexturedButtonsSetupCooldownWindow",
};

local windowName = TexturedButtons.Setup.Cooldown.WindowName;
local localization = TexturedButtons.Localization.GetMapping();

local hoverColorExample = nil;

function TexturedButtons.Setup.Cooldown.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Cooldown.Title"]);
	LabelSetText(windowName .. "EnableCheckboxLabel", localization["Setup.Cooldown.Enable"]);
	LabelSetText(windowName .. "HideFlashCheckboxLabel", localization["Setup.Cooldown.HideFlash"]);
	
	LabelSetText(windowName .. "CooldownAnimation", localization["Setup.Cooldown.CooldownAnimation"]);
	LabelSetText(windowName .. "CooldownAnimationColor", localization["Strings.Color"]);
	LabelSetText(windowName .. "CooldownAnimationAlpha", localization["Strings.Alpha"]);
	
	LabelSetText(windowName .. "RemoveCooldownSCheckboxLabel", localization["Setup.Cooldown.RemoveCooldownS"]);
	LabelSetText(windowName .. "ShowGlobalCooldownTextCheckboxLabel", localization["Setup.Cooldown.ShowGlobalCooldownText"]);
	LabelSetText(windowName .. "EnableButtonTintingCheckboxLabel", localization["Setup.Cooldown.EnableButtonTinting"]);
	
	TexturedButtons.Setup.Cooldown.LoadSettings();
	
end

function TexturedButtons.Setup.Cooldown.LoadSettings()

	local settings = TexturedButtons.Settings;
	
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", (settings.Cooldown.Enabled == true));
	ButtonSetPressedFlag(windowName .. "HideFlash" .. "Button", (settings.Cooldown.HideFlash == true));
	ButtonSetPressedFlag(windowName .. "RemoveCooldownS" .. "Button", (settings.Cooldown.RemoveS == true));
	ButtonSetPressedFlag(windowName .. "ShowGlobalCooldownText" .. "Button", (settings.Cooldown.ShowGlobalCooldownText == true));
	ButtonSetPressedFlag(windowName .. "EnableButtonTinting" .. "Button", (settings.Cooldown.EnableButtonTinting == true));
	
	SliderBarSetCurrentPosition(windowName .. "CooldownAnimationAlphaSlider", settings.Cooldown.Alpha);
	
	local color = settings.Cooldown.Tint;
	WindowSetTintColor(windowName .. "CooldownAnimationColorExampleColor", color.R, color.G, color.B);	

	TexturedButtons.Setup.Cooldown.OnSlideCooldownAlpha();
	
end

function TexturedButtons.Setup.Cooldown.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.Cooldown.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.Cooldown.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.Cooldown.OnHidden()

	TexturedButtons.Setup.SelectColor.Hide();
	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.Cooldown.OnCloseLUp()

	TexturedButtons.Setup.Cooldown.Hide();

end

function TexturedButtons.Setup.Cooldown.OnEnableLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "Enable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", isChecked);
	
	TexturedButtons.Settings.Cooldown.Enabled = isChecked;
	TexturedButtons.UpdateCooldowns();
	
end

function TexturedButtons.Setup.Cooldown.OnHideFlashLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideFlash" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideFlash" .. "Button", isChecked);
	
	TexturedButtons.Settings.Cooldown.HideFlash = isChecked;
	TexturedButtons.UpdateCooldowns();
	
end

function TexturedButtons.Setup.Cooldown.OnSlideCooldownAlpha()

	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "CooldownAnimationAlphaSlider") * 100);
	LabelSetText(windowName .. "CooldownAnimationAlphaSliderValue", towstring(value) .. L"%");
	
	TexturedButtons.Settings.Cooldown.Alpha = (value / 100);
	TexturedButtons.UpdateCooldowns();
	
end

local function SelectColor(colorExample, settings, color)
	WindowSetTintColor(colorExample .. "Color", color.R, color.G, color.B);
	settings.R = color.R;
	settings.G = color.G;
	settings.B = color.B;
	TexturedButtons.UpdateCooldowns();
end

function TexturedButtons.Setup.Cooldown.OnCooldownColorLUp()
	local colorExample = windowName .. "CooldownAnimationColorExample";
	local colorSettings = TexturedButtons.Settings.Cooldown.Tint;
	
	TexturedButtons.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings, "topright", "topleft");
end

function TexturedButtons.Setup.Cooldown.OnRemoveCooldownSLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "RemoveCooldownS" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "RemoveCooldownS" .. "Button", isChecked);
	
	TexturedButtons.Settings.Cooldown.RemoveS = isChecked;
	TexturedButtons.UpdateCooldowns();
	
end

function TexturedButtons.Setup.Cooldown.OnShowGlobalCooldownTextLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "ShowGlobalCooldownText" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ShowGlobalCooldownText" .. "Button", isChecked);
	
	TexturedButtons.Settings.Cooldown.ShowGlobalCooldownText = isChecked;
	TexturedButtons.UpdateCooldowns();
	
end

function TexturedButtons.Setup.Cooldown.OnEnableButtonTintingLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "EnableButtonTinting" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnableButtonTinting" .. "Button", isChecked);
	
	TexturedButtons.Settings.Cooldown.EnableButtonTinting = isChecked;
	TexturedButtons.UpdateCooldowns();
	
end

function TexturedButtons.Setup.Cooldown.OnColorExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverColorExample = windowName;
	WindowSetTintColor(hoverColorExample .. "Border", 255, 110, 10);
end

function TexturedButtons.Setup.Cooldown.OnColorExampleMouseOut()
	if (not hoverColorExample) then return end
	WindowSetTintColor(hoverColorExample .. "Border", 50, 50, 50);
	hoverColorExample = nil;
end
