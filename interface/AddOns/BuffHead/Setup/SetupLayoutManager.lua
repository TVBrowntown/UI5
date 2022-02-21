BuffHead.Setup.Layout.Manager = 
{
	WindowName = "BuffHeadSetupLayoutManagerWindow",
};

local this = BuffHead.Setup.Layout.Manager;

local EXPORT_VERSION = 1;

local windowName = this.WindowName;
local localization = BuffHead.Localization.GetMapping();

local elements = 
{
	Import = 
	{
		Selector = "Import", 
		Window = "ElementImport",
	},
	Export = 
	{
		Selector = "Export",
		Window = "ElementExport",
	},
	Layouts = 
	{
		Selector = "Layouts",
		Window = "ElementLayouts",
	},
};

local activeElement = nil;
local exportIndexToSettingsIndex = nil;
local layoutsIndexToSettingsIndex = nil;
local selectedLayout = nil;
local activeSettings = nil;

local function CopyTable(t)
	local copiedTable = {};
	for k, v in pairs(t) do
		if (type(v) == "table") then
			copiedTable[k] = CopyTable(v);
		else
			copiedTable[k] = v;
		end
	end
	return copiedTable;
end

-- Importing:
local function ImportString(segment)
	local value = "";
	value, segment = segment:match("s(.-)_%$(.*)");
	return segment, value;
end

local function ImportNumber(segment)
	local number = 0;
	number, segment = segment:match("#(%-?[%d%.]+)(.*)");
	return segment, tonumber(number);
end

local function ImportBoolean(segment)
	local bool = false;
	bool, segment = segment:match("%?(%a)(.*)");
	return segment, (bool == "t");
end

local function ImportColor(segment)
	local color = { R = 0, G = 0, B = 0 };
	local r, g, b;
	r, g, b, segment = segment:match("c(%x%x)(%x%x)(%x%x)(.*)");
	color.R = tonumber("0x" .. r);
	color.G = tonumber("0x" .. g);
	color.B = tonumber("0x" .. b);
	return segment, color;
end

local function ImportCoreSettings(segment, settings)
	segment, settings.X = ImportNumber(segment);
	segment, settings.Y = ImportNumber(segment);
	segment, settings.Width = ImportNumber(segment);
	segment, settings.Height = ImportNumber(segment);
	segment, settings.Scale = ImportNumber(segment);
	segment, settings.Alpha = ImportNumber(segment);
	segment, settings.Layer = ImportNumber(segment);
	return segment;
end

local function ImportSegment(value)
	local SETTING_SEPERATOR = "/";
	return value:match("(.-)" .. SETTING_SEPERATOR .. "(.*)");
end

