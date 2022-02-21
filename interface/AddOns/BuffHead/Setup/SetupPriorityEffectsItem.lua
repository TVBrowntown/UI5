BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.PriorityEffectsItem = 
{
	WindowName = "BuffHeadSetupPriorityEffectsItemWindow",
};
local this = BuffHead.Setup.PriorityEffectsItem;

local windowName = BuffHead.Setup.PriorityEffectsItem.WindowName;
local localization = BuffHead.Localization.GetMapping();

local existingItem = {};

local function ShowButtons(showApply, showCreate)

	if (WindowGetShowing(windowName .. "ApplyButton") == showApply and WindowGetShowing(windowName .. "CreateButton") == showCreate) then return end

	WindowSetShowing(windowName .. "ApplyButton", showApply);
	WindowSetShowing(windowName .. "CreateButton", showCreate);
	
	if (showCreate) then
		WindowClearAnchors(windowName .. "CreateButton");
		if (showApply) then
			WindowAddAnchor(windowName .. "CreateButton", "topleft", windowName .. "ApplyButton", "topright", 0, 0);
		else
			WindowAddAnchor(windowName .. "CreateButton", "bottomright", windowName, "bottomright", -20, -20);
		end
	end

end

local function LoadItem(abilityId)

	local item = nil;
	existingItem = { AbilityId = abilityId };
	
	local targetType = {};
	
	if (abilityId) then
		--existing
		targetType = BuffHead.Settings.PriorityEffects.Effect[abilityId] or targetType;
	else
		--new
	end
	
	TextEditBoxSetText(windowName .. "AbilityIdEditBox", towstring(abilityId or ""));
	
	ButtonSetPressedFlag(windowName .. "TargetTypeSelf" .. "Button", (targetType[BuffHead.TargetType.Self] == true));
	ButtonSetPressedFlag(windowName .. "TargetTypeGroup" .. "Button", (targetType[BuffHead.TargetType.Group] == true));
	ButtonSetPressedFlag(windowName .. "TargetTypeFriendly" .. "Button", (targetType[BuffHead.TargetType.Friendly] == true));
	ButtonSetPressedFlag(windowName .. "TargetTypeHostile" .. "Button", (targetType[BuffHead.TargetType.Hostile] == true));
	
	if (abilityId) then
		ShowButtons(true, false);
	else
		ShowButtons(false, true);
	end

end


function BuffHead.Setup.PriorityEffectsItem.Initialize()	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.PriorityEffectsItem.Title"]);
	LabelSetText(windowName .. "AbilityIdLabel", localization["Setup.PriorityEffectsItem.AbilityId"]);
	
	LabelSetText(windowName .. "TargetTypeLabel", localization["Setup.PriorityEffectsItem.TargetType"]);	
	LabelSetText(windowName .. "TargetTypeSelfCheckboxLabel", localization["Setup.Trackers.Tracker.Self"]);
	LabelSetText(windowName .. "TargetTypeGroupCheckboxLabel", localization["Setup.Trackers.Tracker.Group"]);
	LabelSetText(windowName .. "TargetTypeFriendlyCheckboxLabel", localization["Setup.Trackers.Tracker.Friendly"]);
	LabelSetText(windowName .. "TargetTypeHostileCheckboxLabel", localization["Setup.Trackers.Tracker.Hostile"]);
	
	ButtonSetText(windowName .. "ApplyButton", localization["Setup.PriorityEffectsItem.Apply"]);
	ButtonSetText(windowName .. "CreateButton", localization["Setup.PriorityEffectsItem.Create"]);
	
	ShowButtons(false, true);
end

function BuffHead.Setup.PriorityEffectsItem.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.PriorityEffectsItem.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.PriorityEffectsItem.OnHidden()
	BuffHead.Setup.SetActiveWindow();
end

function BuffHead.Setup.PriorityEffectsItem.OnCloseLUp()
	this.Hide();
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.PriorityEffects);
end

function BuffHead.Setup.PriorityEffectsItem.Update()
	SetupEntries();
end

function BuffHead.Setup.PriorityEffectsItem.ShowNew()
	LoadItem(nil);
	this.Show();
end

function BuffHead.Setup.PriorityEffectsItem.ShowEdit(index)
	LoadItem(index);
	this.Show();
end

function BuffHead.Setup.PriorityEffectsItem.GetActiveItem()
	return existingItem or {};
end

function BuffHead.Setup.PriorityEffectsItem.OnAbilityIdChanged()
	local abilityId = tonumber(TextEditBoxGetText(windowName .. "AbilityIdEditBox"));
	
	if (abilityId == existingItem.AbilityId or BuffHead.Settings.PriorityEffects.Effect[abilityId]) then
		ShowButtons(true, false);
	else
		ShowButtons((existingItem.AbilityId ~= nil), true);
	end
end

function BuffHead.Setup.PriorityEffectsItem.OnTargetTypeLUp()
	local isChecked = ButtonGetPressedFlag(SystemData.ActiveWindow.name .. "Button") == false;
	ButtonSetPressedFlag(SystemData.ActiveWindow.name .. "Button", isChecked);
end

local function SaveItem(apply)
	local abilityId = tonumber(TextEditBoxGetText(windowName .. "AbilityIdEditBox"));
	local targetType = {};

	if (apply and existingItem.AbilityId and existingItem.AbilityId ~= abilityId) then
		BuffHead.Settings.PriorityEffects.Effect[existingItem.AbilityId] = nil;
	end
	
	targetType = 
	{
		[BuffHead.TargetType.Self] = (ButtonGetPressedFlag(windowName .. "TargetTypeSelf" .. "Button") == true),
		[BuffHead.TargetType.Group] = (ButtonGetPressedFlag(windowName .. "TargetTypeGroup" .. "Button") == true),
		[BuffHead.TargetType.Friendly] = (ButtonGetPressedFlag(windowName .. "TargetTypeFriendly" .. "Button") == true),
		[BuffHead.TargetType.Hostile] = (ButtonGetPressedFlag(windowName .. "TargetTypeHostile" .. "Button") == true)
	};
	
	BuffHead.Settings.PriorityEffects.Effect[abilityId] = targetType;
	
	BuffHead.Setup.PriorityEffects.Update();
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.PriorityEffects);
end

function BuffHead.Setup.PriorityEffectsItem.OnApplyLClick()
	SaveItem(true);
end

function BuffHead.Setup.PriorityEffectsItem.OnCreateLClick()
	SaveItem();
end