--[[ 
Queue Queuer
Warhammer Online: Age of Reckoning UI modification that simplifies warband
scenario queueing with other scenario-oriented features as well.
    
Copyright (C) 2008-2010  Dillon "Rhekua" DeLoss
rhekua@msn.com		    www.rhekua.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

--[[ 
2000 Gates of Ekrund
2001 Mourkain Temple
2002 Black Fire Basin
2003 Kadrin Valley Pass
2004 Gromril Crossing
2005 Thunder Valley
2006 Logrin's Forge
2007 Krazy Fungus Cave
2008 Howling Gorge
2009 Karaz-a-Karak Gates
2010 Eight Peaks Gates
2011 Doomfist Crater
2012 Altdorf War Quarters
2013 The Undercroft
2014 Gates of Ekrund
2015 The Ironclad
2100 Nordenwatch
2101 Stonetroll Crossing
2102 Talabec Dam
2103 Highpass Cemetery
2104 Maw of Madness
2105 Twisting Tower
2106 Battle for Praag
2107 Grovod Caverns
2108 Reikland Factory
2109 Reikland Hills
2110 The Inevitable City
2111 Altdorf
2123 The Eternal Citadel
2136 College of Corruption
2200 Khaine's Embrace
2201 Phoenix Gate
2202 Tor Anroc
2203 Lost Temple of Isha
2204 Serpent's Passage
2205 Dragon's Bane
2206 Blood of the Black Cairn
2207 Caledor Woods
2151 Thanquol's Stand: Ratnarök

2152 Maw of Madness (Ranked Solo)
2153 Maw of Madness (Ranked Group)

]]--


QueueQueuer = {}

QueueQueuer_SavedVariables =
{
	["enabled"] = true,
	["autojoin"] = false,
	["autoqueue"] = false,
	["autobalance"] = true,
	["blacklist"] = 
	{
		-- tier 1
		["Gates of Ekrund"] 			= false, --2000
		["Nordenwatch"] 				= false, --2100
		["Khaine's Embrace"] 			= false, --2200

		-- tier 2	
		["Mourkain Temple"] 			= false, --2001
		["Phoenix Gate"] 			= false, --2201
		["Stonetroll Crossing"] 		= false, --2101

		-- tier 3	
		["Black Fire Basin"] 			= false, --2002
		["Doomfist Crater"] 			= false, --2011
		["Talabec Dam"] 				= false, --2102
		["Highpass Cemetery"] 			= false, --2103
		["Tor Anroc"] 					= false, --2202
		["Lost Temple of Isha"] 	= false, --2203

		-- tier 4	
		["Thunder Valley"] 				= false, --2005
		["Logrin's Forge"] 		= false, --2006
		["Battle for Praag"] 		= false, --2106
		["Grovod Caverns"] 		= false, --2107
		["Serpent's Passage"] 	= false, --2204
		["Dragon's Bane"] 		= false, --2205
		["The Eternal Citadel"] = false, --2123


		-- tier 4, special	
		["Altdorf War Quarters"]		= false, --2012
		["The Undercroft"]				= false, --2013
		["Maw of Madness"]				= false, --2104
		["Reikland Hills"]				= false, --2109

		-- tier 4, special	
		["Kadrin Valley Pass"]			= false, --2003
		["Gromril Crossing"]			= false, --2004
		["Black Crag Keep"]				= false, --2007
		["Howling Gorge"]				= false, --2008
		["Karaz-a-Karak Gates"]			= false, --2009
		["Eight Peaks Gates"]			= false, --2010
		["Twisting Tower"]				= false, --2105
		["Castle Fragendorf"]			= false, --2108
		["Altdorf"]						= false, --2111
		["Blood of the Black Cairn"]	= false, --2206
		["Caledor Woods"]				= true, --2207
		["The Eternal Citadel"] 		= true, --2123
		["College of Corruption"] 		= true, --2136
		["The Ironclad"] 				= false, --2015

		["The Ironclad"] 				= false, --2015
		
		["Caledor Woods (Ranked)"]		= true, --2207
		["Caledor Woods (Ranked Solo)"]	= true, --2016

		["Thanquol's Stand: Ratnarök"]	= false, --2151
		
		["Maw of Madness (Ranked Solo)"]	= true, --2152
		["Maw of Madness (Ranked)"]	= true, --2153
		["Ranked Solo"]	= true, --3000
		["Ranked"] = true, --3001
		
	}
	
}

QueueQueuer.ScenarioNames = 
-- this is for other languages
{
	-- tier 1
	["Gates of Ekrund"] 		= GetScenarioName(2000), --2000
	["Nordenwatch"] 			= GetScenarioName(2100), --2100
	["Khaine's Embrace"] 		= GetScenarioName(2200), --2200

	-- tier 2
	["Mourkain Temple"] 		= GetScenarioName(2001), --2001
	["Phoenix Gate"] 			= GetScenarioName(2201), --2201
	["Stonetroll Crossing"] 	= GetScenarioName(2101), --2101

	-- tier 3
	["Black Fire Basin"] 		= GetScenarioName(2002), --2002
	["Doomfist Crater"] 		= GetScenarioName(2011), --2011
	["Talabec Dam"] 			= GetScenarioName(2102), --2102
	["Highpass Cemetery"] 		= GetScenarioName(2103), --2103
	["Tor Anroc"] 				= GetScenarioName(2202), --2202
	["Lost Temple of Isha"] 	= GetScenarioName(2203), --2203

	-- tier 4
	["Thunder Valley"] 			= GetScenarioName(2005), --2005
	["Logrin's Forge"] 			= GetScenarioName(2006), --2006
	["Battle for Praag"] 		= GetScenarioName(2106), --2106
	["Grovod Caverns"] 			= GetScenarioName(2107), --2107
	["Serpent's Passage"] 		= GetScenarioName(2204), --2204
	["Dragon's Bane"] 			= GetScenarioName(2205), --2205
	["The Eternal Citadel"]		= GetScenarioName(2123), --2205

	-- tier 4, special
	["Altdorf War Quarters"]	= GetScenarioName(2012), --2012
	["The Undercroft"]			= GetScenarioName(2013), --2013
	["Maw of Madness"]			= GetScenarioName(2104), --2104
	["Reikland Hills"]			= GetScenarioName(2109), --2109

	-- tier 4, special
	["Kadrin Valley Pass"]		= GetScenarioName(2003), --2003
	["Gromril Crossing"]		= GetScenarioName(2004), --2004
	["Black Crag Keep"]			= GetScenarioName(2007), --2007
	["Howling Gorge"]			= GetScenarioName(2008), --2008
	["Karaz-a-Karak Gates"]		= GetScenarioName(2009), --2009
	["Eight Peaks Gates"]		= GetScenarioName(2010), --2010
	["Twisting Tower"]			= GetScenarioName(2105), --2105
	["Castle Fragendorf"]		= GetScenarioName(2108), --2108
	["Altdorf"] 				= GetScenarioName(2111), --2111
	["Blood of the Black Cairn"]	= GetScenarioName(2206), --2206
	["Caledor Woods"]				= GetScenarioName(2207), --2207
	["The Eternal Citadel"] 		= GetScenarioName(2123), --2123
	["College of Corruption"] 		= GetScenarioName(2136), --2136	
	["The Ironclad"] 				= GetScenarioName(2015), --2015	
	
	["Caledor Woods (Ranked Solo)"]	= GetScenarioName(2016), --2016
	["Caledor Woods (Ranked)"]		= GetScenarioName(2207), --2207

	-- RoR specific scenarios
	["Thanquol's Stand: Ratnarök"]	= GetScenarioName(2151), --2151

	["Maw of Madness (Ranked Solo)"]	= GetScenarioName(2152), --2152
	["Maw of Madness (Ranked)"]			= GetScenarioName(2153), --2153
	["Ranked Solo"]			= GetScenarioName(3000), --3000
	["Ranked"]			= GetScenarioName(3001), --3001
}

QueueQueuer.QueueZones = 
{
	-- all the zones that allow you to queue

	--Dwarfs vs Greenskins
	6, -- L"Ekrund",
	11, -- L"Mount Bloodhorn",
	7, -- L"Barak Varr",
	1, -- L"Marshes of Madness",
	2, -- L"The Badlands",
	8, -- L"Black Fire Pass",
	9, -- L"Kadrin Valley",
	5, -- L"Thunder Mountain",
	3, -- L"Black Crag",
	-- Forts
	4, -- L"Butcher's Pass",
	10, -- L"Stonewatch",

	--Chaos vs Empire
	100, -- L"Norsca",
	106, -- L"Nordland",
	107, -- L"Ostland",
	101, -- L"Troll Country",
	102, -- L"High Pass",
	108, -- L"Talabecland",
	103, -- L"Chaos Wastes",
	105, -- L"Praag",
	109, -- L"Reikland",
	-- Forts
	104, -- L"The Maw",
	110, -- L"Reikwald",
	--Cities
	161, -- L"The Inevitable City",
	162, -- L"Altdorf",
	--Land of the Dead
	191, -- L"Necropolis of Zandri",

	--High Elves vs Dark Elves
	200, -- L"The Blighted Isle",
	206, -- L"Chrace",
	201, -- L"The Shadowlands",
	207, -- L"Ellyrion",
	202, -- L"Avelorn",
	208, -- L"Saphery",
	203, -- L"Caledor",
	205, -- L"Dragonwake",
	209, -- L"Eataine"
	-- Forts
	204, -- L"Fell Landing"
	210 -- L"Shining Way"
}

QueueQueuer.CampaignZones = 
{
	-- all the zones that are tied to scenarios

	--Dwarfs vs Greenskins
	9, -- L"Kadrin Valley",
	5, -- L"Thunder Mountain",
	3, -- L"Black Crag",
	4, -- L"Butcher's Pass",
	10, -- L"Stonewatch",

	--Chaos vs Empire
	103, -- L"Chaos Wastes",
	105, -- L"Praag",
	109, -- L"Reikland",
	104, -- L"The Maw",
	110, -- L"Reikwald",
	161, -- L"The Inevitable City",
	162, -- L"Altdorf",

	--High Elves vs Dark Elves
	203, -- L"Caledor",
	205, -- L"Dragonwake",
	209, -- L"Eataine",
	204, -- L"Fell Landing",
	210 -- L"Shining Way"
}

local initialized = false
local TIME_DELAY = 1
local timeLeft = TIME_DELAY -- start in TIME_DELAY seconds
local oldZone = nil -- this is the zone before recent zone, used to prevent excessive zone change messages
local recentZone = nil
local recentZoneTier = nil
local recentZonePairing = nil
local lobbyPopup = 0
local queuer = false 
local queueCooldown = false
local queueAttemptsDefault = 2
local queueAttempts = queueAttemptsDefault 
local queueAttemptDelay = 0
local queueStep = 0
local leaveStep = 0
local queueMsgStep = 0
local leaveMsgStep = 0
local queuerCheckMsgStep = 0
local leaveFix = false
local triggeredBlacklist = nil
local triggeredBlacklistText = L""
local triggeredTierText = L""
local soloQueuing = false -- this is to tell whether or not we are queuing while solo to prevent queuing a group/warband the player joined mid-queue process
local sendLoadedMessage = false -- handles whether or not to tell your warband you have loaded (after finishing a scenario)
local sendPopMessage = false -- handles whether or not to tell your warband your queue has popped
local cooldownBlacklist = {} -- used to put a cooldown on recently left scenario queues
local cooldownBlacklist_TIME = 60*3 -- 3 minutes cooldown
local campaignStatus = {} -- used to track when zones get locked to re-open the scenario lobby window
local queuerList = {} -- keeps track of queuers in the warband
local randomCode = L""
local randomCodeTime = 0

local h_EA_Window_ScenarioLobby_OnLeaveActiveQueueFromLobby = nil

function QueueQueuer.FixName( name )
	-- currently the game adds a ^M or ^F at the end of names for what I 
	-- assume is to determine sex in combat or other messages
	-- it's terrible and it makes comparing names difficult

	if ( name == "" or name == nil ) then
		return L""
	end

	if ( type(name) ~= "wstring" ) then
		name = towstring(name)
	end

	-- this is to prevent unnecessary checks and because wstring.reverse(L"") returns a STRING, and that breaks stuff
	if ( name == L"" ) then
		return name
	end

	if ( wstring.find(name, L"^", 1, true) ~= nil ) then
		name = wstring.sub(name, 1, wstring.find(name, L"^", 1, true)-1)
	end

	-- remove spaces at the start and end of names. IE: I encounted a L"Rock-Biter Gnoblar " that compared incorrectly.
	-- OR TAB CHARACTERS (WHAT THE FUCK, MYTHIC?) "Battle for Praag" in other languages has a TAB CHARACTER in it.
	-- AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH!
	local done = false
	while ( not done ) do
		if ( wstring.find(name, L" ", 1, true) == 1 or wstring.find(name, L"	", 1, true) == 1) then
			name = wstring.sub(name, 2, -1)
		elseif ( wstring.find(wstring.reverse(name), L" ", 1, true) == 1 or wstring.find(wstring.reverse(name), L"	", 1, true) == 1 ) then
			name = wstring.sub(name, 1, -2)
		else
			done = true
		end
	end

	return name
end

function QueueQueuer.CompareWStrings( first, second )
	-- for some fucked up reason, the game or lua likes to put random hidden characters in wstrings
	-- this messes up their length and makes wstring.find return nil even though they appear to be the same
	-- IE: the wstring name of enemy L"Burning Spear" will sometimes not equal wstring L"Burning Spear"

	first = QueueQueuer.FixName( first )
	second = QueueQueuer.FixName( second )

	-- check lengths as QueueQueuer.CompareWStrings(L"Doggles", L"Dog") will return true otherwise
	if ( wstring.len(first) ~= wstring.len(second) ) then
		return false
	end

	if ( wstring.find(first, second, 1, true) == 1 ) then
		return true
	else
		return false
	end
end

function QueueQueuer.SendChatText( text, chan )
	if( SystemData.ClientVersion >= L"Version 1.3.6 Build 0" ) then
		-- THANKS, MYTHIC
		SendChatText( text, chan )
	else
		SystemData.UserInput.ChatText = text
		BroadcastEvent( SystemData.Events.SEND_CHAT_TEXT )
	end
end

function QueueQueuer.ZoneCheck( zone )
	--[[
	if ( zone == nil or type(zone) ~= "number" ) then
		return false
	end

	local zoneName = GetZoneName(zone)
	for k, v in ipairs(QueueQueuer.QueueZones) do
		if ( zone == v ) then
			return true
		end
	end
	return false
	]]--
	return true
end

function QueueQueuer.GetQueuerList()
	return queuerList
end

function QueueQueuer.IsQueuer()
	return queuer
end

function QueueQueuer.QueueCooldown()
	return queueCooldown
end

function QueueQueuer.OnInitialize()

	RegisterEventHandler(SystemData.Events.CHAT_TEXT_ARRIVED, "QueueQueuer.OnChat")
	RegisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_CANCEL, "QueueQueuer.OnCancel")
	RegisterEventHandler(SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "QueueQueuer.OnLeave")
	RegisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW, "QueueQueuer.OnJoinNow")

	h_EA_Window_ScenarioLobby_OnLeaveActiveQueueFromLobby = EA_Window_ScenarioLobby.OnLeaveActiveQueueFromLobby
	EA_Window_ScenarioLobby.OnLeaveActiveQueueFromLobby = QueueQueuer.OnLeaveActiveQueueFromLobby

	if (QueueQueuer_SavedVariables["enabled"] == true) then
		EA_ChatWindow.Print(L"Queue Queuer: Loaded and enabled!")
	else
		EA_ChatWindow.Print(L"Queue Queuer: Loaded, but disabled.")
	end
	LibSlash.RegisterSlashCmd("qq", function(input) QueueQueuer.HandleSlashCmd(input) end)
	LibSlash.RegisterSlashCmd("queuequeuer", function(input) QueueQueuer.HandleSlashCmd(input) end)

	QueueQueuer.CheckCampaignStatus() -- init campaign status to avoid a redundant lobby popup

	if (QueueQueuer_SavedVariables["blacklist"]["College of Corruption"] == nil) then
		QueueQueuer_SavedVariables["blacklist"]["College of Corruption"] = false
	end

	QueueQueuer_SavedVariables["blacklist"]["Ranked Solo"] = true

	initialized = true
