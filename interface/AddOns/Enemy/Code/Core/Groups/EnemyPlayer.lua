local Enemy = Enemy
local ipairs = ipairs
local pairs = pairs
local tinsert = table.insert
local tremove = table.remove
local min = math.min
local max = math.max
local floor = math.floor
local GameData = GameData

local DISTANT_DISTANCE = 250

local CareersWithPet =
{
	[GameData.CareerLine.WHITE_LION] = true,
	[GameData.CareerLine.MAGUS] = true,
	[GameData.CareerLine.ENGINEER] = true,
	[GameData.CareerLine.SQUIG_HERDER] = true
}

--------------------------------------------------------------- EnemyPlayer class
EnemyPlayer = {}
EnemyPlayer.__index = EnemyPlayer

function EnemyPlayer.New (name)
	local obj = {}
	setmetatable (obj, EnemyPlayer)

	-- defaults
	obj.name = name
	obj.career = 0
	obj.level = 0
	obj.hp = 0
	obj.ap = 0
	obj.morale = 0
	obj.isOnline = true
	obj.isDistant = false
	obj.isGroupLeader = false
	obj.worldObjectId = 0
	obj.zoneId = 0
	obj.distance = 0

	obj.isSelected = false
	obj.isLOS = false

	obj.isInPlayerGroup = false
	obj.isSelf = false

	obj.pet = nil

	obj.effects = {}

	return obj
end


function EnemyPlayer:IsMainAssist ()

	local main_assist_member = PartyUtils.GetWarbandMainAssist ()
    local main_assist_name = nil

    if (main_assist_member)
    then
    	main_assist_name = Enemy.FixString (main_assist_member.name)
    end

	return self.name == main_assist_name
end


function EnemyPlayer:IsValid ()
	return self.name ~= nil and self.name ~= L"" and self.career ~= 0
end


function EnemyPlayer:IsInGroup ()
	return self.group ~= nil
end


function EnemyPlayer:IsSelected ()
	return self.isSelected == true
end


function EnemyPlayer:IsLOS ()
	return self.isLOS == true
end

function EnemyPlayer:SetLOS (value, silent)

	if (self.isLOS == value or self.isSelf) then return end

	self.isLOS = value

	if (not silent) then Enemy.TriggerEvent ("GroupsPlayerUpdated", self) end
end

function EnemyPlayer:SetSelected (value)

	self.isSelected = value

	if (not self.isSelected and not self.isDistant)
	then
		self:SetLOS (false)
	end
end


function EnemyPlayer:SetDistant (value)

	if (self.isDistant == value or self.isSelf) then return end

	self.isDistant = value

	if (not self.isSelected and not self.isDistant)
	then
		self:SetLOS (false, true)
	end

	Enemy.TriggerEvent ("GroupsPlayerUpdated", self)
end


function EnemyPlayer:SetDistance (value)

	if (self.distance == value or self.isSelf) then return end

	self.distance = floor (0.5 + value)
	Enemy.TriggerEvent ("GroupsPlayerDistanceUpdated", self)

	self:SetDistant (value >= DISTANT_DISTANCE)
end


function EnemyPlayer:SetObjectWorldId (id)

	local old_id = self.worldObjectId
	self.worldObjectId = id

	if (old_id ~= id)
	then
		Enemy.TriggerEvent ("GroupsPlayerWorldObjectIdUpdated", self)
	end
end


function EnemyPlayer:LoadFromScenarioData (data)

	self.career = Enemy.ScenarioCareerIdToLine[data.careerId]
	self.level = data.rank
	self.hp = data.health
	self.ap = min (data.ap, 100)

	if (data.moraleLevel ~= nil)
	then
		self.morale = data.moraleLevel
	end

	self.zoneId = GameData.Player.zone or 0
	self.isGroupLeader = false
end


function EnemyPlayer:LoadFromWarbandData (data)
	self:LoadFromGroupData (data)
end


function EnemyPlayer:LoadFromGroupData (data)

	self.career = data.careerLine
	self.level = data.level
	self.hp = data.healthPercent
	self.ap = min (data.actionPointPercent, 100)
	self.morale = data.moraleLevel

	self.zoneId = data.zoneNum or 0
	self:SetObjectWorldId (data.worldObjNum or 0)

	self.isOnline = data.online
	self.isGroupLeader = data.isGroupLeader

	if (CareersWithPet[self.career] and data.Pet and data.Pet.healthPercent)
	then
		self.pet =
		{
			owner = self,
			career = self.career,
			hp = data.Pet.healthPercent
		}
	else
		self.pet = nil
	end
end


