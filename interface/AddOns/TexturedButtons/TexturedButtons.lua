TexturedButtons = TexturedButtons or {};
TexturedButtons.Textures = {};
TexturedButtons.Preset = {};
TexturedButtons.IsLoaded = false;
TexturedButtons.IsEnabled = true;

local VERSION_SETTINGS = 6;

-- Default values
local buttonTexture =
{
	Textures =
	{
		-- now using the default button textures as defaults instead of gloss
		Normal = "EA_SquareFrame",
		Highlighted = "EA_SquareFrame_Highlight",
		Pressed = "EA_SquareFrame_Pressed",
		PressedHighlighted = "",
	},
	Slices = {},
};
local buttonTextureForSlotType = nil;

local BASE_ICON = 0;
local BUTTON_TEXT = 1;
local COOLDOWN = 2;
local COOLDOWN_TIMER = 3;
local FLASH_ANIM = 4;
local ACTIVE_ANIM = 5;
local GLOW_ANIM = 6;
local STACK_COUNT_TEXT = 7;
local USE_ENABLED_ICON = 42;

local SlotType = { ActionBar1 = 1, ActionBar2 = 2, ActionBar3 = 3, ActionBar4 = 4, ActionBar5 = 5, Stance = 6, GrantedAbilities = 7, PetAbilities = 8 };
local CustomGlow = { None = 1, OnlyResized = 2, All = 3 };
local customGlow = CustomGlow.OnlyResized;
local forceResizeButtons = false;

local resizeButtonWindows = { BASE_ICON, COOLDOWN, COOLDOWN_TIMER, FLASH_ANIM, ACTIVE_ANIM, GLOW_ANIM };

local buttonSize = {};
local keybindOffset = {};
local hotbarUpdate = nil;
local buttonsUpdate = nil;
local settingsUpdate = nil;
local texturizeQueue = {};
local buttonAction = {};
local cooldownPulse = {};
local initialLoad = true;
local registerTexturesUpdate = nil;
local isLibSlashRegistered = false;
local isLibAddonButtonRegistered = false;

local isTargetValidOverride = nil; -- for witch elf kisses (remove all references of this when Mythic fixes it)

local oldSetActionBarSetting = nil;
local oldUpdateCooldownAnimation = nil;
local oldButtonCreate = nil;
local oldUpdateKeyBindingText = nil;
local oldUpdateEnabledState = nil;
local oldMoraleUpdate = nil;
local oldUpdateBurning = nil;
local oldSetPetCommands = nil;
local oldResetActionbarSettings = nil;
local oldActionButtonOnLButtonDown = nil;

local function RegisterLibs()
--[[	
	if (not isLibSlashRegistered) then
		if (LibSlash) then
			LibSlash.RegisterSlashCmd("texturedbuttons", function(args) TexturedButtons.SlashCommand(args) end);
			LibSlash.RegisterSlashCmd("tb", function(args) TexturedButtons.SlashCommand(args) end);
			isLibSlashRegistered = true;
		end
	end

	if (not isLibAddonButtonRegistered) then
		if (LibAddonButton) then
			LibAddonButton.Register("fx");
			LibAddonButton.AddMenuItem("fx", "TexturedButtons", TexturedButtons.Setup.Show);
			isLibAddonButtonRegistered = true;
		end
	end
]]
end

local function GetSlotType(slot)

	if (slot >= GameDefs.FIRST_GRANTED_ABILITY_SLOT and slot <= GameDefs.LAST_GRANTED_ABILITY_SLOT) then
		return SlotType.GrantedAbilities;
	end

	if (slot >= GameDefs.FIRST_PET_ABILITY_SLOT and slot <= GameDefs.LAST_PET_ABILITY_SLOT) then
		return SlotType.PetAbilities;
	end

	if (slot >= GameDefs.FIRST_STANCE_ABILITY_SLOT and slot <= GameDefs.LAST_STANCE_ABILITY_SLOT) then
		return SlotType.Stance;
	end

	for index = 1, 5 do
		if (slot >= GameData.HOTBAR_BUTTONS_PER_BAR * (index - 1) and slot <= GameData.HOTBAR_BUTTONS_PER_BAR * index) then
			return index;
		end
	end

end

local function OffsetKeybind(button, x, y)

	local keybindFrame = button.m_Windows[BUTTON_TEXT];
	local iconFrame = button.m_Windows[BASE_ICON];
	if (keybindFrame and iconFrame) then
		WindowClearAnchors(keybindFrame.m_Name)
		WindowAddAnchor(keybindFrame.m_Name, "topright", iconFrame.m_Name, "topright", x or -5, y or 5);
	end

end

local function CustomizeButtonGlow(button, width, height, x, y)

	local buttonName = button.m_Name .. "Action";
	local frame = button.m_Windows[GLOW_ANIM];
	
	if (customGlow == CustomGlow.All or (customGlow == CustomGlow.OnlyResized and width and height)) then
		-- glows in the bottom right corner
		-- note the animation will auto scale itself, but when the animation is refreshed, it's reset to 1
		local glowWidth = math.min(72, width or 72); -- slight offset of 8px, full would be 80px and -16 instead or 72 and -8
		local glowHeight = math.min(51, height or 51);
		local glowX = (x or -8) + (width or 72) - glowWidth;
		local glowY = (y or 0) + (height or 64) - glowHeight;
		
		WindowSetDimensions(frame.m_Name, glowWidth, glowHeight);
		WindowAddAnchor(frame.m_Name, "topleft", button.m_Name .. "Overlay", "topleft", glowX, glowY);
	else
		-- default glow location
		WindowSetDimensions(frame.m_Name, 80, 110);
		WindowAddAnchor(frame.m_Name, "center", button.m_Name .. "Overlay", "center", -8, -26);
	end
				
end

local function ResizeButton(button, width, height, x, y)

	local buttonName = button.m_Name .. "Action";
	
	for _, id in ipairs(resizeButtonWindows) do
		local frame = button.m_Windows[id];
		if (frame) then
			WindowClearAnchors(frame.m_Name)
			if (id == GLOW_ANIM) then
				CustomizeButtonGlow(button, width, height, x, y);
			else
				WindowSetDimensions(frame.m_Name, width or 64, height or 64);
				WindowAddAnchor(frame.m_Name, "topleft", buttonName, "topleft", x or 0, y or 0);
			end
		end
	end

end

