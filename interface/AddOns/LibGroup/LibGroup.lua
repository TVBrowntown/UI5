local VERSION = 8; -- 1.0.5 build/release
local VERSION_SETTINGS = 1;

LibGroup = LibGroup or {};
LibGroup.Version = VERSION;

LibGroup.Events = 
{ 
	-- EVENT										-- PARAMETERS
	GROUP_MEMBER_ADDED = 1, 						-- (groupMember)
	GROUP_MEMBER_UPDATED = 2, 						-- (groupMember)
	GROUP_UPDATED = 3, 								-- ()
	GROUP_MEMBER_DISTANCE_CHANGED = 4, 				-- (groupMember)
	GROUP_MEMBER_REMOVED = 5, 						-- (groupMember)
	GROUP_MEMBER_WORLD_OBJECT_CHANGED = 6,			-- (oldWorldObject, newWorldObject, groupMember)
	GROUP_MEMBER_DISTANCE_TO_PLAYER_CHANGED = 7,	-- (oldDistance, newDistance, groupMember)
};
LibGroup.RegisteredEvents = {};

LibGroup.GroupMembers = {};
LibGroup.GroupMembers.ByIndex = {};
LibGroup.GroupMembers.BySlot = {};
LibGroup.GroupMembers.ByName = {};
LibGroup.GroupMembers.Distance = {};

LibGroup.IsEventsRegistered = false;
LibGroup.IsLoaded = false;
LibGroup.IsLibSlashRegistered = false;

local MODE_WARBAND = "warband";
local MODE_SCENARIO = "scenario";
local MODE_PARTY = "party";

local MAX_POINTS = 520; -- (was 300) The maximum number of objects that can be displayed on the map (worldwide). This number could change over time and exceed this value
local MAX_GROUP_MEMBERS = 6;

local UPDATE_DELAY = 1;
local DISTANCE_UPDATE_DELAY = 0.1;
local DISTANCE_SEARCH_DELAY = 3;

local lastUpdate = UPDATE_DELAY;
local lastDistanceUpdate = DISTANCE_UPDATE_DELAY;
local lastDistanceSearch = 0;
local groupInWarband = nil;

local careerIdToLine = 
{
	[20] = GameData.CareerLine.IRON_BREAKER,
	[100] = GameData.CareerLine.SWORDMASTER,
	[64] = GameData.CareerLine.CHOSEN,
	[24] = GameData.CareerLine.BLACK_ORC,
	[60] = GameData.CareerLine.WITCH_HUNTER,
	[102] = GameData.CareerLine.WHITE_LION or GameData.CareerLine.SEER,
	[65] = GameData.CareerLine.MARAUDER or GameData.CareerLine.WARRIOR,
	[105] = GameData.CareerLine.WITCH_ELF or GameData.CareerLine.ASSASSIN,
	[62] = GameData.CareerLine.BRIGHT_WIZARD,
	[67] = GameData.CareerLine.MAGUS,
	[107] = GameData.CareerLine.SORCERER,
	[23] = GameData.CareerLine.ENGINEER,
	[101] = GameData.CareerLine.SHADOW_WARRIOR,
	[27] = GameData.CareerLine.SQUIG_HERDER,
	[63] = GameData.CareerLine.WARRIOR_PRIEST,
	[106] = GameData.CareerLine.DISCIPLE or GameData.CareerLine.BLOOD_PRIEST,
	[103] = GameData.CareerLine.ARCHMAGE,
	[26] = GameData.CareerLine.SHAMAN,
	[22] = GameData.CareerLine.RUNE_PRIEST,
	[66] = GameData.CareerLine.ZEALOT,
	[104] = GameData.CareerLine.BLACKGUARD or GameData.CareerLine.SHADE,
	[61] = GameData.CareerLine.KNIGHT,
	[25] = GameData.CareerLine.CHOPPA,
	[21] = GameData.CareerLine.SLAYER,
};

