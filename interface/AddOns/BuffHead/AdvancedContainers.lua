BuffHead.AdvancedContainers = {};

local advancedContainers = nil;
local registeredLayouts = nil;

local friendlyContainers = nil;
local hostileContainers = nil;
local selfContainers = nil;

local POSITION_ATTACHED = BuffHead.ScreenPosition.Attached;
local POSITION_FIXED = BuffHead.ScreenPosition.Fixed;

local function CopyTable(t)
	local copiedTable = {};
	for k, v in pairs(t) do
		--d("advanced containers Copy table")
		--d(k)
		if (type(v) == "table") then
			copiedTable[k] = CopyTable(v);
		else
			copiedTable[k] = v;
		end
		--d("- advanced containers Copy table")
	end
	return copiedTable;
end

local function GetLayout(id)
	if (id) then
		for index, layout in ipairs(BuffHead.Settings.Layouts) do
			if (layout.Settings.Id == id) then
				return layout.Settings;
			end
		end
	end
	return BuffHead.Settings.Layout;
end

local function RegisterLayoutEditor(container, displayName, settings, sourceSettings, layout, scale)
	
	local layoutWindow = "BuffHeadAdvancedContainerLayoutEditorWindow" .. #registeredLayouts;
	--CreateWindowFromTemplate(layoutWindow, "BuffHeadContainerTemplate", "Root")
	CreateWindowFromTemplate(layoutWindow, "BuffHeadContainerTemplate", "RootFrame")

	local rows, columns = 1, 1;
	local indicatorWidth, indicatorHeight = 64, 64;	
	if (settings.Size and settings.Size.Rows and settings.Size.Columns) then
		--rows, columns = settings.Size.Rows, settings.Size.Columns;
	end
	if (layout and layout.Width and layout.Height) then
		indicatorWidth, indicatorHeight = layout.Width, layout.Height;
	end
	
	-- This can get somewhat complicated. The subcontainers have their parent scaled but they themselves are actually a scale of 1
	-- To make the layout editor window the same size as an indicator, the scale has to be factored into the width, rather than setting
	-- the actual scale of the indicator or else there will be a scaling issue between the actual containers and the layout editor
	WindowSetDimensions(layoutWindow, indicatorWidth * columns * scale, indicatorHeight * rows * scale);
	WindowSetScale(layoutWindow, WindowGetScale(container:GetName()));
	--WindowAddAnchor(layoutWindow, "topleft", "Root", "topleft", settings.Offset.X, settings.Offset.Y);
	WindowAddAnchor(layoutWindow, "topleft", "RootFrame", "topleft", settings.Offset.X, settings.Offset.Y);

	LayoutEditor.RegisterWindow(layoutWindow, displayName, L"", false, false, true);
	table.insert(registeredLayouts, { LayoutWindow = layoutWindow, Container = container, Settings = settings, SourceSettings = sourceSettings });
end

