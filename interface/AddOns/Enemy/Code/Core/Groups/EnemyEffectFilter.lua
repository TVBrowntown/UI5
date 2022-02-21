local Enemy = Enemy
local ipairs = ipairs
local pairs = pairs
local tinsert = table.insert
local tremove = table.remove
local tconcat = table.concat

local Types =
{
	["isDebuff"] = { text = L"debuff", value = "isDebuff" },
	["isAilment"] = { text = L"ailment", value = "isAilment" },
	["isHex"] = { text = L"hex", value = "isHex" },
	["isCurse"] = { text = L"curse", value = "isCurse" },
	["isOffensive"] = { text = L"offensive", value = "isOffensive" },
	["isDamaging"] = { text = L"damaging", value = "isDamaging" },
	["isDefensive"] = { text = L"defensive", value = "isDefensive" },
	["isHealing"] = { text = L"healing", value = "isHealing" },
	["isBuff"] = { text = L"buff", value = "isBuff" },
	["isBlessing"] = { text = L"blessing", value = "isBlessing" },
	["isStatsBuff"] = { text = L"stats buff", value = "isStatsBuff" },
	["isGranted"] = { text = L"granted", value = "isGranted" },
	["isPassive"] = { text = L"passive", value = "isPassive" }
}

Enemy.EffectFilterTypes = Types		-- for other addons


-- Custom effect filter types

--
-- Heal debuffs
-- Partial credits for heal debuffs data goes to majeric, the author of SquaredHDIndicator addon
--
local HealDebuffsAbilityIds =
{
	In =
	{
		Destr =
		{
			-- Zealot
			[8613] = 50, 			-- Windblock
			-- Disciple Of Khaine
			[9602] = 50, 			-- Curse Of Khaine
			[3428] = 50, 			-- Curse Of Khaine
			-- Witch Elf
			[9424] = 50, 			-- Black Lotus Blade
			-- Marauder
			[8440] = 50, 			-- Deadly Clutch
			-- Squig Herder
			[1853] = 50, 			-- Rotten Arrer
			-- Choppa
			[1773] = 50, 			-- No More Helpin'
			[1803] = 50, 			-- Yer Goin Down!
			-- Shaman
			[1905] = 50, 			-- Gork's Barbs'
			[3352] = 50, 			-- Gork's Barbs'
			-- Chosen
			[8348] = 25, 			-- Discordant Turbulence
			[3409] = 25, 			-- Discordant Turbulence
			[3776] = 25, 			-- Discordant Turbulence
			-- Marauder
			[8401] = 25, 			-- Tainted Claw
			-- Witch Elf
			[10412] = 25, 			-- Guile
			[10717] = 25 			-- Guile
		},
		
		Order =
		{
			-- Archmage
			[3915] = 50, 			-- Scatter the Winds
			[9247] = 50, 			-- Scatter the Winds
			-- Bright Wizard
			[3569] = 50, 			-- Playing with Fire
			[8184] = 50, 			-- Playing with Fire
			[20577] = 50, 			-- Playing with Fire
			-- Witch Hunter
			[8112] = 50, 			-- Punish The False
			[20324] = 50, 			-- Punish The False
			[8153] = 50, 			-- Excommunicate
			-- Shadowwarrior
			[9109] = 50, 			-- Shadow Sting
			-- Slayer
			[1434] = 50, 			-- Deep Wound
			[12692] = 50, 			-- Deep Wound
			[1501] = 50 			-- Looks like a Challenge
		}
	},
	Out =
	{
		Destr =
		{
			-- With Elf
			[3598] = 50, 			-- Kiss of Death
			[3811] = 50, 			-- Kiss of Death
			[9407] = 50, 			-- Kiss of Death
			[20263] = 50, 			-- Kiss of Death
			-- Blackguard
			[3372] = 50, 			-- Mind Killer
			[9317] = 50 			-- Mind Killer
		},
		
		Order =
		{
			-- Iron Breaker
			[1410] = 50,			-- Punishing Knock
			[3166] = 50,			-- Punishing Knock
			[3469] = 50,			-- Punishing Knock
			
			-- Witch Hunter
			[3002] = 50, 			-- Blessed Bullets of Confession
			[3784] = 50, 			-- Blessed Bullets of Confession
			[8099] = 50, 			-- Blessed Bullets of Confession
			
			-- Knight of the blazing sun
			[3493] = 25, 			-- Now's Our Chance!
			[8036] = 25, 			-- Now's Our Chance!
			
			-- White Lion
			[9191] = 50 			-- Thin the Herd
		}
	}   
}

