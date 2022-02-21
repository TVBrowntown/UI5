BuffHeadContainer = Frame:Subclass("BuffHeadContainerTemplate");
local INACTIVE_TIMEOUT = 10;
local DISTANCE_THRESHOLD = 50;
local STUCK_TIMEOUT = 5;

local EffectType = { Buff = 1, Debuff = 2, Hex = 3, Ailment = 4, Curse = 5, Enchantment = 6, Blessing = 7 };
local dispelTable = nil;
local cacheEffects = false;

BuffHeadContainer.EffectType = EffectType;
BuffHeadContainer.ContainerType = { AlwaysShow = 1, Buff = 2, Debuff = 3 };

local WindowClearAnchors, WindowAddAnchor = WindowClearAnchors, WindowAddAnchor;

local function CopyTable(dataTable)

	local copiedTable = {};

	for k,v in pairs(dataTable) do
		copiedTable[k] = v;
	end
	
	return copiedTable;

end

local function IsFriendly(targetType)
	return (targetType == BuffHead.TargetType.Friendly or targetType == BuffHead.TargetType.Self or targetType == BuffHead.TargetType.Group);
end

local function IsHostile(targetType)
	return (targetType == BuffHead.TargetType.Hostile);
end

local function GetEffectColor(ability)
	if (ability.isHex or ability.isCurse or ability.isCripple or ability.isAilment or ability.isBolster or ability.isAugmentation or ability.isBlessing or ability.isEnchantment) then
		return { r = ability.typeColorRed or 0, g = ability.typeColorGreen or 0, b = ability.typeColorBlue or 0 };
	elseif (ability.isDamaging) then
		return DefaultColor.AbilityType.DAMAGING;
	elseif (ability.isHealing) then
		return DefaultColor.AbilityType.HEALING;
	elseif (ability.isDebuff) then
		return DefaultColor.AbilityType.DEBUFF;
	elseif (ability.isBuff or ability.isStatsBuff) then
		return DefaultColor.AbilityType.BUFF;
	elseif (ability.isOffensive or ability.isDefensive) then
		return DefaultColor.AbilityType.OFFENSIVE;
	end
    return DefaultColor.WHITE;
end

function BuffHeadContainer.GetEffectColor(ability)
	return GetEffectColor(ability);
end

local function GetEffectType(ability, targetType)

	if (IsHostile(targetType)) then
		if (ability.castByPlayer) then
			if (ability.isHex) then	return EffectType.Debuff;
			elseif (ability.isCurse) then return EffectType.Debuff;
			elseif (ability.isCripple) then return EffectType.Debuff;
			elseif (ability.isAilment) then return EffectType.Debuff;
			elseif (ability.isBolster) then return EffectType.Buff;
			elseif (ability.isAugmentation) then return EffectType.Buff;
			elseif (ability.isBlessing) then return EffectType.Buff;
			elseif (ability.isEnchantment) then return EffectType.Buff;
			elseif (ability.isDamaging) then return EffectType.Debuff;
			elseif (ability.isHealing) then return EffectType.Buff;
			else return EffectType.Debuff;
			end
		else
			if (ability.isHex) then	return EffectType.Debuff;
			elseif (ability.isCurse) then return EffectType.Debuff;
			elseif (ability.isCripple) then return EffectType.Debuff;
			elseif (ability.isAilment) then return EffectType.Debuff;
			elseif (ability.isBolster) then return EffectType.Buff;
			elseif (ability.isAugmentation) then return EffectType.Buff;
			elseif (ability.isBlessing) then return EffectType.Buff;
			elseif (ability.isEnchantment) then return EffectType.Buff;
			elseif (ability.isDamaging) then return EffectType.Debuff;
			elseif (ability.isHealing) then return EffectType.Buff;
			elseif (ability.isDebuff) then return EffectType.Debuff;
			elseif (ability.isBuff) then return EffectType.Buff;
			elseif (ability.isStatsBuff) then return EffectType.Buff;
			elseif (ability.isOffensive) then return EffectType.Buff;
			elseif (ability.isDefensive) then return EffectType.Buff;
			else return EffectType.Buff;
			end
		end
	else
		if (ability.castByPlayer) then
			if (ability.isHex) then return EffectType.Debuff;
			elseif (ability.isCurse) then return EffectType.Debuff;
			elseif (ability.isCripple) then return EffectType.Debuff;
			elseif (ability.isAilment) then return EffectType.Debuff;
			elseif (ability.isBolster) then return EffectType.Buff;
			elseif (ability.isAugmentation) then return EffectType.Buff;
			elseif (ability.isBlessing) then return EffectType.Buff;
			elseif (ability.isEnchantment) then return EffectType.Buff;
			elseif (ability.isDamaging) then return EffectType.Debuff;
			elseif (ability.isHealing) then return EffectType.Buff;
			else return EffectType.Buff;
			end
		else
			if (ability.isHex) then return EffectType.Debuff;
			elseif (ability.isCurse) then return EffectType.Debuff;
			elseif (ability.isCripple) then return EffectType.Debuff;
			elseif (ability.isAilment) then return EffectType.Debuff;
			elseif (ability.isBolster) then return EffectType.Buff;
			elseif (ability.isAugmentation) then return EffectType.Buff;
			elseif (ability.isBlessing) then return EffectType.Buff;
			elseif (ability.isEnchantment) then return EffectType.Buff;
			elseif (ability.isDamaging) then return EffectType.Debuff;
			elseif (ability.isHealing) then return EffectType.Buff;
			elseif (ability.isDebuff) then return EffectType.Debuff;
			elseif (ability.isBuff) then return EffectType.Buff;
			elseif (ability.isStatsBuff) then return EffectType.Buff;
			elseif (ability.isOffensive) then return EffectType.Buff;
			elseif (ability.isDefensive) then return EffectType.Buff;
			else return EffectType.Buff;
			end
		end
	end
