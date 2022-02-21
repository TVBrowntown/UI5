local Enemy = Enemy
local g = {}

local YOUR_HITS = SystemData.ChatLogFilters.YOUR_HITS
local YOUR_HEALS = SystemData.ChatLogFilters.YOUR_HEALS
--local PET_DMG = SystemData.ChatLogFilters.PET_DMG
local PET_HITS = SystemData.ChatLogFilters.PET_HITS
local YOUR_DMG_FROM_PC = SystemData.ChatLogFilters.YOUR_DMG_FROM_PC
local YOUR_DMG_FROM_NPC = SystemData.ChatLogFilters.YOUR_DMG_FROM_NPC

Enemy.CombatLogTypes =
{
	IncommingDamage = 1,
	OutgoingDamage = 2,
	IncommingHeal = 3,
	OutgoingHeal = 4
}

Enemy.CombatLogTypeNames =
{
	[Enemy.CombatLogTypes.IncommingDamage] = L"Incomming damage",
	[Enemy.CombatLogTypes.OutgoingDamage] = L"Outgoing damage",
	[Enemy.CombatLogTypes.IncommingHeal] = L"Incomming heal",
	[Enemy.CombatLogTypes.OutgoingHeal] = L"Outgoing heal"
}

Enemy.CombatLogTypeEpsNames =
{
	[Enemy.CombatLogTypes.IncommingDamage] = L"DPS",
	[Enemy.CombatLogTypes.OutgoingDamage] = L"DPS",
	[Enemy.CombatLogTypes.IncommingHeal] = L"HPS",
	[Enemy.CombatLogTypes.OutgoingHeal] = L"HPS"
}

Enemy.CombatLogTargetDefenseTypes =
{
	Mitigation = 1,
	Absorb = 2,
	Block = 3,
	Parry = 4,
	Disrupt = 5,
	Dodge = 6
}

local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local strmatch = wstring.match
local tinsert = table.insert
local tremove = table.remove
local mmin = math.min
local mmax = math.max
local mmodf = math.modf
local mabs = math.abs
local mfloor = math.floor


local MACRO_TOGGLE = L"/script Enemy.CombatLogStatsWindowToggle()"


--------------------------------------------------------------- Init

