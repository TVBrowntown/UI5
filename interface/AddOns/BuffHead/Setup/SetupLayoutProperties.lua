BuffHead.Setup.Layout.Properties = 
{
	WindowName = "BuffHeadSetupLayoutPropertiesWindow",
};

local this = BuffHead.Setup.Layout.Properties;

local DEFAULT_HEIGHT = 160;
local MIN_FONT_SCALE_SLIDER = 0.1;
local MAX_FONT_SCALE_SLIDER = 2;
local MIN_ICON_SCALE_SLIDER = 0.1;
local MAX_ICON_SCALE_SLIDER = 2;
local MIN_TIMER_DECIMALS_SLIDER = 0;
local MAX_TIMER_DECIMALS_SLIDER = 3;
local MAX_SIZE_SCALE_SLIDER = 2;

local windowDimensions = {};

local windowName = this.WindowName;
local localization = BuffHead.Localization.GetMapping();

local LayoutFrame = BuffHead.Setup.Layout.Frames;

local elements =
{
	CoreSize = --width, height (for the layer 0 size element)
	{
		Name = localization["Strings.Size"],
		Window = "ElementCoreSize",
	},
	Size = --width, height, scale
	{
		Name = localization["Strings.Size"],
		Window = "ElementSize",
	},
	Alpha = --alpha
	{
		Name = localization["Strings.Alpha"],
		Window = "ElementAlpha",
	},
	Layer = --layer
	{
		Name = localization["Strings.Layer"],
		Window = "ElementLayer",
	},
	Font = -- font type, align and color
	{
		Name = localization["Layout.Properties.Font"],
		Window = "ElementFont",
	},
	DurationFormat = -- format for duration text
	{
		Name = localization["Layout.Properties.DurationFormat"],
		Window = "ElementDurationFormat",
	},
	StatusBar = -- texture, color, alpha
	{
		Name = localization["Layout.Properties.StatusBar"],
		Window = "ElementStatusBar",
	},
	StatusBarOrientation = -- orientation
	{
		Name = localization["Layout.Properties.StatusBarOrientation"],
		Window = "ElementStatusBarOrientation",
	},
	IconBorder = -- enable, color, alpha
	{
		Name = localization["Layout.Properties.IconBorder"],
		Window = "ElementIconBorder",
	},
	Offset = -- x, y
	{
		Name = localization["Strings.Offset"],
		Window = "ElementOffset",
	},
};

local propertyElements =
{
	[LayoutFrame.Size] = { elements.CoreSize },
	[LayoutFrame.Icon] = { elements.Size, elements.Offset, elements.Alpha, elements.Layer, elements.IconBorder },
	[LayoutFrame.StatusBar] = { elements.Size, elements.Offset,elements.Layer, elements.StatusBar, elements.StatusBarOrientation },
	[LayoutFrame.Duration] = { elements.Size, elements.Offset, elements.Alpha, elements.Layer, elements.Font, elements.DurationFormat },
	[LayoutFrame.StackCount] = { elements.Size, elements.Offset, elements.Alpha, elements.Layer, elements.Font },
	[LayoutFrame.Name] = { elements.Size, elements.Offset, elements.Alpha, elements.Layer, elements.Font },
};

local availableProperties = { LayoutFrame.Size, LayoutFrame.Icon, LayoutFrame.StatusBar, LayoutFrame.Duration, LayoutFrame.StackCount, LayoutFrame.Name };
local propertyToIndex = {};

local availableElements = {};

local indexToAlignment = { "bottom", "bottomleft", "bottomright", "center", "left", "leftcenter", "right", "rightcenter" };
local lockSettings = false;
local lockSlider = false;

local activeLayoutFrame = nil;
local activeElement = nil;
local hoverColorExample = nil;
local hoverTextureButton = nil;
local hoverFontLabel = nil;
local activeSettings = nil;

local function GetSettings()
	return activeSettings or {};
end

local function GetAlignmentIndex(align)
	for index, alignment in ipairs(indexToAlignment) do
		if (align == alignment) then
			return index;
		end
	end
	return 1;