local function LayoutButton(button, buttonTexture, sliceTexture)
	
	local texture = nil;
	if (sliceTexture) then
		texture = TexturedButtons.Textures[buttonTexture].Slices[sliceTexture];
	else
		texture = TexturedButtons.Textures[buttonTexture];
	end
	
	local slot = button.m_HotBarSlot;
	local resizeButton = false;
	local offsetKeybind = false;
	
	if (texture) then
		if (texture.Size) then
			buttonSize[slot] = buttonSize[slot] or { Width = 64, Height = 64 };
			local width, height = texture.Size.Width or 64, texture.Size.Height or 64;
			local x, y = texture.Size.X or 0, texture.Size.Y or 0;
			if (forceResizeButtons or buttonSize[slot].Width ~= width or buttonSize[slot].Height ~= height) then
				ResizeButton(button, width, height, x, y);
				buttonSize[slot] = { Width = width, Height = height };
			end 
			resizeButton = true;
		else
			if (forceResizeButtons) then
				ResizeButton(button);
				resizeButton = true;
			end
		end
		if (texture.KeybindOffset) then
			keybindOffset[slot] = keybindOffset[slot] or { X = -5, Y = 5 };
			local x, y = texture.KeybindOffset.X or -5, texture.KeybindOffset.Y or -5;
			if (keybindOffset[slot].X ~= x or keybindOffset[slot].Y ~= y) then
				OffsetKeybind(button, x, y);
				keybindOffset[slot] = { X = x, Y = y };
			end 
			offsetKeybind = true;
		end
	end
	
	if (not resizeButton and buttonSize[slot]) then
		ResizeButton(button);
		buttonSize[slot] = nil;
	end
	if (not offsetKeybind and keybindOffset[slot]) then
		OffsetKeybind(button);
		keybindOffset[slot] = nil;
	else
		if (resizeButton and not offsetKeybind) then
			OffsetKeybind(button);
		end
	end
end

local function SetButtonTexture(button, buttonState, buttonTexture, sliceTexture)

	local buttonName = button.m_Name .. "Action";

	if (buttonState == Button.ButtonState.NORMAL) then
		LayoutButton(button, buttonTexture, sliceTexture);
	end

	if (sliceTexture) then
    	ButtonSetTextureSlice(buttonName, buttonState, buttonTexture, sliceTexture);
	else
		ButtonSetTexture(buttonName, buttonState, buttonTexture or "", 0, 0);
	end

end

-- Sets the textures for the given button
function TexturedButtons.TexturizeButton(button, override)
	if (not TexturedButtons.IsLoaded or (not TexturedButtons.IsEnabled and not override)) then return end

	local texture = nil;
	if (buttonTextureForSlotType) then
		local slotType = GetSlotType(button.m_HotBarSlot);
		texture = buttonTextureForSlotType[slotType] or buttonTexture;
	else
		texture = buttonTexture;
	end

	SetButtonTexture(button, Button.ButtonState.NORMAL, texture.Textures.Normal, texture.Slices.Normal);
	SetButtonTexture(button, Button.ButtonState.HIGHLIGHTED, texture.Textures.Highlighted, texture.Slices.Highlighted);
	SetButtonTexture(button, Button.ButtonState.PRESSED, texture.Textures.Pressed, texture.Slices.Pressed);
	SetButtonTexture(button, Button.ButtonState.PRESSED_HIGHLIGHTED, texture.Textures.PressedHighlighted, texture.Slices.PressedHighlighted);
	
end

-- Texturizes every action bar button
function TexturedButtons.Texturize(override) 
	if (not TexturedButtons.IsLoaded or (not TexturedButtons.IsEnabled and not override)) then return end
	
	for barNum, barData in pairs(ActionBars.m_Bars) do
		for btnNum, btnData in ipairs(barData.m_Buttons) do
			TexturedButtons.TexturizeButton(btnData, override);
		end
	end
end

function TexturedButtons.TexturizeDefaults()
	
	buttonTexture =
	{
		Textures =
		{
			Normal = "EA_SquareFrame",
			Highlighted = "EA_SquareFrame_Highlight",
			Pressed = "EA_SquareFrame_Pressed",
			PressedHighlighted = "",
		},
		Slices = {},
	};
	
	TexturedButtons.Texturize(true);

end

function TexturedButtons.UpdateSettings()
	local settings = TexturedButtons.Settings;
	local isEnabled = false;
	
	if (settings.Preset.Enabled) then
		isEnabled = true;
		if (TexturedButtons.Preset[settings.Preset.Name] and TexturedButtons.Preset[settings.Preset.Name].Textures) then
			buttonTexture = TexturedButtons.Preset[settings.Preset.Name];
			buttonTexture.Slices = buttonTexture.Slices or {};
		end
	elseif (settings.Custom.Enabled) then
		isEnabled = true;
		if (settings.Custom.State) then
			local state = settings.Custom.State;
			buttonTexture = {
				Textures =
				{
					Normal = state[Button.ButtonState.NORMAL].Texture,
					Highlighted = state[Button.ButtonState.HIGHLIGHTED].Texture,
					Pressed = state[Button.ButtonState.PRESSED].Texture,
					PressedHighlighted = state[Button.ButtonState.PRESSED_HIGHLIGHTED].Texture,
				},
				Slices =
				{
					Normal = state[Button.ButtonState.NORMAL].Slice,
					Highlighted = state[Button.ButtonState.HIGHLIGHTED].Slice,
					Pressed = state[Button.ButtonState.PRESSED].Slice,
					PressedHighlighted = state[Button.ButtonState.PRESSED_HIGHLIGHTED].Slice,
				},
			};
		end
	end
	
	buttonTextureForSlotType = nil;
	for slotType, settings in pairs(settings.AdvancedTextures) do
		if (settings.Preset and settings.Preset.Enabled) then
			isEnabled = true;
			buttonTextureForSlotType = buttonTextureForSlotType or {};
			if (TexturedButtons.Preset[settings.Preset.Name] and TexturedButtons.Preset[settings.Preset.Name].Textures) then
				buttonTextureForSlotType[slotType] = TexturedButtons.Preset[settings.Preset.Name];
				buttonTextureForSlotType[slotType].Slices = buttonTextureForSlotType[slotType].Slices or {};
			end
		elseif (settings.Custom and settings.Custom.Enabled) then
			isEnabled = true;
			buttonTextureForSlotType = buttonTextureForSlotType or {};
			if (settings.Custom.State) then
				local state = settings.Custom.State;
				buttonTextureForSlotType[slotType] = {
					Textures =
					{
						Normal = state[Button.ButtonState.NORMAL].Texture,
						Highlighted = state[Button.ButtonState.HIGHLIGHTED].Texture,
						Pressed = state[Button.ButtonState.PRESSED].Texture,
						PressedHighlighted = state[Button.ButtonState.PRESSED_HIGHLIGHTED].Texture,
					},
					Slices =
					{
						Normal = state[Button.ButtonState.NORMAL].Slice,
						Highlighted = state[Button.ButtonState.HIGHLIGHTED].Slice,
						Pressed = state[Button.ButtonState.PRESSED].Slice,
						PressedHighlighted = state[Button.ButtonState.PRESSED_HIGHLIGHTED].Slice,
					},
				};
			end
		end
	end
	
	TexturedButtons.IsEnabled = isEnabled;
	
	if (isEnabled) then
		TexturedButtons.Texturize();
	else
		TexturedButtons.TexturizeDefaults();
	end

