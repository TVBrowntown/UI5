BuffHead = BuffHead or {}; 
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.EffectCache = 
{
	WindowName = "BuffHeadSetupEffectCacheWindow",
	Entries = {},
};

local windowName = BuffHead.Setup.EffectCache.WindowName;
local localization = BuffHead.Localization.GetMapping();

local SEARCH_DELAY = 0.5;

local searchTime = 0;
local searchRegistered = false;
local effectCache = {};

local indexToRow = {};
local activeRow = nil;
local activeItem = nil;
local SortDirection = { Ascending = 1, Descending = 2 };
local SortType = { Id = 1, Name = 2 };

local sortDisplay = { Type = SortType.Name, Direction = SortDirection.Ascending };
local sortButton = 
{
	[SortType.Id] = { Name = windowName .. "SortBarSortByAbilityButton", Tooltip = localization["Setup.EffectCache.SortBy.Id.Tooltip"], Text = localization["Setup.EffectCache.SortBy.Id"] },
	[SortType.Name] = { Name = windowName .. "SortBarSortByNameButton", Tooltip = localization["Setup.EffectCache.SortBy.Name.Tooltip"], Text = localization["Setup.EffectCache.SortBy.Name"] },
};

local function TintRow(rowName, isActive)

	local id = WindowGetId(rowName);
	local entry = BuffHead.Setup.EffectCache.Entries[id];
		
	if (isActive) then
		WindowSetTintColor(rowName .. "Background", 12, 47, 158);
		WindowSetAlpha(rowName .. "Background", 0.4);
	else
		WindowSetAlpha(rowName .. "Background", 0);
	end

end

local function TintRows()
	indexToRow = {};
	for rowIndex, dataIndex in ipairs(BuffHeadSetupEffectCacheWindowList.PopulatorIndices) do
	
		local rowName = windowName .. "ListRow" .. rowIndex;
		WindowSetId(rowName, dataIndex);
		indexToRow[dataIndex] = rowIndex;
		
		local entry = BuffHead.Setup.EffectCache.Entries[dataIndex];
		
		TintRow(rowName, (rowName == activeRow));
	
	end
end

local function CompareEntry(indexA, indexB)
	if (indexB == nil) then
		return false;
	end
	
	local entryA = BuffHead.Setup.EffectCache.Entries[indexA];
	local entryB = BuffHead.Setup.EffectCache.Entries[indexB];
	
	if (sortDisplay.Type == SortType.Id) then
		if (sortDisplay.Direction == SortDirection.Ascending) then
			return (entryA.Id < entryB.Id);
		else
			return (entryA.Id > entryB.Id);
		end
	else
		if (sortDisplay.Direction == SortDirection.Ascending) then
			return (WStringsCompare(entryA.Name, entryB.Name) < 0);
		else
			return (WStringsCompare(entryA.Name, entryB.Name) > 0);
		end
	end
	
end

local function SetupEntries()
	BuffHead.Setup.EffectCache.Entries = {};
	
	local replacements = 
	{
		[L"%%"] = L"%%%%",
		[L"%("] = L"%%(",
		[L"%)"] = L"%%)",
	};
	
	local filterText = (TextEditBoxGetText(windowName .. "SearchEditBox")):lower();
	if (filterText:len() > 0) then
		for find, replace in pairs(replacements) do
			filterText = filterText:gsub(find, replace);
		end
	end
	
	for abilityId, effect in pairs(effectCache) do
		if (filterText:len() == 0 or wstring.match(towstring(effect.Data.name):lower(), filterText) ~= nil or wstring.match(towstring(abilityId), filterText) ~= nil) then
			table.insert(BuffHead.Setup.EffectCache.Entries, 
				{
					Id = abilityId,
					Name = towstring(effect.Data.name),
				});
		end
	end
	
	BuffHead.Setup.EffectCache.UpdateList();
end

