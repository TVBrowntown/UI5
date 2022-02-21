Obsidian = Obsidian or {};
Obsidian.SystemTime = 0;
Obsidian.Latency = nil; -- in seconds, if available
Obsidian.TargetType = { Friendly = 1, Hostile = 2 };
Obsidian.Targets = { Friendly = 0, Hostile = 0 };

local VERSION_SETTINGS = 3;

local castEnded = nil;
local initialLoad = true;

local castbar = nil;
local rangeTintingEnabled = false;

local globalCooldown = nil;
local globalCooldownEnabled = false;
local globalCooldownExpected = false;

local hostileEffects = nil;
local friendlyEffects = nil;
local hostileEffectsEnabled = false;
local friendlyEffectsEnabled = false;

local settingsDirty = false;

local oldActionButtonUpdateCooldownAnimation = nil;
local oldActionButtonUpdateEnabledState = nil;

local isLibSlashRegistered = false;
local isLibAddonButtonRegistered = false;

--[[
local function RegisterLibs()

	if (not isLibSlashRegistered) then
		if (LibSlash) then
			LibSlash.RegisterWSlashCmd("obsidian", function(args) Obsidian.SlashCommand(args) end);
			isLibSlashRegistered = true;
		end
	end

	if (not isLibAddonButtonRegistered) then
		if (LibAddonButton) then
			LibAddonButton.Register("fx");
			LibAddonButton.AddMenuItem("fx", "Obsidian", Obsidian.Setup.Show);
			isLibAddonButtonRegistered = true;
		end
	end
end
]]

local function SetScale(scale)

	castbar:SetScale(scale);
	globalCooldown:SetScale(scale);
	hostileEffects:SetScale(scale);
	friendlyEffects:SetScale(scale);
	
end

function Obsidian.Initialize()

	Obsidian.LoadSettings();
	Obsidian.Setup.Initialize();
	
    RegisterEventHandler(SystemData.Events.PLAYER_END_CAST, "Obsidian.EndCast")
    RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "Obsidian.BeginCast")
	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "Obsidian.OnTargetEffectsUpdated");
	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "Obsidian.OnTargetUpdated");
	RegisterEventHandler(SystemData.Events.LOADING_END, "Obsidian.OnLoadingEnd");
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "Obsidian.OnLoadingEnd");
	table.insert(LayoutEditor.EventHandlers, Obsidian.OnLayoutEditorFinished);
	
	castbar = Obsidian.Castbar:Create("ObsidianCastbar");
	globalCooldown = Obsidian.GlobalCooldown:Create("ObsidianGlobalCooldownBar");
	hostileEffects = Obsidian.EffectContainer:Create("ObsidianEffectsHostile", Obsidian.TargetType.Hostile, Obsidian.Settings.EffectTracker.Hostile);
	friendlyEffects = Obsidian.EffectContainer:Create("ObsidianEffectsFriendly", Obsidian.TargetType.Friendly, Obsidian.Settings.EffectTracker.Friendly);

	LayoutEditor.RegisterWindow(castbar:GetName(), L"Obsidian Cast Bar", "", true, true, false, nil);
	
	local settings = Obsidian.Settings;
	local interfaceScale = InterfaceCore.GetScale();
	local scale = settings.Castbar.Scale or interfaceScale;
	
	if (settings.Castbar.Position.X and settings.Castbar.Position.Y) then
		castbar:AnchorTo("Root", "topleft", "topleft", settings.Castbar.Position.X, settings.Castbar.Position.Y);
	else
		castbar:AnchorTo("Root", "bottom", "bottom", (settings.Castbar.Size.Height + settings.Castbar.Size.Border) / 2, -300);
	end
	
	SetScale(scale);

	LayerTimerWindow.StartInteractTimer = function(...)
		castbar:StartInteraction(...);
	end
	
	LayerTimerWindow.HideCastBar = function(...)
		castbar:Hide(...);
	end
	
	LayerTimerWindow.ShowCastBar = function(...)
		castbar:StartCasting(...);
	end
	
	LayerTimerWindow.SetbackCastBar = function(...)
		castbar:Setback(...);
	end
	
	LayerTimerWindow.SetActionName = function(...)
		castbar:SetName(...);
	end
	
	LayerTimerWindow.Update = function(...)
		-- note, we are making the default update function do nothing, since certain addons cause this update to be disabled anyways
		--castbar:Update(...); 
	end
	
	oldActionButtonUpdateCooldownAnimation = ActionButton.UpdateCooldownAnimation;
	ActionButton.UpdateCooldownAnimation = function(self, ...)
		oldActionButtonUpdateCooldownAnimation(self, ...);
		if (globalCooldownEnabled and globalCooldownExpected) then
			if (self.m_MaxCooldown < ActionButton.GLOBAL_COOLDOWN and self.m_Cooldown > 0 and globalCooldown.Cooldown == nil) then
				globalCooldownExpected = false;
				globalCooldown:Start(self.m_Cooldown);
			end
		end
	end
        
	oldActionButtonUpdateEnabledState = ActionButton.UpdateEnabledState;
	ActionButton.UpdateEnabledState = function(self, ...)
		oldActionButtonUpdateEnabledState(self, ...)
		if (rangeTintingEnabled == true and castbar.Casting ~= nil and castbar.Casting.Ability == self.m_ActionId) then
			castbar:UpdateOutOfRangeState(self.m_IsEnabled and not self.m_IsTargetValid);
		end
	end
	
	Obsidian.OnSettingsChanged(true);
	