end

local function SetTextureButton(textureButton, texture, name, dimensions)
	if (not dimensions) then
		dimensions = BuffHead.Textures.GetDimensions(texture);
	end
	DynamicImageSetTexture(textureButton .. "Texture", texture, 0, 0);
	DynamicImageSetTextureDimensions(textureButton .. "Texture", dimensions.Width, dimensions.Height);
	if (name) then
		LabelSetText(textureButton .. "Name", name);
	end
end

local function LoadSizeSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementSize";

	local width, height = settings.Width, settings.Height;

	TextEditBoxSetText(windowName .. "SizeWidthEditBox", towstring(width or 0));
	TextEditBoxSetText(windowName .. "SizeHeightEditBox", towstring(height or 0));
	TextEditBoxSetText(windowName .. "ScaleEditBox",  towstring(string.format("%.2f", settings.Scale)));

	lockSettings = false;
end

local function LoadCoreSizeSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementCoreSize";

	local width, height = settings.Width, settings.Height;

	TextEditBoxSetText(windowName .. "SizeWidthEditBox", towstring(width or 0));
	TextEditBoxSetText(windowName .. "SizeHeightEditBox", towstring(height or 0));

	lockSettings = false;
end

local function LoadOffsetSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementOffset";

	TextEditBoxSetText(windowName .. "OffsetXEditBox", towstring(settings.X));
	TextEditBoxSetText(windowName .. "OffsetYEditBox", towstring(settings.Y));

	lockSettings = false;
end

local function LoadAlphaSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementAlpha";

	SliderBarSetCurrentPosition(windowName .. "AlphaSlider", settings.Alpha or 1);
	this.OnSlideAlphaAlpha();

	lockSettings = false;
end

local function LoadLayerSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementLayer";

	ComboBoxSetSelectedMenuItem(windowName .. "LayerComboBox", settings.Layer or 1);

	lockSettings = false;
end

local function LoadStatusBarSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementStatusBar";

	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", (settings.Enabled == true));

	local color = settings.Background.Color;
	WindowSetTintColor(windowName .. "BackgroundColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "BackgroundAlphaSlider", settings.Background.Alpha or 1);
	
	color = settings.Foreground.Color;
	WindowSetTintColor(windowName .. "ForegroundColorExampleColor", color.R, color.G, color.B);
	SliderBarSetCurrentPosition(windowName .. "ForegroundAlphaSlider", settings.Foreground.Alpha or 1);

	ComboBoxSetSelectedMenuItem(windowName .. "ForegroundColorTypeComboBox", settings.Foreground.Type);
	
	SetTextureButton(windowName .. "ForegroundTextureButton", settings.Foreground.Texture,
		towstring(BuffHead.Textures.GetName(settings.Foreground.Texture)), settings.Foreground.TextureDimensions);
		
	ButtonSetPressedFlag(windowName .. "ForegroundStretch" .. "Button", (settings.Foreground.Stretch == true));
	
	this.OnSlideStatusBarBackgroundAlpha();
	this.OnSlideStatusBarForegroundAlpha();

	lockSettings = false;
end

local function LoadStatusBarOrientationSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementStatusBarOrientation";
	ComboBoxSetSelectedMenuItem(windowName .. "OrientationComboBox", settings.Orientation);
	ButtonSetPressedFlag(windowName .. "Reverse" .. "Button", (settings.Reverse == true));

	lockSettings = false;
end

local function LoadFontSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementFont";

	local color = settings.Color;
	WindowSetTintColor(windowName .. "ColorExampleColor", color.R, color.G, color.B);
	
	local alignment = 1;
	for index, align in ipairs(indexToAlignment) do
		if (settings.Alignment == align) then
			alignment = index;
			break;
		end
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "AlignmentComboBox", alignment);
	
	LabelSetText(windowName .. "FontExampleLabel", towstring(BuffHead.Setup.SelectFont.GetFontName(settings.Font)));
	LabelSetFont(windowName .. "FontExampleLabel", settings.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);

	lockSettings = false;
end

