LibGroup = LibGroup or {};
LibGroup.Setup = 
{
	WindowName = "LibGroupSetupWindow",
};

local UPDATE_DELAY = { 0.01, 0.1, 0.5, 1, 2, 5 };
local SEARCH_DELAY = { 1, 3, 5, 10, 30 };

local windowName = LibGroup.Setup.WindowName;
local localization = LibGroup.Localization.GetMapping();

local function GetDelayValue(value, valueList)

	local index = 1;
	
	for k, v in ipairs(valueList) do
		if (value == v) then
			return k;
		elseif (value > v) then
			index = k;
		end
	end

	return index;

end

function LibGroup.Setup.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Title"]);
	
	LabelSetText(windowName .. "GroupUpdateDelayLabel", localization["Setup.GroupUpdate"]);
	LabelSetText(windowName .. "GroupUpdateDelayDescriptionLabel", localization["Setup.GroupUpdate.Info"]);
	
	LabelSetText(windowName .. "GroupDistanceLabel", localization["Setup.GroupDistance"]);
	LabelSetText(windowName .. "EnableGroupDistanceCheckboxLabel", localization["Setup.GroupDistance.Enable"]);
	
	LabelSetText(windowName .. "GroupDistanceCacheUpdateLabel", localization["Setup.GroupDistance.CacheUpdate"]);
	LabelSetText(windowName .. "GroupDistanceCacheUpdateDescriptionLabel", localization["Setup.GroupDistance.CacheUpdate.Info"]);
	
	LabelSetText(windowName .. "GroupDistanceSearchUpdateLabel", localization["Setup.GroupDistance.SearchUpdate"]);
	LabelSetText(windowName .. "GroupDistanceSearchUpdateDescriptionLabel", localization["Setup.GroupDistance.SearchUpdate.Info"]);
	
	LibGroup.Setup.LoadSettings();
	
end

function LibGroup.Setup.LoadSettings()

	SliderBarSetCurrentPosition(windowName .. "GroupUpdateDelaySlider", math.max(math.min(1, (GetDelayValue(LibGroup.Settings.Group.UpdateDelay, UPDATE_DELAY) - 1) / (#UPDATE_DELAY - 1)), 0));
	SliderBarSetCurrentPosition(windowName .. "GroupDistanceCacheUpdateSlider", math.max(math.min(1, (GetDelayValue(LibGroup.Settings.Distance.UpdateDelay, UPDATE_DELAY) - 1) / (#UPDATE_DELAY - 1)), 0));
	SliderBarSetCurrentPosition(windowName .. "GroupDistanceSearchUpdateSlider", math.max(math.min(1, (GetDelayValue(LibGroup.Settings.Distance.SearchDelay, SEARCH_DELAY) - 1) / (#SEARCH_DELAY - 1)), 0));
	ButtonSetPressedFlag(windowName .. "EnableGroupDistance" .. "Button", (LibGroup.Settings.Distance.Enabled == true));
	
	LibGroup.Setup.OnSlideGroupUpdateDelay();
	LibGroup.Setup.OnSlideGroupDistanceCacheUpdate();
	LibGroup.Setup.OnSlideGroupDistanceSearchUpdate();

end

function LibGroup.Setup.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, LibGroup.Setup.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function LibGroup.Setup.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function LibGroup.Setup.OnCloseLUp()

	LibGroup.Setup.Hide();

end

function LibGroup.Setup.OnSlideGroupUpdateDelay()

	local value = UPDATE_DELAY[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "GroupUpdateDelaySlider") * (#UPDATE_DELAY - 1))];
	
	local stringValue = "%.2fs";
	LabelSetText(windowName .. "GroupUpdateDelaySliderValue", towstring(stringValue:format(value)));
	
	LibGroup.Settings.Group.UpdateDelay = value;
	
end

function LibGroup.Setup.OnSlideGroupDistanceCacheUpdate()

	local value = UPDATE_DELAY[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "GroupDistanceCacheUpdateSlider") * (#UPDATE_DELAY - 1))];
	
	local stringValue = "%.2fs";
	LabelSetText(windowName .. "GroupDistanceCacheUpdateSliderValue", towstring(stringValue:format(value)));
	
	LibGroup.Settings.Distance.UpdateDelay = value;
	
end

function LibGroup.Setup.OnSlideGroupDistanceSearchUpdate()

	local value = SEARCH_DELAY[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "GroupDistanceSearchUpdateSlider") * (#SEARCH_DELAY - 1))];
	
	local stringValue = "%.2fs";
	LabelSetText(windowName .. "GroupDistanceSearchUpdateSliderValue", towstring(stringValue:format(value)));
	
	LibGroup.Settings.Distance.SearchDelay = value;
	
end

function LibGroup.Setup.OnEnableGroupDistanceLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "EnableGroupDistance" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnableGroupDistance" .. "Button", isChecked);
	
	LibGroup.Settings.Distance.Enabled = isChecked;
	
end