local function ImportLayout_v1(value)
	local settings = {};
	local TABLE_SEPERATOR = "@";
	
	-- general
	local segment, value = ImportSegment(value);
	segment, settings.Width = ImportNumber(segment);
	segment, settings.Height = ImportNumber(segment);
	
	--icon
	settings.Icon = { Border = {} };
	segment, value = ImportSegment(value);
	segment = ImportCoreSettings(segment, settings.Icon);
	segment = segment:match(TABLE_SEPERATOR .. "(.*)");
	segment, settings.Icon.Border.Enabled = ImportBoolean(segment);
	segment, settings.Icon.Border.Alpha = ImportNumber(segment);
	segment, settings.Icon.Border.Type = ImportNumber(segment);
	segment, settings.Icon.Border.Color = ImportColor(segment);
		
	--status bar
	settings.StatusBar = { Background = { TextureDimensions = {} }, Foreground = { TextureDimensions = {} } };
	segment, value = ImportSegment(value);
	segment, settings.StatusBar.X = ImportNumber(segment);
	segment, settings.StatusBar.Y = ImportNumber(segment);
	segment, settings.StatusBar.Width = ImportNumber(segment);
	segment, settings.StatusBar.Height = ImportNumber(segment);
	segment, settings.StatusBar.Scale = ImportNumber(segment);
	segment, settings.StatusBar.Layer = ImportNumber(segment);
	segment, settings.StatusBar.Enabled = ImportBoolean(segment);
	segment, settings.StatusBar.Orientation = ImportNumber(segment);
	segment, settings.StatusBar.Reverse = ImportBoolean(segment);
	segment = segment:match(TABLE_SEPERATOR .. "(.*)");
	segment, settings.StatusBar.Background.Color = ImportColor(segment);
	segment, settings.StatusBar.Background.Alpha = ImportNumber(segment);
	segment, settings.StatusBar.Background.Texture = ImportString(segment);
	segment, settings.StatusBar.Background.TextureDimensions.Width = ImportNumber(segment);
	segment, settings.StatusBar.Background.TextureDimensions.Height = ImportNumber(segment);
	segment, settings.StatusBar.Background.Stretch = ImportBoolean(segment);
	segment = segment:match(TABLE_SEPERATOR .. "(.*)");
	segment, settings.StatusBar.Foreground.Color = ImportColor(segment);
	segment, settings.StatusBar.Foreground.Alpha = ImportNumber(segment);
	segment, settings.StatusBar.Foreground.Type = ImportNumber(segment);
	segment, settings.StatusBar.Foreground.Texture = ImportString(segment);
	segment, settings.StatusBar.Foreground.TextureDimensions.Width = ImportNumber(segment);
	segment, settings.StatusBar.Foreground.TextureDimensions.Height = ImportNumber(segment);
	segment, settings.StatusBar.Foreground.Stretch = ImportBoolean(segment);
		
	--duration
	settings.Duration = {};
	segment, value = ImportSegment(value);
	segment = ImportCoreSettings(segment, settings.Duration);
	segment, settings.Duration.Color = ImportColor(segment);
	segment, settings.Duration.Font = ImportString(segment);
	segment, settings.Duration.Format = ImportNumber(segment);
	segment, settings.Duration.Alignment = ImportString(segment);
	
	--stack count
	settings.StackCount = {};
	segment, value = ImportSegment(value);
	segment = ImportCoreSettings(segment, settings.StackCount);
	segment, settings.StackCount.Color = ImportColor(segment);
	segment, settings.StackCount.Font = ImportString(segment);
	segment, settings.StackCount.Alignment = ImportString(segment);
		
	--name
	settings.Name = {};
	segment, value = ImportSegment(value);
	segment = ImportCoreSettings(segment, settings.Name);
	segment, settings.Name.Color = ImportColor(segment);
	segment, settings.Name.Font = ImportString(segment);
	segment, settings.Name.Alignment = ImportString(segment);
	
	return settings;
end

local function ImportLayout(value)
	local version, segment = value:match("v(%d+)%+(.*)");
	
	if (version == "1") then
		return ImportLayout_v1(segment);
	end	
end
-- Importing End

-- Exporting:
local function ExportString(string)
	return "s" .. tostring(string) .. "_$";
end

local function ExportNumber(number)
	return "#" .. number;
end

local function ExportBoolean(bool)
	return "?" .. (bool and "t" or "f");
end

local function toHex(number)
	local hex = string.format("%x", number);
	if (hex:len() == 1) then
		hex = "0" .. hex;
	end
	return hex;
end

local function ExportColor(color)
	return "c" .. toHex(color.R) .. toHex(color.G) .. toHex(color.B);
end

local function ExportCoreSettings(settings)
	return ExportNumber(settings.X) .. ExportNumber(settings.Y) .. ExportNumber(settings.Width) .. ExportNumber(settings.Height)
		 .. ExportNumber(settings.Scale) .. ExportNumber(settings.Alpha) .. ExportNumber(settings.Layer);
end

