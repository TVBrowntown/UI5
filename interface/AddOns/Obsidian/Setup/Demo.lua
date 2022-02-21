Obsidian = Obsidian or {};
Obsidian.Setup = Obsidian.Setup or {};
Obsidian.Setup.Demo = {};

local localization = Obsidian.Localization.GetMapping();

local friendlyEffects = nil;
local hostileEffects = nil;

local updateRegistered = false;
local demoCastbar = nil;
local demoGCD = nil;
local updateDemo = true;
local demoNextCastIn = nil;
local demoCastResult = false;
local demoFriendlyEffects = nil;
local demoHostileEffects = nil;
local demoEffects = false;
local demoNextFriendlyEffectIn = nil;
local demoNextHostileEffectIn = nil;
local hostileIndex = 1;
local friendlyIndex = 1;

local function SetupEffects()
	friendlyEffects =
	{
		{
			abilityId = 245,
			castByPlayer = true,
			iconNum = 5004,
			isBuff = true,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = false,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
		},
		{
			abilityId = 8558,
			castByPlayer = true,
			iconNum = 5142,
			isBlessing = true,
			isBuff = false,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			typeColorBlue = 80,
			typeColorGreen = 220,
			typeColorRed = 255,
		},
		{
			abilityId = 3551,
			castByPlayer = true,
			iconNum = 4503,
			isBuff = false,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
		},
		{
			abilityId = 3914,
			castByPlayer = true,
			iconNum = 13342,
			isBuff = true,
			isCasterDispellable = false,
			isDamaging = false,
			isDebuff = false,
			isDefensive = true,
			isEnchantment = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			typeColorBlue = 255,
			typeColorGreen = 186,
			typeColorRed = 104,
		},
	};
	
	hostileEffects =
	{
		{
			abilityId = 1616,
			castByPlayer = true,
			iconNum = 4500,
			isAilment = true,
			isBuff = false,
			isDamaging = true,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			trackerPriority = 0,
			typeColorBlue = 255,
			typeColorGreen = 186,
			typeColorRed = 104,
		},
		{
			abilityId = 1589,
			castByPlayer = true,
			iconNum = 4627,
			isBuff = false,
			isDamaging = true,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = false,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
		},
		{
			abilityId = 3913,
			castByPlayer = true,
			iconNum = 13343,
			isBuff = false,
			isDamaging = true,
			isDebuff = false,
			isDefensive = true,
			isGranted = false,
			isHealing = false,
			isHex = true,
			isOffensive = false,
			isPassive = false,
			isStatsBuff = false,
			name = localization["Strings.Example"],
			trackerPriority = 0,
			typeColorBlue = 9,
			typeColorGreen = 0,
			typeColorRed = 184,
		},
	};
end

local function AnchorEffectTracker(container, settings)
	local pointOnAnchor, pointOnSelf = "topleft", "bottomleft";
	local anchorTo = demoCastbar:GetName();
	
	if (settings.Position == Obsidian.EffectContainer.Position.TopLeft) then
		 pointOnAnchor, pointOnSelf = "topleft", "bottomleft";
	elseif (settings.Position == Obsidian.EffectContainer.Position.TopRight) then
		 pointOnAnchor, pointOnSelf = "topright", "bottomright";
	elseif (settings.Position == Obsidian.EffectContainer.Position.BottomLeft) then
		 pointOnAnchor, pointOnSelf = "bottomleft", "topleft";
	elseif (settings.Position == Obsidian.EffectContainer.Position.BottomRight) then
		 pointOnAnchor, pointOnSelf = "bottomright", "topright";
	elseif (settings.Position == Obsidian.EffectContainer.Position.FreeUp) then
		 pointOnAnchor, pointOnSelf = "topleft", "topleft";
		 anchorTo = "Root";
	elseif (settings.Position == Obsidian.EffectContainer.Position.FreeDown) then
		 pointOnAnchor, pointOnSelf = "topleft", "topleft";
		 anchorTo = "Root";
	end
	
	container:AnchorTo(anchorTo, pointOnAnchor, pointOnSelf, settings.X, settings.Y);
end

local function UpdateAnchors()
	local settings = Obsidian.Settings;
	if (demoGCD and demoCastbar) then	
		if (settings.GlobalCooldown.Position == Obsidian.GlobalCooldown.Position.Bottom) then
			demoGCD:AnchorTo(demoCastbar:GetName(), "bottom", "top", settings.GlobalCooldown.X or 0, settings.GlobalCooldown.Y or 0);
		elseif (settings.GlobalCooldown.Position == Obsidian.GlobalCooldown.Position.Top) then
			demoGCD:AnchorTo(demoCastbar:GetName(), "top", "bottom", settings.GlobalCooldown.X or 0, settings.GlobalCooldown.Y or 0);
		else -- free
			demoGCD:AnchorTo("Root", "topleft", "topleft", settings.GlobalCooldown.X or 0, settings.GlobalCooldown.Y or 0);
		end
	end
	if (demoCastbar) then
		if (demoFriendlyEffects) then
			if (settings.EffectTracker.Friendly.Enabled) then
				AnchorEffectTracker(demoFriendlyEffects, settings.EffectTracker.Friendly);
			else
				demoFriendlyEffects:ClearAllEffects();
			end
		end
		if (demoHostileEffects) then
			if (settings.EffectTracker.Hostile.Enabled) then
				AnchorEffectTracker(demoHostileEffects, settings.EffectTracker.Hostile);
			else
				demoHostileEffects:ClearAllEffects();
			end
		end
	end
end

function Obsidian.Setup.Demo.Initialize()

end

