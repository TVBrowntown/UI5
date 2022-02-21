BuffHead.Setup.AdvancedContainersItem.Properties = 
{
	WindowName = "BuffHeadSetupAdvancedContainersItemPropertiesWindow",
};

local this = BuffHead.Setup.AdvancedContainersItem.Properties;

local DEFAULT_HEIGHT = 160;
local MIN_FONT_SCALE_SLIDER = 0.1;
local MAX_FONT_SCALE_SLIDER = 2;
local MIN_ICON_SCALE_SLIDER = 0.1;
local MAX_ICON_SCALE_SLIDER = 2;
local MIN_TIMER_DECIMALS_SLIDER = 0;
local MAX_TIMER_DECIMALS_SLIDER = 3;
local MAX_SIZE_SCALE_SLIDER = 2;
local MIN_SCALE_SLIDER = 0.5;
local MAX_SCALE_SLIDER = 2;

local windowDimensions = {};

local windowName = this.WindowName;
local localization = BuffHead.Localization.GetMapping();

local LayoutFrame = BuffHead.Setup.AdvancedContainersItem.Frames;

local elements =
{
	Container = --enable, rows, columns
	{
		Name = localization["Setup.AdvancedContainersItem.Properties.Container"],
		Window = "ElementContainer",
	},
	Layer = --layer
	{
		Name = localization["Strings.Layer"],
		Window = "ElementLayer",
	},
	Position = -- fixed or attached, offset
	{
		Name = localization["Setup.AdvancedContainersItem.Properties.Position"],
		Window = "ElementPosition",
	},
	Effects = -- buffs, debuffs
	{
		Name = localization["Setup.AdvancedContainersItem.Properties.Effects"],
		Window = "ElementEffects",
	},
	Padding = -- padding
	{
		Name = localization["Strings.Padding"],
		Window = "ElementPadding",
	},
	Offset = -- offset
	{
		Name = localization["Strings.Offset"],
		Window = "ElementOffset",
	},
	Layout = --layout
	{
		Name = localization["Setup.AdvancedContainersItem.IndicatorLayout"],
		Window = "ElementLayout",
	},
	Scale = --scale
	{
		Name = localization["Strings.Scale"],
		Window = "ElementScale",
	},
	Growth = --growth direction (indicators)
	{
		Name = localization["Setup.AdvancedContainersItem.Properties.Growth"],
		Window = "ElementGrowth",
	},
	MaximumThreshold = --maximum threshold
	{
		Name = localization["Setup.General.MaximumThreshold"],
		Window = "ElementMaximumThreshold",
	},
	MinimumThreshold = --minimum threshold
	{
		Name = localization["Setup.General.MinimumThreshold"],
		Window = "ElementMinimumThreshold",
	},
	HandleInput = --show tooltips, right-click removable
	{
		Name = localization["Setup.General.HandleInput"],
		Window = "ElementHandleInput",
	},
};

local propertyElements =
{
	[LayoutFrame.Container] = { elements.Effects, elements.HandleInput, elements.Layout, elements.Layer, 
		elements.MaximumThreshold, elements.MinimumThreshold, elements.Offset, elements.Padding, elements.Scale },
	[LayoutFrame.AlwaysShow] = { elements.Container, elements.Growth, elements.Position },
	[LayoutFrame.Buffs] = { elements.Container, elements.Growth, elements.Position },
	[LayoutFrame.Debuffs] = { elements.Container, elements.Growth, elements.Position },
};

local availableProperties = { LayoutFrame.Container, LayoutFrame.AlwaysShow, LayoutFrame.Buffs, LayoutFrame.Debuffs };
local propertyToIndex = {};

local availableElements = {};

local maximumThresholdMultipler = { 1, 60, 3600 };

local lockSettings = false;
local activeElement = nil;
local activeProperty = nil;
local activeSettings = nil;
local indexToAnchor = nil;
local layoutsIndexToSettingsIndex = nil;

local function GetSettings()
	return activeSettings or {};
end