local function ExportLayout(settings)
	local export = "v" .. EXPORT_VERSION .. "+";
	local SETTING_SEPERATOR = "/";
	local TABLE_SEPERATOR = "@";
	
	-- general
	export = export .. ExportNumber(settings.Width) .. ExportNumber(settings.Height) .. SETTING_SEPERATOR;
	
	--icon
	export = export .. ExportCoreSettings(settings.Icon) .. TABLE_SEPERATOR .. ExportBoolean(settings.Icon.Border.Enabled) 
		.. ExportNumber(settings.Icon.Border.Alpha) .. ExportNumber(settings.Icon.Border.Type) .. ExportColor(settings.Icon.Border.Color) .. SETTING_SEPERATOR;
		
	--status bar
	export = export .. ExportNumber(settings.StatusBar.X) .. ExportNumber(settings.StatusBar.Y) .. ExportNumber(settings.StatusBar.Width) 
		.. ExportNumber(settings.StatusBar.Height) .. ExportNumber(settings.StatusBar.Scale) .. ExportNumber(settings.StatusBar.Layer)
		.. ExportBoolean(settings.StatusBar.Enabled)
		.. ExportNumber(settings.StatusBar.Orientation).. ExportBoolean(settings.StatusBar.Reverse) .. TABLE_SEPERATOR 
		.. ExportColor(settings.StatusBar.Background.Color) .. ExportNumber(settings.StatusBar.Background.Alpha) 
		.. ExportString(settings.StatusBar.Background.Texture) .. ExportNumber(settings.StatusBar.Background.TextureDimensions.Width) 
		.. ExportNumber(settings.StatusBar.Background.TextureDimensions.Height) .. ExportBoolean(settings.StatusBar.Background.Stretch) .. TABLE_SEPERATOR
		.. ExportColor(settings.StatusBar.Foreground.Color) .. ExportNumber(settings.StatusBar.Foreground.Alpha) 
		.. ExportNumber(settings.StatusBar.Foreground.Type) .. ExportString(settings.StatusBar.Foreground.Texture) 
		.. ExportNumber(settings.StatusBar.Foreground.TextureDimensions.Width) 
		.. ExportNumber(settings.StatusBar.Foreground.TextureDimensions.Height) .. ExportBoolean(settings.StatusBar.Foreground.Stretch) .. SETTING_SEPERATOR;
		
	--duration
	export = export .. ExportCoreSettings(settings.Duration) .. ExportColor(settings.Duration.Color) .. ExportString(settings.Duration.Font)
		.. ExportNumber(settings.Duration.Format) .. ExportString(settings.Duration.Alignment) .. SETTING_SEPERATOR;
		
	--stack count
	export = export .. ExportCoreSettings(settings.StackCount) .. ExportColor(settings.StackCount.Color) .. ExportString(settings.StackCount.Font)
		.. ExportString(settings.StackCount.Alignment) .. SETTING_SEPERATOR;
		
	--name
	export = export .. ExportCoreSettings(settings.Name) .. ExportColor(settings.Name.Color) .. ExportString(settings.Name.Font)
		.. ExportString(settings.Name.Alignment) .. SETTING_SEPERATOR;
		
	return export;	
end
-- Exporting End

local function GenerateExport(index)
	if (not exportIndexToSettingsIndex) then return end
	local settings = nil;
	index = exportIndexToSettingsIndex[index];
	if (index == nil or index == 0) then
		settings = BuffHead.Setup.Layout.GetActiveSettings();
	else
		settings = BuffHead.Settings.Layouts[index].Settings;
	end
	local export = nil;
	if (settings) then
		 export = ExportLayout(settings);
	end
	
	local exportedText = "";
	while (export and export:len() > 0) do
		local length = math.min(export:len(), 40);
		local line = export:sub(1, length);
		export = export:sub(length + 1);
		exportedText = exportedText .. line .. "\n";
	end
	
	TextEditBoxSetText(windowName .. "ElementExportEditBox", towstring(exportedText));
end