local currentMode = nil
local registeredEvents = nil;
local flagUpdate = true;

local playersName = nil;

local function UpdateEvent(event, ...)

	if (not LibGroup.RegisteredEvents[event]) then return end

	for _, func in pairs(LibGroup.RegisteredEvents[event]) do
		local success, errmsg = pcall(func, ...);
	end

end

local function CreateEventObj(e, func)

	local event = {};
	
	event.e = e;
	event.func = func;
	
	return event;

end

local function AddEvent(events, eventObj)

	table.insert(events, eventObj);

end

local function RegisterEvents(events, enabled)

	for index, event in pairs(events) do
		if (enabled) then
			RegisterEventHandler(event.e, event.func);
		else
			UnregisterEventHandler(event.e, event.func);
		end
	end

end

local function SetMode(mode, enabled)

	local events = {};

	if (mode == MODE_PARTY) then
		AddEvent(events, CreateEventObj(SystemData.Events.GROUP_STATUS_UPDATED, "LibGroup.OnGroupStatusUpdated"));
	elseif (mode == MODE_WARBAND) then
		AddEvent(events, CreateEventObj(SystemData.Events.BATTLEGROUP_MEMBER_UPDATED, "LibGroup.OnWarbandMemberUpdated"));
	elseif (mode == MODE_SCENARIO) then
		AddEvent(events, CreateEventObj(SystemData.Events.GROUP_STATUS_UPDATED, "LibGroup.OnGroupStatusUpdated"));
	end
	
	RegisterEvents(events, enabled);
	
	currentMode = mode;

end

local function GetPlayersName()

	if (playersName == nil) then
	    playersName = GameData.Player.name:match(L"([^^]+)^?([^^]*)");
	end
	
	return playersName;
	
end

local function IsValid(memberData)

	return (memberData and memberData.careerLine and memberData.careerLine ~= 0 and memberData.name and memberData.name ~= L"");

end

local function GetDistanceInfoForGroupMember(groupMember)
		
	local distanceInfo = LibGroup.GroupMembers.Distance[groupMember.Index];
	if (not distanceInfo or distanceInfo.Name ~= groupMember.Name) then
		LibGroup.GroupMembers.Distance[groupMember.Index] = {};
		distanceInfo = LibGroup.GroupMembers.Distance[groupMember.Index];
		distanceInfo.Name = groupMember.Name;
	end
	
	return distanceInfo;

end

local function UpdateGroupMemberDistance(groupMember, distance)

	if (groupMember.Distance ~= distance) then
		local oldDistance = groupMember.Distance;
		groupMember.Distance = distance;
		
		UpdateEvent(LibGroup.Events.GROUP_MEMBER_DISTANCE_TO_PLAYER_CHANGED, oldDistance, distance, groupMember);
	end
				
end

