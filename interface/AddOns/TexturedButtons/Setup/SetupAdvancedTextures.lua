TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.AdvancedTextures = 
{
	WindowName = "TexturedButtonsSetupAdvancedTexturesWindow",
};

local windowName = TexturedButtons.Setup.AdvancedTextures.WindowName;
local localization = TexturedButtons.Localization.GetMapping();

local presetToIndex = {};
local indexToPreset = {};
local indexToButtonState = { Button.ButtonState.NORMAL, Button.ButtonState.HIGHLIGHTED, Button.ButtonState.PRESSED, Button.ButtonState.PRESSED_HIGHLIGHTED };
local buttonStateToIndex = { [Button.ButtonState.NORMAL] = 1, [Button.ButtonState.HIGHLIGHTED] = 2, [Button.ButtonState.PRESSED] = 3, [Button.ButtonState.PRESSED_HIGHLIGHTED] = 4 };
local indexToTexture = {};
local textureToIndex = {};
local sliceToIndex = {};
local indexToSlice = {};
local lockUpdate = false;

local Tabs = { Preset = "Preset", Custom = "Custom" };
local ButtonState = { Normal = 1, Highlighted = 2, Pressed = 3, PressedHighlighted = 4 };
local activeTab = nil;
local activeButtonState = ButtonState.Normal;
local activeSlotType = 1;

local function HasSlices(texture)

	if (not TexturedButtons.Textures[texture] or not TexturedButtons.Textures[texture].Slices) then
		return false;
	end

	for textureName, _ in pairs(TexturedButtons.Textures[texture].Slices) do
		return true;
	end
	
	return false;

end

local function SetupDefaults(settings)
	if (not settings.Preset) then
		settings.Preset = { Name = "Gloss", Enabled = false };
	end
	
	if (not settings.Custom) then
		settings.Custom = 
		{ 
			Enabled = false,
			State = 
			{
				[Button.ButtonState.NORMAL] = { Texture = "TexturedButtons_Gloss" },
				[Button.ButtonState.HIGHLIGHTED] = { Texture = "TexturedButtons_Gloss" },
				[Button.ButtonState.PRESSED] = { Texture = "TexturedButtons_Gloss_Down" },
				[Button.ButtonState.PRESSED_HIGHLIGHTED] = { Texture = "TexturedButtons_Gloss" },
			},
		};
	end
end

local function LoadPresets()

	local index = 1;
	ComboBoxClearMenuItems(windowName .. "PresetComboBox");
	
	presetToIndex = {};
	indexToPreset = {};
	
	local sortedPresets = {};
	
	for presetName, _ in pairs(TexturedButtons.Preset) do
		table.insert(sortedPresets, presetName);
	end
	
	table.sort(sortedPresets);
	
	for _, presetName in ipairs(sortedPresets) do
	
		ComboBoxAddMenuItem(windowName .. "PresetComboBox", towstring(presetName));
		
		presetToIndex[presetName] = index;
		indexToPreset[index] = presetName;
	
		index = index + 1;
	
	end
	
end

local function LoadTextures()

	local index = 1;
	ComboBoxClearMenuItems(windowName .. "CustomTextureComboBox");
	
	textureToIndex = {};
	indexToTexture = {};
	
	local sortedTextures = {};
	
	for textureName, _ in pairs(TexturedButtons.Textures) do
		table.insert(sortedTextures, textureName);
	end
	
	table.sort(sortedTextures);
	
	for _, textureName in ipairs(sortedTextures) do
	
		local displayName = string.match(textureName, "TexturedButtons_(.*)") or textureName; -- To remove the TexturedButtons_ prefix
		ComboBoxAddMenuItem(windowName .. "CustomTextureComboBox", towstring(displayName));
		
		textureToIndex[textureName] = index;
		indexToTexture[index] = textureName;
	
		index = index + 1;
	
	end

end

