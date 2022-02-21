TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.Tint = 
{
	WindowName = "TexturedButtonsSetupTintWindow",
};

local windowName = TexturedButtons.Setup.Tint.WindowName;
local localization = TexturedButtons.Localization.GetMapping();

local TintType = { EnabledValid = 1, EnabledInvalid = 2, DisabledInvalid = 3, Disabled = 4, OnCooldown = 5 };
local activeTintType = nil;
local colorLock = false;
local lockSettings = false;

function TexturedButtons.Setup.Tint.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Tint.Title"]);
	LabelSetText(windowName .. "EnableCheckboxLabel", localization["Setup.Tint.Enable"]);
	LabelSetText(windowName .. "TintType", localization["Setup.Tint.Type"]);
	LabelSetText(windowName .. "TintRed", localization["Strings.Color.Red"]);
	LabelSetText(windowName .. "TintGreen", localization["Strings.Color.Green"]);
	LabelSetText(windowName .. "TintBlue", localization["Strings.Color.Blue"]);
	
	ComboBoxClearMenuItems(windowName .. "TintTypeComboBox");
	ComboBoxAddMenuItem(windowName .. "TintTypeComboBox", localization["Setup.Tint.Type.EnabledValid"]);
	ComboBoxAddMenuItem(windowName .. "TintTypeComboBox", localization["Setup.Tint.Type.EnabledInvalid"]);
	ComboBoxAddMenuItem(windowName .. "TintTypeComboBox", localization["Setup.Tint.Type.DisabledInvalid"]);
	ComboBoxAddMenuItem(windowName .. "TintTypeComboBox", localization["Setup.Tint.Type.Disabled"]);
	ComboBoxAddMenuItem(windowName .. "TintTypeComboBox", localization["Setup.Tint.Type.OnCooldown"]);
	
	TexturedButtons.Setup.Tint.LoadSettings();
	
end

local function LoadTintType(tintType)

	lockSettings = true;
	activeTintType = tintType;
	local tintSettings = TexturedButtons.Settings.Tint;
	local color = { R = 255, G = 255, B = 255 };
	local typeInfo = L"";
	
	if (tintType == TintType.EnabledValid) then
		color = tintSettings.EnabledValid or color;
		typeInfo = localization["Setup.Tint.Type.EnabledValid.Info"];
	elseif (tintType == TintType.EnabledInvalid) then
		color = tintSettings.EnabledInvalid or color;
		typeInfo = localization["Setup.Tint.Type.EnabledInvalid.Info"];
	elseif (tintType == TintType.DisabledInvalid) then
		color = tintSettings.DisabledInvalid or color;
		typeInfo = localization["Setup.Tint.Type.DisabledInvalid.Info"];
	elseif (tintType == TintType.Disabled) then
		color = tintSettings.Disabled or color;
		typeInfo = localization["Setup.Tint.Type.Disabled.Info"];
	elseif (tintType == TintType.OnCooldown) then
		color = tintSettings.OnCooldown or color;
		typeInfo = localization["Setup.Tint.Type.OnCooldown.Info"];
	end
	
	LabelSetText(windowName .. "TintTypeInfo", typeInfo);
	
	TextEditBoxSetText(windowName .. "TintRedEditBox", towstring(color.R));
	TextEditBoxSetText(windowName .. "TintGreenEditBox", towstring(color.G));
	TextEditBoxSetText(windowName .. "TintBlueEditBox", towstring(color.B));	
	
	TexturedButtons.Setup.Tint.OnSlideTint();
	lockSettings = false;
	
end

function TexturedButtons.Setup.Tint.LoadSettings()

	local settings = TexturedButtons.Settings;
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", (settings.Tint.Enabled == true));
	
	ComboBoxSetSelectedMenuItem(windowName .. "TintTypeComboBox", TintType.EnabledValid);
	LoadTintType(TintType.EnabledValid);
	
end

function TexturedButtons.Setup.Tint.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.Tint.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.Tint.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.Tint.OnHidden()

	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.Tint.OnCloseLUp()

	TexturedButtons.Setup.Tint.Hide();

end

function TexturedButtons.Setup.Tint.OnEnableLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "Enable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", isChecked);
	
	TexturedButtons.Settings.Tint.Enabled = isChecked;
	TexturedButtons.UpdateTints();
	
end

function TexturedButtons.Setup.Tint.OnTintTypeChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "TintTypeComboBox");
	LoadTintType(value);
	
end

function TexturedButtons.Setup.Tint.OnSlideTint()

	local r = math.floor(SliderBarGetCurrentPosition(windowName .. "TintRedSlider") * 255);
	local g = math.floor(SliderBarGetCurrentPosition(windowName .. "TintGreenSlider") * 255);
	local b = math.floor(SliderBarGetCurrentPosition(windowName .. "TintBlueSlider") * 255);
	
	colorLock = true;
	TextEditBoxSetText(windowName .. "TintRedEditBox", towstring(r));
	TextEditBoxSetText(windowName .. "TintGreenEditBox", towstring(g));
	TextEditBoxSetText(windowName .. "TintBlueEditBox", towstring(b));
	colorLock = false;
	
	TexturedButtons.Setup.Tint.OnTintChanged(true);
	
end

function TexturedButtons.Setup.Tint.OnTintChanged(value)

	if (colorLock) then return end

	local r = tonumber(TextEditBoxGetText(windowName .. "TintRedEditBox"));
	local g = tonumber(TextEditBoxGetText(windowName .. "TintGreenEditBox"));
	local b = tonumber(TextEditBoxGetText(windowName .. "TintBlueEditBox"));
	
	if (value ~= true) then
		SliderBarSetCurrentPosition(windowName .. "TintRedSlider", r / 255);
		SliderBarSetCurrentPosition(windowName .. "TintGreenSlider", g / 255);
		SliderBarSetCurrentPosition(windowName .. "TintBlueSlider", b / 255);
	end
	
	WindowSetTintColor(windowName .. "TintColor", r, g, b);
	
	if (lockSettings) then return end
	
	local color = { R = r, G = g, B = b };
	local tintSettings = TexturedButtons.Settings.Tint;
	
	if (activeTintType == TintType.EnabledValid) then
		tintSettings.EnabledValid = color;
	elseif (activeTintType == TintType.EnabledInvalid) then
		tintSettings.EnabledInvalid = color;
	elseif (activeTintType == TintType.DisabledInvalid) then
		tintSettings.DisabledInvalid = color;
	elseif (activeTintType == TintType.Disabled) then
		tintSettings.Disabled = color;
	elseif (activeTintType == TintType.OnCooldown) then
		tintSettings.OnCooldown = color;
	end
	
	TexturedButtons.UpdateTints();
	
end
