BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.PriorityEffects = 
{
	WindowName = "BuffHeadSetupPriorityEffectsWindow",
	Entries = {},
};
local this = BuffHead.Setup.PriorityEffects;

local windowName = BuffHead.Setup.PriorityEffects.WindowName;
local localization = BuffHead.Localization.GetMapping();

local activeRow = nil;
local activeRowItem = nil;

local function TintRow(rowName, isActive)

	local id = WindowGetId(rowName);
	local entry = this.Entries[id];
		
	if (isActive) then
		WindowSetTintColor(rowName .. "Background", 12, 47, 158);
		WindowSetAlpha(rowName .. "Background", 0.4);
	else
		WindowSetAlpha(rowName .. "Background", 0);
	end

end

local function TintRows()
	for rowIndex, dataIndex in ipairs(BuffHeadSetupPriorityEffectsWindowList.PopulatorIndices) do
	
		local rowName = windowName .. "ListRow" .. rowIndex;
		WindowSetId(rowName, dataIndex);
		
		local entry = this.Entries[dataIndex];
		
		TintRow(rowName, (rowName == activeRow));
	
	end
end

local function CompareEntry(indexA, indexB)
	if (indexB == nil) then
		return false;
	end
	
	local entryA = this.Entries[indexA];
	local entryB = this.Entries[indexB];
	
	if (entryA.Name == entryB.Name) then
		if (type(entryA.Value) == type(entryB.Value)) then
			if (type(entryA.Value) == "number") then
				return (entryA.Value < entryB.Value);
			end
		end
		return (WStringsCompare(entryA.Value, entryB.Value) < 0);
	else
		return (WStringsCompare(entryA.Name, entryB.Name) < 0);
	end
end

local function GetDisplayName(abilityName)
	local displayName = towstring(abilityName);
	local abilityId = L"?";
	
	if (type(abilityName) == "number") then
		local name = GetAbilityName(abilityName);
		if (name and name:len() > 0) then
			displayName = name;
			abilityId = towstring(abilityName);
		end
	end
	return displayName, abilityId;
end

local function SetupEntries()
	
	this.Entries = {};
	
	for abilityId, targetType in pairs(BuffHead.Settings.PriorityEffects.Effect) do
		local displayName, description = GetDisplayName(abilityId);
		table.insert(this.Entries, 
			{
				Name = displayName,
				Description = description,
				Value = abilityId,
			});
	end
	
	this.UpdateList();
end

function BuffHead.Setup.PriorityEffects.Initialize()
	BuffHead.Setup.PriorityEffectsItem.Initialize();
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.PriorityEffects.Title"]);
	LabelSetText(windowName .. "SortFirstCheckboxLabel", localization["Setup.PriorityEffects.SortFirst"]);
	LabelSetText(windowName .. "AnimationLabel", localization["Setup.PriorityEffects.Animation"]);
	LabelSetText(windowName .. "EffectsLabel", localization["Setup.PriorityEffects.Effects"]);
	
	ButtonSetText(windowName .. "NewButton", localization["Setup.PriorityEffects.New"]);
	
	ComboBoxClearMenuItems(windowName .. "AnimationComboBox");
	ComboBoxAddMenuItem(windowName .. "AnimationComboBox", localization["Setup.PriorityEffects.Animation.None"]);
	ComboBoxAddMenuItem(windowName .. "AnimationComboBox", localization["Setup.PriorityEffects.Animation.AnimatedBorder"]);
	ComboBoxAddMenuItem(windowName .. "AnimationComboBox", localization["Setup.PriorityEffects.Animation.AnimatedBorderThick"]);
	
	BuffHead.Setup.PriorityEffects.LoadSettings();
	
	SetupEntries();
end

function BuffHead.Setup.PriorityEffects.LoadSettings()
	local settings = BuffHead.Settings.PriorityEffects;

	ButtonSetPressedFlag(windowName .. "SortFirst" .. "Button", (settings.SortToFront == true));
	ComboBoxSetSelectedMenuItem(windowName .. "AnimationComboBox", settings.Animation or 1);
end

function BuffHead.Setup.PriorityEffects.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.PriorityEffects.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.PriorityEffects.OnHidden()
	BuffHead.Setup.SetActiveWindow();
end

function BuffHead.Setup.PriorityEffects.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.PriorityEffects.UpdateList()
    local entriesOrdered = {};
    for index, data in ipairs(this.Entries) do
        table.insert(entriesOrdered, index);
    end

	table.sort(entriesOrdered, CompareEntry);
	ListBoxSetDisplayOrder(windowName .. "List", entriesOrdered);
end

local function CreateContextMenu()
	if (not activeRowItem) then return end
	
	EA_Window_ContextMenu.CreateContextMenu(activeRow);
	
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.PriorityEffects.Context.Remove"], this.OnContextMenuRemoveLUp, false, true);
	EA_Window_ContextMenu.Finalize();
end

function BuffHead.Setup.PriorityEffects.OnRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function BuffHead.Setup.PriorityEffects.OnRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function BuffHead.Setup.PriorityEffects.OnRowLDown()

	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.PriorityEffects.OnRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	BuffHead.Setup.PriorityEffectsItem.ShowEdit(entry.Value);
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.PriorityEffectsItem);
	
end

function BuffHead.Setup.PriorityEffects.OnRowRDown()

	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.PriorityEffects.OnRowRUp()
	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	activeRowItem = entry;
	CreateContextMenu();
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
end

function BuffHead.Setup.PriorityEffects.OnContextMenuRemoveLUp()
	if (activeRowItem) then		
		BuffHead.Settings.PriorityEffects.Effect[activeRowItem.Value] = nil;
		activeRowItem = nil;
		SetupEntries();
	end
end

function BuffHead.Setup.PriorityEffects.OnPopulate()
	if (not BuffHeadSetupPriorityEffectsWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
end

function BuffHead.Setup.PriorityEffects.Update()
	SetupEntries();
end

function BuffHead.Setup.PriorityEffects.OnNewLClick()
	BuffHead.Setup.PriorityEffectsItem.ShowNew()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.PriorityEffectsItem);
end

function BuffHead.Setup.PriorityEffects.OnSortFirstLUp()
	local isChecked = ButtonGetPressedFlag(windowName .. "SortFirst" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "SortFirst" .. "Button", isChecked);
	
	BuffHead.Settings.PriorityEffects.SortToFront = isChecked;
end

function BuffHead.Setup.PriorityEffects.OnAnimationChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "AnimationComboBox");
	BuffHead.Settings.PriorityEffects.Animation = value;
end