local function LoadContainerSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementContainer";

	local rows, columns = settings.Size.Rows, settings.Size.Columns;

	TextEditBoxSetText(windowName .. "SizeRowsEditBox", towstring(rows or 0));
	TextEditBoxSetText(windowName .. "SizeColumnsEditBox", towstring(columns or 0));

	lockSettings = false;
end

local function LoadMaximumThresholdSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementMaximumThreshold";

	TextEditBoxSetText(windowName .. "EditBox", towstring(settings.MaximumThreshold or 60));
	ComboBoxSetSelectedMenuItem(windowName .. "ComboBox", 1);

	lockSettings = false;
end

local function LoadMinimumThresholdSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementMinimumThreshold";

	TextEditBoxSetText(windowName .. "EditBox", towstring(settings.MinimumThreshold or 0));
	ComboBoxSetSelectedMenuItem(windowName .. "ComboBox", 1);

	lockSettings = false;
end

local function LoadPaddingSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementPadding";

	local x, y = settings.Containers.Padding.X, settings.Containers.Padding.Y;
	TextEditBoxSetText(windowName .. "ContainerPaddingXEditBox", towstring(x or 0));
	TextEditBoxSetText(windowName .. "ContainerPaddingYEditBox", towstring(y or 0));

	x, y = settings.Indicators.Padding.X, settings.Indicators.Padding.Y;
	TextEditBoxSetText(windowName .. "IndicatorPaddingXEditBox", towstring(x or 0));
	TextEditBoxSetText(windowName .. "IndicatorPaddingYEditBox", towstring(y or 0));

	lockSettings = false;
end

local function LoadOffsetSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementOffset";

	local x, y = settings.Offset.X, settings.Offset.Y;

	TextEditBoxSetText(windowName .. "OffsetXEditBox", towstring(x or 0));
	TextEditBoxSetText(windowName .. "OffsetYEditBox", towstring(y or 0));

	lockSettings = false;
end

local function LoadLayerSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementLayer";

	ComboBoxSetSelectedMenuItem(windowName .. "LayerComboBox", (settings.Layer or 0) + 1);

	lockSettings = false;
end

local function LoadScaleSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementScale";
	
	SliderBarSetCurrentPosition(windowName .. "Slider", math.max(math.min(1, (settings.Scale - MIN_SCALE_SLIDER) / (MAX_SCALE_SLIDER - MIN_SCALE_SLIDER)), 0));
	this.OnSlideScale();

	lockSettings = false;
end

local function LoadGrowthSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementGrowth";
	
	ComboBoxSetSelectedMenuItem(windowName .. "HorizontalComboBox", settings.Growth.Horizontal);
	ComboBoxSetSelectedMenuItem(windowName .. "VerticalComboBox", settings.Growth.Vertical);

	lockSettings = false;
end

local function LoadLayoutSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementLayout";

	local selectedIndex = 1;
	layoutsIndexToSettingsIndex = {};
	ComboBoxClearMenuItems(windowName .. "LayoutComboBox");
	ComboBoxAddMenuItem(windowName .. "LayoutComboBox", localization["Setup.Layout.Manager.Layouts.Current"]);
	table.insert(layoutsIndexToSettingsIndex, 0);
	
	for index, layout in ipairs(BuffHead.Settings.Layouts) do
		table.insert(layoutsIndexToSettingsIndex, index);
		ComboBoxAddMenuItem(windowName .. "LayoutComboBox", layout.Name);
		if (settings.Layout and layout.Settings.Id == settings.Layout) then
			selectedIndex = #layoutsIndexToSettingsIndex;
		end
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "LayoutComboBox", selectedIndex);

	lockSettings = false;
end