local function LoadDurationFormatSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementDurationFormat";
	
	ComboBoxSetSelectedMenuItem(windowName .. "FormatComboBox", settings.Format);

	lockSettings = false;
end

local function LoadIconBorderSettings(settings)
	lockSettings = true;
	
	local windowName = windowName .. "ElementIconBorder";
	
	local color = settings.Border.Color;
	WindowSetTintColor(windowName .. "ColorExampleColor", color.R, color.G, color.B);

	SliderBarSetCurrentPosition(windowName .. "AlphaSlider", settings.Border.Alpha or 1);
	
	ComboBoxSetSelectedMenuItem(windowName .. "ColorTypeComboBox", settings.Border.Type);
	
	this.OnSlideIconBorderAlpha();

	lockSettings = false;
end

local function LoadElementSettings(element)
	if (element == elements.CoreSize) then
		LoadCoreSizeSettings(GetSettings());
	elseif (element == elements.Size) then
		LoadSizeSettings(GetSettings());
	elseif (element == elements.Offset) then
		LoadOffsetSettings(GetSettings());
	elseif (element == elements.Alpha) then
		LoadAlphaSettings(GetSettings());
	elseif (element == elements.Layer) then
		LoadLayerSettings(GetSettings());
	elseif (element == elements.Font) then
		LoadFontSettings(GetSettings());
	elseif (element == elements.DurationFormat) then
		LoadDurationFormatSettings(GetSettings());
	elseif (element == elements.StatusBar) then
		LoadStatusBarSettings(GetSettings());
	elseif (element == elements.StatusBarOrientation) then
		LoadStatusBarOrientationSettings(GetSettings());
	elseif (element == elements.IconBorder) then
		LoadIconBorderSettings(GetSettings());
	end
end

local function OnSettingsChanged(onlyAnchor)
	BuffHead.Setup.Demo.OnSettingsChanged();
end

local function UpdateLayoutFrame()
	if (activeLayoutFrame) then
		local settings = GetSettings();
		BuffHead.Setup.LayoutControlFrame.SetSize(activeLayoutFrame, settings.Width or 10, settings.Height or 10, settings.Scale or 1);
		if (activeLayoutFrame:IsActive()) then
			BuffHead.Setup.Layout.RemoveControlFrame(activeLayoutFrame);
		end
	end
end

local function UpdateLayoutFrameOffset()
	-- convert the relative offset to the onscreen offset
	if (activeLayoutFrame) then
		BuffHead.Setup.Layout.LoadLayout();
		if (activeLayoutFrame:IsActive()) then
			BuffHead.Setup.Layout.RemoveControlFrame(activeLayoutFrame);
		end
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

local function ShowElement(element)

	if (activeElement and activeElement ~= element) then
		WindowSetShowing(windowName .. activeElement.Window, false);
	end
	
	local width, _ = GetWindowDimension(windowName);
	local _, height = GetWindowDimension(windowName .. element.Window);
	
	local x, y = WindowGetScreenPosition(windowName);
	
	WindowSetDimensions(windowName, width, height + DEFAULT_HEIGHT);

	local interfaceScale = InterfaceCore.GetScale();
	WindowClearAnchors(windowName);
	--WindowAddAnchor(windowName, "topleft", "Root", "topleft", x / interfaceScale, y / interfaceScale);
	WindowAddAnchor(windowName, "topleft", "RootFrame", "topleft", x / interfaceScale, y / interfaceScale);
	activeElement = element;
	WindowSetShowing(windowName .. element.Window, true);

end

local function GetPropertyTitle(propertyId)
	if (propertyId == LayoutFrame.Size) then
		return localization["Layout.Size"];
	elseif (propertyId == LayoutFrame.Icon) then
		return localization["Layout.Icon"];
	elseif (propertyId == LayoutFrame.StatusBar) then
		return localization["Layout.StatusBar"];
	elseif (propertyId == LayoutFrame.Duration) then
		return localization["Layout.Duration"];
	elseif (propertyId == LayoutFrame.StackCount) then
		return localization["Layout.StackCount"];
	elseif (propertyId == LayoutFrame.Name) then
		return localization["Layout.Name"];
	end

	return localization["Setup.Layout.Properties.Title"];	
