BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.Trackers = 
{
	WindowName = "BuffHeadSetupTrackersWindow",
};

local windowName = BuffHead.Setup.Trackers.WindowName;
local localization = BuffHead.Localization.GetMapping();

local TrackerType = { Friendly = 1, Hostile = 2, Group = 3, Self = 4 };
local TargetType = { Friendly = 1, Hostile = 2 };

local trackers = {};
local activeTracker;

local function SetTracker(tracker, trackerType)

	activeTracker = nil;

	ComboBoxClearMenuItems(windowName .. "TrackerBuffsList");
	ComboBoxClearMenuItems(windowName .. "TrackerDebuffsList");
	
	if (tracker.Type == TargetType.Friendly) then
		ComboBoxAddMenuItem(windowName .. "TrackerBuffsList", localization["Setup.Trackers.Friendly.Buffs.None"]);
		ComboBoxAddMenuItem(windowName .. "TrackerBuffsList", localization["Setup.Trackers.Friendly.Buffs.CastByMe"]);
		ComboBoxAddMenuItem(windowName .. "TrackerBuffsList", localization["Setup.Trackers.Friendly.Buffs.All"]);
		
		ComboBoxAddMenuItem(windowName .. "TrackerDebuffsList", localization["Setup.Trackers.Friendly.Debuffs.None"]);
		ComboBoxAddMenuItem(windowName .. "TrackerDebuffsList", localization["Setup.Trackers.Friendly.Debuffs.CurableByMe"]);
		ComboBoxAddMenuItem(windowName .. "TrackerDebuffsList", localization["Setup.Trackers.Friendly.Debuffs.All"]);
	else
		ComboBoxAddMenuItem(windowName .. "TrackerBuffsList", localization["Setup.Trackers.Hostile.Buffs.None"]);
		ComboBoxAddMenuItem(windowName .. "TrackerBuffsList", localization["Setup.Trackers.Hostile.Buffs.RemovableByMe"]);
		ComboBoxAddMenuItem(windowName .. "TrackerBuffsList", localization["Setup.Trackers.Hostile.Buffs.All"]);
		
		ComboBoxAddMenuItem(windowName .. "TrackerDebuffsList", localization["Setup.Trackers.Hostile.Debuffs.None"]);
		ComboBoxAddMenuItem(windowName .. "TrackerDebuffsList", localization["Setup.Trackers.Hostile.Debuffs.CastByMe"]);
		ComboBoxAddMenuItem(windowName .. "TrackerDebuffsList", localization["Setup.Trackers.Hostile.Debuffs.All"]);
	end
	
	activeTracker = tracker.Tracker;
	
	ButtonSetPressedFlag(windowName .. "TrackerEnable" .. "Button", (activeTracker.Enabled == true));
	ComboBoxSetSelectedMenuItem(windowName .. "TrackerBuffsList", activeTracker.Buffs);
	ComboBoxSetSelectedMenuItem(windowName .. "TrackerDebuffsList", activeTracker.Debuffs);
	ButtonSetPressedFlag(windowName .. "TrackerPermanentEffects" .. "Button", (activeTracker.Permanent == true));
	
	local activeType = BuffHead.Setup.Filter.ActiveType;
	if (activeType == BuffHead.Setup.Filter.WindowType.AlwaysShow) then
		BuffHead.Setup.Filter.Initialize(activeType, activeTracker.AlwaysShow);
	elseif (activeType == BuffHead.Setup.Filter.WindowType.AlwaysIgnore) then
		BuffHead.Setup.Filter.Initialize(activeType, activeTracker.AlwaysIgnore);
	end
	
	local r, g, b = 255, 255, 255;
	local onTargetChangeEnabled = true;
	
	if (trackerType == TrackerType.Friendly or trackerType == TrackerType.Hostile) then
		onTargetChangeEnabled = true;
		
		ButtonSetPressedFlag(windowName .. "OnTargetChangeClearAlwaysShow" .. "Button", (activeTracker.OnTargetChange.ClearAlwaysShow == true));
		ButtonSetPressedFlag(windowName .. "OnTargetChangeClearBuffs" .. "Button", (activeTracker.OnTargetChange.ClearBuffs == true));
		ButtonSetPressedFlag(windowName .. "OnTargetChangeClearDebuffs" .. "Button", (activeTracker.OnTargetChange.ClearDebuffs == true));
	else
		onTargetChangeEnabled = false;
		r, g, b = 140, 140, 140;
		
		ButtonSetPressedFlag(windowName .. "OnTargetChangeClearAlwaysShow" .. "Button", false);
		ButtonSetPressedFlag(windowName .. "OnTargetChangeClearBuffs" .. "Button", false);
		ButtonSetPressedFlag(windowName .. "OnTargetChangeClearDebuffs" .. "Button", false);
	end
	
	ButtonSetDisabledFlag(windowName .. "OnTargetChangeClearAlwaysShow" .. "Button", (onTargetChangeEnabled == false));
	ButtonSetDisabledFlag(windowName .. "OnTargetChangeClearBuffs" .. "Button", (onTargetChangeEnabled == false));
	ButtonSetDisabledFlag(windowName .. "OnTargetChangeClearDebuffs" .. "Button", (onTargetChangeEnabled == false));
	LabelSetTextColor(windowName .. "OnTargetChangeClearAlwaysShowCheckboxLabel", r, g, b);
	LabelSetTextColor(windowName .. "OnTargetChangeClearBuffsCheckboxLabel", r, g, b);
	LabelSetTextColor(windowName .. "OnTargetChangeClearDebuffsCheckboxLabel", r, g, b);

