TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.Actionbar = 
{
	WindowName = "TexturedButtonsSetupActionbarWindow",
};

local windowName = TexturedButtons.Setup.Actionbar.WindowName;
local localization = TexturedButtons.Localization.GetMapping();

local activeBar = 1;
local selectorToIndex = { [ActionBarConstants.SHOW_PAGE_SELECTOR_RIGHT] = 1, [ActionBarConstants.SHOW_PAGE_SELECTOR_LEFT] = 2, [ActionBarConstants.HIDE_PAGE_SELECTOR] = 3 };
local indexToSelector = { ActionBarConstants.SHOW_PAGE_SELECTOR_RIGHT, ActionBarConstants.SHOW_PAGE_SELECTOR_LEFT, ActionBarConstants.HIDE_PAGE_SELECTOR };

function TexturedButtons.Setup.Actionbar.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Actionbar.Title"]);
	LabelSetText(windowName .. "EnableCheckboxLabel", localization["Setup.Actionbar.Enable"]);
	
	LabelSetText(windowName .. "ActionbarLabel", localization["Setup.Actionbar.Actionbar"]);
	LabelSetText(windowName .. "SelectorLabel", localization["Setup.Actionbar.Selector"]);
	LabelSetText(windowName .. "HideBackgroundCheckboxLabel", localization["Setup.Actionbar.HideBackground"]);
	LabelSetText(windowName .. "HideEmptyCheckboxLabel", localization["Setup.Actionbar.HideEmpty"]);
	
	LabelSetText(windowName .. "PaddingLabel", localization["Setup.Actionbar.Padding"]);
	LabelSetText(windowName .. "PaddingXLabel", localization["Setup.Actionbar.Padding.X"]);
	LabelSetText(windowName .. "PaddingYLabel", localization["Setup.Actionbar.Padding.Y"]);
	LabelSetText(windowName .. "SpacingLabel", localization["Setup.Actionbar.Spacing"]);
	LabelSetText(windowName .. "SpacingXLabel", localization["Setup.Actionbar.Spacing.X"]);
	LabelSetText(windowName .. "SpacingYLabel", localization["Setup.Actionbar.Spacing.Y"]);
	
	ComboBoxClearMenuItems(windowName .. "BarComboBox");
	for index = 1, CREATED_HOTBAR_COUNT do
		ComboBoxAddMenuItem(windowName .. "BarComboBox", towstring(string.format(tostring(localization["Setup.Actionbar.Bar"]), index)));
	end
	
	ComboBoxClearMenuItems(windowName .. "SelectorComboBox");
	ComboBoxAddMenuItem(windowName .. "SelectorComboBox", localization["Setup.Actionbar.Selector.Right"]);
	ComboBoxAddMenuItem(windowName .. "SelectorComboBox", localization["Setup.Actionbar.Selector.Left"]);
	ComboBoxAddMenuItem(windowName .. "SelectorComboBox", localization["Setup.Actionbar.Selector.Hide"]);
	
	TexturedButtons.Setup.Actionbar.LoadSettings();
	
end

local function LoadBar(index)
	
	activeBar = index;
	
	local settings = TexturedButtons.Settings;
	local clusterSettings = ActionBarClusterManager.m_Settings;
	
	if (not settings.Actionbars.Bar[index]) then
		settings.Actionbars.Bar[index] =
		{
			PageSelector = clusterSettings:GetActionBarSetting(index, "selector"),
			HideBackground = (clusterSettings:GetActionBarSetting(index, "background") ~= ActionBarConstants.SHOW_BACKGROUND),
			HideEmpty = (clusterSettings:GetActionBarSetting(index, "showEmptySlots") ~= ActionBarConstants.SHOW_EMPTY_SLOTS),
			Padding = 
			{
				X = clusterSettings:GetActionBarSetting(index, "buttonXPadding"),
				Y = clusterSettings:GetActionBarSetting(index, "buttonYPadding"),
			},
			Spacing = 
			{
				X = clusterSettings:GetActionBarSetting(index, "buttonXSpacing"),
				Y = clusterSettings:GetActionBarSetting(index, "buttonYSpacing"),
			},
		};
	end
	
	local bar = settings.Actionbars.Bar[index];
	
	ComboBoxSetSelectedMenuItem(windowName .. "SelectorComboBox", selectorToIndex[bar.PageSelector] or 3); 	
	ButtonSetPressedFlag(windowName .. "HideBackground" .. "Button", (bar.HideBackground == true));
	ButtonSetPressedFlag(windowName .. "HideEmpty" .. "Button", (bar.HideEmpty == true));
	TextEditBoxSetText(windowName .. "PaddingXEditBox", towstring(bar.Padding.X or 0));
	TextEditBoxSetText(windowName .. "PaddingYEditBox", towstring(bar.Padding.Y or 0));
	TextEditBoxSetText(windowName .. "SpacingXEditBox", towstring(bar.Spacing.X or 0));
	TextEditBoxSetText(windowName .. "SpacingYEditBox", towstring(bar.Spacing.Y or 0));
	