end

local function CopyAbilityData(ability)
	-- copy only the relevant data, rather than looping through everything
	return {
		color = GetEffectColor(ability),
		abilityId = ability.abilityId,
		name = ability.name,
		duration = ability.duration,
		stackCount = ability.stackCount,
		iconNum = ability.iconNum,
		castByPlayer = ability.castByPlayer,
		permanentUntilDispelled = ability.permanentUntilDispelled,
		source = ability,
	};
end

local function SetupDispelTable()

	if (dispelTable) then return end
	
	local isHex = EffectType.Hex; --GetString(StringTables.Default.LABEL_ABILITY_TYPE_HEX);
	local isAilment = EffectType.Ailment; --GetString(StringTables.Default.LABEL_ABILITY_TYPE_AILMENT);
	local isCurse = EffectType.Curse; --GetString(StringTables.Default.LABEL_ABILITY_TYPE_CURSE);
	local isEnchantment = EffectType.Enchantment; --GetString(StringTables.Default.LABEL_ABILITY_TYPE_ENCHANTMENT);
	local isBlessing = EffectType.Blessing; --GetString(StringTables.Default.LABEL_ABILITY_TYPE_BLESSING);
	
	dispelTable = {};
	dispelTable[GameData.CareerLine.ARCHMAGE] = {};
	dispelTable[GameData.CareerLine.ARCHMAGE][isHex] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.ARCHMAGE][isAilment] = BuffHead.TargetType.Friendly;
	
	dispelTable[GameData.CareerLine.DISCIPLE or GameData.CareerLine.BLOOD_PRIEST] = {};
	dispelTable[GameData.CareerLine.DISCIPLE or GameData.CareerLine.BLOOD_PRIEST][isHex] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.DISCIPLE or GameData.CareerLine.BLOOD_PRIEST][isAilment] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.DISCIPLE or GameData.CareerLine.BLOOD_PRIEST][isEnchantment] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.BRIGHT_WIZARD] = {};
	dispelTable[GameData.CareerLine.BRIGHT_WIZARD][isHex] = BuffHead.TargetType.Self;
	dispelTable[GameData.CareerLine.BRIGHT_WIZARD][isAilment] = BuffHead.TargetType.Self;
	dispelTable[GameData.CareerLine.BRIGHT_WIZARD][isCurse] = BuffHead.TargetType.Self;
	
	dispelTable[GameData.CareerLine.RUNE_PRIEST] = {};
	dispelTable[GameData.CareerLine.RUNE_PRIEST][isCurse] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.RUNE_PRIEST][isAilment] = BuffHead.TargetType.Friendly;
	
	dispelTable[GameData.CareerLine.SHAMAN] = {};
	dispelTable[GameData.CareerLine.SHAMAN][isCurse] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.SHAMAN][isAilment] = BuffHead.TargetType.Friendly;
	
	dispelTable[GameData.CareerLine.WARRIOR_PRIEST] = {};
	dispelTable[GameData.CareerLine.WARRIOR_PRIEST][isCurse] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.WARRIOR_PRIEST][isHex] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.WARRIOR_PRIEST][isEnchantment] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.ZEALOT] = {};
	dispelTable[GameData.CareerLine.ZEALOT][isCurse] = BuffHead.TargetType.Friendly;
	dispelTable[GameData.CareerLine.ZEALOT][isHex] = BuffHead.TargetType.Friendly;
	
	dispelTable[GameData.CareerLine.SWORDMASTER] = {};
	dispelTable[GameData.CareerLine.SWORDMASTER][isEnchantment] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.BLACK_ORC] = {};
	dispelTable[GameData.CareerLine.BLACK_ORC][isEnchantment] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.KNIGHT] = {};
	dispelTable[GameData.CareerLine.KNIGHT][isEnchantment] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.BLACKGUARD or GameData.CareerLine.SHADE] = {};
	dispelTable[GameData.CareerLine.BLACKGUARD or GameData.CareerLine.SHADE][isEnchantment] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.IRON_BREAKER] = {};
	dispelTable[GameData.CareerLine.IRON_BREAKER][isBlessing] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.CHOSEN] = {};
	dispelTable[GameData.CareerLine.CHOSEN][isBlessing] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.WITCH_HUNTER] = {};
	dispelTable[GameData.CareerLine.WITCH_HUNTER][isBlessing] = BuffHead.TargetType.Hostile;
	
	dispelTable[GameData.CareerLine.WITCH_ELF or GameData.CareerLine.ASSASSIN] = {};
	dispelTable[GameData.CareerLine.WITCH_ELF or GameData.CareerLine.ASSASSIN][isBlessing] = BuffHead.TargetType.Hostile;

end

local function IsDispellable(ability, targetType)

	local type = nil;
	
	if (ability.isHex) then
		type = EffectType.Hex;
	elseif (ability.isCurse) then
		type = EffectType.Curse;
	elseif (ability.isCripple) then
	elseif (ability.isAilment) then
		type = EffectType.Ailment;
	elseif (ability.isBolster) then
	elseif (ability.isAugmentation) then
	elseif (ability.isBlessing) then
		type = EffectType.Blessing;
	elseif (ability.isEnchantment) then
		type = EffectType.Enchantment;
	end

	local t = dispelTable[GameData.Player.career.line];

	if (t and t[type]) then
		if (t[type] == targetType or (t[type] == BuffHead.TargetType.Friendly and IsFriendly(targetType))) then
			return true;
		end
	end
	
	return false;

