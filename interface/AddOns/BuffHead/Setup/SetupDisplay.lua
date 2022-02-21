BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.Display = 
{
	WindowName = "BuffHeadSetupDisplayWindow",
};
local this = BuffHead.Setup.Display;

local MIN_SCALE_SLIDER = 0.5;
local MAX_SCALE_SLIDER = 1.5;
local MAX_PADDING_SLIDER = 10;

local windowName = BuffHead.Setup.Display.WindowName;
local localization = BuffHead.Localization.GetMapping();

function BuffHead.Setup.Display.Initialize()
	LabelSetText(windowName .. "DisplayLabel", localization["Setup.Display.Title"]);

	LabelSetText(windowName .. "IndicatorScaleLabel", localization["Setup.Display.IndicatorScale"]);
	
	LabelSetText(windowName .. "IndicatorPaddingLabel", localization["Setup.Padding.Indicator"]);
	LabelSetText(windowName .. "IndicatorPaddingHorizontalDescriptionLabel", localization["Setup.Padding.Horizontal"]);
	LabelSetText(windowName .. "IndicatorPaddingVerticalDescriptionLabel", localization["Setup.Padding.Vertical"]);
	
	LabelSetText(windowName .. "IndicatorLayerLabel", localization["Setup.Display.IndicatorLayer"]);
	ComboBoxClearMenuItems(windowName .. "IndicatorLayer");
	ComboBoxAddMenuItem(windowName .. "IndicatorLayer", localization["Setup.Display.IndicatorLayer.Layer0"]);
	ComboBoxAddMenuItem(windowName .. "IndicatorLayer", localization["Setup.Display.IndicatorLayer.Layer1"]);
	ComboBoxAddMenuItem(windowName .. "IndicatorLayer", localization["Setup.Display.IndicatorLayer.Layer2"]);
	
	LabelSetText(windowName .. "SortLabel", localization["Setup.Display.Sorting"]);
	LabelSetText(windowName .. "EnableSortCheckboxLabel", localization["Setup.Display.Sorting.Enable"]);
	
	LabelSetText(windowName .. "SortByLabel", localization["Setup.Display.Sorting.SortBy"]);
	ComboBoxClearMenuItems(windowName .. "SortByList");
	ComboBoxAddMenuItem(windowName .. "SortByList", localization["Setup.Display.Sorting.SortBy.Duration"]);
	ComboBoxAddMenuItem(windowName .. "SortByList", localization["Setup.Display.Sorting.SortBy.Ability"]);
	
	LabelSetText(windowName .. "SortDirectionLabel", localization["Setup.Display.Sorting.Direction"]);
	ComboBoxClearMenuItems(windowName .. "SortDirectionList");
	ComboBoxAddMenuItem(windowName .. "SortDirectionList", localization["Setup.Display.Sorting.Direction.Ascending"]);
	ComboBoxAddMenuItem(windowName .. "SortDirectionList", localization["Setup.Display.Sorting.Direction.Descending"]);
	
	LabelSetText(windowName .. "OffsetLabel", localization["Setup.Display.Offset"]);
	LabelSetText(windowName .. "OffsetDescriptionLabel", localization["Setup.Display.Offset.Info"]);
	LabelSetText(windowName .. "OffsetXLabel", localization["Setup.Display.Offset.X"]);
	LabelSetText(windowName .. "OffsetYLabel", localization["Setup.Display.Offset.Y"]);

	BuffHead.Setup.Display.LoadSettings();	
end

