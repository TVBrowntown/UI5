BuffHeadEffectContainer = Frame:Subclass("BuffHeadContainerTemplate");

local tableRemove = table.remove;
local tableInsert = table.insert;

local ADVANCED_COMPRESSION_START_ID = 50000; -- abilityId to start from, to use with advanced compression

local WindowSetDimensions, WindowClearAnchors, WindowAddAnchor = WindowSetDimensions, WindowClearAnchors, WindowAddAnchor;

local function CompareEffects(effectA, effectB)

	if (effectB == nil) then
		return false;
	end
	
	local abilityA = effectA.AbilityData.Data;
	local abilityB = effectB.AbilityData.Data;
	
	if (abilityA.priority == abilityB.priority or not BuffHead.Settings.PriorityEffects.SortToFront) then
		if (abilityA.permanentUntilDispelled == abilityB.permanentUntilDispelled) then
		
			if (BuffHead.Settings.Sorting.Type == BuffHead.Sorting.Type.Duration) then
				local durationA = abilityA.duration - (BuffHead.TimeCount - effectA.AbilityData.TimeAdded);
				local durationB = abilityB.duration - (BuffHead.TimeCount - effectB.AbilityData.TimeAdded);
				if (BuffHead.Settings.Sorting.Direction == BuffHead.Sorting.Direction.Ascending) then
					return durationA < durationB;
				else
					return durationA > durationB;
				end
			elseif (BuffHead.Settings.Sorting.Type == BuffHead.Sorting.Type.Ability) then
				if (BuffHead.Settings.Sorting.Direction == BuffHead.Sorting.Direction.Ascending) then
					return abilityA.abilityId < abilityB.abilityId;
				else
					return abilityA.abilityId > abilityB.abilityId;
				end
			end
		else
			return (abilityA.permanentUntilDispelled == true);
		end
	else
		if (abilityA.priority and abilityB.priority) then
			return (abilityA.priority < abilityB.priority);
		else
			return (abilityA.priority ~= nil);
		end
	end
	
end

local function TransferFrameControl(self, oldEffect, newEffect)

	-- give the old frame to the new one if applicable
	if (oldEffect.Frame) then
		newEffect:SetFrame(oldEffect.Frame);
		
		-- for advanced compression when the abilities do not match
		if (newEffect.AbilityData.Data.abilityId ~= oldEffect.AbilityData.abilityId) then
			oldEffect.Frame:SetLayout(newEffect.AbilityData);
		end
		
		oldEffect.Frame:ResetAlpha();
		newEffect:UpdateFading(); -- update the fading effect for the frame to use this effect's duration
		
		-- if the old frame was a registered anchor, register the new frame as an anchor
		if (self.Anchors[oldEffect.AbilityData.Index]) then
			self.Anchors[oldEffect.AbilityData.Index] = nil;
			self.Anchors[newEffect.AbilityData.Index] = newEffect;
		end
		
		oldEffect.Frame = nil;
	end
	
end

function BuffHeadEffectContainer:Create(id, parent, containerSettings, settings)
	local parentName = nil;
	if (containerSettings.Placement == BuffHead.Container.Placement.Fixed or settings.ScreenPosition == BuffHead.ScreenPosition.Fixed) then
		--parentName = "Root";
		parentName = "RootFrame";
	else
		parentName = parent:GetName();
	end

	local frame = self:CreateFromTemplate(parent:GetName() .. id, parentName);
	frame.ContainerSettings = containerSettings;
	frame.Settings = settings;
	frame.EffectFrames = {};
	frame.CompressedEffects = {};
	frame.Size = { Width = 0, Height = 0 };
	frame.DisplaySize = { Width = 0, Height = 0 };
	frame.Parent = parent;
	frame.SortTree = BuffHead.RBTree:Create(CompareEffects);
	frame.Queue = { Update = BuffHeadQueue:Create(), Remove = {} };
	frame.PriorityEffects = { Frames = {}, Count = 0 };
	frame.DimensionsDirty = false;

	if (settings.HandleRemovable or settings.ShowTooltips) then
		WindowSetHandleInput(frame:GetName(), true);
	end
	
	if (containerSettings.Placement == BuffHead.Container.Placement.Fixed) then
		frame.IsFixed = true;
		frame:UpdateFixedPosition();
	
		local rows, columns = (containerSettings.Size.Rows or 1), (containerSettings.Size.Columns or 10);
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
		frame:SetSize(size.Width * settings.Scale, size.Height * settings.Scale);
	end
	
	frame:SetShowing(true);
	
	return frame;
