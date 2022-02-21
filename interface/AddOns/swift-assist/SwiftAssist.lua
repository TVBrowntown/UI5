-- credits for the original idea and icons to Yak, where the hell are you ;P
-- mod was edited by Wothor aka Philsound

-- mod was reworked and extended by Aktheon (smiling Aktheon)

local SwiftVersion = L"v2.4.4 "

local SwiftLineS = L"[SwiftAssist] : "
local SwiftLineSC = L"<LINK data=\"0\" text=\"[SwiftAssist]\" color=\"255,255,125\"> : "
local SwiftIcon = L"<icon64> "
local SwiftKillIcon = L"<icon51> "
local PatternAssistMe = L"Assist on my target "

local ChannelCodes = {
	["say"] = 0,
	["shout"] = 11,
	["region"] = 57,
	["p"] = 4,
	["wb"] = 14,
	["sc"] = 15,
	["sp"] = 16,
}

local SmartAssistSound = 1102

SwiftAssist = {}
local Addon = SwiftAssist
Addon.Settings = {}
Addon.target = L""

local Events = {MYASSIST = 1}--, SCENARIO_MODE_CHANGED = 2}
Addon.Events = Events
Addon.EventCallbacks = Addon.EventCallbacks or {}
local EventCallbacks = Addon.EventCallbacks

local tonumber = tonumber
local string_find = string.find

local SetMacroData = SetMacroData
local SendChatText = SendChatText
local WindowSetShowing = WindowSetShowing
local GetIconData = GetIconData
local LabelSetText = LabelSetText
local DynamicImageSetTexture = DynamicImageSetTexture

local redirect = 0
local assistMacroId = -1
local assistSmartMacroId = -1

local playersName = nil
local function GetPlayersName()
	if (playersName == nil) then
	    playersName = (GameData.Player.name)
	end
	return playersName
end

local playersFormatedName = nil
local function GetPlayersFormatedName()
	if playersFormatedName == nil then
		playersFormatedName = GetPlayersName():match(L"([^^]+)^?([^^]*)")
	end
	return playersFormatedName
end

local function GetChannel()
	local serverCmd
	if GameData.Player.isInSiege then
		if Addon.Settings.AnnounceSiege == nil and Addon.Settings.AnnounceScInSiege then
			serverCmd = Addon.Settings.AnnounceScenario
		else
			serverCmd = Addon.Settings.AnnounceSiege
		end
	elseif  GameData.Player.isInScenario then
		serverCmd = Addon.Settings.AnnounceScenario
	elseif IsWarBandActive() then
		serverCmd = Addon.Settings.AnnounceWorld
	elseif PartyUtils.IsPartyActive() and Addon.Settings.AnnounceWorld == L"/wb" then
		serverCmd = L"/p"	-- when set to warband, but in party: fallback to party
	else
		serverCmd = Addon.Settings.AnnounceWorld
	end
	return serverCmd
end

function Addon.Inactive(opt)
	if opt == L"assist" then
		EA_ChatWindow.Print(SwiftLineSC .. L"Assist macro is inactive, please select allie and use SwiftSetAssist")
	elseif opt == L"smart" then
		EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist macro is inactive, please configured it via /swift smart, and make sure someone have used SwiftAssistMe")
	end
end

function Addon.AssistMe()
	local serverCmd = GetChannel()

	TargetInfo:UpdateFromClient()
	local eName = TargetInfo:UnitName ("selfhostiletarget")
	local eCareer = TargetInfo:UnitCareer("selfhostiletarget")

	if (serverCmd and eName ~= L"" ) then
		local textToSend = SwiftLineSC .. PatternAssistMe .. SwiftKillIcon .. eName
		if eCareer ~= 0 then
			textToSend = textToSend .. L"<icon" .. Icons.GetCareerIconIDFromCareerLine(eCareer) .. L">"
		end
		SendChatText(textToSend, serverCmd)
	end
end