function Obsidian.Setup.Demo.Enable(windowName, enableEffects)
	if (friendlyEffects == nil or hostileEffects == nil) then
		SetupEffects();
	end

	demoEffects = enableEffects;
	local scale = Obsidian.Settings.Castbar.Scale or interfaceScale;
	if (demoCastbar == nil) then
		demoCastbar = Obsidian.Castbar:Create("ObsidianDemoCastbar");
		demoCastbar:Show(true);
	end
	if (demoGCD == nil) then
		demoGCD = Obsidian.GlobalCooldown:Create("ObsidianDemoGlobalCooldown");
	end
	if (demoFriendlyEffects == nil) then
		demoFriendlyEffects = Obsidian.EffectContainer:Create("ObsidianDemoFriendly", Obsidian.TargetType.Friendly, Obsidian.Settings.EffectTracker.Friendly);
	end
	if (demoHostileEffects == nil) then
		demoHostileEffects = Obsidian.EffectContainer:Create("ObsidianDemoHostile", Obsidian.TargetType.Hostile, Obsidian.Settings.EffectTracker.Hostile);
	end

	local yOffset = 20;
	if (enableEffects) then
		yOffset = 100;
	end

	demoCastbar:AnchorTo(windowName, "bottom", "top", 0, yOffset);
	demoCastbar:SetScale(scale);
	demoGCD:SetScale(scale);
	demoFriendlyEffects:SetScale(scale);
	demoHostileEffects:SetScale(scale);
	Obsidian.Setup.Demo.OnSettingsChanged();
	
	if (not updateRegistered) then
		updateRegistered = true;
		demoNextCastIn = nil;
    	RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "Obsidian.Setup.Demo.OnUpdate");
	end
end

function Obsidian.Setup.Demo.Disable()
	if (updateRegistered) then
		updateRegistered = false;
		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "Obsidian.Setup.Demo.OnUpdate");
	end
	if (demoCastbar) then
		demoCastbar:Show(false);
	end
	if (demoGCD) then
		demoGCD:Show(false);
	end
	if (demoFriendlyEffects) then
		demoFriendlyEffects:ClearAllEffects();
		demoFriendlyEffects:Show(false);
	end
	if (demoHostileEffects) then
		demoHostileEffects:ClearAllEffects();
		demoHostileEffects:Show(false);
	end
	demoEffects = false;
end

function Obsidian.Setup.Demo.OnSettingsChanged()
	updateDemo = true;
	UpdateAnchors();
end

function Obsidian.Setup.Demo.OnUpdate(elapsed)
	local settings = Obsidian.Settings;

	if (updateDemo) then
		updateDemo = false;
		if (demoCastbar) then
			demoCastbar:SetLayout();
		end
		if (demoGCD) then
			demoGCD:SetLayout();
		end
		if (demoFriendlyEffects) then
			demoFriendlyEffects:SetLayout();
		end
		if (demoHostileEffects) then
			demoHostileEffects:SetLayout();
		end
	end
	
	if (demoNextCastIn == nil) then
		local castTime = math.random(3, 10);
		demoNextCastIn = castTime + 0.5;
		demoCastResult = (math.random(1, 2) ~= 2);
		if (demoCastbar) then
			demoCastbar:SetName(localization["Strings.Example"], true);
			demoCastbar:StartCasting(246, (math.random(1, 2) == 2), castTime);
		end
		if (demoGCD and settings.GlobalCooldown.Enabled) then
			demoGCD:Start(1.5);
		end
	else
		demoNextCastIn = demoNextCastIn - elapsed;
		if (demoCastbar and demoCastbar.Casting) then
			local checkTime = 0.5;
			if (demoCastResult) then
				checkTime = 1;
			end
			if (demoNextCastIn <= checkTime) then
				demoCastbar:Hide(demoCastResult);
			end
		end
		if (demoNextCastIn < 0) then
			demoNextCastIn = nil;
		end
	end
	
	if (demoEffects) then
		if (settings.EffectTracker.Hostile.Enabled) then
			if (demoNextHostileEffectIn == nil) then
				local duration = math.random(3, 10);
				hostileIndex = (hostileIndex + 1) % 10;
				demoNextHostileEffectIn = duration - 2;
				if (demoHostileEffects) then
					local effect =  hostileEffects[math.random(1, #hostileEffects)];					
					effect.duration = duration;
					demoHostileEffects:UpdateEffects({ [hostileIndex] = effect }, false);
				end
			else
				demoNextHostileEffectIn = demoNextHostileEffectIn - elapsed;
				if (demoNextHostileEffectIn < 0) then
					demoNextHostileEffectIn = nil;
				end
			end
		end
		if (settings.EffectTracker.Friendly.Enabled) then
			if (demoNextFriendlyEffectIn == nil) then
				local duration = math.random(3, 10);
				friendlyIndex = (friendlyIndex + 1) % 10;
				demoNextFriendlyEffectIn = duration - 2;
				if (demoNextFriendlyEffectIn) then
					local effect =  friendlyEffects[math.random(1, #friendlyEffects)];
					effect.duration = duration;
					demoFriendlyEffects:UpdateEffects({ [friendlyIndex] = effect }, false);
				end
			else
				demoNextFriendlyEffectIn = demoNextFriendlyEffectIn - elapsed;
				if (demoNextFriendlyEffectIn < 0) then
					demoNextFriendlyEffectIn = nil;
				end
			end
		end
	end
	
	if (demoCastbar) then
		demoCastbar:Update(elapsed);
	end
	if (demoGCD) then
		demoGCD:Update(elapsed);
	end
	if (demoEffects) then
		if (demoFriendlyEffects) then
			demoFriendlyEffects:Update(elapsed);
		end
		if (demoHostileEffects) then
			demoHostileEffects:Update(elapsed);
		end
	end
end