local function UpdateSortButtons()
    
	local type = sortDisplay.Type;
	local direction = sortDisplay.Direction;
	
	for _, sortType in pairs(SortType) do
		ButtonSetPressedFlag(sortButton[sortType].Name, type == sortType);
	end
	
	WindowSetShowing(windowName .. "SortBarUpArrow", direction == SortDirection.Ascending);
	WindowSetShowing(windowName .. "SortBarDownArrow", direction == SortDirection.Descending);
	
	local window = sortButton[type];
	
	if (direction == SortDirection.Ascending) then		
		WindowClearAnchors(windowName .. "SortBarUpArrow");
		WindowAddAnchor(windowName .. "SortBarUpArrow", "right", sortButton[type].Name, "right", -10, 0);
	else
		WindowClearAnchors(windowName .. "SortBarDownArrow");
		WindowAddAnchor(windowName .. "SortBarDownArrow", "right", sortButton[type].Name, "right", -10, 0);
	end
	
end

function BuffHead.Setup.EffectCache.Initialize()

	BuffHead.Setup.EffectCacheTable.Initialize();
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.EffectCache.Title"]);
	LabelSetText(windowName .. "SearchLabel", localization["Setup.EffectCache.Search"]);
	LabelSetText(windowName .. "EnableCachingCheckboxLabel", localization["Setup.EffectCache.Enable"]);
	
	ButtonSetText(windowName .. "ResetButton", localization["Setup.EffectCache.Reset"]);
	ButtonSetText(windowName .. "RefreshButton", localization["Setup.EffectCache.Refresh"]);
	
	for _, sortType in pairs(SortType) do
		ButtonSetText(sortButton[sortType].Name, sortButton[sortType].Text);
	end
	
	SetupEntries();
	UpdateSortButtons();
	
end

function BuffHead.Setup.EffectCache.Show()

	if (WindowGetShowing(windowName)) then return end

	SetupEntries();
	--d("Effect cache show")
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.EffectCache.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function BuffHead.Setup.EffectCache.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function BuffHead.Setup.EffectCache.OnHidden()

	BuffHead.Setup.EffectCacheTable.Hide();

end

function BuffHead.Setup.EffectCache.OnCloseLUp()

	BuffHead.Setup.EffectCache.Hide();

end

function BuffHead.Setup.EffectCache.CreateContextMenu()
	
	if (not activeItem) then return end
	
	EA_Window_ContextMenu.CreateContextMenu(activeRow);
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.EffectCache.Context.AddToAlwaysShow"], BuffHead.Setup.EffectCache.OnContextMenuAlwaysShowLUp, false, true);
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.EffectCache.Context.AddToAlwaysIgnore"], BuffHead.Setup.EffectCache.OnContextMenuAlwaysIgnoreLUp, false, true);
	EA_Window_ContextMenu.AddMenuDivider();
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.EffectCache.Context.ViewTable"], BuffHead.Setup.EffectCache.OnContextMenuViewTableLUp, false, true);
	EA_Window_ContextMenu.Finalize();
	
end

function BuffHead.Setup.EffectCache.OnContextMenuAlwaysShowLUp()

	if (not activeItem) then return end
	
	local alwaysShow = BuffHead.Settings.AlwaysShow;
	
	local isShowing = (BuffHead.Setup.Filter.IsShowing() and BuffHead.Setup.Filter.ActiveType == BuffHead.Setup.Filter.WindowType.AlwaysShow);
	if (isShowing) then
		alwaysShow = BuffHead.Setup.Filter.GetActiveList() or alwaysShow;
	end
	
	alwaysShow[activeItem.Id] = true;
	
	if (isShowing) then
		BuffHead.Setup.Filter.Update();
	end

end

function BuffHead.Setup.EffectCache.OnContextMenuAlwaysIgnoreLUp()

	if (not activeItem) then return end
	
	local alwaysIgnore = BuffHead.Settings.AlwaysIgnore;
	
	local isShowing = (BuffHead.Setup.Filter.IsShowing() and BuffHead.Setup.Filter.ActiveType == BuffHead.Setup.Filter.WindowType.AlwaysIgnore);
	if (isShowing) then
		alwaysIgnore = BuffHead.Setup.Filter.GetActiveList() or alwaysIgnore;
	end
	
	alwaysIgnore[activeItem.Id] = true;
	
	if (isShowing) then
		BuffHead.Setup.Filter.Update();
	end

end

function BuffHead.Setup.EffectCache.OnContextMenuViewTableLUp()

	if (not activeItem) then return end

	local effectData = effectCache[activeItem.Id];
	if (not effectData) then return end
	
	BuffHead.Setup.EffectCacheTable.ShowTable(effectData);