end

function Obsidian.OnLoadingEnd()

	--RegisterLibs();
	
	if (initialLoad) then
		initialLoad = false;
			
		if (DoesWindowExist("LayerTimerWindow")) then
			WindowSetShowing("LayerTimerWindow", false);
			if (LayoutEditor.windowsList["LayerTimerWindow"]) then
				LayoutEditor.UnregisterWindow("LayerTimerWindow");
			end
			WindowUnregisterCoreEventHandler("LayerTimerWindow", "OnUpdate");
		end
	end
	
end

function Obsidian.OnLayoutEditorFinished(exitCode)
	
	if (exitCode ~= LayoutEditor.EDITING_END) then return end
	
	local interfaceScale = InterfaceCore.GetScale();
	local scale = WindowGetScale(castbar:GetName());
	local width, height = WindowGetDimensions(castbar:GetName());
	local x, y = WindowGetScreenPosition(castbar:GetName());
	
	local settings = Obsidian.Settings.Castbar;

	settings.Scale = scale;
	settings.Position.X = x / interfaceScale;
	settings.Position.Y = y / interfaceScale;
	settings.Size.Width = width - (settings.Size.Border * 2);
	settings.Size.Height = height - (settings.Size.Border * 2);
	
	settings = Obsidian.Settings;
	
	if (settings.EffectTracker.Hostile.Position == Obsidian.EffectContainer.Position.FreeUp or settings.EffectTracker.Hostile.Position == Obsidian.EffectContainer.Position.FreeDown) then
		x, y = WindowGetScreenPosition(hostileEffects:GetName());
		settings.EffectTracker.Hostile.X = math.floor(x / interfaceScale * 10) / 10;
		settings.EffectTracker.Hostile.Y = math.floor(y / interfaceScale * 10) / 10;
	end
	if (settings.EffectTracker.Friendly.Position == Obsidian.EffectContainer.Position.FreeUp or settings.EffectTracker.Friendly.Position == Obsidian.EffectContainer.Position.FreeDown) then
		x, y = WindowGetScreenPosition(friendlyEffects:GetName());
		settings.EffectTracker.Friendly.X = math.floor(x / interfaceScale * 10) / 10;
		settings.EffectTracker.Friendly.Y = math.floor(y / interfaceScale * 10) / 10;
	end
	if (settings.GlobalCooldown.Position == Obsidian.GlobalCooldown.Position.Free) then
		x, y = WindowGetScreenPosition(globalCooldown:GetName());
		settings.GlobalCooldown.X = math.floor(x / interfaceScale * 10) / 10;
		settings.GlobalCooldown.Y = math.floor(y / interfaceScale * 10) / 10;
	end
	
	SetScale(scale);
	Obsidian.Setup.Castbar.LoadSettings();
	Obsidian.OnSettingsChanged();
	