Enemy.HealDebuffsAbilityIds = HealDebuffsAbilityIds		-- for external usage

local HealDebuffIn = {}
local HealDebuffOut = {}

Types["healDebuffIn50"] =
{
	text = L"incomming heal debuff 50%",
	value = "healDebuffIn50",
	
	IsMatch = function (effect)
		return HealDebuffIn[effect.abilityId] == 50
	end
}
	
Types["healDebuffIn25"] =
{
	text = L"incomming heal debuff 25%",
	value = "healDebuffIn25",
	
	IsMatch = function (effect)
		return HealDebuffIn[effect.abilityId] == 25
	end
}
	
Types["healDebuffIn"] =
{
	text = L"incomming heal debuff",
	value = "healDebuffIn",
	
	IsMatch = function (effect)
		return HealDebuffIn[effect.abilityId] ~= nil
	end
}
	
Types["healDebuffOut50"] =
{
	text = L"outgoing heal debuff 50%",
	value = "healDebuffOut50",
	
	IsMatch = function (effect)
		return HealDebuffIn[effect.abilityId] == 50
	end
}
	
Types["healDebuffOut25"] =
{
	text = L"outgoing heal debuff 25%",
	value = "healDebuffOut25",
	
	IsMatch = function (effect)
		return HealDebuffIn[effect.abilityId] == 25
	end
}
	
Types["healDebuffOut"] =
{
	text = L"outgoing heal debuff",
	value = "healDebuffOut",
	
	IsMatch = function (effect)
		return HealDebuffOut[effect.abilityId] ~= nil
	end
}


--
-- Stagger
--
local StaggerAbilityIds =
{
	Destr =
	{
		-- Chosen
		[3031] = true,	-- Quake
		[8349] = true,	-- Quake
		[20189] = true,	-- Quake
		
		-- DoK
		[3707] = true,	-- Universal Confusion
		[9606] = true,	-- Universal Confusion
		[23065] = true,	-- Universal Confusion
		
		-- Magus
		[8541] = true,	-- Daemonic Infestation
		[21655] = true, -- Instability
		
		-- Witch Elf
		[3032] = true,	-- Agile Escape
		[9396] = true,	-- Agile Escape
		
		-- Zealot
		[3027] = true,	-- Aethyric Shock
		[8571] = true,	-- Aethyric Shock
		[20461] = true,	-- Aethyric Shock
		
		-- Sorcerer
		[671] = true,	-- Scintillating Energy
		[3168] = true	-- Scintillating Energy
	},
	Order =
	{
		-- Engineer
		[1524] = true,	-- Land Mine
		[3630] = true,	-- Land Mine
		[5879] = true,	-- Land Mine
		[1525] = true,	-- Self-Destruct
		[31] = true,	-- Detonation
		[383] = true,	-- Detonation
		[3034] = true,	-- Detonation
		[3149] = true,	-- Detonation
		[3167] = true,	-- Detonation
		
		-- KotBS
		[3030] = true,	-- Heaven's Fury
		[8038] = true,	-- Heaven's Fury
		[20249] = true,	-- Heaven's Fury
		
		-- Rune Priest
		[1613] = true,	-- Rune of Binding
		[3028] = true,	-- Rune of Binding
		[20480] = true,	-- Rune of Binding
		
		-- Shadow Warrior
		[3029] = true,	-- Instill Fear
		[9139] = true,	-- Instill Fear
		
		-- Warrior Priest
		[3035] = true,	-- Penance
		[8304] = true,	-- Penance
		
		-- Witch Hunter
		[3033] = true,	-- Declare Anathema
		[8094] = true,	-- Declare Anathema
		
		-- Bright Wizard
		[671] = true,	-- Scintillating Energy
		[3168] = true	-- Scintillating Energy
	}
}

