Obsidian = Obsidian or {};
Obsidian.Setup = Obsidian.Setup or {};
Obsidian.Setup.Castbar = 
{
	WindowName = "ObsidianSetupCastbarWindow",
	Textures = {},
	TexturesOrder = {},
};

local DEFAULT_HEIGHT = 160;
local MIN_FONT_SCALE_SLIDER = 0.1;
local MAX_FONT_SCALE_SLIDER = 2;
local MIN_ICON_SCALE_SLIDER = 0.1;
local MAX_ICON_SCALE_SLIDER = 3;
local MIN_TIMER_DECIMALS_SLIDER = 0;
local MAX_TIMER_DECIMALS_SLIDER = 3;

local windowDimensions = {};

local windowName = Obsidian.Setup.Castbar.WindowName;
local localization = Obsidian.Localization.GetMapping();

local elements =
{
	"ElementGeneral", "ElementBackground", "ElementFill", "ElementSpark", "ElementName", "ElementTimer", "ElementIcon", "ElementLatency", "ElementGlobalCooldown", "ElementRange",
}

local indexToAlignment = { "leftcenter", "center", "rightcenter" };

local lockSettings = false;

local activeElement = nil;
local hoverColorExample = nil;
local hoverTextureButton = nil;
local hoverFontLabel = nil;

local function GetAlignmentIndex(align)
	for index, alignment in ipairs(indexToAlignment) do
		if (align == alignment) then
			return index;
		end
	end
	return 1;
end

local function OnSettingsChanged(onlyAnchor)
	if (not onlyAnchor) then
		Obsidian.OnSettingsChanged();
	end
	Obsidian.Setup.Demo.OnSettingsChanged();
end

local function SetTextureButton(textureButton, texture, name, dimensions)
	if (not dimensions) then
		dimensions = Obsidian.Textures.GetDimensions(texture);
	end
	DynamicImageSetTexture(textureButton .. "Texture", texture, 0, 0);
	DynamicImageSetTextureDimensions(textureButton .. "Texture", dimensions.Width, dimensions.Height);
	if (name) then
		LabelSetText(textureButton .. "Name", name);
	end
end

local function GetWindowDimension(windowName)
	local dimensions = windowDimensions[windowName];
	if (not dimensions) then
		local w, h = WindowGetDimensions(windowName);
		dimensions = { Width = w, Height = h };
		windowDimensions[windowName] = dimensions;
	end
	return dimensions.Width, dimensions.Height;
end

local function ShowElement(name)

	if (activeElement and activeElement ~= name) then
		WindowSetShowing(windowName .. activeElement, false);
	end
	
	local width, _ = GetWindowDimension(windowName);
	local _, height = GetWindowDimension(windowName .. name);
	
	WindowSetDimensions(windowName, width, height + DEFAULT_HEIGHT);
	
	activeElement = name;
	WindowSetShowing(windowName .. activeElement, true);

end