end

function QueueQueuer.OnShutdown()

	UnregisterEventHandler(SystemData.Events.CHAT_TEXT_ARRIVED, "QueueQueuer.OnChat")
	UnregisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_CANCEL, "QueueQueuer.OnCancel")
	UnregisterEventHandler(SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE, "QueueQueuer.OnLeave")
	UnregisterEventHandler(SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW, "QueueQueuer.OnJoinNow")

	EA_Window_ScenarioLobby.OnLeaveActiveQueueFromLobby = h_EA_Window_ScenarioLobby_OnLeaveActiveQueueFromLobby
	h_EA_Window_ScenarioLobby_OnLeaveActiveQueueFromLobby = nil

	initialized = false
end

function QueueQueuer.SetQueueStep( stepNumber )

	queueStep = stepNumber
end

function QueueQueuer.CheckCampaignStatus()
	local changed = false

	for k, v in pairs(QueueQueuer.CampaignZones) do
		local tempZoneData = GetCampaignZoneData(v)
		if ( campaignStatus[v] ~= tempZoneData.isLocked ) then
			campaignStatus[v] = tempZoneData.isLocked
			changed = true
		end
	end

	return changed
end

function QueueQueuer.HandleSlashCmd(arg)

	if (arg == "enable" or arg == "enabled" or arg == "on" or arg == "1") then

		QueueQueuer_SavedVariables["enabled"] = true
		if ( QueueQueuer.inBattlegroup() and queuer == true ) then
			local zoneName = L""
			zoneName = GetZoneName(GameData.Player.zone)
			zoneName = QueueQueuer.FixName(zoneName) -- there is some weird shit at the tail end of these zone strings
			QueueQueuer.SendChatText(L"/wb [Queue Queuer v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L" QUEUER: QQ ENABLED.]", L"")
		else
			EA_ChatWindow.Print(L"Queue Queuer: Enabled.")
		end
		return
	end

	if (arg == "disable" or arg == "disabled" or arg == "off" or arg == "0") then

		QueueQueuer_SavedVariables["enabled"] = false

		-- reset all variables
		QueueQueuer.SetQueueStep( 0 )
		leaveStep = 0
		queueCooldown = false
		queueAttempts = queueAttemptsDefault
		soloQueuing = false
		sendLoadedMessage = false
		queueMsgStep = 0
		leaveMsgStep = 0
		queuerCheckMsgStep = 0
		leaveFix = false
		triggeredBlacklist = nil
		triggeredBlacklistText = L""
		triggeredTierText = L""
		queueAttempts = queueAttemptsDefault
		lobbyPopup = 0
		sendPopMessage = false
		cooldownBlacklist = {}
		randomCode = L""

		if ( QueueQueuer.inBattlegroup() and queuer == true ) then
			QueueQueuer.SendChatText(L"/wb [Queue Queuer v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L" QUEUER: QQ DISABLED.]", L"")
		else
			EA_ChatWindow.Print(L"Queue Queuer: Disabled.")
		end
		return
	end

	if (arg == "autojoin") then

		if (QueueQueuer_SavedVariables["autojoin"] == true) then
			QueueQueuer_SavedVariables["autojoin"] = false
			EA_ChatWindow.Print(L"Queue Queuer: Automatic joining of scenarios disabled.")
		else
			QueueQueuer_SavedVariables["autojoin"] = true
			EA_ChatWindow.Print(L"Queue Queuer: Automatic joining of scenarios enabled!")
		end
		return
	end

	if (arg == "autoqueue") then

		if (QueueQueuer_SavedVariables["autoqueue"] == true) then
			QueueQueuer_SavedVariables["autoqueue"] = false

			-- reset related variables
			queueAttempts = queueAttemptsDefault 
			queueAttemptDelay = 0
			QueueQueuer.SetQueueStep( 0 )
			queueCooldown = false
			soloQueuing = false

			EA_ChatWindow.Print(L"Queue Queuer: Automatic queuing of scenarios disabled.")
		else
			QueueQueuer_SavedVariables["autoqueue"] = true
			EA_ChatWindow.Print(L"Queue Queuer: Automatic queuing of scenarios enabled!")
		end
		return
	end
	
	if (arg == "autobalance") then

		if (QueueQueuer_SavedVariables["autobalance"] == true) then
			QueueQueuer_SavedVariables["autobalance"] = false
			
			-- reset related variables
			queuerList = {} -- keeps track of queuers in the warband
			randomCode = L""
			randomCodeTime = 0

			EA_ChatWindow.Print(L"Queue Queuer: Automatic balancing of warband queuers disabled.")
		else
			QueueQueuer_SavedVariables["autobalance"] = true
			EA_ChatWindow.Print(L"Queue Queuer: Automatic balancing of warband queuers enabled!")
		end
		return
	end

	if (arg == "join" or arg == "queue") then

		if (QueueQueuer_SavedVariables["enabled"] == false) then
			EA_ChatWindow.Print(L"Queue Queuer: Currently disabled.")
		elseif (not QueueQueuer.inGroup() and not QueueQueuer.inBattlegroup()) then
			EA_ChatWindow.Print(L"Queue Queuer: Joining queues...")
			soloQueuing = true
			QueueQueuer.SetQueueStep( 1 )
		elseif (QueueQueuer.inGroup() == true and not QueueQueuer.inBattlegroup() and queuer == true) then
			EA_ChatWindow.Print(L"Queue Queuer: Group joining queues...")
			soloQueuing = false
			QueueQueuer.SetQueueStep( 1 )
		elseif (queuer == false) then
			EA_ChatWindow.Print(L"Queue Queuer: Solo joining queues...")
			soloQueuing = true
			QueueQueuer.SetQueueStep( 1 )
		else
			if (GameData.Player.isInScenario == true or
				GameData.Player.isInSiege == true or
				WindowGetShowing("EA_Window_ScenarioStarting")) then
				EA_ChatWindow.Print(L"Queue Queuer: Aborted, already in or joining a scenario!")
				return
			end
			
			soloQueuing = false
			queueMsgStep = 1
		end
		GameData.ScenarioQueueData.selectedId = 0 -- reset selected
		queueCooldown = false -- cancel cooldown period
		queueAttempts = queueAttemptsDefault -- reset attempts
		timeLeft = 1
		return
	end

	if (arg == "leave" or arg == "unqueue") then

		if (QueueQueuer_SavedVariables["enabled"] == false) then
			EA_ChatWindow.Print(L"Queue Queuer: Currently disabled.")
		elseif ( ( not QueueQueuer.inGroup() and not QueueQueuer.inBattlegroup() ) or soloQueuing == true) then
			EA_ChatWindow.Print(L"Queue Queuer: Leaving queues...")
			leaveStep = 1
		elseif (queuer == false) then
			EA_ChatWindow.Print(L"Queue Queuer: Solo leaving queues...")
			leaveStep = 1
		else
			if (GameData.Player.isInScenario == true or
				GameData.Player.isInSiege == true or
				WindowGetShowing("EA_Window_ScenarioStarting")) then
				EA_ChatWindow.Print(L"Queue Queuer: Aborted, already in or joining a scenario!")
				return
			end

			leaveMsgStep = 1
		end
		queueCooldown = false -- cancel cooldown period
		queueAttempts = queueAttemptsDefault -- reset attempts
		timeLeft = 1
		return
	end

	if (arg == "queuer") then

		if (queuer == true) then
			queuer = false

			-- reset related variables
			sendLoadedMessage = false 
			sendPopMessage = false
			triggeredBlacklist = nil
			triggeredBlacklistText = L""
			triggeredTierText = L""

			if ( QueueQueuer.inBattlegroup() and QueueQueuer_SavedVariables["enabled"] == true ) then
				QueueQueuer.SendChatText(L"/wb [Queue Queuer v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L" QUEUER DISABLED!]", L"")
			else
				EA_ChatWindow.Print(L"Queue Queuer: No longer a queuer!")
			end
		else
			queuer = true

			-- reset related variables
			sendPopMessage = true

			if ( QueueQueuer.inBattlegroup() and QueueQueuer_SavedVariables["enabled"] == true ) then
				local zoneName = L""
				zoneName = GetZoneName(GameData.Player.zone)
				zoneName = QueueQueuer.FixName(zoneName) -- there is some weird shit at the tail end of these zone strings
				QueueQueuer.SendChatText(L"/wb [Queue Queuer v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L" QUEUER ENABLED!]", L"")
			else
				EA_ChatWindow.Print(L"Queue Queuer: You are now a queuer!")
			end
		end
		return
	end

	if (arg == "blacklist" or arg == "options") then

		-- SUPER LAZY
		--QueueQueuer_GUI.MapButton_OnLButtonUp()
		QueueQueuer_GUI.OptionsButton_OnLButtonUp()
		return
	end

	if (arg == "check" or arg == "queuercheck") then
		if (QueueQueuer_SavedVariables["enabled"] == false) then
			EA_ChatWindow.Print(L"Queue Queuer: Currently disabled.")
		elseif ( queuer == true ) then
			queuerCheckMsgStep = 1
			timeLeft = 1
		else
			EA_ChatWindow.Print(L"Queue Queuer: Aborted, not a queuer!")
		end
		return
	end

	EA_ChatWindow.Print(L"Invalid argument, try: 'enable' 'disable' 'autojoin' 'autoqueue' 'join' 'leave' 'queuer' 'blacklist' 'options' 'check'")