function Enemy.CombatLogInitialize ()
	
	g.settings = Enemy.Settings

	Enemy.combatLog = g
	--g.isPluginEnabled = Enemy.DefaultSettings.combatLogEnabled
		
	g.allStats = Enemy.Settings.CombatLogStats
	if (not g.allStats) then Enemy.CombatLog_ResetStatsAllSessions () end
	
	g.stats = g.allStats[#g.allStats]
	if (not g.stats) then Enemy.CombatLog_StatsSessionAdd () end
	
	if (Enemy.Settings.prevVersion > 0)
	then
		if (math.modf (Enemy.Settings.prevVersion) < 274)
		then
			DialogManager.MakeTwoButtonDialog (L"Enemy addon\n\nCause of considerable changes in combat log statistics code it's recommended to reset combat log settings to default values. Only combat log settings will be affected.\n\nDo you want to reset it now (you will have to wait for game interface to reload)?\n\nRecommended - yes",
	                                       L"Yes", Enemy.CombatLogResetSettings,
	                                       L"No")
		end
		
		if (math.modf (Enemy.Settings.prevVersion) < 278)
		then
			Enemy.CombatLog_ResetStatsAllSessions ()
		end
			
		if (math.modf (Enemy.Settings.prevVersion) < 279)
		then
			for _, s in ipairs (g.allStats)
			do
				for _, eps in pairs (s.eps)
				do
					eps.object = eps.data[#eps.data].object
					eps.objectTime = eps.data[#eps.data].time
				end
			end
		end
	end
	
	-- UI: config
	g.configDlgSection =
	{
		name = "CombatLog",
		title = L"Combat log",
		templateName = "EnemyCombatLogConfiguration",
		onInitialize = Enemy.CombatLogUI_ConfigDialog_OnInitialize,
		onLoad = Enemy.CombatLogUI_ConfigDialog_OnLoad,
		onSave = Enemy.CombatLogUI_ConfigDialog_OnSave,
		onReset = Enemy.CombatLogUI_ConfigDialog_OnReset
	}
	
	Enemy.CombatLogUI_StatsWindow_Initialize ()
	Enemy.CombatLogUI_SnapshotWindow_Initialize ()
	Enemy.CombatLogUI_IDS_Initialize ()
	Enemy.CombatLogUI_EpsWindow_Initialize ()
	Enemy.CombatLogUI_TargetDefenseWindow_Initialize ()
	
	-- static events
	Enemy.AddEventHandler ("CombatLog", "SettingsChanged", Enemy.CombatLog_OnSettingsChanged)
	
	Enemy.AddEventHandler ("CombatLog", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections, g.configDlgSection)
	end)

	Enemy.CreateMacro (L"Enemy: toggle combat log stats window", MACRO_TOGGLE, 208)
	
	Enemy.TriggerEvent ("CombatLogInitialized")
end


function Enemy._CombatLogEnabledChanged (enable)

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable
	
	if (g.isPluginEnabled)
	then
		Enemy.CombatLogInitLocalization ()
		
		g.strCrit = Enemy.Localize("combatLogParse_strCrit")
		g.strBlock = Enemy.Localize("combatLogParse_strBlock")
		g.strParry = Enemy.Localize("combatLogParse_strParry")
		g.strDodge = Enemy.Localize("combatLogParse_strDodge")
		g.strDisrupted = Enemy.Localize("combatLogParse_strDisrupted")
		g.strYou = Enemy.Localize("combatLogParse_strYou")
		g.regexMitigation = Enemy.Localize("combatLogParse_regexMitigation")
		g.regexAbsorb = Enemy.Localize("combatLogParse_regexAbsorb")
		g.regexOverheal = Enemy.Localize("combatLogParse_regexOverheal")
		g.regexIncommingDamage = Enemy.Localize("combatLogParse_regexIncommingDamage")
		g.regexIncommingDamageFromSelf = Enemy.Localize("combatLogParse_regexIncommingDamageFromSelf")
		g.regexIncommingDamageIgnored = Enemy.Localize("combatLogParse_regexIncommingDamageIgnored")
		g.regexOutgoingDamage = Enemy.Localize("combatLogParse_regexOutgoingDamage")
		g.regexOutgoingDamageIgnored = Enemy.Localize("combatLogParse_regexOutgoingDamageIgnored")
		g.regexOutgoingPetDamage = Enemy.Localize("combatLogParse_regexOutgoingPetDamage")
		g.regexOutgoingPetDamageIgnored = Enemy.Localize("combatLogParse_regexOutgoingPetDamageIgnored")
		g.regexOutgoingHeal = Enemy.Localize("combatLogParse_regexOutgoingHeal")
		g.regexIncommingHeal = Enemy.Localize("combatLogParse_regexIncommingHeal")
		g.regexIncommingHealYours = Enemy.Localize("combatLogParse_regexIncommingHealYours")
		
		g.damageIgnoreTypeByAction =
		{
			[g.strBlock] = "block",
			[g.strParry] = "parry",
			[g.strDodge] = "dodge",
			[g.strDisrupted] = "disrupt"
		}
		
		g.combatLogParseByType =
		{
			[YOUR_DMG_FROM_NPC] = Enemy.CombatLog_ParseIncommingDamage,
			[YOUR_DMG_FROM_PC] = Enemy.CombatLog_ParseIncommingDamage,
			[YOUR_HITS] = Enemy.CombatLog_ParseOutgoingDamage,
			[PET_HITS] = Enemy.CombatLog_ParseOutgoingPetDamage,
			[YOUR_HEALS] = Enemy.CombatLog_ParseHeal
		}
		
		Enemy.CombatLogFixLocalization (g)
		
		RegisterEventHandler (TextLogGetUpdateEventId ("Combat"), "Enemy.CombatLog_OnCombatLog")

		if (g.settings.combatLogIgnoreWhenPolymorphed)
		then
			Enemy.AddEventHandler ("CombatLog", "GroupsPlayerEffectsUpdated", Enemy.CombatLog_OnGroupsPlayerEffectsUpdated)

			if (Enemy.groups and Enemy.groups.player)
			then
				Enemy.CombatLog_OnGroupsPlayerEffectsUpdated (Enemy.groups.player)
			end
		end
				
		g.wasEnabled = true
	else
		if (g.wasEnabled)
		then
			UnregisterEventHandler (TextLogGetUpdateEventId ("Combat"), "Enemy.CombatLog_OnCombatLog")
		end

		Enemy.RemoveEventHandler ("CombatLog", "GroupsPlayerEffectsUpdated")
	end
end


function Enemy.CombatLog_OnSettingsChanged (settings)

	g.settings = settings
	Enemy._CombatLogEnabledChanged (g.settings.combatLogEnabled)
	Enemy.TriggerEvent ("CombatLogSettingsChanged", g.settings)
end



--------------------------------------------------------------- Sessions

function Enemy.CombatLog_ResetStatsAllSessions ()
	
	g.allStats = {}
	Enemy.Settings.CombatLogStats = g.allStats

	Enemy.CombatLog_StatsSessionAdd ()
	Enemy.CombatLog_ResetStatsCurrentSession ()
end


function Enemy.CombatLog_ResetStatsCurrentSession ()

	g.stats.dt = Enemy.GetCurrentDateTime ()
	g.stats.data = {}
	g.stats.eps = {}

	Enemy.TriggerEvent ("CombatLogSessionsUpdated")
end


function Enemy.CombatLog_StatsSessionAdd (name)

	g.stats =
	{
		name = name or L"Default",
		dt = Enemy.GetCurrentDateTime (),
		data = {},
		eps = {}
	}
	
	tinsert (g.allStats, g.stats)
	Enemy.TriggerEvent ("CombatLogSessionsUpdated")
end


function Enemy.CombatLog_StatsSessionDelete (indexOrStatsObject)

	if (not indexOrStatsObject) then return end
	
	local index = indexOrStatsObject

	if (type (indexOrStatsObject) == "table")
	then
		index = nil
		
		for k, v in ipairs (g.allStats)
		do
			if (v == indexOrStatsObject)
			then
				index = k
				break
			end
		end
	end
	
	if (not index) then return end	
	tremove (g.allStats, index)
	
	if (#g.allStats < 1)
	then
		Enemy.CombatLog_StatsSessionAdd ()
	end
	
	Enemy.TriggerEvent ("CombatLogSessionsUpdated")
end



--------------------------------------------------------------- Main functionality


function Enemy.CombatLog_OnGroupsPlayerEffectsUpdated (player)

	if (not player.isSelf) then return end

	g.isPolymorphed = false

	for _, effect in pairs (player.effects)
	do
		if (Enemy.PolymorphedAbilityIds[effect.abilityId])
		then
			g.isPolymorphed = true
			return
		end
	end
end


function Enemy.CombatLog_GetPlayerInfoForCombatEvent (combatEvent)

	local player = Enemy.latestTargets[TargetInfo.HOSTILE_TARGET]
	if (player and player.name == combatEvent.object) then return player end
	
	player = Enemy.latestTargets[TargetInfo.FRIENDLY_TARGET]
	if (player and player.name == combatEvent.object) then return player end

	if (combatEvent.object == g.strYou or combatEvent.object == Enemy.playerName)
	then
		player = Enemy.groups.player

		if (player ~= nil)
		then
			return
			{
				id = player.worldObjectId,
				name = player.name,
				type = TargetInfo.FRIENDLY_TARGET,
				isFriendly = true,
				isNpc = false,
				career = player.career,
				level = player.level,
				hp = player.hp
			}
		end
	end
	
	return nil
end


function Enemy.CombatLog_OnCombatLog (updateType, filterType)
	
	if (updateType ~= SystemData.TextLogUpdate.ADDED or not g.combatLogParseByType[filterType] or not g.settings) then return end

	
	local time, t, msg = TextLogGetEntry ("Combat", TextLogGetNumEntries ("Combat") - 1)
	if (not (msg)) then return end
		
	local combat_event = g.combatLogParseByType[t] (msg, Enemy.CombatLog_ParseTime (time))
	if (not combat_event and g.settings.combatLogLogParseErrors)
	then
		d (L"Error parsing ["..Enemy.toWString (t)..L"] "..msg)
		return
	end
		
	if (combat_event.value == nil) then combat_event.value = 0 end
		
	if (
			(
				g.settings.combatLogIgnoreAbilityMinValue ~= nil
				and
				(
					(
						combat_event.value >= g.settings.combatLogIgnoreAbilityMinValue
					)
					or
					(
						combat_event.overheal ~= nil
						and
						(combat_event.value + combat_event.overheal) >= g.settings.combatLogIgnoreAbilityMinValue
					)
				)
			)
			or
			(
				g.settings.combatLogIgnoreNpc
				and
				(
					(
						(
							combat_event.type == Enemy.CombatLogTypes.OutgoingHeal
							or
							combat_event.type == Enemy.CombatLogTypes.IncommingHeal
						)
						and
						Enemy.latestTargets[TargetInfo.FRIENDLY_TARGET] ~= nil
						and
						Enemy.latestTargets[TargetInfo.FRIENDLY_TARGET].isNpc
					)
					or
					(
						(
							combat_event.type == Enemy.CombatLogTypes.OutgoingDamage
							or
							combat_event.type == Enemy.CombatLogTypes.IncommingDamage
						)
						and
						Enemy.latestTargets[TargetInfo.HOSTILE_TARGET] ~= nil
						and
						Enemy.latestTargets[TargetInfo.HOSTILE_TARGET].isNpc
					)
				)
			)
			or
			(
				g.settings.combatLogIgnoreWhenPolymorphed
				and
				Enemy.groups.player.isPolymorphed
			)
		)
	then
		return
	end

	
	combat_event.currentTarget = false
		
	if (
			combat_event.type == Enemy.CombatLogTypes.OutgoingHeal
			and
			Enemy.latestTargets[TargetInfo.FRIENDLY_TARGET] == nil
			and
			(combat_event.object == g.strYou or combat_event.object == Enemy.playerName)
		)
	then
		combat_event.currentTarget = true
	else
		local player = Enemy.latestTargets[TargetInfo.HOSTILE_TARGET]
		if (player and player.name == combat_event.object) then combat_event.currentTarget = true end
		
		player = Enemy.latestTargets[TargetInfo.FRIENDLY_TARGET]
		if (player and player.name == combat_event.object) then combat_event.currentTarget = true end
	end

	if (
			g.settings.combatLogIgnoreNpc
			and
			not combat_event.currentTarget
		)
	then
		return
	end

	-- combat statistics
	local combat_event2 = nil
	if (g.settings.combatLogStatisticsEnabled)
	then
		Enemy._CombatLog_StatisticsAddCombatEvent (combat_event)
		
		-- if we've been healing ourself then emulate incomming heal combat event
		if (combat_event.type == Enemy.CombatLogTypes.OutgoingHeal and combat_event.object == g.strYou)
		then
			combat_event2 = Enemy.clone (combat_event)
			combat_event2.type = Enemy.CombatLogTypes.IncommingHeal
			combat_event2.object = Enemy.playerName
			
			Enemy._CombatLog_StatisticsAddCombatEvent (combat_event2)
		end
	end
	
	Enemy.TriggerEvent ("CombatLogNewCombatEvent", combat_event)
	if (combat_event2) then Enemy.TriggerEvent ("CombatLogNewCombatEvent", combat_event2) end
end
		
		
local function ResetEps (eps)
	
	eps.data = {}
	
	eps.object = nil			-- name of the latest target for single target eps
	eps.objectTime = nil		-- time when the latest target has been set

	eps.total = 0
	eps.totalAoe = 0
	eps.value = nil
	eps.valueAoe = nil

	eps.valueMax = nil
	eps.valueMaxData = nil
	eps.valueAoeMax = nil
	eps.valueAoeMaxData = nil
end
		
		
function Enemy._CombatLog_StatisticsAddCombatEvent (combatEvent)

	local stats = g.stats.data[combatEvent.type]
	if (not stats)
	then
		stats = {}
		g.stats.data[combatEvent.type] = stats
	end


	local eps = g.stats.eps[combatEvent.type]
	if (not eps)
	then
		eps = {}
		ResetEps (eps)
		g.stats.eps[combatEvent.type] = eps
	end

	
	local ability_name = combatEvent.ability
	if (combatEvent.type == Enemy.CombatLogTypes.IncommingHeal)
	then
		ability_name = combatEvent.object..L" - "..ability_name
	end
	
	local ability_stats = stats[ability_name]
	if (not ability_stats)
	then
		ability_stats =
		{
			normal =
			{
				count = 0,
				total = 0,
				overheal = 0,
				mit = 0,
				abs = 0,
				min = nil,
				minObject = nil,
				max = nil,
				maxObject = nil
			},
			
			crit =
			{
				count = 0,
				total = 0,
				overheal = 0,
				mit = 0,
				abs = 0,
				min = nil,
				minObject = nil,
				max = nil,
				maxObject = nil
			},
			
			block = 0,
			parry = 0,
			disrupt = 0,
			dodge = 0
		}
		
		stats[ability_name] = ability_stats
	end
	
	if (combatEvent.damageIgnoreType == nil)
	then
		local v = combatEvent.value + (combatEvent.overheal or 0)
		
		local s

		if (combatEvent.crit)
		then
			s = ability_stats.crit
		else
			s = ability_stats.normal
		end
			
		s.count = s.count + 1
		s.total = s.total + combatEvent.value

		if (s.min == nil or v <= s.min)
		then
			s.min = v
			s.minObject = Enemy.CombatLog_GetPlayerInfoForCombatEvent (combatEvent)
		end

		if (s.max == nil or v >= s.max)
		then
			s.max = v
			s.maxObject = Enemy.CombatLog_GetPlayerInfoForCombatEvent (combatEvent)
		end
		
		if (combatEvent.overheal == nil)
		then
			if (combatEvent.mit ~= nil) then s.mit = s.mit + combatEvent.mit end
			if (combatEvent.abs ~= nil) then s.abs = s.abs + combatEvent.abs end
		else
			s.overheal = s.overheal + combatEvent.overheal
		end
		

		-- eps statistics
		if (g.settings.combatLogEPSEnabled[combatEvent.type])
		then
			local max_time = combatEvent.time - g.settings.combatLogEPSTimeframe
			
			
			-- remove all combat events that exceeds measuring timeframe interval
				
			local latest_event = eps.data[#eps.data]
			if (latest_event and latest_event.time < max_time)
			then
				ResetEps (eps)
			else
				while (#eps.data > 0)
				do
					local old_e = eps.data[1]
					
					if (old_e.time >= max_time) then break end

					local old_v = old_e.value + (old_e.overheal or 0)
				
					-- remove statistical data
					if (old_e.type == Enemy.CombatLogTypes.OutgoingDamage or old_e.type == Enemy.CombatLogTypes.OutgoingHeal)
					then
						if (old_e.currentTarget and old_e.object == eps.object and old_e.time >= eps.objectTime)
						then
							eps.total = eps.total - old_v
						end
						
						eps.totalAoe = eps.totalAoe - old_v
					else
						eps.total = eps.total - old_v
					end
				
					tremove (eps.data, 1)
				end
			end
				
				
			-- reset eps data if current target has been changed
			if (combatEvent.currentTarget and eps.object ~= combatEvent.object)
			then
				eps.object = combatEvent.object
				eps.objectTime = combatEvent.time
				eps.total = 0
				eps.value = nil
				eps.valueMax = nil
				eps.valueMaxData = nil
			end
			

			-- add statistical data
			tinsert (eps.data, combatEvent)
			
			if (combatEvent.type == Enemy.CombatLogTypes.OutgoingDamage or combatEvent.type == Enemy.CombatLogTypes.OutgoingHeal)
			then
				if (combatEvent.currentTarget) then eps.total = eps.total + v end
				eps.totalAoe = eps.totalAoe + v
			else
				eps.total = eps.total + v
			end
			
			
			if (#eps.data > 1)
			then
				local t1 = eps.data[1].time
				local t2 = eps.data[#eps.data].time
				local dt = t2 - t1
			
				if (dt > 0)
				then
					eps.value = mfloor (eps.total / dt + 0.5)
					eps.valueAoe = mfloor (eps.totalAoe / dt + 0.5)
					
					if (dt >= g.settings.combatLogEPSMaxValueMinTime)
					then
						if (eps.value > 0)
						then
							if (eps.valueMax == nil or eps.value >= eps.valueMax)
							then
								eps.valueMax = eps.value
								eps.valueMaxData = {}
								
								for _, data in ipairs (eps.data)
								do
									if (not data.currentTarget or data.object ~= eps.object or data.time < eps.objectTime)
									then
										continue
									end
									
									tinsert (eps.valueMaxData, data)
								end
							end
						end
								
						if (eps.valueAoe > 0)
						then
							if (eps.valueAoeMax == nil or eps.valueAoe >= eps.valueAoeMax)
							then
								eps.valueAoeMax = eps.valueAoe
								eps.valueAoeMaxData = Enemy.clone (eps.data)
							end
						end
					end
				end
			end
		end
	else
		ability_stats.normal.count = ability_stats.normal.count + 1
		
		local n = combatEvent.damageIgnoreType
		ability_stats[n] = ability_stats[n] + 1
	end
end

--------------------------------------------------------------- Parse function

function Enemy.CombatLog_ParseTime (str)

	if (not str) then return nil end

	local h, m, s = strmatch (str, L"^%[(%d%d):(%d%d):(%d%d)%]")
	return Enemy.today + tonumber (h) * 3600 + tonumber (m) * 60 + tonumber (s)
end


function Enemy.CombatLog_ParseIncommingDamage (str, time)

	local object, ability, crit, val, mit = strmatch (str, g.regexIncommingDamage)

	if (object)
	then
		return
		{
			time = time,
			type = Enemy.CombatLogTypes.IncommingDamage,
			str = str,
			
			object = object,
			ability = ability,
			crit = (crit == g.strCrit),
			value = tonumber (val or 0),
			mit = tonumber (strmatch (mit, g.regexMitigation) or 0),
			abs = tonumber (strmatch (mit, g.regexAbsorb) or 0)
		}
	else
		local action, object, ability = strmatch (str, g.regexIncommingDamageIgnored)
		local damage_ignore_type = g.damageIgnoreTypeByAction[action]
		
		if (damage_ignore_type)
		then
			return
			{
				time = time,
				type = Enemy.CombatLogTypes.IncommingDamage,
				str = str,
				
				object = object,
				ability = ability,
				
				damageIgnoreType = damage_ignore_type
			}
		end

		if (g.regexIncommingDamageFromSelf)
		then
			local ability, crit, object, val, mit = strmatch (str, g.regexIncommingDamageFromSelf)
			if (ability)
			then
				return
				{
					time = time,
					type = Enemy.CombatLogTypes.IncommingDamage,
					str = str,
					
					object = object,
					ability = ability,
					crit = (crit == g.strCrit),
					value = tonumber (val or 0),
					mit = tonumber (strmatch (mit, g.regexMitigation) or 0),
					abs = tonumber (strmatch (mit, g.regexAbsorb) or 0)
				}
			end
		end
	end
	
	return nil
end


function Enemy.CombatLog_ParseOutgoingDamage (str, time)

	local ability, crit, object, val, mit = strmatch (str, g.regexOutgoingDamage)

	if (object)
	then
		return
		{
			time = time,
			type = Enemy.CombatLogTypes.OutgoingDamage,
			str = str,
			
			object = object,
			ability = ability,
			crit = (crit == g.strCrit),
			value = tonumber (val or 0),
			mit = tonumber (strmatch (mit, g.regexMitigation) or 0),
			abs = tonumber (strmatch (mit, g.regexAbsorb) or 0)
		}
	else
		local object, action, ability = strmatch (str, g.regexOutgoingDamageIgnored)
		local damage_ignore_type = g.damageIgnoreTypeByAction[action]
		
		if (action)
		then		
			return
			{
				time = time,
				type = Enemy.CombatLogTypes.OutgoingDamage,
				str = str,
				
				object = object,
				ability = ability,
				
				damageIgnoreType = damage_ignore_type
			}
		end
	end
	
	return nil
end


function Enemy.CombatLog_ParseOutgoingPetDamage (str, time)

	local petname, ability, crit, object, val, mit = strmatch (str, g.regexOutgoingPetDamage)

	if (object)
	then
		return
		{
			time = time,
			type = Enemy.CombatLogTypes.OutgoingDamage,
			pet = true,
			str = str,
			
			object = object,
			ability = ability,
			crit = (crit == g.strCrit),
			value = tonumber (val or 0),
			mit = tonumber (strmatch (mit, g.regexMitigation) or 0),
			abs = tonumber (strmatch (mit, g.regexAbsorb) or 0)
		}
	else
		local object, action, petname, ability = strmatch (str, g.regexOutgoingPetDamageIgnored)
		local damage_ignore_type = g.damageIgnoreTypeByAction[action]
		
		if (action)
		then
			return
			{
				time = time,
				type = Enemy.CombatLogTypes.OutgoingDamage,
				pet = true,
				str = str,
				
				object = object,
				ability = ability,
				
				damageIgnoreType = damage_ignore_type
			}
		end
		
		-- Mythic in their infinite wisdom treats player healing his pet as pet hits :|
		return Enemy.CombatLog_ParseHeal (str, time)
	end
end



function Enemy.CombatLog_ParseHeal (str, time)

	local ability, crit, object, val, overheal = strmatch (str, g.regexIncommingHealYours)
	
	if (object)
	then
		return
		{
			time = time,
			type = Enemy.CombatLogTypes.OutgoingHeal,
			str = str,
			
			object = object,
			ability = ability,
			crit = (crit == g.strCrit),
			value = tonumber (val or 0),
			overheal = tonumber (strmatch (overheal, g.regexOverheal) or 0)
		}
	else
		object, ability, crit, val, overheal = strmatch (str, g.regexIncommingHeal)
		
		if (object)
		then
			return
			{
				time = time,
				type = Enemy.CombatLogTypes.IncommingHeal,
				str = str,
				
				object = object,
				ability = ability,
				crit = (crit == g.strCrit),
				value = tonumber (val or 0),
				overheal = tonumber (strmatch (overheal, g.regexOverheal) or 0)
			}
		else
			local ability, crit, object, val, overheal = strmatch (str, g.regexOutgoingHeal)
		
			if (object)
			then
				return
				{
					time = time,
					type = Enemy.CombatLogTypes.OutgoingHeal,
					str = str,
					
					object = object,
					ability = ability,
					crit = (crit == g.strCrit),
					value = tonumber (val or 0),
					overheal = tonumber (strmatch (overheal, g.regexOverheal) or 0)
				}
			end
		end
	end
	
	return nil
end


--------------------------------------------------------------- UI: Configuration
local config_dlg = {}

config_dlg.properties =
{
	combatLogEnabled =
	{
		key = "combatLogEnabled",
		order = 100,
		name = L"Enable combat log parsing",
		tooltip = L"Enable whole combat log parsing module",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEnabled
	},

	combatLogIgnoreNpc =
	{
		key = "combatLogIgnoreNpc",
		order = 110,
		name = L"Ignore NPC",
		tooltip = L"If checked then will ignore any combat events while you got NPC targeted. Note - this will eventually disable AoE parsing.",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogIgnoreNpc
	},

	combatLogIgnoreWhenPolymorphed =
	{
		key = "combatLogIgnoreWhenPolymorphed",
		order = 120,
		name = L"Ignore when polymorphed",
		tooltip = L"If checked then all combat events will be ignored while you polymorphed (champion/general/skaven forms)",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogIgnoreWhenPolymorphed
	},
	
	combatLogLogParseErrors =
	{
		key = "combatLogLogParseErrors",
		order = 200,
		name = L"Log parse errors to /debug log",
		tooltip = L"Enable this if you want to identify problems with combat log parsing. Type /debug and click on 'Logs' button to switch loggin on. Then close debug window. Only after that type /reloadui. After this all log messages will be stored in 'warhammer_directory/logs/uilog.log' file.",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogLogParseErrors
	},
	
	combatLogStatisticsEnabled =
	{
		key = "combatLogStatisticsEnabled",
		order = 300,
		name = L"Enable collecting statistics",
		tooltip = L"This will enable gathering statistical data about combat log event like max damage for abilities, crit %, mitigation %, ect.",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogStatisticsEnabled
	},

	combatLogStatsWindowToggleMacro =
	{
		key = "combatLogStatsWindowToggleMacro",
		order = 350,
		name = L"Toggle combat log statistics window",
		tooltip = L"Drag and drop this macro on your toolbar",
		macro = MACRO_TOGGLE,
		type = "macro"
	},


	combatLogEPSTitle =
	{
		key = "combatLogEPSTitle",
		order = 400,
		name = L"DPS/HPS statistics",
		type = "title",
		paddingTop = 40
	},
	
	combatLogEPSOutgoingDamageStatisticsEnabled =
	{
		key = "combatLogEPSOutgoingDamageStatisticsEnabled",
		order = 600,
		name = L"Enable outgoing damage statistics",
		tooltip = L"This will enable gathering statistical data about current outgoing damage (DPS)",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSEnabled[Enemy.CombatLogTypes.OutgoingDamage]
	},
	
	combatLogEPSIncommingDamageStatisticsEnabled =
	{
		key = "combatLogEPSIncommingDamageStatisticsEnabled",
		order = 700,
		name = L"Enable incomming damage statistics",
		tooltip = L"This will enable gathering statistical data about current incomming damage (DPS)",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSEnabled[Enemy.CombatLogTypes.IncommingDamage]
	},
			
	combatLogEPSOutgoingHealStatisticsEnabled =
	{
		key = "combatLogEPSOutgoingHealStatisticsEnabled",
		order = 800,
		name = L"Enable outgoing healing statistics",
		tooltip = L"This will enable gathering statistical data about current outgoing healing (HPS)",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSEnabled[Enemy.CombatLogTypes.OutgoingHeal]
	},
	
	combatLogEPSIncommingHealStatisticsEnabled =
	{
		key = "combatLogEPSIncommingHealStatisticsEnabled",
		order = 900,
		name = L"Enable incomming healing statistics",
		tooltip = L"This will enable gathering statistical data about current incomming healing (HPS)",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSEnabled[Enemy.CombatLogTypes.IncommingHeal]
	},
	
	combatLogEPSTimeframe =
	{
		key = "combatLogEPSTimeframe",
		order = 950,
		name = L"Current value timeframe",
		tooltip = L"Sets based on how many last seconds of combat log latest DPS/HPS statistics is stored",
		type = "float",
		min = 0.1,
		max = 60,
		default = Enemy.DefaultSettings.combatLogEPSTimeframe
	},
			
	combatLogEPSMaxValueMinTime =
	{
		key = "combatLogEPSMaxValueMinTime",
		order = 1000,
		name = L"Min time",
		tooltip = L"Sets the minimum amount of seconds that should be passed after the start of the first damage/heal event before starting Max DPS/HPS statistics calculation",
		type = "float",
		min = 0,
		max = 60,
		default = Enemy.DefaultSettings.combatLogEPSMaxValueMinTime
	},

	combatLogEPSOutgoingDamageStatisticsShow =
	{
		key = "combatLogEPSOutgoingDamageStatisticsShow",
		order = 1040,
		name = L"Show outgoing damage in DPS window",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSShow[Enemy.CombatLogTypes.OutgoingDamage]
	},
	
	combatLogEPSIncommingDamageStatisticsShow =
	{
		key = "combatLogEPSIncommingDamageStatisticsShow",
		order = 1050,
		name = L"Enable incomming damage in DPS window",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSShow[Enemy.CombatLogTypes.IncommingDamage]
	},
			
	combatLogEPSOutgoingHealStatisticsShow =
	{
		key = "combatLogEPSOutgoingHealStatisticsShow",
		order = 1060,
		name = L"Enable outgoing healing in DPS window",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSShow[Enemy.CombatLogTypes.OutgoingHeal]
	},
	
	combatLogEPSIncommingHealStatisticsShow =
	{
		key = "combatLogEPSIncommingHealStatisticsShow",
		order = 1070,
		name = L"Enable incomming healing in DPS window",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogEPSShow[Enemy.CombatLogTypes.IncommingHeal]
	},


	combatLogIDSTitle =
	{
		key = "combatLogIDSTitle",
		order = 1100,
		name = L"Incomming damage statistics",
		type = "title",
		paddingTop = 40
	},
	combatLogIDSEnabled =
	{
		key = "combatLogIDSEnabled",
		order = 110,
		name = L"Enable incomming damage statistics",
		tooltip = L"Enable this to see window with list of players that currently hitting you",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogIDSEnabled
	},
	combatLogIDSType =
	{
		key = "combatLogIDSType",
		order = 1200,
		name = L"Display",
		tooltip = L"Sort and display type",
		type = "select",
		values =
		{
			{ text = L"Damage", value = "damage" },
			{ text = L"DPS", value = "dps" }
		},
		default = Enemy.DefaultSettings.combatLogIDSType
	},
	combatLogIDSTimeframe =
	{
		key = "combatLogIDSTimeframe",
		order = 1300,
		name = L"Timeframe",
		tooltip = L"Sets based on how many last seconds of combat log the incomming damage statistics will be calculated",
		type = "float",
		min = 0.1,
		max = 60,
		default = Enemy.DefaultSettings.combatLogIDSTimeframe
	},
	combatLogIDSMaxRows =
	{
		key = "combatLogIDSMaxRows",
		order = 1400,
		name = L"Max rows",
		tooltip = L"How many rows to display",
		type = "number",
		min = 1,
		max = 10,
		default = Enemy.DefaultSettings.combatLogIDSMaxRows
	},
	combatLogIDSDisplayTime =
	{
		key = "combatLogIDSDisplayTime",
		order = 1500,
		name = L"Display time",
		tooltip = L"Amount of seconds to display rows after last stats update",
		type = "float",
		min = 0.1,
		max = 600,
		default = Enemy.DefaultSettings.combatLogIDSDisplayTime
	},
	combatLogIDSRowSize =
	{
		key = "combatLogIDSRowSize",
		order = 1600,
		name = L"Size (XY)",
		tooltip = L"Row size",
		type = "int[]",
		size = 2,
		min = { 1, 1 },
		max = { 500, 500 },
		default = Enemy.DefaultSettings.combatLogIDSRowSize
	},
	combatLogIDSRowPadding =
	{
		key = "combatLogIDSRowPadding",
		order = 1700,
		name = L"Row padding",
		tooltip = L"Space between rows",
		type = "number",
		min = 0,
		max = 100,
		default = Enemy.DefaultSettings.combatLogIDSRowPadding
	},
	combatLogIDSRowScale =
	{
		key = "combatLogIDSRowScale",
		order = 1800,
		name = L"Row scaling",
		type = "float",
		min = 0.1,
		max = 5,
		default = Enemy.DefaultSettings.combatLogIDSRowScale
	},
	combatLogIDSRowBackground =
	{
		key = "combatLogIDSRowBackground",
		order = 1900,
		name = L"Row background color",
		type = "color",
		default = Enemy.DefaultSettings.combatLogIDSRowBackground
	},
	combatLogIDSRowBackgroundAlpha =
	{
		key = "combatLogIDSRowBackgroundAlpha",
		order = 2000,
		name = L"Row background opacity",
		type = "float",
		min = 0,
		max = 1,
		default = Enemy.DefaultSettings.combatLogIDSRowBackgroundAlpha
	},
			
	
	combatLogTargetDefenseTitle =
	{
		key = "combatLogTargetDefenseTitle",
		order = 2100,
		name = L"Target defense",
		type = "title",
		paddingTop = 40
	},
	combatLogTargetDefenseEnabled =
	{
		key = "combatLogTargetDefenseEnabled",
		order = 2200,
		name = L"Enable target defense statistics",
		tooltip = L"Enable this to see current target defense statistics window",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseEnabled
	},
	combatLogTargetDefenseTimeframe =
	{
		key = "combatLogTargetDefenseTimeframe",
		order = 2300,
		name = L"Timeframe",
		tooltip = L"Sets based on how many last seconds of combat log the target defense statistics will be calculated",
		type = "float",
		min = 0.1,
		max = 60,
		default = Enemy.DefaultSettings.combatLogTargetDefenseTimeframe
	},
	combatLogTargetDefenseHideTimeout =
	{
		key = "combatLogTargetDefenseHideTimeout",
		order = 2350,
		name = L"Timeframe",
		tooltip = L"Sets amount of seconds since the last hit after which target defense windows will be hidden. Set to zero to disable auto hiding.",
		type = "float",
		min = 0,
		max = 60,
		default = Enemy.DefaultSettings.combatLogTargetDefenseHideTimeout
	},
	combatLogTargetDefenseShowMitigation =
	{
		key = "combatLogTargetDefenseShowMitigation",
		order = 2400,
		name = L"Show mitigation",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Mitigation]
	},
	combatLogTargetDefenseShowAbsorb =
	{
		key = "combatLogTargetDefenseShowAbsorb",
		order = 2500,
		name = L"Show absorb",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Absorb]
	},
	combatLogTargetDefenseShowBlock =
	{
		key = "combatLogTargetDefenseShowBlock",
		order = 2600,
		name = L"Show block",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Block]
	},
	combatLogTargetDefenseShowParry =
	{
		key = "combatLogTargetDefenseShowParry",
		order = 2700,
		name = L"Show parry",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Parry]
	},
	combatLogTargetDefenseShowDisrupt =
	{
		key = "combatLogTargetDefenseShowDisrupt",
		order = 2800,
		name = L"Show disrupt",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Disrupt]
	},
	combatLogTargetDefenseShowDodge =
	{
		key = "combatLogTargetDefenseShowDodge",
		order = 2900,
		name = L"Show dodge",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Dodge]
	},
	combatLogTargetDefenseSize =
	{
		key = "combatLogTargetDefenseSize",
		order = 3000,
		name = L"Size (XY)",
		tooltip = L"Indicator size",
		type = "int[]",
		size = 2,
		min = { 1, 1 },
		max = { 500, 500 },
		default = Enemy.DefaultSettings.combatLogTargetDefenseSize
	},
	combatLogTargetDefenseScale =
	{
		key = "combatLogTargetDefenseScale",
		order = 3100,
		name = L"Scaling",
		type = "float",
		min = 0.1,
		max = 5,
		default = Enemy.DefaultSettings.combatLogTargetDefenseScale
	},
	combatLogTargetDefenseBackground =
	{
		key = "combatLogTargetDefenseBackground",
		order = 3200,
		name = L"Background color",
		type = "color",
		default = Enemy.DefaultSettings.combatLogTargetDefenseBackground
	},
	combatLogTargetDefenseBackgroundAlpha =
	{
		key = "combatLogTargetDefenseBackgroundAlpha",
		order = 3300,
		name = L"Background opacity",
		type = "float",
		min = 0,
		max = 1,
		default = Enemy.DefaultSettings.combatLogTargetDefenseBackgroundAlpha
	},
	combatLogTargetDefenseTotalEnabled =
	{
		key = "combatLogTargetDefenseTotalEnabled",
		order = 3400,
		name = L"Enable total defense window",
		tooltip = L"Total defense window will show average defense % of the current target based on parameters included in calculation",
		type = "bool",
		paddingTop = 30,
		default = Enemy.DefaultSettings.combatLogTargetDefenseTotalEnabled
	},
	combatLogTargetDefenseTotalCalculateMitigation =
	{
		key = "combatLogTargetDefenseTotalCalculateMitigation",
		order = 3500,
		name = L"Total defense include mitigation",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Mitigation]
	},
	combatLogTargetDefenseTotalCalculateAbsorb =
	{
		key = "combatLogTargetDefenseTotalCalculateAbsorb",
		order = 3600,
		name = L"Total defense include absorb",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Absorb]
	},
	combatLogTargetDefenseTotalCalculateBlock =
	{
		key = "combatLogTargetDefenseTotalCalculateBlock",
		order = 3700,
		name = L"Total defense include block",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Block]
	},
	combatLogTargetDefenseTotalCalculateParry =
	{
		key = "combatLogTargetDefenseTotalCalculateParry",
		order = 3800,
		name = L"Total defense include parry",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Parry]
	},
	combatLogTargetDefenseTotalCalculateDisrupt =
	{
		key = "combatLogTargetDefenseTotalCalculateDisrupt",
		order = 3900,
		name = L"Total defense include disrupt",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Disrupt]
	},
	combatLogTargetDefenseTotalCalculateDodge =
	{
		key = "combatLogTargetDefenseTotalCalculateDodge",
		order = 4000,
		name = L"Total defense include dodge",
		type = "bool",
		default = Enemy.DefaultSettings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Dodge]
	},
	combatLogTargetDefenseTotalBackground =
	{
		key = "combatLogTargetDefenseTotalBackground",
		order = 4100,
		name = L"Background color",
		type = "color",
		default = Enemy.DefaultSettings.combatLogTargetDefenseTotalBackground
	},
	combatLogTargetDefenseTotalBackgroundAlpha =
	{
		key = "combatLogTargetDefenseTotalBackgroundAlpha",
		order = 4200,
		name = L"Background opacity",
		type = "float",
		min = 0,
		max = 1,
		default = Enemy.DefaultSettings.combatLogTargetDefenseTotalBackgroundAlpha
	}
}