function Obsidian.Setup.Castbar.Initialize()

	for index, element in ipairs(elements) do
		WindowSetShowing(windowName .. element, false);
	end

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Castbar.Title"]);
	LabelSetText(windowName .. "ElementLabel", localization["Setup.Castbar.Element"]);
	
	LabelSetText(windowName .. "ElementGeneralLabel", localization["Setup.Castbar.General"]);
	LabelSetText(windowName .. "ElementGeneralSizeLabel", localization["Strings.Size"]);
	LabelSetText(windowName .. "ElementGeneralSizeWidthLabel", localization["Strings.Size.Width"]);
	LabelSetText(windowName .. "ElementGeneralSizeHeightLabel", localization["Strings.Size.Height"]);
	LabelSetText(windowName .. "ElementGeneralAccuracyLabel", localization["Setup.Castbar.General.Accurate"]);
	LabelSetText(windowName .. "ElementGeneralAccurateCheckboxLabel", localization["Setup.Castbar.General.Accurate.Enable"]);
	
	LabelSetText(windowName .. "ElementBackgroundLabel", localization["Setup.Castbar.Background"]);
	LabelSetText(windowName .. "ElementBackgroundColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementBackgroundAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementBackgroundBorderLabel", localization["Setup.Castbar.Background.Border"]);
	
	LabelSetText(windowName .. "ElementFillLabel", localization["Setup.Castbar.Fill"]);
	LabelSetText(windowName .. "ElementFillColorsLabel", localization["Setup.Castbar.Fill.Colors"]);
	LabelSetText(windowName .. "ElementFillNormalColorLabel", localization["Setup.Castbar.Fill.Colors.Normal"]);
	LabelSetText(windowName .. "ElementFillChanneledColorLabel", localization["Setup.Castbar.Fill.Colors.Channeled"]);
	LabelSetText(windowName .. "ElementFillSuccessColorLabel", localization["Setup.Castbar.Fill.Colors.Success"]);
	LabelSetText(windowName .. "ElementFillFailedColorLabel", localization["Setup.Castbar.Fill.Colors.Failed"]);
	LabelSetText(windowName .. "ElementFillAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementFillTextureLabel", localization["Strings.Texture"]);
	LabelSetText(windowName .. "ElementFillUpdatePriorityLabel", localization["Setup.Castbar.Fill.UpdatePriority"]);
	ComboBoxClearMenuItems(windowName .. "ElementFillUpdatePriorityComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementFillUpdatePriorityComboBox", localization["Setup.Castbar.Fill.UpdatePriority.Low"]);
	ComboBoxAddMenuItem(windowName .. "ElementFillUpdatePriorityComboBox", localization["Setup.Castbar.Fill.UpdatePriority.Normal"]);
	ComboBoxAddMenuItem(windowName .. "ElementFillUpdatePriorityComboBox", localization["Setup.Castbar.Fill.UpdatePriority.High"]);
	
	LabelSetText(windowName .. "ElementLatencyLabel", localization["Setup.Castbar.Latency"]);
	LabelSetText(windowName .. "ElementLatencyInfoLabel", localization["Setup.Castbar.Latency.Info"]);
	LabelSetText(windowName .. "ElementLatencyEnableCheckboxLabel", localization["Setup.Castbar.Latency.Enable"]);
	LabelSetText(windowName .. "ElementLatencyColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementLatencyAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementLatencyEnableTextCheckboxLabel", localization["Setup.Castbar.Latency.Text.Enable"]);
	LabelSetText(windowName .. "ElementLatencyTextColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementLatencyTextAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementLatencyTextFontLabel", localization["Strings.Font"]);
	LabelSetText(windowName .. "ElementLatencyTextScaleLabel", localization["Strings.Scale"]);
	
	LabelSetText(windowName .. "ElementSparkLabel", localization["Setup.Castbar.Spark"]);
	LabelSetText(windowName .. "ElementSparkColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementSparkAlphaLabel", localization["Strings.Alpha"]);
	
	LabelSetText(windowName .. "ElementNameLabel", localization["Setup.Castbar.Name"]);
	LabelSetText(windowName .. "ElementNameOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowName .. "ElementNameOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementNameOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowName .. "ElementNameColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementNameAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementNameFontLabel", localization["Strings.Font"]);
	LabelSetText(windowName .. "ElementNameScaleLabel", localization["Strings.Scale"]);
	LabelSetText(windowName .. "ElementNameWidthLabel", localization["Strings.Size.Width"]);
	LabelSetText(windowName .. "ElementNameAlignmentLabel", localization["Strings.Align"]);
	ComboBoxClearMenuItems(windowName .. "ElementNameAlignmentComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementNameAlignmentComboBox", localization["Strings.Align.Left"]);
	ComboBoxAddMenuItem(windowName .. "ElementNameAlignmentComboBox", localization["Strings.Align.Center"]);
	ComboBoxAddMenuItem(windowName .. "ElementNameAlignmentComboBox", localization["Strings.Align.Right"]);
	
	LabelSetText(windowName .. "ElementTimerLabel", localization["Setup.Castbar.Timer"]);
	LabelSetText(windowName .. "ElementTimerOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowName .. "ElementTimerOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementTimerOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowName .. "ElementTimerColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementTimerAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementTimerFontLabel", localization["Strings.Font"]);
	LabelSetText(windowName .. "ElementTimerScaleLabel", localization["Strings.Scale"]);
	LabelSetText(windowName .. "ElementTimerDecimalsLabel", localization["Setup.Castbar.Timer.Decimals"]);
	LabelSetText(windowName .. "ElementTimerAlignmentLabel", localization["Strings.Align"]);
	ComboBoxClearMenuItems(windowName .. "ElementTimerAlignmentComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementTimerAlignmentComboBox", localization["Strings.Align.Left"]);
	ComboBoxAddMenuItem(windowName .. "ElementTimerAlignmentComboBox", localization["Strings.Align.Center"]);
	ComboBoxAddMenuItem(windowName .. "ElementTimerAlignmentComboBox", localization["Strings.Align.Right"]);
	
	LabelSetText(windowName .. "ElementIconLabel", localization["Setup.Castbar.Icon"]);
	LabelSetText(windowName .. "ElementIconEnableCheckboxLabel", localization["Setup.Castbar.Icon.Enable"]);
	LabelSetText(windowName .. "ElementIconOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowName .. "ElementIconOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementIconOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowName .. "ElementIconAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementIconPositionLabel", localization["Strings.Position"]);
	LabelSetText(windowName .. "ElementIconScaleLabel", localization["Strings.Scale"]);
	ComboBoxClearMenuItems(windowName .. "ElementIconPositionComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementIconPositionComboBox", localization["Strings.Position.Left"]);
	ComboBoxAddMenuItem(windowName .. "ElementIconPositionComboBox", localization["Strings.Position.Right"]);
	
	LabelSetText(windowName .. "ElementGlobalCooldownLabel", localization["Setup.Castbar.GlobalCooldown"]);
	LabelSetText(windowName .. "ElementGlobalCooldownEnableCheckboxLabel", localization["Setup.Castbar.GlobalCooldown.Enable"]);
	LabelSetText(windowName .. "ElementGlobalCooldownReverseCheckboxLabel", localization["Setup.Castbar.GlobalCooldown.Reverse"]);
	LabelSetText(windowName .. "ElementGlobalCooldownOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowName .. "ElementGlobalCooldownOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementGlobalCooldownOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowName .. "ElementGlobalCooldownSizeLabel", localization["Strings.Size"]);
	LabelSetText(windowName .. "ElementGlobalCooldownSizeWidthLabel", localization["Strings.Size.Width"]);
	LabelSetText(windowName .. "ElementGlobalCooldownSizeHeightLabel", localization["Strings.Size.Height"]);
	LabelSetText(windowName .. "ElementGlobalCooldownElementsLabel", localization["Setup.Castbar.GlobalCooldown.Elements"]);
	LabelSetText(windowName .. "ElementGlobalCooldownColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementGlobalCooldownAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementGlobalCooldownBackgroundLabel", localization["Setup.Castbar.Background"]);
	LabelSetText(windowName .. "ElementGlobalCooldownFillLabel", localization["Setup.Castbar.Fill"]);
	LabelSetText(windowName .. "ElementGlobalCooldownFillReadyLabel", localization["Setup.Castbar.FillReady"]);
	LabelSetText(windowName .. "ElementGlobalCooldownDividerLabel", localization["Setup.Castbar.Divider"]);
	LabelSetText(windowName .. "ElementGlobalCooldownSparkLabel", localization["Setup.Castbar.Spark"]);
	LabelSetText(windowName .. "ElementGlobalCooldownPositionLabel", localization["Strings.Position"]);
	ComboBoxClearMenuItems(windowName .. "ElementGlobalCooldownPositionComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementGlobalCooldownPositionComboBox", localization["Strings.Position.Top"]);
	ComboBoxAddMenuItem(windowName .. "ElementGlobalCooldownPositionComboBox", localization["Strings.Position.Bottom"]);
	ComboBoxAddMenuItem(windowName .. "ElementGlobalCooldownPositionComboBox", localization["Strings.Position.Free"]);
	
	LabelSetText(windowName .. "ElementRangeLabel", localization["Setup.Castbar.Range"]);
	LabelSetText(windowName .. "ElementRangeEnableCheckboxLabel", localization["Setup.Castbar.Range.Enable"]);
	LabelSetText(windowName .. "ElementRangeColorLabel", localization["Strings.Color"]);
	
	ComboBoxClearMenuItems(windowName .. "ElementComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.General"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Background"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Fill"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Spark"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Name"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Timer"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Icon"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Latency"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.GlobalCooldown"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.Castbar.Range"]);
	
	ComboBoxSetSelectedMenuItem(windowName .. "ElementComboBox", 1);
	ShowElement(elements[1]);
	
	Obsidian.Setup.Castbar.LoadSettings();
	
end

function Obsidian.Setup.Castbar.LoadSettings()
	
	lockSettings = true;
	local settings = Obsidian.Settings.Castbar;
	local gcdSettings = Obsidian.Settings.GlobalCooldown;
	
	TextEditBoxSetText(windowName .. "ElementGeneralSizeWidthEditBox", towstring(settings.Size.Width));
	TextEditBoxSetText(windowName .. "ElementGeneralSizeHeightEditBox", towstring(settings.Size.Height));
	ButtonSetPressedFlag(windowName .. "ElementGeneralAccurate" .. "Button", (settings.Accurate == true));
	
	local color = settings.Background.Color;
	WindowSetTintColor(windowName .. "ElementBackgroundColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementBackgroundAlphaSlider", settings.Background.Alpha or 1);
	TextEditBoxSetText(windowName .. "ElementBackgroundBorderSizeEditBox", towstring(settings.Size.Border));
	
	color = settings.Fill.Colors.Normal;
	WindowSetTintColor(windowName .. "ElementFillNormalColorExampleColor", color.R, color.G, color.B);
	color = settings.Fill.Colors.Channeled;
	WindowSetTintColor(windowName .. "ElementFillChanneledColorExampleColor", color.R, color.G, color.B);
	color = settings.Fill.Colors.Success;
	WindowSetTintColor(windowName .. "ElementFillSuccessColorExampleColor", color.R, color.G, color.B);
	color = settings.Fill.Colors.Failed;
	WindowSetTintColor(windowName .. "ElementFillFailedColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementFillAlphaSlider", settings.Fill.Alpha or 1);
	SetTextureButton(windowName .. "ElementFillTextureButton", settings.Fill.Texture, towstring(Obsidian.Textures.GetName(settings.Fill.Texture)));
	ComboBoxSetSelectedMenuItem(windowName .. "ElementFillUpdatePriorityComboBox", settings.Fill.Priority or 1);
	
	ButtonSetPressedFlag(windowName .. "ElementLatencyEnable" .. "Button", (settings.Latency.Enabled == true));
	color = settings.Latency.Color;
	WindowSetTintColor(windowName .. "ElementLatencyColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementLatencyAlphaSlider", settings.Latency.Alpha or 1);
	ButtonSetPressedFlag(windowName .. "ElementLatencyEnableText" .. "Button", (settings.Latency.Text.Enabled == true));
	color = settings.Latency.Text.Color;
	WindowSetTintColor(windowName .. "ElementLatencyTextColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementLatencyTextAlphaSlider", settings.Latency.Text.Alpha or 1);
	LabelSetText(windowName .. "ElementLatencyTextFontExampleLabel", towstring(Obsidian.Setup.SelectFont.GetFontName(settings.Latency.Text.Font)));
	LabelSetFont(windowName .. "ElementLatencyTextFontExampleLabel", settings.Latency.Text.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	SliderBarSetCurrentPosition(windowName .. "ElementLatencyTextScaleSlider", math.max(math.min(1, (settings.Latency.Text.Scale - MIN_FONT_SCALE_SLIDER) / (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER)), 0));
	
	color = settings.Spark.Color;
	WindowSetTintColor(windowName .. "ElementSparkColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementSparkAlphaSlider", settings.Spark.Alpha or 1);
	
	color = settings.Name.Color;
	WindowSetTintColor(windowName .. "ElementNameColorExampleColor", color.R, color.G, color.B);
	TextEditBoxSetText(windowName .. "ElementNameOffsetXEditBox", towstring(settings.Name.X));
	TextEditBoxSetText(windowName .. "ElementNameOffsetYEditBox", towstring(settings.Name.Y));
	SliderBarSetCurrentPosition(windowName .. "ElementNameAlphaSlider", settings.Name.Alpha or 1);
	LabelSetText(windowName .. "ElementNameFontExampleLabel", towstring(Obsidian.Setup.SelectFont.GetFontName(settings.Name.Font)));
	LabelSetFont(windowName .. "ElementNameFontExampleLabel", settings.Name.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	SliderBarSetCurrentPosition(windowName .. "ElementNameScaleSlider", math.max(math.min(1, (settings.Name.Scale - MIN_FONT_SCALE_SLIDER) / (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER)), 0));
	SliderBarSetCurrentPosition(windowName .. "ElementNameWidthSlider", settings.Name.Width);
	ComboBoxSetSelectedMenuItem(windowName .. "ElementNameAlignmentComboBox", GetAlignmentIndex(settings.Name.Alignment));
	
	color = settings.Timer.Color;
	WindowSetTintColor(windowName .. "ElementTimerColorExampleColor", color.R, color.G, color.B);
	TextEditBoxSetText(windowName .. "ElementTimerOffsetXEditBox", towstring(settings.Timer.X));
	TextEditBoxSetText(windowName .. "ElementTimerOffsetYEditBox", towstring(settings.Timer.Y));
	SliderBarSetCurrentPosition(windowName .. "ElementTimerAlphaSlider", settings.Timer.Alpha or 1);
	LabelSetText(windowName .. "ElementTimerFontExampleLabel", towstring(Obsidian.Setup.SelectFont.GetFontName(settings.Timer.Font)));
	LabelSetFont(windowName .. "ElementTimerFontExampleLabel", settings.Timer.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	SliderBarSetCurrentPosition(windowName .. "ElementTimerScaleSlider", math.max(math.min(1, (settings.Timer.Scale - MIN_FONT_SCALE_SLIDER) / (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER)), 0));
	SliderBarSetCurrentPosition(windowName .. "ElementTimerDecimalsSlider", math.max(math.min(1, (settings.Timer.Decimals - MIN_TIMER_DECIMALS_SLIDER) / (MAX_TIMER_DECIMALS_SLIDER - MIN_TIMER_DECIMALS_SLIDER)), 0));
	ComboBoxSetSelectedMenuItem(windowName .. "ElementTimerAlignmentComboBox", GetAlignmentIndex(settings.Timer.Alignment));
	
	ButtonSetPressedFlag(windowName .. "ElementIconEnable" .. "Button", (settings.Icon.Enabled == true));
	TextEditBoxSetText(windowName .. "ElementIconOffsetXEditBox", towstring(settings.Icon.X));
	TextEditBoxSetText(windowName .. "ElementIconOffsetYEditBox", towstring(settings.Icon.Y));
	SliderBarSetCurrentPosition(windowName .. "ElementIconAlphaSlider", settings.Icon.Alpha or 1);
	ComboBoxSetSelectedMenuItem(windowName .. "ElementIconPositionComboBox", settings.Icon.Position or 1);
	SliderBarSetCurrentPosition(windowName .. "ElementIconScaleSlider", math.max(math.min(1, (settings.Icon.Scale - MIN_ICON_SCALE_SLIDER) / (MAX_ICON_SCALE_SLIDER - MIN_ICON_SCALE_SLIDER)), 0));
	
	ButtonSetPressedFlag(windowName .. "ElementGlobalCooldownEnable" .. "Button", (gcdSettings.Enabled == true));
	ButtonSetPressedFlag(windowName .. "ElementGlobalCooldownReverse" .. "Button", (gcdSettings.Reverse == true));
	TextEditBoxSetText(windowName .. "ElementGlobalCooldownOffsetXEditBox", towstring(gcdSettings.X));
	TextEditBoxSetText(windowName .. "ElementGlobalCooldownOffsetYEditBox", towstring(gcdSettings.Y));
	TextEditBoxSetText(windowName .. "ElementGlobalCooldownSizeWidthEditBox", towstring(gcdSettings.Width));
	TextEditBoxSetText(windowName .. "ElementGlobalCooldownSizeHeightEditBox", towstring(gcdSettings.Height));
	ComboBoxSetSelectedMenuItem(windowName .. "ElementGlobalCooldownPositionComboBox", gcdSettings.Position or 1);
	color = gcdSettings.Background.Color;
	WindowSetTintColor(windowName .. "ElementGlobalCooldownBackgroundColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementGlobalCooldownBackgroundAlphaSlider", gcdSettings.Background.Alpha or 1);
	color = gcdSettings.Fill.Color;
	WindowSetTintColor(windowName .. "ElementGlobalCooldownFillColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementGlobalCooldownFillAlphaSlider", gcdSettings.Fill.Alpha or 1);

	color = gcdSettings.FillReady.Color;
	WindowSetTintColor(windowName .. "ElementGlobalCooldownFillReadyColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementGlobalCooldownFillReadyAlphaSlider", gcdSettings.FillReady.Alpha or 1);

	color = gcdSettings.Divider.Color;
	WindowSetTintColor(windowName .. "ElementGlobalCooldownDividerColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementGlobalCooldownDividerAlphaSlider", gcdSettings.Divider.Alpha or 1);

	color = gcdSettings.Spark.Color;
	WindowSetTintColor(windowName .. "ElementGlobalCooldownSparkColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ElementGlobalCooldownSparkAlphaSlider", gcdSettings.Spark.Alpha or 1);
	
	ButtonSetPressedFlag(windowName .. "ElementRangeEnable" .. "Button", (settings.Range.Enabled == true));
	color = settings.Range.Color;
	WindowSetTintColor(windowName .. "ElementRangeColorExampleColor", color.R, color.G, color.B);
	
	Obsidian.Setup.Castbar.OnSlideBackgroundAlpha();
	Obsidian.Setup.Castbar.OnSlideFillAlpha();
	Obsidian.Setup.Castbar.OnSlideLatencyAlpha();
	Obsidian.Setup.Castbar.OnSlideLatencyTextAlpha();
	Obsidian.Setup.Castbar.OnSlideLatencyTextScale();
	Obsidian.Setup.Castbar.OnSlideSparkAlpha();
	Obsidian.Setup.Castbar.OnSlideNameAlpha();
	Obsidian.Setup.Castbar.OnSlideNameScale();
	Obsidian.Setup.Castbar.OnSlideNameWidth();
	Obsidian.Setup.Castbar.OnSlideTimerAlpha();
	Obsidian.Setup.Castbar.OnSlideTimerScale();
	Obsidian.Setup.Castbar.OnSlideTimerDecimals();
	Obsidian.Setup.Castbar.OnSlideIconAlpha();
	Obsidian.Setup.Castbar.OnSlideIconScale();
	Obsidian.Setup.Castbar.OnSlideGlobalCooldownBackgroundAlpha();
	Obsidian.Setup.Castbar.OnSlideGlobalCooldownFillAlpha();
	Obsidian.Setup.Castbar.OnSlideGlobalCooldownSparkAlpha();
	Obsidian.Setup.Castbar.OnSlideGlobalCooldownDividerAlpha();
	Obsidian.Setup.Castbar.OnSlideGlobalCooldownFillReadyAlpha();
	lockSettings = false;
	
end

function Obsidian.Setup.Castbar.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	Obsidian.Setup.Demo.Enable(windowName);
	
	WindowUtils.AddToOpenList(windowName, Obsidian.Setup.Castbar.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function Obsidian.Setup.Castbar.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function Obsidian.Setup.Castbar.OnHidden()

	Obsidian.Setup.SelectTexture.Hide();
	Obsidian.Setup.SelectColor.Hide();
	Obsidian.Setup.Demo.Disable();
	Obsidian.Setup.SetActiveWindow();

end

function Obsidian.Setup.Castbar.OnCloseLUp()

	Obsidian.Setup.Castbar.Hide();

end

function Obsidian.Setup.Castbar.OnElementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementComboBox");
	if (elements[value]) then
		ShowElement(elements[value]);
	end
	
	Obsidian.Setup.SelectTexture.Hide();
	Obsidian.Setup.SelectColor.Hide();

end

local function SelectColor(colorExample, settings, color)
	WindowSetTintColor(colorExample .. "Color", color.R, color.G, color.B);
	settings.R = color.R;
	settings.G = color.G;
	settings.B = color.B;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGeneralSizeWidthChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementGeneralSizeWidthEditBox"));
	Obsidian.Settings.Castbar.Size.Width = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGeneralSizeHeightChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementGeneralSizeHeightEditBox"));
	Obsidian.Settings.Castbar.Size.Height = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGeneralAccurateLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementGeneralAccurate" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementGeneralAccurate" .. "Button", isChecked);
	Obsidian.Settings.Castbar.Accurate = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnBackgroundColorLUp()
	local colorExample = windowName .. "ElementBackgroundColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Background.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnBackgroundBorderSizeChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementBackgroundBorderSizeEditBox"));
	Obsidian.Settings.Castbar.Size.Border = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnFillNormalColorLUp()
	local colorExample = windowName .. "ElementFillNormalColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Fill.Colors.Normal;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnFillChanneledColorLUp()
	local colorExample = windowName .. "ElementFillChanneledColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Fill.Colors.Channeled;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnFillSuccessColorLUp()
	local colorExample = windowName .. "ElementFillSuccessColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Fill.Colors.Success;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnFillFailedColorLUp()
	local colorExample = windowName .. "ElementFillFailedColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Fill.Colors.Failed;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnFillUpdatePriorityChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementFillUpdatePriorityComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Fill.Priority = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnColorExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverColorExample = windowName;
	WindowSetTintColor(hoverColorExample .. "Border", 255, 110, 10);
end

function Obsidian.Setup.Castbar.OnColorExampleMouseOut()
	if (not hoverColorExample) then return end
	WindowSetTintColor(hoverColorExample .. "Border", 50, 50, 50);
	hoverColorExample = nil;
end

function Obsidian.Setup.Castbar.OnFontExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverFontLabel = windowName;
	LabelSetTextColor(hoverFontLabel, 255, 110, 10);
end

function Obsidian.Setup.Castbar.OnFontExampleMouseOut()
	if (not hoverFontLabel) then return end
	LabelSetTextColor(hoverFontLabel, 255, 255, 255);
	hoverFontLabel = nil;
end

function Obsidian.Setup.Castbar.OnSlideBackgroundAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementBackgroundAlphaSlider");
	LabelSetText(windowName .. "ElementBackgroundAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Background.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnSlideFillAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementFillAlphaSlider");
	LabelSetText(windowName .. "ElementFillAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Fill.Alpha = value;
		OnSettingsChanged();
	end
end

local function SelectTexture(texture, textureButton, settings)
	SetTextureButton(windowName .. "ElementFillTextureButton", texture.Texture, texture.Name, texture.Dimensions)
		
	settings.Texture = texture.Texture;
	settings.TextureDimensions = texture.Dimensions;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnFillTextureLUp()
	Obsidian.Setup.SelectTexture.Show(windowName, windowName .. "ElementFillTextureButton", 
		function(texture) SelectTexture(texture, windowName .. "ElementFillTextureButton", Obsidian.Settings.Castbar.Fill) end);
end

function Obsidian.Setup.Castbar.OnTextureButtonMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverTextureButton = windowName;
	LabelSetTextColor(hoverTextureButton .. "Name", 255, 110, 10);
end

function Obsidian.Setup.Castbar.OnTextureButtonMouseOut()
	if (not hoverTextureButton) then return end
	LabelSetTextColor(hoverTextureButton .. "Name", 255, 255, 255);
	hoverTextureButton = nil;
end

function Obsidian.Setup.Castbar.OnLatencyEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementLatencyEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementLatencyEnable" .. "Button", isChecked);
	Obsidian.Settings.Castbar.Latency.Enabled = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnLatencyColorLUp()
	local colorExample = windowName .. "ElementLatencyColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Latency.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideLatencyAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementLatencyAlphaSlider");
	LabelSetText(windowName .. "ElementLatencyAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Latency.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnLatencyEnableTextLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementLatencyEnableText" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementLatencyEnableText" .. "Button", isChecked);
	Obsidian.Settings.Castbar.Latency.Text.Enabled = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnLatencyTextColorLUp()
	local colorExample = windowName .. "ElementLatencyTextColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Latency.Text.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideLatencyTextAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementLatencyTextAlphaSlider");
	LabelSetText(windowName .. "ElementLatencyTextAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Latency.Text.Alpha = value;
		OnSettingsChanged();
	end
end

local function SelectFont(font, label, settings)
	settings.Font = font.Font;
	LabelSetText(label, towstring(font.Name));
	LabelSetFont(label, font.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnLatencyTextFontLUp()
	Obsidian.Setup.SelectFont.Show(function(font) SelectFont(font, windowName .. "ElementLatencyTextFontExampleLabel", Obsidian.Settings.Castbar.Latency.Text) end);
end

function Obsidian.Setup.Castbar.OnSlideLatencyTextScale()
	local value = MIN_FONT_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "ElementLatencyTextScaleSlider") * (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowName .. "ElementLatencyTextScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Latency.Text.Scale = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnSparkColorLUp()
	local colorExample = windowName .. "ElementSparkColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Spark.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideSparkAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementSparkAlphaSlider");
	LabelSetText(windowName .. "ElementSparkAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Spark.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnNameOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementNameOffsetXEditBox"));
	Obsidian.Settings.Castbar.Name.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnNameOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementNameOffsetYEditBox"));
	Obsidian.Settings.Castbar.Name.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnNameAlignmentChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementNameAlignmentComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Name.Alignment = indexToAlignment[value];
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnNameColorLUp()
	local colorExample = windowName .. "ElementNameColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Name.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideNameAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementNameAlphaSlider");
	LabelSetText(windowName .. "ElementNameAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Name.Alpha = value;
		Obsidian.Settings.Castbar.Name.Enabled = (value > 0);
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnNameFontLUp()
	Obsidian.Setup.SelectFont.Show(function(font) SelectFont(font, windowName .. "ElementNameFontExampleLabel", Obsidian.Settings.Castbar.Name) end);
end

function Obsidian.Setup.Castbar.OnSlideNameScale()
	local value = MIN_FONT_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "ElementNameScaleSlider") * (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowName .. "ElementNameScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Name.Scale = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnSlideNameWidth()
	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "ElementNameWidthSlider") * 100) / 100;
	LabelSetText(windowName .. "ElementNameWidthValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Name.Width = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnTimerOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementTimerOffsetXEditBox"));
	Obsidian.Settings.Castbar.Timer.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnTimerOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementTimerOffsetYEditBox"));
	Obsidian.Settings.Castbar.Timer.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnTimerAlignmentChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementTimerAlignmentComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Timer.Alignment = indexToAlignment[value];
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnTimerColorLUp()
	local colorExample = windowName .. "ElementTimerColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Timer.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideTimerAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementTimerAlphaSlider");
	LabelSetText(windowName .. "ElementTimerAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Timer.Alpha = value;
		Obsidian.Settings.Castbar.Timer.Enabled = (value > 0);
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnTimerFontLUp()
	Obsidian.Setup.SelectFont.Show(function(font) SelectFont(font, windowName .. "ElementTimerFontExampleLabel", Obsidian.Settings.Castbar.Timer) end);
end

function Obsidian.Setup.Castbar.OnSlideTimerScale()
	local value = MIN_FONT_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "ElementTimerScaleSlider") * (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowName .. "ElementTimerScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Timer.Scale = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnSlideTimerDecimals()
	local value = math.floor(MIN_TIMER_DECIMALS_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "ElementTimerDecimalsSlider") * (MAX_TIMER_DECIMALS_SLIDER - MIN_TIMER_DECIMALS_SLIDER) * 100) / 100);
	LabelSetText(windowName .. "ElementTimerDecimalsValue", towstring(value));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Timer.Decimals = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnIconEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementIconEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementIconEnable" .. "Button", isChecked);
	Obsidian.Settings.Castbar.Icon.Enabled = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnIconOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementIconOffsetXEditBox"));
	Obsidian.Settings.Castbar.Icon.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnIconOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementIconOffsetYEditBox"));
	Obsidian.Settings.Castbar.Icon.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnSlideIconAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementIconAlphaSlider");
	LabelSetText(windowName .. "ElementIconAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Icon.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnSlideIconScale()
	local value = MIN_ICON_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "ElementIconScaleSlider") * (MAX_ICON_SCALE_SLIDER - MIN_ICON_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowName .. "ElementIconScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Icon.Scale = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnIconPositionChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementIconPositionComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.Castbar.Icon.Position = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnGlobalCooldownEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementGlobalCooldownEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementGlobalCooldownEnable" .. "Button", isChecked);
	Obsidian.Settings.GlobalCooldown.Enabled = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGlobalCooldownReverseLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementGlobalCooldownReverse" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementGlobalCooldownReverse" .. "Button", isChecked);
	Obsidian.Settings.GlobalCooldown.Reverse = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGlobalCooldownOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementGlobalCooldownOffsetXEditBox"));
	Obsidian.Settings.GlobalCooldown.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGlobalCooldownOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementGlobalCooldownOffsetYEditBox"));
	Obsidian.Settings.GlobalCooldown.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGlobalCooldownSizeWidthChanged()
	if (lockSettings) then return end
	local value = tostring(TextEditBoxGetText(windowName .. "ElementGlobalCooldownSizeWidthEditBox"));
	if (not value:match("%%")) then
		value = tonumber(value);
	end
	Obsidian.Settings.GlobalCooldown.Width = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGlobalCooldownSizeHeightChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementGlobalCooldownSizeHeightEditBox"));
	Obsidian.Settings.GlobalCooldown.Height = value;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnGlobalCooldownBackgroundColorLUp()
	local colorExample = windowName .. "ElementGlobalCooldownBackgroundColorExample";
	local colorSettings = Obsidian.Settings.GlobalCooldown.Background.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideGlobalCooldownBackgroundAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementGlobalCooldownBackgroundAlphaSlider");
	LabelSetText(windowName .. "ElementGlobalCooldownBackgroundAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.GlobalCooldown.Background.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnGlobalCooldownFillColorLUp()
	local colorExample = windowName .. "ElementGlobalCooldownFillColorExample";
	local colorSettings = Obsidian.Settings.GlobalCooldown.Fill.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end


function Obsidian.Setup.Castbar.OnGlobalCooldownDividerColorLUp()
	local colorExample = windowName .. "ElementGlobalCooldownDividerColorExample";
	local colorSettings = Obsidian.Settings.GlobalCooldown.Divider.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideGlobalCooldownDividerAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementGlobalCooldownDividerAlphaSlider");
	LabelSetText(windowName .. "ElementGlobalCooldownDividerAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.GlobalCooldown.Divider.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnGlobalCooldownFillReadyColorLUp()
	local colorExample = windowName .. "ElementGlobalCooldownFillReadyColorExample";
	local colorSettings = Obsidian.Settings.GlobalCooldown.FillReady.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideGlobalCooldownFillReadyAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementGlobalCooldownFillReadyAlphaSlider");
	LabelSetText(windowName .. "ElementGlobalCooldownFillReadyAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.GlobalCooldown.FillReady.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnSlideGlobalCooldownFillAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementGlobalCooldownFillAlphaSlider");
	LabelSetText(windowName .. "ElementGlobalCooldownFillAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.GlobalCooldown.Fill.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnGlobalCooldownSparkColorLUp()
	local colorExample = windowName .. "ElementGlobalCooldownSparkColorExample";
	local colorSettings = Obsidian.Settings.GlobalCooldown.Spark.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.Castbar.OnSlideGlobalCooldownSparkAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementGlobalCooldownSparkAlphaSlider");
	LabelSetText(windowName .. "ElementGlobalCooldownSparkAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.GlobalCooldown.Spark.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnGlobalCooldownPositionChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementGlobalCooldownPositionComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.GlobalCooldown.Position = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnRangeEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementRangeEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementRangeEnable" .. "Button", isChecked);
	Obsidian.Settings.Castbar.Range.Enabled = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.Castbar.OnRangeColorLUp()
	local colorExample = windowName .. "ElementRangeColorExample";
	local colorSettings = Obsidian.Settings.Castbar.Range.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings, "bottomright", "bottomleft");
end