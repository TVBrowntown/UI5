BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.ContainerDemo = {};

local localization = BuffHead.Localization.GetMapping();

local SETTINGS_UPDATE_DELAY = 2;
local EFFECT_DURATION = 30;

local friendlyEffects = nil;
local hostileEffects = nil;

local updateRegistered = false;
local demoContainer = nil;
local updateDemo = nil;
local demoNextEffectIn = nil;
local abilityData = nil;
local refreshUpdate = 0;
local activeSettings = nil;

local function CopyTable(t)
	local copiedTable = {};
	for k, v in pairs(t) do
		if (type(v) == "table") then
			copiedTable[k] = CopyTable(v);
		else
			copiedTable[k] = v;
		end
	end
	return copiedTable;
end

local function GetLayout(id)
	if (id) then
		for index, layout in ipairs(BuffHead.Settings.Layouts) do
			if (layout.Settings.Id == id) then
				return layout.Settings or BuffHead.Settings.Layout;
			end
		end
	end
	return BuffHead.Settings.Layout;
end

local function SetupEffects()
	friendlyEffects =
	{
		{
			abilityId = 245,
			castByPlayer = true,
			iconNum = 5004,
			isBuff = true,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = false,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
		},
		{
			abilityId = 8558,
			castByPlayer = true,
			iconNum = 5142,
			isBlessing = true,
			isBuff = false,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			typeColorBlue = 80,
			typeColorGreen = 220,
			typeColorRed = 255,
		},
		{
			abilityId = 3551,
			castByPlayer = true,
			iconNum = 4503,
			isBuff = false,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
		},
		{
			abilityId = 3914,
			castByPlayer = true,
			iconNum = 13342,
			isBuff = true,
			isCasterDispellable = false,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isEnchantment = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			typeColorBlue = 255,
			typeColorGreen = 186,
			typeColorRed = 104,
		},
	};
	
	hostileEffects =
	{
		{
			abilityId = 1616,
			castByPlayer = true,
			iconNum = 4500,
			isAilment = true,
			isBuff = false,
			isDamaging = true,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			trackerPriority = 0,
			typeColorBlue = 255,
			typeColorGreen = 186,
			typeColorRed = 104,
		},
		{
			abilityId = 1589,
			castByPlayer = true,
			iconNum = 4627,
			isBuff = false,
			isDamaging = true,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = false,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
		},
		{
			abilityId = 3913,
			castByPlayer = true,
			iconNum = 13343,
			isBuff = false,
			isDamaging = true,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = false,
			isHex = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			trackerPriority = 0,
			typeColorBlue = 9,
			typeColorGreen = 0,
			typeColorRed = 184,
		},
	};
end

function BuffHead.Setup.ContainerDemo.Initialize()

end

local function CreateContainer()
	
	if (demoContainer) then
		demoContainer:Destroy();
		demoContainer = nil;
	end
	
	local worldObjectNum = GameData.Player.worldObjNum;
	if (activeSettings.ScreenPosition == BuffHead.ScreenPosition.Fixed) then
		worldObjectNum = nil;
	end
	demoContainer = BuffHeadContainer:Create("ContainerDemo", activeSettings.Type, worldObjectNum, activeSettings);
		
end

function BuffHead.Setup.ContainerDemo.Enable(windowName, settings)
	local settings = CopyTable(settings);
	settings.Indicators.Compression = BuffHead.Compression.None;
	settings.Layout = GetLayout(settings.Layout);
	settings.ShowTooltips = false;
	settings.HandleRemovable = false;

	refreshUpdate = 0;
	demoNextEffectIn = nil;
	activeSettings = settings;
	
	if (friendlyEffects == nil or hostileEffects == nil) then
		SetupEffects();
	end

	if (demoContainer == nil) then
		CreateContainer();
	end
	
	if (not updateRegistered) then
		updateRegistered = true;
		demoNextCastIn = nil;
    	RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "BuffHead.Setup.ContainerDemo.OnUpdate");
	end
end