local function UpdateGroupDistance()

	local updatesNeeded = 0;
	local groupMembers = {};

	for index, groupMember in pairs(LibGroup.GroupMembers.ByIndex) do
		if (groupMember.IsValid and groupMember.IsOnline and groupMember.Name ~= GetPlayersName()) then
			groupMembers[groupMember.Name] = groupMember;
		
			local distanceInfo = GetDistanceInfoForGroupMember(groupMember);
			if (distanceInfo.Index) then
				-- attempt to get the map point using a cached index. if the cached index is no longer valid, flag a refresh to search for it
				local pointData = GetMapPointData("EA_Window_OverheadMapMapDisplay", distanceInfo.Index);
				if (pointData and pointData.name:match(L"([^^]+)^?([^^]*)") == distanceInfo.Name) then
					UpdateGroupMemberDistance(groupMember, pointData.distance);
				else
					distanceInfo.Index = nil;
				end
			end
			
			if (not distanceInfo.Index) then
				updatesNeeded = updatesNeeded + 1;
			end
		elseif (groupMember.Name == GetPlayersName()) then
			UpdateGroupMemberDistance(groupMember, 0);
		elseif (groupMember.IsValid) then
			UpdateGroupMemberDistance(groupMember, nil);
		elseif (not groupMember.IsValid) then
			LibGroup.GroupMembers.Distance[groupMember.Index] = nil;
		end
	end
	
	-- search for and update all members that need updates. any other group members found while searching will also be updated
	if (updatesNeeded > 0 and lastDistanceSearch <= 0) then
		lastDistanceSearch = LibGroup.Settings.Distance.SearchDelay or DISTANCE_SEARCH_DELAY;
		
		for index = 1, MAX_POINTS do
			local pointData = GetMapPointData("EA_Window_OverheadMapMapDisplay", index);
			
			if (pointData) then
				local name = pointData.name:match(L"([^^]+)^?([^^]*)");
				local groupMember = groupMembers[name];
				
				if (groupMember) then
					local distanceInfo = GetDistanceInfoForGroupMember(groupMember);
					if (not distanceInfo.Index) then
						-- a group member that required an update was found
						updatesNeeded = updatesNeeded - 1;
					end
					distanceInfo.Index = index;
					
					UpdateGroupMemberDistance(groupMember, pointData.distance);
					
					if (updatesNeeded <= 0) then
						return;
					end
				end
			end
		end
	end

end

local function UpdateGroupMember(groupMember, memberData)

	if (not groupMember) then return end

	local distanceChanged = false;
	
	groupMember.IsOnline = memberData.online;
	groupMember.IsInSameRegion = memberData.isInSameRegion;
	groupMember.CareerLine = memberData.careerLine;
	groupMember.CareerName = memberData.careerName;
	groupMember.Name = memberData.name:match(L"([^^]+)^?([^^]*)");
	
	if (memberData.isDistant ~= nil) then
		if (groupMember.IsDistant ~= memberData.isDistant) then
			groupMember.IsDistant = memberData.isDistant;
			distanceChanged = true;
		end
	elseif (not groupMember.IsDistant) then
		groupMember.IsDistant = true; --distance info is missing, assume player is far away
		distanceChanged = true;
	end
	
	-- When the group changes, the "new" world object is temporarily set to nil or 0 until the game sends an update
	-- Since we don't want this, we will ignore any nil or 0 updates
	if (memberData.worldObjNum and memberData.worldObjNum ~= 0) then
		local grMem = nil
		if (groupMember.WorldObjectId ~= nil) then 
 			grMem = groupMember.WorldObjectId % 5000
		end
		local memDt = nil
		if (memberData.worldObjNum ~= nil) then
			memDt = memberData.worldObjNum % 5000
		end
		if ((grMem) ~= (memDt)) then
			UpdateEvent(LibGroup.Events.GROUP_MEMBER_WORLD_OBJECT_CHANGED, grMem, memDt, groupMember);
		end
		
		groupMember.WorldObjectId = memDt;
	end
		
	if (memberData.healthPercent ~= nil) then
		groupMember.IsAlive = (memberData.healthPercent > 0);
	end
	
	if (distanceChanged) then
		UpdateEvent(LibGroup.Events.GROUP_MEMBER_DISTANCE_CHANGED, groupMember);
	end
	
end