function TexturedButtons.Setup.AdvancedTextures.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.AdvancedTextures.Title"]);
	LabelSetText(windowName .. "SelectBarLabel", localization["Setup.AdvancedTextures.SelectBar"]);
	
	ComboBoxClearMenuItems(windowName .. "SlotTypeComboBox");
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox", towstring(tostring(localization["Setup.AdvancedTextures.Bars.Actionbar"]):format(1)));
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox", towstring(tostring(localization["Setup.AdvancedTextures.Bars.Actionbar"]):format(2)));
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox", towstring(tostring(localization["Setup.AdvancedTextures.Bars.Actionbar"]):format(3)));
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox", towstring(tostring(localization["Setup.AdvancedTextures.Bars.Actionbar"]):format(4)));
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox", towstring(tostring(localization["Setup.AdvancedTextures.Bars.Actionbar"]):format(5)));
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox",localization["Setup.AdvancedTextures.Bars.Stance"]);
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox",localization["Setup.AdvancedTextures.Bars.Granted"]);
	ComboBoxAddMenuItem(windowName .. "SlotTypeComboBox",localization["Setup.AdvancedTextures.Bars.Pet"]);
	ComboBoxSetSelectedMenuItem(windowName .. "SlotTypeComboBox", 1);
	
	LabelSetText(windowName .. "UseCustomCheckboxLabel", localization["Setup.Textures.UseCustom"]);
	LabelSetText(windowName .. "UsePresetCheckboxLabel", localization["Setup.Textures.UsePreset"]);
	LabelSetText(windowName .. "DisabledCheckboxLabel", localization["Setup.Textures.Disabled"]);
	
	LabelSetText(windowName .. "PresetNameLabel", localization["Setup.Textures.Preset.Name"]);
	LabelSetText(windowName .. "PresetAuthorLabel", localization["Setup.Textures.Preset.Author"]);
	LabelSetText(windowName .. "PresetDescriptionLabel", localization["Setup.Textures.Preset.Description"]);
	
	LabelSetText(windowName .. "CustomButtonLabel", localization["Setup.Textures.Custom.Button"]);
	LabelSetText(windowName .. "CustomTextureLabel", localization["Setup.Textures.Custom.Texture"]);
	LabelSetText(windowName .. "CustomTextureNameLabel", localization["Setup.Textures.Custom.Name"]);
	LabelSetText(windowName .. "CustomTextureExampleLabel", localization["Setup.Textures.Custom.Example"]);
	
	ComboBoxClearMenuItems(windowName .. "CustomButtonComboBox");
	ComboBoxAddMenuItem(windowName .. "CustomButtonComboBox", localization["Setup.Textures.ButtonState.Normal"]);
	ComboBoxAddMenuItem(windowName .. "CustomButtonComboBox", localization["Setup.Textures.ButtonState.Highlighted"]);
	ComboBoxAddMenuItem(windowName .. "CustomButtonComboBox", localization["Setup.Textures.ButtonState.Pressed"]);
	ComboBoxAddMenuItem(windowName .. "CustomButtonComboBox", localization["Setup.Textures.ButtonState.PressedHighlighted"]);
	
	TexturedButtons.Setup.AdvancedTextures.LoadSettings();
	
end

local function SetTab(tab)

	if (tab and activeTab == tab) then return end;
	activeTab = tab;

	for _, name in pairs(Tabs) do
		WindowSetShowing(windowName .. name, (tab == name));
	end

end

local function LoadSlices(texture)

	local index = 1;
	ComboBoxClearMenuItems(windowName .. "CustomTextureSliceComboBox");
	
	sliceToIndex = {};
	indexToSlice = {};

	local sortedTextures = {};
	
	for textureName, _ in pairs(TexturedButtons.Textures[texture].Slices) do
		table.insert(sortedTextures, textureName);
	end
	
	table.sort(sortedTextures);
	
	for _, textureName in ipairs(sortedTextures) do
	
		ComboBoxAddMenuItem(windowName .. "CustomTextureSliceComboBox", towstring(textureName));
		
		sliceToIndex[textureName] = index;
		indexToSlice[index] = textureName;
	
		index = index + 1;
	
	end
	
end

local function LoadButtonState(buttonState)

	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	activeButtonState = buttonState;
	local buttonTexture = nil;
	
	local index = 1;
	if (settings.Custom and settings.Custom.State) then
		settings.Custom.State[indexToButtonState[buttonState]] = settings.Custom.State[indexToButtonState[buttonState]] or {};
		buttonTexture = settings.Custom.State[indexToButtonState[buttonState]];
		
		if (buttonTexture.Texture) then
			index = textureToIndex[buttonTexture.Texture] or 1;
		else
			buttonTexture.Texture = indexToTexture[index];
			buttonTexture.Slice = nil;
		end
	end
	
	ComboBoxSetSelectedMenuItem(windowName .. "CustomTextureComboBox", index);
	
	if (buttonTexture and buttonTexture.Slice and HasSlices(buttonTexture.Texture)) then
		LoadSlices(buttonTexture.Texture);
		WindowSetShowing(windowName .. "CustomTextureSliceComboBox", true);
		ComboBoxSetSelectedMenuItem(windowName .. "CustomTextureSliceComboBox", sliceToIndex[buttonTexture.Slice] or 1);
		TexturedButtons.Setup.AdvancedTextures.OnCustomTextureSliceChanged();
	else
		TexturedButtons.Setup.AdvancedTextures.OnCustomTextureChanged();
	end

end

local function LoadPreset(presetName)
	
	local author = L"";
	local description = L"";
	
	if (presetName and TexturedButtons.Preset[presetName]) then
		local preset = TexturedButtons.Preset[presetName];
		author = towstring(preset.Author or "");
		if (author == L"") then
			author = L"Unknown";
		end
		description = towstring(preset.Description or "");
		if (description == L"") then
			description = L"Not available";
		end
	end	
	
	LabelSetText(windowName .. "PresetAuthor", author);
	LabelSetText(windowName .. "PresetDescription", description);

end

local function LoadAdvancedTexturePreset()

	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	local presetName = (settings.Preset and settings.Preset.Name) or "Gloss";
	local presetIndex = (presetToIndex[presetName] or 1);
	ComboBoxSetSelectedMenuItem(windowName .. "PresetComboBox", presetIndex);
	
	LoadPreset(indexToPreset[presetIndex]);
	
end