Enemy.StaggerAbilityIds = StaggerAbilityIds		-- for external usage

local Staggers = {}

Types["stagger"] =
{
	text = L"stagger",
	value = "stagger",
	
	IsMatch = function (effect)
		return Staggers[effect.abilityId] == true
	end
}

	
--
-- Guard
--
local GuardAbilityIds =
{
	[1008] = true,	-- Guard
	[1363] = true,	-- Guard
	[8013] = true,	-- Guard
	[8325] = true,	-- Guard
	[9008] = true,	-- Guard
	[9325] = true,	-- Guard
	
	[1674] = true	-- Save Da Runts
}

Enemy.GuardAbilityIds = GuardAbilityIds		-- for external usage

Types["guard"] =
{
	text = L"guard",
	value = "guard",
	
	IsMatch = function (effect)
		return GuardAbilityIds[effect.abilityId] == true
	end
}


--
-- Polymorphed
--
local PolymorphedAbilityIds =
{
	[24533] = true,		-- Champion of Tchar'zanek
	[24534] = true,		-- Champion of Karl Franz
	[24535] = true,		-- Champion Buff
	[24543] = true,		-- Champion Buff Applied
	[24544] = true,		-- Champion Buff - 1 - Tank
	[24545] = true,		-- Champion Buff - 1 - DPS Melee
	[24546] = true,		-- Champion Buff - 1 - DPS Range
	[24547] = true,		-- Champion Buff - 1 - Healer
	[24548] = true,		-- Champion Buff - 2 - Tank
	[24549] = true,		-- Champion Buff - 2 - DPS Melee
	[24550] = true,		-- Champion Buff - 2 - DPS Range
	[24551] = true,		-- Champion Buff - 2 - Healer

	[24561] = true,		-- Skaven Skirmisher
	[24855] = true,		-- Skaven Play-as-Monster
}

Enemy.PolymorphedAbilityIds = PolymorphedAbilityIds		-- for external usage


--------------------------------------------------------------- Helper functions

function Enemy._GroupsInitializeCustomEffectFilters ()

	if (GameData.Player.realm == GameData.Realm.ORDER)
	then
		HealDebuffIn = HealDebuffsAbilityIds.In.Destr
		HealDebuffOut = HealDebuffsAbilityIds.Out.Destr
		Staggers = StaggerAbilityIds.Destr
	else
		HealDebuffIn = HealDebuffsAbilityIds.In.Order
		HealDebuffOut = HealDebuffsAbilityIds.Out.Order
		Staggers = StaggerAbilityIds.Order
	end
	
	Enemy.TriggerEvent ("GroupsInitializeCustomEffectFilters", Types)
end


--------------------------------------------------------------- EnemyEffectFilter class
EnemyEffectFilter = {}
EnemyEffectFilter.__index = EnemyEffectFilter


function EnemyEffectFilter.New (data)
	local obj = {}
	setmetatable (obj, EnemyEffectFilter)
	
	-- defaults
	obj.filterName = nil
	obj.name = nil
	obj.nameMatch = 1
	obj.description = nil
	obj.descriptionMatch = 2
	obj.abilityIds = nil
	obj.typeMatch = 1
	obj.type = nil
	obj.durationType = 1
	obj.durationMin = nil
	obj.durationMax = nil
	obj.stackCount = nil
	obj.castedByMe = 1
	
	if (data)
	then
		obj:Load (data)
	end
	
	return obj
end


function EnemyEffectFilter:Load (data)

	self.filterName = data.filterName
	self.name = data.name
	self.nameMatch = data.nameMatch
	self.description = data.description
	self.descriptionMatch = data.descriptionMatch
	self.abilityIds = data.abilityIds
	self.typeMatch = data.typeMatch
	self.type = data.type
	self.durationType = data.durationType
	self.durationMin = data.durationMin
	self.durationMax = data.durationMax
	self.stackCount = data.stackCount
	self.castedByMe = data.castedByMe
	
	if (self.name) then self.name = self.name:lower () end
	if (self.description) then self.description = self.description:lower () end
	
	self.hasDurationLimit = (
								(self.durationType == 2 or self.durationType == 4)
								and
								(self.durationMin ~= nil or self.durationMax ~= nil)
							)
	
	if (self.abilityIds)
	then
		self.abilityIdsHash = {}
		
		local has_ids = false
		for _, v in ipairs (Enemy.Split (self.abilityIds, L",", true))
		do
			self.abilityIdsHash[tonumber (Enemy.trim (v))] = true
			has_ids = true
		end
		
		if (not has_ids)
		then
			self.abilityIdsHash = nil
		end
	else
		self.abilityIdsHash = nil
	end