end

--[[
function Obsidian.SlashCommand(args)

	--Obsidian.Setup.Show();

end
]]

function Obsidian.OnTargetUpdated(targetType, targetObjectNumber, targetObjectType)

	TargetInfo:UpdateFromClient();

	if (targetType == "selfhostiletarget" and Obsidian.Targets.Hostile ~= targetObjectNumber) then
		Obsidian.Targets.Hostile = targetObjectNumber;
		if (hostileEffectsEnabled) then
			hostileEffects:ClearAllEffects();
		end
	elseif (targetType == "selffriendlytarget" and Obsidian.Targets.Friendly ~= targetObjectNumber) then
		Obsidian.Targets.Friendly = targetObjectNumber;
		if (friendlyEffectsEnabled) then
			friendlyEffects:ClearAllEffects();
		end
	end

end

function Obsidian.OnTargetEffectsUpdated(targetType, changedEffects, isFullList)
	if (changedEffects == nil) then return end
	
	if (hostileEffectsEnabled and targetType == GameData.BuffTargetType.TARGET_HOSTILE) then
		hostileEffects:UpdateEffects(changedEffects, isFullList);
	elseif (friendlyEffectsEnabled and targetType == GameData.BuffTargetType.TARGET_FRIENDLY) then
		friendlyEffects:UpdateEffects(changedEffects, isFullList);
	end
end

local function UpdateSettings()
	local settings = Obsidian.Settings;
	local version = settings.Version;
	
	if (version == 1) then
		version = 2;
		
		if (settings.Castbar) then
			settings.Castbar.Name.Alignment = "leftcenter";
			settings.Castbar.Timer.Alignment = "rightcenter";
			settings.Castbar.Icon.Scale = 1;
		end
		if (settings.EffectTracker) then
			settings.EffectTracker.General.Name.Alignment = "leftcenter";
			settings.EffectTracker.General.Timer.Alignment = "rightcenter";
			settings.EffectTracker.Friendly.Icon.Scale = 1;
			settings.EffectTracker.Hostile.Icon.Scale = 1;
		end
	end
	
	if (version == 2) then
		version = 3;
		
		if (settings.GlobalCooldown) then
			settings.GlobalCooldown.Width = "100%";
		end
	end
	
	if (version == 3) then
		version = 4;
	end
end