end

function TexturedButtons.RefreshActionBars()

	hotbarUpdate = hotbarUpdate - 1;
	
	if (hotbarUpdate <= 0) then
		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.RefreshActionBars");
		hotbarUpdate = nil;
		
		TexturedButtons.Texturize();
	end

end

function TexturedButtons.RefreshSettings()

	settingsUpdate = settingsUpdate - 1;
	
	if (settingsUpdate <= 0) then
		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.RefreshSettings");
		settingsUpdate = nil;

		local settings = TexturedButtons.Settings;
		
		if (settings.Misc.HideQuicklock) then
			if (DoesWindowExist(QUICK_LOCK_NAME) and WindowGetShowing(QUICK_LOCK_NAME)) then
				local cluster = ActionBarClusterPositions[ActionBarClusterManager.m_Settings:Get("layoutMode")];
				cluster[QUICK_LOCK_NAME] = cluster[QUICK_LOCK_NAME] or {};
				cluster.showing = false;
				WindowSetShowing(QUICK_LOCK_NAME, false);
			end
		end
	end

end

function TexturedButtons.UpdateButtons()

	buttonsUpdate = buttonsUpdate - 1;
	
	if (buttonsUpdate <= 0) then
		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.UpdateButtons");
		buttonsUpdate = nil;
		
		local queue = texturizeQueue;
		texturizeQueue = {};
		
		for slot, button in pairs(queue) do
			TexturedButtons.TexturizeButton(button);
		end
	end

end

local function SettingsUpdated()

	local alreadyRegistered = (settingsUpdate ~= nil);
	settingsUpdate = 2;
	
	if (not alreadyRegistered) then
		RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.RefreshSettings");
	end
	
end

local function ActionBarsUpdated()

	local alreadyRegistered = (hotbarUpdate ~= nil);
	hotbarUpdate = 2;
	
	if (not alreadyRegistered) then
		RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.RefreshActionBars");
	end

end

local function ButtonsUpdated()

	local alreadyRegistered = (buttonsUpdate ~= nil);
	buttonsUpdate = 2;
	
	if (not alreadyRegistered) then
		RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.UpdateButtons");
	end
	
end

-- Hook the SetActionBarSetting function, which is called whenever a bar's setting is changed
oldSetActionBarSetting = ActionBarClusterSettingsManager.SetActionBarSetting;
ActionBarClusterSettingsManager.SetActionBarSetting = function(...)

	oldSetActionBarSetting(...);
	ActionBarsUpdated();
	SettingsUpdated();
	
end

local function TintButton(button)

	local self = button;
	local iconFrame = self.m_Windows[BASE_ICON];
	local buttonLabel = self.m_Windows[BUTTON_TEXT];
		
	local tintSettings = TexturedButtons.Settings.Tint;
	local fontSettings = TexturedButtons.Settings.Fonts;
	
	-- for overriding witch elf kisses
	if (isTargetValidOverride ~= nil) then
		self.m_IsTargetValid = isTargetValidOverride[self.m_ActionId] or self.m_IsTargetValid;
	end
	
	if (tintSettings.Enabled) then
		if (self.m_IsEnabled and self.m_IsTargetValid) then
			iconFrame:SetTintColor(tintSettings.EnabledValid.R, tintSettings.EnabledValid.G, tintSettings.EnabledValid.B);
		elseif (self.m_IsEnabled) then
			iconFrame:SetTintColor(tintSettings.EnabledInvalid.R, tintSettings.EnabledInvalid.G, tintSettings.EnabledInvalid.B);
		elseif (not self.m_IsTargetValid) then
			iconFrame:SetTintColor(tintSettings.DisabledInvalid.R, tintSettings.DisabledInvalid.G, tintSettings.DisabledInvalid.B);
		elseif (not self.m_IsEnabled) then
			texture, x, y, disabledTexture = GetIconData(self.m_IconNum);
			if (disabledTexture == "") then
				iconFrame:SetTintColor(tintSettings.Disabled.R, tintSettings.Disabled.G, tintSettings.Disabled.B);
			end
		else
			iconFrame:SetTintColor(255, 255, 255); -- this will actually never occur
		end
	end
	
	if (fontSettings.Enabled) then
		if (not self.m_IsTargetValid) then
			-- UI will auto change it to red
		else
			LabelSetTextColor(buttonLabel:GetName(), fontSettings.Keybind.Color.R, fontSettings.Keybind.Color.G, fontSettings.Keybind.Color.B);
		end
	end
	
end

function TexturedButtons.Initialize() 
	if (TexturedButtons.IsLoaded) then return end
	
	TexturedButtons.LoadSettings();
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "TexturedButtons.OnLoadComplete");
	RegisterEventHandler(SystemData.Events.LOADING_END, "TexturedButtons.OnLoadComplete");
	
end

function TexturedButtons.RegisterLayoutEditorQuicklock()

	local miscSettings = TexturedButtons.Settings.Misc;
	local isRegistered = (LayoutEditor.windowsList[QUICK_LOCK_NAME] ~= nil)
	
	if (miscSettings.SaveQuicklock) then
		if (not isRegistered) then
			LayoutEditor.RegisterWindow(QUICK_LOCK_NAME, L"", L"", false, false, true);
		end
	else
		if (isRegistered) then
			LayoutEditor.UnregisterWindow(QUICK_LOCK_NAME);
		end
	end