function BuffHead.Setup.ContainerDemo.Disable()
	if (updateRegistered) then
		updateRegistered = false;
		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "BuffHead.Setup.ContainerDemo.OnUpdate");
	end
	if (demoContainer) then
		demoContainer:Destroy();
		demoContainer = nil;
	end
end

local function UpdateEffectFrames(container)
	container.AnchorsDirty = true;
	for index, effectFrame in pairs(container.EffectFrames) do
		if (effectFrame.Frame) then
			effectFrame.Frame:SetLayout(effectFrame.Frame.AbilityData, nil, container.Settings);
		end
	end
end

local function UpdateContainerSettings()
	if (not demoContainer) then return end
	
	local worldObjectNum = GameData.Player.worldObjNum;
	if (activeSettings.ScreenPosition == BuffHead.ScreenPosition.Fixed) then
		worldObjectNum = nil;
	end
	
	if (demoContainer.WorldObjectId ~= worldObjectNum) then
		demoContainer.WorldObjectId = worldObjectNum;
		if (worldObjectNum) then
			WindowClearAnchors(demoContainer:GetName());
		end
		demoContainer:AttachTo(worldObjectNum);
	end
	
	demoContainer.IsFixed = (activeSettings.ScreenPosition == BuffHead.ScreenPosition.Fixed);
	
	demoContainer.Settings = activeSettings;
	demoContainer.Containers.AlwaysShow.ContainerSettings = activeSettings.Containers.AlwaysShow;
	demoContainer.Containers.AlwaysShow.Settings = activeSettings;
	demoContainer.Containers.AlwaysShow.IsFixed = (activeSettings.Containers.AlwaysShow.Placement == BuffHead.Container.Placement.Fixed);
	demoContainer.Containers.AlwaysShow.VisibleEffects = nil;

	if (demoContainer.IsFixed) then
		demoContainer:UpdateFixedPosition();
	end
	
	if (activeSettings.Containers.AlwaysShow.Placement == BuffHead.Container.Placement.Fixed) then
		demoContainer.Containers.AlwaysShow:UpdateFixedPosition();
	end
	
	demoContainer.Containers.Buffs.ContainerSettings = activeSettings.Containers.Buffs;
	demoContainer.Containers.Buffs.Settings = activeSettings;
	demoContainer.Containers.Buffs.IsFixed = (activeSettings.Containers.Buffs.Placement == BuffHead.Container.Placement.Fixed);
	demoContainer.Containers.Buffs.VisibleEffects = nil;
	
	if (activeSettings.Containers.Buffs.Placement == BuffHead.Container.Placement.Fixed) then
		demoContainer.Containers.Buffs:UpdateFixedPosition();
	end
	
	demoContainer.Containers.Debuffs.ContainerSettings = activeSettings.Containers.Debuffs;
	demoContainer.Containers.Debuffs.Settings = activeSettings;
	demoContainer.Containers.Debuffs.IsFixed = (activeSettings.Containers.Debuffs.Placement == BuffHead.Container.Placement.Fixed);
	demoContainer.Containers.Debuffs.VisibleEffects = nil;
	
	if (activeSettings.Containers.Debuffs.Placement == BuffHead.Container.Placement.Fixed) then
		demoContainer.Containers.Debuffs:UpdateFixedPosition();
	end
	
	UpdateEffectFrames(demoContainer.Containers.AlwaysShow);
	UpdateEffectFrames(demoContainer.Containers.Buffs);
	UpdateEffectFrames(demoContainer.Containers.Debuffs);
	
	demoContainer.AnchorsDirty = true;
	demoContainer:AnchorEffects();
end

function BuffHead.Setup.ContainerDemo.OnSettingsChanged()
	activeSettings = BuffHead.Setup.AdvancedContainersItem.GetSettings();	
	updateDemo = SETTINGS_UPDATE_DELAY;
end