end

function BuffHead.Setup.Trackers.Initialize()

	LabelSetText(windowName .. "TrackersLabel", localization["Setup.Trackers.Title"]);
	
	LabelSetText(windowName .. "TrackerTypeLabel",  localization["Setup.Trackers.Tracker"]);
	ComboBoxClearMenuItems(windowName .. "TrackerTypeList");
	ComboBoxAddMenuItem(windowName .. "TrackerTypeList", localization["Setup.Trackers.Tracker.Friendly"]);
	ComboBoxAddMenuItem(windowName .. "TrackerTypeList", localization["Setup.Trackers.Tracker.Hostile"]);
	ComboBoxAddMenuItem(windowName .. "TrackerTypeList", localization["Setup.Trackers.Tracker.Group"]);
	ComboBoxAddMenuItem(windowName .. "TrackerTypeList", localization["Setup.Trackers.Tracker.Self"]);
	
	LabelSetText(windowName .. "TrackerEnableCheckboxLabel", localization["Setup.Trackers.Enable"]);
	LabelSetText(windowName .. "TrackerBuffsLabel", localization["Setup.Trackers.ShowBuffs"]);
	LabelSetText(windowName .. "TrackerDebuffsLabel", localization["Setup.Trackers.ShowDebuffs"]);
	LabelSetText(windowName .. "TrackerPermanentEffectsCheckboxLabel", localization["Setup.Trackers.PermanentEffects"]);
	
	LabelSetText(windowName .. "OnTargetChangeLabel", localization["Setup.Trackers.OnTargetChange"]);
	LabelSetText(windowName .. "OnTargetChangeClearAlwaysShowCheckboxLabel", localization["Setup.Trackers.OnTargetChange.ClearAlwaysShow"]);
	LabelSetText(windowName .. "OnTargetChangeClearBuffsCheckboxLabel", localization["Setup.Trackers.OnTargetChange.ClearBuffs"]);
	LabelSetText(windowName .. "OnTargetChangeClearDebuffsCheckboxLabel", localization["Setup.Trackers.OnTargetChange.ClearDebuffs"]);
	
	LabelSetText(windowName .. "AlwaysIgnoreLabel", localization["Setup.AlwaysIgnore"]);
	LabelSetText(windowName .. "AlwaysIgnoreDescriptionLabel", localization["Setup.AlwaysIgnore.Info"]);
	ButtonSetText(windowName .. "AlwaysIgnoreButton", localization["Setup.AlwaysIgnore.Manage"]);
	
	LabelSetText(windowName .. "AlwaysShowLabel", localization["Setup.AlwaysShow"]);
	LabelSetText(windowName .. "AlwaysShowDescriptionLabel", localization["Setup.AlwaysShow.Info"]);
	ButtonSetText(windowName .. "AlwaysShowButton", localization["Setup.AlwaysShow.Manage"]);
	
	ComboBoxSetSelectedMenuItem(windowName .. "TrackerTypeList", 1);
	
	BuffHead.Setup.Trackers.LoadSettings();
	
end

function BuffHead.Setup.Trackers.LoadSettings()

	trackers =
	{
		{ Tracker = BuffHead.Settings.Trackers.Friendly, Type = TargetType.Friendly },
		{ Tracker = BuffHead.Settings.Trackers.Hostile, Type = TargetType.Hostile },
		{ Tracker = BuffHead.Settings.Trackers.Group, Type = TargetType.Friendly },
		{ Tracker = BuffHead.Settings.Trackers.Self, Type = TargetType.Friendly },
	};

	BuffHead.Setup.Trackers.OnTrackerTypeChanged();

end