end

function QueueQueuer.inGroup()
	return GroupWindow.groupData[1].name ~= L"" and GroupWindow.groupData[1].name ~= nil
end

function QueueQueuer.inBattlegroup()
	if ( BattlegroupWindow ~= nil ) then
		return BattlegroupWindow.IsBattlegroupActive()
	elseif ( BattlegroupHUD ~= nil ) then
		for i = 1, table.getn(GetBattlegroupMemberData()) do
			if ( table.getn(GetBattlegroupMemberData()[i].players) > 0 ) then
				return true
			end
		end
	end
end

function QueueQueuer.GetCooldownBlacklist()
	return cooldownBlacklist
end

function QueueQueuer.CheckCooldownBlacklist( scenario )
	if ( type(scenario) == "number" ) then
		for k, v in pairs(cooldownBlacklist) do
			if ( k == scenario ) then
				return true
			end
		end
	elseif ( type(scenario) == "wstring" ) then
		for k, v in pairs(cooldownBlacklist) do
			--EA_ChatWindow.Print( QueueQueuer.ScenarioNames[scenario])
			if ( QueueQueuer.CompareWStrings( scenario, GetScenarioName(k) ) ) then
				return true
			end
		end
	elseif ( type(scenario) == "string" ) then
		return QueueQueuer.CheckCooldownBlacklist( towstring(scenario) )
	end
	return false