end

function TexturedButtons.SaveQuicklock()

	local miscSettings = TexturedButtons.Settings.Misc;
	if (not miscSettings.SaveQuicklock or not DoesWindowExist(QUICK_LOCK_NAME)) then return end
	
	local interfaceScale = InterfaceCore.GetScale();
	local x, y = WindowGetScreenPosition(QUICK_LOCK_NAME);
	local windowScale = WindowGetScale(QUICK_LOCK_NAME);
	local isShowing = WindowGetShowing(QUICK_LOCK_NAME);
	
	if (miscSettings.HideQuicklock and isShowing) then
		WindowSetShowing(QUICK_LOCK_NAME, false);
		isShowing = false;
	end
	
	if (x and y) then
		ActionBarClusterPositions[ActionBarClusterManager.m_Settings:Get("layoutMode")][QUICK_LOCK_NAME] = 
		{ 
			-- since Point, RelativePoint and RelativeTo are not supplied, Root, "topleft" and "topleft" will be used by default
			XOffset = x / interfaceScale,
			YOffset = y / interfaceScale,
			scale = windowScale / interfaceScale,
			showing = isShowing,
		};
	end
						
end

function TexturedButtons.Unload()
	if (not TexturedButtons.IsLoaded) then return end

	TexturedButtons.SaveQuicklock();
	
	UnregisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "TexturedButtons.OnLoadComplete");
	UnregisterEventHandler(SystemData.Events.LOADING_END, "TexturedButtons.OnLoadComplete");
	UnregisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_UPDATED, "TexturedButtons.OnHotbarUpdated");
	UnregisterEventHandler(SystemData.Events.USER_SETTINGS_CHANGED, "TexturedButtons.OnSettingsChanged");
	UnregisterEventHandler(SystemData.Events.PLAYER_CAREER_LINE_UPDATED, "TexturedButtons.OnCareerLineUpdated");

	if (oldSetActionBarSetting) then
		ActionBarClusterSettingsManager.SetActionBarSetting = oldSetActionBarSetting;
		oldSetActionBarSetting = nil;
	end
	if (oldUpdateCooldownAnimation) then
		ActionButton.UpdateCooldownAnimation = oldUpdateCooldownAnimation;
		oldUpdateCooldownAnimation = nil;
	end
	if (oldButtonCreate) then
		ActionButton.Create = oldButtonCreate;
		oldButtonCreate = nil;
	end
	if (oldUpdateKeyBindingText) then
		ActionButton.UpdateKeyBindingText = oldUpdateKeyBindingText;
		oldUpdateKeyBindingText = nil;
	end
	if (oldUpdateEnabledState) then
		ActionButton.UpdateEnabledState = oldUpdateEnabledState;
		oldUpdateEnabledState = nil;
	end
	if (oldMoraleUpdate) then
		MoraleButton.Update = oldMoraleUpdate;
		oldMoraleUpdate = nil;
	end
	if (oldUpdateBurning) then
		ActionButton.UpdateBurning = oldUpdateBurning;
		oldUpdateBurning = nil;
	end
	if (oldSetPetCommands) then
		PetWindow.SetPetCommands = oldSetPetCommands;
		oldSetPetCommands = nil;
	end
	if (oldResetActionbarSettings) then
		SettingsWindowTabInterface.ResetActionbarSettings = oldResetActionbarSettings;
		oldResetActionbarSettings = nil;
	end
	if (oldActionButtonOnLButtonDown) then
		ActionButton.OnLButtonDown = oldActionButtonOnLButtonDown;
		oldActionButtonOnLButtonDown = nil;
	end

end

function TexturedButtons.OnLoadComplete()

	if (not TexturedButtons.IsLoaded) then
		TexturedButtons.IsLoaded = true;
		TexturedButtons.UpdateSettings();
		TexturedButtons.Setup.Initialize();
		RegisterEventHandler(SystemData.Events.PLAYER_HOT_BAR_UPDATED, "TexturedButtons.OnHotbarUpdated");
		RegisterEventHandler(SystemData.Events.USER_SETTINGS_CHANGED, "TexturedButtons.OnSettingsChanged");
		RegisterEventHandler(SystemData.Events.PLAYER_CAREER_LINE_UPDATED, "TexturedButtons.OnCareerLineUpdated");
	end

	--RegisterLibs();
	TexturedButtons.RegisterLayoutEditorQuicklock();
	TexturedButtons.OnCareerLineUpdated(); -- for witch elf kisses

	if (initialLoad) then
		initialLoad = false;
		TexturedButtons.UpdateActionbars();
	end

end

local function UpdateSettings()

	local settings = TexturedButtons.Settings;
	local version = settings.Version;
	
	if (not version) then
		version = 1;
		if (settings.Custom) then
			for state, texture in pairs(settings.Custom.State) do
				if (type(texture) == "string") then
					settings.Custom.State[state] = { Texture = texture };
				else
					settings.Custom.State[state] = { Texture = "" };
				end
			end
		end
	end
	
	if (version == 1) then
		version = 2;
		if (settings.Misc) then
			if (settings.Misc.QuicklockPosition) then
				settings.Misc.SaveQuicklock = (settings.Misc.QuicklockPosition ~= nil);
				ActionBarClusterPositions[ActionBarClusterManager.m_Settings:Get("layoutMode")][QUICK_LOCK_NAME] = 
				{ 
					XOffset = settings.Misc.QuicklockPosition.X,
					YOffset = settings.Misc.QuicklockPosition.Y,
				};
				settings.Misc.QuicklockPosition = nil;
			end
		end
	end
	
	if (version == 2) then
		version = 3;
		if (settings.Misc) then
			settings.Misc.CustomGlow = CustomGlow.OnlyResized;
		end
	end
	
	if (version == 3) then
		version = 4;
		if (settings.Misc) then
			settings.Misc.HideActive = false;
		end
	end
	
	if (version == 4) then
		version = 5;
		if (settings.Misc) then
			settings.Misc.HideActive = false;
			settings.Misc.HideQuicklock = false;
		end
	end
	
	if (version == 5) then
		version = 6;
		if (settings.Cooldown) then
			settings.Cooldown.EnableButtonTinting = true;
		end
		if (settings.Tint) then
			settings.Tint.OnCooldown = { R = 100, G = 100, B = 100 };
		end
	end

end