end

local function ShowProperty(propertyId)
	
	LabelSetText(windowName .. "TitleLabel", GetPropertyTitle(propertyId));

	availableElements = propertyElements[propertyId] or {};
	
	ComboBoxClearMenuItems(windowName .. "ElementComboBox");
	for index, element in ipairs(availableElements) do
		ComboBoxAddMenuItem(windowName .. "ElementComboBox", element.Name);
		LoadElementSettings(element);
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "ElementComboBox", 1);
	ShowElement(availableElements[1]);

end

function BuffHead.Setup.Layout.Properties.Initialize()

	for id, element in pairs(elements) do
		WindowSetShowing(windowName .. element.Window, false);
	end
	
	ComboBoxClearMenuItems(windowName .. "PropertiesComboBox");
	for index, id in ipairs(availableProperties) do
		propertyToIndex[id] = index;
		ComboBoxAddMenuItem(windowName .. "PropertiesComboBox", GetPropertyTitle(id));
	end
	WindowSetShowing(windowName .. "PropertiesComboBox", false);

	LabelSetText(windowName .. "ElementLabel", localization["Layout.Properties.Property"]);
	
	LabelSetText(windowName .. "ElementCoreSizeSizeLabel", localization["Strings.Size"]);
	LabelSetText(windowName .. "ElementCoreSizeSizeWidthLabel", localization["Strings.Size.Width"]);
	LabelSetText(windowName .. "ElementCoreSizeSizeHeightLabel", localization["Strings.Size.Height"]);
	LabelSetText(windowName .. "ElementCoreSizeAutoSizeLabel", localization["Layout.Properties.CoreSize.AutoSize.Info"]);
	ButtonSetText(windowName .. "ElementCoreSizeAutoSizeButton", localization["Layout.Properties.CoreSize.AutoSize"]);
	
	LabelSetText(windowName .. "ElementSizeSizeLabel", localization["Strings.Size"]);
	LabelSetText(windowName .. "ElementSizeSizeWidthLabel", localization["Strings.Size.Width"]);
	LabelSetText(windowName .. "ElementSizeSizeHeightLabel", localization["Strings.Size.Height"]);
	LabelSetText(windowName .. "ElementSizeScaleLabel", localization["Strings.Scale"]);
	
	LabelSetText(windowName .. "ElementOffsetOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowName .. "ElementOffsetOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementOffsetOffsetYLabel", localization["Strings.Offset.Y"]);
	
	LabelSetText(windowName .. "ElementAlphaAlphaLabel", localization["Strings.Alpha"]);

	LabelSetText(windowName .. "ElementLayerLayerLabel", localization["Strings.Layer"]);
	ComboBoxClearMenuItems(windowName .. "ElementLayerLayerComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementLayerLayerComboBox", localization["Layout.Layers.Layer1"]);
	ComboBoxAddMenuItem(windowName .. "ElementLayerLayerComboBox", localization["Layout.Layers.Layer2"]);
	ComboBoxAddMenuItem(windowName .. "ElementLayerLayerComboBox", localization["Layout.Layers.Layer3"]);
	ComboBoxAddMenuItem(windowName .. "ElementLayerLayerComboBox", localization["Layout.Layers.Layer4"]);
	
	LabelSetText(windowName .. "ElementStatusBarEnableCheckboxLabel", localization["Layout.Properties.StatusBar.Enable"]);
	LabelSetText(windowName .. "ElementStatusBarBackgroundLabel", localization["Layout.Properties.StatusBar.Background"]);
	LabelSetText(windowName .. "ElementStatusBarBackgroundColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementStatusBarBackgroundAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementStatusBarForegroundLabel", localization["Layout.Properties.StatusBar.Foreground"]);
	LabelSetText(windowName .. "ElementStatusBarForegroundColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementStatusBarForegroundAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementStatusBarForegroundColorTypeLabel", localization["Layout.Properties.ColorType"]);
	ComboBoxClearMenuItems(windowName .. "ElementStatusBarForegroundColorTypeComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementStatusBarForegroundColorTypeComboBox", localization["Layout.Properties.ColorType.EffectColor"]);
	ComboBoxAddMenuItem(windowName .. "ElementStatusBarForegroundColorTypeComboBox", localization["Layout.Properties.ColorType.EffectType"]);
	ComboBoxAddMenuItem(windowName .. "ElementStatusBarForegroundColorTypeComboBox", localization["Layout.Properties.ColorType.Custom"]);
	LabelSetText(windowName .. "ElementStatusBarForegroundTextureLabel", localization["Strings.Texture"]);
	LabelSetText(windowName .. "ElementStatusBarForegroundStretchCheckboxLabel", localization["Layout.Properties.StatusBar.Texture.Stretch"]);
	
	LabelSetText(windowName .. "ElementStatusBarOrientationOrientationLabel", localization["Layout.Properties.StatusBarOrientation"]);
	ComboBoxClearMenuItems(windowName .. "ElementStatusBarOrientationOrientationComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementStatusBarOrientationOrientationComboBox", localization["Layout.Properties.StatusBarOrientation.Horizontal"]);
	ComboBoxAddMenuItem(windowName .. "ElementStatusBarOrientationOrientationComboBox", localization["Layout.Properties.StatusBarOrientation.Vertical"]);
	LabelSetText(windowName .. "ElementStatusBarOrientationReverseCheckboxLabel", localization["Layout.Properties.StatusBarOrientation.Reverse"]);
	
	LabelSetText(windowName .. "ElementFontColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementFontAlignmentLabel", localization["Strings.Align"]);
	ComboBoxClearMenuItems(windowName .. "ElementFontAlignmentComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.Bottom"]);
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.BottomLeft"]);
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.BottomRight"]);
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.Center"]);
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.Left"]);
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.LeftCenter"]);
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.Right"]);
	ComboBoxAddMenuItem(windowName .. "ElementFontAlignmentComboBox", localization["Strings.Align.RightCenter"]);
	LabelSetText(windowName .. "ElementFontFontLabel", localization["Strings.Font"]);
	
	LabelSetText(windowName .. "ElementIconBorderColorLabel", localization["Strings.Color"]);
	LabelSetText(windowName .. "ElementIconBorderAlphaLabel", localization["Strings.Alpha"]);
	LabelSetText(windowName .. "ElementIconBorderColorTypeLabel", localization["Layout.Properties.ColorType"]);
	ComboBoxClearMenuItems(windowName .. "ElementIconBorderColorTypeComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementIconBorderColorTypeComboBox", localization["Layout.Properties.ColorType.EffectColor"]);
	ComboBoxAddMenuItem(windowName .. "ElementIconBorderColorTypeComboBox", localization["Layout.Properties.ColorType.EffectType"]);
	ComboBoxAddMenuItem(windowName .. "ElementIconBorderColorTypeComboBox", localization["Layout.Properties.ColorType.Custom"]);
	
	LabelSetText(windowName .. "ElementDurationFormatFormatLabel", localization["Layout.Properties.DurationFormat.Format"]);
	ComboBoxClearMenuItems(windowName .. "ElementDurationFormatFormatComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementDurationFormatFormatComboBox", L"0.0");
	ComboBoxAddMenuItem(windowName .. "ElementDurationFormatFormatComboBox", L"0s");
	ComboBoxAddMenuItem(windowName .. "ElementDurationFormatFormatComboBox", L"0.#s");
	ComboBoxAddMenuItem(windowName .. "ElementDurationFormatFormatComboBox", L"0.#");
		
