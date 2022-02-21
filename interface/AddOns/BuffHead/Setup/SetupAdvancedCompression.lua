BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.AdvancedCompression = 
{
	WindowName = "BuffHeadSetupAdvancedCompressionWindow",
	Entries = {},
};
local this = BuffHead.Setup.AdvancedCompression;

local windowName = BuffHead.Setup.AdvancedCompression.WindowName;
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
	for rowIndex, dataIndex in ipairs(BuffHeadSetupAdvancedCompressionWindowList.PopulatorIndices) do
	
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
	
	for index, compressedEffect in ipairs(BuffHead.Settings.AdvancedCompression) do
		local text = L"";
		local count = math.min(10, #compressedEffect.Items);
		
		for index = 1, count do
			text = text .. towstring(compressedEffect.Items[index].AbilityId);
			if (index < count) then
				text = text .. L", ";
			elseif (index < #compressedEffect.Items) then
				text = text .. L", ...";
			end
		end
		
		table.insert(this.Entries, 
			{
				Index = index,
				Text = compressedEffect.DisplayName,
				Effects = text,
			});
	end
	
	this.UpdateList();
end

function BuffHead.Setup.AdvancedCompression.Initialize()
	BuffHead.Setup.AdvancedCompressionItem.Initialize();
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.AdvancedCompression.Title"]);
	LabelSetText(windowName .. "CompressedEffectsLabel", localization["Setup.AdvancedCompression.CompressedEffects"]);
	
	ButtonSetText(windowName .. "NewButton", localization["Setup.AdvancedCompression.New"]);
	
	SetupEntries();
end

function BuffHead.Setup.AdvancedCompression.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.AdvancedCompression.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.AdvancedCompression.OnHidden()
	BuffHead.Setup.SetActiveWindow();
	
	BuffHead.AdvancedCompression.Clear();
	BuffHead.AdvancedCompression.Load();
end

function BuffHead.Setup.AdvancedCompression.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.AdvancedCompression.UpdateList()
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
	
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.AdvancedCompression.Context.Remove"], this.OnContextMenuRemoveLUp, false, true);
	EA_Window_ContextMenu.Finalize();
end

function BuffHead.Setup.AdvancedCompression.OnRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function BuffHead.Setup.AdvancedCompression.OnRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function BuffHead.Setup.AdvancedCompression.OnRowLDown()

	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.AdvancedCompression.OnRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	BuffHead.Setup.AdvancedCompressionItem.ShowEdit(entry.Index);
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedCompressionItem);
	
end

function BuffHead.Setup.AdvancedCompression.OnRowRDown()

	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.AdvancedCompression.OnRowRUp()
	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	activeRowItem = entry;
	CreateContextMenu();
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
end

function BuffHead.Setup.AdvancedCompression.OnContextMenuRemoveLUp()
	if (activeRowItem) then		
		table.remove(BuffHead.Settings.AdvancedCompression, activeRowItem.Index);
		activeRowItem = nil;
		SetupEntries();
	end
end

function BuffHead.Setup.AdvancedCompression.OnPopulate()
	if (not BuffHeadSetupAdvancedCompressionWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
end

function BuffHead.Setup.AdvancedCompression.Update()
	SetupEntries();
	
	BuffHead.AdvancedCompression.Clear();
	BuffHead.AdvancedCompression.Load();
end

function BuffHead.Setup.AdvancedCompression.OnNewLClick()
	BuffHead.Setup.AdvancedCompressionItem.ShowNew()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedCompressionItem);
end