function TexturedButtons.LoadSettings()
	--UI5

	if (not TexturedButtons.Settings) then
		TexturedButtons.Settings = {};
	else
		UpdateSettings();
	end
	
	local settings = TexturedButtons.Settings;
	settings.Version = VERSION_SETTINGS;
	
	if (not settings.Preset) or (settings.Preset) then
		settings.Preset = 
			{
				Name = "Ryver1",
				Enabled = true,
			}
		--{ Name = "Gloss", Enabled = true };
	end
	
	if (not settings.Custom) or (settings.Custom) then
		settings.Custom = 
		{
			Enabled = false,
			State = 
			{
				[0] = 
				{
					Texture = "Ryver_border",
				},
				[1] = 
				{
					Texture = "Ryver_pushed",
				},
				[3] = 
				{
					Texture = "Ryver_gloss",
				},
				[4] = 
				{
					Texture = "Ryver_hover",
				},
			},
		}
--[[		
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
		]]
	end
	
	if (not settings.AdvancedTextures) or (settings.AdvancedTextures) then
		settings.AdvancedTextures = 
			{
				[7] = 
				{
				},
				[1] = 
				{
				},
				[6] = 
				{
				},
				[8] = 
				{
				},
			}
		--{};
	end
	
	if (not settings.Cooldown) or (settings.Cooldown) then
		settings.Cooldown =
		{
			Enabled = true,
			RemoveS = true,
			EnableButtonTinting = true,
			HideFlash = false,
			Tint = 
			{
				B = 0,
				G = 0,
				R = 0,
			},
			Alpha = 0.8,
			ShowGlobalCooldownText = false,
		}
--[[		
		{
			Enabled = false,
			EnableButtonTinting = true,
			HideFlash = true,
			RemoveS = true,
			ShowGlobalCooldownText = false,
			Tint = { R = 0, G = 0, B = 0 },
			Alpha = 0.8,
		};
]]
	end
	
	if (not settings.Fonts) or (settings.Fonts) then
		settings.Fonts = 
		{
			Enabled = true,
			Cooldown = 
			{
				Color = 
				{
					B = 0,
					G = 0,
					R = 255,
				},
				Font = "font_clear_large_bold",
				Hide = false,
			},
			Keybind = 
			{
				Color = 
				{
					B = 255,
					G = 255,
					R = 255,
				},
				Font = "font_clear_medium_bold",
				Hide = false,
			},
		}
--[[		
		{
			Enabled = false,
			Keybind = 
			{
				Font = "font_clear_medium_bold", 
				Color = { R = 255, G = 255, B = 255},
				Hide = false,
			};
			Cooldown = 
			{
				Font = "font_clear_large_bold", 
				Color = { R = 255, G = 255, B = 0 },
				Hide = false,
			};
		};
]]
	end
	
	if (not settings.Tint) or (settings.Tint) then
		settings.Tint = 
		{
			Enabled = true,
			Disabled = 
			{
				B = 150,
				G = 150,
				R = 150,
			},
			EnabledInvalid = 
			{
				B = 60,
				G = 60,
				R = 60,
			},
			DisabledInvalid = 
			{
				B = 60,
				G = 60,
				R = 255,
			},
			EnabledValid = 
			{
				B = 255,
				G = 255,
				R = 255,
			},
			OnCooldown = 
			{
				B = 100,
				G = 100,
				R = 100,
			},
		}
--[[
		{
			Enabled = false,
			EnabledValid = { R = 255, G = 255, B = 255 },
			EnabledInvalid = { R = 200, G = 0, B = 0 },
			DisabledInvalid = { R = 100, G = 0, B = 0 },
			Disabled = { R = 150, G = 150, B = 150 },
			OnCooldown = { R = 100, G = 100, B = 100 },
		};
		]]
	end
	
	if (not settings.Misc) or (settings.Misc) then
		settings.Misc =
		{
			HideActive = false,
			SaveQuicklock = true,
			ActionButtonPickUpModifier = 8,
			CooldownPulse = false,
			CustomGlow = 3,
			HideGlow = false,
			HideQuicklock = false,
		}
--[[		
		{
			HideGlow = false,
			CooldownPulse = false,
			SaveQuicklock = false,
			HideQuicklock = false,
			ActionButtonPickUpModifier = nil,
			CustomGlow = CustomGlow.OnlyResized,
			HideActive = false,
		};
]]
	end
	
	if (not settings.Actionbars) or (settings.Actionbars) then
		settings.Actionbars = 
		{
			Bar = 
				{
				Enabled = true,
				Bar = 
				{
					
					{
						Spacing = 
						{
							Y = 0,
							X = 0,
						},
						Padding = 
						{
							Y = 0,
							X = 0,
						},
						HideBackground = true,
						HideEmpty = false,
						PageSelector = 44,
					},
					
					{
						Spacing = 
						{
							Y = 0,
							X = 0,
						},
						HideBackground = true,
						Padding = 
						{
							Y = 0,
							X = 0,
						},
						HideEmpty = true,
						PageSelector = 44,
					},
					
					{
						Spacing = 
						{
							Y = 0,
							X = 0,
						},
						HideBackground = true,
						Padding = 
						{
							Y = 0,
							X = 0,
						},
						HideEmpty = true,
						PageSelector = 44,
					},
					
					{
						Spacing = 
						{
							Y = 0,
							X = 0,
						},
						HideBackground = true,
						Padding = 
						{
							Y = 0,
							X = 0,
						},
						HideEmpty = false,
						PageSelector = 44,
					},
					
					{
						Spacing = 
						{
							Y = 0,
							X = 0,
						},
						HideBackground = true,
						Padding = 
						{
							Y = 0,
							X = 0,
						},
						HideEmpty = false,
						PageSelector = 44,
					},
				},
			},
			--{},
		};
	end
	
	customGlow = settings.Misc.CustomGlow;
	if (TexturedButtons.IsLoaded) then
		TexturedButtons.UpdateSettings();
		if DoesWindowExist("EA_ActionBar1PageSelector") then WindowSetShowing("EA_ActionBar1PageSelector", false) end
		if DoesWindowExist("EA_ActionBar2PageSelector") then WindowSetShowing("EA_ActionBar2PageSelector", false) end
		if DoesWindowExist("EA_ActionBar3PageSelector") then WindowSetShowing("EA_ActionBar3PageSelector", false) end
		if DoesWindowExist("EA_ActionBar4PageSelector") then WindowSetShowing("EA_ActionBar4PageSelector", false) end
		if DoesWindowExist("EA_ActionBar5PageSelector") then WindowSetShowing("EA_ActionBar5PageSelector", false) end
		if DoesWindowExist("EA_ActionBar6PageSelector") then WindowSetShowing("EA_ActionBar6PageSelector", false) end
		if DoesWindowExist("EA_ActionBar7PageSelector") then WindowSetShowing("EA_ActionBar7PageSelector", false) end
		if DoesWindowExist("EA_ActionBar8PageSelector") then WindowSetShowing("EA_ActionBar8PageSelector", false) end
	end

