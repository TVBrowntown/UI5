Obsidian = Obsidian or {};
Obsidian.Setup = Obsidian.Setup or {};
Obsidian.Setup.EffectTracker = 
{
	WindowName = "ObsidianSetupEffectTrackerWindow",
	Textures = {},
	TexturesOrder = {},
};

local DEFAULT_HEIGHT = 160;
local DEFAULT_BAR_HEIGHT = 40;
local DEFAULT_FRIENDLY_HEIGHT = 40;
local MIN_FONT_SCALE_SLIDER = 0.1;
local MAX_FONT_SCALE_SLIDER = 2;
local MIN_ICON_SCALE_SLIDER = 0.1;
local MAX_ICON_SCALE_SLIDER = 2;
local MIN_TRACKER_EFFECTS = 1;
local MAX_TRACKER_EFFECTS = 10;

local indexToAlignment = { "leftcenter", "center", "rightcenter" };

local windowDimensions = {};

local windowName = Obsidian.Setup.EffectTracker.WindowName;
local windowNameBar = windowName .. "ElementBars";
local windowNameTracker = windowName .. "ElementTracker";
local localization = Obsidian.Localization.GetMapping();

local elements =
{
	"ElementBars", "FriendlyTracker", "HostileTracker",
}

local barElements =
{
	"ElementBarsElementGeneral", "ElementBarsElementBackground", "ElementBarsElementFill", "ElementBarsElementName", "ElementBarsElementTimer",
}

local trackerElements =
{
	"ElementTrackerElementGeneral", "ElementTrackerElementIcon",
}

local lockSettings = false;

local activeElement = nil;
local activeBarElement = nil;
local activeFriendlyElement = nil;
local hoverColorExample = nil;
local hoverTextureButton = nil;
local hoverFontLabel = nil;
local activeTrackerSettings = nil;

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