end

function BuffHead.Setup.EffectCache.UpdateList()

    local entriesOrdered = {};
    for index, data in ipairs(BuffHead.Setup.EffectCache.Entries) do
        table.insert(entriesOrdered, index);
    end

	table.sort(entriesOrdered, CompareEntry);
	ListBoxSetDisplayOrder(windowName .. "List", entriesOrdered);
	
end

function BuffHead.Setup.EffectCache.OnSortButtonLUp()

	local type = WindowGetId(SystemData.ActiveWindow.name);
	
	-- if the sort type is already active, change the order.
	if (type == sortDisplay.Type) then
		if (sortDisplay.Direction == SortDirection.Ascending) then
			sortDisplay.Direction = SortDirection.Descending;
		else
			sortDisplay.Direction = SortDirection.Ascending;
		end
	else
		sortDisplay.Type = type;
		sortDisplay.Direction = SortDirection.Ascending;
	end 
	
	BuffHead.Setup.EffectCache.UpdateList()
	UpdateSortButtons();
	
end

function BuffHead.Setup.EffectCache.OnSortButtonMouseOver()

	local windowName = SystemData.ActiveWindow.name;
	local type = WindowGetId(windowName);
	
	Tooltips.CreateTextOnlyTooltip(windowName, nil);
	Tooltips.SetTooltipText(1, 1, sortButton[type].Tooltip);
	Tooltips.SetTooltipColorDef(1, 1, Tooltips.COLOR_HEADING);
	Tooltips.Finalize();
	
	local anchor = { Point = "top", RelativeTo = windowName, RelativePoint = "center", XOffset = 0, YOffset = -32 };
	Tooltips.AnchorTooltip(anchor);
	Tooltips.SetTooltipAlpha(1);
	
end

function BuffHead.Setup.EffectCache.OnRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function BuffHead.Setup.EffectCache.OnRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function BuffHead.Setup.EffectCache.OnRowLDown()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = BuffHead.Setup.EffectCache.Entries[id];
	if (not entry) then return end
	
	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.EffectCache.OnRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = BuffHead.Setup.EffectCache.Entries[id];
	if (not entry) then return end
	
	-- nothing to do
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
	
end

function BuffHead.Setup.EffectCache.OnRowRUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = BuffHead.Setup.EffectCache.Entries[id];
	if (not entry) then return end
	
	activeItem = entry;
	BuffHead.Setup.EffectCache.CreateContextMenu();
		
end

function BuffHead.Setup.EffectCache.OnPopulate()

	if (not BuffHeadSetupEffectCacheWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
	
end

function BuffHead.Setup.EffectCache.UpdateSearch(elapsed)

	searchTime = searchTime + elapsed;
	
	if (searchTime > SEARCH_DELAY) then
		SetupEntries();
		
		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "BuffHead.Setup.EffectCache.UpdateSearch");
		searchRegistered = false;
	end

end

function BuffHead.Setup.EffectCache.OnSearchChanged()
	
	searchTime = 0;

	if (not searchRegistered) then
		searchRegistered = true;
		RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "BuffHead.Setup.EffectCache.UpdateSearch");
	end

end

function BuffHead.Setup.EffectCache.Cache(ability)

	local abilityId = ability.abilityId;
	if (not abilityId) then return end

	local duration = 0;

	if (not effectCache[abilityId]) then
		effectCache[abilityId] = { Count = 0, Data = {} };
	else
		duration = effectCache[abilityId].Data.duration;
	end
	
	for k, v in pairs(ability) do
		effectCache[abilityId].Data[k] = v;
	end
	
	effectCache[abilityId].Data.duration = math.max(duration, ability.duration);
	effectCache[abilityId].Count = effectCache[abilityId].Count + 1;

end

function BuffHead.Setup.EffectCache.OnEnableCachingLUp()
	
	local isChecked = ButtonGetPressedFlag(windowName .. "EnableCaching" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "EnableCaching" .. "Button", isChecked);
	
	BuffHeadContainer.EnableCaching(isChecked);

end

function BuffHead.Setup.EffectCache.OnRefreshLClick()

	SetupEntries();

end

function BuffHead.Setup.EffectCache.OnResetLClick()
	
	effectCache = {};
	SetupEntries();
	
end
