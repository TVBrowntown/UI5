TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.Fonts = 
{
	WindowName = "TexturedButtonsSetupFontsWindow",
};

local windowName = TexturedButtons.Setup.Fonts.WindowName;
local localization = TexturedButtons.Localization.GetMapping();

local hoverFontLabel = nil;
local hoverColorExample = nil;

function TexturedButtons.Setup.Fonts.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Fonts.Title"]);
	LabelSetText(windowName .. "EnableCheckboxLabel", localization["Setup.Fonts.Enable"]);
	LabelSetText(windowName .. "Keybind", localization["Setup.Fonts.Keybind"]);
	LabelSetText(windowName .. "KeybindFont", localization["Strings.Font"]);
	LabelSetText(windowName .. "KeybindColor", localization["Strings.Color"]);
	LabelSetText(windowName .. "Cooldown", localization["Setup.Fonts.Cooldown"]);
	LabelSetText(windowName .. "CooldownFont", localization["Strings.Font"]);
	LabelSetText(windowName .. "CooldownColor", localization["Strings.Color"]);
	LabelSetText(windowName .. "HideKeybindCheckboxLabel", localization["Setup.Fonts.HideKeybind"]);
	LabelSetText(windowName .. "HideCooldownCheckboxLabel", localization["Setup.Fonts.HideCooldown"]);
	
	TexturedButtons.Setup.Fonts.LoadSettings();
	
end

function TexturedButtons.Setup.Fonts.LoadSettings()

	local settings = TexturedButtons.Settings;
	
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", (settings.Fonts.Enabled == true));
	ButtonSetPressedFlag(windowName .. "HideKeybind" .. "Button", (settings.Fonts.Keybind.Hide == true));
	ButtonSetPressedFlag(windowName .. "HideCooldown" .. "Button", (settings.Fonts.Cooldown.Hide == true));
	
	local font = settings.Fonts.Keybind.Font or fonts[1].Font;
	LabelSetText(windowName .. "KeybindFontExample", towstring(TexturedButtons.Setup.SelectFont.GetFontName(font)));
	LabelSetFont(windowName .. "KeybindFontExample", font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	
	font = settings.Fonts.Cooldown.Font or fonts[1].Font;
	LabelSetText(windowName .. "CooldownFontExample", towstring(TexturedButtons.Setup.SelectFont.GetFontName(font)));
	LabelSetFont(windowName .. "CooldownFontExample", font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	
	local color = settings.Fonts.Keybind.Color;
	WindowSetTintColor(windowName .. "KeybindColorExampleColor", color.R, color.G, color.B);
	
	color = settings.Fonts.Cooldown.Color;
	WindowSetTintColor(windowName .. "CooldownColorExampleColor", color.R, color.G, color.B);
	
end

function TexturedButtons.Setup.Fonts.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.Fonts.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.Fonts.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.Fonts.OnHidden()

	TexturedButtons.Setup.SelectColor.Hide();
	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.Fonts.OnCloseLUp()

	TexturedButtons.Setup.Fonts.Hide();

end

function TexturedButtons.Setup.Fonts.OnEnableLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "Enable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", isChecked);
	
	TexturedButtons.Settings.Fonts.Enabled = isChecked;
	TexturedButtons.UpdateFonts();
	
end

local function SelectFont(font, label, settings)
	settings.Font = font.Font;
	LabelSetText(label, towstring(font.Name));
	LabelSetFont(label, font.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	TexturedButtons.UpdateFonts();
end

local function SelectColor(colorExample, settings, color)
	WindowSetTintColor(colorExample .. "Color", color.R, color.G, color.B);
	settings.R = color.R;
	settings.G = color.G;
	settings.B = color.B;
	TexturedButtons.UpdateFonts();
end

function TexturedButtons.Setup.Fonts.OnKeybindFontLUp()

	TexturedButtons.Setup.SelectFont.Show(function(font) SelectFont(font, windowName .. "KeybindFontExample", TexturedButtons.Settings.Fonts.Keybind) end);
	
end

function TexturedButtons.Setup.Fonts.OnKeybindColorLUp()
	local colorExample = windowName .. "KeybindColorExample";
	local colorSettings = TexturedButtons.Settings.Fonts.Keybind.Color;
	
	TexturedButtons.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings, "topleft", "topright");
end

function TexturedButtons.Setup.Fonts.OnHideKeybindLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideKeybind" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideKeybind" .. "Button", isChecked);
	
	TexturedButtons.Settings.Fonts.Keybind.Hide = isChecked;
	TexturedButtons.UpdateFonts();
	
end

function TexturedButtons.Setup.Fonts.OnCooldownFontLUp()

	TexturedButtons.Setup.SelectFont.Show(function(font) SelectFont(font, windowName .. "CooldownFontExample", TexturedButtons.Settings.Fonts.Cooldown) end);
	
end

function TexturedButtons.Setup.Fonts.OnCooldownColorLUp()
	local colorExample = windowName .. "CooldownColorExample";
	local colorSettings = TexturedButtons.Settings.Fonts.Cooldown.Color;
	
	TexturedButtons.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings, "bottomleft", "bottomright");
end

function TexturedButtons.Setup.Fonts.OnHideCooldownLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideCooldown" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideCooldown" .. "Button", isChecked);
	
	TexturedButtons.Settings.Fonts.Cooldown.Hide = isChecked;
	TexturedButtons.UpdateFonts();
	
end

function TexturedButtons.Setup.Fonts.OnFontExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverFontLabel = windowName;
	LabelSetTextColor(hoverFontLabel, 255, 110, 10);
end

function TexturedButtons.Setup.Fonts.OnFontExampleMouseOut()
	if (not hoverFontLabel) then return end
	LabelSetTextColor(hoverFontLabel, 255, 255, 255);
	hoverFontLabel = nil;
end

function TexturedButtons.Setup.Fonts.OnColorExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverColorExample = windowName;
	WindowSetTintColor(hoverColorExample .. "Border", 255, 110, 10);
end

function TexturedButtons.Setup.Fonts.OnColorExampleMouseOut()
	if (not hoverColorExample) then return end
	WindowSetTintColor(hoverColorExample .. "Border", 50, 50, 50);
	hoverColorExample = nil;
end