end

function BuffHead.Setup.Layout.Properties.Show()
	if (WindowGetShowing(windowName)) then return end
	
	local interfaceScale = InterfaceCore.GetScale();
	local x, y = WindowGetScreenPosition(BuffHead.Setup.Layout.WindowName);
	local width, height = WindowGetDimensions(BuffHead.Setup.Layout.WindowName);
	
	WindowClearAnchors(BuffHead.Setup.Layout.Properties.WindowName);
	--WindowAddAnchor(BuffHead.Setup.Layout.Properties.WindowName, "topleft", "Root", "topleft", x / interfaceScale + width + 25, y / interfaceScale + 25);
	WindowAddAnchor(BuffHead.Setup.Layout.Properties.WindowName, "topleft", "RootFrame", "topleft", x / interfaceScale + width + 25, y / interfaceScale + 25);
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.Layout.Properties.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.Layout.Properties.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.Layout.Properties.OnHidden()
	activeLayoutFrame = nil;
	BuffHead.Setup.SelectTexture.Hide();
	BuffHead.Setup.SelectColor.Hide();
end

function BuffHead.Setup.Layout.Properties.OnCloseLUp()
	BuffHead.Setup.Layout.Properties.Hide();
end

function BuffHead.Setup.Layout.Properties.ShowProperties(propertyId, settings, layoutFrame)
	activeSettings = settings;
	activeLayoutFrame = layoutFrame;
	ShowProperty(propertyId);
	ComboBoxSetSelectedMenuItem(windowName .. "PropertiesComboBox", propertyToIndex[propertyId] or 1);
	this.Show();
