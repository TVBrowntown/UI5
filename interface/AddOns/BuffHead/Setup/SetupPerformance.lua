BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.Performance = 
{
	WindowName = "BuffHeadSetupPerformanceWindow",
};

local MAX_PRIORITY_START_SLIDER = 90;
local UPDATE_DELAY = { 0.01, 0.1, 0.5, 1, 2 };
local RESYNC_DELAY = { 0, 1, 5, 10, 20, 30 };
local MAXIMUM_UPDATES = { 0, 1, 2, 5, 10, 15, 20, 30, 50 };

local windowName = BuffHead.Setup.Performance.WindowName;
local localization = BuffHead.Localization.GetMapping();

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

function BuffHead.Setup.Performance.Initialize()

	LabelSetText(windowName .. "PerformanceLabel", localization["Setup.Performance.Title"]);
	LabelSetText(windowName .. "GeneralUpdateDelayLabel", localization["Setup.Performance.GeneralUpdateDelay"]);
	LabelSetText(windowName .. "PriorityUpdateLabel", localization["Setup.Performance.PriorityUpdates"]);
	LabelSetText(windowName .. "EnablePriorityUpdatesCheckboxLabel", localization["Setup.Performance.PriorityUpdates.Enable"]);
	LabelSetText(windowName .. "PriorityUpdateStartLabel", localization["Setup.Performance.PriorityUpdates.Start"]);
	LabelSetText(windowName .. "PriorityUpdateDelayLabel", localization["Setup.Performance.PriorityUpdates.Delay"]);
	LabelSetText(windowName .. "FadingLabel", localization["Setup.Performance.Fading"]);
	LabelSetText(windowName .. "EnableFadingCheckboxLabel", localization["Setup.Performance.Fading.Enable"]);
	LabelSetText(windowName .. "SyncLabel", localization["Setup.Performance.Sync"]);
	LabelSetText(windowName .. "EnableSyncCheckboxLabel", localization["Setup.Performance.Sync.Enable"]);
	LabelSetText(windowName .. "ResyncTargetDelayLabel", localization["Setup.Performance.Sync.ResyncTarget"]);
	LabelSetText(windowName .. "MaximumUpdatesLabel", localization["Setup.Performance.MaximumUpdates"]);
	LabelSetText(windowName .. "EffectAnchoringLabel", localization["Setup.Performance.EffectAnchoring"]);
	
	ComboBoxClearMenuItems(windowName .. "EffectAnchoringList");
	ComboBoxAddMenuItem(windowName .. "EffectAnchoringList", localization["Setup.Performance.EffectAnchoring.Needed"]);
	ComboBoxAddMenuItem(windowName .. "EffectAnchoringList", localization["Setup.Performance.EffectAnchoring.Updated"]);
	
	BuffHead.Setup.Performance.LoadSettings();
	
end