function Enemy.CombatLogUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section
	
	local root = config_dlg.section.windowName.."ContentScrollChild"
	config_dlg.cwn = root.."Config"
	Enemy.CreateConfigurationWindow (config_dlg.cwn, root, config_dlg.properties, Enemy.CombatLogUI_ConfigDialog_TestSettings)
	
	ScrollWindowUpdateScrollRect (config_dlg.section.windowName.."Content")
end


function Enemy.CombatLogUI_ConfigDialog_OnLoad (section)

	config_dlg.isLoading = true
	
	config_dlg.combatLogEnabled = Enemy.Settings.combatLogEnabled
	config_dlg.combatLogIgnoreNpc = Enemy.Settings.combatLogIgnoreNpc
	config_dlg.combatLogIgnoreWhenPolymorphed = Enemy.Settings.combatLogIgnoreWhenPolymorphed

	config_dlg.combatLogLogParseErrors = Enemy.Settings.combatLogLogParseErrors
	config_dlg.combatLogStatisticsEnabled = Enemy.Settings.combatLogStatisticsEnabled
	
	config_dlg.combatLogEPSOutgoingDamageStatisticsEnabled = Enemy.Settings.combatLogEPSEnabled[Enemy.CombatLogTypes.OutgoingDamage]
	config_dlg.combatLogEPSOutgoingHealStatisticsEnabled = Enemy.Settings.combatLogEPSEnabled[Enemy.CombatLogTypes.OutgoingHeal]
	config_dlg.combatLogEPSIncommingDamageStatisticsEnabled = Enemy.Settings.combatLogEPSEnabled[Enemy.CombatLogTypes.IncommingDamage]
	config_dlg.combatLogEPSIncommingHealStatisticsEnabled = Enemy.Settings.combatLogEPSEnabled[Enemy.CombatLogTypes.IncommingHeal]
	config_dlg.combatLogEPSTimeframe = Enemy.Settings.combatLogEPSTimeframe
	config_dlg.combatLogEPSMaxValueMinTime = Enemy.Settings.combatLogEPSMaxValueMinTime
	config_dlg.combatLogEPSOutgoingDamageStatisticsShow = Enemy.Settings.combatLogEPSShow[Enemy.CombatLogTypes.OutgoingDamage]
	config_dlg.combatLogEPSOutgoingHealStatisticsShow = Enemy.Settings.combatLogEPSShow[Enemy.CombatLogTypes.OutgoingHeal]
	config_dlg.combatLogEPSIncommingDamageStatisticsShow = Enemy.Settings.combatLogEPSShow[Enemy.CombatLogTypes.IncommingDamage]
	config_dlg.combatLogEPSIncommingHealStatisticsShow = Enemy.Settings.combatLogEPSShow[Enemy.CombatLogTypes.IncommingHeal]

	config_dlg.combatLogIDSEnabled = Enemy.Settings.combatLogIDSEnabled
	config_dlg.combatLogIDSType = Enemy.Settings.combatLogIDSType
	config_dlg.combatLogIDSTimeframe = Enemy.Settings.combatLogIDSTimeframe
	config_dlg.combatLogIDSMaxRows = Enemy.Settings.combatLogIDSMaxRows
	config_dlg.combatLogIDSDisplayTime = Enemy.Settings.combatLogIDSDisplayTime
	config_dlg.combatLogIDSRowSize = Enemy.clone (Enemy.Settings.combatLogIDSRowSize)
	config_dlg.combatLogIDSRowPadding = Enemy.Settings.combatLogIDSRowPadding
	config_dlg.combatLogIDSRowScale = Enemy.Settings.combatLogIDSRowScale
	config_dlg.combatLogIDSRowBackground = Enemy.clone (Enemy.Settings.combatLogIDSRowBackground)
	config_dlg.combatLogIDSRowBackgroundAlpha = Enemy.Settings.combatLogIDSRowBackgroundAlpha
		
	config_dlg.combatLogTargetDefenseEnabled = Enemy.Settings.combatLogTargetDefenseEnabled
	config_dlg.combatLogTargetDefenseTimeframe = Enemy.Settings.combatLogTargetDefenseTimeframe
	config_dlg.combatLogTargetDefenseHideTimeout = Enemy.Settings.combatLogTargetDefenseHideTimeout
	config_dlg.combatLogTargetDefenseShowMitigation = Enemy.Settings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Mitigation]
	config_dlg.combatLogTargetDefenseShowAbsorb = Enemy.Settings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Absorb]
	config_dlg.combatLogTargetDefenseShowBlock = Enemy.Settings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Block]
	config_dlg.combatLogTargetDefenseShowParry = Enemy.Settings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Parry]
	config_dlg.combatLogTargetDefenseShowDisrupt = Enemy.Settings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Disrupt]
	config_dlg.combatLogTargetDefenseShowDodge = Enemy.Settings.combatLogTargetDefenseShow[Enemy.CombatLogTargetDefenseTypes.Dodge]
	config_dlg.combatLogTargetDefenseSize = Enemy.clone (Enemy.Settings.combatLogTargetDefenseSize)
	config_dlg.combatLogTargetDefenseScale = Enemy.Settings.combatLogTargetDefenseScale
	config_dlg.combatLogTargetDefenseBackground = Enemy.clone (Enemy.Settings.combatLogTargetDefenseBackground)
	config_dlg.combatLogTargetDefenseBackgroundAlpha = Enemy.Settings.combatLogTargetDefenseBackgroundAlpha

	config_dlg.combatLogTargetDefenseTotalEnabled = Enemy.Settings.combatLogTargetDefenseTotalEnabled
	config_dlg.combatLogTargetDefenseTotalCalculateMitigation = Enemy.Settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Mitigation]
	config_dlg.combatLogTargetDefenseTotalCalculateAbsorb = Enemy.Settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Absorb]
	config_dlg.combatLogTargetDefenseTotalCalculateBlock = Enemy.Settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Block]
	config_dlg.combatLogTargetDefenseTotalCalculateParry = Enemy.Settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Parry]
	config_dlg.combatLogTargetDefenseTotalCalculateDisrupt = Enemy.Settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Disrupt]
	config_dlg.combatLogTargetDefenseTotalCalculateDodge = Enemy.Settings.combatLogTargetDefenseTotalCalculate[Enemy.CombatLogTargetDefenseTypes.Dodge]
	config_dlg.combatLogTargetDefenseTotalBackground = Enemy.clone (Enemy.Settings.combatLogTargetDefenseTotalBackground)
	config_dlg.combatLogTargetDefenseTotalBackgroundAlpha = Enemy.Settings.combatLogTargetDefenseTotalBackgroundAlpha

	Enemy.ConfigurationWindowLoadData (config_dlg.cwn, config_dlg)
	config_dlg.isLoading = false
	Enemy.CombatLogUI_ConfigDialog_TestSettings ()
