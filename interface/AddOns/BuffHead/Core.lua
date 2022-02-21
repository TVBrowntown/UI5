BuffHead = BuffHead or {};

local VERSION_SETTINGS = 9;
local UPDATE_THROTTLE = 0.1;
local STUCK_THROTTLE = 1;
local updateThrottle = 0.1;

BuffHead.TimeCount = 0;
BuffHead.FriendlyTarget = { IsNpc = false, WorldObjectId = 0, Name = L"" };
BuffHead.HostileTarget =  { IsNpc = false, WorldObjectId = 0, Name = L"" };
BuffHead.ActiveContainers = {};
BuffHead.Containers = {};
BuffHead.Location = { X = 0, Y = 0 };
BuffHead.GroupMemberObjectCache = {};

BuffHead.LayoutRevision = 0; -- when the layout gets modified
BuffHead.ContainerRevision = 0; -- when the container settings are modified

BuffHead.BuffType = 
{
	Friendly = { None = 1, CastByMe = 2, All = 3 },
	Hostile = { None = 1, RemovableByMe = 2, All = 3 },
};
BuffHead.DebuffType = 
{
	Friendly = { None = 1, CurableByMe = 2, All = 3 },
	Hostile = { None = 1, CastByMe = 2, All = 3 },
};
BuffHead.TargetType = { Self = 1, Group = 2, Friendly = 3, Hostile = 4 };

BuffHead.ColorType = { EffectColor = 1, EffectType = 2, Custom = 3 };

BuffHead.Container = 
{
	Anchor = { Anchor = 1, AlwaysShow = 2, Buffs = 3, Debuffs = 4 },
	Placement = { After = 1, Below = 2, Fixed = 3 },
	Growth =
	{
		Vertical = { Up = 1, Down = 2 },
		Horizontal = { Left = 1, Right = 2 },
	},
};
BuffHead.Sorting = 
{
	Type = { Duration = 1, Ability = 2 },
	Direction = { Ascending = 1, Descending = 2 },
};
BuffHead.ScreenPosition = { Fixed = 1, Attached = 2 };

BuffHead.Display = 
{
	Duration =
	{
		Format = { Default = 1, Simple = 1, SimpleWithSeconds = 2, CompactingWithSeconds = 3, SimpleCompacting = 4 },
	},
	StatusBar =
	{
		Orientation = { Horizontal = 1, Vertical = 2 },
	},
};

BuffHead.Compression = { None = 1, OnlyMine = 2, OnlyOthers = 3, All = 4 };
BuffHead.EffectAnchoring = { OnUpdate = 1, OnGeneralUpdate = 2 };
BuffHead.PriorityAnimation = { None = 1, AnimatedBorder = 2, AnimatedBorderThick = 3 };

BuffHead.Sync = { Total = 0, Count = 0, Delay = 0 };
		
local lastUpdate = 0;
local lastStuckCheck = 0;
local lastSlainTimestamp = nil;
local groupTrackingEnabled = false;
local selfTrackingEnabled = false;
local nameToId = {};

local isLibSlashRegistered = false;
local isLibAddonButtonRegistered = false;
local localization = BuffHead.Localization.GetMapping();

local function RegisterLibs()
	if (not isLibSlashRegistered) then
		if (LibSlash) then
			LibSlash.RegisterWSlashCmd("buffhead", function(args) BuffHead.SlashCommand(args) end);
			isLibSlashRegistered = true;
		end
	end

	if (not isLibAddonButtonRegistered) then
		if (LibAddonButton) then
			LibAddonButton.Register("fx");
			LibAddonButton.AddMenuItem("fx", "BuffHead", BuffHead.Setup.Show);
			isLibAddonButtonRegistered = true;
		end
	end
end

local function RecentDeath()
	local indexOfLastEntry = TextLogGetNumEntries("Chat") - 1;
	if (indexOfLastEntry <= 0) then return end
	
	local timestamp, _, msg = TextLogGetEntry("Chat", indexOfLastEntry);
	local hasSlain = (string.find(tostring(msg), tostring(localization["Core.HaveSlain"])) or string.find(tostring(msg), tostring(localization["Core.HasSlain"])));
	
	if (timestamp and hasSlain) then
		-- Due to the advice chat cleanup, it's now possible to have a dead chat, where the last entry will be
		-- "has slain x" for a while. To counter this, remember the last timestamp and when it was recorded.
		-- Only pass true if an existing timestamp is less than a second old
		if (lastSlainTimestamp and lastSlainTimestamp.Timestamp == timestamp) then
			return (BuffHead.TimeCount - lastSlainTimestamp.SystemTime <= 1);
		else
			lastSlainTimestamp = { Timestamp = timestamp, SystemTime = BuffHead.TimeCount };
		end
	end
	
	return hasSlain;
end

local function IsPermanentContainer(id)
	if (id == BuffHead.FriendlyTarget.WorldObjectId or id == BuffHead.HostileTarget.WorldObjectId or id == GameData.Player.worldObjNum or BuffHead.GroupMemberObjectCache[id]) then
		return true;
	end
	return false;
end

local function GetTargetType(id)
	if (id == GameData.Player.worldObjNum) then
		return BuffHead.TargetType.Self;
	elseif (BuffHead.GroupMemberObjectCache[id]) then
		return BuffHead.TargetType.Group;
	elseif (id == BuffHead.HostileTarget.WorldObjectId) then
		return BuffHead.TargetType.Hostile;
	elseif (id == BuffHead.FriendlyTarget.WorldObjectId) then
		return BuffHead.TargetType.Friendly;
	end
	
	return BuffHead.TargetType.Friendly;