function BuffHead.AdvancedContainers.Register(settings)

	local containerSettings = CopyTable(settings);
	containerSettings.Layout = GetLayout(containerSettings.Layout); -- (the saved layout is id based, rather than saving the entire table)

	if (advancedContainers == nil) then
		advancedContainers = {};
		registeredLayouts = {};
	end

	local containerId = "AdvancedContainer" .. #advancedContainers;	
	local container = BuffHeadContainer:Create(containerId, containerSettings.Type, nil, containerSettings, settings);
	local advancedContainer = { Container = container, Settings = containerSettings };
	local worldObjectId = nil;
	
	local screenPosition = containerSettings.ScreenPosition;
	if (containerSettings.Type == BuffHead.TargetType.Self) then
		selfContainers = selfContainers or {};
		selfContainers[screenPosition] = selfContainers[screenPosition] or {};
		table.insert(selfContainers[screenPosition], advancedContainer);
		worldObjectId = GameData.Player.worldObjNum;
	elseif (containerSettings.Type == BuffHead.TargetType.Friendly) then
		friendlyContainers = friendlyContainers or {};
		friendlyContainers[screenPosition] = friendlyContainers[screenPosition] or {};
		table.insert(friendlyContainers[screenPosition], advancedContainer);
		worldObjectId = BuffHead.FriendlyTarget.WorldObjectId;
	elseif (containerSettings.Type == BuffHead.TargetType.Hostile) then
		hostileContainers = hostileContainers or {};
		hostileContainers[screenPosition] = hostileContainers[screenPosition] or {};
		table.insert(hostileContainers[screenPosition], advancedContainer);
		worldObjectId = BuffHead.HostileTarget.WorldObjectId;
	end
	
	if (screenPosition == BuffHead.ScreenPosition.Attached and worldObjectId and worldObjectId ~= 0) then
		container.WorldObjectId = worldObjectId;
		container:AttachTo(worldObjectId);
	end
	
	table.insert(advancedContainers, advancedContainer);
	
	local localization = BuffHead.Localization.GetMapping();
	local targetTypeName = 
	{
		localization["Setup.Trackers.Tracker.Self"],
		localization["Setup.Trackers.Tracker.Group"],
		localization["Setup.Trackers.Tracker.Friendly"],
		localization["Setup.Trackers.Tracker.Hostile"],
	};
	local layoutName = L"BuffHead " .. targetTypeName[containerSettings.Type];
	
	if (screenPosition == BuffHead.ScreenPosition.Fixed) then
		RegisterLayoutEditor(container, layoutName, containerSettings, settings, containerSettings.Layout, containerSettings.Scale);
	end
	
	if (containerSettings.Containers.AlwaysShow.Placement == BuffHead.Container.Placement.Fixed) then
		RegisterLayoutEditor(container.Containers.AlwaysShow, layoutName .. L" (" .. localization["Setup.Containers.Container.AlwaysShow"] .. L")", 
			containerSettings.Containers.AlwaysShow, settings.Containers.AlwaysShow, containerSettings.Layout, containerSettings.Scale);
	end
	
	if (containerSettings.Containers.Buffs.Placement == BuffHead.Container.Placement.Fixed) then
		RegisterLayoutEditor(container.Containers.Buffs, layoutName .. L" (" .. localization["Setup.Containers.Container.Buffs"] .. L")", 
			containerSettings.Containers.Buffs, settings.Containers.Buffs, containerSettings.Layout, containerSettings.Scale);	
	end
	
	if (containerSettings.Containers.Debuffs.Placement == BuffHead.Container.Placement.Fixed) then
		RegisterLayoutEditor(container.Containers.Debuffs, layoutName .. L" (" .. localization["Setup.Containers.Container.Debuffs"] .. L")", 
			containerSettings.Containers.Debuffs, settings.Containers.Debuffs, containerSettings.Layout, containerSettings.Scale);	
	end

end

function BuffHead.AdvancedContainers.Clear()
	if (advancedContainers) then
		for index, container in ipairs(advancedContainers) do
			--d("AdvancedContainers.clear")
			--d(index)
			container.Container:Destroy();
			--d("- AdvancedContainers.clear")
		end
	end
	if (registeredLayouts) then
		for index, layout in ipairs(registeredLayouts) do
			--d("AdvancedContainers.clear registered layouts")
			--d(index)
			LayoutEditor.UnregisterWindow(layout.LayoutWindow);
			DestroyWindow(layout.LayoutWindow);
			--d("- AdvancedContainers.clear registered layouts")
		end
	end
	
	advancedContainers = nil;
	registeredLayouts = nil;
	friendlyContainers = nil;
	hostileContainers = nil;
	selfContainers = nil;
end

function BuffHead.AdvancedContainers.Load()
	for index, containerSettings in ipairs(BuffHead.Settings.AdvancedContainers) do
		--d("advanced containers.load")
		--d(index)
		BuffHead.AdvancedContainers.Register(containerSettings);
		--d("- advanced containers.load")
	end
end

function BuffHead.AdvancedContainers.ClearAllEffects()
	if (advancedContainers == nil) then return end
	
	for index, container in ipairs(advancedContainers) do
		--d("Advanced containers clear all effects")
		--d(index)
		container:ClearAllEffects();
		--d("- Advanced containers clear all effects")
	end
end

local function ResetContainer(advancedContainer, worldObjectId)
	if (advancedContainer == nil) then return end
	for index, container in ipairs(advancedContainer) do
		--d("reset container advanced container")
		--d(index)
		container.Container:ClearAllEffects();
		if (worldObjectId) then
			container.Container.WorldObjectId = worldObjectId;
			container.Container:AttachTo(worldObjectId);
		end
		--d("- reset container advanced container")
	end
end

