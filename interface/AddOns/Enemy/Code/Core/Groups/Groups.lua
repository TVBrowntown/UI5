local Enemy = Enemy
local g = {}
local ipairs = ipairs
local pairs = pairs
local tinsert = table.insert
local tremove = table.remove
local mfloor = math.floor

local MAX_MAP_POINTS = 511
local DISTANCE_FIX_COEFFICIENT = 1 / 1.06

local MapPointTypeFilter =
{
	--[SystemData.MapPips.PLAYER] = true,
	[SystemData.MapPips.GROUP_MEMBER] = true,
	[SystemData.MapPips.WARBAND_MEMBER] = true,
	[SystemData.MapPips.DESTRUCTION_ARMY] = true,
	[SystemData.MapPips.ORDER_ARMY] = true
}

--------------------------------------------------------------- Main
function Enemy.GroupsInitialize ()

	Enemy.groups = g
	g.initialized = false
	
	-- constants
	Enemy.GroupTypes =
	{
		Solo = 0,
		Group = 1,
		Warband = 2,
		Scenario = 3
	}
	
	Enemy.Archetypes = 
	{
		Tank = 1,
		Dps = 2,
		Healer = 3
	}
	
	Enemy.careerArchetypes =
	{
		[GameData.CareerLine.IRON_BREAKER] = Enemy.Archetypes.Tank,
		[GameData.CareerLine.SWORDMASTER] = Enemy.Archetypes.Tank,
		[GameData.CareerLine.CHOSEN] = Enemy.Archetypes.Tank,
		[GameData.CareerLine.BLACK_ORC] = Enemy.Archetypes.Tank,
		[GameData.CareerLine.KNIGHT] = Enemy.Archetypes.Tank,
		[GameData.CareerLine.BLACKGUARD] = Enemy.Archetypes.Tank,
		
		[GameData.CareerLine.WITCH_HUNTER] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.WHITE_LION] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.MARAUDER] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.WITCH_ELF] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.BRIGHT_WIZARD] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.MAGUS] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.SORCERER] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.ENGINEER] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.SHADOW_WARRIOR] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.SQUIG_HERDER] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.CHOPPA] = Enemy.Archetypes.Dps,
		[GameData.CareerLine.SLAYER or GameData.CareerLine.HAMMERER] = Enemy.Archetypes.Dps,
		
		[GameData.CareerLine.WARRIOR_PRIEST] = Enemy.Archetypes.Healer,
		[GameData.CareerLine.DISCIPLE] = Enemy.Archetypes.Healer,
		[GameData.CareerLine.ARCHMAGE] = Enemy.Archetypes.Healer,
		[GameData.CareerLine.SHAMAN] = Enemy.Archetypes.Healer,
		[GameData.CareerLine.RUNE_PRIEST] = Enemy.Archetypes.Healer,
		[GameData.CareerLine.ZEALOT] = Enemy.Archetypes.Healer
	}
	
	local los_check_bility_ids =
	{
		[GameData.CareerLine.SHAMAN] = 1898, -- Gork'll Fix It
	    [GameData.CareerLine.RUNE_PRIEST] =  1587, -- Grungni's Gift
	    [GameData.CareerLine.DISCIPLE] =  9548, -- Restore Essence
	    [GameData.CareerLine.ARCHMAGE] =  9236, -- Healing Energy
	    [GameData.CareerLine.WARRIOR_PRIEST] =  8238, -- Divine Aid
	    [GameData.CareerLine.ZEALOT] =  8569, -- Flash Of Chaos
	    [GameData.CareerLine.IRON_BREAKER] =  1353, -- Oath Friend
	    [GameData.CareerLine.CHOSEN] =  8325, -- Guard (Chosen)
	    [GameData.CareerLine.SWORDMASTER] =  9008, -- Guard (Swordmaster)
	    [GameData.CareerLine.BLACK_ORC] =  1674, -- Save Da Runts
	    [GameData.CareerLine.KNIGHT] =  8013, -- Guard (Knight of the Blazing Sun)
	    [GameData.CareerLine.BLACKGUARD] =  9325, -- Guard (Black Guard)
	}
	g.losCheckAbilityId = los_check_bility_ids[GameData.Player.career.line]
	
	Enemy._GroupsInitializeCustomEffectFilters ()
	Enemy._GroupsReset ()
	
	-- UI: effect filter dialog
	CreateWindow ("EnemyEffectFilterDialog", false)
	
	-- events
	RegisterEventHandler (SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
	RegisterEventHandler (SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
	RegisterEventHandler (SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
	RegisterEventHandler (SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
	RegisterEventHandler (SystemData.Events.PLAYER_CAREER_RANK_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
	RegisterEventHandler (SystemData.Events.PLAYER_MORALE_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
	
	RegisterEventHandler (SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "Enemy.Groups_OnCurrentPlayerCombatFlagUpdated")
	RegisterEventHandler (SystemData.Events.PLAYER_RVR_FLAG_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
	
	RegisterEventHandler (SystemData.Events.PLAYER_TARGET_UPDATED, "Enemy.Groups_OnPlayerTargetUpdated")
	RegisterEventHandler (SystemData.Events.SHOW_ALERT_TEXT, "Enemy.Groups_OnShowAlertText")
	
	RegisterEventHandler (SystemData.Events.PLAYER_PET_HEALTH_UPDATED, "Enemy.Groups_OnPlayerPetHealthUpdated")
--	RegisterEventHandler (SystemData.Events.PLAYER_PET_UPDATED, "Enemy.Groups_OnPlayerPetUpdated")
	
	RegisterEventHandler (SystemData.Events.SCENARIO_BEGIN, "Enemy.GroupsUpdateType")
	RegisterEventHandler (SystemData.Events.SCENARIO_END, "Enemy.GroupsUpdateType")
	RegisterEventHandler (SystemData.Events.SCENARIO_GROUP_JOIN, "Enemy.GroupsUpdateType")
	RegisterEventHandler (SystemData.Events.SCENARIO_GROUP_LEAVE, "Enemy.GroupsUpdateType")
	
	RegisterEventHandler(SystemData.Events.CITY_SCENARIO_BEGIN, "Enemy.GroupsUpdateType")
	RegisterEventHandler(SystemData.Events.CITY_SCENARIO_END, "Enemy.GroupsUpdateType")
	
	RegisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_GROUPS_UPDATED, "Enemy.GroupsUpdate")
	RegisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_RESERVATIONS_UPDATED, "Enemy.GroupsUpdate")
	
	RegisterEventHandler (SystemData.Events.SCENARIO_PLAYER_HITS_UPDATED, "Enemy.Groups_OnScenarioPlayerHitsUpdated")
	
	RegisterEventHandler (SystemData.Events.GROUP_UPDATED, "Enemy.GroupsUpdateType")
	RegisterEventHandler (SystemData.Events.GROUP_PLAYER_ADDED, "Enemy.GroupsUpdate")
	RegisterEventHandler (SystemData.Events.GROUP_STATUS_UPDATED, "Enemy.Groups_OnGroupStatusUpdated")
	
	RegisterEventHandler (SystemData.Events.BATTLEGROUP_UPDATED, "Enemy.GroupsUpdateType")
	RegisterEventHandler (SystemData.Events.BATTLEGROUP_MEMBER_UPDATED, "Enemy.Groups_OnBattlegroupMemberUpdated")
	
	RegisterEventHandler (SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "Enemy.Groups_OnPlayerTargetEffectsUpdated")
	RegisterEventHandler (SystemData.Events.PLAYER_EFFECTS_UPDATED, "Enemy.Groups_OnCurrentPlayerEffectsUpdated")
	RegisterEventHandler (SystemData.Events.GROUP_EFFECTS_UPDATED, "Enemy.Groups_OnGroupEffectUpdated")
	
	RegisterEventHandler (SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.GroupsCheckTarget")
	
	if (g.losCheckAbilityId)
	then
		Enemy.AddTaskAction ("groups los check", function ()
		
			if (g.target and not g.target.isSelf)
			then
				g.target:SetLOS (not IsTargetValid (g.losCheckAbilityId))
			end
			
			return false
		end)
	end
	
	Enemy.GroupsUpdateType ()
	Enemy.TriggerEvent ("GroupsInitialized")
	
	EnemyTimer.New ("groups distance check", 1, function ()
	
		for k = 1, MAX_MAP_POINTS
		do
			local mpd = GetMapPointData ("EA_Window_OverheadMapMapDisplay", k)
			if (not mpd or not MapPointTypeFilter[mpd.pointType] or not mpd.name) then continue end
			
			local name = Enemy.FixString (mpd.name)

			local player = g.players[name]
			local distance = mfloor (mpd.distance * DISTANCE_FIX_COEFFICIENT)
			
			if (not player) then continue end

			player:SetDistance (distance)
		end
		
		return false
	end)
end


function Enemy._GroupsReset ()
	
	g.groups = {}
	g.groupsPlayersCount = {}
	g.ungroupedPlayers = {}
	
	for group_index = 1, Enemy.MaxGroups
	do
		tinsert (g.groups, {})
		g.groupsPlayersCount[group_index] = 0
	end
	
	g.players = {}
	g.target = nil
end


function Enemy.GroupsUpdateType ()

	-- determine group type
	local new_group_type = Enemy.GroupTypes.Solo
	
	if (GetNumGroupmates () > 0)
	then
		new_group_type = Enemy.GroupTypes.Group
	end
	
	if (IsWarBandActive ())
	then
		new_group_type = Enemy.GroupTypes.Warband
	end
	
	if (GameData.Player.isInScenario and GameData.Player.isInSiege)
	then
		new_group_type = Enemy.GroupTypes.Warband
	end
	
	if (GameData.Player.isInScenario or GameData.Player.isInSiege)
	then
		new_group_type = Enemy.GroupTypes.Scenario
	end
	
	if (new_group_type ~= g.groupType)
	then
		Enemy._GroupsReset ()
		Enemy.TriggerEvent ("GroupsTypeUpdated", new_group_type, g.groupType)
	end
	
	g.groupType = new_group_type
	
	Enemy.GroupsCheckTarget ()	
	Enemy.GroupsUpdate ()
end


function Enemy.GroupsGetMaxGroups ()

	if (g.groupType == Enemy.GroupTypes.Warband or g.groupType == Enemy.GroupTypes.Scenario)
	then
		return Enemy.MaxGroups
	end
	
	return 1
end


function Enemy.IsPlayerInGroup ()
	return
		(
			g.groupType == Enemy.GroupTypes.Group
			or
			g.groupType == Enemy.GroupTypes.Warband
			or
			(
				g.groupType == Enemy.GroupTypes.Scenario
				and
				g.player.group
			)
		)
end


function Enemy.GroupsUpdate ()

	-- shedule groups update
	if (Enemy.GetTask ("groups sheduled update")) then return end
	
	Enemy.AddTaskAction ("groups sheduled update", function ()
		Enemy._GroupsUpdate ()
		return true
	end)
end


function Enemy._GroupsForceGroupsUpdateIfNeeded ()

	if (Enemy.GetTask ("groups sheduled update") and not g.updateInProgress)
	then
		Enemy.RemoveTask ("groups sheduled update")
		Enemy._GroupsUpdate ()
	end
end


function Enemy._GroupsUpdate ()

	if (g.updateInProgress) then return end
	g.updateInProgress = true

	local old_player = g.player
	local old_players = g.players or {}
	local need_load_self = false
	
	local old_target_name = nil
	if (g.target)
	then
		old_target_name = g.target.name
	end
	
	local player_group_index = nil
	if (old_player) then player_group_index = old_player.groupIndex end
	
	if (g.groupType == Enemy.GroupTypes.Scenario)
	then
		-- in scenario
	
		local data = GameData.GetScenarioPlayerGroups ()
		if (not data)
		then
			g.updateInProgress = false
			return
		end

		Enemy._GroupsReset ()
	
		for _, player_data in ipairs (data)
		do
			local name = Enemy.FixString (player_data.name)
			local player = old_players[name]
			if (not player) then player = EnemyPlayer.New (name) end
			
			player:LoadFromScenarioData (player_data)
			
			if (not player:IsValid ()) then continue end
		
			g.players[player.name] = player
			
			if (player_data.sgroupindex > 0)
			then
				local group = g.groups[player_data.sgroupindex]
				
				player.group = group
				player.index = player_data.sgroupslotnum
				player.groupIndex = player_data.sgroupindex
				
				group[player.index] = player
			else
				player.index = nil
				player.group = nil
				player.groupIndex = nil
				
				tinsert (g.ungroupedPlayers, player)
			end
		end
		
		need_load_self = true
		
	elseif (g.groupType == Enemy.GroupTypes.Warband)
	then
		-- warband
		local data = PartyUtils.GetWarbandData ()
		if (not data)
		then
			g.updateInProgress = false
			return
		end
		
		Enemy._GroupsReset ()
		
		for group_index, group_data in ipairs (data)
		do
			local group = g.groups[group_index]
		
			for player_index, player_data in ipairs (group_data.players)
			do
				local name = Enemy.FixString (player_data.name)
				local player = old_players[name]
				if (not player) then player = EnemyPlayer.New (name) end
				
				player:LoadFromWarbandData (player_data)
				
				if (not player:IsValid ()) then continue end
				
				player.group = group
				player.index = player_index
				player.groupIndex = group_index
				
				g.players[player.name] = player
				group[player.index] = player
			end
		end
		
		need_load_self = true
		
	else
		-- group or solo
		
		local data = PartyUtils.GetPartyData ()
		if (not data)
		then
			g.updateInProgress = false
			return
		end
		
		Enemy._GroupsReset ()
		
		local player = old_player
		if (not player) then player = EnemyPlayer.New (Enemy.playerName) end
		
		player:LoadFromCurrentPlayer ()
		
		local group = g.groups[1]
		player.group = group
		player.index = 1
		player.groupIndex = 1
		
		g.players[player.name] = player
		group[1] = player
		
		for player_index, player_data in ipairs (data)
		do
			if player_data.name and player_data.name ~= L"" then
				local name = Enemy.FixString (player_data.name)
				player = old_players[name]
				if (not player) then player = EnemyPlayer.New (name) end
				
				player:LoadFromGroupData (player_data)
				
				if (not player:IsValid ()) then continue end
				
				player.group = group
				player.index = player_index + 1
				player.groupIndex = 1
					
				g.players[player.name] = player
				group[player.index] = player
			end
		end
		
		need_load_self = false
	end
	
	g.player = g.players[Enemy.playerName]
	
	if (g.player)
	then
		if (need_load_self)
		then
			g.player:LoadFromCurrentPlayer ()
		end
		
		for _, player in pairs (g.players)
		do
			player.isSelf = (player == g.player)
			player.isInPlayerGroup = (player.groupIndex ~= nil and player.groupIndex == g.player.groupIndex)
			
			if (player:IsInGroup())
			then
				g.groupsPlayersCount[player.groupIndex] = g.groupsPlayersCount[player.groupIndex] + 1
			end
		end
		
		if (not g.initialized)
		then
			g.initialized = true
			
			-- update can cleanse
			if (g.player.career == GameData.CareerLine.BRIGHT_WIZARD)
			then
				g.canCleanse = "self"
				g.canCleanseHex = true
				g.canCleanseAilment = true
				g.canCleanseCurse = true
				
			elseif (g.player.career == GameData.CareerLine.WARRIOR_PRIEST or g.player.career == GameData.CareerLine.ZEALOT)
			then
				g.canCleanse = "all"
				g.canCleanseHex = true
				g.canCleanseAilment = false
				g.canCleanseCurse = true
				
			elseif (g.player.career == GameData.CareerLine.DISCIPLE or g.player.career == GameData.CareerLine.ARCHMAGE)
			then
				g.canCleanse = "all"
				g.canCleanseHex = true
				g.canCleanseAilment = true
				g.canCleanseCurse = false
				
			elseif (g.player.career == GameData.CareerLine.SHAMAN or g.player.career == GameData.CareerLine.RUNE_PRIEST)
			then
				g.canCleanse = "all"
				g.canCleanseHex = false
				g.canCleanseAilment = true
				g.canCleanseCurse = true
			
			else
			
				g.canCleanse = nil
				g.canCleanseHex = false
				g.canCleanseAilment = false
				g.canCleanseCurse = false
			end
			
			Enemy.TriggerEvent ("GroupsPlayerInitialized", g.player)
			Enemy.UpdateEffects ()
		end
		
		g.target = g.players[old_target_name]
		
		Enemy.TriggerEvent ("GroupsUpdated", player_group_index ~= g.player.groupIndex)
	end
	
	g.updateInProgress = false
end


function Enemy.UpdateEffects ()

	if (not g.player) then return end

	Enemy.Groups_OnCurrentPlayerEffectsUpdated (GetBuffs (GameData.BuffTargetType.SELF), true)

	if (g.player.group)
	then
		for k = 1, 6
		do
			local player = g.player.group[k]
			if (not player or player.isSelf) then continue end
			
			local update_type = GameData.BuffTargetType.GROUP_MEMBER_START + (player.index - 1)
			Enemy.Groups_OnGroupEffectUpdated (update_type, GetBuffs (update_type), true)
		end
	end
end


function Enemy.Groups_OnBattlegroupMemberUpdated (groupIndex, memberIndex)

	Enemy._GroupsForceGroupsUpdateIfNeeded ()

	local player_data = PartyUtils.GetWarbandMember (groupIndex, memberIndex)
	if (player_data == nil or not player_data.name or player_data.name == L"") then return end
	
	local player = g.players[Enemy.FixString (player_data.name)]
	if (not player) then return end
	
	player:LoadFromGroupData (player_data)
	
	Enemy.TriggerEvent ("GroupsPlayerUpdated", player)
end


function Enemy.Groups_OnScenarioPlayerHitsUpdated (groupIndex, groupSlotNum, hits)

	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	if (g.groupType ~= Enemy.GroupTypes.Scenario or not g.groups) then return end
	
	--d ("OnScenarioPlayerHitsUpdated ("..tostring (groupIndex or "nil")..", "..tostring (groupSlotNum or "nil")..", "..tostring (hits or "nil")..")")

	local group = g.groups[groupIndex]
	if (not group) then return end
	
	local player = group[groupSlotNum]
	if (not player) then return end
	
	player.hp = hits
	
	Enemy.TriggerEvent ("GroupsPlayerUpdated", player)
end


function Enemy.Groups_OnGroupStatusUpdated (memberIndex)

	Enemy._GroupsForceGroupsUpdateIfNeeded ()

	local player_data = PartyUtils.GetPartyMember (memberIndex)
	if (not player_data or not player_data.name and player_data.name ~= L"") then return end
	
	local player = g.players[Enemy.FixString (player_data.name)]
	if (not player) then return end
	
	player:LoadFromGroupData (player_data)
	
	Enemy.TriggerEvent ("GroupsPlayerUpdated", player)
end


function Enemy.Groups_OnCurrentPlayerUpdated ()

	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	if (not g.player) then return end
	
	g.player:LoadFromCurrentPlayer ()
	Enemy.TriggerEvent ("GroupsPlayerUpdated", g.player)
end


function Enemy.Groups_OnPlayerPetHealthUpdated ()

	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	if (not g.player) then return end
	
	g.player:LoadPetFromCurrentPlayer()
	Enemy.TriggerEvent ("GroupsPlayerPetUpdated", g.player)
end


function Enemy.Groups_OnCurrentPlayerCombatFlagUpdated ()

	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	if (not g.player) then return end
	
	g.player.isInCombat = GameData.Player.inCombat
	Enemy.TriggerEvent ("GroupsPlayerCombatUpdated", g.player)
end


function Enemy.GroupsCheckTarget ()
	
	TargetInfo:UpdateFromClient ()
	
	if (not TargetInfo:UnitName (TargetInfo.FRIENDLY_TARGET))
	then
		Enemy._GroupsClearTarget ()
	end
end


function Enemy._GroupsClearTarget ()
	if (not g.target) then return end
	
	g.target:SetSelected (false)
	Enemy.TriggerEvent ("GroupsTargetChanged", g.target, nil)
	g.target = nil
end


function Enemy.Groups_OnPlayerTargetUpdated (targetClassification, targetId, targetType)

	if (targetClassification == TargetInfo.HOSTILE_TARGET) then return end
	
	local is_friendly_target = (targetClassification == TargetInfo.FRIENDLY_TARGET)

	if (targetId == 0)
	then
		if (is_friendly_target) then Enemy._GroupsClearTarget () end
		return
	end
	
	TargetInfo:UpdateFromClient ()
	
	if (TargetInfo:UnitHealth (targetClassification) == 0 and targetClassification == "mouseovertarget")
	then
		return
	end

	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	if (not g.player)
	then
		if (is_friendly_target) then Enemy._GroupsClearTarget () end
		return
	end
	
	local name = Enemy.FixString (TargetInfo:UnitName (targetClassification))
	local player = g.players[name]
	
	if (not player)
	then
		if (is_friendly_target) then Enemy._GroupsClearTarget () end
		return
	end
	
	player:LoadFromTarget (targetClassification, targetId)
	
	if (is_friendly_target)
	then
		player:SetSelected (true)
	
		if (g.losCheckAbilityId)
		then
			player:SetLOS (not IsTargetValid (g.losCheckAbilityId), true)
		end
	end
	
	Enemy.TriggerEvent ("GroupsPlayerUpdated", player)
	
	if (is_friendly_target)
	then
		local old_target = g.target
		if (old_target ~= player)
		then
			if (old_target)
			then
				old_target:SetSelected (false)
			end
		
			g.target = player
			
			Enemy.TriggerEvent ("GroupsTargetChanged", old_target, g.target)
		end
	end
end


function Enemy.Groups_OnShowAlertText ()

	for _, v in ipairs (SystemData.AlertText.VecText)
	do
        local name = v:match (GetStringFormat (StringTables.Default.TEXT_TARGET_PLAYER_ERROR, {L"(%S+)"}))
        if (not name) then continue end
        
        local player = g.players[Enemy.FixString (name)]
        if (not player) then continue end
        
        player:SetDistant (true)
    end
end


function Enemy.Groups_OnCurrentPlayerEffectsUpdated (updatedEffects, isFullList)

--	d ("OnCurrentPlayerEffectsUpdated ("..tostring (updatedEffects or "nil")..", "..tostring (isFullList or "nil")..")")

	if (not updatedEffects) then return end
	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	if (not g.player) then return end
	
	g.player:LoadEffects (updatedEffects, isFullList)
	Enemy.TriggerEvent ("GroupsPlayerEffectsUpdated", g.player)
end


function Enemy.Groups_OnPlayerTargetEffectsUpdated (updateType, updatedEffects, isFullList)

--	d ("OnPlayerTargetEffectsUpdated ("..tostring (updateType or "nil")..", "..tostring (updatedEffects or "nil")..", "..tostring (isFullList or "nil")..")")

	if (not updatedEffects or updateType ~= GameData.BuffTargetType.TARGET_FRIENDLY) then return end
	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	
	local name = Enemy.FixString (TargetInfo:UnitName (TargetInfo.FRIENDLY_TARGET))
	local player = g.players[name]
	if (not player) then return end
	
	player:LoadEffects (updatedEffects, isFullList)
	Enemy.TriggerEvent ("GroupsPlayerEffectsUpdated", player)
end 


function Enemy.Groups_OnGroupEffectUpdated (updateType, updatedEffects, isFullList)

--	d ("OnGroupEffectUpdated ("..tostring (updateType or "nil")..", "..tostring (updatedEffects or "nil")..", "..tostring (isFullList or "nil")..")")
--	Enemy._GroupsDebugGetEffectsNames (updatedEffects)

	if (not updatedEffects
		or 
		updateType < GameData.BuffTargetType.GROUP_MEMBER_START
		or
		updateType > GameData.BuffTargetType.GROUP_MEMBER_END)
	then
		return
	end

	Enemy._GroupsForceGroupsUpdateIfNeeded ()
	if (not g.player or not g.player.group) then return end
	
	local index = updateType - GameData.BuffTargetType.GROUP_MEMBER_START + 1
	if (g.groupType == Enemy.GroupTypes.Group or index >= g.player.index)
	then
		index = index + 1
	end
	
	local player = g.player.group[index]
	if (not player) then return end
	
	player:LoadEffects (updatedEffects, isFullList)
	Enemy.TriggerEvent ("GroupsPlayerEffectsUpdated", player)
end



--------------------------------------------------------------- Debug

function Enemy._GroupsDebugGetEffectsNames (effects)

	if (not effects) then return end

	local res = L""
	
	for _, effect in pairs (effects)
	do
		if (res:len() > 0)
		then
			res = res..L", "
		end
		
		res = res..L"#"..towstring (effect.abilityId)..L" "..effect.name
		
		if (effect.duration > 0)
		then
			res = res..L" "..towstring (Enemy.Round (effect.duration / 60.0, 1))..L"s"
		end
		
		if (effect.castByPlayer)
		then
			res = res..L" (mine)"
		end
	end
	
	return res
end


function Enemy.PrintEffects (groupIndex, playerIndex)

	local player
	
	if (type (groupIndex) == "string" or type (groupIndex) == "wstring")
	then
		groupIndex = Enemy.toWStringOrEmpty (groupIndex)
		player = g.players[groupIndex]
		
		if (not player)
		then
			Enemy.Print (L"Player '"..groupIndex..L"' not found.")
			return
		end
		
	elseif (groupIndex and playerIndex)
	then
		player = g.groups[groupIndex][playerIndex]
		
		if (not player)
		then
			Enemy.Print (L"Player with group index "..Enemy.toWStringOrEmpty (groupIndex)..L" and player index "..Enemy.toWStringOrEmpty (playerIndex)..L" not found.")
			return
		end
	else
		player = groupIndex
	end

	if (not player)
	then
		Enemy.Print ("Player not found.")
		return
	end
	
	Enemy.Print (player.name..L": "..Enemy._GroupsDebugGetEffectsNames (player.effects))
end


function Enemy._GroupsDebugEffects (text)

	if (not g.debugTarget) then return end	
	Enemy.DebugClear ()
	
	if (text)
	then
		Enemy.DebugAdd (text)
	end
	
	if (g.groupType == Enemy.GroupTypes.Solo)
	then
		Enemy.DebugAdd ("Solo")
	elseif (g.groupType == Enemy.GroupTypes.Group)
	then
		Enemy.DebugAdd ("Group")
	elseif (g.groupType == Enemy.GroupTypes.Scenario)
	then
		Enemy.DebugAdd ("Scenario")
	else
		Enemy.DebugAdd ("Warband")
	end
	
	local player = g.players[g.debugTarget]
	if (not player) then return end
	
	Enemy.DebugAdd (player.name)
	Enemy.DebugAdd ("---------------------------------")
	
	for _, effect in pairs (player.effects)
	do
		local str = effect.name
	
		if (effect.castByPlayer)
		then
			str = str..L" (mine)"
		end
		
		Enemy.DebugAdd (str)
	end
end


