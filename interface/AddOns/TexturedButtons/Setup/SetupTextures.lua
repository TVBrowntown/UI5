TexturedButtons = TexturedButtons or {};
TexturedButtons.Setup = TexturedButtons.Setup or {};
TexturedButtons.Setup.Textures = 
{
	WindowName = "TexturedButtonsSetupTexturesWindow",
};

local windowName = TexturedButtons.Setup.Textures.WindowName;
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

local function OnSettingsChanged()
	if (lockUpdate) then return end
	TexturedButtons.UpdateSettings();
end

local function HasSlices(texture)

	if (not TexturedButtons.Textures[texture] or not TexturedButtons.Textures[texture].Slices) then
		return false;
	end

	for textureName, _ in pairs(TexturedButtons.Textures[texture].Slices) do
		return true;
	end
	
	return false;

end

function TexturedButtons.Setup.Textures.Initialize()

	LabelSetText(windowName .. "TitleLabel", localization["Setup.Textures.Title"]);
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
	
	TexturedButtons.Setup.Textures.LoadSettings();
	
end

local function SetTab(tab)

	if (activeTab == tab) then return end;
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

local function LoadButtonState(buttonState)

	local settings = TexturedButtons.Settings;
	activeButtonState = buttonState;
	local buttonTexture = nil;
	
	local index = 1;
	if (settings.Custom.State) then
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
		TexturedButtons.Setup.Textures.OnCustomTextureSliceChanged();
	else
		TexturedButtons.Setup.Textures.OnCustomTextureChanged();
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

function TexturedButtons.Setup.Textures.LoadSettings()

	lockUpdate = true;
	local settings = TexturedButtons.Settings;

	LoadPresets();
	LoadTextures();
	
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", false);
	
	local presetIndex = (presetToIndex[settings.Preset.Name] or 1);
	ComboBoxSetSelectedMenuItem(windowName .. "PresetComboBox", presetIndex);
	ComboBoxSetSelectedMenuItem(windowName .. "CustomButtonComboBox", ButtonState.Normal);
	LoadPreset(indexToPreset[presetIndex]);
	LoadButtonState(ButtonState.Normal);
	
	if (settings.Preset.Enabled) then
		ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", true);
		SetTab(Tabs.Preset);
	elseif (settings.Custom.Enabled) then
		ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", true);
		SetTab(Tabs.Custom);
	else
		ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", true);
		SetTab(Tabs.Preset);
	end
	lockUpdate = false;

end

function TexturedButtons.Setup.Textures.Show()

	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, TexturedButtons.Setup.Textures.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function TexturedButtons.Setup.Textures.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function TexturedButtons.Setup.Textures.OnHidden()

	TexturedButtons.Setup.SetActiveWindow();

end

function TexturedButtons.Setup.Textures.OnCloseLUp()

	TexturedButtons.Setup.Textures.Hide();

end

function TexturedButtons.Setup.Textures.OnUsePresetLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "UsePreset" .. "Button") == false;
	if (not isChecked) then return end
	
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", isChecked);
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", false);
	SetTab(Tabs.Preset);
	
	TexturedButtons.Settings.Preset.Enabled = true;
	TexturedButtons.Settings.Custom.Enabled = false;
	
	OnSettingsChanged();
	
end

function TexturedButtons.Setup.Textures.OnUseCustomLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "UseCustom" .. "Button") == false;
	if (not isChecked) then return end
	
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", isChecked);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", false);
	SetTab(Tabs.Custom);
	
	TexturedButtons.Settings.Preset.Enabled = false;
	TexturedButtons.Settings.Custom.Enabled = true;
	
	OnSettingsChanged();
			
end

function TexturedButtons.Setup.Textures.OnDisabledLUp()

	local isChecked = ButtonGetPressedFlag(windowName .. "Disabled" .. "Button") == false;
	if (not isChecked) then return end
	
	ButtonSetPressedFlag(windowName .. "UsePreset" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "UseCustom" .. "Button", false);
	ButtonSetPressedFlag(windowName .. "Disabled" .. "Button", isChecked);
	
	TexturedButtons.Settings.Preset.Enabled = false;
	TexturedButtons.Settings.Custom.Enabled = false;
	
	OnSettingsChanged();
	TexturedButtons.TexturizeDefaults();
			
end

function TexturedButtons.Setup.Textures.OnPresetChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "PresetComboBox");
	
	LoadPreset(indexToPreset[value]);
	if (not lockUpdate) then
		TexturedButtons.Settings.Preset.Name = indexToPreset[value];
		OnSettingsChanged();
	end
	
end

function TexturedButtons.Setup.Textures.OnCustomChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CustomButtonComboBox");
	
	LoadButtonState(value);
	
end

function TexturedButtons.Setup.Textures.OnCustomTextureChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CustomTextureComboBox");
	local texture = indexToTexture[value];
	
	if (HasSlices(texture)) then
		LoadSlices(texture);
		WindowSetShowing(windowName .. "CustomTextureSliceComboBox", true);
		ComboBoxSetSelectedMenuItem(windowName .. "CustomTextureSliceComboBox", 1);
		TexturedButtons.Setup.Textures.OnCustomTextureSliceChanged();
		return;
	else
		WindowSetShowing(windowName .. "CustomTextureSliceComboBox", false);
	end

	DynamicImageSetTexture(windowName .. "CustomIcon", texture or "EA_TintableImage", 0, 0);
	LabelSetText(windowName .. "CustomTextureName", towstring(texture or ""));
	
	if (not lockUpdate) then
		TexturedButtons.Settings.Custom.State[indexToButtonState[activeButtonState]] = { Texture = texture };		
		OnSettingsChanged();
	end

end

function TexturedButtons.Setup.Textures.OnCustomTextureSliceChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "CustomTextureComboBox");
	local texture = indexToTexture[value];
	
	value = ComboBoxGetSelectedMenuItem(windowName .. "CustomTextureSliceComboBox");
	local slice = indexToSlice[value];
	
	if (not slice) then return end

	DynamicImageSetTexture(windowName .. "CustomIcon", texture or "EA_TintableImage", 0, 0);
	DynamicImageSetTextureSlice(windowName .. "CustomIcon", slice or "");
	LabelSetText(windowName .. "CustomTextureName", towstring(texture or "" .. " " .. slice or ""));
	
	if (not lockUpdate) then
		TexturedButtons.Settings.Custom.State[indexToButtonState[activeButtonState]] = { Texture = texture, Slice = slice };
		OnSettingsChanged();
	end

end