local function LoadAnchors(settings)
	local windowName = windowName .. "ElementPositionPlacementAnchored";
	local index = 1;
	
	local anchorNames = 
	{
		[BuffHead.Container.Anchor.Anchor] = localization["Setup.Containers.Container.Anchor"],
		[BuffHead.Container.Anchor.AlwaysShow] = localization["Setup.Containers.Container.AlwaysShow"],
		[BuffHead.Container.Anchor.Buffs] = localization["Setup.Containers.Container.Buffs"],
		[BuffHead.Container.Anchor.Debuffs] = localization["Setup.Containers.Container.Debuffs"],
	};
	
	local selectedIndex = 1;
	indexToAnchor = {};
	ComboBoxClearMenuItems(windowName .. "AnchorComboBox");
	for id, value in pairs(BuffHead.Container.Anchor) do
		if ((value == BuffHead.Container.Anchor.AlwaysShow and activeProperty == LayoutFrame.AlwaysShow) or
			(value == BuffHead.Container.Anchor.Buffs and activeProperty == LayoutFrame.Buffs) or
			(value == BuffHead.Container.Anchor.Debuffs and activeProperty == LayoutFrame.Debuffs)) then
		else
			local name = anchorNames[value];
			if (name) then
				indexToAnchor[index] = value;		
				ComboBoxAddMenuItem(windowName .. "AnchorComboBox", name);
				if (settings.Anchor == value) then
					selectedIndex = index;
				end
				index = index + 1;
			end
		end
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "AnchorComboBox", selectedIndex);
end

local function LoadPositionSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementPosition";
	
	local placement = settings.Placement or 1;
	ComboBoxSetSelectedMenuItem(windowName .. "PlacementComboBox", placement);
	
	WindowSetShowing(windowName .. "PlacementAnchored", (placement ~= BuffHead.Container.Placement.Fixed));
	WindowSetShowing(windowName .. "PlacementFixed", (placement == BuffHead.Container.Placement.Fixed));
	
	ComboBoxSetSelectedMenuItem(windowName .. "PlacementAnchoredAnchorComboBox", settings.Anchor or 1);

	TextEditBoxSetText(windowName .. "PlacementFixedOffsetXEditBox", towstring(settings.Offset.X or 0));
	TextEditBoxSetText(windowName .. "PlacementFixedOffsetYEditBox", towstring(settings.Offset.Y or 0));
	
	LoadAnchors(settings);

	lockSettings = false;
end

local function LoadEffectsSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementEffects";
	
	ComboBoxClearMenuItems(windowName .. "BuffsComboBox");
	ComboBoxClearMenuItems(windowName .. "DebuffsComboBox");
	
	if (settings.Type == BuffHead.TargetType.Hostile) then
		ComboBoxAddMenuItem(windowName .. "BuffsComboBox", localization["Setup.Trackers.Hostile.Buffs.None"]);
		ComboBoxAddMenuItem(windowName .. "BuffsComboBox", localization["Setup.Trackers.Hostile.Buffs.RemovableByMe"]);
		ComboBoxAddMenuItem(windowName .. "BuffsComboBox", localization["Setup.Trackers.Hostile.Buffs.All"]);
		
		ComboBoxAddMenuItem(windowName .. "DebuffsComboBox", localization["Setup.Trackers.Hostile.Debuffs.None"]);
		ComboBoxAddMenuItem(windowName .. "DebuffsComboBox", localization["Setup.Trackers.Hostile.Debuffs.CastByMe"]);
		ComboBoxAddMenuItem(windowName .. "DebuffsComboBox", localization["Setup.Trackers.Hostile.Debuffs.All"]);
	else
		ComboBoxAddMenuItem(windowName .. "BuffsComboBox", localization["Setup.Trackers.Friendly.Buffs.None"]);
		ComboBoxAddMenuItem(windowName .. "BuffsComboBox", localization["Setup.Trackers.Friendly.Buffs.CastByMe"]);
		ComboBoxAddMenuItem(windowName .. "BuffsComboBox", localization["Setup.Trackers.Friendly.Buffs.All"]);
		
		ComboBoxAddMenuItem(windowName .. "DebuffsComboBox", localization["Setup.Trackers.Friendly.Debuffs.None"]);
		ComboBoxAddMenuItem(windowName .. "DebuffsComboBox", localization["Setup.Trackers.Friendly.Debuffs.CurableByMe"]);
		ComboBoxAddMenuItem(windowName .. "DebuffsComboBox", localization["Setup.Trackers.Friendly.Debuffs.All"]);
	end
	
	ButtonSetPressedFlag(windowName .. "Permanent" .. "Button", (settings.Permanent == true));
	ButtonSetPressedFlag(windowName .. "AlwaysShowEnable" .. "Button", (settings.AlwaysShowEnabled == true));
	
	ComboBoxSetSelectedMenuItem(windowName .. "BuffsComboBox", settings.Buffs or 1);
	ComboBoxSetSelectedMenuItem(windowName .. "DebuffsComboBox", settings.Debuffs or 1);

	lockSettings = false;