function BuffHead.Setup.Display.LoadSettings()
	SliderBarSetCurrentPosition(windowName .. "IndicatorScaleSlider", math.max(math.min(1, (BuffHead.Settings.Scale - MIN_SCALE_SLIDER) / (MAX_SCALE_SLIDER - MIN_SCALE_SLIDER)), 0));
	BuffHead.Setup.Display.OnSlideIndicatorScale();
	
	ComboBoxSetSelectedMenuItem(windowName .. "IndicatorLayer", (BuffHead.Settings.Layer or 1) + 1); -- setting starts from 0
	
	SliderBarSetCurrentPosition(windowName .. "IndicatorPaddingHorizontalSlider", math.min(1, BuffHead.Settings.Indicators.Padding.X / MAX_PADDING_SLIDER));
	SliderBarSetCurrentPosition(windowName .. "IndicatorPaddingVerticalSlider", math.min(1, BuffHead.Settings.Indicators.Padding.Y / MAX_PADDING_SLIDER));
	BuffHead.Setup.Display.OnSlidePaddingHorizontal();
	BuffHead.Setup.Display.OnSlidePaddingVertical();
	
	ButtonSetPressedFlag(windowName .. "EnableSort" .. "Button", BuffHead.Settings.Sorting.Enabled);
	ComboBoxSetSelectedMenuItem(windowName .. "SortByList", BuffHead.Settings.Sorting.Type);
	ComboBoxSetSelectedMenuItem(windowName .. "SortDirectionList", BuffHead.Settings.Sorting.Direction);
	TextEditBoxSetText(windowName .. "OffsetXEditBox", towstring(BuffHead.Settings.Offset.X));
	TextEditBoxSetText(windowName .. "OffsetYEditBox", towstring(BuffHead.Settings.Offset.Y));
end

function BuffHead.Setup.Display.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.Display.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.Display.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.Display.OnHidden()
	BuffHead.Setup.SetActiveWindow();
	BuffHead.Setup.Filter.Hide();
end

function BuffHead.Setup.Display.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.Display.OnLayerChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "IndicatorLayer");
	BuffHead.Settings.Layer = value - 1;
	BuffHead.DestroyAllContainers();
	BuffHead.RefreshPlayerBuffs();
end

function BuffHead.Setup.Display.OnEnableSortLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "EnableSort" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnableSort" .. "Button", isChecked);
	BuffHead.Settings.Sorting.Enabled = isChecked;
end

function BuffHead.Setup.Display.OnSortByChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "SortByList");
	BuffHead.Settings.Sorting.Type = value;
end

function BuffHead.Setup.Display.OnSortDirectionChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "SortDirectionList");
	BuffHead.Settings.Sorting.Direction = value;
end

function BuffHead.Setup.Display.OnOffsetXChanged()
	local value = tonumber(TextEditBoxGetText(windowName .. "OffsetXEditBox"));
	BuffHead.Settings.Offset.X = value;
end

function BuffHead.Setup.Display.OnOffsetYChanged()
	local value = tonumber(TextEditBoxGetText(windowName .. "OffsetYEditBox"));
	BuffHead.Settings.Offset.Y = value;
end

function BuffHead.Setup.Display.OnSlideIndicatorScale()
	local value = MIN_SCALE_SLIDER + math.floor(SliderBarGetCurrentPosition(windowName .. "IndicatorScaleSlider") * (MAX_SCALE_SLIDER - MIN_SCALE_SLIDER) * 100) / 100;

	LabelSetText(windowName .. "IndicatorScaleValue", towstring(string.format("%d%%", value * 100)));
	
	BuffHead.Settings.Scale = value;
end

function BuffHead.Setup.Display.OnSlidePaddingHorizontal()
	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "IndicatorPaddingHorizontalSlider") * MAX_PADDING_SLIDER);
	LabelSetText(windowName .. "IndicatorPaddingHorizontalValue", towstring(value));

	if (BuffHead.Settings.Indicators.Padding.X ~= value) then
		BuffHead.Settings.Indicators.Padding.X = value;
	end
end

function BuffHead.Setup.Display.OnSlidePaddingVertical()
	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "IndicatorPaddingVerticalSlider") * MAX_PADDING_SLIDER);
	LabelSetText(windowName .. "IndicatorPaddingVerticalValue", towstring(value));

	if (BuffHead.Settings.Indicators.Padding.Y ~= value) then
		BuffHead.Settings.Indicators.Padding.Y = value;
	end
end