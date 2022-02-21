BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.AdvancedContainers = 
{
	WindowName = "BuffHeadSetupAdvancedContainersWindow",
	Entries = {},
};
local this = BuffHead.Setup.AdvancedContainers;

local windowName = BuffHead.Setup.AdvancedContainers.WindowName;
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
	for rowIndex, dataIndex in ipairs(BuffHeadSetupAdvancedContainersWindowList.PopulatorIndices) do
	
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

	return (WStringsCompare(entryA.Text, entryB.Text) < 0);
end

local function SetupEntries()
	
	this.Entries = {};
	
	local targetTypeName = 
	{
		localization["Setup.Trackers.Tracker.Self"],
		localization["Setup.Trackers.Tracker.Group"],
		localization["Setup.Trackers.Tracker.Friendly"],
		localization["Setup.Trackers.Tracker.Hostile"],
	};
	
	local friendlyBuffs =
	{
		localization["Setup.Trackers.Friendly.Buffs.None"],
		localization["Setup.Trackers.Friendly.Buffs.CastByMe"],
		localization["Setup.Trackers.Friendly.Buffs.All"],
	};
	
	local friendlyDebuffs =
	{
		localization["Setup.Trackers.Friendly.Debuffs.None"],
		localization["Setup.Trackers.Friendly.Debuffs.CurableByMe"],
		localization["Setup.Trackers.Friendly.Debuffs.All"],
	};
	
	local hostileBuffs =
	{
		localization["Setup.Trackers.Hostile.Buffs.None"],
		localization["Setup.Trackers.Hostile.Buffs.RemovableByMe"],
		localization["Setup.Trackers.Hostile.Buffs.All"],
	};
	
	local hostileDebuffs =
	{
		localization["Setup.Trackers.Hostile.Debuffs.None"],
		localization["Setup.Trackers.Hostile.Debuffs.CastByMe"],
		localization["Setup.Trackers.Hostile.Debuffs.All"],
	};
	
	for index, container in ipairs(BuffHead.Settings.AdvancedContainers) do
		local text = targetTypeName[container.Type] or L"";
		local description = L"";
		
		if (container.ScreenPosition == BuffHead.ScreenPosition.Fixed) then
			text = text .. L" (" .. localization["Setup.AdvancedContainersItem.Position.Fixed"] .. L")";
		else
			text = text .. L" (" .. localization["Setup.AdvancedContainersItem.Position.Attached"] .. L")";
		end
		
		local descriptionFormat = tostring(localization["Setup.AdvancedContainers.BasicDescription"]);
		if (container.Type == BuffHead.TargetType.Self or container.Type == BuffHead.TargetType.Friendly) then
			description = towstring(descriptionFormat:format(tostring(friendlyBuffs[container.Buffs]), tostring(friendlyDebuffs[container.Debuffs])));
		else
			description = towstring(descriptionFormat:format(tostring(hostileBuffs[container.Buffs]), tostring(hostileDebuffs[container.Debuffs])));
		end
		
		table.insert(this.Entries, 
			{
				Index = index,
				Text = text,
				Description = description,
			});
	end
	
	this.UpdateList();
end

function BuffHead.Setup.AdvancedContainers.Initialize()
	BuffHead.Setup.AdvancedContainersItem.Initialize();
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.AdvancedContainers.Title"]);
	LabelSetText(windowName .. "CompressedEffectsLabel", localization["Setup.AdvancedContainers.CompressedEffects"]);
	
	ButtonSetText(windowName .. "NewButton", localization["Setup.AdvancedContainers.New"]);
	
	SetupEntries();
end

function BuffHead.Setup.AdvancedContainers.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.AdvancedContainers.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.AdvancedContainers.OnHidden()
	BuffHead.Setup.SetActiveWindow();
	
	BuffHead.SetTrackers();
	BuffHead.RefreshPlayerBuffs();
end

function BuffHead.Setup.AdvancedContainers.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.AdvancedContainers.UpdateList()
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
	
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.AdvancedContainers.Context.Remove"], this.OnContextMenuRemoveLUp, false, true);
	EA_Window_ContextMenu.Finalize();
end

function BuffHead.Setup.AdvancedContainers.OnRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function BuffHead.Setup.AdvancedContainers.OnRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function BuffHead.Setup.AdvancedContainers.OnRowLDown()

	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.AdvancedContainers.OnRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	BuffHead.Setup.AdvancedContainersItem.ShowEdit(entry.Index);
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedContainersItem);
	
end

function BuffHead.Setup.AdvancedContainers.OnRowRDown()

	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.AdvancedContainers.OnRowRUp()
	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	activeRowItem = entry;
	CreateContextMenu();
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
end

function BuffHead.Setup.AdvancedContainers.OnContextMenuRemoveLUp()
	if (activeRowItem) then		
		table.remove(BuffHead.Settings.AdvancedContainers, activeRowItem.Index);
		activeRowItem = nil;
		BuffHead.AdvancedContainers.Clear();
		BuffHead.AdvancedContainers.Load();
		SetupEntries();
	end
end

function BuffHead.Setup.AdvancedContainers.OnPopulate()
	if (not BuffHeadSetupAdvancedContainersWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
end

function BuffHead.Setup.AdvancedContainers.Update()
	SetupEntries();
	
	BuffHead.AdvancedContainers.Clear();
	BuffHead.AdvancedContainers.Load();
	BuffHead.RefreshPlayerBuffs();
end

function BuffHead.Setup.AdvancedContainers.OnNewLClick()
	BuffHead.Setup.AdvancedContainersItem.ShowNew()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedContainersItem);
end