local function AnnounceSetAssist()
	local serverCmd = GetChannel()
	if (serverCmd and Addon.target ~= L"") then
		SendChatText(SwiftLineSC .. L"Assisting " .. SwiftIcon .. Addon.target, serverCmd)
	end
end

local function BroadcastSwiftAssistEvent(Event)
	if EventCallbacks[Event] == nil then return end
	if Event == Events.MYASSIST then
		for _, CallbackFunction in ipairs(EventCallbacks[Event]) do
			CallbackFunction((Addon.target):match(L"([^^]+)^?([^^]*)"))
		end
	end
end

local function isChannelAllowed(chCode)
	if Addon.Settings.SmartAssist == L"all" then
		for a,b in pairs(ChannelCodes) do
			if b == chCode then
				return true
			end
		end
	--elseif Addon.Settings.SmartAssist == L"name" then
		--return true
	elseif not IsWarBandActive() and Addon.Settings.SmartAssist == L"wb" and ChannelCodes["p"] == chCode then
		return true
	elseif ChannelCodes[tostring(Addon.Settings.SmartAssist)] == chCode then
		return true
	end
	return false
end

--[SwiftAssist] : Assist on my target <icon51> asd
local function ParseEntry(msg, channelCode)
	local trigB, _ = string.find( tostring(msg), tostring(SwiftLineS .. PatternAssistMe), 1, true )
	if trigB ~= nil then
		local senderNameB
		if ChannelCodes["say"] == channelCode then
			senderNameB, _ = string.find(tostring(msg), "[", 1, true)
		else
			senderNameB, _ = string.find(tostring(msg), "[", 2, true)
		end
		local senderNameEnd, _ = string.find(tostring(msg), "]", senderNameB, true)
		local SenderName, _ = string.sub(tostring(msg), senderNameB+1, senderNameEnd-1)

		return towstring(SenderName)
		--[[atm useless
		if Addon.Settings.SmartAssist == L"name" then
			if Addon.Settings.SmartAssistName == towstring(SenderName) then
				return towstring(SenderName)
			end
		else
			return towstring(SenderName)
		end]]
	end
end

local function SetSmartLabel(wtxt, show)
	LabelSetText("SwiftAssistSmartLabel", wtxt)
	LabelSetText("SwiftAssistSmartShadow", wtxt)
	if show ~= nil then
		WindowSetShowing("SwiftAssistSmartCareerIcon", show)
		WindowSetShowing("SwiftAssistSmartCareerIconFX", show)
	end
end

function Addon.onChatUpdated()
	if Addon.Settings.SmartAssist ~= nil then --SmartAssist enabled
		local num = TextLogGetNumEntries("Chat") - 1
		local _, channelCode, msg = TextLogGetEntry("Chat", num)

		if isChannelAllowed(channelCode) == true then
			local playerToAssist = ParseEntry(msg, channelCode)

			if (playerToAssist ~= nil) and (playerToAssist ~= GetPlayersFormatedName()) then
				SetMacroData (L"SwiftSmartAssist", L"/assist " .. playerToAssist, 192, assistSmartMacroId)
				SetSmartLabel(playerToAssist, true)
				if Addon.Settings.SmartAssistPlaySound == 1 then
					PlaySound(SmartAssistSound)
				end
			end
		end
	end
end

function Addon.RegisterEventHandler(Event, CallbackFunction)
	if EventCallbacks[Event] == nil then EventCallbacks[Event] = {} end
	local isInStock
	for _, callbck in ipairs(EventCallbacks[Event]) do
		if callbck == CallbackFunction then
			isInStock = true
			break
		end
	end
	if not isInStock then
		table.insert(EventCallbacks[Event], CallbackFunction)
	end
	if Event == Events.MYASSIST and Addon.target ~= L"" then	-- Broadcast current immediately
		CallbackFunction(Addon.target)
	end
end

