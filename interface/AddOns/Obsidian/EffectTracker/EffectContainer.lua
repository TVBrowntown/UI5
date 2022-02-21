Obsidian.EffectContainer = Frame:Subclass("ObsidianEffectContainerTemplate");
Obsidian.EffectContainer.Position = { TopLeft = 1, TopRight = 2, BottomLeft = 3, BottomRight = 4, FreeUp = 5, FreeDown = 6 };
Obsidian.EffectContainer.EffectType = { Buff = 1, Debuff = 2 };

--[[
	Note: A majority of this code is from BuffHead2 and as such, some of it is not needed since
	effects are not actually tracked. For example, though it is a safety, buff checking is not needed
	since effects are automatically cleared and reshown on target.
--]]

local EffectType = Obsidian.EffectContainer.EffectType;

local function CopyTable(dataTable)

	local copiedTable = {};

	for k,v in pairs(dataTable) do
		copiedTable[k] = v;
	end
	
	return copiedTable;

end

local function CompareEffects(effectA, effectB)

	if (effectB == nil) then
		return false;
	end
	
	local abilityA = effectA.AbilityData.Data;
	local abilityB = effectB.AbilityData.Data;
	
	if (abilityA.permanentUntilDispelled == abilityB.permanentUntilDispelled) then
		local durationA = abilityA.duration - (Obsidian.SystemTime - effectA.AbilityData.TimeAdded);
		local durationB = abilityB.duration - (Obsidian.SystemTime - effectB.AbilityData.TimeAdded);
	
		return durationA < durationB;
	else
		return (abilityA.permanentUntilDispelled == true);
	end
	
end

local function IsFriendly(targetType)
	return (targetType == Obsidian.TargetType.Friendly);
end

local function IsHostile(targetType)
	return (targetType == Obsidian.TargetType.Hostile);
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
			else return EffectType.Debuff;
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
			else return EffectType.Debuff;
			end
		end
	end
end

local function IsDurationWithinThreshold(self, abilityData)

	local ability = abilityData.Data;
	local timeAdded = abilityData.TimeAdded;
	local duration = math.max(ability.duration - (Obsidian.SystemTime - timeAdded), 0);
	
	return (duration < Obsidian.Settings.EffectTracker.General.MaximumThreshold);

end

local function IsAbilityValid(self, abilityData)

	local settings = self.Settings;
	local ability = abilityData.Data;
	local timeAdded = abilityData.TimeAdded;

	local duration = math.max(ability.duration - (Obsidian.SystemTime - timeAdded), 0);

	local effectType = abilityData.Type;
	local isBuff = (effectType == EffectType.Buff);
	local isDebuff = (effectType == EffectType.Debuff);
	
	local displayEffect = false;
	if (ability.castByPlayer and not ability.permanentUntilDispelled and duration > 0) then
		if ((isBuff and settings.ShowBuffs) or (isDebuff and settings.ShowDebuffs)) then
			displayEffect = true;
		end
	end
	
	return displayEffect;

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

local function IsAbilityMatchingFrame(abilityData, effect)

	-- In some cases, the index of an ability may be re-used, such as when a player is targeted, untargeted, 
	-- then targeted again when there buffs have changed (buffs got removed)
	
	if (abilityData.Data.abilityId ~= effect.AbilityData.Data.abilityId or 
		abilityData.Data.castByPlayer ~= effect.AbilityData.Data.castByPlayer) then
		
		return false;
	
	end
	
	return true;

end

local function AddEffect(self, index, abilityData)

	if (self.Effects[index]) then
		return; -- error, unique index failed
	end
	
	local effect = { Index = index, AbilityData = abilityData };
	self.Effects[index] = effect;
	effect.TreeNode = self.SortTree:Insert(effect);
	
	self.EffectsDirty = true;
	
	return effect;

end

local function UpdateEffect(self, index, abilityData)

	local effect = self.Effects[index];

	if (effect) then
		effect.AbilityData = abilityData;

		self.SortTree:Remove(effect.TreeNode);
		effect.TreeNode = self.SortTree:Insert(effect);
		self.EffectsDirty = true;
	end
				
end