end

function BuffHead.Setup.Layout.Properties.GetActiveFrame()
	return activeLayoutFrame;
end

function BuffHead.Setup.Layout.Properties.ReloadSettings()
	for index, element in ipairs(availableElements) do
		LoadElementSettings(element);
	end
end

local function SelectTexture(texture, textureButton, settings)
	SetTextureButton(textureButton, texture.Texture, texture.Name, texture.Dimensions)
		
	settings.Texture = texture.Texture;
	settings.TextureDimensions = texture.Dimensions;
	OnSettingsChanged();
end

local function SelectFont(font, label, settings)
	settings.Font = font.Font;
	LabelSetText(label, towstring(font.Name));
	LabelSetFont(label, font.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
	OnSettingsChanged();
end

local function SelectColor(colorExample, settings, color)
	WindowSetTintColor(colorExample .. "Color", color.R, color.G, color.B);
	settings.R = color.R;
	settings.G = color.G;
	settings.B = color.B;
	OnSettingsChanged();
end

function BuffHead.Setup.Layout.Properties.OnPropertyTitleMouseOver()
	LabelSetTextColor(windowName .. "TitleLabel", 255, 110, 10);
end

function BuffHead.Setup.Layout.Properties.OnPropertyTitleMouseOut()
	LabelSetTextColor(windowName .. "TitleLabel", 255, 255, 255);
end

function BuffHead.Setup.Layout.Properties.OnPropertyTitleLClick()
	WindowSetShowing(windowName .. "PropertiesComboBox", true);
	WindowSetShowing(windowName .. "TitleLabel", false);
end

function BuffHead.Setup.Layout.Properties.OnPropertiesChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "PropertiesComboBox");
	local propertyId = availableProperties[value];
	local layoutFrame = BuffHead.Setup.Layout.GetLayoutFrame(propertyId);
	
	WindowSetShowing(windowName .. "PropertiesComboBox", false);
	WindowSetShowing(windowName .. "TitleLabel", true);
	if (not layoutFrame) then return end
	
	activeSettings = layoutFrame.Settings;
	activeLayoutFrame = layoutFrame;
	ShowProperty(propertyId);
end

function BuffHead.Setup.Layout.Properties.OnElementChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementComboBox");
	if (availableElements[value]) then
		ShowElement(availableElements[value]);
	end
	
	BuffHead.Setup.SelectTexture.Hide();
	BuffHead.Setup.SelectColor.Hide();
end

function BuffHead.Setup.Layout.Properties.OnCoreSizeSizeWidthChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementCoreSizeSizeWidthEditBox"));

	GetSettings().Width = value;
	OnSettingsChanged();
	UpdateLayoutFrame();
end