end


function EnemyEffectFilter:Edit (onOkCallback)
	
	Enemy.GroupsUI_EffectFilterDialog_Open (self, function (old, new)
		
		old:Load (new)
		
		if (onOkCallback)
		then
			onOkCallback (self)
		end
	end)
end


function EnemyEffectFilter:IsMatch (effect)

	if (self.name)
	then
		if (self.nameMatch == 1)
		then
			if (effect._enemyName ~= self.name) then return false end
		elseif (self.nameMatch == 2)
		then
			if (not effect._enemyName:find (self.name, 1, true)) then return false end
		elseif (self.nameMatch == 3)
		then
			if (not effect._enemyName:match (self.name)) then return false end
		end
	end
	
	if (self.description)
	then
		if (self.descriptionMatch == 1)
		then
			if (effect._enemyEffectText ~= self.description) then return false end
		elseif (self.descriptionMatch == 2)
		then
			if (not effect._enemyEffectText:find (self.description, 1, true)) then return false end
		elseif (self.descriptionMatch == 3)
		then
			if (not effect._enemyEffectText:match (self.description)) then return false end
		end
	end
	
	if (self.abilityIdsHash)
	then
		if (self.abilityIdsHash[effect.abilityId] ~= true) then return false end
	end
	
	if (self.type)
	then
		local t = Types[self.type]
		
		if (not t.IsMatch)
		then
			if (effect[t.value] ~= (self.typeMatch == 1)) then return false end
		else
			if (t.IsMatch (effect) ~= (self.typeMatch == 1)) then return false end
		end
	end
	
	if (self.durationType ~= 1)
	then
		if (self.durationType == 2)
		then
			if (effect._enemyDuration <= 0) then return false end
			if (self.durationMin and effect._enemyDuration < self.durationMin) then return false end
			if (self.durationMax and effect._enemyDuration > self.durationMax) then return false end
			
		elseif (self.durationType == 4)
		then
			if (effect.duration <= 0) then return false end
			if (self.durationMin and effect.duration < self.durationMin) then return false end
			if (self.durationMax and effect.duration > self.durationMax) then return false end
			
		else
			if (not effect.permanentUntilDispelled) then return false end
		end
	end
	
	if (self.stackCount and effect.stackCount ~= self.stackCount)
	then
		return false
	end
	
	if (self.castedByMe ~= 1)
	then
		if (not (self.castedByMe == 2 and effect.castByPlayer)
			and
			not (self.castedByMe == 3 and not effect.castByPlayer))
		then return false end
	end
	
	return true
end


----------------------------------------------------------------- UI: Effect filter dialog
local effect_filter_dlg =
{
	isInitialized = false
}


function Enemy.GroupsUI_EffectFilterDialog_IsOpen ()
	return WindowGetShowing ("EnemyEffectFilterDialog")
end


function Enemy.GroupsUI_EffectFilterDialog_Hide ()
	WindowSetShowing ("EnemyEffectFilterDialog", false)
end


