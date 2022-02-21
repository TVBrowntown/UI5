BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.Filter = 
{
	WindowName = "BuffHeadSetupFilterWindow",
	Entries = {},
	WindowType = { AlwaysIgnore = 1, AlwaysShow = 2 },
	ActiveType = nil,
};

local windowName = BuffHead.Setup.Filter.WindowName;
local activeRow = nil;
local abilityList = nil;
local activeItem = nil;

local localization = BuffHead.Localization.GetMapping();

local function TintRow(rowName, isActive)

	local id = WindowGetId(rowName);
	local entry = BuffHead.Setup.Filter.Entries[id];

	if (entry and entry.Inherited) then
		LabelSetTextColor(rowName .. "Name", 92, 92, 92);
	else
		LabelSetTextColor(rowName .. "Name", 255, 255, 255);
	end
		
	if (isActive) then
		WindowSetTintColor(rowName .. "Background", 12, 47, 158);
		WindowSetAlpha(rowName .. "Background", 0.4);
	else		
		WindowSetAlpha(rowName .. "Background", 0);
	end

end

local function TintRows()
	for rowIndex, dataIndex in ipairs(BuffHeadSetupFilterWindowList.PopulatorIndices) do
	
		local rowName = windowName .. "ListRow" .. rowIndex;
		WindowSetId(rowName, dataIndex);
		WindowSetId(rowName .. "Enable", dataIndex);
		
		local entry = BuffHead.Setup.Filter.Entries[dataIndex];
		if (entry) then	
			ButtonSetDisabledFlag(rowName .. "EnableButton", entry.Inherited);
			ButtonSetPressedFlag(rowName .. "EnableButton", (entry.Enabled == true));
		end
		
		TintRow(rowName, (rowName == activeRow));
	
	end
end

local function CompareEntry(indexA, indexB)
	if (indexB == nil) then
		return false;
	end
	
	local entryA = BuffHead.Setup.Filter.Entries[indexA];
	local entryB = BuffHead.Setup.Filter.Entries[indexB];
	
	if (entryA.Inherited == entryB.Inherited) then
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
	else
		return (entryA.Inherited == true);
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
	
	BuffHead.Setup.Filter.Entries = {};
	if (not abilityList) then return end
	
	local coreList = BuffHead.Settings.AlwaysShow;
	if (BuffHead.Setup.Filter.ActiveType == BuffHead.Setup.Filter.WindowType.AlwaysIgnore) then
		coreList = BuffHead.Settings.AlwaysIgnore;
	end
	if (abilityList ~= coreList) then
		for abilityName, enabled in pairs(coreList) do
			if (abilityList[abilityName] == nil) then
				local displayName, abilityId = GetDisplayName(abilityName);
				table.insert(BuffHead.Setup.Filter.Entries, { Name = displayName, AbilityId = abilityId, Inherited = true, Value = abilityName, Enabled = enabled });
			end
		end
	end
	
	for abilityName, enabled in pairs(abilityList) do
		local displayName, abilityId = GetDisplayName(abilityName);
		table.insert(BuffHead.Setup.Filter.Entries, { Name = displayName, AbilityId = abilityId, Inherited = false, Value = abilityName, Enabled = enabled });
	end
	
	BuffHead.Setup.Filter.UpdateList();
end

function BuffHead.Setup.Filter.Update()

	SetupEntries();
		
end

function BuffHead.Setup.Filter.Initialize(windowType, list)

	if (BuffHead.Setup.Filter.ActiveType ~= windowType) then
		BuffHead.Setup.Filter.ActiveType = windowType;
		
		if (windowType == BuffHead.Setup.Filter.WindowType.AlwaysIgnore) then
			LabelSetText(windowName .. "FilterLabel", localization["Setup.Filter.AlwaysIgnore"]);
		elseif (windowType == BuffHead.Setup.Filter.WindowType.AlwaysShow) then
			LabelSetText(windowName .. "FilterLabel", localization["Setup.Filter.AlwaysShow"]);
		end
		
		LabelSetText(windowName .. "AbilityNameLabel", localization["Setup.Filter.AbilityName"]);
		ButtonSetText(windowName .. "AddButton", localization["Setup.Filter.AbilityName.Add"]);
	end
	
	if (abilityList ~= list) then
		abilityList = list;
		SetupEntries();
	end
		