function EnemyPlayer:LoadFromCurrentPlayer ()

	self.career = GameData.Player.career.line
	self.level = GameData.Player.level
	self.hp = floor (100.0 * GameData.Player.hitPoints.current / GameData.Player.hitPoints.maximum)
	self.ap = min (floor (100.0 * GameData.Player.actionPoints.current / GameData.Player.actionPoints.maximum), 100)
	self.morale = GetPlayerMoraleLevel ()

	self.zoneId = GameData.Player.zone or 0
	self.worldObjectId = GameData.Player.worldObjNum or 0

	self.isOnline = true
	self.isGroupLeader = GameData.Player.isGroupLeader
	self:SetDistant (false)

	self.isRVRFlagged = (GameData.Player.rvrZoneFlagged or GameData.Player.rvrPermaFlagged)
	self.isInCombat = GameData.Player.inCombat

	self:LoadPetFromCurrentPlayer ()
end


function EnemyPlayer:LoadPetFromCurrentPlayer ()

	if (CareersWithPet[self.career] and GameData.Player.Pet and GameData.Player.Pet.healthPercent)
	then
		self.pet =
		{
			owner = self,
			name = Enemy.FixString (GameData.Player.Pet.name),
			career = self.career,
			level = GameData.Player.Pet.level,
			hp = GameData.Player.Pet.healthPercent,
			worldObjectId = GameData.Player.Pet.objNum
		}
	else
		self.pet = nil
	end
end


function EnemyPlayer:LoadFromTarget (targetClassification, targetId)

	self.name = Enemy.FixString (TargetInfo:UnitName (targetClassification))
	self.career = TargetInfo:UnitCareer (targetClassification)
	self.level = TargetInfo:UnitLevel (targetClassification)
	self.hp = TargetInfo:UnitHealth (targetClassification)

	self.zoneId = GameData.Player.zone or 0
	self:SetObjectWorldId (TargetInfo:UnitEntityId (targetClassification) or 0)

	self.isOnline = true
end


function EnemyPlayer:LoadEffects (data, isFullList)

	if (isFullList) then self.effects = {} end

	for index, effect in pairs (data)
	do
		if (effect.effectIndex == nil or effect.iconNum == nil or effect.iconNum < 1)
		then
			self.effects[index] = nil
		else
			if (not effect._enemy)
			then
				effect._enemyName = Enemy.FixString (effect.name):lower ()
				effect._enemyEffectText = Enemy.FixString (effect.effectText):lower ()
				effect._enemy = true
			end

			-- effect._enemyDuration will holds the duration of the effect
			-- when it was first "seen" on the player

			if (not effect._enemyDuration or effect.duration < effect._enemyDuration)
			then
				effect._enemyDuration = max (0, effect.duration)
				effect._enemyTimeout = Enemy.time + effect._enemyDuration
			end

			self.effects[index] = effect
		end
	end

	if (self.checkEffectsTimer)
	then
		self.checkEffectsTimer:Remove ()
		self.checkEffectsTimer = nil
	end

	if (self:IsInGroup () and not self.isInPlayerGroup)
	then
		-- calculate minimal duration effect
		-- also calculate timeout for effect

		local min_timeout = nil
		for _, effect in pairs (self.effects)
		do
			if (min_timeout == nil or (effect._enemyTimeout and min_timeout > effect._enemyTimeout))
			then
				min_timeout = effect._enemyTimeout
			end
		end

		if (min_timeout)
		then
			self.checkEffectsTimer = EnemyTimer.New (nil, min_timeout - Enemy.time, function (timer, player)

				local new_data = {}
				local effects_changed = false

				for index, effect in pairs (player.effects)
				do
					if (effect._enemyTimeout and Enemy.time >= effect._enemyTimeout)
					then
						player.effects[index] = nil
						effects_changed = true
					end
				end

				if (effects_changed)
				then
					player:LoadEffects ({}, false)
					Enemy.TriggerEvent ("GroupsPlayerEffectsUpdated", player)
				end

				return true

			end, self)
		end
	end
end


function EnemyPlayer.GetExample ()

	local obj = EnemyPlayer.New (Enemy.groups.player.name)

	for k, v in pairs (Enemy.groups.player)
	do
		obj[k] = v
	end

	obj.distance = 123
	obj.isGroupLeader = true
	obj.morale = 4
	obj.isSelected = true

	return obj
end


function EnemyPlayer.GetRandomExample (group_index, index)

	local prefix = ""
	if group_index then prefix = prefix.."G:"..group_index end
	if index then prefix = prefix.."P:"..index end

	local obj = EnemyPlayer.New (towstring (Enemy.capitalize (prefix..(Enemy.GetRandomString2 (math.random (4, 15)))  )  ))

	obj.career = math.random (24)
	obj.level = math.random (40)
	obj.hp = math.random (0, 100)
	obj.ap = math.random (0, 100)
	obj.morale = math.random (0, 4)
	obj.distance = math.random (DISTANT_DISTANCE + 50)

	obj.isOnline = math.random (0, 10) ~= 5
	obj.isDistant = obj.distance >= DISTANT_DISTANCE
	obj.isGroupLeader = math.random (0, 1) == 0
	obj.isInPlayerGroup = math.random (0, 1) == 0
	obj.isSelected = math.random (0, 3) == 2
	obj.isLOS = math.random (0, 10) == 5
	obj.isSelf = obj.isInPlayerGroup and (math.random (0, 1) == 0)

	return obj
end