end

local function GetSettingsForType(targetType)

	local isFriendly = (targetType == BuffHead.TargetType.Friendly);
	local isHostile = IsHostile(targetType);
	local isGroup = (targetType == BuffHead.TargetType.Group);
	local isSelf = (targetType == BuffHead.TargetType.Self);
	local settings = nil;
	
	if (isFriendly) then
		settings = BuffHead.Settings.Trackers.Friendly;
	elseif (isGroup) then
		settings = BuffHead.Settings.Trackers.Group;
	elseif (isSelf) then
		settings = BuffHead.Settings.Trackers.Self;
	elseif (isHostile) then
		settings = BuffHead.Settings.Trackers.Hostile;
	end
	
	return settings;
	
end

local function IsDurationWithinThreshold(abilityData, maximumThreshold, minimumThreshold)

	local ability = abilityData.Data;
	local timeAdded = abilityData.TimeAdded;
	local duration = math.max(ability.duration - (BuffHead.TimeCount - timeAdded), 0);
	
	if (minimumThreshold and duration < minimumThreshold) then
		return false;
	end
	
	return (duration < (maximumThreshold or BuffHead.Settings.MaximumThreshold));

end

local function IsAbilityValid(self, abilityData, targetType)

	local ability = abilityData.Data;
	local timeAdded = abilityData.TimeAdded;

	local name = tostring(ability.name:match(L"([a-zA-Z,'! ]+)"));
	local duration = math.max(ability.duration - (BuffHead.TimeCount - timeAdded), 0);

	local isFriendly = (targetType == BuffHead.TargetType.Friendly);
	local isHostile = IsHostile(targetType);
	local isGroup = (targetType == BuffHead.TargetType.Group);
	local isSelf = (targetType == BuffHead.TargetType.Self);
	local effectType = abilityData.Type; --GetEffectType(ability, targetType);
	local isBuff = (effectType == EffectType.Buff);
	local isDebuff = (effectType == EffectType.Debuff);
	local isDispellable = abilityData.IsDispellable; --IsDispellable(ability, targetType);
	
	local displayPermanent = nil;
	
	if (self.IsAdvancedContainer) then
		displayPermanent = self.Settings.Permanent;
	else
		displayPermanent = (isSelf and BuffHead.Settings.Trackers.Self.Permanent) or (isGroup and BuffHead.Settings.Trackers.Group.Permanent) 
								or (isFriendly and BuffHead.Settings.Trackers.Friendly.Permanent) or (isHostile and BuffHead.Settings.Trackers.Hostile.Permanent);
	end
	
	local displayEffect = false;
	local displayAlwaysShow = true;
	local settings = nil;
	if (not self.IsAdvancedContainer) then
		settings = GetSettingsForType(targetType);
	else
		displayAlwaysShow = self.Settings.AlwaysShowEnabled;
		settings = self.Settings;
	end
	
	local skipAlwaysIgnoreCoreList = false;
	if (settings) then
		local alwaysIgnoreSettings = settings.AlwaysIgnore;
		
		if (alwaysIgnoreSettings) then
			local ignored = (alwaysIgnoreSettings[name] or alwaysIgnoreSettings[ability.abilityId]);
			if (ignored ~= nil) then
				if (ignored) then
					return false;
				else
					skipAlwaysIgnoreCoreList = true;
				end
			end
		end
	end
	
	if (not skipAlwaysIgnoreCoreList and (BuffHead.Settings.AlwaysIgnore[name] or BuffHead.Settings.AlwaysIgnore[ability.abilityId])) then
		return false;
	end
	
	local skipAlwaysShowCoreList = false;
	if (settings) then
		local alwaysShowSettings = settings.AlwaysShow;
		
		if (alwaysShowSettings) then
			local show = (alwaysShowSettings[name] or alwaysShowSettings[ability.abilityId]);
			if (show ~= nil) then
				if (show) then
					return displayAlwaysShow;
				else
					skipAlwaysShowCoreList = true;
				end
			end
		end
	end
	
	if (not skipAlwaysShowCoreList and (BuffHead.Settings.AlwaysShow[name] or BuffHead.Settings.AlwaysShow[ability.abilityId])) then
		return displayAlwaysShow;
	end
		
	if (isFriendly or isGroup or isSelf) then
		local tracker = nil;
		if (self.IsAdvancedContainer) then
			tracker = self.Settings;
		elseif (isFriendly) then
			tracker = BuffHead.Settings.Trackers.Friendly;
		elseif (isGroup) then
			tracker = BuffHead.Settings.Trackers.Group;
		elseif (isSelf) then
			tracker = BuffHead.Settings.Trackers.Self;
		end
		
		if (tracker) then
			if (isBuff) then
				if (tracker.Buffs == BuffHead.BuffType.Friendly.All) then
					displayEffect = true;
				elseif (tracker.Buffs == BuffHead.BuffType.Friendly.CastByMe and ability.castByPlayer) then
					displayEffect = true;
				end
			elseif (isDebuff) then
				if (tracker.Debuffs == BuffHead.DebuffType.Friendly.All) then
					displayEffect = true;
				elseif (tracker.Debuffs == BuffHead.DebuffType.Friendly.CurableByMe and isDispellable) then
					displayEffect = true;
				end
			end
		end
	elseif (isHostile) then
		local tracker = nil;
		if (self.IsAdvancedContainer) then
			tracker = self.Settings;
		else
			tracker = BuffHead.Settings.Trackers.Hostile;
		end
		
		if (tracker) then
			if (isBuff) then
				if (tracker.Buffs == BuffHead.BuffType.Hostile.All) then
					displayEffect = true;
				elseif (tracker.Buffs == BuffHead.BuffType.Hostile.RemovableByMe and isDispellable) then
					displayEffect = true;
				end
			elseif (isDebuff) then
				if (tracker.Debuffs == BuffHead.DebuffType.Hostile.All) then
					displayEffect = true;
				elseif (tracker.Debuffs == BuffHead.DebuffType.Hostile.CastByMe and ability.castByPlayer) then
					displayEffect = true;
				end
			end
		end
	end
	
	if (displayEffect and ((not ability.permanentUntilDispelled and duration > 0) or (ability.permanentUntilDispelled and displayPermanent))) then
		return true;
	end
	
	return false;