local function SetupGroupMember(indexInGroup, slotInGroup, memberData)

	local indexChanged = false;

	if (not (slotInGroup and indexInGroup)) then
		return indexChanged;
	end
	
	local memberName = L"";
	
	if (memberData) then
		memberName = memberData.name:match(L"([^^]+)^?([^^]*)");
	end
	
	local groupMember = {};
	local alreadyExists = false;
	
	if (IsValid(memberData)) then
		if (LibGroup.GroupMembers.ByName[memberName]) then
			groupMember = LibGroup.GroupMembers.ByName[memberName];
			alreadyExists = true;
	
			if (groupMember.Slot ~= slotInGroup or groupMember.Index ~= indexInGroup) then
				indexChanged = true;
			end
		else
			LibGroup.GroupMembers.ByName[memberName] = groupMember;
		end
	end
	
	groupMember.Slot = slotInGroup;
	groupMember.Index = indexInGroup;
	groupMember.IsValid = IsValid(memberData);
	
	LibGroup.GroupMembers.BySlot[slotInGroup] = groupMember;
	LibGroup.GroupMembers.ByIndex[indexInGroup] = groupMember;
	
	if (IsValid(memberData)) then
		UpdateGroupMember(groupMember, memberData);
	
		if (not alreadyExists) then
			UpdateEvent(LibGroup.Events.GROUP_MEMBER_ADDED, groupMember);
			return true;
		else
			UpdateEvent(LibGroup.Events.GROUP_MEMBER_UPDATED, groupMember);
			return indexChanged;
		end
	end
	
	return indexChanged;
	
end

function LibGroup.Initialize()

	if (LibGroup.IsLoaded) then return end
	
	registeredEvents = {};
	
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.RELOAD_INTERFACE, "LibGroup.OnLoadComplete"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.LOADING_END, "LibGroup.OnLoadComplete"));
	
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.RELOAD_INTERFACE, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.LOADING_END, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.SCENARIO_BEGIN, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.SCENARIO_END, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.SCENARIO_GROUP_JOIN, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.SCENARIO_GROUP_LEAVE, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.SCENARIO_PLAYERS_LIST_GROUPS_UPDATED, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.SCENARIO_PLAYERS_LIST_RESERVATIONS_UPDATED, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.BATTLEGROUP_UPDATED, "LibGroup.FlagUpdate"));
	AddEvent(registeredEvents, CreateEventObj(SystemData.Events.GROUP_UPDATED, "LibGroup.FlagUpdate"));
	
    if (SystemData.Events.CITY_SCENARIO_BEGIN) then
		AddEvent(registeredEvents, CreateEventObj(SystemData.Events.CITY_SCENARIO_BEGIN, "LibGroup.FlagUpdate"));
		AddEvent(registeredEvents, CreateEventObj(SystemData.Events.CITY_SCENARIO_END, "LibGroup.FlagUpdate"));
    end

	for index = 1, MAX_GROUP_MEMBERS do
		SetupGroupMember(index, index, nil);
	end

	RegisterEvents(registeredEvents, true);

	LibGroup.LoadSettings();
	LibGroup.Setup.Initialize();
	
	LibGroup.IsEventsRegistered = true;
	LibGroup.IsLoaded = true;
	
	LibGroup.FlagUpdate();
	
end

function LibGroup.Unload()

	if (currentMode) then
	
		SetMode(currentMode, false);
		
	end
	
	if (LibGroup.IsEventsRegistered) then
	
		RegisterEvents(registeredEvents, false);
		LibGroup.IsEventsRegistered = false;
		
	end
	
	LibGroup.IsLoaded = false;

end

local function UpdateSettings()

	local version = LibGroup.Settings.Version;
	
	-- changes from version to version go here
	if (version == 1) then
	
	end

end

function LibGroup.LoadSettings()

	if (not LibGroup.Settings) then
		LibGroup.Settings = {};
	else
		UpdateSettings();
	end
	
	local settings = LibGroup.Settings;	
	settings.Version = VERSION_SETTINGS;
	
	if (not settings.Group) then
		settings.Group =
		{
			UpdateDelay = 0.5,
		};
	end
	
	if (not settings.Distance) then
		settings.Distance =
		{
			Enabled = true,
			UpdateDelay = DISTANCE_UPDATE_DELAY,
			SearchDelay = DISTANCE_SEARCH_DELAY,
		};
	end

end

function LibGroup.OnLoadComplete()

	if (not LibGroup.IsLibSlashRegistered) then
		if (LibSlash) then
			LibSlash.RegisterSlashCmd("libgroup", function(args) LibGroup.SlashCommand(args) end);
			LibGroup.IsLibSlashRegistered = true;
		end
	end