end

function BuffHead.Setup.Filter.LoadSettings()

	BuffHead.Setup.Filter.Hide(); -- a filter cannot have it's settings reloaded
		
end

function BuffHead.Setup.Filter.CreateContextMenu(inherited)
	
	EA_Window_ContextMenu.CreateContextMenu(activeRow);
	if (inherited) then
		EA_Window_ContextMenu.AddMenuItem(localization["Setup.Filter.IgnoreInheritance"], BuffHead.Setup.Filter.OnContextMenuIgnoreInheritanceLUp, false, true);
	else
		EA_Window_ContextMenu.AddMenuItem(localization["Setup.Filter.Remove"], BuffHead.Setup.Filter.OnContextMenuRemoveLUp, false, true);
	end
	EA_Window_ContextMenu.Finalize();
	
end

function BuffHead.Setup.Filter.UpdateList()

    local entriesOrdered = {};
    for index,data in ipairs(BuffHead.Setup.Filter.Entries) do
        table.insert(entriesOrdered, index);
    end

	table.sort(entriesOrdered, CompareEntry);
	ListBoxSetDisplayOrder(windowName .. "List", entriesOrdered)
	
end

function BuffHead.Setup.Filter.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.Filter.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function BuffHead.Setup.Filter.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function BuffHead.Setup.Filter.OnHidden()

end

function BuffHead.Setup.Filter.OnCloseLUp()

	BuffHead.Setup.Filter.Hide();

end

function BuffHead.Setup.Filter.OnEnableFilter()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = BuffHead.Setup.Filter.Entries[id];
	if (not entry or entry.Inherited) then return end

	local isChecked = ButtonGetPressedFlag(SystemData.ActiveWindow.name .. "Button") == false;
	ButtonSetPressedFlag(SystemData.ActiveWindow.name .. "Button", isChecked);
	
	if (abilityList) then
		abilityList[entry.Value] = isChecked;
	end

end

function BuffHead.Setup.Filter.OnRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function BuffHead.Setup.Filter.OnRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function BuffHead.Setup.Filter.OnRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = BuffHead.Setup.Filter.Entries[id];
	if (not entry) then return end
	
	TextEditBoxSetText(windowName .. "AbilityNameEditBox", towstring(entry.Value));
		
end

function BuffHead.Setup.Filter.OnRowRUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = BuffHead.Setup.Filter.Entries[id];
	if (not entry) then return end
	
	activeItem = entry.Value;
	BuffHead.Setup.Filter.CreateContextMenu(entry.Inherited);
		
end

function BuffHead.Setup.Filter.OnContextMenuRemoveLUp()
	
	if (activeItem) then		
		if (abilityList) then
			abilityList[activeItem] = nil;
			activeItem = nil;
			SetupEntries();
		end
	end
	
end

function BuffHead.Setup.Filter.OnContextMenuIgnoreInheritanceLUp()
	
	if (activeItem) then		
		if (abilityList) then
			abilityList[activeItem] = false;
			activeItem = nil;
			SetupEntries();
		end
	end

end

function BuffHead.Setup.Filter.OnPopulate()

	if (not BuffHeadSetupFilterWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
end

function BuffHead.Setup.Filter.OnAddLClick()

	local value = tostring(TextEditBoxGetText(windowName .. "AbilityNameEditBox"));
	TextEditBoxSetText(windowName .. "AbilityNameEditBox", L"")
	if (abilityList) then
		if (tostring(tonumber(value)) == value) then
			value = tonumber(value);
		end
		abilityList[value] = true;
		SetupEntries();
	end
	
end

function BuffHead.Setup.Filter.GetActiveList()
	return abilityList;
end

function BuffHead.Setup.Filter.IsShowing()
	return WindowGetShowing(windowName)
end