function Addon.UnregisterEventHandler(Event, CallbackFunction)
	for k, callbck in ipairs(EventCallbacks[Event]) do
		if callbck == CallbackFunction then
			table.remove(EventCallbacks[Event], k)
			break
		end
	end
end

local function WriteLabels(text)
	LabelSetText("SwiftAssistLabel", text)
	LabelSetText("SwiftAssistShadow", text)
end

local function SetTexLabel()
	WriteLabels(towstring(Addon.target))
	local tex,x,y=GetIconData(Icons.GetCareerIconIDFromCareerLine(Addon.career))
	DynamicImageSetTexture("SwiftAssistCareerIcon",tex,x,y)
	WindowSetShowing("SwiftAssistCareerIcon", true)
	WindowSetShowing("SwiftAssistCareerIconFX", true)
end

local function GetMacroId(aWString)
	local macros = DataUtils.GetMacros()
	for slot = 1, EA_Window_Macro.NUM_MACROS do
		if macros[slot] and (macros[slot].text == aWString or macros[slot].name == aWString) then return slot end
	end
end

local function CreateMacro(name, text, iconId)
	local slot = GetMacroId (name)
	if (slot) then return slot end
	local macros = DataUtils.GetMacros()
	for slot = 1, EA_Window_Macro.NUM_MACROS
	do
		if (macros[slot].text == L"")
		then
			SetMacroData (name, text, iconId, slot)
 			EA_Window_Macro.UpdateMacros ()
			return slot
		end
	end
end

local function TellBroadcastState(x)
	if Addon.Settings.AnnounceWorld and ( x==nil or x=="w" ) then EA_ChatWindow.Print(SwiftLineSC .. L"Announce set for World : " .. Addon.Settings.AnnounceWorld ) end
	if Addon.Settings.AnnounceScenario and ( x==nil or x=="sc" ) then EA_ChatWindow.Print(SwiftLineSC .. L"Announce set for Scenario : " .. Addon.Settings.AnnounceScenario ) end
	if Addon.Settings.AnnounceSiege and ( x==nil or x=="city" ) then EA_ChatWindow.Print(SwiftLineSC .. L"Announce set for CitySiege : " .. Addon.Settings.AnnounceSiege ) end
	if Addon.Settings.AnnounceScInSiege and ( x==nil or x=="city" ) then EA_ChatWindow.Print(SwiftLineSC .. L"City Siege will use Scenario's settings (if no settings set for City)" ) end
	if Addon.Settings.SmartAssist and ( x==nil or x=="smart" ) then EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist set to : " .. Addon.Settings.SmartAssist ) end
	--if Addon.Settings.SmartAssistName and Addon.Settings.SmartAssist == L"name" and ( x==nil or x=="smart" ) then EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist limited to assist only player : " .. Addon.Settings.SmartAssistName ) end
end