end

function LibGroup.SlashCommand(args)

	if (not LibGroup.IsLoaded) then return end
	LibGroup.Setup.Show();

end

function LibGroup.FlagUpdate()

	flagUpdate = true;

end

function LibGroup.Register(event, func)

	if (not event) then return end

	if (not LibGroup.RegisteredEvents[event]) then
		LibGroup.RegisteredEvents[event] = {};
	end
	
	LibGroup.RegisteredEvents[event][func] = func;
	--table.insert(LibGroup.RegisteredEvents[event], func);

end

function LibGroup.Unregister(event, func)

	if (not event) then return end

	if (LibGroup.RegisteredEvents[event]) then
		LibGroup.RegisteredEvents[event][func] = nil;
	end

end

local function GeneratePlayersData()

	local memberData = {};

	memberData.name = GameData.Player.name;
	memberData.level = GameData.Player.level;
	memberData.careerLine = GameData.Player.career.line;
	memberData.careerName = GameData.Player.career.name;
	memberData.online = true;
	memberData.isInSameRegion = true;
	memberData.isDistant = false;
	memberData.healthPercent = (GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum);
	memberData.worldObjNum = GameData.Player.worldObjNum;
	
	return memberData;

end

local function InvalidateGroup(fromIndex, toIndex)

	local groupChanged = false;
	
	if (fromIndex > toIndex) then
		return groupChanged;
	end
	
	local playersSlot = LibGroup.GroupMembers.ByIndex[MAX_GROUP_MEMBERS].Slot;

	for indexInGroup = fromIndex, toIndex do
		local groupMember = LibGroup.GroupMembers.ByIndex[indexInGroup];
		local memberName = nil;
		
		local slotInGroup = indexInGroup;
		if (playersSlot and slotInGroup >= playersSlot) then -- convert group index to slot
			slotInGroup = slotInGroup + 1;
		end
		
		if (groupMember and groupMember.IsValid) then
			groupChanged = true;
		end
				
		SetupGroupMember(indexInGroup, slotInGroup, nil);
	end
	
	return groupChanged;
	
end

local function GetPartyData()

	local partyData =  PartyUtils.GetPartyData();
	local groupChanged = false;
	
	for index = 1, MAX_GROUP_MEMBERS - 1 do
		groupChanged = SetupGroupMember(index, index, partyData[index]) or groupChanged;
	end

	groupChanged = SetupGroupMember(MAX_GROUP_MEMBERS, MAX_GROUP_MEMBERS, GeneratePlayersData()) or groupChanged;
	
	return groupChanged;
	
end