end

function TexturedButtons.SlashCommand(args)

	--TexturedButtons.Setup.Show();

end

local function IsNameUsed(name)

	return (TexturedButtons.Preset[name] ~= nil);

end

local function AddTextures(buttonSet)

	if (not buttonSet or not buttonSet.Textures) then
		return;
	end
	
	for buttonState, texture in pairs(buttonSet.Textures) do
		if (not TexturedButtons.Textures[texture]) then
			if (not buttonSet.Slices) then
				TexturedButtons.Textures[texture] = buttonSet;
			else
				TexturedButtons.Textures[texture] = { Slices = {} };
			end
		end
	end
	
	if (buttonSet.Slices) then
		local lastT = "";
		for buttonState, texture in pairs(buttonSet.Slices) do
			TexturedButtons.Textures[buttonSet.Textures[buttonState]].Slices[texture] = buttonSet;
		end
	end

end

local function Register(buttonSet)

	local name = buttonSet.Name;
	local index = 1;
	
	if (not name) then
		name = buttonSet.Author or "Unnamed";
	end
	
	local registeredName = name;
	
	while (IsNameUsed(registeredName)) do
		registeredName = name .. index;
		index = index + 1;
	end
	
	TexturedButtons.Preset[registeredName] = buttonSet;
	AddTextures(buttonSet);

end

function TexturedButtons.Register(...)

	if (type(...) == "table") then
		Register(...);
	else
		local name, author, description, normal, highlighted, pressed, pressedHighlighted = ...;
		Register({
			Name = name,
			Author = author,
			Description = description,
			Textures = {
				Normal = normal,
				Highlighted = highlighted,
				Pressed = pressed,
				PressedHighlighted = pressedHighlighted,
			},
		});
	end
	
	if (TexturedButtons.IsLoaded) then
		if (registerTexturesUpdate == nil) then
			RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.OnRegisteredTexturedChanged");
		end
		registerTexturesUpdate = 2;
	end

end

function TexturedButtons.OnRegisteredTexturedChanged()
	if (registerTexturesUpdate) then
		if (registerTexturesUpdate <= 1) then
			registerTexturesUpdate = nil;
			UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TexturedButtons.OnRegisteredTexturedChanged");
		else
			registerTexturesUpdate = registerTexturesUpdate - 1;
		end
	end
	if (not registerTexturesUpdate) then
		TexturedButtons.Setup.AdvancedTextures.LoadSettings();
		TexturedButtons.Setup.Textures.LoadSettings();
		TexturedButtons.UpdateSettings();
	end
end

-- For when the action bar lock is pressed
-- Note that the action bars only reset when the lock is changed, if NAMBLA is installed
function TexturedButtons.OnSettingsChanged()

	ActionBarsUpdated();
	SettingsUpdated();

end

-- For witch elf kisses, remove when fixed
function TexturedButtons.OnCareerLineUpdated()

	if (GameData.Player.career.line == GameData.CareerLine.WITCH_ELF) then
		isTargetValidOverride =
		{
			[9407] = true,
			[9412] = true,
			[9402] = true,
		};
	else
		isTargetValidOverride = nil;
	end

end

local function IsHotbarSlot(slot)

	if (slot <= GameDefs.HOTBAR_SWAPPABLE_SLOT_COUNT) then
		return true;
	end
	
	return false;

end

function TexturedButtons.OnHotbarUpdated(slot, actionType, actionId)
	
	local forceRetexture = false;
	local previousAction = buttonAction[slot];
	
	if (previousAction == 0) then
		forceRetexture = (actionId ~= 0); -- retexture a button if it previously didn't have a texture
	end
	
	if (actionId == 0 or previousAction ~= actionId) then
		local miscSettings = TexturedButtons.Settings.Misc;
		if (miscSettings.CooldownPulse) then
			local pulseFrame = cooldownPulse[slot];
			if (pulseFrame) then
				pulseFrame:StopPulse();
			end
		end
	end
	
	buttonAction[slot] = actionId;

	-- Note that we only care about granted abilities since they are the only buttons not effected by the settings texturize
	if (not forceRetexture and IsHotbarSlot(slot)) then return end

    local barObject, buttonId = ActionBars:BarAndButtonIdFromSlot(slot);
	    
    -- It's possible for barObject to be nil, it just means that this particular bar hasn't been created.
    if (barObject ~= nil) then
		local index = slot - barObject.m_Buttons[1].m_HotBarSlot + 1;
		local button = barObject.m_Buttons[index];
		
		texturizeQueue[slot] = button;
		ButtonsUpdated();
    end

end

function TexturedButtons.UpdateCustomGlow()

	local settings = TexturedButtons.Settings;
	if (customGlow ~= settings.Misc.CustomGlow) then
		customGlow = settings.Misc.CustomGlow;
		forceResizeButtons = true;
		TexturedButtons.Texturize();
		forceResizeButtons = false;
	end
	
end

function TexturedButtons.UpdateTints()
	if (not TexturedButtons.IsLoaded) then return end

	local tintSettings = TexturedButtons.Settings.Tint;
	if (not tintSettings.Enabled) then return end
	
	for barNum, barData in pairs(ActionBars.m_Bars) do
		for btnNum, btnData in ipairs(barData.m_Buttons) do
			TintButton(btnData);
		end
	end
	
end

function TexturedButtons.UpdateCooldowns()
	if (not TexturedButtons.IsLoaded) then return end

	local cooldownSettings = TexturedButtons.Settings.Cooldown;
	if (not cooldownSettings.Enabled) then return end
	
	-- nothing to do
	
end