local function LoadAdvancedTextureCustom()

	LoadButtonState(ButtonState.Normal);
	ComboBoxSetSelectedMenuItem(windowName .. "CustomButtonComboBox", 1);
	
end

local function LoadAdvancedTexture()

	TexturedButtons.Settings.AdvancedTextures[activeSlotType] = TexturedButtons.Settings.AdvancedTextures[activeSlotType] or {};
	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", false);
	
	if (settings.Preset and settings.Preset.Enabled) then
		LoadAdvancedTexturePreset();
		ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", true);
		SetTab(Tabs.Preset);
	elseif (settings.Preset and settings.Custom.Enabled) then
		LoadAdvancedTextureCustom();
		ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", true);
		SetTab(Tabs.Custom);
	else
		ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", true);
		SetTab(nil);
	end
	
end

function TexturedButtons.Setup.AdvancedTextures.LoadSettings()

	lockUpdate = true;
	LoadPresets();
	LoadTextures();
	LoadAdvancedTexture();
	lockUpdate = false;

end

function TexturedButtons.Setup.AdvancedTextures.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.AdvancedTextures.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.AdvancedTextures.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.AdvancedTextures.OnHidden()

	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.AdvancedTextures.OnCloseLUp()

	TexturedButtons.Setup.AdvancedTextures.Hide();

end

function TexturedButtons.Setup.AdvancedTextures.OnUsePresetLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "UsePreset" .. "Button") == false;
	if (not isChecked) then return end
	
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", isChecked);
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", false);
	SetTab(Tabs.Preset);
	
	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	SetupDefaults(settings);
	
	settings.Preset.Enabled = true;
	settings.Custom.Enabled = false;
	
	LoadAdvancedTexturePreset();
	
	TexturedButtons.UpdateSettings();
	
end

function TexturedButtons.Setup.AdvancedTextures.OnUseCustomLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "UseCustom" .. "Button") == false;
	if (not isChecked) then return end
	
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", isChecked);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", false);
	SetTab(Tabs.Custom);
	
	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	SetupDefaults(settings);
	
	settings.Preset.Enabled = false;
	settings.Custom.Enabled = true;
	
	LoadAdvancedTextureCustom();
	
	TexturedButtons.UpdateSettings();
			
end

function TexturedButtons.Setup.AdvancedTextures.OnDisabledLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "Disabled" .. "Button") == false;
	if (not isChecked) then return end
	
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", isChecked);
	SetTab(nil);
	
	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	settings.Preset = nil;
	settings.Custom = nil;
	
	TexturedButtons.UpdateSettings();
			
end

function TexturedButtons.Setup.AdvancedTextures.OnPresetChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "PresetComboBox");
	
	LoadPreset(indexToPreset[value]);
	if (not lockUpdate) then
		local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
		settings.Preset.Name = indexToPreset[value];
		TexturedButtons.UpdateSettings();
	end
	
end

function TexturedButtons.Setup.AdvancedTextures.OnCustomChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CustomButtonComboBox");
	
	LoadButtonState(value);
	
end

function TexturedButtons.Setup.AdvancedTextures.OnCustomTextureChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CustomTextureComboBox");
	local texture = indexToTexture[value];
	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	
	if (HasSlices(texture)) then
		LoadSlices(texture);
		WindowSetShowing(windowName .. "CustomTextureSliceComboBox", true);
		ComboBoxSetSelectedMenuItem(windowName .. "CustomTextureSliceComboBox", 1);
		TexturedButtons.Setup.AdvancedTextures.OnCustomTextureSliceChanged();
		return;
	else
		WindowSetShowing(windowName .. "CustomTextureSliceComboBox", false);
	end

	DynamicImageSetTexture(windowName .. "CustomIcon", texture or "EA_TintableImage", 0, 0);
	LabelSetText(windowName .. "CustomTextureName", towstring(texture or ""));
	
	if (not lockUpdate) then
		settings.Custom.State[indexToButtonState[activeButtonState]] = { Texture = texture };
		TexturedButtons.UpdateSettings();
	end

end

function TexturedButtons.Setup.AdvancedTextures.OnCustomTextureSliceChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CustomTextureComboBox");
	local texture = indexToTexture[value];
	local settings = TexturedButtons.Settings.AdvancedTextures[activeSlotType];
	
	value = ComboBoxGetSelectedMenuItem(windowName .. "CustomTextureSliceComboBox");
	local slice = indexToSlice[value];
	
	if (not slice) then return end

	DynamicImageSetTexture(windowName .. "CustomIcon", texture or "EA_TintableImage", 0, 0);
	DynamicImageSetTextureSlice(windowName .. "CustomIcon", slice or "");
	LabelSetText(windowName .. "CustomTextureName", towstring(texture or "" .. " " .. slice or ""));
	
	if (not lockUpdate) then
		settings.Custom.State[indexToButtonState[activeButtonState]] = { Texture = texture, Slice = slice };
		TexturedButtons.UpdateSettings();
	end

end

function TexturedButtons.Setup.AdvancedTextures.OnSlotTypeChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "SlotTypeComboBox");
	activeSlotType = value;
	LoadAdvancedTexture();
end