local function GetScenarioData()

    local scenarioData = GameData.GetScenarioPlayerGroups();
	local groupChanged = false;
	local lastIndexInGroup = 0;
	
    if (not scenarioData) then 
		return groupChanged;
	end
	
    local scenarioGroups = {};
    
    for index, memberData in ipairs(scenarioData) do
        if (memberData.sgroupindex > 0) then
            local scenarioGroup = memberData.sgroupindex;
            local slotInGroup = memberData.sgroupslotnum;
			
            if (not scenarioGroups[scenarioGroup]) then 
				scenarioGroups[scenarioGroup] = {};
			end
			
            table.insert(scenarioGroups[scenarioGroup], {index, slotInGroup});
        end
    end
            
    for scenarioGroup, groupIndexes in pairs(scenarioGroups) do
        local playersGroup = false;
		local playersSlot = nil
		
        for _, indexData in ipairs(groupIndexes) do
		
			local index = indexData[1];
            local memberData = scenarioData[index];
			
            if (memberData.name:match(L"([^^]+)^?([^^]*)") == GetPlayersName()) then
                playersGroup = true;
				playersSlot = indexData[2];
				break;
            end
			
        end
		
		if (playersGroup) then
			for _, indexData in ipairs(groupIndexes) do
				local index = indexData[1];
				local memberData = scenarioData[index];
				local slotInGroup = indexData[2];
				local indexInGroup = slotInGroup;
				
				if (slotInGroup == playersSlot) then
					indexInGroup = MAX_GROUP_MEMBERS;
				else
					--convert slot to group index by pretending that the player (self) isn't in the group
					--subtract a slot, if this member's slot comes after the player (self)
					if (slotInGroup > playersSlot) then
						indexInGroup = slotInGroup - 1;
					end
					
					if (indexInGroup > lastIndexInGroup) then
						lastIndexInGroup = indexInGroup;
					end
				end	
				
				local data = {};
		
				if (memberData.name and memberData.name ~= L"") then
					
					if (slotInGroup == playersSlot) then
						data = GeneratePlayersData();
					else
						--build a fake member object			
						data.online = true;
						data.isInSameRegion = true;
						data.careerLine = careerIdToLine[memberData.careerId];
						data.careerName = memberData.career;
						data.name = memberData.name;
						data.healthPercent = memberData.health;
						data.worldObjNum = memberData.worldObjNum;

						memberData = PartyUtils.GetPartyMember(indexInGroup);
						
						if (memberData and memberData.name:match(L"([^^]+)^?([^^]*)") == data.name:match(L"([^^]+)^?([^^]*)")) then						
							data = memberData;
						else
							-- member data will only be out of sync at the beginning of a scenario
							-- therefore, if the data can't be pulled, assume the player is not distant
							data.isDistant = false;
						end
					end
					
					groupChanged = SetupGroupMember(indexInGroup, slotInGroup, data) or groupChanged;
				end
			end
	
			groupChanged = InvalidateGroup(lastIndexInGroup + 1, MAX_GROUP_MEMBERS - 1) or groupChanged;
			
			return groupChanged; --group loaded, skip the rest
		end
		
    end
	
	groupChanged = InvalidateGroup(lastIndexInGroup + 1, MAX_GROUP_MEMBERS - 1) or groupChanged;
	
	return groupChanged;

end

local function GetWarbandData()

	local warbandData = PartyUtils.GetWarbandData();
	local groupChanged = false;
	local lastIndexInGroup = 0;

    if (not warbandData) then
		return groupChanged;
	end
	
	for warbandGroup, groupData in ipairs(warbandData) do
        local playersGroup = false;
		local playersSlot = nil;
		
		for slotInGroup, memberData in ipairs(groupData.players) do
			if (memberData.name:match(L"([^^]+)^?([^^]*)") == GetPlayersName()) then
                playersGroup = true;
				playersSlot = slotInGroup;
				break;
            end
		end
		
		if (playersGroup) then
			groupInWarband = warbandGroup;

			for slotInGroup, memberData in ipairs(groupData.players) do
				local indexInGroup = slotInGroup;
				
				if (memberData and memberData.name:match(L"([^^]+)^?([^^]*)") == GetPlayersName()) then
					memberData = GeneratePlayersData();
					indexInGroup = MAX_GROUP_MEMBERS;
				else
					if (slotInGroup > playersSlot) then
						indexInGroup = slotInGroup - 1;
					end
					
					if (indexInGroup > lastIndexInGroup) then
						lastIndexInGroup = indexInGroup;
					end
				end
				
				groupChanged = SetupGroupMember(indexInGroup, slotInGroup, memberData) or groupChanged;
				
			end
	
			groupChanged = InvalidateGroup(lastIndexInGroup + 1, MAX_GROUP_MEMBERS - 1) or groupChanged;
			
			return groupChanged; --group was found, ignore the rest
		
		end
		
    end
	
	groupChanged = InvalidateGroup(lastIndexInGroup + 1, MAX_GROUP_MEMBERS - 1) or groupChanged;
	
	return groupChanged;

end