function BuffHead.Setup.Layout.Properties.OnCoreSizeSizeHeightChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementCoreSizeSizeHeightEditBox"));
	
	GetSettings().Height = value;
	OnSettingsChanged();
	UpdateLayoutFrame();
end

function BuffHead.Setup.Layout.Properties.OnCoreSizeAutoSizeLClick()
	BuffHead.Setup.Layout.AutoSize();
end

function BuffHead.Setup.Layout.Properties.OnSizeSizeWidthChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementSizeSizeWidthEditBox"));

	GetSettings().Width = value;
	OnSettingsChanged();
	UpdateLayoutFrame();
end

function BuffHead.Setup.Layout.Properties.OnSizeSizeHeightChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementSizeSizeHeightEditBox"));
	
	GetSettings().Height = value;
	OnSettingsChanged();
	UpdateLayoutFrame();
end

function BuffHead.Setup.Layout.Properties.OnSizeScaleChanged(value)
	if (lockSlider) then return end	
	
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementSizeScaleEditBox"));
	if (value ~= true) then
		SliderBarSetCurrentPosition(windowName .. "ElementSizeScaleSlider", math.min(value / MAX_SIZE_SCALE_SLIDER, 1));
	end
	
	if (not lockSettings) then	
		GetSettings().Scale = value;
		OnSettingsChanged();
		UpdateLayoutFrame();
	end
end

function BuffHead.Setup.Layout.Properties.OnSlideSizeScale()
	if (lockSettings) then return end

	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "ElementSizeScaleSlider") * MAX_SIZE_SCALE_SLIDER * 100) / 100;

	lockSlider = true;
	TextEditBoxSetText(windowName .. "ElementSizeScaleEditBox", towstring(string.format("%.2f", value)));
	lockSlider = false;

	GetSettings().Scale = value;
	OnSettingsChanged();
	UpdateLayoutFrame();
end

function BuffHead.Setup.Layout.Properties.OnSlideAlphaAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementAlphaAlphaSlider");
	LabelSetText(windowName .. "ElementAlphaAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		GetSettings().Alpha = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnLayerLayerChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementLayerLayerComboBox");
	
	if (not lockSettings) then
		GetSettings().Layer = value;
		OnSettingsChanged();
		BuffHead.Setup.Layout.UpdateLayers();
	end
end

function BuffHead.Setup.Layout.Properties.OnStatusBarEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementStatusBarEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementStatusBarEnable" .. "Button", isChecked);
	
	if (not lockSettings) then
		GetSettings().Enabled = isChecked;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnStatusBarBackgroundColorLUp()
	local colorExample = windowName .. "ElementStatusBarBackgroundColorExample";
	local colorSettings = GetSettings().Background.Color;
	
	BuffHead.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function BuffHead.Setup.Layout.Properties.OnSlideStatusBarBackgroundAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementStatusBarBackgroundAlphaSlider");
	LabelSetText(windowName .. "ElementStatusBarBackgroundAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		GetSettings().Background.Alpha = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnStatusBarForegroundColorLUp()
	local colorExample = windowName .. "ElementStatusBarForegroundColorExample";
	local colorSettings = GetSettings().Foreground.Color;
	
	BuffHead.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function BuffHead.Setup.Layout.Properties.OnSlideStatusBarForegroundAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementStatusBarForegroundAlphaSlider");
	LabelSetText(windowName .. "ElementStatusBarForegroundAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		GetSettings().Foreground.Alpha = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnStatusBarForegroundColorTypeChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementStatusBarForegroundColorTypeComboBox");
	
	if (not lockSettings) then
		GetSettings().Foreground.Type = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnStatusBarForegroundTextureLUp()
	BuffHead.Setup.SelectTexture.Show(windowName, windowName .. "ElementStatusBarForegroundTextureButton", 
		function(texture) SelectTexture(texture, windowName .. "ElementStatusBarForegroundTextureButton", GetSettings().Foreground) end);
end

function BuffHead.Setup.Layout.Properties.OnStatusBarForegroundStretchLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementStatusBarForegroundStretch" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementStatusBarForegroundStretch" .. "Button", isChecked);
	
	if (not lockSettings) then
		GetSettings().Foreground.Stretch = isChecked;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnStatusBarOrientationChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementStatusBarOrientationOrientationComboBox");
	
	if (not lockSettings) then
		GetSettings().Orientation = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnStatusBarOrientationReverseLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementStatusBarOrientationReverse" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementStatusBarOrientationReverse" .. "Button", isChecked);
	
	if (not lockSettings) then
		GetSettings().Reverse = isChecked;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnFontColorLUp()
	local colorExample = windowName .. "ElementFontColorExample";
	local colorSettings = GetSettings().Color;
	
	BuffHead.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function BuffHead.Setup.Layout.Properties.OnFontAlignmentChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementFontAlignmentComboBox");
	
	if (not lockSettings) then
		GetSettings().Alignment = indexToAlignment[value];
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnFontFontLUp()
	BuffHead.Setup.SelectFont.Show(function(font) 
		SelectFont(font, windowName .. "ElementFontFontExampleLabel", GetSettings()) end);