end

function BuffHeadEffectContainer:SetShowing(isVisible)
	--d("EffectContainer:SetShowing")
	self:Show(isVisible);
end

function BuffHeadEffectContainer:UpdateFixedPosition()
	local growRight, growDown = true, true;	
	if (self.ContainerSettings.Growth) then
		growRight = (self.ContainerSettings.Growth.Horizontal == BuffHead.Container.Growth.Horizontal.Right);
		growDown = (self.ContainerSettings.Growth.Vertical == BuffHead.Container.Growth.Vertical.Down);
	end
	
	local anchorOnAnchor, anchorOnSelf;
	local x, y = self.ContainerSettings.Offset.X, self.ContainerSettings.Offset.Y;
	
	if (growRight) then
		if (growDown) then
			anchorOnAnchor, anchorOnSelf = "topleft", "topleft";
		else
			anchorOnAnchor, anchorOnSelf = "topleft", "bottomleft";
			y = y + (self.Settings.Layout.Height * self.Settings.Scale);
		end
	else
		if (growDown) then
			anchorOnAnchor, anchorOnSelf = "topleft", "topright";
			x = x + (self.Settings.Layout.Width * self.Settings.Scale);
		else
			anchorOnAnchor, anchorOnSelf = "topleft", "bottomright";
			x = x + (self.Settings.Layout.Width * self.Settings.Scale);
			y = y + (self.Settings.Layout.Height * self.Settings.Scale);
		end
	end
	
	WindowClearAnchors(self:GetName());
	-- previously, the parent of fixed containers were the base container, but now its root
	--WindowAddAnchor(self:GetName(), anchorOnAnchor, "Root", anchorOnSelf, x, y); -- x / self.Settings.Scale, y / self.Settings.Scale
	WindowAddAnchor(self:GetName(), anchorOnAnchor, "RootFrame", anchorOnSelf, x, y); -- x / self.Settings.Scale, y / self.Settings.Scale
end

function BuffHeadEffectContainer:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)

	WindowClearAnchors(self:GetName());
	WindowAddAnchor(self:GetName(), pointOnAnchor, anchorFrame, pointOnSelf, xOffset, yOffset);

end

local function IsCompressed(self, index, abilityData)

	local ability = abilityData.Data;
	local abilityId = ability.abilityId;
	local compressionId = nil;
	
	local advancedCompression = BuffHead.AdvancedCompression.GetCompression(abilityData.Data);
	if (advancedCompression) then
		compressionId = ADVANCED_COMPRESSION_START_ID + advancedCompression;
	else
		compressionId = abilityId;
	end
	local compressedEffects = self.CompressedEffects[compressionId];

	if (compressedEffects and compressedEffects.Effects[index]) then
		if (compressedEffects.LongestDuration.Index == index) then
			return false; -- though the effect is compressed, it's at the top level
		else
			return true;
		end
	end
	
	return false;
	
end