local function SlashHandler(cmd)
  local opt, args = cmd:match("([a-zA-Z0-9]+)[ ]?(.*)")
	if opt then opt = opt:lower() end
	if args then args = args:lower() end

	if opt == "set" or opt == "world" then
		if args == "party" or args == "p" then
			Addon.Settings.AnnounceWorld = L"/p"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in World: Party")
		elseif args == "warband" or args == "wb" then
			Addon.Settings.AnnounceWorld = L"/wb"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in World: Warband")
		elseif args == "say" or args == "s" then
			Addon.Settings.AnnounceWorld = L"/s"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in World: Say")
		elseif args == "disable" or args == "off" then
			Addon.Settings.AnnounceWorld = nil
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in World has been Disabled")
		else
			TellBroadcastState("w")
			EA_ChatWindow.Print(SwiftLineSC .. L"Secondary Arguments to \"set\":<br>say(s), party(p), warband(wb), disable(off)")
		end

	elseif opt == "sc" then
		if args == "party" or args == "p" then
			Addon.Settings.AnnounceScenario = L"/p"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in Scenario: Party")
		elseif args == "warband" or args == "wb" then
			Addon.Settings.AnnounceScenario = L"/wb"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in Scenario: Warband")
		elseif args == "scenario" or args == "sc" then
			Addon.Settings.AnnounceScenario = L"/sc"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in Scenario: Scenario")
		elseif args == "scenarioparty" or args == "sp" then
			Addon.Settings.AnnounceScenario = L"/sp"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in Scenario: ScenarioParty")
		elseif args == "say" or args == "s" then
			Addon.Settings.AnnounceScenario = L"/s"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in Scenario: Say")
		elseif args == "disable" or args == "off" then
			Addon.Settings.AnnounceScenario = nil
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in Scenario has been Disabled")
		else
			TellBroadcastState("sc")
			EA_ChatWindow.Print(SwiftLineSC .. L"Secondary Arguments to \"sc\":<br>say(s), party(p), warband(wb),<br>scenario(sc), scenarioparty(sp), disable(off)")
		end

	elseif opt == "city" then
		if args == "party" or args == "p" then
			Addon.Settings.AnnounceSiege = L"/p"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege: Party")
		elseif args == "warband" or args == "wb" then
			Addon.Settings.AnnounceSiege = L"/wb"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege: Warband")
		elseif args == "city" or args == "sc" then
			Addon.Settings.AnnounceSiege = L"/sc"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege: Scenario(City)")
		elseif args == "cityparty" or args == "sp" then
			Addon.Settings.AnnounceSiege = L"/sp"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege: ScenarioParty(City)")
		elseif args == "say" or args == "s" then
			Addon.Settings.AnnounceSiege = L"/s"
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege: Say")
		elseif args == "disable" or args == "off" then
			Addon.Settings.AnnounceSiege = nil
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege has been Disabled")

		elseif args == "usescenario" or args == "usesc" then
			Addon.Settings.AnnounceScInSiege = true
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege: Use Scenario settings (in case city settings off)")
		elseif args == "usescenariooff" or args == "useoff" then
			Addon.Settings.AnnounceScInSiege = nil
			EA_ChatWindow.Print(SwiftLineSC .. L"Announce in City Siege: Stoped usage of Scenario settings")
		else
			TellBroadcastState("city")
			EA_ChatWindow.Print(SwiftLineSC .. L"Secondary Arguments to \"city\":<br>say(s), party(p), warband(wb),<br>city(sc), cityparty(sp), disable(off),<br>usescenario(usesc), usescenariooff(useoff)")
		end

	elseif opt == "smart" then
		if args == "all" or args == "on" then
			Addon.Settings.SmartAssist = L"all"
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist enabled for : All players")
		elseif args == "party" or args == "p" then
			Addon.Settings.SmartAssist = L"p"
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist enabled for : Party")
		elseif args == "warband" or args == "wb" then
			Addon.Settings.SmartAssist = L"wb"
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist enabled for : Warband")
		elseif args == "scenario" or args == "sc" then
			Addon.Settings.SmartAssist = L"sc"
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist enabled for : Scenario")
		elseif args == "scenarioparty" or args == "sp" then
			Addon.Settings.SmartAssist = L"sp"
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist enabled for : Scenario Party")

		elseif args == "disable" or args == "off" then
			Addon.Settings.SmartAssist = nil
			--Addon.Settings.SmartAssistName = nil
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist has been Disabled")
			SetSmartLabel(L"", false)
			SetMacroData (L"SwiftSmartAssist", L"/script SwiftAssist.Inactive(L\"smart\")", 177, assistSmartMacroId)
		elseif args == "reset" or args == "clear" then
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist : Stored Player name has been reset")
			SetSmartLabel(L"", false)
			SetMacroData (L"SwiftSmartAssist", L"/script SwiftAssist.Inactive(L\"smart\")", 177, assistSmartMacroId)

		elseif args == "soundon" then
			Addon.Settings.SmartAssistPlaySound = 1
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist sound : Enabled")
		elseif args == "soundoff" then
			Addon.Settings.SmartAssistPlaySound = 2
			EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist soung : Disabled")

		elseif args == "help" then
			EA_ChatWindow.Print(SwiftLineSC .. L"Enabled Smart Assist will track usage of \"SwiftAssistMe\" macro by other players and will set \"SwiftSmartAssist\" to be able to assist him.")
			EA_ChatWindow.Print(L"You can limit Smart Assist to track messages only in: wb, party, scenario or assist anyone<br>Use \"/swift smart\" for options")
			EA_ChatWindow.Print(SwiftLineSC .. L"You might want to turn off Smart Assist (\"/swift smart off\") when not needed to increase performance")
		else

			--[[local isSetName, nameStartsAt = string.find(tostring(args), "only")
			if isSetName ~= nil then
				local SmartAssistName = string.sub(tostring(args), nameStartsAt+2)
				if SmartAssistName ~= "" then
					Addon.Settings.SmartAssist = L"name"
					Addon.Settings.SmartAssistName = towstring( string.gsub(SmartAssistName, "^%l", string.upper) )
					EA_ChatWindow.Print(SwiftLineSC .. L"Smart Assist was set to assist player : " .. Addon.Settings.SmartAssistName)
				else
					EA_ChatWindow.Print(SwiftLineSC .. L"Please provide Player's name for Smart Assist: /swiftassist smart only <PlayerName>")
				end

			else]]
				TellBroadcastState("smart")
				EA_ChatWindow.Print(SwiftLineSC .. L"Secondary Arguments to \"smart\":<br>all(on), party(p), warband(wb),<br>scenario(sc), scenarioparty(sp), disable(off),<br>help, soundon, soundoff, reset(clear)")
			--end
		end

	elseif opt == "menu" then
		--feature coming Soon(tm)

	elseif opt == "help" then
		EA_ChatWindow.Print(SwiftLineSC .. L"This addon will let you mark selected player as Assisted player with \"SwiftSetAssist\" macro and select his target with \"SwiftAssist\" macro")
		EA_ChatWindow.Print(L"You can use \"SwiftAssistMe\" macro to ask in chat to assist on your target (uses same broadcast options as SwiftSetAssist, use \"/swift set/sc/city\")")
		EA_ChatWindow.Print(L"If \"/swift smart\" enabled - your macro \"SwiftSmartAssist\" will be set to assist last player that has used \"SwiftAssistMe\" macro")

	elseif opt == "d" then
		d(GameData.Player) --debug

	else
		--EA_ChatWindow.Print(L"Argument needed! Possible Arguments:<br>set<br>")
		--EA_ChatWindow.Print(SwiftLineSC .. L"Secondary Arguments to set:<br>say, party, warband, worldoff,<br>scenario, scenarioparty, scenariooff")
		--EA_ChatWindow.Print(L"") -- new line

		--Deprecated
		--[[if assistMacroId ~= -1 then
			EA_ChatWindow.Print(SwiftLineSC .. L"Assist Macro found: " .. assistMacroId)
		else
			EA_ChatWindow.Print(SwiftLineSC .. L"Assist Macro not found!")
		end]]

		TellBroadcastState()
		EA_ChatWindow.Print(SwiftLineSC .. L"You can use \"set(world)\", \"sc\", \"city\" as Argument to select case and set broadcast channel.<br>Use \"smart\" to Enable and configure SmartAssist. Use \"help\" for more info")
	end
