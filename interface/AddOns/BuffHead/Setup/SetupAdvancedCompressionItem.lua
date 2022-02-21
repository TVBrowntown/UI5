BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.AdvancedCompressionItem = 
{
	WindowName = "BuffHeadSetupAdvancedCompressionItemWindow",
	Entries = {},
	Effects = {},
};
local this = BuffHead.Setup.AdvancedCompressionItem;

local windowName = BuffHead.Setup.AdvancedCompressionItem.WindowName;
local localization = BuffHead.Localization.GetMapping();

local existingItem = {};

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
	for rowIndex, dataIndex in ipairs(BuffHeadSetupAdvancedCompressionItemWindowList.PopulatorIndices) do
	
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

	return entryA.AbilityId < entryB.AbilityId;
end

local function SetupEntries()
	
	this.Entries = {};

	for index, effect in ipairs(this.Effects) do
		local effectText = towstring(effect.AbilityId);
		local effectType = nil;
		if (effect.Type == BuffHead.Compression.OnlyMine) then
			effectType = localization["Setup.AdvancedCompressionItemEffect.CastBy.Self"];
		elseif (effect.Type == BuffHead.Compression.OnlyOthers) then
			effectType = localization["Setup.AdvancedCompressionItemEffect.CastBy.Others"];
		elseif (effect.Type == BuffHead.Compression.All) then
			effectType = localization["Setup.AdvancedCompressionItemEffect.CastBy.Any"];
		end
		table.insert(this.Entries, 
			{
				Index = index,
				Text = effectText,
				Type = effectType,
				AbilityId = effect.AbilityId,
			});
	end
	
	this.UpdateList();
end

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

local function LoadItem(index)

	local item = nil;
	existingItem = { Index = index };
	this.Effects = {};
	
	if (index) then
		item = BuffHead.Settings.AdvancedCompression[index];
	end
	
	local name = L"";
	local overrideName = L"";
	local overrideIcon = L"";
	
	if (item) then
		--existing
		for index, effect in ipairs(item.Items) do
			table.insert(this.Effects, effect);
		end
		name = item.DisplayName or name;
		overrideName = item.Name or overrideName;
		overrideIcon = towstring(item.Icon or "");
	else
		--new
	end
	
	TextEditBoxSetText(windowName .. "NameEditBox", name);
	TextEditBoxSetText(windowName .. "OverrideNameEditBox", overrideName);
	TextEditBoxSetText(windowName .. "OverrideIconEditBox", overrideIcon);
	
	if (item) then
		ShowButtons(true, true);
	else
		ShowButtons(false, true);
	end
	
	SetupEntries();

end


function BuffHead.Setup.AdvancedCompressionItem.Initialize()
	BuffHead.Setup.AdvancedCompressionItemEffect.Initialize()
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.AdvancedCompressionItem.Title"]);
	LabelSetText(windowName .. "NameLabel", localization["Setup.AdvancedCompressionItem.Name"]);
	LabelSetText(windowName .. "OverrideLabel", localization["Setup.AdvancedCompressionItem.Override"]);
	LabelSetText(windowName .. "OverrideNameLabel", localization["Setup.AdvancedCompressionItem.Override.Name"]);
	LabelSetText(windowName .. "OverrideIconLabel", localization["Setup.AdvancedCompressionItem.Override.Icon"]);
	LabelSetText(windowName .. "EffectsLabel", localization["Setup.AdvancedCompressionItem.Effects"]);
	
	ButtonSetText(windowName .. "AddButton", localization["Setup.AdvancedCompressionItem.New"]);
	ButtonSetText(windowName .. "ApplyButton", localization["Setup.AdvancedCompressionItem.Apply"]);
	ButtonSetText(windowName .. "CreateButton", localization["Setup.AdvancedCompressionItem.Create"]);
	
	ShowButtons(false, true);
end

function BuffHead.Setup.AdvancedCompressionItem.LoadSettings()

end