local function SelectLayoutsLayout(index)
	if (not layoutsIndexToSettingsIndex) then return end
	local settings = nil;
	local isCurrent, isSaved = false, false;
	index = layoutsIndexToSettingsIndex[index];
	if (index == nil or index == 0) then
		settings = BuffHead.Setup.Layout.GetActiveSettings();
		isCurrent = true;
	else
		settings = BuffHead.Settings.Layouts[index].Settings;
		isSaved = true;
	end
	
	WindowSetShowing(windowName .. "ElementLayoutsCurrentLayout", isCurrent);
	WindowSetShowing(windowName .. "ElementLayoutsSavedLayout", isSaved);

	selectedLayout = 
	{
		Settings = settings,
		Index = index,
	};
end

local function ShowImport()
	TextEditBoxSetText(windowName .. "ElementImportEditBox", L"");
end

local function ShowExport()
	exportIndexToSettingsIndex = {};
	ComboBoxClearMenuItems(windowName .. "ElementExportComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementExportComboBox", localization["Setup.Layout.Manager.Layouts.Current"]);
	table.insert(exportIndexToSettingsIndex, 0);
	
	for index, layout in ipairs(BuffHead.Settings.Layouts) do
		table.insert(exportIndexToSettingsIndex, index);
		ComboBoxAddMenuItem(windowName .. "ElementExportComboBox", layout.Name);
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "ElementExportComboBox", 1);
	GenerateExport(1);
end

local function ShowLayouts(selectedLayout)
	local selectedIndex = 1;
	layoutsIndexToSettingsIndex = {};
	ComboBoxClearMenuItems(windowName .. "ElementLayoutsComboBox");
	ComboBoxAddMenuItem(windowName .. "ElementLayoutsComboBox", localization["Setup.Layout.Manager.Layouts.Current"]);
	table.insert(layoutsIndexToSettingsIndex, 0);
	
	for index, layout in ipairs(BuffHead.Settings.Layouts) do
		table.insert(layoutsIndexToSettingsIndex, index);
		ComboBoxAddMenuItem(windowName .. "ElementLayoutsComboBox", layout.Name);
		if (layout == selectedLayout) then
			selectedIndex = #layoutsIndexToSettingsIndex;
		end
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "ElementLayoutsComboBox", selectedIndex);
	SelectLayoutsLayout(selectedIndex);
end

local function ShowElement(element)
	if (element == activeElement) then return end
	if (activeElement) then
		WindowSetShowing(windowName .. activeElement.Window, false);
		ButtonSetPressedFlag(windowName .. activeElement.Selector .. "Button", false);
	end
	
	if (type(element.OnShown) == "function") then
		element.OnShown();
	end
	
	WindowSetShowing(windowName .. element.Window, true);
	ButtonSetPressedFlag(windowName .. element.Selector .. "Button", true);
	activeElement = element;
end

function BuffHead.Setup.Layout.Manager.Initialize()
	elements.Import.OnShown = ShowImport;
	elements.Export.OnShown = ShowExport;
	elements.Layouts.OnShown = ShowLayouts;
	
	for id, element in pairs(elements) do
		WindowSetShowing(windowName .. element.Window, false);
	end
	ShowElement(elements.Import);
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.Layout.Manager.Title"]);
	LabelSetText(windowName .. "ImportCheckboxLabel", localization["Setup.Layout.Manager.Import"]);
	LabelSetText(windowName .. "ExportCheckboxLabel", localization["Setup.Layout.Manager.Export"]);
	LabelSetText(windowName .. "LayoutsCheckboxLabel", localization["Setup.Layout.Manager.Layouts"]);
	
	ButtonSetText(windowName .. "ElementImportButton", localization["Setup.Layout.Manager.Import"]);
	
	LabelSetText(windowName .. "ElementExportInfoLabel", localization["Setup.Layout.Manager.Export.Info"]);
	
	LabelSetText(windowName .. "ElementLayoutsCurrentLayoutSaveLabel", localization["Setup.Layout.Manager.Layouts.Save.Info"]);
	ButtonSetText(windowName .. "ElementLayoutsCurrentLayoutSaveButton", localization["Setup.Layout.Manager.Layouts.Save"]);
	LabelSetText(windowName .. "ElementLayoutsSavedLayoutActivateLabel", localization["Setup.Layout.Manager.Layouts.Activate.Info"]);
	ButtonSetText(windowName .. "ElementLayoutsSavedLayoutActivateButton", localization["Setup.Layout.Manager.Layouts.Activate"]);
	LabelSetText(windowName .. "ElementLayoutsSavedLayoutDeleteLabel", localization["Setup.Layout.Manager.Layouts.Delete.Info"]);
	ButtonSetText(windowName .. "ElementLayoutsSavedLayoutDeleteButton", localization["Setup.Layout.Manager.Layouts.Delete"]);