end

function Addon.Initialize()
	CreateWindow("SwiftAssist", true)
	WindowSetShowing("SwiftAssistCareerIcon", false)
	WindowSetShowing("SwiftAssistCareerIconFX", false)

	LayoutEditor.RegisterWindow( "SwiftAssist", L"SwiftAssist", L"SwiftAssist", false, false, true, nil )
	WriteLabels(L"")
	local tex,_,_=GetIconData(64)
	DynamicImageSetTexture("SwiftAssistSmartCareerIcon",tex,0,0)
	SetSmartLabel(L"",false)

	RegisterEventHandler(SystemData.Events.MACROS_LOADED, "SwiftAssist.OnMacrosLoaded")
	RegisterEventHandler(SystemData.Events.MACRO_UPDATED, "SwiftAssist.OnMacroUpdated")

	Addon.OnMacrosLoaded()

	if LibSlash then
		LibSlash.RegisterSlashCmd("swift", SlashHandler)
	else
		local orig_ChatWindow_OnKeyEnter = EA_ChatWindow.OnKeyEnter
		EA_ChatWindow.OnKeyEnter = function(...)
				local input = WStringToString(EA_TextEntryGroupEntryBoxTextInput.Text)
				local cmd, args = input:match("^/([a-zA-Z]+)[ ]?(.*)")
				if cmd then
					cmd = cmd:lower()
					if cmd == "swiftassist" then
						SlashHandler(args)
						EA_TextEntryGroupEntryBoxTextInput.Text = L""
					end
				end
				return orig_ChatWindow_OnKeyEnter(...)
			end
	end

	RegisterEventHandler( TextLogGetUpdateEventId( "Chat" ), "SwiftAssist.onChatUpdated" )
	if not Addon.Settings.SmartAssistPlaySound then
		Addon.Settings.SmartAssistPlaySound = 1
	end

	EA_ChatWindow.Print(L"<icon57> " .. SwiftLineSC .. SwiftVersion .. L"has been initialized. Use /swift for more details" )