end

local function SetLayer(frame)
	
	WindowSetLayer(frame:GetName(), frame.Settings.Layer);

end

local function CompareRefresh(refreshA, refreshB)

	if (refreshB == nil) then
		return false;
	end
	
	return refreshA.RefreshAt < refreshB.RefreshAt;
	
end

local function AddRefreshAt(self, index, refreshAt)
	
	if (self.RefreshEffects[index]) then return end

	if (not self.RefreshAt or refreshAt < self.RefreshAt) then
		self.RefreshAt = refreshAt;
	end
	
	local refreshEffect =
	{
		RefreshAt = refreshAt,
		Index = index,
	};
	
	refreshEffect.TreeNode = self.RefreshTree:Insert(refreshEffect);
	self.RefreshEffects[index] = refreshEffect;
	
end

local function RemoveRefreshAt(self, index)

	local refreshEffect = self.RefreshEffects[index];
	if (not refreshEffect) then return end
	
	self.RefreshTree:Remove(refreshEffect.TreeNode);
	self.RefreshEffects[index] = nil;

end

local function IsAbilityMatchingFrame(abilityData, effectFrame)

	-- In some cases, the index of an ability may be re-used, such as when a player is targeted, untargeted, 
	-- then targeted again when there buffs have changed (buffs got removed)
	
	if (abilityData.Data.abilityId ~= effectFrame.AbilityData.Data.abilityId or 
		abilityData.Data.castByPlayer ~= effectFrame.AbilityData.Data.castByPlayer) then
		
		return false;
	
	end
	
	return true;

end

local function ProcessAddedEffect(self, index, abilityData)
	--d("ProcessAddedEffect")
	if (not abilityData.Container) then return end
	local effectFrame = abilityData.Container.EffectFrames[index];

	if (IsAbilityValid(self, abilityData, self.TargetType)) then
		if (IsDurationWithinThreshold(abilityData, self.Settings.MaximumThreshold, self.Settings.MinimumThreshold)) then
			if (effectFrame and not IsAbilityMatchingFrame(abilityData, effectFrame)) then
				-- The added effect is actually a new one. Remove the old one, but keep the cache (the cache is the new effect)
				self:RemoveEffect(abilityData.Container, index, true);
				effectFrame = nil;
			end
				
			if (not effectFrame) then
				effectFrame = abilityData.Container:AddEffect(index, abilityData);
				self.ActiveFrames = self.ActiveFrames + 1;
			else
				abilityData.Container:UpdateEffect(index, abilityData);
			end
			
			self.LastUpdate = BuffHead.TimeCount;
			return;
		else
			--the ability is valid, but it's duration is too long
			local refreshAt = math.max((abilityData.Data.duration - (BuffHead.TimeCount - abilityData.TimeAdded)) - 
				(self.Settings.MaximumThreshold or BuffHead.Settings.MaximumThreshold), 0) + BuffHead.TimeCount + 1;
			AddRefreshAt(self, index, refreshAt);
		end
	end
	
	-- This frame has failed visibility, but it exists. Was probably a frame with a long duration that got refreshed
	if (effectFrame) then
		self:RemoveEffect(abilityData.Container, index, true);
	end
	--d("-- ProcessAddedEffect")	
end

local function ProcessRemovedEffect(self, index, abilityData)
        --d("ProcessRemovedEffect")
	-- Removes any future updates for this effect, if available
	RemoveRefreshAt(self, index);

	-- Passed without an ability, meaning the cache was used
	if (not abilityData) then
		abilityData = self.EffectsCache[index];
	end
	
	if (abilityData and abilityData.Container) then
		self:RemoveEffect(abilityData.Container, index, false);
	end
        --d("-- ProcessRemovedEffect")
end

function BuffHeadContainer.EnableCaching(enabled)
	cacheEffects = enabled;
end