end

function BuffHead.Setup.Layout.Properties.OnDurationFormatChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementDurationFormatFormatComboBox");
	
	if (not lockSettings) then
		GetSettings().Format = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnIconBorderColorLUp()
	local colorExample = windowName .. "ElementIconBorderColorExample";
	local colorSettings = GetSettings().Border.Color;
	
	BuffHead.Setup.SelectColor.Show(windowName, colorExample, function(color) SelectColor(colorExample, colorSettings, color) end, colorSettings);
end

function BuffHead.Setup.Layout.Properties.OnSlideIconBorderAlpha()
	local value = SliderBarGetCurrentPosition(windowName .. "ElementIconBorderAlphaSlider");
	LabelSetText(windowName .. "ElementIconBorderAlphaValue", towstring(math.floor(value * 100) .. "%"));
	
	if (not lockSettings) then
		GetSettings().Border.Alpha = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.Layout.Properties.OnIconBorderColorTypeChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementIconBorderColorTypeComboBox");
	
	if (not lockSettings) then
		GetSettings().Border.Type = value;
		OnSettingsChanged();
	end
end



function BuffHead.Setup.Layout.Properties.OnColorExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverColorExample = windowName;
	WindowSetTintColor(hoverColorExample .. "Border", 255, 110, 10);
end

function BuffHead.Setup.Layout.Properties.OnColorExampleMouseOut()
	if (not hoverColorExample) then return end
	WindowSetTintColor(hoverColorExample .. "Border", 50, 50, 50);
	hoverColorExample = nil;
end

function BuffHead.Setup.Layout.Properties.OnFontExampleMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverFontLabel = windowName;
	LabelSetTextColor(hoverFontLabel, 255, 110, 10);
end

function BuffHead.Setup.Layout.Properties.OnFontExampleMouseOut()
	if (not hoverFontLabel) then return end
	LabelSetTextColor(hoverFontLabel, 255, 255, 255);
	hoverFontLabel = nil;
end

function BuffHead.Setup.Layout.Properties.OnTextureButtonMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	hoverTextureButton = windowName;
	LabelSetTextColor(hoverTextureButton .. "Name", 255, 110, 10);
end

function BuffHead.Setup.Layout.Properties.OnTextureButtonMouseOut()
	if (not hoverTextureButton) then return end
	LabelSetTextColor(hoverTextureButton .. "Name", 255, 255, 255);
	hoverTextureButton = nil;
end

function BuffHead.Setup.Layout.Properties.OnOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementOffsetOffsetXEditBox"));
	
	BuffHead.Setup.Layout.ClearActiveFrames();
	GetSettings().X = value;
	OnSettingsChanged();
	UpdateLayoutFrameOffset();
end

function BuffHead.Setup.Layout.Properties.OnOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementOffsetOffsetYEditBox"));
	
	BuffHead.Setup.Layout.ClearActiveFrames();
	GetSettings().Y = value;
	OnSettingsChanged();
	UpdateLayoutFrameOffset();
end