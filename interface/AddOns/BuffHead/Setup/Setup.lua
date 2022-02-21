BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.WindowName = "BuffHeadSetupMenuWindow";
BuffHead.Setup.ActiveWindow = nil;
BuffHead.Setup.Entries = {};

local windowName = BuffHead.Setup.WindowName;
local localization = BuffHead.Localization.GetMapping();
	
local activeRow = nil;
local activeRowItem = nil;

local function TintRow(rowName, isActive)
	local id = WindowGetId(rowName);
	local entry = BuffHead.Setup.Entries[id];
		
	if (isActive and entry.Function) then
		WindowSetTintColor(rowName .. "Background", 12, 47, 158);
		WindowSetAlpha(rowName .. "Background", 0.4);
	else
		WindowSetAlpha(rowName .. "Background", 0);
	end
end

local function TintRows()
	for rowIndex, dataIndex in ipairs(BuffHeadSetupMenuWindowList.PopulatorIndices) do
		local rowName = windowName .. "ListRow" .. rowIndex;
		WindowSetId(rowName, dataIndex);
		
		local entry = BuffHead.Setup.Entries[dataIndex];
		
		LabelSetFont(rowName .. "Text", entry.Font or "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
		
		TintRow(rowName, (rowName == activeRow));
	end
end

local function MenuGeneral()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.General);
end

local function MenuDisplay()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.Display);
end

local function MenuContainer()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.Container);
end

local function MenuAdvancedContainers()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedContainers);
end

local function MenuPerformance()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.Performance);
end

local function MenuTrackers()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.Trackers);
end

local function MenuLayout()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.Layout);
end

local function MenuPriorityEffects()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.PriorityEffects);
end

local function MenuAdvancedCompression()
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedCompression);
end

local function SetupEntries()
	local menuItems =
	{
		{ Text = localization["Setup.Menu.General"], Font = "font_clear_small_bold" },
		{ Text = localization["Setup.Menu.General"], Function = MenuGeneral },
		{ Text = localization["Setup.Menu.Trackers"], Function = MenuTrackers },
		
		{ Text = localization["Setup.Menu.Display"], Font = "font_clear_small_bold" },
		{ Text = localization["Setup.Menu.Display"], Function = MenuDisplay },
		{ Text = localization["Setup.Menu.Containers"], Function = MenuContainer },
		{ Text = localization["Setup.Menu.Layout"], Function = MenuLayout },
		{ Text = localization["Setup.Menu.AdvancedContainers"], Function = MenuAdvancedContainers },
		
		{ Text = localization["Setup.Menu.Enhancements"], Font = "font_clear_small_bold" },
		{ Text = localization["Setup.Menu.Performance"], Function = MenuPerformance },
		{ Text = localization["Setup.Menu.PriorityEffects"], Function = MenuPriorityEffects },
		{ Text = localization["Setup.Menu.AdvancedCompression"], Function = MenuAdvancedCompression },
	};
	local entriesOrdered = {};
	
	for index, compressedEffect in ipairs(menuItems) do		
		menuItems[index].Index = index;
		if (menuItems[index].Function) then
			menuItems[index].Text = L"\t" .. menuItems[index].Text;
		end
        table.insert(entriesOrdered, index);
	end
	BuffHead.Setup.Entries = menuItems;
	ListBoxSetDisplayOrder(windowName .. "List", entriesOrdered);
end

function BuffHead.Setup.Initialize()

	BuffHead.Setup.SelectFont.Initialize();
	BuffHead.Setup.SelectColor.Initialize();
	BuffHead.Setup.SelectTexture.Initialize();
	
	BuffHead.Setup.General.Initialize();
	BuffHead.Setup.Filter.Initialize();
	BuffHead.Setup.Display.Initialize();
	BuffHead.Setup.Container.Initialize();
	BuffHead.Setup.Performance.Initialize();
	BuffHead.Setup.Trackers.Initialize();
	BuffHead.Setup.Layout.Initialize();
	BuffHead.Setup.AdvancedCompression.Initialize();
	BuffHead.Setup.AdvancedContainers.Initialize();
	BuffHead.Setup.PriorityEffects.Initialize();
	BuffHead.Setup.EffectCache.Initialize(); -- note this doesn't have a menu item

	LabelSetText(windowName .. "Label", localization["Setup.Menu.Title"]);
	
	SetupEntries();

end

function BuffHead.Setup.LoadSettings()

	BuffHead.Setup.General.LoadSettings();
	BuffHead.Setup.Filter.LoadSettings();
	BuffHead.Setup.Display.LoadSettings();
	BuffHead.Setup.Container.LoadSettings();
	BuffHead.Setup.Performance.LoadSettings();
	BuffHead.Setup.Trackers.LoadSettings();
	BuffHead.Setup.PriorityEffects.LoadSettings();
	
end

function BuffHead.Setup.SetActiveWindow(setupWindow)
	
	if (BuffHead.Setup.ActiveWindow == setupWindow) then return end

	if (BuffHead.Setup.ActiveWindow and BuffHead.Setup.ActiveWindow.WindowName) then
		--WindowClearAnchors(BuffHead.Setup.ActiveWindow.WindowName);	
		--WindowAddAnchor(BuffHead.Setup.ActiveWindow.WindowName, "center", "Root", "center", 0, 0);	
		BuffHead.Setup.ActiveWindow.Hide();
	end
	
	BuffHead.Setup.ActiveWindow = setupWindow;
	
	if (setupWindow and setupWindow.WindowName) then
		BuffHead.Setup.ActiveWindow.Show();
		
		local x, y = WindowGetScreenPosition(windowName);
		if (x == BuffHead.Setup.DefaultPosition.X and y == BuffHead.Setup.DefaultPosition.Y) then
			local width, height = WindowGetDimensions(setupWindow.WindowName);
			WindowClearAnchors(windowName);
			--WindowAddAnchor(windowName, "center", "Root", "topright", -(width / 2), -(height / 2));
			WindowAddAnchor(windowName, "center", "RootFrame", "topright", -(width / 2), -(height / 2));
		end
		
		WindowClearAnchors(setupWindow.WindowName);
		WindowAddAnchor(setupWindow.WindowName, "topright", windowName, "topleft", 0, 0);
	else
	
	end

end

function BuffHead.Setup.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowClearAnchors(windowName);
	--WindowAddAnchor(windowName, "center", "Root", "center", 0, 0);
	WindowAddAnchor(windowName, "center", "RootFrame", "center", 0, 0);

	local x, y = WindowGetScreenPosition(windowName);
	BuffHead.Setup.DefaultPosition = { X = x, Y = y };
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function BuffHead.Setup.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function BuffHead.Setup.OnHidden()

	BuffHead.Setup.SetActiveWindow();

end

function BuffHead.Setup.OnCloseLUp()
	BuffHead.Setup.Hide();
end

function BuffHead.Setup.OnPopulate()
	if (not BuffHeadSetupMenuWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
end

function BuffHead.Setup.OnRowMouseOver()
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
end

function BuffHead.Setup.OnRowMouseOut()
	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
end

function BuffHead.Setup.OnRowLDown()
	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
end

function BuffHead.Setup.OnRowLUp()
	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = BuffHead.Setup.Entries[id];
	if (not entry) then return end
	
	if (entry.Function) then
		entry.Function();
	end
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
end

function BuffHead.Setup.OnRowRDown()

end

function BuffHead.Setup.OnRowRUp()

end