local function RemoveEffect(self, index)

	local effect = self.Effects[index];
	if (not effect) then
		return;
	end
	
	self.SortTree:Remove(effect.TreeNode);
	self.Effects[index] = nil;
	
	if (self.ActiveEffects and self.ActiveEffects[index]) then
		self.EffectsDirty = true;
	end

end

local function ProcessAddedEffect(self, index, abilityData)

	local effect = self.Effects[index];

	if (IsAbilityValid(self, abilityData)) then
		if (IsDurationWithinThreshold(self, abilityData)) then
			if (effect and not IsAbilityMatchingFrame(abilityData, effect)) then
				-- The added effect is actually a new one. Remove the old one, but keep the cache (the cache is the new effect)
				self:RemoveEffect(index, true);
				effect = nil;
			end
				
			if (not effect) then
				effect = AddEffect(self, index, abilityData);
			else
				UpdateEffect(self, index, abilityData);
			end
			return;
		else
			--the ability is valid, but it's duration is too long
			local refreshAt = math.max((abilityData.Data.duration - (Obsidian.SystemTime - abilityData.TimeAdded)) - Obsidian.Settings.EffectTracker.General.MaximumThreshold, 0) + Obsidian.SystemTime + 1;
			AddRefreshAt(self, index, refreshAt);
		end
	end
	
	-- This frame has failed visibility, but it exists. Was probably a frame with a long duration that got refreshed
	if (effect) then
		self:RemoveEffect(index, true);
	end
	
end

local function ProcessRemovedEffect(self, index, abilityData)

	-- Removes any future updates for this effect, if available
	RemoveRefreshAt(self, index);

	-- Passed without an ability, meaning the cache was used
	if (not abilityData) then
		abilityData = self.EffectsCache[index];
	end
	
	if (abilityData) then
		self:RemoveEffect(index, false);
	end

end

local function UpdateEffectFrames(self)
	if (not self.EffectsDirty) then return end
	self.EffectsDirty = false;
	self.ActiveEffects = {};
	
	local effectsList = self.SortTree:GetValues(self.Settings.MaximumEffects);
	
	for index, effectFrame in ipairs(self.EffectFrames) do
		local effect = effectsList[index];
		if (effect) then
			effectFrame:ShowEffect(effect.AbilityData);
			effect.Frame = effectFrame;
			self.ActiveEffects[effect.Index] = effect;
		else
			effectFrame:Hide(true);
		end
	end
end

function Obsidian.EffectContainer:SetLayout()
	local settings = self.Settings;
	local generalSettings = Obsidian.Settings.EffectTracker.General;
	local scale = WindowGetScale(self:GetName());
	
	if (#self.EffectFrames < self.Settings.MaximumEffects) then
		for index = #self.EffectFrames + 1, self.Settings.MaximumEffects do
			self.EffectFrames[index] = Obsidian.EffectBar:Create(self, self:GetName() .. "Effect" .. index, self.Settings);
			self.EffectFrames[index]:SetScale(scale);
		end
	end
	
	WindowSetDimensions(self:GetName(), generalSettings.Size.Width, (generalSettings.Size.Height + generalSettings.Spacing) * self.Settings.MaximumEffects);
	
	for index, effectFrame in ipairs(self.EffectFrames) do
		effectFrame:SetLayout();
		
		-- anchored to the top, grow up, or anchored to the bottom, grown down
		if (settings.Position  == Obsidian.EffectContainer.Position.TopLeft or settings.Position  == Obsidian.EffectContainer.Position.TopRight or 
			settings.Position == Obsidian.EffectContainer.Position.FreeUp) then
			
			if (index == 1) then
				effectFrame:AnchorTo(self:GetName(), "bottomleft", "bottomleft", 0, 0);
			else
				effectFrame:AnchorTo(self.EffectFrames[index - 1]:GetName(), "topleft", "bottomleft", 0, -generalSettings.Spacing);
			end
		else
			if (index == 1) then
				effectFrame:AnchorTo(self:GetName(), "topleft", "topleft", 0, 0);
			else
				effectFrame:AnchorTo(self.EffectFrames[index - 1]:GetName(), "bottomleft", "topleft", 0, generalSettings.Spacing);
			end
		end
	end
end

function Obsidian.EffectContainer:SetScale(scale)
	WindowSetScale(self:GetName(), scale);
	for index, effectFrame in ipairs(self.EffectFrames) do
		effectFrame:SetScale(scale);
	end
end

function Obsidian.EffectContainer:Create(name, targetType, settings)
	local frame = self:CreateFromTemplate(name, "Root");

	frame.TargetType = targetType;
	frame.EffectsCache = {};
	frame.Effects = {};
	frame.EffectFrames = {};
	frame.ActiveEffects = {};
	frame.HasEffects = false;
	frame.Settings = settings;
	
	frame.SortTree = Obsidian.RBTree:Create(CompareEffects);
	
	frame.RefreshTree = Obsidian.RBTree:Create(CompareRefresh);
	frame.RefreshEffects = {};
	
	frame:SetShowing(true);
	
	return frame;
end

function Obsidian.EffectContainer:RegisterLayoutEditor()
	if (self.isLayoutEditorRegistered) then return end
	LayoutEditor.RegisterWindow(self:GetName(), towstring(self:GetName()), "", false, false, false, nil);
	self.isLayoutEditorRegistered = true;
end

function Obsidian.EffectContainer:UnregisterLayoutEditor()
	if (not self.isLayoutEditorRegistered) then return end
	LayoutEditor.UnregisterWindow(self:GetName());
	self.isLayoutEditorRegistered = nil;
end

function Obsidian.EffectContainer:SetShowing(isVisible)
	self:Show(isVisible);
end

function Obsidian.EffectContainer:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)
	WindowClearAnchors(self:GetName());
	WindowAddAnchor(self:GetName(), pointOnAnchor, anchorFrame, pointOnSelf, xOffset, yOffset);