function Enemy.GroupsUI_EffectFilterDialog_Open (data, onOkCallback)
	
	if (not effect_filter_dlg.isInitialized)
	then
		-- initialize dialog UI
		LabelSetText ("EnemyEffectFilterDialogTitleBarText", L"Effect filter")
		ButtonSetText ("EnemyEffectFilterDialogOkButton", L"OK")
		ButtonSetText ("EnemyEffectFilterDialogCancelButton", L"Cancel")
		
		LabelSetText ("EnemyEffectFilterDialogFilterNameLabel", L"Filter name")
		
		LabelSetText ("EnemyEffectFilterDialogNameLabel", L"Effect name")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogNameMatch", L"exact")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogNameMatch", L"substring")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogNameMatch", L"regexp")
		
		LabelSetText ("EnemyEffectFilterDialogDescriptionLabel", L"Effect description")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogDescriptionMatch", L"exact")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogDescriptionMatch", L"substring")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogDescriptionMatch", L"regexp")
		
		LabelSetText ("EnemyEffectFilterDialogAbilityIdsLabel", L"Ability ids")
		
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogTypeMatch", L"Type is")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogTypeMatch", L"Type is not")
		
		
		effect_filter_dlg.typeComboBoxValues = Enemy.UI_PrepareComboBoxValuesArray (Types,
			function (k, v)
				return { text = v.text, value = v.value }
			end,
			function (a, b)
				return a.text < b.text
			end)
			
		tinsert (effect_filter_dlg.typeComboBoxValues, 1, { text= L"any", value = nil })
		
		for _, v in pairs (effect_filter_dlg.typeComboBoxValues)
		do
			ComboBoxAddMenuItem ("EnemyEffectFilterDialogType", v.text)
		end
		
		
		LabelSetText ("EnemyEffectFilterDialogDurationLabel", L"Duration")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogDurationType", L"doesn't matter")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogDurationType", L"has initial duration")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogDurationType", L"permanent")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogDurationType", L"has current duration")
		LabelSetText ("EnemyEffectFilterDialogDurationLabel2", L" ... ")
		
		LabelSetText ("EnemyEffectFilterDialogStackCountLabel", L"Stack count")
		
		LabelSetText ("EnemyEffectFilterDialogCastedByMeLabel", L"Casted by me")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogCastedByMe", L"doesn't matter")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogCastedByMe", L"yes")
		ComboBoxAddMenuItem ("EnemyEffectFilterDialogCastedByMe", L"no")
		
		effect_filter_dlg.isInitialized = true
	end
	
	-- proceed parameters
	effect_filter_dlg.oldData = data
	effect_filter_dlg.data = EnemyEffectFilter.New (data)
	effect_filter_dlg.onOkCallback = onOkCallback
	
	-- fill form
	TextEditBoxSetText ("EnemyEffectFilterDialogFilterName", Enemy.isNil (effect_filter_dlg.data.filterName, L""))
	
	TextEditBoxSetText ("EnemyEffectFilterDialogName", Enemy.isNil (effect_filter_dlg.data.name, L""))
	ComboBoxSetSelectedMenuItem ("EnemyEffectFilterDialogNameMatch", effect_filter_dlg.data.nameMatch)
	
	TextEditBoxSetText ("EnemyEffectFilterDialogDescription", Enemy.isNil (effect_filter_dlg.data.description, L""))
	ComboBoxSetSelectedMenuItem ("EnemyEffectFilterDialogDescriptionMatch", effect_filter_dlg.data.descriptionMatch)
	
	TextEditBoxSetText ("EnemyEffectFilterDialogAbilityIds", Enemy.isNil (effect_filter_dlg.data.abilityIds, L""))
	
	ComboBoxSetSelectedMenuItem ("EnemyEffectFilterDialogTypeMatch", effect_filter_dlg.data.typeMatch)

	Enemy.UI_SetComboBoxValueByValuesArray ("EnemyEffectFilterDialogType", effect_filter_dlg.typeComboBoxValues, function (k, v)
		return (v.value == effect_filter_dlg.data.type)
	end)
	
	ComboBoxSetSelectedMenuItem ("EnemyEffectFilterDialogDurationType", effect_filter_dlg.data.durationType)
	Enemy.GroupsUI_EffectFilterDialog_OnDurationTypeSelChanged ()
	TextEditBoxSetText ("EnemyEffectFilterDialogDurationMin", Enemy.toWStringOrEmpty (effect_filter_dlg.data.durationMin))
	TextEditBoxSetText ("EnemyEffectFilterDialogDurationMax", Enemy.toWStringOrEmpty (effect_filter_dlg.data.durationMax))
	
	TextEditBoxSetText ("EnemyEffectFilterDialogStackCount", Enemy.toWStringOrEmpty (effect_filter_dlg.data.stackCount))
	
	ComboBoxSetSelectedMenuItem ("EnemyEffectFilterDialogCastedByMe", effect_filter_dlg.data.castedByMe)
		
	
	WindowSetShowing ("EnemyEffectFilterDialog", true)