function BuffHeadEffectContainer:AnchorEffects(cacheOnly)

	if (self.EffectsCache == nil) then
		if (not self.AnchorsDirty) then return end
		self.AnchorsDirty = false;
	else
		-- the existing cache data is out of date (data has changed during the update cycle)
		if (cacheOnly) then
			if (self.AnchorsDirty) then
				self.EffectsCache = nil;
				self.AnchorsDirty = false;
			else
				return;
			end
		end
	end

	local effectsList = {};
	
	local rows, columns = (self.ContainerSettings.Size.Rows or 1), (self.ContainerSettings.Size.Columns or 10);
	local previousFrame = nil;
	local previousRowFrame = nil;
	local maximumEffects = (rows * columns);
	
	if (self.EffectsCache) then
		effectsList = self.EffectsCache;
		self.EffectsCache = nil;
	else
		if (BuffHead.Settings.Sorting.Enabled) then
			effectsList = self.SortTree:GetValues(maximumEffects);
		else
			for index, effectFrame in pairs(self.EffectFrames) do
				if (not IsCompressed(self, effectFrame.AbilityData.Index, effectFrame.AbilityData)) then
					tableInsert(effectsList, effectFrame);
					--d("BuffHeadEffectContainer anchor effects")
					--d(effectFrame.m_Name)
					if (#effectsList == maximumEffects) then
						break;
					end
				end
			end
		end
		
		-- cached size changing is done to prevent flickering, by resizing the container, then adding buffs rather than the other way around
		if (cacheOnly) then
			-- calculate how many effects will be visible, and update the parent size
			local visibleEffects = math.min(#effectsList, rows * columns);
			local lastEffectCount = self.VisibleEffects or 0;
			
			local currentSize = visibleEffects;
			if (currentSize > columns) then
				currentSize = columns * (math.floor((visibleEffects - 1) / columns) + 1);
			end
			
			local oldSize = lastEffectCount;
			if (oldSize > columns) then
				oldSize = columns * (math.floor((lastEffectCount - 1) / columns) + 1);
			end
			
			self.VisibleEffects = visibleEffects;
			local sizeChanged = (oldSize ~= currentSize);
			
			self.EffectsCache = effectsList;
			
			if (#self.Queue.Remove > 0) then
				self.RemoveCache = self.Queue.Remove;
				self.Queue.Remove = {};
			end
			
			return sizeChanged;
		else
			-- updating directly without using a cache
			-- note: nothing should be using this
			if (#self.Queue.Remove > 0) then
				self.RemoveCache = self.Queue.Remove;
				self.Queue.Remove = {};
			end
		end
	end
	
	local oldAnchors = self.Anchors or {};
	self.Anchors = {};
	
	local growRight, growDown = true, true;	
	if (self.ContainerSettings.Growth) then
		growRight = (self.ContainerSettings.Growth.Horizontal == BuffHead.Container.Growth.Horizontal.Right);
		growDown = (self.ContainerSettings.Growth.Vertical == BuffHead.Container.Growth.Vertical.Down);
	end
	
	
	local initialAnchorOnAnchor, initialAnchorOnSelf; -- for anchoring the 1st element
	local previousRowAnchorOnAnchor, privousRowAnchorOnSelf; -- for anchoring the 1st element on a new row
	local previousAnchorOnAnchor, previousAnchorOnSelf; -- for anchoring a element to the previous one
	local paddingX, paddingY = self.Settings.Indicators.Padding.X, self.Settings.Indicators.Padding.Y;
	
	if (growRight) then
		if (growDown) then
			initialAnchorOnAnchor, initialAnchorOnSelf = "topleft", "topleft";
			previousRowAnchorOnAnchor, privousRowAnchorOnSelf = "bottomleft", "topleft";
		else
			initialAnchorOnAnchor, initialAnchorOnSelf = "bottomleft", "bottomleft";
			previousRowAnchorOnAnchor, privousRowAnchorOnSelf = "topleft", "bottomleft";
			paddingY = -paddingY;
		end
		previousAnchorOnAnchor, previousAnchorOnSelf = "topright", "topleft";
	else
		if (growDown) then
			initialAnchorOnAnchor, initialAnchorOnSelf = "topright", "topright";
			previousRowAnchorOnAnchor, privousRowAnchorOnSelf = "bottomright", "topright";
		else
			initialAnchorOnAnchor, initialAnchorOnSelf = "bottomright", "bottomright";
			previousRowAnchorOnAnchor, privousRowAnchorOnSelf = "topright", "bottomright";
			paddingY = -paddingY;
		end
		previousAnchorOnAnchor, previousAnchorOnSelf = "topleft", "topright";
		paddingX = -paddingX;
	end
	
	for index, effectFrame in ipairs(effectsList) do
		
		local columnIndex = (index - 1) % columns;
		local rowIndex = math.floor((index - 1) / columns);
		
		local isVisible = (not (columnIndex + 1 > columns or rowIndex + 1 > rows));
		
		if (isVisible) then		
			local abilityIndex = effectFrame.AbilityData.Index;
			self.Anchors[abilityIndex] = effectFrame;
			oldAnchors[abilityIndex] = nil;
			
			if (columnIndex == 0) then
				if (previousRowFrame) then
					effectFrame:AnchorTo(previousRowFrame.Frame:GetName(), previousRowAnchorOnAnchor, privousRowAnchorOnSelf, 0, paddingY);
				else
					effectFrame:AnchorTo(self:GetName(), initialAnchorOnAnchor, initialAnchorOnSelf, 0, 0);
				end
				previousRowFrame = effectFrame;
			else
				if (previousFrame) then
					effectFrame:AnchorTo(previousFrame.Frame:GetName(), previousAnchorOnAnchor, previousAnchorOnSelf, paddingX, 0);
				else
					effectFrame:AnchorTo(self:GetName(), initialAnchorOnAnchor, initialAnchorOnSelf, 0, 0);
				end
			end
			
			previousFrame = effectFrame;
		else
			break; -- do not continue through hidden items
		end
		
		effectFrame:SetShowing(isVisible);
	end
	--d(" anchor effect destroy ")
	if (self.RemoveCache) then
		for index, effectFrame in ipairs(self.RemoveCache) do
			--d("Anchor effect destroy")
			--d(index)
			oldAnchors[effectFrame.AbilityData.Index] = nil;
			effectFrame:Destroy();
			--d("- Anchor effect destroy")
		end
		self.RemoveCache = nil;
	end
	
	-- This method is no longer used, since in rare occurences, a remove operation could
	-- occur during an update cycle. This would result in a cache containing removed item
	-- where the frame would then be removed shortly after, resulting in an empty space
	--[[
	if (#self.Queue.Remove > 0) then
		for index, effectFrame in ipairs(self.Queue.Remove) do
		        --d("Anchor effect destroy 0")
			--d(index)
			oldAnchors[effectFrame.AbilityData.Index] = nil;
			effectFrame:Destroy();
			--d("- Anchor effect destroy 0")
		end
		self.Queue.Remove = {};
	end
	--]]
	--d(" - anchor effect destroy ")	
	--d(" anchor release frames")
	-- release all the frames of previously shown anchors
	for abilityIndex, effectFrame in pairs(oldAnchors) do
		effectFrame:ReleaseFrame();
	end
	--d(" - anchor release frames")
	
end

function BuffHeadEffectContainer:SetSize(width, height)
	
	if (self.Size.Width ~= width or self.Size.Height ~= height) then	
		self.Size = { Width = width, Height = height };
		self.DimensionsDirty = true;
		return true;
	end
	
end

local function RemoveCompressed(self, index, abilityData)
	
	local ability = abilityData.Data;
	local abilityId = ability.abilityId;
	local compressionId = nil;
	
	local advancedCompression = BuffHead.AdvancedCompression.GetCompression(abilityData.Data);
	if (advancedCompression) then
		compressionId = ADVANCED_COMPRESSION_START_ID + advancedCompression;
	else
		compressionId = abilityId;
	end
	local compressedEffects = self.CompressedEffects[compressionId];
	local returnedFrame = nil;
	
	if (compressedEffects and compressedEffects.Effects[index]) then
		local longestEffect = compressedEffects.LongestDuration.Effect;
		compressedEffects.Effects[index] = nil;
		
		if (compressedEffects.LongestDuration.Index == index) then
			-- replace the longest effect
			local longestDuration = 0;
			for effectIndex, effectFrame in pairs(compressedEffects.Effects) do
				local duration = effectFrame:GetDuration();
				if (duration > longestDuration) then
					compressedEffects.LongestDuration = { Effect = effectFrame, Index = effectIndex };
					longestDuration = duration;
				end
			end
			
			-- nothing was found, clear the compressed variable for this ability
			if (longestDuration == 0) then
				--d("Compressed effects assign nil")
				self.CompressedEffects[compressionId] = nil;
				return;
			else
				-- give the old longest frame to the new one
				returnedFrame = compressedEffects.LongestDuration.Effect;
				TransferFrameControl(self, longestEffect, returnedFrame);
			end
		end
		
		local compressionCount = compressedEffects.CompressionCount;
		
		--if (ability.stackCount and ability.stackCount > 0) then
			--compressionCount = compressionCount - ability.stackCount;
		--else
			compressionCount = compressionCount - 1;
		--end
		
		compressedEffects.CompressionCount = compressionCount;
		compressedEffects.LongestDuration.Effect:SetCompression(compressionCount);
	end
	
	return returnedFrame;

end

local function ApplyAdvancedCompression(abilityData, advancedCompression)
	local settings = BuffHead.AdvancedCompression.GetCompressionSettings(advancedCompression);
	if (not settings) then return end
	local ability = abilityData.Data;
	
	-- apply overrides
	if (settings.Name) then
		ability.name = settings.Name;
	end
	if (settings.Icon) then
		if (type(settings.Icon) == "number") then
			ability.iconNum = settings.Icon;
		else
			ability.iconTexture = settings.Icon;
		end
	end
end

local function AddCompressed(self, effectFrame, index, abilityData)
	
	local advancedCompression = BuffHead.AdvancedCompression.GetCompression(abilityData.Data);
	local compressSettings = self.Settings.Indicators.Compression or BuffHead.Settings.Indicators.Compression;
	if (compressSettings == BuffHead.Compression.None and not advancedCompression) then return end
	
	local isCompressed = false;
	local ability = abilityData.Data;
	local abilityId = ability.abilityId;
	local duration = effectFrame:GetDuration();
	local compressedEffects = self.CompressedEffects;
	local compressionId = nil;
	
	if (advancedCompression) then
		compressionId = ADVANCED_COMPRESSION_START_ID + advancedCompression;
		ApplyAdvancedCompression(abilityData, advancedCompression);
	else
		compressionId = abilityId;
	end
	
	if (advancedCompression or (compressSettings == BuffHead.Compression.All or (ability.castByPlayer and compressSettings == BuffHead.Compression.OnlyMine) or 
		(not ability.castByPlayer and compressSettings == BuffHead.Compression.OnlyOthers))) then
	
		if (compressedEffects[compressionId]) then
			if (duration > compressedEffects[compressionId].LongestDuration.Effect:GetDuration()) then
				-- take the frame from the old effect
				local longestEffect = compressedEffects[compressionId].LongestDuration.Effect;
				
				TransferFrameControl(self, longestEffect, effectFrame);
				
				-- remove the old effect from sorting
				self.SortTree:Remove(longestEffect.TreeNode);
				longestEffect.TreeNode = nil;
				compressedEffects[compressionId].LongestDuration = { Effect = effectFrame, Index = index };
			else
				isCompressed = true; -- the frame is hidden
			end
		else
			compressedEffects[compressionId] = { Effects = {}, LongestDuration = { Effect = effectFrame, Index = index }, CompressionCount = 0 };
		end
	
		local compressionCount = compressedEffects[compressionId].CompressionCount;
		
		--if (ability.stackCount and ability.stackCount > 0) then
			--compressionCount = compressionCount + ability.stackCount;
		--else
			compressionCount = compressionCount + 1;
		--end
		
		compressedEffects[compressionId].CompressionCount = compressionCount;
		compressedEffects[compressionId].Effects[index] = effectFrame;
		
		compressedEffects[compressionId].LongestDuration.Effect:SetCompression(compressionCount);
		
	end
	
	return isCompressed;
		
end

function BuffHeadEffectContainer:AddEffect(index, abilityData)

	if (self.EffectFrames[index]) then
		return; -- error, unique index failed
	end
	
	local effectFrame = BuffHeadEffect:Create(self, index, abilityData);
	self.EffectFrames[index] = effectFrame;
	
	local priorityEffect = BuffHead.Settings.PriorityEffects.Effect[abilityData.Data.abilityId];
	if (priorityEffect ~= nil and priorityEffect[self.Parent.TargetType]) then
		abilityData.Data.priority = 1; -- note that priority effects can be sorted against each other
		self.PriorityEffects.Count = self.PriorityEffects.Count + 1;
		self.PriorityEffects.Frames[index] = effectFrame;
	end
	
	local isCompressed = AddCompressed(self, effectFrame, index, abilityData);
	
	if (not isCompressed) then
		if (BuffHead.Settings.Sorting.Enabled) then
			effectFrame.TreeNode = self.SortTree:Insert(effectFrame);
		end
	
		self.AnchorsDirty = true;
	end
	
	return effectFrame;

end

function BuffHeadEffectContainer:UpdateEffect(index, abilityData)

	local effectFrame = self.EffectFrames[index];
	abilityData.Data.priority = effectFrame.AbilityData.Data.priority;

	if (effectFrame) then
		effectFrame:Update(abilityData);
		
		--[[ Although this will guarantee proper compression visibility, it's not really needed at the cost of the loop
		RemoveCompressed(self, index, abilityData);
		local isCompressed = AddCompressed(self, effectFrame, index, abilityData);
		--]]
		
		local isCompressed = IsCompressed(self, index, abilityData);
		
		self.SortTree:Remove(effectFrame.TreeNode);
		
		if (not isCompressed) then
			if (BuffHead.Settings.Sorting.Enabled) then
				effectFrame.TreeNode = self.SortTree:Insert(effectFrame);
			end
		
			self.AnchorsDirty = true;
		end
	end
				
end

function BuffHeadEffectContainer:RemoveEffect(index)

	local effectFrame = self.EffectFrames[index];
	if (not effectFrame) then
		return;
	end
	
	if (self.PriorityEffects.Count > 0 and self.PriorityEffects.Frames[index]) then
		self.PriorityEffects.Frames[index] = nil;
		self.PriorityEffects.Count = self.PriorityEffects.Count - 1;
	end
	
	local newCompressed = RemoveCompressed(self, index, effectFrame.AbilityData);
	self.SortTree:Remove(effectFrame.TreeNode);
	if (newCompressed) then
		if (BuffHead.Settings.Sorting.Enabled) then
			newCompressed.TreeNode = self.SortTree:Insert(newCompressed);
		end
		self.AnchorsDirty = true;
	end
	
	self.Queue.Update:Remove(index);
	self.EffectFrames[index] = nil;
	
	if (self.EffectsCache or (self.Anchors and self.Anchors[index])) then
		--d("queue for removal")
		--d(index)
		tableInsert(self.Queue.Remove, effectFrame); -- item is anchored to something, remove it on the next re-anchor
		self.AnchorsDirty = true;
		--d("- queue for removal")
	else
		--d("effect container remove effect")
		--d(index)
		effectFrame:Destroy(); -- item wasn't anchored to anything, and there is no cache, just remove it. it might not be created, but it could be in the cache
	end

end

function BuffHeadEffectContainer:UpdateDurations()

	for index, effectFrame in pairs(self.EffectFrames) do
		--d("Update Duration")
		--d(index)	
		effectFrame:UpdateDuration();
	end

end

function BuffHeadEffectContainer:UpdateDimensions()

	if (self.DimensionsDirty) then
		-- This is to prevent the jitter effect as containers are resized, which was basically caused
		-- by multiple resizes at the same time
		WindowSetDimensions(self:GetName(), self.Size.Width, self.Size.Height);
		self.DimensionsDirty = false;
	end
	
end

function BuffHeadEffectContainer:Update(elapsed)
	
	if (self.DimensionsDirty) then
		-- This is to prevent the jitter effect as containers are resized, which was basically caused
		-- by multiple resizes at the same time
		WindowSetDimensions(self:GetName(), self.Size.Width, self.Size.Height);
		self.DimensionsDirty = false;
	end
	
	if (self.PriorityEffects.Count > 0) then
		if (BuffHead.TimeCount > (self.PriorityEffects.NextUpdate or 0)) then
			self.PriorityEffects.NextUpdate = BuffHead.TimeCount + 0.15;
			for index, effectFrame in pairs(self.PriorityEffects.Frames) do
				--d("update effect container")
				--d(effectFrame.Frame)
				if (effectFrame.Frame) then
					effectFrame.Frame:Update(elapsed);
				end
				--d("- update effect container")
			end
		end
	end
	
	local updates = 0;
	local maxUpdates = BuffHead.Settings.Performance.MaximumUpdates or 10;
	while (updates < maxUpdates or maxUpdates == 0) do
		local item = self.Queue.Update:GetNext();
		if (item) then
			item.Frame:SetDuration(item.Duration);
			updates = updates + 1;
		else
			return;
		end
	end
	
end

function BuffHeadEffectContainer:ClearAllEffects() --SCarfaXX
        --d("effect container clear all effects")
	if (not self.EffectFrames) then return end

	local frameCount = 0;
	for index, effectFrame in pairs(self.EffectFrames) do
		--d("clear all effect destroy")
		--d(effectFrame.m_Name)
		effectFrame:Destroy();
		frameCount = frameCount + 1;
		--d(" - clear all effect destroy")
	end

	self.PriorityEffects = { Frames = {}, Count = 0 };
	self.EffectFrames = {};
	self.SortTree:Clear();
	self.Queue.Update:Clear();
	self.Queue.Remove = {}
	self.CompressedEffects = {};
	
	self.AnchorsDirty = true;
	
	self.Parent.ActiveFrames = math.max(self.Parent.ActiveFrames - frameCount, 0);
	BuffHead.RecheckFrames()
	--d("- effect container clear all effects")
end

BuffHeadQueue = {};
BuffHeadQueue.__index = BuffHeadQueue;

function BuffHeadQueue:Create()

	local queue = setmetatable({}, self);
	queue.__index = queue;
	
	queue.Keys = {};
	queue.Queue = {};
	
	return queue;
	
end

function BuffHeadQueue:IsQueued(key)

	return (self.Keys[key] ~= nil);

end

function BuffHeadQueue:Add(key, item)
	
	-- add the item if it's not queued, else, update the current queued item
	if (not self:IsQueued(key)) then	
		--d("BuffHeadQueue_Add")
		--d(key)
		tableInsert(self.Queue, key);
	end
	self.Keys[key] = item;
	
end

function BuffHeadQueue:Remove(key)
	
	if (not self:IsQueued(key)) then return end
	
	self.Keys[key] = nil;
	
	for index, item in ipairs(self.Queue) do
		--d("Queue remove")
		--d(index)
		if (item == key) then
			tableRemove(self.Queue, index);
			return; -- an item is unique in a queue
		end
	end

end

function BuffHeadQueue:Clear()

	self.Keys = {};
	self.Queue = {};

end

function BuffHeadQueue:GetNext()

	if (#self.Queue == 0) then
		return nil;
	end
	
	local key = tableRemove(self.Queue, 1);
	local item = self.Keys[key];
	self.Keys[key] = nil;
	
	return item;

end