local function AddEffects()
	if (not demoContainer) then return end
	local settings = demoContainer.Settings;
	local buffsEnabled = false;
	local debuffsEnabled = false;
	local alwaysShowEnabled = settings.AlwaysShowEnabled;
	
	if (settings.Type == BuffHead.TargetType.Friendly or settings.Type == BuffHead.TargetType.Self) then
		buffsEnabled = (settings.Buffs ~= BuffHead.BuffType.Friendly.None);
		debuffsEnabled = (settings.Debuffs ~= BuffHead.DebuffType.Friendly.None);
	else
		buffsEnabled = (settings.Buffs ~= BuffHead.BuffType.Hostile.None);
		debuffsEnabled = (settings.Debuffs ~= BuffHead.DebuffType.Hostile.None);
	end
	
	local effectIndex = 0;
	if (buffsEnabled) then
		local buffCount = settings.Containers.Buffs.Size.Rows * settings.Containers.Buffs.Size.Columns;
		local effects = {};
		for count = 1, buffCount do
			effectIndex = effectIndex + 1;
			local effect = CopyTable(friendlyEffects[math.random(1, #friendlyEffects)]);
			effect.duration = 10 + (count / buffCount) * (EFFECT_DURATION - 10);
			effect.stackCount = math.random(1, 5);
			effects[effectIndex] = effect;
		end
		demoContainer:AddEffects(effects, BuffHeadContainer.EffectType.Buff, BuffHeadContainer.ContainerType.Buff);
	end
	
	if (debuffsEnabled) then
		local debuffCount = settings.Containers.Debuffs.Size.Rows * settings.Containers.Debuffs.Size.Columns;
		local effects = {};
		for count = 1, debuffCount do
			effectIndex = effectIndex + 1;
			local effect = CopyTable(hostileEffects[math.random(1, #hostileEffects)]);
			effect.duration = 10 + (count / debuffCount) * (EFFECT_DURATION - 10);
			effect.stackCount = math.random(1, 5);
			effects[effectIndex] = effect;
		end
		demoContainer:AddEffects(effects, BuffHeadContainer.EffectType.Debuff, BuffHeadContainer.ContainerType.Debuff);
	end
	
	if (alwaysShowEnabled) then
		local alwaysShowCount = settings.Containers.AlwaysShow.Size.Rows * settings.Containers.AlwaysShow.Size.Columns;
		local effects = {};
		for count = 1, alwaysShowCount do
			effectIndex = effectIndex + 1;
			local effect = CopyTable(friendlyEffects[math.random(1, #friendlyEffects)]);
			effect.duration = 10 + (count / alwaysShowCount) * (EFFECT_DURATION - 10);
			effect.stackCount = math.random(1, 5);
			effects[effectIndex] = effect;
		end
		demoContainer:AddEffects(effects, BuffHeadContainer.EffectType.Buff, BuffHeadContainer.ContainerType.AlwaysShow);
	end
	
end

function BuffHead.Setup.ContainerDemo.OnUpdate(elapsed)	
	
	if (updateDemo) then
		updateDemo = updateDemo - elapsed;
		if (updateDemo <= 0 and demoContainer) then
			updateDemo = nil;
			activeSettings = CopyTable(activeSettings);
			activeSettings.Indicators.Compression = BuffHead.Compression.None;
			activeSettings.Layout = GetLayout(activeSettings.Layout);
			activeSettings.ShowTooltips = false;
			activeSettings.HandleRemovable = false;
			UpdateContainerSettings();
		end
	end
	
	if (demoNextEffectIn == nil) then
		demoNextEffectIn = EFFECT_DURATION + 1;
		if (demoNextEffectIn) then
			AddEffects();
		end
	else
		demoNextEffectIn = demoNextEffectIn - elapsed;
		if (demoNextEffectIn < 0) then
			demoNextEffectIn = nil;
		end
	end
	
	if (demoContainer) then
		local refresh = false;
		if (BuffHead.TimeCount - refreshUpdate >= BuffHead.GetUpdateThrottle()) then
			refresh = true;
			refreshUpdate = BuffHead.TimeCount;
		end
		demoContainer:Update(elapsed, refresh);
	end
	
end