end

local cdb_TIME_DELAY = 1
local cdb_timeLeft = cdb_TIME_DELAY
function QueueQueuer.UpdateCooldownBlacklist(elapsed)

	cdb_timeLeft = cdb_timeLeft - elapsed
	if cdb_timeLeft > 0 then
		return -- cut out early
	end
	cdb_timeLeft = cdb_TIME_DELAY -- reset to cdb_TIME_DELAY seconds

	for k, v in pairs(cooldownBlacklist) do
		if ( v > 0 ) then
			cooldownBlacklist[k] = cooldownBlacklist[k] - cdb_TIME_DELAY 
		else
			cooldownBlacklist[k] = nil
		end
	end
end

function QueueQueuer.OnUpdate(elapsed)

	if (SystemData.LoadingData.isLoading == true or QueueQueuer_SavedVariables["enabled"] == false or initialized == false ) then

		return
	end

	QueueQueuer.UpdateCooldownBlacklist(elapsed)

	timeLeft = timeLeft - elapsed
	if timeLeft > 0 then
		return -- cut out early
	end
	timeLeft = TIME_DELAY -- reset to TIME_DELAY seconds
	-- this will run roughly every second. If TIME_DELAY were 2, it'd run every 2 seconds.
	
	-- clear old code after x seconds
	QueueQueuer.UpdateRandomCodeTimeout(elapsed)

	if ( lobbyPopup > 0 ) then
		if ( WindowGetShowing("EA_Window_ScenarioLobby") ) then
			WindowSetShowing("EA_Window_ScenarioLobby", false)
			lobbyPopup = 0
		elseif ( lobbyPopup < 6 ) then -- window isn't showing yet, try to trigger it again just in-case something bad happened
			lobbyPopup = lobbyPopup + 1
			timeLeft = 0.5 -- keep checking every half second
		else -- window has not shown up for 3 seconds, abandon ship
			DEBUG( L"EA_Window_ScenarioLobby was triggered to open and failed to do so for 3 seconds." )
				lobbyPopup = 0
			end
			return
		end

		if ( queuer == true and QueueQueuer.inBattlegroup() == true ) then
			if ( sendLoadedMessage == false ) then
				if ( GameData.Player.isInScenario == true ) then
					sendLoadedMessage = true
				end
			else
				if ( GameData.Player.isInScenario == false ) then
					QueueQueuer.SendChatText(L"/wb [QQ: POST-SCENARIO: Client finished loading and ready to queue!]", L"")
					sendLoadedMessage = false
				end
			end
		end

		if (recentZone ~= GameData.Player.zone and queueStep == 0 and leaveStep == 0 
			and not WindowGetShowing("ScenarioSummaryWindow")
			and not WindowGetShowing("EA_Window_ScenarioStarting")
			and not WindowGetShowing("EA_Window_ScenarioJoinPrompt")) then

			if ( GameData.Player.isInScenario == true ) then
				-- in a scenario, reset queue attempts and abort zone update
				queueCooldown = false
				queueAttempts = queueAttemptsDefault
				return
			end

			-- inform the warband that this moron changed tiers or is roaming around The Inevitable City / Altdorf
			if ( recentZone ~= nil and queuer == true and QueueQueuer.inBattlegroup() == true 
				and ( recentZoneTier ~= GetZoneTier() 
					--or recentZone == 161 or recentZone == 162 
					--or GameData.Player.zone == 161 or GameData.Player.zone == 162
					or QueueQueuer.ZoneCheck( recentZone ) ~= QueueQueuer.ZoneCheck( GameData.Player.zone ) ) ) then

				local zoneNameOld = L""
				local zoneNameNew = L""
				zoneNameOld = QueueQueuer.FixName(GetZoneName(recentZone)) -- there is some weird shit at the tail end of these zone strings
				zoneNameNew = QueueQueuer.FixName(GetZoneName(GameData.Player.zone)) -- there is some weird shit at the tail end of these zone strings

			--[[ no longer needed
			QueueQueuer.SendChatText(L"/wb [QQ: ZONE CHANGE: T" .. towstring(recentZoneTier) .. L": " .. zoneNameOld .. L" to T" 
								  .. towstring(GetZoneTier()) .. L": " .. zoneNameNew ..  L".]", L"")
								  ]]--
								end

								oldZone = recentZone
								recentZone = GameData.Player.zone

								if ( recentZoneTier ~= GetZoneTier() or recentZonePairing ~= GetZonePairing()
									or ( QueueQueuer.ZoneCheck( oldZone ) == false and QueueQueuer.ZoneCheck( recentZone ) == true ) ) then

									GameData.ScenarioQueueData.selectedId = 0
									if( SystemData.ClientVersion <= L"Version 1.2.1 Build 999" ) then
										-- not needed in 1.3.0 as the list is automatically refreshed
										BroadcastEvent(SystemData.Events.INTERACT_SELECT_SCENARIO_QUEUE_LIST)
										lobbyPopup = 1
										timeLeft = 0.5 -- wait only half a second before closing this window down
									end
								end

								recentZoneTier = GetZoneTier()
								recentZonePairing = GetZonePairing()

								-- zone change, reset cooldown
								queueCooldown = false
								queueAttempts = queueAttemptsDefault

								return
							end

							-- this should work regardless of where we are
							QueueQueuer.QueuerCheckMessage()

							if (GameData.Player.isInScenario == true or
								GameData.Player.isInSiege == true ) then

								-- reset steps if we were in the middle of em
								QueueQueuer.SetQueueStep( 0 )
								leaveStep = 0
								queueCooldown = false
								queueAttempts = queueAttemptsDefault
								queueAttemptDelay = 0
								soloQueuing = false

								timeLeft = 3
								return
							end

							if( SystemData.ClientVersion <= L"Version 1.2.1 Build 999" ) then
								-- not needed in 1.3.0 as the list is automatically refreshed

								if ( recentZoneTier == 4 and QueueQueuer.CheckCampaignStatus() ) then
									-- if a tier 4 zone gets locked, a scenario is locked as well: update queue list
									GameData.ScenarioQueueData.selectedId = 0
									BroadcastEvent(SystemData.Events.INTERACT_SELECT_SCENARIO_QUEUE_LIST)
									lobbyPopup = 1
									timeLeft = 0.5 -- wait only half a second before closing this window down
									return
								end

							end

							-- handle the auto queuing timer
							QueueQueuer.JoinQueues()
							QueueQueuer.LeaveQueues()
							QueueQueuer.JoinQueuesMessage()
							QueueQueuer.LeaveQueuesMessage()

							if (WindowGetShowing("EA_Window_ScenarioJoinPrompt")) then

								-- sometimes the game likes to show both windows, no idea why but im fixing it here
								if (WindowGetShowing("EA_Window_ScenarioStarting")) then
									WindowSetShowing("EA_Window_ScenarioStarting", false)
								end

								if ( queuer == true and QueueQueuer.inBattlegroup() == true and sendPopMessage == true ) then
									QueueQueuer.SendChatText(L"/wb [QQ: " .. wstring.upper(LabelGetText("EA_Window_ScenarioJoinPromptBoxName")) 
										.. L" POPPED FOR GROUP " ..  towstring(QueueQueuer.GetGroup()) ..  L"!]", L"")
									sendPopMessage = false
								end

								if (ButtonGetDisabledFlag("EA_Window_ScenarioJoinPromptBoxJoinWaitButton") == false 
									and (EA_Window_ScenarioLobby.autoCancelTime > 0 and EA_Window_ScenarioLobby.autoCancelTime < 5) 
									and QueueQueuer_SavedVariables["autojoin"] == true and GetAFKFlag() == false) then

									EA_Window_ScenarioLobby.OnJoinInstanceWait()
								end

								-- reset steps if we were in the middle of em
								QueueQueuer.SetQueueStep( 0 )
								leaveStep = 0
								queueCooldown = false
								queueAttempts = queueAttemptsDefault
								soloQueuing = false

								return
							end

							-- catch whether or not we are going to autojoin a scenario and prevent autoqueuing before the loading screen
							-- clicking the Join button is handled in QueueQueuer.OnJoinNow()
							if (WindowGetShowing("EA_Window_ScenarioStarting") and EA_Window_ScenarioLobby.startTime <= 1) then
								queueAttemptDelay = 10
								return
							end

							if ( queueAttemptDelay > 0 ) then
								queueAttemptDelay = queueAttemptDelay - TIME_DELAY
								return
							end

							-- this is just in-case someone uses right-click leave instead of the /qq leave
							if (queueCooldown == true) then
								-- we successfully joined queues, reset cooldown
								if (GetScenarioQueueData() ~= nil) then
									queueCooldown = false
									queueAttempts = queueAttemptsDefault
								end
								return
							end

							if (not QueueQueuer.inGroup() and not QueueQueuer.inBattlegroup() and GetScenarioQueueData() == nil 
								and queueStep == 0 and leaveStep == 0 and QueueQueuer_SavedVariables["autoqueue"] == true
								and not WindowGetShowing("EA_Window_ScenarioStarting")
								and not WindowGetShowing("EA_Window_ScenarioJoinPrompt")
								and QueueQueuer.ZoneCheck( GameData.Player.zone ) == true
								and not QueueQueuer.CheckOneButtonDlgs( L"You have been idle for one minute." )
								and not (GameData.ScenarioQueueData[1].id == 0) ) then

								queueAttempts = queueAttempts - 1
								if (queueAttempts < 0) then
									if ( queueAttemptsDefault > 1 ) then
										EA_ChatWindow.Print(L"Queue Queuer: Attempted " .. towstring(queueAttemptsDefault) .. L" times to join queues and failed; on cooldown until zone change or next command.")
									else
										EA_ChatWindow.Print(L"Queue Queuer: Attempted to join queues and failed; on cooldown until zone change or next command.")
									end
									-- tried three times, prevent spam
									queueCooldown = true
									queueAttempts = queueAttemptsDefault

									-- for some reason when we attempt to join queues that do not exist,
										-- the game bugs out and won't requeue until we leave the non-existant ones WEIRD
										leaveFix = true
										leaveStep = 1 
										return
									end
									EA_ChatWindow.Print(L"Queue Queuer: Attempting to auto-queue...")
									GameData.ScenarioQueueData.selectedId = 0 -- reset selected

									if ( queueAttemptsDefault > 1 and queueAttempts == queueAttemptsDefault - 2 ) then
										-- second attempt will be to try refreshing the scenario queue data and see if that fixes the problem

										GameData.ScenarioQueueData.selectedId = 0
										if( SystemData.ClientVersion >= L"Version 1.2.1 Build 999" ) then
											-- not needed in 1.3.0 as the list is automatically refreshed
											BroadcastEvent(SystemData.Events.INTERACT_SELECT_SCENARIO_QUEUE_LIST)
											lobbyPopup = 1
											timeLeft = 0.5 -- wait only half a second before closing this window down
										end
									end

									queueAttemptDelay = 3 -- pause between attempts
									soloQueuing = true
									QueueQueuer.SetQueueStep( 1 )
									return
								end
							end

							function QueueQueuer.OnChat()

								if (QueueQueuer_SavedVariables["enabled"] == true) then
									local type = GameData.ChatData.type
									if (type == SystemData.ChatLogFilters.BATTLEGROUP or type == SystemData.ChatLogFilters.GROUP) then
										QueueQueuer.ChatHandler()
									end
								end		
							end

							function QueueQueuer.OnLeave()
								-- when you press the Leave button
								if (QueueQueuer_SavedVariables["enabled"] == true) then
									queueAttemptDelay = 5 -- pause between attempts
								end
							end

							function QueueQueuer.OnJoinNow()
								-- when the Join button is pressed on ScenarioStarting or JoinPrompt window
								if (QueueQueuer_SavedVariables["enabled"] == true) then
									queueAttemptDelay = 10 -- pause between attempts
								end
							end

							function QueueQueuer.OnCancel()
								-- when the JoinPrompt window expires
								if (QueueQueuer_SavedVariables["enabled"] == true) then
									QueueQueuer.SetQueueStep( 0 )
									leaveStep = 0
									queueCooldown = false
									queueAttempts = queueAttemptsDefault
									EA_Window_ScenarioLobby.OnLeaveActiveQueueFromLobby()
									queueAttemptDelay = 5 -- pause between attempts
								end
							end

							function QueueQueuer.OnLeaveActiveQueueFromLobby()
								-- when you leave a queue from the ScenarioStarting or ScenarioJoinPromptBox (after it pops)
								cooldownBlacklist[GameData.ScenarioData.startingScenario] = cooldownBlacklist_TIME

								return h_EA_Window_ScenarioLobby_OnLeaveActiveQueueFromLobby()
							end

							function QueueQueuer.BoolToInt(bool)
								return bool and 1 or 0
							end

							function QueueQueuer.JoinQueuesMessage()
								if (queueMsgStep == 0) then
									return
								elseif (leaveStep > 0) then
									queueMsgStep = 0
									EA_ChatWindow.Print(L"Queue Queuer: Aborted, you are currently in the process of leaving queues...")
									return
								end
								queueMsgStep = 0

								local tier = 0
								tier = GetZoneTier()

								if ( tier == 0 ) then
									EA_ChatWindow.Print(L"Queue Queuer: Aborted, this zone has no known scenarios to join.")
									return
								end

								local myBlacklist = {}

								-- copy the table
								for k, v in pairs(QueueQueuer_SavedVariables["blacklist"]) do
									myBlacklist[k] = v
								end

								-- add in the cooldown blacklist
								for k, v in pairs(myBlacklist) do
									local cooldownValue = QueueQueuer.CheckCooldownBlacklist( QueueQueuer.ScenarioNames[k] ) 
									if ( cooldownValue ) then
										myBlacklist[k] = cooldownValue
										EA_ChatWindow.Print(L"Queue Queuer: Blacklist adjusted for " .. QueueQueuer.FixName(QueueQueuer.ScenarioNames[k]) .. L" cooldown.")
									end
								end

								local tempBlacklist = L""
								for id = 1, EA_Window_ScenarioLobby.MAX_SCENARIOS do
									if (GameData.ScenarioQueueData[id].id ~= 0) then
										for key, value in pairs(myBlacklist) do
											if ( QueueQueuer.ScenarioNames[key] == GetScenarioName(GameData.ScenarioQueueData[id].id) ) then
												tempBlacklist = towstring(tempBlacklist) .. towstring(QueueQueuer.BoolToInt(value))
											end
										end
									end
								end
								if ( GameData.ScenarioQueueData[1].id == 0 ) then
									-- No scenarios available.
									EA_ChatWindow.Print(L"Queue Queuer: Aborted, no scenarios available to join.")
									return
								end
								QueueQueuer.SendChatText(L"/wb [QQ: QUEUE " .. tempBlacklist .. L":" .. tier .. L"]", L"")
							end

							function QueueQueuer.LeaveQueuesMessage()

								if (leaveMsgStep == 0) then
									return
								elseif (queueStep > 0) then
									leaveMsgStep = 0
									EA_ChatWindow.Print(L"Queue Queuer: Aborted, you are currently in the process of joining queues...")
									return
								end
								leaveMsgStep = 0
								if (QueueQueuer.inBattlegroup()) then
									QueueQueuer.SendChatText(L"/wb [QQ: LEAVE]", L"")
								else
									QueueQueuer.SendChatText(L"/p [QQ: LEAVE]", L"")
								end
							end

							function QueueQueuer.UpdateRandomCodeTimeout(elapsed)
								randomCodeTime = randomCodeTime - elapsed
								if randomCodeTime > 0 then
									return -- cut out early
								end
								randomCode = L""
							end

							function QueueQueuer.GetRandomCode()
								if ( randomCode == L"" ) then
									local code = L""
									for i=1,5 do
										if ( math.random(0,1) == 0 ) then
											code = code .. towstring(math.random(0,9))
										else
											-- a-z
											code = code .. wstring.char(math.random(97,122))
										end
									end
									randomCode = code
									randomCodeTime = 2 -- about 2 seconds timeout
									return randomCode
								else
									return randomCode
								end
							end

							function QueueQueuer.QueuerCheckMessage()

								if (queuerCheckMsgStep == 0) then
									return
								end

								queuerCheckMsgStep = 0

								if (QueueQueuer.inBattlegroup()) then
									local zoneName = L""
									zoneName = GetZoneName(GameData.Player.zone)
									zoneName = QueueQueuer.FixName(zoneName) -- there is some weird shit at the tail end of these zone strings
									if ( QueueQueuer_SavedVariables["autobalance"] ) then
										QueueQueuer.SendChatText(L"/wb [QQ: QUEUER CHECK " .. QueueQueuer.GetRandomCode() .. L"]\n[QQ: REPORT " .. QueueQueuer.GetRandomCode() .. L" v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L"]", L"")	
									else
										QueueQueuer.SendChatText(L"/wb [QQ: QUEUER CHECK]" .. L"\n[Queue Queuer v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L" QUEUER!]", L"")
									end
								else
									EA_ChatWindow.Print(L"Queue Queuer: Aborted, not in a warband!")
								end
							end

							function QueueQueuer.CheckOneButtonDlgs( text )
								for i = 1, 5 do
									if (DialogManager.oneButtonDlgs[i].inUse == true) then
										if ( wstring.find(LabelGetText("OneButtonDlg" .. i .. "BoxText"), text) ~= nil) then
											return true
										end
									end
								end
								return false
							end

							function QueueQueuer.JoinProblemCheck()
								-- for all sorts of shit that can go wrong, cancel and put on cooldown
								local problem = false
								if ( GameData.ScenarioQueueData[1].id == 0 ) then
									if (QueueQueuer.inBattlegroup() == true and queuer == true and problem == false) then
										QueueQueuer.SendChatText(L"/wb [QQ: Aborted, no scenarios available.]", L"")
										leaveFix = true
										leaveMsgStep = 1
									elseif (QueueQueuer.inGroup() == true and queuer == true and problem == false) then
										QueueQueuer.SendChatText(L"/p [QQ: Aborted, no scenarios available.]", L"")
										leaveFix = true
										leaveMsgStep = 1
									elseif (QueueQueuer.inGroup() == false and problem == false) then
										EA_ChatWindow.Print(L"Queue Queuer: Aborted, no scenarios available.")
										leaveFix = true
										leaveStep = 1
									end
									QueueQueuer.SetQueueStep( 0 )
									queueCooldown = true
									queueAttempts = queueAttemptsDefault
									timeLeft = 1
									problem = true
								end
								for i = 1, 5 do
									if (DialogManager.oneButtonDlgs == nil or DialogManager.oneButtonDlgs[i] == nil) then
										break
									end
									if (DialogManager.oneButtonDlgs[i].inUse == true) then
										if ( wstring.find(LabelGetText("OneButtonDlg" .. i .. "BoxText"), L"You cannot join this scenario, your rank is too high.") ~= nil) then
											if (QueueQueuer.inBattlegroup() == true and queuer == true and problem == false) then
												QueueQueuer.SendChatText(L"/wb [QQ: Aborted, failed to join queue. Not all players are low enough rank.]", L"")
												leaveFix = true
												leaveMsgStep = 1
											elseif (QueueQueuer.inGroup() == true and queuer == true and problem == false) then
												QueueQueuer.SendChatText(L"/p [QQ: Aborted, failed to join queue. Not all players are low enough rank.]", L"")
												leaveFix = true
												leaveMsgStep = 1
											elseif (QueueQueuer.inGroup() == false and problem == false) then
												EA_ChatWindow.Print(L"Queue Queuer: Aborted, rank is too high.")
												leaveFix = true
												leaveStep = 1
											end
											DialogManager.oneButtonDlgs[i].inUse = false
											WindowSetShowing("OneButtonDlg" .. i, false)
											QueueQueuer.SetQueueStep( 0 )
											queueCooldown = true
											queueAttempts = queueAttemptsDefault
											timeLeft = 1
											problem = true
										elseif (wstring.find(LabelGetText("OneButtonDlg" .. i .. "BoxText"), L"You cannot join this scenario, your rank is too low.") ~= nil) then
											if (QueueQueuer.inBattlegroup() == true and queuer == true and problem == false) then
												QueueQueuer.SendChatText(L"/wb [QQ: Aborted, failed to join queue. Not all players are high enough rank.]", L"")
												leaveFix = true
												leaveMsgStep = 1
											elseif (QueueQueuer.inGroup() == true and queuer == true and problem == false) then
												QueueQueuer.SendChatText(L"/p [QQ: Aborted, failed to join queue. Not all players are high enough rank.]", L"")
												leaveFix = true
												leaveMsgStep = 1
											elseif (QueueQueuer.inGroup() == false and problem == false) then
												EA_ChatWindow.Print(L"Queue Queuer: Aborted, rank is too low.")
												leaveFix = true
												leaveStep = 1
											end
											DialogManager.oneButtonDlgs[i].inUse = false
											WindowSetShowing("OneButtonDlg" .. i, false)
											QueueQueuer.SetQueueStep( 0 )
											queueCooldown = true
											queueAttempts = queueAttemptsDefault
											timeLeft = 1
											problem = true
										elseif (wstring.find(LabelGetText("OneButtonDlg" .. i .. "BoxText"), L"Your party cannot join this scenario together because not all players are in the same bracket.") ~= nil) then
											if (QueueQueuer.inBattlegroup() == true and queuer == true and problem == false) then
												QueueQueuer.SendChatText(L"/wb [QQ: Aborted, failed to join queue. Not all players are in the same bracket.]", L"")
											elseif (QueueQueuer.inGroup() == true and queuer == true and problem == false) then
												QueueQueuer.SendChatText(L"/p [QQ: Aborted, failed to join queue. Not all players are in the same bracket.]", L"")
											end
											DialogManager.oneButtonDlgs[i].inUse = false
											WindowSetShowing("OneButtonDlg" .. i, false)
											QueueQueuer.SetQueueStep( 0 )
											queueCooldown = true
											queueAttempts = queueAttemptsDefault
											leaveMsgStep = 1
											timeLeft = 1
											problem = true
										end
									end
								end
								return problem
							end

							function QueueQueuer.JoinQueues()

								if (queueStep == 0) then
									return
								elseif (leaveStep > 0) then
									queueStep = 0
									soloQueuing = false
									EA_ChatWindow.Print(L"Queue Queuer: Aborted, you are currently in the process of leaving queues...")
									return
								elseif (queueStep > EA_Window_ScenarioLobby.MAX_SCENARIOS) then
									queueStep = 0
									if (queuer == true and QueueQueuer.inBattlegroup() == true and soloQueuing == false) then
										if ( GetScenarioQueueData() ~= nil 
											or WindowGetShowing("EA_Window_ScenarioStarting")
											or WindowGetShowing("EA_Window_ScenarioJoinPrompt") ) then

											QueueQueuer.SendChatText(L"/wb [QQ: Group joined all requested queues!]", L"")
										else
											QueueQueuer.SendChatText(L"/wb [QQ: Group failed to joined all requested queues.]", L"")
										end
									else
										if ( GetScenarioQueueData() ~= nil 
											or WindowGetShowing("EA_Window_ScenarioStarting")
											or WindowGetShowing("EA_Window_ScenarioJoinPrompt") ) then

											EA_ChatWindow.Print(L"Queue Queuer: Joined all requested queues!")
										else
											if ( QueueQueuer.JoinProblemCheck() == false ) then
												EA_ChatWindow.Print(L"Queue Queuer: Failed to join all requested queues.")
											end
										end
									end
									soloQueuing = false
									-- reset the triggered blacklist if there is one
									if ( triggeredBlacklistText ~= L"" ) then
										triggeredBlacklistText = L""
									end
									if ( triggeredBlacklistTierText ~= L"" ) then
										triggeredBlacklistTierText = L""
									end
									if ( triggeredBlacklist ~= nil ) then
										triggeredBlacklist = nil
									end

									-- one last check for errors, just to be sure
									QueueQueuer.JoinProblemCheck()

									return
								end

								-- only check on the second step
								-- this actually doesn't need to be here when we are setting timeLeft = 0, but definitely does with larger time steps
								if (queueStep == 2) then
									if ( QueueQueuer.JoinProblemCheck() ) then
										return
									end
								end

								if (GameData.ScenarioQueueData[queueStep].id ~= 0) then
									if (not WindowGetShowing("EA_Window_ScenarioJoinPrompt") and not WindowGetShowing("EA_Window_ScenarioStarting")) then
										if (not QueueQueuer.inBattlegroup() or soloQueuing == true) then
											local blacklistValue = false

											for key,value in pairs(QueueQueuer_SavedVariables["blacklist"]) do

												if(key == 2006) then blacklistValue = true; break; end

												if ( QueueQueuer.CompareWStrings( QueueQueuer.ScenarioNames[key], GetScenarioName(GameData.ScenarioQueueData[queueStep].id) ) ) then
													blacklistValue = value
													break -- found it, leave
												end
											end

											local cooldownValue = QueueQueuer.CheckCooldownBlacklist( GameData.ScenarioQueueData[queueStep].id )
											if ( cooldownValue ) then
												EA_ChatWindow.Print(L"Queue Queuer: Blacklist adjusted for " .. QueueQueuer.FixName(GetScenarioName(GameData.ScenarioQueueData[queueStep].id)) .. L" cooldown.")
											end

											if ( blacklistValue == true or cooldownValue == true ) then
												queueStep = queueStep + 1
												timeLeft = 0
												return
											end
										end
										if ( ( not QueueQueuer.inGroup() and not QueueQueuer.inBattlegroup() ) or soloQueuing == true ) then
											GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[queueStep].id
											local event = EA_Window_ScenarioLobby.joinModes[1].joinSingleEvent
											BroadcastEvent(event)
										else
											if ( triggeredBlacklist ~= nil ) then
												local blacklistValue = false
												for key,value in pairs(triggeredBlacklist) do
													if ( QueueQueuer.CompareWStrings( QueueQueuer.ScenarioNames[key], GetScenarioName(GameData.ScenarioQueueData[queueStep].id) ) ) then
														blacklistValue = value
														break -- found it, leave
													end
												end
												if ( blacklistValue == true ) then
													queueStep = queueStep + 1
													timeLeft = 0 -- return instantly to avoid desync
													return
												end
												--do it the old way, then
												elseif ( triggeredBlacklistText ~= L"" ) then
													if ( wstring.sub(triggeredBlacklistText, queueStep, queueStep) == L"1" ) then
														queueStep = queueStep + 1
														timeLeft = 0 -- return instantly to avoid desync
														return
													end
												end
												--debug
				--[[if (QueueQueuer.inBattlegroup() == true) then
					SystemData.UserInput.ChatText = L"/wb [QQ: Group queued for " .. GetScenarioName(GameData.ScenarioQueueData[queueStep].id) .. L".]"
					BroadcastEvent( SystemData.Events.SEND_CHAT_TEXT )
				end]]--
				--EA_ChatWindow.Print(wstring.sub(triggeredBlacklistText, queueStep, queueStep + 1))
				GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[queueStep].id
				local event = EA_Window_ScenarioLobby.joinModes[2].joinSingleEvent
				BroadcastEvent(event)
			end
			timeLeft = 0 -- speed up the process (the grace-time needed between joining and leaving queues seems to have been removed from the game)
		else
			-- instant scenario pop!
			-- end of the line, boss
			queueStep = EA_Window_ScenarioLobby.MAX_SCENARIOS
			timeLeft = 0 -- report ASAP that it was successful
		end
	else
		-- end of the line, boss
		queueStep = EA_Window_ScenarioLobby.MAX_SCENARIOS
		if ( GetScenarioQueueData() == nil ) then
			timeLeft = 3 -- give some time for the server to queue us before looping back to report a fail or success
		end
	end
	queueStep = queueStep + 1