end

function Obsidian.EffectContainer:RemoveEffect(index, keepCache)

	local effect = self.Effects[index];
	
	if (effect) then
		RemoveEffect(self, index);
	end
	
	if (not keepCache) then
		self.EffectsCache[index] = nil;
	end

end

function Obsidian.EffectContainer:Update(elapsed)

	if (not self.HasEffects) then return end

	if (self.RefreshAt and Obsidian.SystemTime > self.RefreshAt) then
		self.RefreshAt = nil;
		
		local refreshEffects = self.RefreshTree:GetValues();

		for index, refreshEffect in ipairs(refreshEffects) do
			if (Obsidian.SystemTime < refreshEffect.RefreshAt) then
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

	UpdateEffectFrames(self);

	for index, effect in pairs(self.ActiveEffects) do
		local effectFrame = effect.Frame;
		if (effectFrame) then
			effectFrame:Update(elapsed);
		end
	end
	
end

function Obsidian.EffectContainer:UpdateDurations()

	local elapsed = (Obsidian.SystemTime - self.LastUpdate);
	self.LastUpdate = Obsidian.SystemTime;

	for index, effect in pairs(self.ActiveEffects) do
		local effectFrame = effect.Frame;
		if (effectFrame) then
			effectFrame:Update(elapsed);
		end
	end

end

function Obsidian.EffectContainer:ClearAllEffects()

	if (not self.HasEffects) then return end
	self.HasEffects = false;

	for index, effect in pairs(self.ActiveEffects) do
		local effectFrame = effect.Frame;
		if (effectFrame) then
			effectFrame:Hide(true);
		end
	end

	self.EffectsDirty = false;
	self.ActiveEffects = {};
	self.Effects = {};
	self.RefreshAt = nil;
	self.RefreshEffects = {};
	self.RefreshTree:Clear();
	self.SortTree:Clear();
	self.EffectsCache = {};

end

function Obsidian.EffectContainer:UpdateEffects(effects, isFullList)
	if (effects == nil) then return end
	self.HasEffects = true;
	
	local oldEffectsCache = self.EffectsCache;
	if (isFullList) then
		self.RefreshAt = nil;
		self.RefreshEffects = {};
		self.RefreshTree:Clear();
		self.EffectsCache = {};
	end
	
	for index, data in pairs(effects) do
	
		if (isFullList) then
			oldEffectsCache[index] = nil;
		else
			if (not data.abilityId) then
				ProcessRemovedEffect(self, index);
			end
		end
	
		if (data.abilityId) then
			local abilityData =  
			{ 
				Data = CopyTable(data), 
				TimeAdded = Obsidian.SystemTime, 
				Type = GetEffectType(data, self.TargetType),
				Index = index,
			};
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
	
end