function BuffHeadContainer:Create(containerId, targetType, worldObjectId, settings)
	--d("BuffHeadContainer:Create")
	--local frame = self:CreateFromTemplate("BuffHead" .. containerId, "Root");
	local frame = self:CreateFromTemplate("BuffHead" .. containerId, "RootFrame");

	frame.WorldObjectId = worldObjectId;
	frame.TargetType = targetType;
	frame.ActiveFrames = 0;
	frame.EffectsCache = {};
	frame.LastUpdate = BuffHead.TimeCount;
	frame.AttachedTo = nil;
	frame.Settings = settings or BuffHead.Settings;
	frame.IsAdvancedContainer = (settings ~= nil);
	frame:AttachTo(worldObjectId);
	
	if (settings) then
		if (settings.ScreenPosition == BuffHead.ScreenPosition.Fixed) then
			frame.IsFixed = true;
			frame:UpdateFixedPosition();
		end
	end
	
	frame.Containers = 
	{
		AlwaysShow = BuffHeadEffectContainer:Create("AlwaysShow", frame, frame.Settings.Containers.AlwaysShow, frame.Settings),
		Buffs = BuffHeadEffectContainer:Create("Buffs", frame, frame.Settings.Containers.Buffs, frame.Settings),
		Debuffs = BuffHeadEffectContainer:Create("Debuffs", frame, frame.Settings.Containers.Debuffs, frame.Settings),
	};
	
	frame.RefreshTree = BuffHead.RBTree:Create(CompareRefresh);
	frame.RefreshEffects = {};
	
	SetLayer(frame);
	frame:SetShowing(true);
	
	SetupDispelTable();
	--d("-- BuffHeadContainer:Create")	
	return frame;
end

function BuffHeadContainer:UpdateFixedPosition()
	--d("Container:UpdateFixedPosition")
	local settings = self.Settings;
	WindowClearAnchors(self:GetName());
	--WindowAddAnchor(self:GetName(), "topleft", "Root", "topleft", settings.Offset.X, settings.Offset.Y);
	WindowAddAnchor(self:GetName(), "topleft", "RootFrame", "topleft", settings.Offset.X, settings.Offset.Y);
	--d("-- Container:UpdateFixedPosition")
end

function BuffHeadContainer:SetShowing(isVisible)
	if (WindowGetShowing(self:GetName()) ~= isVisible) then
		WindowSetShowing(self:GetName(), isVisible);
	end
end

function BuffHeadContainer:AttachTo(objectId)

	if (self.AttachedTo) then
		DetachWindowFromWorldObject(self:GetName(), self.AttachedTo);
	end
	if (objectId) then
		AttachWindowToWorldObject(self:GetName(), objectId);
	end
	self.AttachedTo = objectId;

end

function BuffHeadContainer:AnchorContainer(placementType, anchorType, container)

	local rootAnchor = self:GetName();
	local alwaysShowAnchor = self.Containers.AlwaysShow:GetName();
	local buffsAnchor = self.Containers.Buffs:GetName();
	local debuffsAnchor = self.Containers.Debuffs:GetName();
	local padding = { X = 0, Y = 0 };
	local point, anchorTo, relativePoint, x, y;
	
	relativePoint = "topleft";
	x, y = 0, 0;
	
	if (placementType == BuffHead.Container.Placement.Fixed) then
		--point, anchorTo = "topleft", "Root";
		point, anchorTo = "topleft", "RootFrame";
		x, y = container.ContainerSettings.Offset.X, container.ContainerSettings.Offset.Y;
	else
		if (placementType == BuffHead.Container.Placement.After) then
			padding.X = self.Settings.Containers.Padding.X;
			point = "topright";
		else -- below
			padding.Y = self.Settings.Containers.Padding.Y;
			point = "bottomleft";
		end
		
		local parentSize = { Width = 0, Height = 0 };
		local parent = nil;
		
		if (anchorType == BuffHead.Container.Anchor.Anchor) then
			anchorTo = rootAnchor;
			point = "topleft"; -- if anchored to root, override positions
			padding = { X = 0, Y = 0 }; -- root has no padding
			if (self.IsAdvancedContainer and self.IsFixed) then
				x, y = 0, 0;
			else
				x, y = self.Settings.Offset.X, self.Settings.Offset.Y;
			end
		elseif (anchorType == BuffHead.Container.Anchor.AlwaysShow) then
			anchorTo = alwaysShowAnchor;
			parent = self.Containers.AlwaysShow;
		elseif (anchorType == BuffHead.Container.Anchor.Buffs) then
			anchorTo = buffsAnchor;
			parent = self.Containers.Buffs;
		else -- debuffs
			anchorTo = debuffsAnchor;
			parent = self.Containers.Debuffs;
		end
		
		if (placementType == BuffHead.Container.Placement.After) then
			if ((parent and parent.Size.Width == 0) or container.Size.Width == 0) then
				padding.X = 0;
			end
		elseif (placementType == BuffHead.Container.Placement.Below) then
			if ((parent and parent.Size.Height == 0) or container.Size.Height == 0) then
				padding.Y = 0;
			end
		end
	end
	
	--if (anchorTo == container:GetName()) then return end -- this can technically be removed, since if this passes, the setup would have caught it
	
	--WindowClearAnchors(container:GetName()); -- handled in caller
	WindowAddAnchor(container:GetName(), point, anchorTo, relativePoint, x + padding.X, y + padding.Y);	

	return padding;

end

local function GetSize(self, container)

	local size = { Width = 0, Height = 0 };
	local rows, columns = (container.ContainerSettings.Size.Rows or 1), (container.ContainerSettings.Size.Columns or 10);
	local effectIndex = container.VisibleEffects or 0;
	
	if (effectIndex > 0) then
		local settings = self.Settings;
		local columnIndex = (effectIndex - 1) % columns;
		local rowIndex = math.floor((effectIndex - 1) / columns);
		columns = math.min(effectIndex, columns);
		rows = math.min(rowIndex + 1, rows);
		local padding = 
		{ 
			X = settings.Indicators.Padding.X * math.max(columns - 1, 0), 
			Y = settings.Indicators.Padding.Y * math.max(rows - 1, 0) 
		};
		
		local layout = settings.Layout or BuffHead.Settings.Layout;
		
		size =
		{ 
			Width = (layout.Width * columns) + padding.X, 
			Height = (layout.Height * rows) + padding.Y
		};
	end
	
	return size;