function TexturedButtons.UpdateFonts()
	if (not TexturedButtons.IsLoaded) then return end

	local fontSettings = TexturedButtons.Settings.Fonts;
	if (not fontSettings.Enabled) then return end

	for barNum, barData in pairs(ActionBars.m_Bars) do
		for btnNum, btnData in ipairs(barData.m_Buttons) do
            local timerLabel = btnData.m_Windows[COOLDOWN_TIMER];
            local buttonLabel = btnData.m_Windows[BUTTON_TEXT];
            
			if (fontSettings.Cooldown.Hide) then
				timerLabel:Show(false);
			else
				timerLabel:Show(true);
				LabelSetFont(timerLabel:GetName(), fontSettings.Cooldown.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
				LabelSetTextColor(timerLabel:GetName(), fontSettings.Cooldown.Color.R, fontSettings.Cooldown.Color.G, fontSettings.Cooldown.Color.B);
			end
			
			if (fontSettings.Keybind.Hide) then
				buttonLabel:Show(false);
			else
				buttonLabel:Show(true);
				LabelSetFont(buttonLabel:GetName(), fontSettings.Keybind.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
				LabelSetTextColor(buttonLabel:GetName(), fontSettings.Keybind.Color.R, fontSettings.Keybind.Color.G, fontSettings.Keybind.Color.B);
			end
		end
	end

end

function TexturedButtons.UpdateActionbars(barIndex)
	if (not TexturedButtons.IsLoaded) then return end

	local clusterSettings = ActionBarClusterManager.m_Settings;
	local actionbarSettings = TexturedButtons.Settings.Actionbars;
	if (not actionbarSettings.Enabled) then return end
	
	for index, barSettings in pairs(actionbarSettings.Bar) do
		if (not barIndex or index == barIndex) then
			local bar = ActionBars:GetBar(index);
			
			local background = ActionBarConstants.SHOW_BACKGROUND;
			if (barSettings.HideBackground) then
				background = ActionBarConstants.HIDE_BACKGROUND;
			end
			local showEmptySlots = ActionBarConstants.SHOW_EMPTY_SLOTS;
			if (barSettings.HideEmpty) then
				showEmptySlots = ActionBarConstants.HIDE_EMPTY_SLOTS;
			end
			
			clusterSettings:SetActionBarSetting(index, "selector", barSettings.PageSelector);
			clusterSettings:SetActionBarSetting(index, "background", background);
			clusterSettings:SetActionBarSetting(index, "showEmptySlots", showEmptySlots);
			clusterSettings:SetActionBarSetting(index, "buttonXPadding", barSettings.Padding.X);
			clusterSettings:SetActionBarSetting(index, "buttonYPadding", barSettings.Padding.Y);
			clusterSettings:SetActionBarSetting(index, "buttonXSpacing", barSettings.Spacing.X);
			clusterSettings:SetActionBarSetting(index, "buttonYSpacing", barSettings.Spacing.Y);
			
			if (bar) then
				bar.m_ButtonXPadding = barSettings.Padding.X;
				bar.m_ButtonYPadding = barSettings.Padding.Y;
				bar.m_ButtonXSpacing = barSettings.Spacing.X;
				bar.m_ButtonYSpacing = barSettings.Spacing.Y;
				bar.m_ShowBackground = background;
				bar.m_ShowEmptySlots = showEmptySlots;
				
				bar:SetPageSelectorMode(barSettings.PageSelector);
				bar:UpdateShowBackground();
				bar:UpdateShownSlots();
				bar:AnchorButtons();
			else
				-- the bar being updated does not exist
				-- there is a problem with the default ui
			end
			
		end
	end
	
	ActionBarClusterManager:SetLayoutMode(ActionBarClusterManager:GetLayoutMode(), 42); -- FORCE_LAYOUT = 42
	SettingsWindowTabInterface.UpdateSettings(); -- updates the settings window

end

local oldActionButtonOnLButtonDown = ActionButton.OnLButtonDown;
ActionButton.OnLButtonDown = function(...)
	local self, flags, x, y = ...;
	
	-- note that this function is called on mouse or key events
	
	oldActionButtonOnLButtonDown();
	
	if (TexturedButtons.Settings.Misc.ActionButtonPickUpModifier == flags and SystemData.Settings.Interface.lockActionBars) then -- don't run if the action bars are unlocked	
		-- Note that button == self, but this guarantees that the mouse has this button selected
		-- The FrameManager could also return other frames that are not this button, such as if the mouse is over the buff window while a key is activated
		local button = FrameManager:GetMouseOverWindow();
		if (not button or not button.GetSlot) then return end
	
		local hotbarSlot = button:GetSlot();
		local modificationAllowed = button:VerifySlotIsUserModifiable(ActionButton.SUPPRESS_MODIFICATION_ATTEMPT_ERROR, ActionButton.MODIFICATION_TYPE_PICKUP);
		
		if (modificationAllowed) then
			ActionBars:SetPickupButton(button);
		end
	end
	
end

oldUpdateCooldownAnimation = ActionButton.UpdateCooldownAnimation;
ActionButton.UpdateCooldownAnimation = function(...)
	oldUpdateCooldownAnimation(...);
	
	local self, timeElapsed = ...;
	local cooldownSettings = TexturedButtons.Settings.Cooldown;
	local fontSettings = TexturedButtons.Settings.Fonts;
	local miscSettings = TexturedButtons.Settings.Misc;
	local tintSettings = TexturedButtons.Settings.Tint;
	local isBarShowing = self:GetParent():IsShowing();
	
	if (not isBarShowing) then return end -- do not update hidden action bars
	
	if (miscSettings.CooldownPulse) then
		local pulseFrame = cooldownPulse[self.m_HotBarSlot];
		if (pulseFrame) then
			pulseFrame:Update(timeElapsed);
		end
		
		if (self.m_MaxCooldown >= 1.6 and self.m_Cooldown >= 1.6) then
			if (not pulseFrame) then
				cooldownPulse[self.m_HotBarSlot] = CooldownPulse:Create(self.m_HotBarSlot);
			else
				pulseFrame:SetIcon(self.m_IconNum);
				pulseFrame:BeginPulseIn(self.m_Cooldown - 0.3); -- pulse just before the end of the cooldown
			end
		end
	end
	
	local activeFrame = self.m_Windows[ACTIVE_ANIM];
	
	if (miscSettings.HideActive) then
		activeFrame:SetAlpha(0);
	else
		activeFrame:SetAlpha(1);
	end
	
	if (cooldownSettings.Enabled) then	
		local cooldownFrame = self.m_Windows[COOLDOWN];
		local cooldownTimer = self.m_Windows[COOLDOWN_TIMER];
		local flashFrame = self.m_Windows[FLASH_ANIM];
		local iconFrame = self.m_Windows[BASE_ICON];
		
		if (cooldownSettings.HideFlash) then
			flashFrame:SetAlpha(0);
		else
			flashFrame:SetAlpha(1);
		end
		
		if (self.m_Cooldown > 0 and self.m_MaxCooldown > 0) then
			cooldownFrame:SetAlpha(cooldownSettings.Alpha);
			cooldownFrame:SetTintColor(cooldownSettings.Tint.R, cooldownSettings.Tint.G, cooldownSettings.Tint.B);
			
			if (cooldownSettings.EnableButtonTinting and tintSettings.Enabled) then
				local color = tintSettings.OnCooldown;
				iconFrame:SetTintColor(color.R, color.G, color.B);
			end
			
			if (cooldownSettings.RemoveS) then
				if (self.m_Cooldown > 3) then
					if (self.m_Cooldown >= 60) then
						cooldownTimer:SetText(wstring.format(L"%dm", math.ceil(self.m_Cooldown / 60)));
					else
						cooldownTimer:SetText(wstring.format(L"%d", self.m_Cooldown));
					end
				else
					cooldownTimer:SetText(wstring.format(L"%0.1f", self.m_Cooldown));
				end
			end
			
			if (fontSettings.Enabled and fontSettings.Cooldown.Hide) then
				cooldownTimer:Show(false);
			else
				if (self.m_MaxCooldown >= 1.6 or cooldownSettings.ShowGlobalCooldownText) then				
					cooldownTimer:Show(true);
				else
					cooldownTimer:Show(false);
				end
			end
		else
			cooldownTimer:Show(false);
			
			TintButton(self);
		end
	end
	
end
        
oldButtonCreate = ActionButton.Create;
ActionButton.Create = function(...)
	local button = oldButtonCreate(...);
	if (not button) then return end
	
	local fontSettings = TexturedButtons.Settings.Fonts;
	
	if (fontSettings.Enabled) then
	
		local timerLabel = button.m_Windows[COOLDOWN_TIMER];
		local buttonLabel = button.m_Windows[BUTTON_TEXT];
		
		if (fontSettings.Cooldown.Hide) then
			timerLabel:Show(false);
		else
			timerLabel:Show(true);
			LabelSetFont(timerLabel:GetName(), fontSettings.Cooldown.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
			LabelSetTextColor(timerLabel:GetName(), fontSettings.Cooldown.Color.R, fontSettings.Cooldown.Color.G, fontSettings.Cooldown.Color.B);
            WindowSetDimensions(timerLabel:GetName(), WindowGetDimensions(timerLabel:GetParent():GetName()));
		end
		
		if (fontSettings.Keybind.Hide) then
			buttonLabel:Show(false);
		else
			buttonLabel:Show(true);
			LabelSetFont(buttonLabel:GetName(), fontSettings.Keybind.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
			LabelSetTextColor(buttonLabel:GetName(), fontSettings.Keybind.Color.R, fontSettings.Keybind.Color.G, fontSettings.Keybind.Color.B);
            WindowSetDimensions(buttonLabel:GetName(), WindowGetDimensions(buttonLabel:GetParent():GetName()));
		end
		
	end
	
	return button;
end

oldUpdateKeyBindingText = ActionButton.UpdateKeyBindingText;
ActionButton.UpdateKeyBindingText = function(...)
	oldUpdateKeyBindingText(...)
	
	local self = ...;
	local buttonLabel = self.m_Windows[BUTTON_TEXT];
	
	local fontSettings = TexturedButtons.Settings.Fonts;
	if (fontSettings.Enabled) then
		if (fontSettings.Keybind.Hide) then
			buttonLabel:Show(false);
		else
			buttonLabel:Show(true);
			LabelSetTextColor(buttonLabel:GetName(), fontSettings.Keybind.Color.R, fontSettings.Keybind.Color.G, fontSettings.Keybind.Color.B);
		end
	end

end
        
oldUpdateEnabledState = ActionButton.UpdateEnabledState;
ActionButton.UpdateEnabledState = function(self, ...)
	oldUpdateEnabledState(self, ...)

	TintButton(self);

end
    
oldMoraleUpdate = MoraleButton.Update;
MoraleButton.Update = function(self, ...)
	oldMoraleUpdate(self, ...)
	
	local BASE_ICON = 2;
	
	local tintSettings = TexturedButtons.Settings.Tint;
	if (tintSettings.Enabled) then
		if (self.m_AbilityId > 0) then
			if self.m_IsTargetValid then
				self.m_Windows[BASE_ICON]:SetTintColor(tintSettings.EnabledValid.R, tintSettings.EnabledValid.G, tintSettings.EnabledValid.B);
			else
				self.m_Windows[BASE_ICON]:SetTintColor(tintSettings.EnabledInvalid.R, tintSettings.EnabledInvalid.G, tintSettings.EnabledInvalid.B);
			end
		end
	end

end

oldUpdateBurning = ActionButton.UpdateBurning;
ActionButton.UpdateBurning = function(...)
	oldUpdateBurning(...);

	local self = ...;
	local glowFrame = self.m_Windows[GLOW_ANIM];
	local miscSettings = TexturedButtons.Settings.Misc;
	
	if (miscSettings.HideGlow) then
		if (glowFrame:IsShowing()) then
			glowFrame:StopAnimation(true);
			glowFrame:Show(false);
		end
	end
end

oldSetPetCommands = PetWindow.SetPetCommands;
PetWindow.SetPetCommands = function(...)

	local self = ...;
	oldSetPetCommands(...);
	
	local barObject = self.m_Actionbar;
	
	if (barObject ~= nil) then	
		for actionIndex, actionId in ipairs (self.m_PetCommands) do
			local slot = GameDefs.LAST_PET_ABILITY_SLOT - actionIndex;
			local index = slot - barObject.m_Buttons[1].m_HotBarSlot + 1;
			local button = barObject.m_Buttons[index];
			
			texturizeQueue[slot] = button;
			ButtonsUpdated();
		end
	end
	
end

oldResetActionbarSettings = SettingsWindowTabInterface.ResetActionbarSettings;
SettingsWindowTabInterface.ResetActionbarSettings = function(...)
	
	oldResetActionbarSettings(...);
	TexturedButtons.UpdateActionbars();
	
end