local function PurgeGroupMembers()

	local membersByName = {};
	local groupChanged = false;

	-- remove the existing group members
	for index = 1, MAX_GROUP_MEMBERS do
		local groupMember = LibGroup.GroupMembers.ByIndex[index];
		if (groupMember and groupMember.IsValid) then
			membersByName[groupMember.Name] = groupMember;
			LibGroup.GroupMembers.ByName[groupMember.Name] = nil;
		end
	end
	
	-- remaining group members are ones that are no longer in the group
	for name, groupMember in pairs(LibGroup.GroupMembers.ByName) do
		if (groupMember and groupMember.IsValid) then
			UpdateEvent(LibGroup.Events.GROUP_MEMBER_REMOVED, groupMember);
			groupChanged = true;
		end
	end
	
	LibGroup.GroupMembers.ByName = membersByName;
	
	return groupChanged;

end

function LibGroup.UpdateGroupData()

	local newMode = currentMode;
	local groupChanged = false;
	
	newMode = MODE_PARTY;

	if (IsWarBandActive()) then
		newMode = MODE_WARBAND;
	end
    if (GameData.Player.isInSiege or GameData.Player.isInScenario) then
		newMode = MODE_SCENARIO;
	end
	
	--unregister old mode events
	if (newMode ~= currentMode) then
		SetMode(currentMode, false);
	end

	--get the group data for the new mode
    if (newMode == MODE_SCENARIO) then
		groupChanged = GetScenarioData();
	elseif (newMode == MODE_WARBAND) then
		groupChanged = GetWarbandData();
	elseif (newMode == MODE_PARTY) then
		groupChanged = GetPartyData();
	end
	
	--register new mode events
	if (newMode ~= currentMode) then
		SetMode(newMode, true);
	end

	groupChanged = PurgeGroupMembers() or groupChanged;

	if (groupChanged) then
		UpdateEvent(LibGroup.Events.GROUP_UPDATED);
	end
	
end

function LibGroup.OnWarbandMemberUpdated(warbandGroup, slotInGroup)
	
	if (warbandGroup ~= groupInWarband) then return end

	local memberData = PartyUtils.GetWarbandMember(groupInWarband, slotInGroup);
    if (not memberData) then return end
	
	local memberName = memberData.name:match(L"([^^]+)^?([^^]*)");
	UpdateGroupMember(LibGroup.GroupMembers.ByName[memberName], memberData);
			
	UpdateEvent(LibGroup.Events.GROUP_MEMBER_UPDATED, groupMember);
	
end

function LibGroup.OnGroupStatusUpdated(indexInGroup)

	local memberData = PartyUtils.GetPartyMember(indexInGroup);
	if (not memberData) then return end
	
	local memberName = memberData.name:match(L"([^^]+)^?([^^]*)");
	UpdateGroupMember(LibGroup.GroupMembers.ByName[memberName], memberData);

	UpdateEvent(LibGroup.Events.GROUP_MEMBER_UPDATED, groupMember);
	
end

function LibGroup.OnUpdate(elapsed)

	if (not LibGroup.IsLoaded) then return end

	lastUpdate = lastUpdate - elapsed;
	if (flagUpdate and lastUpdate <= 0) then
		LibGroup.UpdateGroupData();
		
		lastUpdate = UPDATE_DELAY;
		flagUpdate = false;
	end
	
	if (LibGroup.Settings.Distance.Enabled) then
		if (lastDistanceSearch > 0) then
			-- to prevent multiple searches in a short time, a full search can only be performed once every few seconds
			lastDistanceSearch = lastDistanceSearch - elapsed;
		end
		
		lastDistanceUpdate = lastDistanceUpdate - elapsed;
		if (lastDistanceUpdate <= 0) then
			UpdateGroupDistance();
			lastDistanceUpdate = LibGroup.Settings.Distance.UpdateDelay or DISTANCE_UPDATE_DELAY;
		end
	end
	
end