end

local function IsTrackerEnabled(targetType)
	if (targetType == BuffHead.TargetType.Hostile and not BuffHead.Settings.Trackers.Hostile.Enabled) then
		return false;
	elseif (targetType == BuffHead.TargetType.Friendly and not BuffHead.Settings.Trackers.Friendly.Enabled) then
		return false;
	elseif (targetType == BuffHead.TargetType.Group and not BuffHead.Settings.Trackers.Group.Enabled) then
		return false;
	elseif (targetType == BuffHead.TargetType.Self and not BuffHead.Settings.Trackers.Self.Enabled) then
		return false;
	end
	
	return true;
end

function BuffHead.Initialize()

	--d("BuffHead Init")
	CreateWindowFromTemplate("RootFrame", "BuffHeadContainerTemplate", "Root")
	local dimensionsx, dimensionsy = WindowGetDimensions("Root")
	WindowSetDimensions("RootFrame", dimensionsx, dimensionsy)
  	WindowClearAnchors("RootFrame")
  	WindowAddAnchor("RootFrame", "center", "Root", "center", 0, 0)
 	WindowSetShowing("RootFrame", true)
	

	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "BuffHead.OnTargetEffectsUpdated");
	RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "BuffHead.OnTargetUpdated");
	RegisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED, "BuffHead.OnPlayerPositionUpdated");
	RegisterEventHandler(TextLogGetUpdateEventId("Combat"), "BuffHead.OnCombatLogUpdated");
	RegisterEventHandler(SystemData.Events.LOADING_END, "BuffHead.OnLoadingEnd");
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "BuffHead.OnLoadingEnd");
	table.insert(LayoutEditor.EventHandlers, BuffHead.OnLayoutEditorFinished);
	
	LibGroup.Register(LibGroup.Events.GROUP_MEMBER_ADDED, BuffHead.OnGroupMemberAdded);
	LibGroup.Register(LibGroup.Events.GROUP_MEMBER_REMOVED, BuffHead.OnGroupMemberRemoved);
	LibGroup.Register(LibGroup.Events.GROUP_MEMBER_WORLD_OBJECT_CHANGED, BuffHead.OnGroupMemberWorldObjectChanged);
	
	RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "BuffHead.RecheckFrames");	
	

	BuffHead.LoadSettings();
	BuffHead.Setup.Initialize();
	
	BuffHead.AdvancedCompression.Clear();
	BuffHead.AdvancedCompression.Load();
	
	BuffHead.AdvancedContainers.Clear();
	BuffHead.AdvancedContainers.Load();
	
	BuffHead.SetTrackers();
	BuffHead.UpdateDelay();
end

function BuffHead.RecheckFrames()
	local frames = FrameManager.m_Frames;
	local flag = false;
	for index, content in pairs(frames) do
		if (index:match("BuffHeadEffectFrame*")) then
			if not(DoesWindowExist(index)) then
				d("Bad record. Removing:")
				d(index)	
				FrameManager.m_Frames[index] = nil;
			end
		end
	end
end
	

function BuffHead.RefreshPlayerBuffs()
	local buffData = GetBuffs(GameData.BuffTargetType.SELF);
	if (buffData ~= nil) then
		BuffHead.OnGroupEffectsUpdated(buffData, true);
	end
end

function BuffHead.OnGroupMemberAdded(groupMember)
	BuffHead.WorldObjectIdChanged(groupMember.WorldObjectId, nil, groupMember.Name, groupMember);
end

function BuffHead.OnGroupMemberRemoved(groupMember)
	BuffHead.WorldObjectIdChanged(nil, groupMember.WorldObjectId, groupMember.Name, groupMember);
end

function BuffHead.OnGroupMemberWorldObjectChanged(oldWorldObject, newWorldObject, groupMember)
	BuffHead.WorldObjectIdChanged(newWorldObject, oldWorldObject, groupMember.Name, groupMember);
end

function BuffHead.OnLayoutEditorFinished(exitCode)
	if (exitCode ~= LayoutEditor.EDITING_END) then return end
	BuffHead.AdvancedContainers.OnLayoutEditorFinished();
end

function BuffHead.SetTrackers()
	BuffHead.SetSelfTracking();
	BuffHead.SetGroupTracking();
end

function BuffHead.SetSelfTracking()
	local enabled = BuffHead.Settings.Trackers.Self.Enabled;
	if (not enabled) then
		for index, advancedContainer in ipairs(BuffHead.Settings.AdvancedContainers) do
			if (advancedContainer.Type == BuffHead.TargetType.Self) then
				enabled = true;
				break;
			end
		end
	end
	if (enabled == selfTrackingEnabled) then return end
	
	if (enabled) then
		RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "BuffHead.OnGroupEffectsUpdated");
	else
		UnregisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "BuffHead.OnGroupEffectsUpdated");
		BuffHead.DestroyContainer(GameData.Player.worldObjNum);
	end
	
	selfTrackingEnabled = enabled;
end

function BuffHead.SetGroupTracking()
	local enabled = BuffHead.Settings.Trackers.Group.Enabled;
	if (enabled == groupTrackingEnabled) then return end
	
	if (enabled) then
		RegisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED, "BuffHead.OnGroupEffectsUpdated");
	else
		UnregisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED, "BuffHead.OnGroupEffectsUpdated");
		
		if (BuffHead.GroupMemberObjectCache) then
			for objectId,_ in pairs(BuffHead.GroupMemberObjectCache) do
				--d("Set group tracking")
				--d(objectId)
				BuffHead.GroupMemberObjectCache[objectId] = nil;
				BuffHead.DestroyContainer(objectId);
			end
		end
		
	end
	
	groupTrackingEnabled = enabled;