end


function Enemy.GroupsUI_EffectFilterDialog_OnDurationTypeSelChanged ()
	local val = ComboBoxGetSelectedMenuItem ("EnemyEffectFilterDialogDurationType")
	WindowSetShowing ("EnemyEffectFilterDialogDurationMin", val == 2 or val == 4)
	WindowSetShowing ("EnemyEffectFilterDialogDurationMax", val == 2 or val == 4)
	WindowSetShowing ("EnemyEffectFilterDialogDurationLabel2", val == 2 or val == 4)
end

function Enemy.GroupsUI_EffectFilterDialog_OnAbilityIdsMouseOver ()

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, L"To get ability ids type")
	Tooltips.SetTooltipText (2, 1, L"/script Enemy.GetAbilityIds(\"Ability name\")")
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.GroupsUI_EffectFilterDialog_Ok ()

	if (not Enemy.GroupsUI_EffectFilterDialog_IsOpen ()) then return end
	
	-- get data from form
	effect_filter_dlg.data.filterName = Enemy.isEmpty (TextEditBoxGetText ("EnemyEffectFilterDialogFilterName"), L"")
	
	if (not Enemy.LogicalExpressionIsValidFunctionName (Enemy.toString (effect_filter_dlg.data.filterName)))
	then
		DialogManager.MakeOneButtonDialog (L"Invalid name specified. Name should not contain any spaces and can not be 'and', 'or', 'not' keyword.", L"Ok")
		return
	end		
	
	effect_filter_dlg.data.name = Enemy.isEmpty (TextEditBoxGetText ("EnemyEffectFilterDialogName"), nil)
	effect_filter_dlg.data.nameMatch = ComboBoxGetSelectedMenuItem ("EnemyEffectFilterDialogNameMatch")
	
	effect_filter_dlg.data.description = Enemy.isEmpty (TextEditBoxGetText ("EnemyEffectFilterDialogDescription"))
	effect_filter_dlg.data.descriptionMatch = ComboBoxGetSelectedMenuItem ("EnemyEffectFilterDialogDescriptionMatch")
	
	effect_filter_dlg.data.abilityIds = Enemy.isEmpty (TextEditBoxGetText ("EnemyEffectFilterDialogAbilityIds"))
	
	effect_filter_dlg.data.typeMatch = ComboBoxGetSelectedMenuItem ("EnemyEffectFilterDialogTypeMatch")

	effect_filter_dlg.data.type = effect_filter_dlg.typeComboBoxValues[ComboBoxGetSelectedMenuItem ("EnemyEffectFilterDialogType")].value
	
	effect_filter_dlg.data.durationType = ComboBoxGetSelectedMenuItem ("EnemyEffectFilterDialogDurationType")
	effect_filter_dlg.data.durationMin = Enemy.clamp (0, 9999, Enemy.ConvertToFloat (TextEditBoxGetText ("EnemyEffectFilterDialogDurationMin")))
	effect_filter_dlg.data.durationMax = Enemy.clamp (0, 9999, Enemy.ConvertToFloat (TextEditBoxGetText ("EnemyEffectFilterDialogDurationMax")))
	
	effect_filter_dlg.data.stackCount = Enemy.clamp (0, 100, Enemy.ConvertToInteger (TextEditBoxGetText ("EnemyEffectFilterDialogStackCount")))
	
	effect_filter_dlg.data.castedByMe = ComboBoxGetSelectedMenuItem ("EnemyEffectFilterDialogCastedByMe")

	if (effect_filter_dlg.onOkCallback)
	then
		effect_filter_dlg.onOkCallback (effect_filter_dlg.oldData, effect_filter_dlg.data)
	end
	
	Enemy.GroupsUI_EffectFilterDialog_Hide ()
end