local function LoadTrackerSettings()

	local settings = activeTrackerSettings;
	if (not settings) then return end
	lockSettings = true;
	
	ButtonSetPressedFlag(windowNameTracker .. "ElementGeneralEnable" .. "Button", (settings.Enabled == true));
	TextEditBoxSetText(windowNameTracker .. "ElementGeneralOffsetXEditBox", towstring(settings.X));
	TextEditBoxSetText(windowNameTracker .. "ElementGeneralOffsetYEditBox", towstring(settings.Y));
	ComboBoxSetSelectedMenuItem(windowNameTracker .. "ElementGeneralFillColorComboBox", settings.FillType or 1);
	ComboBoxSetSelectedMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox", settings.Position or 1);
	local color = settings.Color;
	WindowSetTintColor(windowNameTracker .. "ElementGeneralColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowNameTracker .. "ElementGeneralMaximumEffectsSlider", math.max(math.min(1, (settings.MaximumEffects - MIN_TRACKER_EFFECTS) / (MAX_TRACKER_EFFECTS - MIN_TRACKER_EFFECTS)), 0));
	
	WindowSetShowing(windowNameTracker .. "ElementGeneralColorExample", (settings.FillType == Obsidian.EffectBar.FillType.Custom));
	
	ButtonSetPressedFlag(windowNameTracker .. "ElementIconEnable" .. "Button", (settings.Icon.Enabled == true));
	TextEditBoxSetText(windowNameTracker .. "ElementIconOffsetXEditBox", towstring(settings.Icon.X));
	TextEditBoxSetText(windowNameTracker .. "ElementIconOffsetYEditBox", towstring(settings.Icon.Y));
	SliderBarSetCurrentPosition(windowNameTracker .. "ElementIconAlphaSlider", settings.Icon.Alpha or 1);
	ComboBoxSetSelectedMenuItem(windowNameTracker .. "ElementIconPositionComboBox", settings.Icon.Position or 1);
	SliderBarSetCurrentPosition(windowNameTracker .. "ElementIconScaleSlider", math.max(math.min(1, (settings.Icon.Scale - MIN_ICON_SCALE_SLIDER) / (MAX_ICON_SCALE_SLIDER - MIN_ICON_SCALE_SLIDER)), 0));
	
	Obsidian.Setup.EffectTracker.OnSlideTrackerMaximumEffects();
	Obsidian.Setup.EffectTracker.OnSlideTrackerIconAlpha();
	Obsidian.Setup.EffectTracker.OnSlideTrackerIconScale();
	
	lockSettings = false;

end

local function ShowBarElement(name)

	if (activeBarElement and activeBarElement ~= name) then
		WindowSetShowing(windowName .. activeBarElement, false);
	end
	
	local width, _ = GetWindowDimension(windowName);
	local barWidth, height = GetWindowDimension(windowName .. name);
	
	WindowSetDimensions(windowName, width, height + DEFAULT_HEIGHT + DEFAULT_BAR_HEIGHT);
	WindowSetDimensions(windowNameBar, barWidth, height + DEFAULT_BAR_HEIGHT);
	
	activeBarElement = name;
	WindowSetShowing(windowName .. activeBarElement, true);

end

local function ShowTrackerElement(name)

	if (activeFriendlyElement and activeFriendlyElement ~= name) then
		WindowSetShowing(windowName .. activeFriendlyElement, false);
	end
	
	local width, _ = GetWindowDimension(windowName);
	local barWidth, height = GetWindowDimension(windowName .. name);
	
	WindowSetDimensions(windowName, width, height + DEFAULT_HEIGHT + DEFAULT_FRIENDLY_HEIGHT);
	WindowSetDimensions(windowNameTracker, barWidth, height + DEFAULT_FRIENDLY_HEIGHT);
	
	activeFriendlyElement = name;
	WindowSetShowing(windowName .. activeFriendlyElement, true);

end

local function ShowElement(name)
	
	if (name == "ElementBars") then
		ComboBoxSetSelectedMenuItem(windowNameBar .. "ElementComboBox", 1);
		ShowBarElement(barElements[1]);
	elseif (name == "FriendlyTracker") then
		LabelSetText(windowNameTracker .. "ElementGeneralEnableCheckboxLabel", localization["Setup.EffectTracker.Friendly.Enable"]);
		name = "ElementTracker";
		activeTrackerSettings = Obsidian.Settings.EffectTracker.Friendly;
		ComboBoxSetSelectedMenuItem(windowNameTracker .. "ElementComboBox", 1);
		LoadTrackerSettings();
		ShowTrackerElement(trackerElements[1]);
	elseif (name == "HostileTracker") then
		LabelSetText(windowNameTracker .. "ElementGeneralEnableCheckboxLabel", localization["Setup.EffectTracker.Hostile.Enable"]);
		name = "ElementTracker";
		activeTrackerSettings = Obsidian.Settings.EffectTracker.Hostile;
		ComboBoxSetSelectedMenuItem(windowNameTracker .. "ElementComboBox", 1);
		LoadTrackerSettings();
		ShowTrackerElement(trackerElements[1]);
	else
		local width, _ = GetWindowDimension(windowName);
		local _, height = GetWindowDimension(windowName .. name);
		
		WindowSetDimensions(windowName, width, height + DEFAULT_HEIGHT + DEFAULT_BAR_HEIGHT);
	end

	if (activeElement and activeElement ~= name) then
		WindowSetShowing(windowName .. activeElement, false);
	end
	
	activeElement = name;
	WindowSetShowing(windowName .. activeElement, true);

end

function Obsidian.Setup.EffectTracker.Initialize()

	for index, element in ipairs(elements) do
		if (element == "FriendlyTracker" or element == "HostileTracker") then
			element = "ElementTracker";
		end
		WindowSetShowing(windowName .. element, false);
	end
	for index, element in ipairs(barElements) do
		WindowSetShowing(windowName .. element, false);
	end
	for index, element in ipairs(trackerElements) do
		WindowSetShowing(windowName .. element, false);
	end

	LabelSetText(windowName .. "TitleLabel", localization["Setup.EffectTracker.Title"]);
	LabelSetText(windowName .. "ElementLabel", localization["Setup.Castbar.Element"]);

	LabelSetText(windowNameBar .. "ElementGeneralLabel", localization["Setup.Castbar.General"]);
	LabelSetText(windowNameBar .. "ElementGeneralSizeLabel", localization["Strings.Size"]);
	LabelSetText(windowNameBar .. "ElementGeneralSizeWidthLabel", localization["Strings.Size.Width"]);
	LabelSetText(windowNameBar .. "ElementGeneralSizeHeightLabel", localization["Strings.Size.Height"]);
	LabelSetText(windowNameBar .. "ElementGeneralSpacingLabel", localization["Setup.EffectTracker.Bars.Spacing"]);
	LabelSetText(windowNameBar .. "ElementGeneralMaximumDurationLabel", localization["Setup.EffectTracker.Bars.MaximumDuration"]);
	LabelSetText(windowNameBar .. "ElementGeneralMaximumDurationSecondsLabel", localization["Setup.EffectTracker.Bars.Duration.Seconds"]);
	LabelSetText(windowNameBar .. "ElementGeneralFixedDurationLabel", localization["Setup.EffectTracker.Bars.FixedDuration"]);
	LabelSetText(windowNameBar .. "ElementGeneralFixedDurationSecondsLabel", localization["Setup.EffectTracker.Bars.Duration.Seconds"]);
	
	LabelSetText(windowNameBar .. "ElementBackgroundLabel", localization["Setup.Castbar.Background"]);
	LabelSetText(windowNameBar .. "ElementBackgroundColorLabel", localization["Strings.Color"]);
	LabelSetText(windowNameBar .. "ElementBackgroundAlphaLabel", localization["Strings.Alpha"]);
	
	LabelSetText(windowNameBar .. "ElementFillLabel", localization["Setup.Castbar.Fill"]);
	LabelSetText(windowNameBar .. "ElementFillAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowNameBar .. "ElementFillTextureLabel", localization["Strings.Texture"]);
	LabelSetText(windowNameBar .. "ElementFillUpdatePriorityLabel", localization["Setup.Castbar.Fill.UpdatePriority"]);
	ComboBoxClearMenuItems(windowNameBar .. "ElementFillUpdatePriorityComboBox");
	ComboBoxAddMenuItem(windowNameBar .. "ElementFillUpdatePriorityComboBox", localization["Setup.Castbar.Fill.UpdatePriority.Low"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementFillUpdatePriorityComboBox", localization["Setup.Castbar.Fill.UpdatePriority.Normal"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementFillUpdatePriorityComboBox", localization["Setup.Castbar.Fill.UpdatePriority.High"]);
	
	LabelSetText(windowNameBar .. "ElementNameLabel", localization["Setup.Castbar.Name"]);
	LabelSetText(windowNameBar .. "ElementNameOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowNameBar .. "ElementNameOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowNameBar .. "ElementNameOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowNameBar .. "ElementNameColorLabel", localization["Strings.Color"]);
	LabelSetText(windowNameBar .. "ElementNameAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowNameBar .. "ElementNameFontLabel", localization["Strings.Font"]);
	LabelSetText(windowNameBar .. "ElementNameScaleLabel", localization["Strings.Scale"]);
	LabelSetText(windowNameBar .. "ElementNameWidthLabel", localization["Strings.Size.Width"]);
	LabelSetText(windowNameBar .. "ElementNameAlignmentLabel", localization["Strings.Align"]);
	ComboBoxClearMenuItems(windowNameBar .. "ElementNameAlignmentComboBox");
	ComboBoxAddMenuItem(windowNameBar .. "ElementNameAlignmentComboBox", localization["Strings.Align.Left"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementNameAlignmentComboBox", localization["Strings.Align.Center"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementNameAlignmentComboBox", localization["Strings.Align.Right"]);
	
	LabelSetText(windowNameBar .. "ElementTimerLabel", localization["Setup.Castbar.Timer"]);
	LabelSetText(windowNameBar .. "ElementTimerOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowNameBar .. "ElementTimerOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowNameBar .. "ElementTimerOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowNameBar .. "ElementTimerColorLabel", localization["Strings.Color"]);
	LabelSetText(windowNameBar .. "ElementTimerAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowNameBar .. "ElementTimerFontLabel", localization["Strings.Font"]);
	LabelSetText(windowNameBar .. "ElementTimerScaleLabel", localization["Strings.Scale"]);
	LabelSetText(windowNameBar .. "ElementTimerAlignmentLabel", localization["Strings.Align"]);
	ComboBoxClearMenuItems(windowNameBar .. "ElementTimerAlignmentComboBox");
	ComboBoxAddMenuItem(windowNameBar .. "ElementTimerAlignmentComboBox", localization["Strings.Align.Left"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementTimerAlignmentComboBox", localization["Strings.Align.Center"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementTimerAlignmentComboBox", localization["Strings.Align.Right"]);

	ComboBoxClearMenuItems(windowName .. "ElementComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.EffectTracker.Bars"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.EffectTracker.Friendly"]);
	ComboBoxAddMenuItem(windowName .. "ElementComboBox", localization["Setup.EffectTracker.Hostile"]);
	
	ComboBoxClearMenuItems(windowNameBar .. "ElementComboBox");
	ComboBoxAddMenuItem(windowNameBar .. "ElementComboBox", localization["Setup.Castbar.General"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementComboBox", localization["Setup.Castbar.Background"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementComboBox", localization["Setup.Castbar.Fill"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementComboBox", localization["Setup.Castbar.Name"]);
	ComboBoxAddMenuItem(windowNameBar .. "ElementComboBox", localization["Setup.Castbar.Timer"]);

	LabelSetText(windowNameTracker .. "ElementGeneralLabel", localization["Setup.Castbar.General"]);
	LabelSetText(windowNameTracker .. "ElementGeneralOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowNameTracker .. "ElementGeneralOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowNameTracker .. "ElementGeneralOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowNameTracker .. "ElementGeneralFillColorLabel", localization["Setup.EffectTracker.Tracker.FillColor"]);
	ComboBoxClearMenuItems(windowNameTracker .. "ElementGeneralFillColorComboBox");
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralFillColorComboBox", localization["Setup.EffectTracker.Tracker.FillColor.EffectType"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralFillColorComboBox", localization["Setup.EffectTracker.Tracker.FillColor.BuffDebuff"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralFillColorComboBox", localization["Setup.EffectTracker.Tracker.FillColor.Custom"]);
	LabelSetText(windowNameTracker .. "ElementGeneralPositionLabel", localization["Setup.EffectTracker.Tracker.Position"]);
	ComboBoxClearMenuItems(windowNameTracker .. "ElementGeneralPositionComboBox");
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox", localization["Setup.EffectTracker.Tracker.Position.TopLeft"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox", localization["Setup.EffectTracker.Tracker.Position.TopRight"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox", localization["Setup.EffectTracker.Tracker.Position.BottomLeft"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox", localization["Setup.EffectTracker.Tracker.Position.BottomRight"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox", localization["Setup.EffectTracker.Tracker.Position.FreeUp"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox", localization["Setup.EffectTracker.Tracker.Position.FreeDown"]);
	LabelSetText(windowNameTracker .. "ElementGeneralMaximumEffectsLabel", localization["Setup.EffectTracker.Tracker.MaximumEffects"]);
	
	LabelSetText(windowNameTracker .. "ElementIconLabel", localization["Setup.Castbar.Icon"]);
	LabelSetText(windowNameTracker .. "ElementIconEnableCheckboxLabel", localization["Setup.Castbar.Icon.Enable"]);
	LabelSetText(windowNameTracker .. "ElementIconOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowNameTracker .. "ElementIconOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowNameTracker .. "ElementIconOffsetYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowNameTracker .. "ElementIconAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowNameTracker .. "ElementIconPositionLabel", localization["Strings.Position"]);
	ComboBoxClearMenuItems(windowNameTracker .. "ElementIconPositionComboBox");
	ComboBoxAddMenuItem(windowNameTracker .. "ElementIconPositionComboBox", localization["Strings.Position.Left"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementIconPositionComboBox", localization["Strings.Position.Right"]);
	LabelSetText(windowNameTracker .. "ElementIconScaleLabel", localization["Strings.Scale"]);
	
	ComboBoxClearMenuItems(windowNameTracker .. "ElementComboBox");
	ComboBoxAddMenuItem(windowNameTracker .. "ElementComboBox", localization["Setup.Castbar.General"]);
	ComboBoxAddMenuItem(windowNameTracker .. "ElementComboBox", localization["Setup.Castbar.Icon"]);
	
	ComboBoxSetSelectedMenuItem(windowName .. "ElementComboBox", 1);
	ShowElement(elements[1]);
	
	Obsidian.Setup.EffectTracker.LoadSettings();
	
end

function Obsidian.Setup.EffectTracker.LoadSettings()
	
	lockSettings = true;
	local settings = Obsidian.Settings.EffectTracker;
	local generalSettings = settings.General;
	
	TextEditBoxSetText(windowNameBar .. "ElementGeneralSizeWidthEditBox", towstring(generalSettings.Size.Width));
	TextEditBoxSetText(windowNameBar .. "ElementGeneralSizeHeightEditBox", towstring(generalSettings.Size.Height));
	TextEditBoxSetText(windowNameBar .. "ElementGeneralSpacingEditBox", towstring(generalSettings.Spacing));
	TextEditBoxSetText(windowNameBar .. "ElementGeneralMaximumDurationEditBox", towstring(generalSettings.MaximumThreshold));
	TextEditBoxSetText(windowNameBar .. "ElementGeneralFixedDurationEditBox", towstring(generalSettings.FixedDuration));
	
	local color = generalSettings.Background.Color;
	WindowSetTintColor(windowNameBar .. "ElementBackgroundColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowNameBar .. "ElementBackgroundAlphaSlider", generalSettings.Background.Alpha or 1);
	
	SliderBarSetCurrentPosition(windowNameBar .. "ElementFillAlphaSlider", generalSettings.Fill.Alpha or 1);
	SetTextureButton(windowNameBar .. "ElementFillTextureButton", generalSettings.Fill.Texture, towstring(Obsidian.Textures.GetName(generalSettings.Fill.Texture)));
	ComboBoxSetSelectedMenuItem(windowNameBar .. "ElementFillUpdatePriorityComboBox", generalSettings.Fill.Priority or 1);
	
	color = generalSettings.Name.Color;
	WindowSetTintColor(windowNameBar .. "ElementNameColorExampleColor", color.R, color.G, color.B);
	TextEditBoxSetText(windowNameBar .. "ElementNameOffsetXEditBox", towstring(generalSettings.Name.X));
	TextEditBoxSetText(windowNameBar .. "ElementNameOffsetYEditBox", towstring(generalSettings.Name.Y));
	SliderBarSetCurrentPosition(windowNameBar .. "ElementNameAlphaSlider", generalSettings.Name.Alpha or 1);
	LabelSetText(windowNameBar .. "ElementNameFontExampleLabel", towstring(Obsidian.Setup.SelectFont.GetFontName(generalSettings.Name.Font)));
	LabelSetFont(windowNameBar .. "ElementNameFontExampleLabel", generalSettings.Name.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	SliderBarSetCurrentPosition(windowNameBar .. "ElementNameScaleSlider", math.max(math.min(1, (generalSettings.Name.Scale - MIN_FONT_SCALE_SLIDER) / (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER)), 0));
	SliderBarSetCurrentPosition(windowNameBar .. "ElementNameWidthSlider", generalSettings.Name.Width);
	ComboBoxSetSelectedMenuItem(windowNameBar .. "ElementNameAlignmentComboBox", GetAlignmentIndex(generalSettings.Name.Alignment));
	
	color = generalSettings.Timer.Color;
	WindowSetTintColor(windowNameBar .. "ElementTimerColorExampleColor", color.R, color.G, color.B);
	TextEditBoxSetText(windowNameBar .. "ElementTimerOffsetXEditBox", towstring(generalSettings.Timer.X));
	TextEditBoxSetText(windowNameBar .. "ElementTimerOffsetYEditBox", towstring(generalSettings.Timer.Y));
	SliderBarSetCurrentPosition(windowNameBar .. "ElementTimerAlphaSlider", generalSettings.Timer.Alpha or 1);
	LabelSetText(windowNameBar .. "ElementTimerFontExampleLabel", towstring(Obsidian.Setup.SelectFont.GetFontName(generalSettings.Timer.Font)));
	LabelSetFont(windowNameBar .. "ElementTimerFontExampleLabel", generalSettings.Timer.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	SliderBarSetCurrentPosition(windowNameBar .. "ElementTimerScaleSlider", math.max(math.min(1, (generalSettings.Timer.Scale - MIN_FONT_SCALE_SLIDER) / (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER)), 0));
	ComboBoxSetSelectedMenuItem(windowNameBar .. "ElementTimerAlignmentComboBox", GetAlignmentIndex(generalSettings.Timer.Alignment));
	
	Obsidian.Setup.EffectTracker.OnSlideBackgroundAlpha();
	Obsidian.Setup.EffectTracker.OnSlideFillAlpha();
	Obsidian.Setup.EffectTracker.OnSlideNameAlpha();
	Obsidian.Setup.EffectTracker.OnSlideNameScale();
	Obsidian.Setup.EffectTracker.OnSlideNameWidth();
	Obsidian.Setup.EffectTracker.OnSlideTimerAlpha();
	Obsidian.Setup.EffectTracker.OnSlideTimerScale();
	
	lockSettings = false;
	
end

function Obsidian.Setup.EffectTracker.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	Obsidian.Setup.Demo.Enable(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, Obsidian.Setup.EffectTracker.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function Obsidian.Setup.EffectTracker.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function Obsidian.Setup.EffectTracker.OnHidden()

	Obsidian.Setup.SelectTexture.Hide();
	Obsidian.Setup.SelectColor.Hide();
	Obsidian.Setup.Demo.Disable();
	Obsidian.Setup.SetActiveWindow();

end

function Obsidian.Setup.EffectTracker.OnCloseLUp()

	Obsidian.Setup.EffectTracker.Hide();

end

function Obsidian.Setup.EffectTracker.OnElementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementComboBox");
	if (elements[value]) then
		ShowElement(elements[value]);
	end
	
	Obsidian.Setup.SelectTexture.Hide();
	Obsidian.Setup.SelectColor.Hide();

end

function Obsidian.Setup.EffectTracker.OnBarElementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowNameBar .. "ElementComboBox");
	if (barElements[value]) then
		ShowBarElement(barElements[value]);
	end
	
	Obsidian.Setup.SelectTexture.Hide();
	Obsidian.Setup.SelectColor.Hide();

end

function Obsidian.Setup.EffectTracker.OnTrackerElementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowNameTracker .. "ElementComboBox");
	if (trackerElements[value]) then
		ShowTrackerElement(trackerElements[value]);
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

function Obsidian.Setup.EffectTracker.OnGeneralSizeWidthChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementGeneralSizeWidthEditBox"));
	Obsidian.Settings.EffectTracker.General.Size.Width = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnGeneralSizeHeightChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementGeneralSizeHeightEditBox"));
	Obsidian.Settings.EffectTracker.General.Size.Height = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnGeneralSpacingChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementGeneralSpacingEditBox"));
	Obsidian.Settings.EffectTracker.General.Spacing = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnGeneralMaximumDurationChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementGeneralMaximumDurationEditBox"));
	Obsidian.Settings.EffectTracker.General.MaximumThreshold = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnGeneralFixedDurationChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementGeneralFixedDurationEditBox"));
	Obsidian.Settings.EffectTracker.General.FixedDuration = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnBackgroundColorLUp()
	local colorExample = windowNameBar .. "ElementBackgroundColorExample";
	local colorSettings = Obsidian.Settings.EffectTracker.General.Background.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.EffectTracker.OnFillUpdatePriorityChanged()
	local value = ComboBoxGetSelectedMenuItem(windowNameBar .. "ElementFillUpdatePriorityComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Fill.Priority = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnColorExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverColorExample = windowName;
	WindowSetTintColor(hoverColorExample .. "Border", 255, 110, 10);
end

function Obsidian.Setup.EffectTracker.OnColorExampleMouseOut()
	if (not hoverColorExample) then return end
	WindowSetTintColor(hoverColorExample .. "Border", 50, 50, 50);
	hoverColorExample = nil;
end

function Obsidian.Setup.EffectTracker.OnFontExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverFontLabel = windowName;
	LabelSetTextColor(hoverFontLabel, 255, 110, 10);
end

function Obsidian.Setup.EffectTracker.OnFontExampleMouseOut()
	if (not hoverFontLabel) then return end
	LabelSetTextColor(hoverFontLabel, 255, 255, 255);
	hoverFontLabel = nil;
end

function Obsidian.Setup.EffectTracker.OnSlideBackgroundAlpha()
	local value = SliderBarGetCurrentPosition(windowNameBar .. "ElementBackgroundAlphaSlider");
	LabelSetText(windowNameBar .. "ElementBackgroundAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Background.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnSlideFillAlpha()
	local value = SliderBarGetCurrentPosition(windowNameBar .. "ElementFillAlphaSlider");
	LabelSetText(windowNameBar .. "ElementFillAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Fill.Alpha = value;
		OnSettingsChanged();
	end
end

local function SelectTexture(texture, textureButton, settings)
	SetTextureButton(windowNameBar .. "ElementFillTextureButton", texture.Texture, texture.Name, texture.Dimensions)
		
	settings.Texture = texture.Texture;
	settings.TextureDimensions = texture.Dimensions;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnFillTextureLUp()
	Obsidian.Setup.SelectTexture.Show(windowName, windowNameBar .. "ElementFillTextureButton", 
		function(texture) SelectTexture(texture, windowNameBar .. "ElementFillTextureButton", Obsidian.Settings.EffectTracker.General.Fill) end);
end

function Obsidian.Setup.EffectTracker.OnTextureButtonMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverTextureButton = windowName;
	LabelSetTextColor(hoverTextureButton .. "Name", 255, 110, 10);
end

function Obsidian.Setup.EffectTracker.OnTextureButtonMouseOut()
	if (not hoverTextureButton) then return end
	LabelSetTextColor(hoverTextureButton .. "Name", 255, 255, 255);
	hoverTextureButton = nil;
end

local function SelectFont(font, label, settings)
	settings.Font = font.Font;
	LabelSetText(label, towstring(font.Name));
	LabelSetFont(label, font.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnNameOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementNameOffsetXEditBox"));
	Obsidian.Settings.EffectTracker.General.Name.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnNameOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementNameOffsetYEditBox"));
	Obsidian.Settings.EffectTracker.General.Name.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnNameAlignmentChanged()
	local value = ComboBoxGetSelectedMenuItem(windowNameBar .. "ElementNameAlignmentComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Name.Alignment = indexToAlignment[value];
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnNameColorLUp()
	local colorExample = windowNameBar .. "ElementNameColorExample";
	local colorSettings = Obsidian.Settings.EffectTracker.General.Name.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.EffectTracker.OnSlideNameAlpha()
	local value = SliderBarGetCurrentPosition(windowNameBar .. "ElementNameAlphaSlider");
	LabelSetText(windowNameBar .. "ElementNameAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Name.Alpha = value;
		Obsidian.Settings.EffectTracker.General.Name.Enabled = (value > 0);
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnNameFontLUp()
	Obsidian.Setup.SelectFont.Show(function(font) SelectFont(font, windowNameBar .. "ElementNameFontExampleLabel", Obsidian.Settings.EffectTracker.General.Name) end);
end

function Obsidian.Setup.EffectTracker.OnSlideNameScale()
	local value = MIN_FONT_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowNameBar .. "ElementNameScaleSlider") * (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowNameBar .. "ElementNameScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Name.Scale = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnSlideNameWidth()
	local value = math.floor(SliderBarGetCurrentPosition(windowNameBar .. "ElementNameWidthSlider") * 100) / 100;
	LabelSetText(windowNameBar .. "ElementNameWidthValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Name.Width = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnTimerOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementTimerOffsetXEditBox"));
	Obsidian.Settings.EffectTracker.General.Timer.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnTimerOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameBar .. "ElementTimerOffsetYEditBox"));
	Obsidian.Settings.EffectTracker.General.Timer.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnTimerAlignmentChanged()
	local value = ComboBoxGetSelectedMenuItem(windowNameBar .. "ElementTimerAlignmentComboBox");
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Timer.Alignment = indexToAlignment[value];
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnTimerColorLUp()
	local colorExample = windowNameBar .. "ElementTimerColorExample";
	local colorSettings = Obsidian.Settings.EffectTracker.General.Timer.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.EffectTracker.OnSlideTimerAlpha()
	local value = SliderBarGetCurrentPosition(windowNameBar .. "ElementTimerAlphaSlider");
	LabelSetText(windowNameBar .. "ElementTimerAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Timer.Alpha = value;
		Obsidian.Settings.EffectTracker.General.Timer.Enabled = (value > 0);
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnTimerFontLUp()
	Obsidian.Setup.SelectFont.Show(function(font) SelectFont(font, windowNameBar .. "ElementTimerFontExampleLabel", Obsidian.Settings.EffectTracker.General.Timer) end);
end

function Obsidian.Setup.EffectTracker.OnSlideTimerScale()
	local value = MIN_FONT_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowNameBar .. "ElementTimerScaleSlider") * (MAX_FONT_SCALE_SLIDER - MIN_FONT_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowNameBar .. "ElementTimerScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		Obsidian.Settings.EffectTracker.General.Timer.Scale = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnTrackerEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowNameTracker .. "ElementGeneralEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowNameTracker .. "ElementGeneralEnable" .. "Button", isChecked);
	activeTrackerSettings.Enabled = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnTrackerOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameTracker .. "ElementGeneralOffsetXEditBox"));
	activeTrackerSettings.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnTrackerOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameTracker .. "ElementGeneralOffsetYEditBox"));
	activeTrackerSettings.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnTrackerFillColorChanged()
	local value = ComboBoxGetSelectedMenuItem(windowNameTracker .. "ElementGeneralFillColorComboBox");
	WindowSetShowing(windowNameTracker .. "ElementGeneralColorExample", (value == Obsidian.EffectBar.FillType.Custom));
	Obsidian.Setup.SelectColor.Hide();
	
	if (not lockSettings) then
		activeTrackerSettings.FillType = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnTrackerFillColorLUp()
	local colorExample = windowNameTracker .. "ElementGeneralColorExample";
	local colorSettings = activeTrackerSettings.Color;
	
	Obsidian.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function Obsidian.Setup.EffectTracker.OnTrackerPositionChanged()
	local value = ComboBoxGetSelectedMenuItem(windowNameTracker .. "ElementGeneralPositionComboBox");
	
	if (not lockSettings) then
		activeTrackerSettings.Position = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnSlideTrackerMaximumEffects()
	local value = MIN_TRACKER_EFFECTS + math.floor(SliderBarGetCurrentPosition(windowNameTracker .. "ElementGeneralMaximumEffectsSlider") * (MAX_TRACKER_EFFECTS - MIN_TRACKER_EFFECTS));
	LabelSetText(windowNameTracker .. "ElementGeneralMaximumEffectsValue", towstring(value));
	
	if (not lockSettings) then
		activeTrackerSettings.MaximumEffects = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnTrackerIconEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowNameTracker .. "ElementIconEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowNameTracker .. "ElementIconEnable" .. "Button", isChecked);
	activeTrackerSettings.Icon.Enabled = isChecked;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnSlideTrackerIconAlpha()
	local value = SliderBarGetCurrentPosition(windowNameTracker .. "ElementIconAlphaSlider");
	LabelSetText(windowNameTracker .. "ElementIconAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		activeTrackerSettings.Icon.Alpha = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnSlideTrackerIconScale()
	local value = MIN_ICON_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowNameTracker .. "ElementIconScaleSlider") * (MAX_ICON_SCALE_SLIDER - MIN_ICON_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowNameTracker .. "ElementIconScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		activeTrackerSettings.Icon.Scale = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.EffectTracker.OnTrackerIconOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameTracker .. "ElementIconOffsetXEditBox"));
	activeTrackerSettings.Icon.X = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnTrackerIconOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowNameTracker .. "ElementIconOffsetYEditBox"));
	activeTrackerSettings.Icon.Y = value;
	OnSettingsChanged();
end

function Obsidian.Setup.EffectTracker.OnTrackerIconPositionChanged()
	local value = ComboBoxGetSelectedMenuItem(windowNameTracker .. "ElementIconPositionComboBox");
	
	if (not lockSettings) then
		activeTrackerSettings.Icon.Position = value;
		OnSettingsChanged();
	end
end

function Obsidian.Setup.Castbar.OnTrackerSlideIconScale()
	local value = MIN_ICON_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "ElementIconScaleSlider") * (MAX_ICON_SCALE_SLIDER - MIN_ICON_SCALE_SLIDER) * 100) / 100;
	LabelSetText(windowName .. "ElementIconScaleValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		activeTrackerSettings.Icon.Scale = value;
		OnSettingsChanged();
	end
end