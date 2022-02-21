Obsidian = Obsidian or {};
Obsidian.Setup = Obsidian.Setup or {};
Obsidian.Setup.WindowName = "ObsidianSetupMenuWindow";
Obsidian.Setup.ActiveWindow = nil;

local windowName = Obsidian.Setup.WindowName;

local localization = Obsidian.Localization.GetMapping();

function Obsidian.Setup.Initialize()

	Obsidian.Setup.SelectFont.Initialize();
	Obsidian.Setup.SelectTexture.Initialize();
	Obsidian.Setup.SelectColor.Initialize();
	Obsidian.Setup.Castbar.Initialize();
	Obsidian.Setup.EffectTracker.Initialize();

	LabelSetText(windowName .. "Label", localization["Setup.Menu.Title"]);
	ButtonSetText(windowName .. "CastbarSetupButton", localization["Setup.Menu.Castbar"]);
	ButtonSetText(windowName .. "EffectTrackerSetupButton", localization["Setup.Menu.EffectTracker"]);

end

function Obsidian.Setup.LoadSettings()

	Obsidian.Setup.General.LoadSettings();
	Obsidian.Setup.Dialogs.Update();
	
end

function Obsidian.Setup.SetActiveWindow(setupWindow)
	
	if (Obsidian.Setup.ActiveWindow == setupWindow) then return end

	if (Obsidian.Setup.ActiveWindow and Obsidian.Setup.ActiveWindow.WindowName) then
		Obsidian.Setup.ActiveWindow.Hide();
	end
	
	Obsidian.Setup.ActiveWindow = setupWindow;
	
	if (setupWindow and setupWindow.WindowName) then
		Obsidian.Setup.ActiveWindow.Show();
		
		local x, y = WindowGetScreenPosition(windowName);
		if (x == Obsidian.Setup.DefaultPosition.X and y == Obsidian.Setup.DefaultPosition.Y) then
			local width, height = WindowGetDimensions(setupWindow.WindowName);
			WindowClearAnchors(windowName);
			WindowAddAnchor(windowName, "center", "Root", "topright", -(width / 2), -(height / 2));
		end
		
		WindowClearAnchors(setupWindow.WindowName);
		WindowAddAnchor(setupWindow.WindowName, "topright", windowName, "topleft", 0, 0);
	else
	
	end

end

--[[
function Obsidian.Setup.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, "center", "Root", "center", 0, 0);

	local x, y = WindowGetScreenPosition(windowName);
	Obsidian.Setup.DefaultPosition = { X = x, Y = y };
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, Obsidian.Setup.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end
]]

function Obsidian.Setup.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function Obsidian.Setup.OnHidden()

	Obsidian.Setup.SetActiveWindow();

end

function Obsidian.Setup.OnCloseLUp()

	Obsidian.Setup.Hide();

end

function Obsidian.Setup.OnCastbarSetupLUp()

	Obsidian.Setup.SetActiveWindow(Obsidian.Setup.Castbar);

end

function Obsidian.Setup.OnEffectTrackerSetupLUp()

	Obsidian.Setup.SetActiveWindow(Obsidian.Setup.EffectTracker);

end