function Obsidian.LoadSettings()
	if (not Obsidian.Settings) then
		Obsidian.Settings = {};
	else
		UpdateSettings();
	end

	local settings = Obsidian.Settings;
	settings.Version = VERSION_SETTINGS;
	
	-- if yes or no, lol
	if (not settings.Castbar) or settings.Castbar then
		d("UI5 Obsidian: Setup!")
		settings.Castbar =
		{
			Spark = 
			{
				Color = 
				{
					B = 255,
					G = 255,
					R = 255,
				},
				Alpha = 1,
			},
			Scale = 0.80000001192093,
			Range = 
			{
				Enabled = true,
				Color = 
				{
					B = 0,
					G = 0,
					R = 255,
				},
			},
			Latency = 
			{
				Enabled = true,
				Text = 
				{
					Enabled = true,
					Font = "font_clear_tiny",
					Color = 
					{
						B = 178,
						G = 178,
						R = 178,
					},
					Alpha = 0.8,
					Scale = 0.6,
				},
				Alpha = 0.6,
				Color = 
				{
					B = 0,
					G = 0,
					R = 255,
				},
			},
			Fill = 
			{
				Colors = 
				{
					Normal = 
					{
						B = 155,
						G = 146,
						R = 255,
					},
					Failed = 
					{
						B = 0,
						G = 0,
						R = 255,
					},
					Success = 
					{
						B = 0,
						G = 255,
						R = 0,
					},
					Channeled = 
					{
						B = 255,
						G = 77,
						R = 82,
					},
				},
				TextureDimensions = 
				{
					Height = 32,
					Width = 256,
				},
				Priority = 3,
				Alpha = 1,
				Texture = "SharedMediaAluminium",
			},
			Timer = 
			{
				Enabled = true,
				Decimals = 1,
				Scale = 1,
				Alpha = 1,
				Y = -16,
				X = -2,
				Alignment = "rightcenter",
				Color = 
				{
					B = 255,
					G = 255,
					R = 255,
				},
				Font = "font_clear_medium_bold",
			},
			Name = 
			{
				Enabled = true,
				Scale = 1,
				Alpha = 1,
				Width = 0.75,
				Y = -16,
				X = 2,
				Alignment = "leftcenter",
				Color = 
				{
					B = 255,
					G = 255,
					R = 255,
				},
				Font = "font_clear_medium_bold",
			},
			Position = 
			{
				Y = 1021.558177445,
				X = 1143.9999392018,
			},
			Accurate = true,
			Background = 
			{
				Color = 
				{
					B = 0,
					G = 0,
					R = 0,
				},
				TextureDimensions = 
				{
					Height = 1,
					Width = 1,
				},
				Alpha = 0.75698244571686,
				Texture = "EA_TintableImage",
			},
			Icon = 
			{
				Enabled = true,
				X = -4,
				Position = 1,
				Scale = 2.8,
				Alpha = 1,
				Y = -10,
			},
			Size = 
			{
				Height = 8,
				Border = 2,
				Width = 384,
			},
--[[			
			Accurate = true,
			Scale = 0.8,
			Size =
			{
				Width = 350,
				Height = 30,
				Border = 3,
			},
			Position =
			{
				X = nil, -- automatically set
				Y = nil,
			},
			Background =
			{
				Alpha = 0.6,
				Color = { R = 0, G = 0, B = 0 },
				Texture = "EA_TintableImage",
				TextureDimensions = { Width = 1, Height = 1 }, -- EA_TintableImage.dds is 128x128
			},
			Latency =
			{
				Enabled = true,
				Alpha = 0.6,
				Color = { R = 255, G = 0, B = 0 },
				Text = 
				{
					Enabled = true,
					Color = { R = 178, G = 178, B = 178 },
					Font = "font_clear_tiny",
					Scale = 0.6,
					Alpha = 0.8,
				},
			},
			Fill =
			{
				Texture = "SharedMediaHealbot",
				TextureDimensions = { Width = 256, Height = 32 },
				Alpha = 1,
				Colors =
				{
					Normal = { R = 0, G = 22, B = 165 },
					Channeled = { R = 82, G = 77, B = 255 },
					Success = { R = 0, G = 255, B = 0 },
					Failed = { R = 255, G = 0, B = 0 },	
				},
				Priority = Obsidian.Castbar.FillPriority.High,
			},
			Spark =
			{
				Color = { R = 255, B = 255, G = 255 },
				Alpha = 1,
			},
			Name =
			{
				Enabled = true,
				X = 8,
				Y = 0,
				Scale = 1,
				Font = "font_clear_small_bold",
				Color = { R = 255, G = 255, B = 255 },
				Alpha = 1,
				Width = 0.75,
				Alignment = "leftcenter",
			},
			Timer =
			{
				Enabled = true,
				X = -8,
				Y = 0,
				Scale = 1,
				Font = "font_clear_small_bold",
				Color = { R = 255, G = 255, B = 255 },
				Alpha = 1,
				Decimals = 1,
				Alignment = "rightcenter",
			},
			Icon =
			{
				Enabled = true,
				X = -3,
				Y = 0,
				Alpha = 1,
				Position =  Obsidian.Castbar.IconPosition.Left, -- left
				Scale = 1,
			},
			Range =
			{
				Enabled = true,
				Color = { R = 255, G = 255, B = 255 },
			},
]]
		};
	end
	
	-- if yes or no, lol
	if (not settings.GlobalCooldown) or settings.GlobalCooldown then
		settings.GlobalCooldown =
		{
			Enabled = false,
			Spark = 
			{
				Color = 
				{
					B = 255,
					G = 255,
					R = 255,
				},
				Alpha = 1,
			},
			Divider = 
			{
				Color = 
				{
					B = 255,
					G = 255,
					R = 255,
				},
				Alpha = 1,
			},
			Width = "100%",
			Y = 0,
			X = 0,
			FillReady = 
			{
				Color = 
				{
					B = 0,
					G = 0,
					R = 0,
				},
				Alpha = 0.8,
			},
			Reverse = false,
			Height = 4,
			Background = 
			{
				Color = 
				{
					B = 0,
					G = 0,
					R = 0,
				},
				Alpha = 0.8,
			},
			Position = 2,
			Fill = 
			{
				Color = 
				{
					B = 0,
					G = 0,
					R = 0,
				},
				Alpha = 0.8,
			},
--[[
			Enabled = true,
			Reverse = false,
			Position = Obsidian.GlobalCooldown.Position.Bottom, -- bottom
			X = 0,
			Y = 0,
			Width = "100%",
			Height = 4,
			Background =
			{
				Color = { R = 0, B = 0, G = 0 },
				Alpha = 0.8,
			},
			Fill =
			{
				Color = { R = 0, B = 0, G = 0 },
				Alpha = 0.8,
			},
			Spark =
			{
				Color = { R = 255, B = 255, G = 255 },
				Alpha = 1,
			},
			FillReady =
			{
				Color = { R = 0, B = 0, G = 0 },
				Alpha = 0.8,
			},
			Divider =
			{
				Color = { R = 255, B = 255, G = 255 },
				Alpha = 1,
			},
			]]
		};
	end
	-- if yes or no, lol
	if (not settings.EffectTracker) or (settings.EffectTracker) then
		settings.EffectTracker = 
		{
			--[[General =
									{
										Spacing = 1,
										MaximumThreshold = 3600,
										FixedDuration = 0,
										Size = 
										{
											Width = 170,
											Height = 15,
											Border = 0,
										},
										Background =
										{
											Alpha = 0.6,
											Color = { R = 0, G = 0, B = 0 },
											Texture = "EA_TintableImage",
											TextureDimensions = { Width = 1, Height = 1 }, -- EA_TintableImage.dds is 128x128
										},
										Fill =
										{
											Texture = "SharedMediaBantoBar",
											TextureDimensions = { Width = 256, Height = 32 },
											Alpha = 1,
											Priority = Obsidian.Castbar.FillPriority.Normal,
										},
										Name =
										{
											Enabled = true,
											X = 4,
											Y = 0,
											Scale = 0.8,
											Font = "font_clear_small",
											Color = { R = 255, G = 255, B = 255 },
											Alpha = 1,
											Width = 0.75,
											Alignment = "leftcenter",
										},
										Timer =
										{
											Enabled = true,
											X = -4,
											Y = 0,
											Scale = 0.8,
											Font = "font_clear_small",
											Color = { R = 255, G = 255, B = 255 },
											Alpha = 1,
											Alignment = "rightcenter",
										},
									},]]
			General = 
			{
				Fill = 
				{
					TextureDimensions = 
					{
						Height = 32,
						Width = 256,
					},
					Priority = 2,
					Alpha = 1,
					Texture = "SharedMediaBantoBar",
				},
				Background = 
				{
					Color = 
					{
						B = 0,
						G = 0,
						R = 0,
					},
					TextureDimensions = 
					{
						Height = 1,
						Width = 1,
					},
					Alpha = 0.6,
					Texture = "EA_TintableImage",
				},
				Name = 
				{
					Enabled = true,
					Scale = 0.8,
					Alpha = 1,
					Width = 0.75,
					Y = 0,
					X = 4,
					Alignment = "leftcenter",
					Color = 
					{
						B = 255,
						G = 255,
						R = 255,
					},
					Font = "font_clear_small",
				},
				Spacing = 1,
				Timer = 
				{
					Enabled = true,
					X = -4,
					Alignment = "rightcenter",
					Font = "font_clear_small",
					Scale = 0.8,
					Color = 
					{
						B = 255,
						G = 255,
						R = 255,
					},
					Alpha = 1,
					Y = 0,
				},
				MaximumThreshold = 3600,
				FixedDuration = 0,
				Size = 
				{
					Height = 15,
					Border = 0,
					Width = 170,
				},
			},
--[[			Friendly =
			{
				Enabled = true,
				ShowBuffs = true,
				ShowDebuffs = false,
				MaximumEffects = 5,
				X = 0,
				Y = -1,
				Position = Obsidian.EffectContainer.Position.TopLeft,
				Color = { R = 0, G = 22, B = 165 },
				FillType = Obsidian.EffectBar.FillType.EffectType,
				Icon =
				{
					Enabled = true,
					X = -3,
					Y = 0,
					Alpha = 1,
					Position = Obsidian.EffectBar.IconPosition.Left,
					Scale = 1,
				},
			},]]
			Friendly = 
			{
				Enabled = false,
				Color = 
				{
					B = 165,
					G = 22,
					R = 0,
				},
				ShowBuffs = true,
				FillType = 1,
				Y = -1,
				MaximumEffects = 5,
				Position = 1,
				X = 0,
				Icon = 
				{
					Enabled = true,
					X = -3,
					Position = 1,
					Scale = 1,
					Alpha = 1,
					Y = 0,
				},
				ShowDebuffs = false,
			},
--[[			Hostile =
			{
				Enabled = true,
				ShowBuffs = false,
				ShowDebuffs = true,
				MaximumEffects = 5,
				X = 0,
				Y = -1,
				Position = Obsidian.EffectContainer.Position.TopRight,
				Color = { R = 0, G = 22, B = 165 },
				FillType = Obsidian.EffectBar.FillType.EffectType,
				Icon =
				{
					Enabled = true,
					X = 3,
					Y = 0,
					Alpha = 1,
					Position = Obsidian.EffectBar.IconPosition.Right,
					Scale = 1,
				},
			},]]
			Hostile = 
			{
				Enabled = false,
				Color = 
				{
					B = 165,
					G = 22,
					R = 0,
				},
				ShowBuffs = false,
				FillType = 1,
				Y = -1,
				MaximumEffects = 5,
				Position = 2,
				X = 0,
				Icon = 
				{
					Enabled = true,
					X = 3,
					Position = 2,
					Scale = 1,
					Alpha = 1,
					Y = 0,
				},
				ShowDebuffs = true,
			},
		};
	end