end

local function ResizeContainers(self, container)

	local parentContainer = container.AnchoredTo;
	
	local placement = container.ContainerSettings.Placement;
	local containerSize = GetSize(self, container);
	
	if (parentContainer and container) then
		local parentSize = GetSize(self, parentContainer);
		
		if (placement == BuffHead.Container.Placement.After) then
			local height = math.max(containerSize.Height, parentSize.Height);
			container:SetSize(containerSize.Width, height);
			parentContainer:SetSize(parentSize.Width, height);
		else -- below
			container:SetSize(containerSize.Width, containerSize.Height);
			parentContainer:SetSize(parentSize.Width, parentSize.Height);
		end
	else
		container:SetSize(containerSize.Width, containerSize.Height);
	end

end

function BuffHeadContainer:GetContainerDimensions(container, width, height)

	if (not container) then
		return { Width = width or 0, Height = height or 0 };
	end

	width = width or container.Size.Width;
	height = height or container.Size.Height;
	
	local placement = container.ContainerSettings.Placement;

	container = container.AnchoredTo;
	
	if (container) then
		if (placement == BuffHead.Container.Placement.After) then
			width = width + container.Size.Width;
			if (container.Size.Height > height) then
				height = container.Size.Height;
			end
		else -- below
			height = height + container.Size.Height;
			if (container.Size.Width > width) then
				width = container.Size.Width;
			end
		end
	end
	
	return self:GetContainerDimensions(container, width, height);

end

local function GetBiggestDimension(newSize, oldSize)

	newSize.Width = math.max(oldSize.Width, newSize.Width);
	newSize.Height = math.max(oldSize.Height, newSize.Height);
	
	return newSize;

end

function BuffHeadContainer:AnchorContainers()

	local containerSettings = self.Settings.Containers;
	local containers = self.Containers;
	local anchorsDirty = false;
	
	if (self.SettingsRevision ~= BuffHead.ContainerRevision) then
		self.SettingsRevision = BuffHead.ContainerRevision;
		anchorsDirty = true;
	elseif (self.AnchorsDirty) then
		anchorsDirty = self.AnchorsDirty;
		self.AnchorsDirty = nil;
	end

	if (anchorsDirty) then
		local toContainer = 
		{
			[BuffHead.Container.Anchor.Anchor] = nil,
			[BuffHead.Container.Anchor.AlwaysShow] = containers.AlwaysShow,
			[BuffHead.Container.Anchor.Buffs] = containers.Buffs,
			[BuffHead.Container.Anchor.Debuffs] = containers.Debuffs,
		};

		local padding = { X = 0, Y = 0 };
		local containerPadding = nil;
		
		if (not containers.AlwaysShow.IsFixed) then
			WindowClearAnchors(containers.AlwaysShow:GetName());
			containerPadding = self:AnchorContainer(containerSettings.AlwaysShow.Placement, containerSettings.AlwaysShow.Anchor, containers.AlwaysShow);
			containers.AlwaysShow.AnchoredTo = toContainer[containerSettings.AlwaysShow.Anchor];
			if (containerPadding) then
				padding.X, padding.Y = padding.X + containerPadding.X, padding.Y + containerPadding.Y;
			end
		end
		
		if (not containers.Buffs.IsFixed) then
			WindowClearAnchors(containers.Buffs:GetName());
			containerPadding = self:AnchorContainer(containerSettings.Buffs.Placement, containerSettings.Buffs.Anchor, containers.Buffs);
			containers.Buffs.AnchoredTo = toContainer[containerSettings.Buffs.Anchor];
			if (containerPadding) then
				padding.X, padding.Y = padding.X + containerPadding.X, padding.Y + containerPadding.Y;
			end
		end
		
		if (not containers.Debuffs.IsFixed) then
			WindowClearAnchors(containers.Debuffs:GetName());
			containerPadding = self:AnchorContainer(containerSettings.Debuffs.Placement, containerSettings.Debuffs.Anchor, containers.Debuffs);
			containers.Debuffs.AnchoredTo = toContainer[containerSettings.Debuffs.Anchor];
			if (containerPadding) then
				padding.X, padding.Y = padding.X + containerPadding.X, padding.Y + containerPadding.Y;
			end
		end
		self.ContainerPadding = padding;
	end

	if (not containers.AlwaysShow.IsFixed) then
		ResizeContainers(self, self.Containers.AlwaysShow);
	end
	if (not containers.Buffs.IsFixed) then
		ResizeContainers(self, self.Containers.Buffs);
	end
	if (not containers.Debuffs.IsFixed) then
		ResizeContainers(self, self.Containers.Debuffs);
	end
			
	if (self.Scale ~= self.Settings.Scale) then
		self.Scale = self.Settings.Scale;
		WindowSetScale(self:GetName(), self.Settings.Scale * InterfaceCore.GetScale());
	end

	local size = { Width = 0, Height = 0 };
	if (not containers.AlwaysShow.IsFixed) then
		size = GetBiggestDimension(self:GetContainerDimensions(self.Containers.AlwaysShow), size);
	end
	if (not containers.Buffs.IsFixed) then
		size = GetBiggestDimension(self:GetContainerDimensions(self.Containers.Buffs), size);
	end
	if (not containers.Debuffs.IsFixed) then
		size = GetBiggestDimension(self:GetContainerDimensions(self.Containers.Debuffs), size);
	end
	
	if (not self.IsFixed) then
		-- the only purpose of resizing the actual container is to re-center it when attached
		self:SetDimensions(size.Width + self.ContainerPadding.X, size.Height + self.ContainerPadding.Y);
		self:AttachTo(self.WorldObjectId);
	end