end

function BuffHead.Setup.Layout.Manager.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.Layout.Manager.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.Layout.Manager.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.Layout.Manager.OnHidden()

end

function BuffHead.Setup.Layout.Manager.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.Layout.Manager.ShowManager(settings)
	TextEditBoxSetText(windowName .. "ManagerEditBox", towstring(ExportLayout(settings)));
	this.Show();
end

function BuffHead.Setup.Layout.Manager.OnImportLUp()
	ShowElement(elements.Import);
end

function BuffHead.Setup.Layout.Manager.OnExportLUp()
	ShowElement(elements.Export);
end

function BuffHead.Setup.Layout.Manager.OnLayoutsLUp()
	ShowElement(elements.Layouts);
end

function BuffHead.Setup.Layout.Manager.OnImportLClick()
	local value = string.gsub(string.gsub(tostring(TextEditBoxGetText(windowName .. "ElementImportEditBox")), "^%s*(.-)%s*$", "%1"), "[\n\r]", "");
	local settings = ImportLayout(value);
	if (not settings) then return end
	
	BuffHead.Setup.Layout.ImportSettings(settings);
	
	TextEditBoxSetText(windowName .. "ElementImportEditBox", L"");
end

function BuffHead.Setup.Layout.Manager.OnExportLayoutChanged()
	local index = ComboBoxGetSelectedMenuItem(windowName .. "ElementExportComboBox");
	GenerateExport(index);
end

local function CompareLayouts(itemA, itemB)
	if (not itemB) then
		return false;
	end
	return WStringsCompare(itemA.Name, itemB.Name) < 0;
end

function BuffHead.Setup.Layout.Manager.OnLayoutsSaveCurrentLayoutLClick()
	local name = TextEditBoxGetText(windowName .. "ElementLayoutsCurrentLayoutSaveEditBox");
	if (name:len() == 0 or not selectedLayout or not selectedLayout.Settings) then return end
	
	local settings = CopyTable(selectedLayout.Settings);
	settings.Id = BuffHead.Setup.Layout.GenerateUniqueId();
	
	local layout = { Name = name, Settings = settings };
	TextEditBoxSetText(windowName .. "ElementLayoutsCurrentLayoutSaveEditBox", L"");
	table.insert(BuffHead.Settings.Layouts, layout);
	table.sort(BuffHead.Settings.Layouts, CompareLayouts);
	
	ShowLayouts(layout);
end

function BuffHead.Setup.Layout.Manager.OnLayoutsActivateLClick()
	if (not selectedLayout or not selectedLayout.Settings) then return end
	local layout = CopyTable(selectedLayout.Settings);
	if (layout.Settings) then
		layout.Settings.Id = nil;
	end
	BuffHead.Setup.Layout.ImportSettings(layout);
end

function BuffHead.Setup.Layout.Manager.OnLayoutsDeleteLClick()
	if (not selectedLayout or not selectedLayout.Settings) then return end
	table.remove(BuffHead.Settings.Layouts, selectedLayout.Index);
	
	ShowLayouts();
end

function BuffHead.Setup.Layout.Manager.OnLayoutsLayoutChanged()
	local index = ComboBoxGetSelectedMenuItem(windowName .. "ElementLayoutsComboBox");
	SelectLayoutsLayout(index);
end