end

function Obsidian.GetCastBar()
	return castbar;
end

function Obsidian.GetGlobalCooldownBar()
	return globalCooldown;
end

function Obsidian.GetHostileEffectsTracker()
	return hostileEffects;
end

function Obsidian.GetHostileFriendlyTracker()
	return friendlyEffects;
end

local function AnchorEffectTracker(container, settings)
	local pointOnAnchor, pointOnSelf = "topleft", "bottomleft";
	local anchorTo = castbar:GetName();
	
	if (settings.Position == Obsidian.EffectContainer.Position.TopLeft) then
		 pointOnAnchor, pointOnSelf = "topleft", "bottomleft";
	elseif (settings.Position == Obsidian.EffectContainer.Position.TopRight) then
		 pointOnAnchor, pointOnSelf = "topright", "bottomright";
	elseif (settings.Position == Obsidian.EffectContainer.Position.BottomLeft) then
		 pointOnAnchor, pointOnSelf = "bottomleft", "topleft";
	elseif (settings.Position == Obsidian.EffectContainer.Position.BottomRight) then
		 pointOnAnchor, pointOnSelf = "bottomright", "topright";
	elseif (settings.Position == Obsidian.EffectContainer.Position.FreeUp) then
		 pointOnAnchor, pointOnSelf = "topleft", "topleft";
		 anchorTo = "Root";
	elseif (settings.Position == Obsidian.EffectContainer.Position.FreeDown) then
		 pointOnAnchor, pointOnSelf = "topleft", "topleft";
		 anchorTo = "Root";
	end
	
	container:AnchorTo(anchorTo, pointOnAnchor, pointOnSelf, settings.X, settings.Y);