end

function QueueQueuer.LeaveQueues()

	if (leaveStep == 0) then
		return
	elseif (queueStep > 0) then
		leaveStep = 0
		EA_ChatWindow.Print(L"Queue Queuer: Aborted, you are currently in the process of joining queues...")
		return
	elseif (leaveStep > EA_Window_ScenarioLobby.MAX_SCENARIOS) then
		leaveStep = 0
		if (queuer == true and QueueQueuer.inBattlegroup() == true and leaveFix == false and soloQueuing == false) then
			QueueQueuer.SendChatText(L"/wb [QQ: Queue Queuer users in group " .. towstring(QueueQueuer.GetGroup()) .. L" have left all queues!]", L"")
		elseif (leaveFix == false) then
			EA_ChatWindow.Print(L"Queue Queuer: Left all queues!")
		end
		soloQueuing = false
		leaveFix = false -- reset for next time
		return
	end

	if (GameData.ScenarioQueueData[leaveStep].id ~= 0) then
		if (not WindowGetShowing("EA_Window_ScenarioJoinPrompt") and not WindowGetShowing("EA_Window_ScenarioStarting")) then
			--[[if (queuer == true and QueueQueuer.inBattlegroup() == true and leaveFix == false) then
				SystemData.UserInput.ChatText = L"/wb [QQ: Group left queue for " .. GetScenarioName(GameData.ScenarioQueueData[leaveStep].id) .. L".]"
				BroadcastEvent( SystemData.Events.SEND_CHAT_TEXT )
			end]]--

			GameData.ScenarioQueueData.selectedId = GameData.ScenarioQueueData[leaveStep].id
			BroadcastEvent( SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE )
		else
			EA_Window_ScenarioLobby.OnLeaveActiveQueueFromLobby()
			leaveStep = EA_Window_ScenarioLobby.MAX_SCENARIOS
		end
		timeLeft = 0 -- speed up the process (the grace-time needed between joining and leaving queues seems to have been removed from the game)
	else
		-- end of the line, boss
		leaveStep = EA_Window_ScenarioLobby.MAX_SCENARIOS
	end
	leaveStep = leaveStep + 1
