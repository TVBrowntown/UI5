TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.WindowName = "TexturedButtonsSetupMenuWindow";
TexturedButtons.Setup.ActiveWindow = nil;
TexturedButtons.Setup.Entries = {};

local windowName = TexturedButtons.Setup.WindowName;
local localization = TexturedButtons.Localization.GetMapping();
	
local activeRow = nil;
local activeRowItem = nil;

local function TintRow(rowName, isActive)
	local id = WindowGetId(rowName);
	local entry = TexturedButtons.Setup.Entries[id];
		
	if (isActive and entry.Function) then
		WindowSetTintColor(rowName .. "Background", 12, 47, 158);
		WindowSetAlpha(rowName .. "Background", 0.4);
	else
		WindowSetAlpha(rowName .. "Background", 0);
	end
end

local function TintRows()
	for rowIndex, dataIndex in ipairs(TexturedButtonsSetupMenuWindowList.PopulatorIndices) do
		local rowName = windowName .. "ListRow" .. rowIndex;
		WindowSetId(rowName, dataIndex);
		
		local entry = TexturedButtons.Setup.Entries[dataIndex];
		
		LabelSetFont(rowName .. "Text", entry.Font or "font_clear_small", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
		
		TintRow(rowName, (rowName == activeRow));
	end
end

local function MenuTextures()
	TexturedButtons.Setup.SetActiveWindow(TexturedButtons.Setup.Textures);
end

local function MenuAdvancedTextures()
	TexturedButtons.Setup.SetActiveWindow(TexturedButtons.Setup.AdvancedTextures);
end

local function MenuCooldown()
	TexturedButtons.Setup.SetActiveWindow(TexturedButtons.Setup.Cooldown);
end

local function MenuFonts()
	TexturedButtons.Setup.SetActiveWindow(TexturedButtons.Setup.Fonts);
end

local function MenuTint()
	TexturedButtons.Setup.SetActiveWindow(TexturedButtons.Setup.Tint);
end

local function MenuMisc()
	TexturedButtons.Setup.SetActiveWindow(TexturedButtons.Setup.Misc);
end

local function MenuActionbars()
	TexturedButtons.Setup.SetActiveWindow(TexturedButtons.Setup.Actionbar);
end

local function SetupEntries()	
	local menuItems =
	{
		{ Text = localization["Setup.Menu.Textures"], Font = "font_clear_small_bold" },
		{ Text = localization["Setup.Menu.Textures"], Function = MenuTextures },
		{ Text = localization["Setup.Menu.Advanced"], Function = MenuAdvancedTextures },
		
		{ Text = localization["Setup.Menu.Display"], Font = "font_clear_small_bold" },
		{ Text = localization["Setup.Menu.Actionbar"], Function = MenuActionbars },
		{ Text = localization["Setup.Menu.Cooldown"], Function = MenuCooldown },
		{ Text = localization["Setup.Menu.Fonts"], Function = MenuFonts },
		{ Text = localization["Setup.Menu.Tint"], Function = MenuTint },
		{ Text = localization["Setup.Menu.Misc"], Function = MenuMisc },
	};
	local entriesOrdered = {};
	
	for index, compressedEffect in ipairs(menuItems) do		
		menuItems[index].Index = index;
		if (menuItems[index].Function) then
			menuItems[index].Text = L"\t" .. menuItems[index].Text;
		end
        table.insert(entriesOrdered, index);
	end
	TexturedButtons.Setup.Entries = menuItems;
	ListBoxSetDisplayOrder(windowName .. "List", entriesOrdered);
end

function TexturedButtons.Setup.Initialize()

	TexturedButtons.Setup.SelectFont.Initialize();
	TexturedButtons.Setup.SelectColor.Initialize();
	
	TexturedButtons.Setup.Textures.Initialize();
	TexturedButtons.Setup.AdvancedTextures.Initialize();
	TexturedButtons.Setup.Cooldown.Initialize();
	TexturedButtons.Setup.Fonts.Initialize();
	TexturedButtons.Setup.Tint.Initialize();
	TexturedButtons.Setup.Misc.Initialize();
	TexturedButtons.Setup.Actionbar.Initialize();

	LabelSetText(windowName .. "Label", localization["Setup.Menu.Title"]);
	SetupEntries();

end

function TexturedButtons.Setup.LoadSettings()

	TexturedButtons.Setup.Textures.LoadSettings();
	TexturedButtons.Setup.AdvancedTextures.LoadSettings();
	TexturedButtons.Setup.Cooldown.LoadSettings();
	TexturedButtons.Setup.Fonts.LoadSettings();
	TexturedButtons.Setup.Tint.LoadSettings();
	TexturedButtons.Setup.Misc.LoadSettings();
	TexturedButtons.Setup.Actionbar.LoadSettings();
	
end

function TexturedButtons.Setup.SetActiveWindow(setupWindow)
	
	if (TexturedButtons.Setup.ActiveWindow == setupWindow) then return end

	if (TexturedButtons.Setup.ActiveWindow and TexturedButtons.Setup.ActiveWindow.WindowName) then
		TexturedButtons.Setup.ActiveWindow.Hide();
	end
	
	TexturedButtons.Setup.ActiveWindow = setupWindow;
	
	if (setupWindow and setupWindow.WindowName) then
		TexturedButtons.Setup.ActiveWindow.Show();
		
		local x, y = WindowGetScreenPosition(windowName);
		if (x == TexturedButtons.Setup.DefaultPosition.X and y == TexturedButtons.Setup.DefaultPosition.Y) then
			local width, height = WindowGetDimensions(setupWindow.WindowName);
			WindowClearAnchors(windowName);
			WindowAddAnchor(windowName, "center", "Root", "topright", -(width / 2), -(height / 2));
		end
		
		WindowClearAnchors(setupWindow.WindowName);
		WindowAddAnchor(setupWindow.WindowName, "topright", windowName, "topleft", 0, 0);
	else
	
	end

end

function TexturedButtons.Setup.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, "center", "Root", "center", 0, 0);

	local x, y = WindowGetScreenPosition(windowName);
	TexturedButtons.Setup.DefaultPosition = { X = x, Y = y };
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.OnHidden()

	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.OnCloseLUp()

	TexturedButtons.Setup.Hide();

end

function TexturedButtons.Setup.OnPopulate()
	if (not TexturedButtonsSetupMenuWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
end

function TexturedButtons.Setup.OnRowMouseOver()
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
end

function TexturedButtons.Setup.OnRowMouseOut()
	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
end

function TexturedButtons.Setup.OnRowLDown()
	if (activeRow) then
		WindowSetTintColor(activeRow .. "Background", 12, 47, 198);
	end
end

function TexturedButtons.Setup.OnRowLUp()
	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = TexturedButtons.Setup.Entries[id];
	if (not entry) then return end
	
	if (entry.Function) then
		entry.Function();
	end
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
end

function TexturedButtons.Setup.OnRowRDown()

end

function TexturedButtons.Setup.OnRowRUp()

end