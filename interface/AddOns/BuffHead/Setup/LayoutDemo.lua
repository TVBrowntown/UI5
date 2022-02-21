BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.Demo = {};

local localization = BuffHead.Localization.GetMapping();

local friendlyEffects = nil;
local hostileEffects = nil;

local updateRegistered = false;
local demoEffect = nil;
local updateDemo = true;
local demoNextEffectIn = nil;
local abilityData = nil;

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
			color = DefaultColor.AbilityType.BUFF,
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
			color = { r = 255, g = 220, b = 80 },
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
			color = DefaultColor.AbilityType.HEALING,
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
			color = { r = 104, g = 186, b = 255 },
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
			color = { r = 104, g = 186, b = 255 },
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
			color = DefaultColor.AbilityType.DAMAGING,
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
			color = { r = 184, g = 0, b = 9 },
		},
	};
end

function BuffHead.Setup.Demo.Initialize()

end

function BuffHead.Setup.Demo.Enable(windowName)
	if (friendlyEffects == nil or hostileEffects == nil) then
		SetupEffects();
	end

	if (demoEffect == nil) then
		demoEffect = BuffHeadEffectFrame:Create();
	end

	demoEffect:AnchorTo(windowName, "bottomleft", "topright", -15, -75);
	BuffHead.Setup.Demo.OnSettingsChanged();
	
	if (not updateRegistered) then
		updateRegistered = true;
		demoNextCastIn = nil;
    	RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "BuffHead.Setup.Demo.OnUpdate");
	end
end

function BuffHead.Setup.Demo.Disable()
	if (updateRegistered) then
		updateRegistered = false;
		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "BuffHead.Setup.Demo.OnUpdate");
	end
	if (demoEffect) then
		demoEffect:Destroy();
		demoEffect = nil;
	end
end

function BuffHead.Setup.Demo.OnSettingsChanged()
	updateDemo = true;
end

function BuffHead.Setup.Demo.OnUpdate(elapsed)	
	if (demoNextEffectIn == nil) then
		local duration = 10;
		demoNextEffectIn = duration;
		if (demoNextEffectIn) then
			local effect =  friendlyEffects[math.random(1, #friendlyEffects)];
			if (math.random(0, 1) == 1) then
				effect = hostileEffects[math.random(1, #hostileEffects)]
			end
			effect.duration = duration;
			effect.stackCount = math.random(1, 15);
			abilityData = { TimeAdded = BuffHead.TimeCount, Data = effect, Duration = duration };
			updateDemo = true;
		end
	else
		demoNextEffectIn = demoNextEffectIn - elapsed;
		if (demoNextEffectIn < 0) then
			demoNextEffectIn = nil;
		end
	end
		
	if (updateDemo) then
		updateDemo = false;
		if (demoEffect) then
			demoEffect:SetLayout(abilityData, BuffHead.Setup.Layout.GetActiveSettings());
			demoEffect:SetStackCount(abilityData.Data.stackCount);
			demoEffect:SetShowing(true);
		end
	end
	
	local timeLeft = abilityData.Data.duration - (BuffHead.TimeCount - abilityData.TimeAdded);
	demoEffect:SetDuration(timeLeft);
	demoEffect:SetStatusBar(timeLeft);
end