end

function QueueQueuer.WStringToBool(wstringText)
	if ( wstringText == L"1" ) then
		return true
	else
		return false
	end
end

function QueueQueuer.CreateTriggeredBlacklist()
	triggeredBlacklist = {}
	for id = 1, EA_Window_ScenarioLobby.MAX_SCENARIOS do
		if (GameData.ScenarioQueueData[id].id ~= 0) then
			for key, value in pairs(QueueQueuer.ScenarioNames) do
				if ( QueueQueuer.CompareWStrings(value, GetScenarioName(GameData.ScenarioQueueData[id].id) ) ) then
					triggeredBlacklist[key] = QueueQueuer.WStringToBool(wstring.sub(triggeredBlacklistText, id, id))
					break -- found it
				end
			end
		end
	end
end

function QueueQueuer.GetVersion()
	local modsList = ModulesGetData()
	for modIndex, modData in ipairs( modsList ) do

		if ( modData.name == "Queue Queuer" ) then
			return modData.version
		end
	end
	return 0
end

function QueueQueuer.GetGroup()
	local groupNumber = 0

	if ( BattlegroupWindow ~= nil ) then
		for i = 1, table.getn(BattlegroupWindow.groups) do	

			if ( BattlegroupWindow.groups[i].players ~= nil ) then

				for j = 1, table.getn(BattlegroupWindow.groups[i].players) do	

					if ( BattlegroupWindow.groups[i].players[j].name ~= nil 
						and QueueQueuer.CompareWStrings(GameData.Player.name, BattlegroupWindow.groups[i].players[j].name) ) then

						groupNumber = i
						break
					end
				end
			end
		end
	elseif ( BattlegroupHUD ~= nil ) then
		for i = 1, table.getn(GetBattlegroupMemberData()) do
			if ( GetBattlegroupMemberData()[i].players ~= nil ) then

				for j = 1, table.getn(GetBattlegroupMemberData()[i].players) do	

					if ( GetBattlegroupMemberData()[i].players[j].name ~= nil 
						and QueueQueuer.CompareWStrings(GameData.Player.name, GetBattlegroupMemberData()[i].players[j].name) ) then

						groupNumber = i
						break
					end
				end
			end
		end
	end

	return groupNumber