end


function Enemy.CombatLogResetSettings ()

	for k, v in pairs (Enemy.Settings)
	do
		if (not k:match("^[cC]ombatLog.*")) then continue end
		Enemy.Settings[k] = nil
	end

	Enemy.Print ("Combat log settings has been reset")
	InterfaceCore.ReloadUI ()
end


function Enemy.CombatLogUI_ConfigDialog_OnReset (section)

	for k, v in pairs (Enemy.Settings)
	do
		if (not k:match("^[cC]ombatLog.*")) then continue end
		Enemy.Settings[k] = nil
	end
	
	Enemy.Print ("Combat log settings has been reset")
	InterfaceCore.ReloadUI ()
end
		
		
function SaveSettings (data, settings)

	settings.combatLogEnabled = data.combatLogEnabled
	settings.combatLogIgnoreNpc = data.combatLogIgnoreNpc
	settings.combatLogIgnoreWhenPolymorphed = data.combatLogIgnoreWhenPolymorphed

	settings.combatLogLogParseErrors = data.combatLogLogParseErrors
	settings.combatLogStatisticsEnabled = data.combatLogStatisticsEnabled
	
	settings.combatLogEPSEnabled =
	{
		[Enemy.CombatLogTypes.OutgoingDamage] = data.combatLogEPSOutgoingDamageStatisticsEnabled,
		[Enemy.CombatLogTypes.OutgoingHeal] = data.combatLogEPSOutgoingHealStatisticsEnabled,
		[Enemy.CombatLogTypes.IncommingDamage] = data.combatLogEPSIncommingDamageStatisticsEnabled,
		[Enemy.CombatLogTypes.IncommingHeal] = data.combatLogEPSIncommingHealStatisticsEnabled
	}
	settings.combatLogEPSTimeframe = data.combatLogEPSTimeframe
	settings.combatLogEPSMaxValueMinTime = data.combatLogEPSMaxValueMinTime
	settings.combatLogEPSShow =
	{
		[Enemy.CombatLogTypes.OutgoingDamage] = data.combatLogEPSOutgoingDamageStatisticsShow,
		[Enemy.CombatLogTypes.OutgoingHeal] = data.combatLogEPSOutgoingHealStatisticsShow,
		[Enemy.CombatLogTypes.IncommingDamage] = data.combatLogEPSIncommingDamageStatisticsShow,
		[Enemy.CombatLogTypes.IncommingHeal] = data.combatLogEPSIncommingHealStatisticsShow
	}

	settings.combatLogIDSEnabled = data.combatLogIDSEnabled
	settings.combatLogIDSType = data.combatLogIDSType
	settings.combatLogIDSTimeframe = data.combatLogIDSTimeframe
	settings.combatLogIDSMaxRows = data.combatLogIDSMaxRows
	settings.combatLogIDSDisplayTime = data.combatLogIDSDisplayTime
	settings.combatLogIDSRowSize = Enemy.clone (data.combatLogIDSRowSize)
	settings.combatLogIDSRowPadding = data.combatLogIDSRowPadding
	settings.combatLogIDSRowScale = data.combatLogIDSRowScale
	settings.combatLogIDSRowBackground = Enemy.clone (data.combatLogIDSRowBackground)
	settings.combatLogIDSRowBackgroundAlpha = data.combatLogIDSRowBackgroundAlpha
		
	settings.combatLogTargetDefenseEnabled = data.combatLogTargetDefenseEnabled
	settings.combatLogTargetDefenseTimeframe = data.combatLogTargetDefenseTimeframe
	settings.combatLogTargetDefenseHideTimeout = data.combatLogTargetDefenseHideTimeout
	settings.combatLogTargetDefenseShow =
	{
		[Enemy.CombatLogTargetDefenseTypes.Mitigation] = data.combatLogTargetDefenseShowMitigation,
		[Enemy.CombatLogTargetDefenseTypes.Absorb] = data.combatLogTargetDefenseShowAbsorb,
		[Enemy.CombatLogTargetDefenseTypes.Block] = data.combatLogTargetDefenseShowBlock,
		[Enemy.CombatLogTargetDefenseTypes.Parry] = data.combatLogTargetDefenseShowParry,
		[Enemy.CombatLogTargetDefenseTypes.Disrupt] = data.combatLogTargetDefenseShowDisrupt,
		[Enemy.CombatLogTargetDefenseTypes.Dodge] = data.combatLogTargetDefenseShowDodge
	}
	settings.combatLogTargetDefenseSize = Enemy.clone (data.combatLogTargetDefenseSize)
	settings.combatLogTargetDefenseScale = data.combatLogTargetDefenseScale
	settings.combatLogTargetDefenseBackground = Enemy.clone (data.combatLogTargetDefenseBackground)
	settings.combatLogTargetDefenseBackgroundAlpha = data.combatLogTargetDefenseBackgroundAlpha

	settings.combatLogTargetDefenseTotalEnabled = data.combatLogTargetDefenseTotalEnabled
	settings.combatLogTargetDefenseTotalCalculate =
	{
		[Enemy.CombatLogTargetDefenseTypes.Mitigation] = data.combatLogTargetDefenseTotalCalculateMitigation,
		[Enemy.CombatLogTargetDefenseTypes.Absorb] = data.combatLogTargetDefenseTotalCalculateAbsorb,
		[Enemy.CombatLogTargetDefenseTypes.Block] = data.combatLogTargetDefenseTotalCalculateBlock,
		[Enemy.CombatLogTargetDefenseTypes.Parry] = data.combatLogTargetDefenseTotalCalculateParry,
		[Enemy.CombatLogTargetDefenseTypes.Disrupt] = data.combatLogTargetDefenseTotalCalculateDisrupt,
		[Enemy.CombatLogTargetDefenseTypes.Dodge] = data.combatLogTargetDefenseTotalCalculateDodge
	}
	settings.combatLogTargetDefenseTotalBackground = Enemy.clone (data.combatLogTargetDefenseTotalBackground)
	settings.combatLogTargetDefenseTotalBackgroundAlpha = data.combatLogTargetDefenseTotalBackgroundAlpha
end


function Enemy.CombatLogUI_ConfigDialog_TestSettings ()

	if (config_dlg.isLoading) then return end
	
	local data = {}
	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, data)
		
	local settings = {}
	SaveSettings (data, settings)
		
	Enemy.CombatLog_OnSettingsChanged (settings)
end


function Enemy.CombatLogUI_ConfigDialog_OnSave (section)

	local data = {}
	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, data)
	SaveSettings (data, Enemy.Settings)
	
	return true
end