function BuffHead.Setup.AdvancedCompressionItem.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.AdvancedCompressionItem.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.AdvancedCompressionItem.OnHidden()
	BuffHead.Setup.SetActiveWindow();
	BuffHead.Setup.AdvancedCompressionItemEffect.Hide();
end

function BuffHead.Setup.AdvancedCompressionItem.OnCloseLUp()
	this.Hide();
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedCompression);
end

function BuffHead.Setup.AdvancedCompressionItem.Update()
	SetupEntries();
end

function BuffHead.Setup.AdvancedCompressionItem.ShowNew()
	LoadItem(nil);
	this.Show();
end

function BuffHead.Setup.AdvancedCompressionItem.ShowEdit(index)
	LoadItem(index);
	this.Show();
end

function BuffHead.Setup.AdvancedCompressionItem.GetActiveItem()
	return existingItem or {};
end

function BuffHead.Setup.AdvancedCompressionItem.UpdateList()
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
	
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.AdvancedCompressionItem.Context.Remove"], this.OnContextMenuRemoveLUp, false, true);
	EA_Window_ContextMenu.Finalize();
end

function BuffHead.Setup.AdvancedCompressionItem.OnRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function BuffHead.Setup.AdvancedCompressionItem.OnRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function BuffHead.Setup.AdvancedCompressionItem.OnRowLDown()
	
	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.AdvancedCompressionItem.OnRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	BuffHead.Setup.AdvancedCompressionItemEffect.ShowEdit(entry.Index);
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
	
end

function BuffHead.Setup.AdvancedCompressionItem.OnRowRDown()
	
	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
	
end

function BuffHead.Setup.AdvancedCompressionItem.OnRowRUp()
	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = this.Entries[id];
	if (not entry) then return end
	
	activeRowItem = entry;
	CreateContextMenu();
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
end

function BuffHead.Setup.AdvancedCompressionItem.OnContextMenuRemoveLUp()
	if (activeRowItem) then		
		table.remove(this.Effects, activeRowItem.Index);
		activeRowItem = nil;
		BuffHead.Setup.AdvancedCompressionItemEffect.Hide();
		SetupEntries();
	end
end

function BuffHead.Setup.AdvancedCompressionItem.OnPopulate()
	if (not BuffHeadSetupAdvancedCompressionItemWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
end

function BuffHead.Setup.AdvancedCompressionItem.OnAddEffectLClick()
	BuffHead.Setup.AdvancedCompressionItemEffect.ShowNew();
end

local function SaveItem()
	local item = {};
	local name = TextEditBoxGetText(windowName .. "NameEditBox");
	local overrideName = TextEditBoxGetText(windowName .. "OverrideNameEditBox");
	local overrideIcon = tostring(TextEditBoxGetText(windowName .. "OverrideIconEditBox"));
	
	if (#this.Effects == 0) then return end
	
	if (overrideName:len() == 0) then
		overrideName = nil;
	end
	if (overrideIcon:len() == 0) then
		overrideIcon = nil;
	else
		if (tostring(tonumber(overrideIcon)) == overrideIcon) then
			overrideIcon = tonumber(overrideIcon);
		end
	end
	
	item.DisplayName = name;
	item.Name = overrideName;
	item.Icon = overrideIcon;
	item.Items = this.Effects;
	
	return item;
end

function BuffHead.Setup.AdvancedCompressionItem.OnApplyLClick()
	local item = SaveItem();
	if (item) then
		BuffHead.Settings.AdvancedCompression[existingItem.Index] = item;
		this.Hide();
		BuffHead.Setup.AdvancedCompression.Update();
		BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedCompression);
	end
end

function BuffHead.Setup.AdvancedCompressionItem.OnCreateLClick()
	local item = SaveItem();
	if (item) then
		table.insert(BuffHead.Settings.AdvancedCompression, item);
		this.Hide();
		BuffHead.Setup.AdvancedCompression.Update();
		BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedCompression);
	end
end