end

function QueueQueuer.UpdateQueuerList(playerName, group)
	local player = QueueQueuer.FixName(GameData.Player.name)
	queuerList[player] = PartyUtils.IsPlayerInWarband(player)
	playerName = QueueQueuer.FixName(playerName)
	
	-- first update those already in the list and dump those who left
	for k, v in pairs(queuerList) do
		local temp = PartyUtils.IsPlayerInWarband(k)
		queuerList[k] = tonumber(temp)
		if ( queuerList[k] == nil ) then
			table.remove(queuerList, k)
		end
	end
	
	if ( group == nil ) then
		group = PartyUtils.IsPlayerInWarband(playerName)
	end
	
	queuerList[playerName] = tonumber(group)
	
	local pG, pP = PartyUtils.IsPlayerInWarband(playerName)
	if ( pG ~= nil and pP ~= nil and not GetBattlegroupMemberData()[pG].players[pP].isAssistant ) then
		QueueQueuer.SendChatText( L"/warbandpromote " .. playerName, L"" ) -- make sure this guy is an assistant
	end
	
	-- check the groups for imbalance
	local groupBalance = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}
	for k, v in pairs(queuerList) do
		groupBalance[v] = groupBalance[v] + 1
	end
	-- balance the groups
	-- find how many groups have players in it
	for i, v in ipairs(groupBalance) do
		if ( GetBattlegroupMemberData()[i].players[1] == nil ) then
			groupBalance[i] = -1
		end
	end
	
	-- run once for each populated group
	for i=1,4 do
		local gEmpty, gOverflow = 0
		if ( groupBalance[i] < 0 ) then return end
		
		for k, v in pairs(groupBalance) do
			if ( v > 1 ) then gOverflow = k end
			if ( v == 0 ) then gEmpty = k end
		end
		local playerToMove = nil
		for k, v in pairs(queuerList) do
			if ( v == gOverflow ) then
				playerToMove = k
				if ( GetBattlegroupMemberData()[gEmpty].players[6] == nil ) then
					PartyUtils.MoveWarbandMember( playerToMove, gEmpty )
				else
					-- not sure if this is necessary but if the group is full, just swap instead
					PartyUtils.SwapWarbandMembers( playerToMove, GetBattlegroupMemberData()[gEmpty].players[6].name )
				end
				-- update position in list
				queuerList[k] = PartyUtils.IsPlayerInWarband(k)
				break
			end
		end	
	end