end

function Addon.OnMacrosLoaded()
	--if ( not GetMacroId(L"/script SwiftAssist.SetMark()") ) then CreateMacro(L"ySetMark", L"/script SwiftAssist.SetMark()", 190) end

	--SwiftSetAssist
	if ( not GetMacroId(L"SwiftSetAssist") ) then
		local macroSetAssistId = GetMacroId(L"SetAssist")
		if ( not macroSetAssist ) then
			CreateMacro(L"SwiftSetAssist", L"/script SwiftAssist.SetAssist()", 193)
		else
			SetMacroData (L"SwiftSetAssist", L"/script SwiftAssist.SetAssist()", 193, macroSetAssistId ) --update old Macro
		end
	end

	--SwiftAssist
	assistMacroId = GetMacroId(L"SwiftAssist")
	if ( not assistMacroId ) then
		local oldAssistMacroId = GetMacroId(L"Assist")
		if ( not oldAssistMacroId ) then
			assistMacroId = CreateMacro(L"SwiftAssist", L"/script SwiftAssist.Inactive(L\"assist\")", 177)
		else
			SetMacroData (L"SwiftAssist", L"/script SwiftAssist.Inactive(L\"assist\")", 177, oldAssistMacroId )
		end
	end

	--SwiftAssistMe
	if ( not GetMacroId(L"SwiftAssistMe") ) then CreateMacro(L"SwiftAssistMe", L"/script SwiftAssist.AssistMe()", 51) end

	--SwiftSmartAssist
	assistSmartMacroId = GetMacroId(L"SwiftSmartAssist")
	if ( not assistSmartMacroId ) then assistSmartMacroId = CreateMacro(L"SwiftSmartAssist", L"/script SwiftAssist.Inactive(L\"smart\")", 177) end
end

function Addon.OnMacroUpdated(macroId)
	if macroId == assistMacroId then
		if Addon.target ~= L"" then
			SetTexLabel()
		else
			WriteLabels(L"")
			WindowSetShowing("SwiftAssistCareerIcon", false)
			WindowSetShowing("SwiftAssistCareerIconFX", false)
		end
		BroadcastSwiftAssistEvent(Events.MYASSIST)
		AnnounceSetAssist()
	end
end

--[[function Addon.Mark()
	if redirect == 0 then
		-- trigger main assist
	elseif redirect == 1 then
		Enemy.Mark()
	end
end]]--

