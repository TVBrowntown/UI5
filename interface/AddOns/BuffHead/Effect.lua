BuffHeadEffect = {};
BuffHeadEffect.__index = BuffHeadEffect;

local EffectType = { Buff = 1, Debuff = 2 };
local StatusBarType = { Horizontal = 1, Vertical = 2 };
local FADING_START_AT = 2;
local effectCount = 0;

local function GetAbilityDuration(abilityData, sync)

	local duration = abilityData.Data.duration - (BuffHead.TimeCount - abilityData.TimeAdded);
	
	if (BuffHead.Settings.Sync.Enable and sync and BuffHead.Sync.Delay) then
		duration = duration + ((BuffHead.TimeCount - abilityData.TimeAdded) * BuffHead.Sync.Delay)
	end

	return math.max(duration, 0);

end

function BuffHeadEffect:Create(parent, abilityIndex, abilityData)
	
	local effect = setmetatable({}, self);
	effect.__index = effect;
	
	effect.Parent = parent;
	effect.AbilityData = { Data = abilityData.Data, TimeAdded = abilityData.TimeAdded, Index = abilityIndex, Type = abilityData.Type };
	effect.Frame = nil;

	effect:Update(abilityData);
	
	return effect;
	
end

function BuffHeadEffect:SetFrame(frame)

	if (self.Frame) then
		--d("Frame destroy setframe")
		self.Frame:Destroy();
	end
	
	self.Frame = frame;

end

function BuffHeadEffect:ReleaseFrame()
        --d("effect:releaseFrame")
	--BuffHeadContainer:CheckExist();
	if (self.Frame) then
		--d("release frame destroy")
		self.Frame:Destroy();
		self.Frame = nil;
		
	else 
		--d("no self.Frame")
	end
end

function BuffHeadEffect:Destroy()
        --d("buffhead effect destroy")
	self:ReleaseFrame();

end

function BuffHeadEffect:ForceCreate()

	if (not self.Frame) then
		self.Frame = BuffHeadEffectFrame:Create(self.Parent, self, self.Parent.Settings.HandleRemovable or self.Parent.Settings.ShowTooltips);
		self.UpdateOnShow = true;
	end

end

function BuffHeadEffect:SetShowing(showing)
        --d("set showing")
	if (showing and (not self.Frame or self.UpdateOnShow)) then
		self.UpdateOnShow = nil;
		if (not self.Frame) then
			self.Frame = BuffHeadEffectFrame:Create(self.Parent, self, self.Parent.Settings.HandleRemovable or self.Parent.Settings.ShowTooltips);
		end
		if (self.AnchorOnShow) then
			local anchor = self.AnchorOnShow;
			self.AnchorOnShow = nil;
			self.Frame:AnchorTo(anchor.AnchorFrame, anchor.PointOnAnchor, anchor.PointOnSelf, anchor.X, anchor.Y);
		end
		self:UpdateLabels();
		self:UpdateFading();
	end
	--d("- set showing")
	if (self.Frame) then
		--d("effect set showing")
		self.Frame:SetShowing(showing);
	end
	
end

function BuffHeadEffect:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)
	--d("Effect:AnchorTo")
	if (self.Frame) then
		self.Frame:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset);
	else
		self.AnchorOnShow = { AnchorFrame = anchorFrame, PointOnAnchor = pointOnAnchor, PointOnSelf = pointOnSelf, X = xOffset, Y = yOffset };
	end

end

function BuffHeadEffect:UpdateFading()

	if (not self.Frame) then return end
	
	if (self.Fading) then
		local timeLeft = GetAbilityDuration(self.AbilityData);
		if (timeLeft > self.Fading.TimeLeft + 0.5) then
			self.Fading = nil;
			self.Frame:ResetAlpha();
		end
	end

end

function BuffHeadEffect:Update(abilityData)
        --d("effect:update")
	if (BuffHead.Settings.Sync.Enable and abilityData.TimeAdded ~= self.AbilityData.TimeAdded) then
		local timeDifference = abilityData.TimeAdded - self.AbilityData.TimeAdded;
		local durationDifference = GetAbilityDuration(abilityData, false) - GetAbilityDuration(self.AbilityData, false);
		local delayTime = durationDifference / timeDifference;
		BuffHead.UpdateSyncTime(delayTime);
	end

	self.AbilityData.Data = abilityData.Data;
	self.AbilityData.Duration = abilityData.Data.duration;
	self.AbilityData.TimeAdded = abilityData.TimeAdded;
	local ability = abilityData.Data;
	
	if (self.Frame) then
	
		if (not self.CompressionCount) then
			self.Frame:SetStackCount(ability.stackCount);
		end
		
		self:UpdateFading();
		
	end
	
	--self:UpdateDuration(true);

end

function BuffHeadEffect:SetCompression(compression)
	
	local stackCount = 0;

	if (compression ~= nil and compression > 1) then
		stackCount = compression;
	else
		local ability = self.AbilityData.Data;
		stackCount = ability.stackCount or 0;
		compression = nil;
	end
	
	self.CompressionCount = compression;

	if (self.Frame) then
		self.Frame:SetStackCount(stackCount);
	end

end

function BuffHeadEffect:GetDuration()
        --d(self.AbilityData)
	return GetAbilityDuration(self.AbilityData);
	
end

function BuffHeadEffect:UpdateLabels()
	--d("update labels")
	if (not self.Frame) then return end
	
	self:UpdateDuration(true);
	self:SetCompression(self.CompressionCount);
	--d("- update labels")
	
end

function BuffHeadEffect:UpdateDuration(force)
        
	if (not self.AbilityData) then return end
	if (self.AbilityData.Data.permanentUntilDispelled) then return end

	--d("force update duration")
	local timeLeft = GetAbilityDuration(self.AbilityData);
	local isShowing = false;
	
	if (self.Frame) then
		--d("isShowing")
		isShowing = self.Frame:IsShowing();
	end
	
	if (timeLeft == 0) then
		self.Parent.Parent:RemoveEffect(self.Parent, self.AbilityData.Index);
		return;
	end
		
	if (not isShowing) then
		if (not force) then
			return;
		end
	end
	
	if (self.Frame) then
		if (timeLeft < FADING_START_AT and BuffHead.Settings.Fading.Enable) then
			if (not self.Fading) then
				self.Fading = { TimeLeft = timeLeft };
				self.Frame:FadeOut(timeLeft);
			end
		end
		
		if (BuffHead.Settings.Performance.MaximumUpdates == 0 or force) then -- update directly
			self.Frame:SetDuration(timeLeft);
		else
			self.Parent.Queue.Update:Add(self.AbilityData.Index, { Frame = self.Frame, Duration = timeLeft });
		end
	end

end