end

function BuffHeadContainer:AnchorEffects()
        --d("AnchorEffects")
	local alwaysShow = self.Containers.AlwaysShow;
	local buffs = self.Containers.Buffs;
	local debuffs = self.Containers.Debuffs;
	
	local sizeChanged = false;
	local anchorsDirty = (alwaysShow.AnchorsDirty or buffs.AnchorsDirty or debuffs.AnchorsDirty)
	
	-- don't update when an update is queued
	if (anchorsDirty) then
		local containerDirty = false;
		local alwaysShowEmpty, buffEmpty, debuffEmpty = alwaysShow.VisibleEffects == 0, buffs.VisibleEffects == 0, debuffs.VisibleEffects == 0;
		
		sizeChanged = alwaysShow:AnchorEffects(true) or sizeChanged;
		sizeChanged = buffs:AnchorEffects(true) or sizeChanged;
		sizeChanged = debuffs:AnchorEffects(true) or sizeChanged;
		
		if ((alwaysShowEmpty and alwaysShow.VisibleEffects ~= 0) or
			(buffEmpty and buffs.VisibleEffects ~= 0) or
			(debuffEmpty and debuffs.VisibleEffects ~= 0)) then
			-- a container was empty, and now it's not
			self.AnchorsDirty = true;
		end
	
		-- To prevent stuttering (indicator will be shown in one place then snaped into the proper place the next), when the size of the container
		-- changes, containers will be re-anchored on the next update.
		if (sizeChanged) then
			self:AnchorContainers();
			self.AnchorContainersOnNextUpdate = 1;
		elseif (self.AnchorContainersOnNextUpdate == nil) then -- if there is no pending update
			alwaysShow:AnchorEffects(false);
			buffs:AnchorEffects(false);
			debuffs:AnchorEffects(false);
		end
	end
        --d("-- AnchorEffects")
end


function BuffHeadContainer:Destroy() --SCarfaXX
	--d("Destroy container")
	self:ClearAllEffects();
	self:AttachTo(nil);
	for index, container in pairs(self.Containers) do
		--d("destroy container")
		--d(index)
		--BuffHead.RecheckFrames();
		container:Destroy();
		--d("- destroy container")
	end
	FrameManager:Remove(self:GetName());
	DestroyWindow(self:GetName());
end

function BuffHeadContainer:IsInactive()
        --d("Container:IsInactive")
	if (self.ActiveFrames == 0 and BuffHead.TimeCount - self.LastUpdate > INACTIVE_TIMEOUT) then
		return true;
	end
        --d("- Container:IsInactive")
	return false;

end

function BuffHeadContainer:RemoveEffect(container, index, keepCache)

	local effectFrame = nil;
	if (not container and self.EffectsCache[index]) then                                                                                                                         
		container = self.EffectsCache[index].Container;
	end
	if (container) then
		effectFrame = container.EffectFrames[index];
	end
	
	-- If a frame exists, remove the frame from the container
	if (effectFrame) then
		--d("remove effect index")
		container:RemoveEffect(index);
		self.ActiveFrames = self.ActiveFrames - 1;
		--d("- remove effect index")
	end
	
	if (not keepCache) then
		self.EffectsCache[index] = nil;
	end

end

function BuffHeadContainer:Refresh()
        --d("Container:Refresh")
	if (self.RefreshAt and BuffHead.TimeCount > self.RefreshAt) then
		self.RefreshAt = nil;
		
		local refreshEffects = self.RefreshTree:GetValues();

		for index, refreshEffect in ipairs(refreshEffects) do
			if (BuffHead.TimeCount < refreshEffect.RefreshAt) then
				self.RefreshAt = refreshEffect.RefreshAt;
				break;
			else
				RemoveRefreshAt(self, refreshEffect.Index);
				local abilityData = self.EffectsCache[refreshEffect.Index];
				if (abilityData) then
					ProcessAddedEffect(self, refreshEffect.Index, abilityData);
				end
			end
		end
	end
	
	self:UpdateDurations();
        --d("- Container:Refresh")
end

function BuffHeadContainer:Update(elapsed, refresh)
	--d("Container:Update")
	if (refresh == true) then
		self:Refresh();
	end

	self.Containers.AlwaysShow:Update(elapsed);
	self.Containers.Buffs:Update(elapsed);
	self.Containers.Debuffs:Update(elapsed);

	if (self.AnchorContainersOnNextUpdate ~= nil) then		
		if (self.AnchorContainersOnNextUpdate == 1) then
			self.AnchorContainersOnNextUpdate = nil;
			self.Containers.AlwaysShow:AnchorEffects(false);
			self.Containers.Buffs:AnchorEffects(false);
			self.Containers.Debuffs:AnchorEffects(false);
		else
			self.AnchorContainersOnNextUpdate = self.AnchorContainersOnNextUpdate - 1;
		end
	end

	if (BuffHead.Settings.Performance.EffectAnchoring == BuffHead.EffectAnchoring.OnUpdate or self.AnchorEffectsOnNextUpdate) then
		self.AnchorEffectsOnNextUpdate = nil;
		self:AnchorEffects();
	end
	--d("- Container:Update")	
end