end

local function UpdateFilterLists(settings)
	if (settings == nil) then return end
	
	if (settings.AlwaysShow) then
		local temp = {};
		for id, value in pairs(settings.AlwaysShow) do
			if (tostring(tonumber(id)) == id) then
				temp[tonumber(id)] = value;
			else
				temp[id] = value;
			end
		end
		settings.AlwaysShow = temp;
	end
	
	if (settings.AlwaysIgnore) then
		local temp = {};
		for id, value in pairs(settings.AlwaysIgnore) do
			if (tostring(tonumber(id)) == id) then
				temp[tonumber(id)] = value;
			else
				temp[id] = value;
			end
		end
		settings.AlwaysIgnore = temp;
	end
end

local function UpdateSettings()
	local settings = BuffHead.Settings;
	local version = settings.Version;

	-- changes from version to version go here
	if (version == nil) then
		version = "2.0";
		if (settings.Display) then
			settings.Display.Layer = 2; --BuffHead.Display.Layer.Default;
		end
	end
	
	if (version == "2.0") then
		version = "2.0.1";
	end
	
	if (version == "2.0.1") then
		version = "2.0.2";
	end
	
	if (version == "2.0.2") then
		version = "2.0.3";
		if (settings.Sorting) then
			settings.Sorting.DisplayFirst = nil;
		end
		if (settings.Container) then
			settings.Container = nil;
		end
		if (settings.Trackers) then
			if (settings.FriendlyEffects) then
				settings.Trackers.Friendly = 
				{
					Enabled = true,
					Buffs = settings.FriendlyEffects.Buffs,
					Debuffs = settings.FriendlyEffects.Debuffs,
					Permanent = settings.FriendlyEffects.Permanent,
					AlwaysShow = {},
					AlwaysIgnore = {},
				};
				settings.FriendlyEffects = nil;
			end
			if (settings.HostileEffects) then
				settings.Trackers.Hostile = 
				{
					Enabled = true,
					Buffs = settings.HostileEffects.Buffs,
					Debuffs = settings.HostileEffects.Debuffs,
					Permanent = settings.HostileEffects.Permanent,
					AlwaysShow = {},
					AlwaysIgnore = {},
				};
				settings.HostileEffects = nil;
			end
			
			local selfTracker = (settings.Trackers.Self == true);
			settings.Trackers.Self = 
			{
				Enabled = selfTracker,
				Buffs = BuffHead.BuffType.Friendly.CastByMe,
				Debuffs = BuffHead.DebuffType.Friendly.CurableByMe,
				Permanent = false,
				AlwaysShow = {},
				AlwaysIgnore = {},
			};
			
			local groupTracker = (settings.Trackers.Group == true);
			settings.Trackers.Group = 
			{
				Enabled = groupTracker,
				Buffs = BuffHead.BuffType.Friendly.CastByMe,
				Debuffs = BuffHead.DebuffType.Friendly.CurableByMe,
				Permanent = false,
				AlwaysShow = {},
				AlwaysIgnore = {},
			};
		end
		if (settings.Display) then
			settings.Display.Font = "font_clear_small";
		end
	end
	
	if (version == "2.0.3") then
		version = "2.0.4";
		
		if (settings.Indicators) then
			if (settings.Indicators.Compression == true) then
				settings.Indicators.Compression = BuffHead.Compression.All;
			else
				settings.Indicators.Compression = BuffHead.Compression.None;
			end
		end
		
		if (settings.Display) then
			settings.Display.StackCount = 5; --BuffHead.Display.StackCount.BottomRight;
			settings.Display.DurationFormat = BuffHead.Display.Duration.Format.Default;
		end
	end
	
	if (version == "2.0.4") then
		version = "2.0.5";
	end
	
	if (version == "2.0.5") then
		version = 6;
		
		if (settings.Performance) then
			settings.Performance.MaximumUpdates = 0;
			settings.Performance.EffectAnchoring = BuffHead.EffectAnchoring.OnGeneralUpdate;
		end
		if (settings.Trackers.Friendly) then
			settings.Trackers.Friendly.OnTargetChange =
			{
				ClearAlwaysShow = false,
				ClearBuffs = false,
				ClearDebuffs = false,
			};
		end
		if (settings.Trackers.Hostile) then
			settings.Trackers.Hostile.OnTargetChange =
			{
				ClearAlwaysShow = false,
				ClearBuffs = false,
				ClearDebuffs = false,
			};
		end
		if (settings.Display) then
			settings.Display.StackFont = "font_clear_small_bold";
		end
		settings.Scale = 1;
	end
	
	if (version == 6) then
		version = 7;
		
		if (settings.Display and settings.Display.Layer) then
			settings.Layer = settings.Display.Layer;
		end
		
		settings.Size = nil;
		settings.Borders = nil;
		settings.Display = nil;
	end
	
	if (version == 7) then
		version = 8;
		
		local x, y = settings.X or 0, settings.Y or -20;
		settings.X = nil;
		settings.Y = nil;
		settings.Offset = { X = x, Y = y };
		
		UpdateFilterLists(settings);
		if (settings.Trackers) then
			UpdateFilterLists(settings.Trackers.Self);
			UpdateFilterLists(settings.Trackers.Group);
			UpdateFilterLists(settings.Trackers.Friendly);
			UpdateFilterLists(settings.Trackers.Hostile);
		end
		
		if (settings.Layouts) then
			for index, layout in ipairs(settings.Layouts) do
				if (layout.Settings) then
					layout.Settings.Id = BuffHead.Setup.Layout.GenerateUniqueId();
				end
			end
		end
	end
	
	if (version == 8) then
		version = 9;
		if (settings.AdvancedContainers) then
			for index, advancedContainer in ipairs(settings.AdvancedContainers) do
				advancedContainer.MaximumThreshold = settings.MaximumThreshold or 60;
			end
		end
	end
	
	if (version == 9) then
		version = 10;
	end