function BuffHead.Setup.Trackers.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.Trackers.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function BuffHead.Setup.Trackers.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function BuffHead.Setup.Trackers.OnHidden()

	BuffHead.Setup.SetActiveWindow();
	BuffHead.Setup.Filter.Hide();
	BuffHead.DestroyAllContainers();
	BuffHead.RefreshPlayerBuffs();

end

function BuffHead.Setup.Trackers.OnCloseLUp()

	BuffHead.Setup.Trackers.Hide();

end

function BuffHead.Setup.Trackers.OnTrackerTypeChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "TrackerTypeList");
	local tracker = trackers[value];
	
	if (tracker) then
		SetTracker(tracker, value);
	end
	
end

function BuffHead.Setup.Trackers.OnTrackerBuffChanged()

	if (not activeTracker) then return end
	local value = ComboBoxGetSelectedMenuItem(windowName .. "TrackerBuffsList");
	activeTracker.Buffs = value;
	
end

function BuffHead.Setup.Trackers.OnTrackerDebuffChanged()

	if (not activeTracker) then return end
	local value = ComboBoxGetSelectedMenuItem(windowName .. "TrackerDebuffsList");
	activeTracker.Debuffs = value;
	
end

function BuffHead.Setup.Trackers.OnTrackerPermanentLUp()

	if (not activeTracker) then return end
	local isChecked = ButtonGetPressedFlag(windowName .. "TrackerPermanentEffects" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "TrackerPermanentEffects" .. "Button", isChecked);
	activeTracker.Permanent = isChecked;

end

function BuffHead.Setup.Trackers.OnTrackerEnableLUp()

	if (not activeTracker) then return end
	local isChecked = ButtonGetPressedFlag(windowName .. "TrackerEnable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "TrackerEnable" .. "Button", isChecked);
	activeTracker.Enabled = isChecked;
	BuffHead.SetTrackers();

end

function BuffHead.Setup.Trackers.OnAlwaysIgnoreLClick()

	BuffHead.Setup.Filter.Initialize(BuffHead.Setup.Filter.WindowType.AlwaysIgnore, activeTracker.AlwaysIgnore);
	BuffHead.Setup.Filter.Show();
		
	WindowClearAnchors(BuffHead.Setup.Filter.WindowName);
	WindowAddAnchor(BuffHead.Setup.Filter.WindowName, "topright", windowName, "topleft", 0, 0);

end

function BuffHead.Setup.Trackers.OnAlwaysShowLClick()

	BuffHead.Setup.Filter.Initialize(BuffHead.Setup.Filter.WindowType.AlwaysShow, activeTracker.AlwaysShow);
	BuffHead.Setup.Filter.Show();
		
	WindowClearAnchors(BuffHead.Setup.Filter.WindowName);
	WindowAddAnchor(BuffHead.Setup.Filter.WindowName, "topright", windowName, "topleft", 0, 0);
	
end

function BuffHead.Setup.Trackers.OnTargetChangeClearAlwaysShowLUp()

	if (not activeTracker) then return end
	local isDisabled = ButtonGetDisabledFlag(windowName .. "OnTargetChangeClearAlwaysShow" .. "Button");
	if (isDisabled) then return end
	local isChecked = ButtonGetPressedFlag(windowName .. "OnTargetChangeClearAlwaysShow" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "OnTargetChangeClearAlwaysShow" .. "Button", isChecked);
	
	if (activeTracker.OnTargetChange) then
		activeTracker.OnTargetChange.ClearAlwaysShow = isChecked;
	end
	
end

function BuffHead.Setup.Trackers.OnTargetChangeClearBuffsLUp()

	if (not activeTracker) then return end
	local isDisabled = ButtonGetDisabledFlag(windowName .. "OnTargetChangeClearBuffs" .. "Button");
	if (isDisabled) then return end
	local isChecked = ButtonGetPressedFlag(windowName .. "OnTargetChangeClearBuffs" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "OnTargetChangeClearBuffs" .. "Button", isChecked);
	
	if (activeTracker.OnTargetChange) then
		activeTracker.OnTargetChange.ClearBuffs = isChecked;
	end
	
end

function BuffHead.Setup.Trackers.OnTargetChangeClearDebuffsLUp()

	if (not activeTracker) then return end
	local isDisabled = ButtonGetDisabledFlag(windowName .. "OnTargetChangeClearDebuffs" .. "Button");
	if (isDisabled) then return end
	local isChecked = ButtonGetPressedFlag(windowName .. "OnTargetChangeClearDebuffs" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "OnTargetChangeClearDebuffs" .. "Button", isChecked);
	
	if (activeTracker.OnTargetChange) then
		activeTracker.OnTargetChange.ClearDebuffs = isChecked;
	end
	
end