function BuffHeadContainer:UpdateDurations()
	--d("Container:UpdateDurations")
	self.Containers.AlwaysShow:UpdateDurations();
	self.Containers.Buffs:UpdateDurations();
	self.Containers.Debuffs:UpdateDurations();

	if (BuffHead.Settings.Performance.EffectAnchoring == BuffHead.EffectAnchoring.OnGeneralUpdate) then
		self.AnchorEffectsOnNextUpdate = true;
	end
	--d("- Container:UpdateDurations")
end

function BuffHeadContainer:ClearAllEffects()
        --d("container clear all efffects")
	self.Containers.AlwaysShow:ClearAllEffects();
	self.Containers.Buffs:ClearAllEffects();
	self.Containers.Debuffs:ClearAllEffects();

	self.EffectsCache = {};
	self.ActiveFrames = 0;
	self.RefreshAt = nil;
	self.RefreshEffects = {};
	self.RefreshTree:Clear();
	self.EffectsCache = {};
        --d("- container clear all efffects")
end

function BuffHeadContainer:GetContainerFromData(abilityData)
	
	if (not abilityData) then
		return nil;
	end
	
	local effectType = abilityData.Type;
	local name = tostring(abilityData.Data.name:match(L"([a-zA-Z,'! ]+)"));

	if (BuffHead.Settings.AlwaysShow[name] or BuffHead.Settings.AlwaysShow[abilityData.Data.abilityId]) then
		return self.Containers.AlwaysShow;
	else
		local settings = nil;
		
		if (not self.IsAdvancedContainer) then
			settings = GetSettingsForType(self.TargetType);
		else
			settings = self.Settings;
		end
		
		if (settings and settings.AlwaysShow and (settings.AlwaysShow[name] or settings.AlwaysShow[abilityData.Data.abilityId])) then
			return self.Containers.AlwaysShow;
		end
	end
	
	if (effectType == EffectType.Buff) then
		return self.Containers.Buffs;
	elseif (effectType == EffectType.Debuff) then
		return self.Containers.Debuffs;
	end
	
end

-- adds effects directly into containers without any checks, used by the demo
function BuffHeadContainer:AddEffects(effects, effectType, containerType)
	for index, data in pairs(effects) do
		data.color = GetEffectColor(data);
		local abilityData =  
		{ 
			Data = data, 
			TimeAdded = BuffHead.TimeCount, 
			Type = effectType,
		};
		
		local container = nil;
		if (containerType == BuffHeadContainer.ContainerType.Buff) then
			container = self.Containers.Buffs
		elseif (containerType == BuffHeadContainer.ContainerType.Debuff) then
			container = self.Containers.Debuffs;
		elseif (containerType == BuffHeadContainer.ContainerType.AlwaysShow) then
			container = self.Containers.AlwaysShow;
		end
		
		if (container) then
			abilityData.Container = container;
			self.EffectsCache[index] = abilityData;
			abilityData.Container:AddEffect(index, abilityData);
			self.ActiveFrames = self.ActiveFrames + 1;
		end
	end
			
end

function BuffHeadContainer:UpdateEffects(effects, isFullList)
	--d("Container:UpdateEffects")
	if (effects == nil) then return end
	
	local oldEffectsCache = self.EffectsCache;
	if (isFullList) then
		self.RefreshAt = nil;
		self.RefreshEffects = {};
		self.RefreshTree:Clear();
		self.EffectsCache = {};
	end
	
	for index, data in pairs(effects) do
	        --d("update effects in buffheadcontainer")
		if (isFullList) then
			oldEffectsCache[index] = nil;
		else
			if (not data.abilityId) then
				ProcessRemovedEffect(self, index);
			end
		end
	
		if (data.abilityId) then
			if (cacheEffects) then
				BuffHead.Setup.EffectCache.Cache(data);
			end
	
			local abilityData =  
			{ 
				Data = CopyAbilityData(data), 
				TimeAdded = BuffHead.TimeCount, 
				Type = GetEffectType(data, self.TargetType),
				IsDispellable = IsDispellable(data, self.TargetType),
			};
			abilityData.Container = self:GetContainerFromData(abilityData);
			self.EffectsCache[index] = abilityData;
			
			ProcessAddedEffect(self, index, abilityData);
		end
	
	end
	
	if (isFullList and oldEffectsCache) then
		-- Remaining effects have been lost. This will occur when a player is retargeted
		for index, abilityData in pairs(oldEffectsCache) do
			ProcessRemovedEffect(self, index, abilityData);
		end
		oldEffectsCache = nil;
	end
	
	self.LastUpdate = BuffHead.TimeCount;
	--d("- Container:UpdateEffects")	
end

function BuffHeadContainer:IsStuck()

	local x, y = WindowGetScreenPosition(self:GetName());
	local distance = 0;
	
	-- we don't care about distance if the timeout has already been specified
	if (self.LastX and not self.StuckTimeout) then
		distance = math.sqrt(math.pow(BuffHead.Location.X - self.LastX, 2) + math.pow(BuffHead.Location.Y - self.LastY, 2));
	end
	
	--make sure the window is visible, since an offscreen objects will always have the same position
	if (self.LastX and WindowGetShowing(self:GetName()) and (self.StuckTimeout or distance > DISTANCE_THRESHOLD) and x == self.LastScreenX and y == self.LastScreenY) then
		if (not self.StuckTimeout) then
			self.StuckTimeout = BuffHead.TimeCount + STUCK_TIMEOUT;
		end
		if (BuffHead.TimeCount > self.StuckTimeout) then
			return true;
		end	
	else
		self.StuckTimeout = nil;
	end
	
	self.LastX = BuffHead.Location.X;
	self.LastY = BuffHead.Location.Y;
	self.LastScreenX = x;
	self.LastScreenY = y;
	
	return false;

end