end

local function LoadHandleInputSettings(settings)
	lockSettings = true;
	local windowName = windowName .. "ElementHandleInput";
	
	ButtonSetPressedFlag(windowName .. "ShowTooltips" .. "Button", (settings.ShowTooltips == true));
	ButtonSetPressedFlag(windowName .. "EnableRemovable" .. "Button", (settings.HandleRemovable == true));

	lockSettings = false;
end

local function LoadElementSettings(element)
	if (element == elements.Container) then
		LoadContainerSettings(GetSettings());
	elseif (element == elements.Position) then
		LoadPositionSettings(GetSettings());
	elseif (element == elements.Effects) then
		LoadEffectsSettings(GetSettings());
	elseif (element == elements.Layer) then
		LoadLayerSettings(GetSettings());
	elseif (element == elements.Offset) then
		LoadOffsetSettings(GetSettings());
	elseif (element == elements.Padding) then
		LoadPaddingSettings(GetSettings());
	elseif (element == elements.Layout) then
		LoadLayoutSettings(GetSettings());
	elseif (element == elements.Scale) then
		LoadScaleSettings(GetSettings());
	elseif (element == elements.Growth) then
		LoadGrowthSettings(GetSettings());
	elseif (element == elements.MaximumThreshold) then
		LoadMaximumThresholdSettings(GetSettings());
	elseif (element == elements.MinimumThreshold) then
		LoadMinimumThresholdSettings(GetSettings());
	elseif (element == elements.HandleInput) then
		LoadHandleInputSettings(GetSettings());
	end
end

local function OnSettingsChanged()
	BuffHead.Setup.ContainerDemo.OnSettingsChanged();
end

local function UpdateLayout()
	BuffHead.Setup.AdvancedContainersItem.UpdateLayout();
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
	
	BuffHead.Setup.Filter.Hide();
	
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
	if (propertyId == LayoutFrame.AlwaysShow) then
		return localization["Setup.Containers.Container.AlwaysShow"];
	elseif (propertyId == LayoutFrame.Buffs) then
		return localization["Setup.Containers.Container.Buffs"];
	elseif (propertyId == LayoutFrame.Debuffs) then
		return localization["Setup.Containers.Container.Debuffs"];
	elseif (propertyId == LayoutFrame.Container) then
		return localization["Setup.AdvancedContainersItem.Properties.General"];
	end

	return localization["Setup.AdvancedContainersItem.Properties.Title"];	
end

local function ShowProperty(propertyId)
	
	LabelSetText(windowName .. "TitleLabel", GetPropertyTitle(propertyId));

	availableElements = propertyElements[propertyId] or {};
	activeProperty = propertyId;
	
	ComboBoxClearMenuItems(windowName .. "ElementComboBox");
	for index, element in ipairs(availableElements) do
		ComboBoxAddMenuItem(windowName .. "ElementComboBox", element.Name);
		LoadElementSettings(element);
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "ElementComboBox", 1);
	ShowElement(availableElements[1]);

end