function BuffHead.AdvancedContainers.ResetAllContainers()
	if (advancedContainers == nil) then return end
	
	for index, container in ipairs(advancedContainers) do
		--d("reset all containers")
		--d(index)
		local worldObjectId = nil;
		local targetType = container.Settings.Type;
		
		if (targetType == BuffHead.TargetType.Friendly) then
			worldObjectId = BuffHead.FriendlyTarget.WorldObjectId;
		elseif (targetType == BuffHead.TargetType.Hostile) then
			worldObjectId = BuffHead.HostileTarget.WorldObjectId;
		elseif (targetType == BuffHead.TargetType.Self) then
			worldObjectId = GameData.Player.worldObjNum;
		end
		--d("clear all effects - reset all containers")
		container.Container:ClearAllEffects();
		--d("-clear all effects - reset all containers")
		if (container.Settings.ScreenPosition == BuffHead.ScreenPosition.Attached) then
			if (container.Container.WorldObjectId ~= worldObjectId) then
				container.Container.WorldObjectId = worldObjectId;
				container.Container:AttachTo(worldObjectId);
			end
		end
		--d("- reset all containers")
	end
end

local function UpdateEffects(advancedContainer, changedEffects, isFullList)
	if (advancedContainer == nil) then return end
	
	for index, container in ipairs(advancedContainer) do
		--d("Update effects advanced container")
		--d(index)
		container.Container:UpdateEffects(changedEffects, isFullList);
		--d("- Update effects advanced container")
	end
end

function BuffHead.AdvancedContainers.HostileTargetChanged(worldObjectId)
	if (hostileContainers == nil) then return end
	
	ResetContainer(hostileContainers[POSITION_ATTACHED], worldObjectId);
	ResetContainer(hostileContainers[POSITION_FIXED]);
end

function BuffHead.AdvancedContainers.ClearHostile()
	if (hostileContainers == nil) then return end
	ResetContainer(hostileContainers[POSITION_ATTACHED]);
	ResetContainer(hostileContainers[POSITION_FIXED]);
end

function BuffHead.AdvancedContainers.FriendlyTargetChanged(worldObjectId)
	if (friendlyContainers == nil) then return end
	
	ResetContainer(friendlyContainers[POSITION_ATTACHED], worldObjectId);
	ResetContainer(friendlyContainers[POSITION_FIXED]);
end

function BuffHead.AdvancedContainers.ClearFriendly()
	if (friendlyContainers == nil) then return end

	ResetContainer(friendlyContainers[POSITION_ATTACHED]);
	ResetContainer(friendlyContainers[POSITION_FIXED]);
end

function BuffHead.AdvancedContainers.ClearSelf()
	if (selfContainers == nil) then return end

	ResetContainer(selfContainers[POSITION_ATTACHED]);
	ResetContainer(selfContainers[POSITION_FIXED]);
end

function BuffHead.AdvancedContainers.UpdateEffects(changedEffects, isFullList, targetType)
	local container = nil;
	
	if (targetType == BuffHead.TargetType.Friendly) then
		container = friendlyContainers;
	elseif (targetType == BuffHead.TargetType.Hostile) then
		container = hostileContainers;
	elseif (targetType == BuffHead.TargetType.Self) then
		container = selfContainers;
	end
	
	if (container) then
		UpdateEffects(container[POSITION_ATTACHED], changedEffects, isFullList);
		UpdateEffects(container[POSITION_FIXED], changedEffects, isFullList);
	end
end

function BuffHead.AdvancedContainers.Refresh()
	if (advancedContainers == nil) then return end
	for index, container in ipairs(advancedContainers) do
		--d("Advanced containers refresh")
		--d(index)
		container.Container:Refresh();
		--d("- Advanced containers refresh")
	end
end

function BuffHead.AdvancedContainers.Update(elapsed, refresh)
	if (advancedContainers == nil) then return end
	for index, container in ipairs(advancedContainers) do
		--d("Advanced containers update")
		--d(index)
		container.Container:Update(elapsed, refresh);
		--d("- Advanced containers update")
	end
end

function BuffHead.AdvancedContainers.OnLayoutEditorFinished()
	if (registeredLayouts == nil) then return end
	
	local interfaceScale = InterfaceCore.GetScale();
	for index, layout in ipairs(registeredLayouts) do
		local x, y = WindowGetScreenPosition(layout.LayoutWindow);
		layout.Settings.Offset.X = x / interfaceScale;
		layout.Settings.Offset.Y = y / interfaceScale;
		layout.SourceSettings.Offset.X = math.floor(x / interfaceScale * 100) / 100;
		layout.SourceSettings.Offset.Y = math.floor(y / interfaceScale * 100) / 100;
		
		layout.Container:UpdateFixedPosition();
	end
end