end

local function SettingsChanged()
	local settings = Obsidian.Settings;
	globalCooldownEnabled = settings.GlobalCooldown.Enabled;
	rangeTintingEnabled = settings.Castbar.Range.Enabled;
	hostileEffectsEnabled = settings.EffectTracker.Hostile.Enabled;
	friendlyEffectsEnabled = settings.EffectTracker.Friendly.Enabled;
	
	castbar:SetLayout();
	
	if (globalCooldownEnabled) then
		globalCooldown:SetLayout();
		
		if (settings.GlobalCooldown.Position == Obsidian.GlobalCooldown.Position.Free) then
			globalCooldown:RegisterLayoutEditor();
		else
			globalCooldown:UnregisterLayoutEditor();
		end
		
		if (settings.GlobalCooldown.Position == Obsidian.GlobalCooldown.Position.Bottom) then
			globalCooldown:AnchorTo(castbar:GetName(), "bottom", "top", settings.GlobalCooldown.X or 0, settings.GlobalCooldown.Y or 0);
		elseif (settings.GlobalCooldown.Position == Obsidian.GlobalCooldown.Position.Top) then
			globalCooldown:AnchorTo(castbar:GetName(), "top", "bottom", settings.GlobalCooldown.X or 0, settings.GlobalCooldown.Y or 0);
		else -- Obsidian.GlobalCooldown.Position.Free
			globalCooldown:AnchorTo("Root", "topleft", "topleft", settings.GlobalCooldown.X or 0, settings.GlobalCooldown.Y or 0);
		end
	else
		globalCooldown:Show(false);
		globalCooldown:UnregisterLayoutEditor();
	end
	
	if (hostileEffectsEnabled) then
		hostileEffects:SetLayout();
		AnchorEffectTracker(hostileEffects, settings.EffectTracker.Hostile);
		if (settings.EffectTracker.Hostile.Position == Obsidian.EffectContainer.Position.FreeUp or settings.EffectTracker.Hostile.Position == Obsidian.EffectContainer.Position.FreeDown) then
			hostileEffects:RegisterLayoutEditor();
		else
			hostileEffects:UnregisterLayoutEditor();
		end
	else
		hostileEffects:ClearAllEffects();
		hostileEffects:Show(false);
		hostileEffects:UnregisterLayoutEditor();
	end
	
	if (friendlyEffectsEnabled) then
		friendlyEffects:SetLayout();
		AnchorEffectTracker(friendlyEffects, settings.EffectTracker.Friendly);
		if (settings.EffectTracker.Friendly.Position == Obsidian.EffectContainer.Position.FreeUp or settings.EffectTracker.Friendly.Position == Obsidian.EffectContainer.Position.FreeDown) then
			friendlyEffects:RegisterLayoutEditor();
		else
			friendlyEffects:UnregisterLayoutEditor();
		end
	else
		friendlyEffects:ClearAllEffects();
		friendlyEffects:Show(false);
		friendlyEffects:UnregisterLayoutEditor();
	end
	
end

function Obsidian.OnSettingsChanged(skipLayout)
	if (skipLayout) then
		SettingsChanged();
	else
		settingsDirty = true;
	end
end

function Obsidian.OnUpdate(elapsed)
	Obsidian.SystemTime = Obsidian.SystemTime + elapsed;
	if (globalCooldownEnabled) then
		globalCooldown:Update(elapsed);
	end
	if (friendlyEffectsEnabled) then
		friendlyEffects:Update(elapsed);
	end
	if (hostileEffectsEnabled) then
		hostileEffects:Update(elapsed);
	end
	if (settingsDirty) then
		settingsDirty = false;
		SettingsChanged();
	end
	castbar:Update(elapsed);
end

function Obsidian.BeginCast()
	castEnded = nil;
	globalCooldownExpected = true;
end

function Obsidian.EndCast(failed)
	if (not failed) then return end
	if (not castEnded) then
		castEnded = Obsidian.SystemTime;
	else
		if (Obsidian.SystemTime  ~= castEnded) then
			Obsidian.Latency = (Obsidian.SystemTime - castEnded); -- in seconds
			-- example showing ms
			-- d(string.format("%dms", (Obsidian.SystemTime - castEnded) * 1000));
		end
		castEnded = nil;
	end
end