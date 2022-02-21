BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.General = 
{
	WindowName = "BuffHeadSetupGeneralWindow",
};
local this = BuffHead.Setup.General;

local MAX_THRESHOLD_SLIDER = 90;

local windowName = BuffHead.Setup.General.WindowName;
local localization = BuffHead.Localization.GetMapping();

function BuffHead.Setup.General.Initialize()
	LabelSetText(windowName .. "OptionsLabel", localization["Setup.General.Title"]);
	LabelSetText(windowName .. "OptionsMaximumThresholdLabel", localization["Setup.General.MaximumThreshold"]);
	LabelSetText(windowName .. "OptionsMaximumThresholdDescriptionLabel", localization["Setup.General.MaximumThreshold.Info"]);
	
	LabelSetText(windowName .. "CompressLabel", localization["Setup.General.Compression"]);
	LabelSetText(windowName .. "CompressDescriptionLabel", localization["Setup.General.Compression.Info"]);
	ComboBoxClearMenuItems(windowName .. "CompressList");
	ComboBoxAddMenuItem(windowName .. "CompressList", localization["Setup.General.Compression.None"]);
	ComboBoxAddMenuItem(windowName .. "CompressList", localization["Setup.General.Compression.OnlyMine"]);
	ComboBoxAddMenuItem(windowName .. "CompressList", localization["Setup.General.Compression.OnlyOthers"]);
	ComboBoxAddMenuItem(windowName .. "CompressList", localization["Setup.General.Compression.All"]);
	
	LabelSetText(windowName .. "AlwaysIgnoreLabel", localization["Setup.AlwaysIgnore"]);
	LabelSetText(windowName .. "AlwaysIgnoreDescriptionLabel", localization["Setup.AlwaysIgnore.Info"]);
	ButtonSetText(windowName .. "AlwaysIgnoreButton", localization["Setup.AlwaysIgnore.Manage"]);
	
	LabelSetText(windowName .. "AlwaysShowLabel", localization["Setup.AlwaysShow"]);
	LabelSetText(windowName .. "AlwaysShowDescriptionLabel", localization["Setup.AlwaysShow.Info"]);
	ButtonSetText(windowName .. "AlwaysShowButton", localization["Setup.AlwaysShow.Manage"]);
	
	this.LoadSettings();
end

function BuffHead.Setup.General.LoadSettings()
	ComboBoxSetSelectedMenuItem(windowName .. "CompressList", BuffHead.Settings.Indicators.Compression);
	
	SliderBarSetCurrentPosition(windowName .. "OptionsMaximumThresholdSlider", math.min(1, BuffHead.Settings.MaximumThreshold / MAX_THRESHOLD_SLIDER));	
	BuffHead.Setup.General.OnSlideMaximumThreshold();
end

function BuffHead.Setup.General.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.General.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.General.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.General.OnHidden()
	BuffHead.Setup.SetActiveWindow();
	BuffHead.Setup.Filter.Hide();
end

function BuffHead.Setup.General.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.General.OnSlideMaximumThreshold()
	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "OptionsMaximumThresholdSlider") * MAX_THRESHOLD_SLIDER);
	
	local stringValue = "0:";
	local min = math.floor(value / 60);
	local sec = value - (min * 60);
	if (min > 0) then
		stringValue = min .. ":"
	end
	if (sec < 10) then
		stringValue = stringValue .. "0";
	end
	stringValue = stringValue .. sec;
	
	LabelSetText(windowName .. "OptionsMaximumThresholdValue", towstring(stringValue));

	BuffHead.Settings.MaximumThreshold = value;
end

function BuffHead.Setup.General.OnAlwaysIgnoreLClick()
	BuffHead.Setup.Filter.Initialize(BuffHead.Setup.Filter.WindowType.AlwaysIgnore, BuffHead.Settings.AlwaysIgnore);
	BuffHead.Setup.Filter.Show();
		
	WindowClearAnchors(BuffHead.Setup.Filter.WindowName);
	WindowAddAnchor(BuffHead.Setup.Filter.WindowName, "topright", windowName, "topleft", 0, 0);
end

function BuffHead.Setup.General.OnAlwaysShowLClick()
	BuffHead.Setup.Filter.Initialize(BuffHead.Setup.Filter.WindowType.AlwaysShow, BuffHead.Settings.AlwaysShow);
	BuffHead.Setup.Filter.Show();
		
	WindowClearAnchors(BuffHead.Setup.Filter.WindowName);
	WindowAddAnchor(BuffHead.Setup.Filter.WindowName, "topright", windowName, "topleft", 0, 0);
end

function BuffHead.Setup.General.OnCompressionChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "CompressList");
	BuffHead.Settings.Indicators.Compression = value;
end