function Addon.SetAssist()
	local actwnd = SystemData.MouseOverWindow.name
	local needsUpdate
	if actwnd == "EnemyIcon" or actwnd == "WarBoard_TogglerEnemy" then
		--[[redirect = 1
		DynamicImageSetTexture("SwiftAssistCareerIcon","SwiftAssistRedirect",0,0)
		WriteLabels(L"Enemy")
		WindowSetShowing("SwiftAssistCareerIcon", true)
		WindowSetShowing("SwiftAssistCareerIconFX", true)]]--
	else
		local isSetter = false
		if Effigy and Effigy.GetMouseOverFormationIndexes then
			local groupIndex,memberIndex=Effigy.GetMouseOverFormationIndexes()
			if memberIndex then
				isSetter = true
				local State = (groupIndex and EffigyState:GetState("Formation"):GetChildState(memberIndex,groupIndex)) or EffigyState:GetState("Party"):GetChildState(memberIndex)
				local name = State:GetExtraInfo("rawname")
				if name ~= GetPlayersName() and name ~= Addon.target then
					Addon.target = name
					Addon.career = State:GetExtraInfo("careerLine")
					redirect = 0
					needsUpdate = true
				end
			end
		end
		if isSetter == false then
			if Squared then
				local _,_,squaredgrp,squaredmember=string_find(actwnd,"^SquaredUnit_(%d+)_(%d+)Action")
				squaredgrp = tonumber(squaredgrp)
				squaredmember = tonumber(squaredmember)
				if squaredgrp ~= nil and squaredmember ~= nil then
					isSetter = true
					local squaredtarget = Squared.GetUnit(squaredgrp,squaredmember)
					local name = squaredtarget.rawname
					if name ~= GetPlayersName() and name ~= Addon.target then
						Addon.target = name
						Addon.career = squaredtarget.career
						redirect = 0
						needsUpdate = true
					end
				end
			end
		end
		if isSetter == false then
			if Enemy then
				local group_index, index, frame = Enemy._GetUnitFrameFromWindowName (SystemData.MouseOverWindow.name)
				if frame then
					isSetter = true
					local name = frame.playerName
					if name ~= GetPlayersFormatedName() and name ~= Addon.target then
						Addon.target = name
						Addon.career = frame.playerCareer
						redirect = 0
						needsUpdate = true
					end
				end
			end
		end
		if isSetter == false then
			TargetInfo:UpdateFromClient()
			local name = TargetInfo:UnitName ("selffriendlytarget")
			if name ~= Addon.target then
				if name ~= L"" and name ~= GetPlayersName() then
					local ftCareer = TargetInfo:UnitCareer("selffriendlytarget")
					if ftCareer ~= 0 then
						Addon.target = name
						Addon.career = ftCareer
						redirect = 0
						needsUpdate = true
					else
						EA_ChatWindow.Print(SwiftLineSC .. L"You cannot assist NPCs or pets!")
						return
					end
				else
					d(L"resetting Assist")
					Addon.target = L""
					Addon.career = 0
					redirect = 0
					needsUpdate = true
				end
			end
		end
	end
	if needsUpdate then
		d(L"updating Macro " .. assistMacroId .. L" " .. Addon.target)
		if Addon.target == L"" then
			SetMacroData (L"SwiftAssist", L"/script SwiftAssist.Inactive(L\"assist\")", 177, assistMacroId)
		else
			SetMacroData (L"SwiftAssist", L"/assist " .. Addon.target, 190, assistMacroId)
			--SetMacroData (L"SwiftAssist", L"/assist"..(((Addon.target ~= L"") and L" "..Addon.target) or L""), 190, assistMacroId)	-- rewrite assist macro
		end
	end
end

--[[
local num = TextLogGetNumEntries("Combat") - 1
_, _, msg = TextLogGetEntry("Combat", num);
if ( filter == PET_HITS ) then
												p_damage,  _, fields.p_damage[1],  fields.p_damage[2],  fields.p_damage[3]  = text:find(ParseTable.dealt.pet.parse)
]]