end

function QueueQueuer.ChatHandler()
	
	local msg = GameData.ChatData.text
	local author = GameData.ChatData.name
	local player = GameData.Player.name

	if ( QueueQueuer_SavedVariables["enabled"] == false ) then
		return
	end
	
	if (wstring.sub(msg, 1, 11) == L"[QQ: QUEUE ") then
		if (GameData.Player.isInScenario == true or
			GameData.Player.isInSiege == true or
			WindowGetShowing("EA_Window_ScenarioStarting") or
			WindowGetShowing("EA_Window_ScenarioJoinPrompt")) then

			QueueQueuer.SendChatText(L"/wb [QQ: QUEUE: Aborted, already in or joining a scenario!]", L"")
			return
		end

		triggeredBlacklistText = wstring.sub(msg, 12, -2)
		if (wstring.sub(triggeredBlacklistText, -2, -2) == L":") then
			triggeredTierText = wstring.sub(triggeredBlacklistText, -1, -1)
			triggeredBlacklistText = wstring.sub(triggeredBlacklistText, 1, -3)
			QueueQueuer.CreateTriggeredBlacklist()
		end

		if ( QueueQueuer.inBattlegroup() == true and queuer == true ) then
			if ( not QueueQueuer.CompareWStrings(player, author) ) then
				if ( triggeredTierText ~= L"" ) then
					QueueQueuer.SendChatText(L"/wb [QQ: GROUP QUEUE " .. triggeredBlacklistText .. L":" .. triggeredTierText .. L"]", L"")
				else
					QueueQueuer.SendChatText(L"/wb [QQ: GROUP QUEUE " .. triggeredBlacklistText .. L"]", L"")
				end
			end
			QueueQueuer.SetQueueStep( 1 )
			GameData.ScenarioQueueData.selectedId = 0
			queueCooldown = false -- cancel cooldown period
			queueAttempts = queueAttemptsDefault -- reset attempts
			sendPopMessage = true
		end

		-- old way of doing things, just in case
	elseif ((msg == L"[QQ: Queue up.]" or msg == L"[QQ: QUEUE]" or msg == L"[QQ: JOIN]") and queuer == true) then
		if (GameData.Player.isInScenario == true or
			GameData.Player.isInSiege == true or
			WindowGetShowing("EA_Window_ScenarioStarting") or
			WindowGetShowing("EA_Window_ScenarioJoinPrompt")) then

			QueueQueuer.SendChatText(L"/wb [QQ: QUEUE: Aborted, already in or joining a scenario!]", L"")
			return
		end
		if (leaveStep > 0) then
			QueueQueuer.SendChatText(L"/wb [QQ: QUEUE: Aborted, already in the process of leaving queues!]", L"")
			return
		elseif (queueStep > 0) then
			QueueQueuer.SendChatText(L"/wb [QQ: QUEUE: Aborted, already in the process of joining queues!]", L"")
			return
		end

		if ( QueueQueuer.inBattlegroup() == true and queuer == true ) then
			if ( not QueueQueuer.CompareWStrings(player, author) ) then
				QueueQueuer.SendChatText(L"/wb [QQ: Group joining queues...]", L"")
			end
			QueueQueuer.SetQueueStep( 1 )
			GameData.ScenarioQueueData.selectedId = 0
			queueCooldown = false -- cancel cooldown period
			queueAttempts = queueAttemptsDefault -- reset attempts
			sendPopMessage = true
		end

	elseif (msg == L"[QQ: Leave queues.]" or msg == L"[QQ: LEAVE]" or msg == L"[QQ: UNQUEUE]") then
		if (GameData.Player.isInScenario == true or
			GameData.Player.isInSiege == true) then

			if ( QueueQueuer.inBattlegroup() == true ) then
				QueueQueuer.SendChatText(L"/wb [QQ: LEAVE: Aborted, already in a scenario!]", L"")
			else
				QueueQueuer.SendChatText(L"/p [QQ: LEAVE: Aborted, already in a scenario!]", L"")
			end
			return
		end
		if (leaveStep > 0) then
			if ( QueueQueuer.inBattlegroup() == true ) then
				QueueQueuer.SendChatText(L"/wb [QQ: LEAVE: Aborted, already in the process of leaving queues!]", L"")
			else
				QueueQueuer.SendChatText(L"/p [QQ: LEAVE: Aborted, already in the process of leaving queues!]", L"")
			end
			return
		elseif (queueStep > 0) then
			if ( QueueQueuer.inBattlegroup() == true ) then
				QueueQueuer.SendChatText(L"/wb [QQ: LEAVE: Aborted, already in the process of joining queues!]", L"")
			else
				QueueQueuer.SendChatText(L"/p [QQ: LEAVE: Aborted, already in the process of joining queues!]", L"")
			end
			return
		end
		if ( QueueQueuer.inBattlegroup() == true and queuer == true ) then
			if ( not QueueQueuer.CompareWStrings(player, author) ) then
				QueueQueuer.SendChatText(L"/wb [QQ: Group leaving queues...]", L"")
			end
		end
		leaveStep = 1
		queueCooldown = false -- cancel cooldown period
		queueAttempts = queueAttemptsDefault -- reset attempts

	elseif (wstring.sub(msg, 1, 18) == L"[QQ: QUEUER CHECK " and queuer == true) then
		if ( QueueQueuer.inBattlegroup() == true ) then
			local zoneName = L""
			local code = wstring.sub(msg, 19, 23)
			zoneName = GetZoneName(GameData.Player.zone)
			zoneName = QueueQueuer.FixName(zoneName) -- there is some weird shit at the tail end of these zone strings
			if ( not QueueQueuer.CompareWStrings(player, author) ) then
				QueueQueuer.SendChatText(L"/wb [QQ: REPORT " .. code .. L" v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L"]", L"")
			end
		end
	elseif (wstring.sub(msg, 1, 18) == L"[QQ: QUEUER CHECK]" and queuer == true) then
		-- old version
		if ( QueueQueuer.inBattlegroup() == true ) then
			local zoneName = L""
			zoneName = GetZoneName(GameData.Player.zone)
			zoneName = QueueQueuer.FixName(zoneName) -- there is some weird shit at the tail end of these zone strings
			if ( not QueueQueuer.CompareWStrings(player, author) ) then
				QueueQueuer.SendChatText(L"/wb [Queue Queuer v" .. towstring(QueueQueuer.GetVersion()) .. L": GROUP " .. towstring(QueueQueuer.GetGroup()) .. L" QUEUER!]", L"")
			end
		end
	elseif (wstring.sub(msg, 1, 12) == L"[QQ: REPORT ") then
		local group = wstring.sub(msg, -2, -2)
		local code = wstring.sub(msg, 13, 17)
		if ( code == randomCode ) then
			-- this random code business is a precaution against someone
			-- trying to 'game' the system and fake themselves as a queuer
			-- to incorrectly gain warband assistant status
			if ( QueueQueuer.CompareWStrings(player, PartyUtils.GetWarbandLeader().name) ) then
				-- are we the leader?
				QueueQueuer.UpdateQueuerList(author, group)
			end
		end
	end
end