end

function TexturedButtons.Setup.Actionbar.LoadSettings()

	local settings = TexturedButtons.Settings;
	
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", (settings.Actionbars.Enabled == true));

	ComboBoxSetSelectedMenuItem(windowName .. "BarComboBox", 1);
	LoadBar(1);
	
end

function TexturedButtons.Setup.Actionbar.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.Actionbar.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.Actionbar.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.Actionbar.OnHidden()

	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.Actionbar.OnCloseLUp()

	TexturedButtons.Setup.Actionbar.Hide();

end

function TexturedButtons.Setup.Actionbar.OnEnableLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "Enable" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "Enable" .. "Button", isChecked);
	
	TexturedButtons.Settings.Actionbars.Enabled = isChecked;
	TexturedButtons.UpdateActionbars();
	
end

function TexturedButtons.Setup.Actionbar.OnBarChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "BarComboBox");
	LoadBar(value);
	
end

function TexturedButtons.Setup.Actionbar.OnSelectorChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "SelectorComboBox");
	
	TexturedButtons.Settings.Actionbars.Bar[activeBar].PageSelector = indexToSelector[3];
	TexturedButtons.UpdateActionbars(activeBar);
	
end

function TexturedButtons.Setup.Actionbar.OnHideBackgroundLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideBackground" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideBackground" .. "Button", isChecked);
	
	TexturedButtons.Settings.Actionbars.Bar[activeBar].HideBackground = isChecked;
	TexturedButtons.UpdateActionbars(activeBar);
	
end

function TexturedButtons.Setup.Actionbar.OnHideEmptyLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "HideEmpty" .. "Button") == false;
	ButtonSetPressedFlag(windowName .. "HideEmpty" .. "Button", isChecked);
	
	TexturedButtons.Settings.Actionbars.Bar[activeBar].HideEmpty = isChecked;
	TexturedButtons.UpdateActionbars(activeBar);

end

function TexturedButtons.Setup.Actionbar.OnPaddingXChanged()

	local value = tonumber(TextEditBoxGetText(windowName .. "PaddingXEditBox"));
	
	TexturedButtons.Settings.Actionbars.Bar[activeBar].Padding.X = value;
	TexturedButtons.UpdateActionbars(activeBar);

end

function TexturedButtons.Setup.Actionbar.OnPaddingYChanged()

	local value = tonumber(TextEditBoxGetText(windowName .. "PaddingYEditBox"));
		
	TexturedButtons.Settings.Actionbars.Bar[activeBar].Padding.Y = value;
	TexturedButtons.UpdateActionbars(activeBar);

end

function TexturedButtons.Setup.Actionbar.OnSpacingXChanged()

	local value = tonumber(TextEditBoxGetText(windowName .. "SpacingXEditBox"));
		
	TexturedButtons.Settings.Actionbars.Bar[activeBar].Spacing.X = value;
	TexturedButtons.UpdateActionbars(activeBar);

end

function TexturedButtons.Setup.Actionbar.OnSpacingYChanged()

	local value = tonumber(TextEditBoxGetText(windowName .. "SpacingYEditBox"));
		
	TexturedButtons.Settings.Actionbars.Bar[activeBar].Spacing.Y = value;
	TexturedButtons.UpdateActionbars(activeBar);

end