end

-- For testing purposes. This function will create X amount of random indicators
function BuffHead.Test(count)
	if (not count) then
		count = 10;
	end

	local effects = {};
	
	local icons = { 4627, 8020, 7966, 7969, 8049, 7913, 8015, 7940 };

	local ability = {};
	for index=1,count do
		ability = {};
		ability.iconNum = icons[math.random(1, #icons)];
		ability.abilityId = math.random(1000, 1100);
		ability.isHex = true;
		ability.name = L"Test";
		ability.duration = 86410;
		ability.castByPlayer = false;
		ability.stackCount = 0;
		
		effects[index] = ability;
	end
	
	BuffHead.UpdateEffects(GameData.Player.worldObjNum, effects, true, "", BuffHead.TargetType.Self);
end

function BuffHead.LoadSettings()
	if (not BuffHead.Settings) then
		BuffHead.Settings = {};
	else
		UpdateSettings();
	end
	
	local settings = BuffHead.Settings;
	settings.Version = VERSION_SETTINGS;

	if (not settings.Trackers) then
		settings.Trackers = {};
	end
	
	if (not settings.Indicators) then
		settings.Indicators = 
		{
			Compression = BuffHead.Compression.None,
			Padding = 
			{
				X = 0,
				Y = 5
			},
		};
	end

	if (not settings.Trackers.Self) then
		settings.Trackers.Self = 
		{
			Enabled = true,
			Buffs = BuffHead.BuffType.Friendly.CastByMe,
			Debuffs = BuffHead.DebuffType.Friendly.CurableByMe,
			Permanent = false,
			AlwaysShow = {},
			AlwaysIgnore = {},
		};
	end

	if (not settings.Trackers.Group) then
		settings.Trackers.Group = 
		{
			Enabled = true,
			Buffs = BuffHead.BuffType.Friendly.CastByMe,
			Debuffs = BuffHead.DebuffType.Friendly.CurableByMe,
			Permanent = false,
			AlwaysShow = {},
			AlwaysIgnore = {},
		};
	end

	if (not settings.Trackers.Friendly) then
		settings.Trackers.Friendly = 
		{
			Enabled = true,
			Buffs = BuffHead.BuffType.Friendly.CastByMe,
			Debuffs = BuffHead.DebuffType.Friendly.CurableByMe,
			Permanent = false,
			AlwaysShow = {},
			AlwaysIgnore = {},
			OnTargetChange =
			{
				ClearAlwaysShow = false,
				ClearBuffs = false,
				ClearDebuffs = false,
			},
		};
	end

	if (not settings.Trackers.Hostile) then
		settings.Trackers.Hostile = 
		{
			Enabled = true,
			Buffs = BuffHead.BuffType.Hostile.None,
			Debuffs = BuffHead.DebuffType.Hostile.CastByMe,
			Permanent = false,
			AlwaysShow = {},
			AlwaysIgnore = {},
			OnTargetChange =
			{
				ClearAlwaysShow = false,
				ClearBuffs = false,
				ClearDebuffs = false,
			},
		};
	end
	
	if (not settings.MaximumThreshold) then
		settings.MaximumThreshold = 60;
	end
	if (not settings.Scale) then
		settings.Scale = 1;
	end
	if (not settings.Offset) then
		settings.Offset = { X = 0, Y = -20 };
	end
	if (not settings.Layer) then
		settings.Layer = 1;
	end
	if (not settings.AlwaysIgnore) then
		settings.AlwaysIgnore = {};
	end
	if (not settings.AlwaysShow) then
		settings.AlwaysShow = 
		{
			-- Unstoppable: 402-407, 412-414
			-- Immovable: 408
			-- Root Ward: 400
			-- Freedom: 411
			[402] = true, -- Unstoppable
			[403] = true,
			[404] = true,
			[405] = true,
			[406] = true,
			[407] = true,
			[412] = true,
			[413] = true,
			[414] = true,
			[408] = true, -- Immovable
			Unstoppable = true, 
			Immovable = true
		};
	end
	
	if (not settings.Sorting) then
		settings.Sorting = 
		{
			Enabled = true,
			Type = BuffHead.Sorting.Type.Duration,
			Direction = BuffHead.Sorting.Direction.Descending,
		};
	end
	
	if (not settings.Containers) then
		settings.Containers = {};
		settings.Containers.AlwaysShow = 
		{
			Placement = BuffHead.Container.Placement.After,
			Anchor = BuffHead.Container.Anchor.Anchor,
			Size = { Rows = 1, Columns = 10 },
		};
		settings.Containers.Buffs = 
		{
			Placement = BuffHead.Container.Placement.After,
			Anchor = BuffHead.Container.Anchor.AlwaysShow,
			Size = { Rows = 1, Columns = 10 },
		};
		settings.Containers.Debuffs = 
		{
			Placement = BuffHead.Container.Placement.After,
			Anchor = BuffHead.Container.Anchor.Buffs,
			Size = { Rows = 1, Columns = 10 },
		};
		settings.Containers.Padding = 
		{
			X = 0,
			Y = 5
		};
	end
	
	if (not settings.Performance) then
		settings.Performance = 
		{
			GeneralDelay = 1,
			PriorityUpdate = true,
			PriorityStart = 3,
			PriorityDelay = 0.1,
			MaximumUpdates = 0,
			EffectAnchoring = BuffHead.EffectAnchoring.OnGeneralUpdate,
		};		
	end
	
	if (not settings.Fading) then
		settings.Fading = 
		{
			Enable = true,
		};
	end
	
	if (not settings.Sync) then
		BuffHead.Settings.Sync = 
		{
			Enable = true,
			ResyncEvery = 10,
		};
	end
	
	if (not settings.Layout) then
		settings.Layout =
		{
			Width = 48,
			Height = 48,
			
			Icon =
			{
				X = 0,
				Y = 0,
				Width = 48,
				Height = 48,
				Scale = 1,
				Alpha = 1,
				Layer = 1,
				
				Border =
				{
					Alpha = 1,
					Type = BuffHead.ColorType.EffectColor,
					Color = { R = 0, G = 0, B = 0 },
				},
			},
			StatusBar =
			{
				X = 0,
				Y = 48,
				Width = 48,
				Height = 16,
				Scale = 1,
				Layer = 1,
				
				Background = 
				{
					Color = { R = 0, G = 0, B = 0 },
					Alpha = 0.8,
					Texture = "EA_TintableImage",
					TextureDimensions = { Width = 128, Height = 128 },
					Stretch = true,
				},
				Foreground = 
				{
					Color = { R = 255, G = 255, B = 255 },
					Alpha = 1,
					Type = BuffHead.ColorType.EffectColor,
					Texture = "EA_TintableImage",
					TextureDimensions = { Width = 128, Height = 128 },
					Stretch = true,
				},
				
				Orientation = BuffHead.Display.StatusBar.Orientation.Horizontal,
				Reverse = false,
				Enabled = false,
			},
			Duration =
			{
				X = 0,
				Y = 30,
				Width = 48,
				Height = 16,
				Scale = 1,
				Alpha = 1,
				Layer = 2,
				
				Color = { R = 255, G = 255, B = 255 },
				Font = "font_clear_small_bold",
				Format = BuffHead.Display.Duration.Format.CompactingWithSeconds,
				Alignment = "center",
			},
			StackCount =
			{
				X = 0,
				Y = 2,
				Width = 48,
				Height = 16,
				Scale = 1,
				Alpha = 1,
				Layer = 2,
				
				Color = { R = 255, G = 255, B = 255 },
				Font = "font_clear_small_bold",
				Alignment = "rightcenter",
			},
			Name =
			{
				X = 50,
				Y = 12,
				Width = 48,
				Height = 16,
				Scale = 1,
				Alpha = 0,
				Layer = 2,
				
				Color = { R = 255, G = 255, B = 255 },
				Font = "font_clear_small",
				Alignment = "leftcenter",
			},
		};
	end
	if (not settings.Layouts) then
		settings.Layouts = {};
	end
	if (not settings.AdvancedCompression) then
		settings.AdvancedCompression = {};
	end
	if (not settings.AdvancedContainers) then
		settings.AdvancedContainers = {};
	end
	if (not settings.PriorityEffects) then
		settings.PriorityEffects =
		{
			SortToFront = true,
			Animation = BuffHead.PriorityAnimation.AnimatedBorder,
			Effect = {},
		};
	end
end

function BuffHead.SlashCommand(args)
	local option, value = args:match(L"([a-z0-9]+)[ ]?(.*)");
	
	if (type(option) == "wstring") then
		option = option:lower();
	end
	
	if (option == L"default" or option == L"reset") then
		--restore default settings
		BuffHead.AdvancedCompression.Clear();
		BuffHead.AdvancedContainers.Clear();
		BuffHead.DestroyAllContainers();
		
		BuffHead.Settings = nil;
		BuffHead.LoadSettings();
		
		BuffHead.Setup.LoadSettings();
		BuffHead.Setup.Layout.LoadSettings();
		BuffHead.AdvancedCompression.Load();
		BuffHead.AdvancedContainers.Load();
		BuffHead.LayoutRevision = (BuffHead.LayoutRevision or 0) + 1;
	elseif (option == L"reset layout") then
		--restore default settings
		BuffHead.Settings.Layout = nil;
		BuffHead.LoadSettings();
		
		BuffHead.Setup.LoadSettings();
		BuffHead.Setup.Layout.LoadSettings();
		BuffHead.DestroyAllContainers();
		BuffHead.LayoutRevision = (BuffHead.LayoutRevision or 0) + 1;
	elseif (option == L"cache") then
		BuffHead.Setup.EffectCache.Show();
	else
		BuffHead.Setup.Show();
	end
end

function BuffHead.OnLoadingEnd()
	RegisterLibs();

	BuffHead.Sync = { Total = 0, Count = 0, Delay = 0 };

	BuffHead.DestroyAllContainers();
	BuffHead.FrameManager.DestroyFrames(); -- clear out the frame cache

	nameToId = {};
	
	BuffHead.RefreshPlayerBuffs();
end

function BuffHead.DestroyAllContainers()
	for index, container in pairs(BuffHead.Containers) do
		--d("Destroy all containers")
		--d(index)
		BuffHead.DestroyContainer(index);
		--d("-Destroy all containers")
	end
	BuffHead.AdvancedContainers.ResetAllContainers();
end

function BuffHead.ClearAllEffects(id)
	if (BuffHead.Containers[id]) then
		--d("Core clear all effects")
		for index, content in pairs(BuffHead.Containers[id]) do
			--d(index)
		end
		BuffHead.Containers[id]:ClearAllEffects();
		--d("- Core clear all effects")
	end	
end

function BuffHead.OnCombatLogUpdated(updateType, filterType)
	--d("onCombatLogUpdated")
	if (updateType ~= SystemData.TextLogUpdate.ADDED) then return end
	if (filterType ~= SystemData.ChatLogFilters.RVR_KILLS_ORDER and filterType ~= SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION) then return end
	
    local message = "";
    local indexOfLastEntry = TextLogGetNumEntries("Combat") - 1;
    
    _, _, message = TextLogGetEntry("Combat", indexOfLastEntry);    
	
	local victim, verb, player, weapon, location = localization["CombatMessageParser"](message);

	if (not (victim and verb and player and weapon and location)) then
		return;
	end
	
	victim = victim:match(L"([^^]+)^?([^^]*)");
	
	if (nameToId[victim]) then
		BuffHead.DestroyContainer(nameToId[victim]);
	end
	--d("- onCombatLogUpdated")
end

function BuffHead.WorldObjectIdChanged(newWorldObjectId, oldWorldObjectId, targetName, groupMember)
	if (oldWorldObjectId == newWorldObjectId) then return end
	
	if (groupMember) then
		if (oldWorldObjectId and oldWorldObjectId ~= 0) then
			BuffHead.GroupMemberObjectCache[oldWorldObjectId] = nil;
			BuffHead.DestroyContainer(oldWorldObjectId);
		end
			
		if (newWorldObjectId and newWorldObjectId ~= 0) then			
			BuffHead.GroupMemberObjectCache[newWorldObjectId] = true;
			--groupMember.WorldObjectId = newWorldObjectId;
		end
	end
		
	if (targetName and targetName ~= L"") then
		BuffHead.DestroyContainer(nameToId[targetName]);
		if (newWorldObjectId and newWorldObjectId ~= 0) then
			nameToId[targetName] = newWorldObjectId;
		end
	end
	--d("- WorldObjectID")
end

local function CheckTargetObject(target)
	if (target.IsNpc or target.Name == L"") then return end

	local groupMember = LibGroup.GroupMembers.ByName[target.Name];
	if (groupMember and groupMember.IsValid) then
		BuffHead.WorldObjectIdChanged(target.WorldObjectId, groupMember.WorldObjectId, groupMember.Name, groupMember);
	elseif (not groupMember) then
		if (nameToId[target.Name]) then
			BuffHead.WorldObjectIdChanged(target.WorldObjectId, nameToId[target.Name], target.Name);
		end
	end
end

local function IsNpc(unitType)
	if (unitType == SystemData.TargetObjectType.SELF or unitType == SystemData.TargetObjectType.ALLY_PLAYER or unitType == SystemData.TargetObjectType.ENEMY_PLAYER) then
		return false;
	end
	
	return true;
end

local function UpdateTrackerOnTargetChanged(worldObjectId, tracker)
	if (not worldObjectId or worldObjectId == 0) then return end
	
	local container = BuffHead.Containers[worldObjectId];
	if (not container) then return end
	
	if (container.TargetType == BuffHead.TargetType.Self or container.TargetType == BuffHead.TargetType.Group) then
		return;
	end
	--d("Update tracker on target changed")
	if (tracker.OnTargetChange.ClearAlwaysShow and tracker.OnTargetChange.ClearBuffs and tracker.OnTargetChange.ClearDebuffs) then
		BuffHead.DestroyContainer(worldObjectId);
	else
		if (tracker.OnTargetChange.ClearAlwaysShow) then
			--d("clear all effects always show")
			container.Containers.AlwaysShow:ClearAllEffects();
		end
		if (tracker.OnTargetChange.ClearBuffs) then
			--d("clear all effects always buffs")		
			container.Containers.Buffs:ClearAllEffects();
		end
		if (tracker.OnTargetChange.ClearDebuffs) then
			--d("clear all effects always debuffs")
			container.Containers.Debuffs:ClearAllEffects();
		end
	end
end

local function HostileTargetChanged(worldObjectId)
	local hostileTracker = BuffHead.Settings.Trackers.Hostile;
	if (not hostileTracker.Enabled) then return end
	
	UpdateTrackerOnTargetChanged(worldObjectId, hostileTracker);
end

local function FriendlyTargetChanged(worldObjectId)
	local friendlyTracker = BuffHead.Settings.Trackers.Friendly;
	if (not friendlyTracker.Enabled) then return end
	
	-- update to not change group/self
	UpdateTrackerOnTargetChanged(worldObjectId, friendlyTracker);
end

function BuffHead.OnTargetUpdated(targetType, targetObjectNumber, targetObjectType)
	--d("TargetUpdated")
	TargetInfo:UpdateFromClient();

	if (targetType == "selfhostiletarget" and targetObjectNumber ~= BuffHead.HostileTarget.WorldObjectId) then
		if (targetObjectNumber == 0 and RecentDeath()) then --the theory is, if you just lost your target, and something was just killed, then your target must have died
			--remove buffs from old target
			BuffHead.ClearAllEffects(BuffHead.HostileTarget.WorldObjectId);
			BuffHead.HostileTarget.WorldObjectId = targetObjectNumber;
			BuffHead.HostileTarget.ResyncTime = nil;
			BuffHead.AdvancedContainers.ClearHostile();
		else
			HostileTargetChanged(BuffHead.HostileTarget.WorldObjectId)
				
			BuffHead.HostileTarget.WorldObjectId = targetObjectNumber;
			BuffHead.HostileTarget.Name = L"";
			BuffHead.HostileTarget.IsNpc = IsNpc(TargetInfo:UnitType(targetType));
			if (not BuffHead.HostileTarget.IsNpc) then
				BuffHead.HostileTarget.Name = TargetInfo:UnitName(targetType):match(L"([^^]+)^?([^^]*)");
			end
			BuffHead.HostileTarget.ResyncTime = BuffHead.TimeCount + BuffHead.Settings.Sync.ResyncEvery;
			if (TargetInfo:UnitHealth("selfhostiletarget") == 0) then
				if (BuffHead.Containers[BuffHead.HostileTarget.WorldObjectId]) then
					--d("on target updated world object id")
					--d(BuffHead.HostileTarget.WorldObjectId)
					BuffHead.Containers[BuffHead.HostileTarget.WorldObjectId]:ClearAllEffects();
					--d("- on target updated world object id")
				end
				BuffHead.AdvancedContainers.ClearHostile();
			else
				BuffHead.AdvancedContainers.HostileTargetChanged(targetObjectNumber);
			end
			CheckTargetObject(BuffHead.HostileTarget);
		end
	elseif (targetType == "selffriendlytarget" and targetObjectNumber ~= BuffHead.FriendlyTarget.WorldObjectId) then
		if (targetObjectNumber == 0 and RecentDeath()) then
			--remove buffs from old target
			BuffHead.ClearAllEffects(BuffHead.FriendlyTarget.WorldObjectId);
			BuffHead.FriendlyTarget.WorldObjectId = targetObjectNumber;
			BuffHead.FriendlyTarget.ResyncTime = nil;
			BuffHead.AdvancedContainers.ClearFriendly();
		else
			FriendlyTargetChanged(BuffHead.FriendlyTarget.WorldObjectId)
			
			BuffHead.FriendlyTarget.WorldObjectId = targetObjectNumber;
			BuffHead.FriendlyTarget.Name = L"";
			BuffHead.FriendlyTarget.IsNpc = IsNpc(TargetInfo:UnitType(targetType));
			if (not BuffHead.FriendlyTarget.IsNpc) then
				BuffHead.FriendlyTarget.Name = TargetInfo:UnitName(targetType):match(L"([^^]+)^?([^^]*)");
			end
			BuffHead.FriendlyTarget.ResyncTime = BuffHead.TimeCount + BuffHead.Settings.Sync.ResyncEvery;
			if (TargetInfo:UnitHealth("selffriendlytarget") == 0) then
				if (BuffHead.Containers[BuffHead.FriendlyTarget.WorldObjectId]) then
					--d("on target updated world object id friendly")
				        --d(BuffHead.FriendlyTarget.WorldObjectId)
					BuffHead.Containers[BuffHead.FriendlyTarget.WorldObjectId]:ClearAllEffects();
					--d("- on target updated world object id friendly")
				end
				BuffHead.AdvancedContainers.ClearFriendly();
			else
				BuffHead.AdvancedContainers.FriendlyTargetChanged(targetObjectNumber);
			end
			CheckTargetObject(BuffHead.FriendlyTarget);
		end
	end
end

function BuffHead.CreateContainer(id, targetName, targetType)
	local name = L"";
	if (targetName) then
		name = targetName;
	end
	
	BuffHead.Containers[id] = BuffHeadContainer:Create(id, targetType, id);
	BuffHead.Containers[id].TargetName = name;
	
	if (name and name ~= L"") then
		if (nameToId[name] and nameToId[name] ~= id) then
			BuffHead.DestroyContainer(nameToId[name]);
		end
		nameToId[name] = id;
	end
end

function BuffHead.DestroyContainer(id)
	if (not id) then return end
	
	local container = BuffHead.Containers[id];
	if (not container) then return end;

	if (container.TargetName ~= "") then
		if (nameToId[container.TargetName]) then
			nameToId[container.TargetName] = nil;
		end
	end
	--d("DestroyContainer id")
	BuffHead.Containers[id] = nil;
	container:Destroy();
end

function BuffHead.UpdateEffects(id, effects, isFullList, targetName, targetType)
	--d("UpdateEffects")
	BuffHead.AdvancedContainers.UpdateEffects(effects, isFullList, targetType);
		
	if (not IsTrackerEnabled(targetType)) then
		return;
	end

	if (not BuffHead.Containers[id]) then	
		BuffHead.CreateContainer(id, targetName, targetType);
	elseif (BuffHead.Containers[id].TargetType ~= targetType and targetType == BuffHead.TargetType.Group or targetType == BuffHead.TargetType.Self) then
		BuffHead.Containers[id].TargetType = targetType;
	end
	
	BuffHead.Containers[id]:UpdateEffects(effects, isFullList);
end

function BuffHead.OnTargetEffectsUpdated(targetType, changedEffects, isFullList)
	if (changedEffects == nil) then return end
	--d("target effect updated")
	if (BuffHead.HostileTarget.WorldObjectId ~= 0 and targetType == GameData.BuffTargetType.TARGET_HOSTILE) then
	
		BuffHead.UpdateEffects(BuffHead.HostileTarget.WorldObjectId, changedEffects, isFullList, BuffHead.HostileTarget.Name, BuffHead.TargetType.Hostile);
		
	-- don't update if the target is yourself. no point updating twice at once
	elseif (BuffHead.FriendlyTarget.WorldObjectId ~= 0 and targetType == GameData.BuffTargetType.TARGET_FRIENDLY) then
	
		if (BuffHead.FriendlyTarget.WorldObjectId ~= GameData.Player.worldObjNum) then		
			BuffHead.UpdateEffects(BuffHead.FriendlyTarget.WorldObjectId, changedEffects, isFullList, BuffHead.FriendlyTarget.Name, BuffHead.TargetType.Friendly);
		else
			BuffHead.AdvancedContainers.UpdateEffects(changedEffects, isFullList, BuffHead.TargetType.Friendly);
		end
		
	end
end

function BuffHead.OnGroupEffectsUpdated(updateType, effects, isFull)
    if (type(updateType) == "table") then
        effects, isFull, updateType = updateType, effects, GameData.BuffTargetType.SELF;
    end
    
    if not updateType then return end
	
	if (updateType >= GameData.BuffTargetType.GROUP_MEMBER_START and updateType <= GameData.BuffTargetType.GROUP_MEMBER_END and BuffHead.Settings.Trackers.Group) then
        local groupIndex = updateType - GameData.BuffTargetType.GROUP_MEMBER_START + 1;
        local memberName = (GroupWindow.groupData[groupIndex].name):match(L"([^^]+)^?([^^]*)");
		local groupMember = LibGroup.GroupMembers.ByName[memberName];
		
		if (groupMember and groupMember.IsValid) then
			local objectId = groupMember.WorldObjectId;
			if (objectId and objectId ~= 0) then
				--d("update effects valid groupmember")
				BuffHead.UpdateEffects(objectId, effects, isFull, memberName, BuffHead.TargetType.Group);
			end
		end
	elseif (updateType == GameData.BuffTargetType.SELF) then
		if (BuffHead.Settings.Trackers.Self) then
		    BuffHead.UpdateEffects(GameData.Player.worldObjNum, effects, isFull, "", BuffHead.TargetType.Self);
		else
			BuffHead.AdvancedContainers.UpdateEffects(effects, isFull, BuffHead.TargetType.Self);
		end
	end
end

function BuffHead.OnPlayerPositionUpdated(x, y)
	BuffHead.Location = { X = x, Y = y };
end

function BuffHead.UpdateDelay()
	if (not BuffHead.Settings.Performance.PriorityUpdate) then
		updateThrottle = BuffHead.Settings.Performance.GeneralDelay;
	else
		updateThrottle = math.min(BuffHead.Settings.Performance.GeneralDelay, BuffHead.Settings.Performance.PriorityDelay);
	end
end

function BuffHead.GetUpdateThrottle()
	return updateThrottle;
end

function BuffHead.UpdateSyncTime(delayTime)
	BuffHead.Sync.Total = BuffHead.Sync.Total + delayTime;
	BuffHead.Sync.Count = BuffHead.Sync.Count + 1;
	
	BuffHead.Sync.Delay = BuffHead.Sync.Total / BuffHead.Sync.Count;	
end

local function ResyncTarget(target, targetType)
	
	if (BuffHead.Settings.Sync.ResyncEvery == 0) then return end;
	if (not target.ResyncTime or BuffHead.TimeCount < target.ResyncTime) then return end

	if (not IsTrackerEnabled(targetType)) then
		return;
	end
        --d("ResyncTarget")
	local buffTargetType = GameData.BuffTargetType.TARGET_FRIENDLY;
	
	if (targetType == BuffHead.TargetType.Hostile) then
		buffTargetType = GameData.BuffTargetType.TARGET_HOSTILE;
	end
	
	local container = BuffHead.Containers[target.WorldObjectId];
	if (not container) then return end
	
	local effects = GetBuffs(buffTargetType);
	BuffHead.UpdateEffects(target.WorldObjectId, effects, true, target.Name, targetType)
	
	target.ResyncTime = BuffHead.TimeCount + BuffHead.Settings.Sync.ResyncEvery;
end

function BuffHead.OnUpdate(elapsed)
	--d("BuffHead.OnUpdate")
	BuffHead.TimeCount = BuffHead.TimeCount + elapsed;
	
	local refresh = nil;
	local checkStuck = nil;
	
	if (BuffHead.TimeCount - lastUpdate >= updateThrottle) then
		refresh = true;
		
		if (BuffHead.TimeCount - lastStuckCheck > STUCK_THROTTLE) then
			checkStuck = true;
			lastStuckCheck = BuffHead.TimeCount;
		end
		
		ResyncTarget(BuffHead.FriendlyTarget, BuffHead.TargetType.Friendly);
		ResyncTarget(BuffHead.HostileTarget, BuffHead.TargetType.Hostile);
		
		lastUpdate = BuffHead.TimeCount;
	end
	
	for id, container in pairs(BuffHead.Containers) do
	        --d("On update check stuck")
		--d(id)
		if (checkStuck) then
			local isPermanent = IsPermanentContainer(id);
			if (checkStuck and not isPermanent and container:IsStuck()) then
				BuffHead.DestroyContainer(id);
			elseif (not isPermanent and container:IsInactive()) then
				BuffHead.DestroyContainer(id);
			else
				container:Update(elapsed, refresh);
			end
		else
			container:Update(elapsed, refresh);
		end
	        --d("- On update check stuck")
	end
	BuffHead.AdvancedContainers.Update(elapsed, refresh);
end