function BuffHead.Setup.AdvancedContainersItem.Properties.Initialize()

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
	
	LabelSetText(windowName .. "ElementContainerSizeLabel", localization["Strings.Size"]);
	LabelSetText(windowName .. "ElementContainerSizeColumnsLabel", localization["Strings.Columns"]);
	LabelSetText(windowName .. "ElementContainerSizeRowsLabel", localization["Strings.Rows"]);
	
	LabelSetText(windowName .. "ElementPositionPlacementLabel", localization["Setup.AdvancedContainersItem.Properties.Position.Placement"]);
	ComboBoxClearMenuItems(windowName .. "ElementPositionPlacementComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementPositionPlacementComboBox", localization["Setup.Containers.Placement.After"]);
	ComboBoxAddMenuItem(windowName .. "ElementPositionPlacementComboBox", localization["Setup.Containers.Placement.Below"]);
	ComboBoxAddMenuItem(windowName .. "ElementPositionPlacementComboBox", localization["Setup.Containers.Placement.Fixed"]);
	LabelSetText(windowName .. "ElementPositionPlacementAnchoredLabel", localization["Setup.AdvancedContainersItem.Properties.Position.Anchor"]);
	LabelSetText(windowName .. "ElementPositionPlacementFixedOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowName .. "ElementPositionPlacementFixedOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementPositionPlacementFixedOffsetYLabel", localization["Strings.Offset.Y"]);
	
	LabelSetText(windowName .. "ElementEffectsPermanentCheckboxLabel", localization["Setup.AdvancedContainersItem.Properties.Effects.Permanent"]);
	LabelSetText(windowName .. "ElementEffectsAlwaysShowEnableCheckboxLabel", localization["Setup.AdvancedContainersItem.Properties.Effects.AlwaysShow"]);
	LabelSetText(windowName .. "ElementEffectsBuffsLabel", localization["Setup.AdvancedContainersItem.Properties.Effects.Buffs"]);
	LabelSetText(windowName .. "ElementEffectsDebuffsLabel", localization["Setup.AdvancedContainersItem.Properties.Effects.Debuffs"]);
	
	LabelSetText(windowName .. "ElementEffectsAlwaysIgnoreLabel", localization["Setup.AlwaysIgnore"]);
	LabelSetText(windowName .. "ElementEffectsAlwaysIgnoreDescriptionLabel", localization["Setup.AlwaysIgnore.Info"]);
	ButtonSetText(windowName .. "ElementEffectsAlwaysIgnoreButton", localization["Setup.AlwaysIgnore.Manage"]);
	
	LabelSetText(windowName .. "ElementEffectsAlwaysShowLabel", localization["Setup.AlwaysShow"]);
	LabelSetText(windowName .. "ElementEffectsAlwaysShowDescriptionLabel", localization["Setup.AlwaysShow.Info"]);
	ButtonSetText(windowName .. "ElementEffectsAlwaysShowButton", localization["Setup.AlwaysShow.Manage"]);
	
	LabelSetText(windowName .. "ElementPaddingContainerPaddingLabel", localization["Setup.AdvancedContainersItem.Properties.Padding.Containers"]);
	LabelSetText(windowName .. "ElementPaddingContainerPaddingXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementPaddingContainerPaddingYLabel", localization["Strings.Offset.Y"]);
	LabelSetText(windowName .. "ElementPaddingIndicatorPaddingLabel", localization["Setup.AdvancedContainersItem.Properties.Padding.Indicators"]);
	LabelSetText(windowName .. "ElementPaddingIndicatorPaddingXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementPaddingIndicatorPaddingYLabel", localization["Strings.Offset.Y"]);
	
	LabelSetText(windowName .. "ElementLayerLabel", localization["Setup.AdvancedContainersItem.Properties.Layer"]);
	ComboBoxClearMenuItems(windowName .. "ElementLayerLayerComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementLayerLayerComboBox", localization["Setup.AdvancedContainersItem.Properties.Layer.Layer0"]);
	ComboBoxAddMenuItem(windowName .. "ElementLayerLayerComboBox", localization["Setup.AdvancedContainersItem.Properties.Layer.Layer1"]);
	ComboBoxAddMenuItem(windowName .. "ElementLayerLayerComboBox", localization["Setup.AdvancedContainersItem.Properties.Layer.Layer2"]);
	
	LabelSetText(windowName .. "ElementOffsetOffsetLabel", localization["Strings.Offset"]);
	LabelSetText(windowName .. "ElementOffsetOffsetXLabel", localization["Strings.Offset.X"]);
	LabelSetText(windowName .. "ElementOffsetOffsetYLabel", localization["Strings.Offset.Y"]);
	
	LabelSetText(windowName .. "ElementScaleLabel", localization["Strings.Scale"]);
	
	LabelSetText(windowName .. "ElementLayoutLabel", localization["Setup.AdvancedContainersItem.IndicatorLayout"]);
	
	LabelSetText(windowName .. "ElementGrowthHorizontalLabel", localization["Setup.AdvancedContainersItem.Properties.Growth.Horizontal"]);
	ComboBoxClearMenuItems(windowName .. "ElementGrowthHorizontalComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementGrowthHorizontalComboBox", localization["Setup.AdvancedContainersItem.Properties.Growth.Horizontal.Left"]);
	ComboBoxAddMenuItem(windowName .. "ElementGrowthHorizontalComboBox", localization["Setup.AdvancedContainersItem.Properties.Growth.Horizontal.Right"]);
	LabelSetText(windowName .. "ElementGrowthVerticalLabel", localization["Setup.AdvancedContainersItem.Properties.Growth.Vertical"]);
	ComboBoxClearMenuItems(windowName .. "ElementGrowthVerticalComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementGrowthVerticalComboBox", localization["Setup.AdvancedContainersItem.Properties.Growth.Vertical.Up"]);
	ComboBoxAddMenuItem(windowName .. "ElementGrowthVerticalComboBox", localization["Setup.AdvancedContainersItem.Properties.Growth.Vertical.Down"]);
	
	LabelSetText(windowName .. "ElementMaximumThresholdLabel", localization["Setup.General.MaximumThreshold.Info"]);
	ComboBoxClearMenuItems(windowName .. "ElementMaximumThresholdComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementMaximumThresholdComboBox", localization["Strings.Seconds"]);
	ComboBoxAddMenuItem(windowName .. "ElementMaximumThresholdComboBox", localization["Strings.Minutes"]);
	ComboBoxAddMenuItem(windowName .. "ElementMaximumThresholdComboBox", localization["Strings.Hours"]);
	
	LabelSetText(windowName .. "ElementMinimumThresholdLabel", localization["Setup.General.MinimumThreshold.Info"]);
	ComboBoxClearMenuItems(windowName .. "ElementMinimumThresholdComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementMinimumThresholdComboBox", localization["Strings.Seconds"]);
	ComboBoxAddMenuItem(windowName .. "ElementMinimumThresholdComboBox", localization["Strings.Minutes"]);
	ComboBoxAddMenuItem(windowName .. "ElementMinimumThresholdComboBox", localization["Strings.Hours"]);
	
	LabelSetText(windowName .. "ElementHandleInputShowTooltipsCheckboxLabel", localization["Setup.General.HandleInput.ShowTooltips"]);
	LabelSetText(windowName .. "ElementHandleInputEnableRemovableCheckboxLabel", localization["Setup.General.HandleInput.HandleRemovable"]);
	
end

function BuffHead.Setup.AdvancedContainersItem.Properties.Show()
	if (WindowGetShowing(windowName)) then return end
	
	local interfaceScale = InterfaceCore.GetScale();
	local x, y = WindowGetScreenPosition(BuffHead.Setup.AdvancedContainersItem.WindowName);
	local width, height = WindowGetDimensions(BuffHead.Setup.AdvancedContainersItem.WindowName);
	
	WindowClearAnchors(BuffHead.Setup.AdvancedContainersItem.Properties.WindowName);
	--WindowAddAnchor(BuffHead.Setup.AdvancedContainersItem.Properties.WindowName, "topleft", "Root", "topleft", x / interfaceScale + width + 25, y / interfaceScale + 25);
	WindowAddAnchor(BuffHead.Setup.AdvancedContainersItem.Properties.WindowName, "topleft", "RootFrame", "topleft", x / interfaceScale + width + 25, y / interfaceScale + 25);
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.AdvancedContainersItem.Properties.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnHidden()
	BuffHead.Setup.Filter.Hide();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnCloseLUp()
	BuffHead.Setup.AdvancedContainersItem.Properties.Hide();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.ShowProperties(propertyId, settings)
	activeSettings = settings;
	ShowProperty(propertyId);
	ComboBoxSetSelectedMenuItem(windowName .. "PropertiesComboBox", propertyToIndex[propertyId] or 1);
	this.Show();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.GetActiveProperty()
	return activeProperty;
end

function BuffHead.Setup.AdvancedContainersItem.Properties.ReloadSettings()
	for index, element in ipairs(availableElements) do
		LoadElementSettings(element);
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPropertyTitleMouseOver()
	LabelSetTextColor(windowName .. "TitleLabel", 255, 110, 10);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPropertyTitleMouseOut()
	LabelSetTextColor(windowName .. "TitleLabel", 255, 255, 255);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPropertyTitleLClick()
	WindowSetShowing(windowName .. "PropertiesComboBox", true);
	WindowSetShowing(windowName .. "TitleLabel", false);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPropertiesChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "PropertiesComboBox");
	local propertyId = availableProperties[value];
	local settings = BuffHead.Setup.AdvancedContainersItem.GetSettings(propertyId);
	
	WindowSetShowing(windowName .. "PropertiesComboBox", false);
	WindowSetShowing(windowName .. "TitleLabel", true);
	if (not settings) then return end
	
	activeSettings = settings;
	ShowProperty(propertyId);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnElementChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementComboBox");
	if (availableElements[value]) then
		ShowElement(availableElements[value]);
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnContainerSizeColumnsChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementContainerSizeColumnsEditBox"));

	GetSettings().Size.Columns = value;
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnContainerSizeRowsChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementContainerSizeRowsEditBox"));
	
	GetSettings().Size.Rows = value;
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPositionPlacementChanged()
	if (lockSettings) then return end
	local placement = ComboBoxGetSelectedMenuItem(windowName .. "ElementPositionPlacementComboBox");
	
	WindowSetShowing(windowName .. "ElementPositionPlacementAnchored", (placement ~= BuffHead.Container.Placement.Fixed));
	WindowSetShowing(windowName .. "ElementPositionPlacementFixed", (placement == BuffHead.Container.Placement.Fixed));
	
	GetSettings().Placement = placement;
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPositionAnchorChanged()
	if (lockSettings) then return end
	local value = indexToAnchor[ComboBoxGetSelectedMenuItem(windowName .. "ElementPositionPlacementAnchoredAnchorComboBox")];
	
	GetSettings().Anchor = value;
	BuffHead.Setup.AdvancedContainersItem.UpdateAnchor(value);
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPlacementFixedOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementPositionPlacementFixedOffsetXEditBox"));
	
	GetSettings().Offset.X = value;
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnPlacementFixedOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementPositionPlacementFixedOffsetYEditBox"));
	
	GetSettings().Offset.Y = value;
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnContainerPaddingXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementPaddingContainerPaddingXEditBox"));
	
	GetSettings().Containers.Padding.X = value;
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnContainerPaddingYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementPaddingContainerPaddingYEditBox"));
	
	GetSettings().Containers.Padding.Y = value;
	OnSettingsChanged();
	UpdateLayout();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnIndicatorPaddingXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementPaddingIndicatorPaddingXEditBox"));
	
	GetSettings().Indicators.Padding.X = value;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnIndicatorPaddingYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementPaddingIndicatorPaddingYEditBox"));
	
	GetSettings().Indicators.Padding.Y = value;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnLayerChanged()
	if (lockSettings) then return end
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementLayerLayerComboBox");
	
	GetSettings().Layer = value - 1; -- 0 based
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnEffectsAlwaysShowEnableLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementEffectsAlwaysShowEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementEffectsAlwaysShowEnable" .. "Button", isChecked);
	
	if (not lockSettings) then
		GetSettings().AlwaysShowEnabled = isChecked;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnEffectsPermanentLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementEffectsPermanent" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementEffectsPermanent" .. "Button", isChecked);
	
	if (not lockSettings) then
		GetSettings().Permanent = isChecked;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnEffectsBuffsChanged()
	if (lockSettings) then return end
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementEffectsBuffsComboBox");
	
	GetSettings().Buffs = value;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnEffectsDebuffsChanged()
	if (lockSettings) then return end
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementEffectsDebuffsComboBox");
	
	GetSettings().Debuffs = value;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnEffectsAlwaysShowLUp()
	BuffHead.Setup.Filter.Initialize(BuffHead.Setup.Filter.WindowType.AlwaysShow, GetSettings().AlwaysShow);
	BuffHead.Setup.Filter.Show();
		
	WindowClearAnchors(BuffHead.Setup.Filter.WindowName);
	WindowAddAnchor(BuffHead.Setup.Filter.WindowName, "topright", windowName, "topleft", 0, 0);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnEffectsAlwaysIgnoreLUp()
	BuffHead.Setup.Filter.Initialize(BuffHead.Setup.Filter.WindowType.AlwaysIgnore, GetSettings().AlwaysIgnore);
	BuffHead.Setup.Filter.Show();
		
	WindowClearAnchors(BuffHead.Setup.Filter.WindowName);
	WindowAddAnchor(BuffHead.Setup.Filter.WindowName, "topright", windowName, "topleft", 0, 0);
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnOffsetXChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementOffsetOffsetXEditBox"));
	
	GetSettings().Offset.X = value;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnOffsetYChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementOffsetOffsetYEditBox"));
	
	GetSettings().Offset.Y = value;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnLayoutChanged()
	if (lockSettings) then return end
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementLayoutLayoutComboBox");
	local layout = layoutsIndexToSettingsIndex[value];
	
	if (value == 0) then
		layout = nil;
	else
		if (BuffHead.Settings.Layouts[layout]) then
			layout = BuffHead.Settings.Layouts[layout].Settings.Id;
		else
			layout = nil;
		end
	end
	
	GetSettings().Layout = layout;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnSlideScale()
	local value = MIN_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "ElementScaleSlider") * (MAX_SCALE_SLIDER - MIN_SCALE_SLIDER) * 100) / 100;

	LabelSetText(windowName .. "ElementScaleValue", towstring(string.format("%d%%", value * 100)));
	
	if (not lockSettings) then
		GetSettings().Scale = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnGrowthHorizontalChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementGrowthHorizontalComboBox");
	
	if (not lockSettings) then
		GetSettings().Growth.Horizontal = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnGrowthVerticalChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "ElementGrowthVerticalComboBox");
	
	if (not lockSettings) then
		GetSettings().Growth.Vertical = value;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnMaximumThresholdChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementMaximumThresholdEditBox"));
	local multiplier = maximumThresholdMultipler[ComboBoxGetSelectedMenuItem(windowName .. "ElementMaximumThresholdComboBox")] or 1;
	
	GetSettings().MaximumThreshold = value * multiplier;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnMinimumThresholdChanged()
	if (lockSettings) then return end
	local value = tonumber(TextEditBoxGetText(windowName .. "ElementMinimumThresholdEditBox"));
	local multiplier = maximumThresholdMultipler[ComboBoxGetSelectedMenuItem(windowName .. "ElementMinimumThresholdComboBox")] or 1;
	
	GetSettings().MinimumThreshold = value * multiplier;
	OnSettingsChanged();
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnHandleInputShowTooltipsLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementHandleInputShowTooltips" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementHandleInputShowTooltips" .. "Button", isChecked);
	
	if (not lockSettings) then
		GetSettings().ShowTooltips = isChecked;
		OnSettingsChanged();
	end
end

function BuffHead.Setup.AdvancedContainersItem.Properties.OnHandleInputEnableRemovableLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "ElementHandleInputEnableRemovable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "ElementHandleInputEnableRemovable" .. "Button", isChecked);
	
	if (not lockSettings) then
		GetSettings().HandleRemovable = isChecked;
		OnSettingsChanged();
	end
end