function BuffHead.Setup.Performance.LoadSettings()
	
	SliderBarSetCurrentPosition(windowName .. "GeneralUpdateDelaySlider", math.max(math.min(1, (GetDelayValue(BuffHead.Settings.Performance.GeneralDelay, UPDATE_DELAY) - 1) / (#UPDATE_DELAY - 1)), 0));
	ButtonSetPressedFlag(windowName .. "EnablePriorityUpdates" .. "Button", BuffHead.Settings.Performance.PriorityUpdate);
	SliderBarSetCurrentPosition(windowName .. "PriorityUpdateStartSlider", math.max(math.min(1, BuffHead.Settings.Performance.PriorityStart / MAX_PRIORITY_START_SLIDER), 0));
	SliderBarSetCurrentPosition(windowName .. "PriorityUpdateDelaySlider", math.max(math.min(1, (GetDelayValue(BuffHead.Settings.Performance.PriorityDelay, UPDATE_DELAY) - 1) / (#UPDATE_DELAY - 1)), 0));
	ButtonSetPressedFlag(windowName .. "EnableFading" .. "Button", BuffHead.Settings.Fading.Enable);
	ButtonSetPressedFlag(windowName .. "EnableSync" .. "Button", BuffHead.Settings.Sync.Enable);
	SliderBarSetCurrentPosition(windowName .. "ResyncTargetDelaySlider", math.max(math.min(1, (GetDelayValue(BuffHead.Settings.Sync.ResyncEvery, RESYNC_DELAY) - 1) / (#RESYNC_DELAY - 1)), 0));
	SliderBarSetCurrentPosition(windowName .. "MaximumUpdatesSlider", math.max(math.min(1, (GetDelayValue(BuffHead.Settings.Performance.MaximumUpdates, MAXIMUM_UPDATES) - 1) / (#MAXIMUM_UPDATES - 1)), 0));
	ComboBoxSetSelectedMenuItem(windowName .. "EffectAnchoringList", BuffHead.Settings.Performance.EffectAnchoring or 1);
	
	BuffHead.Setup.Performance.OnSlideGeneralUpdateDelay();
	BuffHead.Setup.Performance.OnSlidePriorityUpdateStart();
	BuffHead.Setup.Performance.OnSlidePriorityUpdateDelay();
	BuffHead.Setup.Performance.OnSlideResyncTargetDelay();
	BuffHead.Setup.Performance.OnSlideMaximumUpdates();
	
end

function BuffHead.Setup.Performance.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.Performance.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function BuffHead.Setup.Performance.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function BuffHead.Setup.Performance.OnHidden()

	BuffHead.Setup.SetActiveWindow();
	BuffHead.Setup.Filter.Hide();

end

function BuffHead.Setup.Performance.OnCloseLUp()

	BuffHead.Setup.Performance.Hide();

end

function BuffHead.Setup.Performance.OnSlideGeneralUpdateDelay()

	local value = UPDATE_DELAY[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "GeneralUpdateDelaySlider") * (#UPDATE_DELAY - 1))];
	
	local stringValue = "%.2fs";
	LabelSetText(windowName .. "GeneralUpdateDelayValue", towstring(stringValue:format(value)));

	BuffHead.Settings.Performance.GeneralDelay = value;
	BuffHead.UpdateDelay();
	
end

function BuffHead.Setup.Performance.OnEnablePriorityLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "EnablePriorityUpdates" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnablePriorityUpdates" .. "Button", isChecked);
	BuffHead.Settings.Performance.PriorityUpdate = isChecked;
	BuffHead.UpdateDelay();
	
end

function BuffHead.Setup.Performance.OnSlidePriorityUpdateStart()

	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "PriorityUpdateStartSlider") * MAX_PRIORITY_START_SLIDER);
	
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
	
	LabelSetText(windowName .. "PriorityUpdateStartValue", towstring(stringValue));

	BuffHead.Settings.Performance.PriorityStart = value;
	
end

function BuffHead.Setup.Performance.OnSlidePriorityUpdateDelay()

	local value = UPDATE_DELAY[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "PriorityUpdateDelaySlider") * (#UPDATE_DELAY - 1))];
	
	local stringValue = "%.2fs";
	LabelSetText(windowName .. "PriorityUpdateDelayValue", towstring(stringValue:format(value)));

	BuffHead.Settings.Performance.PriorityDelay = value;
	BuffHead.UpdateDelay();
	
end

function BuffHead.Setup.Performance.OnEnableFadingLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "EnableFading" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnableFading" .. "Button", isChecked);
	BuffHead.Settings.Fading.Enable = isChecked;
	
end

function BuffHead.Setup.Performance.OnEnableSyncLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "EnableSync" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnableSync" .. "Button", isChecked);
	BuffHead.Settings.Sync.Enable = isChecked;
	
end

function BuffHead.Setup.Performance.OnSlideResyncTargetDelay()

	local value = RESYNC_DELAY[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "ResyncTargetDelaySlider") * (#RESYNC_DELAY - 1))];
	
	local stringValue = "%.2fs";
	if (value == 0) then
		stringValue = localization["Setup.Performance.Sync.ResyncTarget.Never"];
	else
		stringValue = towstring(stringValue:format(value));
	end
	LabelSetText(windowName .. "ResyncTargetDelayValue", stringValue);

	BuffHead.Settings.Sync.ResyncEvery = value;
	
end

function BuffHead.Setup.Performance.OnSlideMaximumUpdates()

	local value = MAXIMUM_UPDATES[1 + math.floor(SliderBarGetCurrentPosition(windowName .. "MaximumUpdatesSlider") * (#MAXIMUM_UPDATES - 1))];
	
	local stringValue = "%d";
	if (value == 0) then
		stringValue = localization["Setup.Performance.MaximumUpdates.Unlimited"];
	else
		stringValue = towstring(stringValue:format(value));
	end
	LabelSetText(windowName .. "MaximumUpdatesValue", stringValue);

	BuffHead.Settings.Performance.MaximumUpdates = value;
	
end

function BuffHead.Setup.Performance.OnEffectAnchoringChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "EffectAnchoringList");
	BuffHead.Settings.Performance.EffectAnchoring = value;

end