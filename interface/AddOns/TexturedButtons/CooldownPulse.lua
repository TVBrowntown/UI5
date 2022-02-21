CooldownPulse = Frame:Subclass("TexturedButtonsCooldownPulse");

local animation =
{
	{ StartScale = 1, EndScale = 2, StartAlpha = 0, EndAlpha = 0.5, Duration = 0.3 },
	{ StartScale = 2, EndScale = 0.5, StartAlpha = 0.5, EndAlpha = 0.5, Duration = 0.4 },
	{ StartScale = 0.5, EndScale = 1, StartAlpha = 0.5, EndAlpha = 0, Duration = 0.2 },
};

CooldownPulse.Animation = { Animation = animation, Duration = 0.9 };
local slotToButton = nil;

local function GetButton(slot)

	if (not slotToButton) then
		slotToButton = {};
		for barNum, barData in pairs(ActionBars.m_Bars) do
			for btnNum, btnData in ipairs(barData.m_Buttons) do
				slotToButton[btnData.m_HotBarSlot] = btnData;
			end
		end
	end
	
	return slotToButton[slot];

end

function CooldownPulse:Create(slot)

	local button = GetButton(slot);
	local frame = self:CreateFromTemplate("TexturedButtonsCooldownPulseSlot" .. slot);
	
	frame.IsActive = false;
	frame.PulseStarted = false;
	frame.Icon = nil;
	frame.ActionButton = button;
	
	frame:AnchorTo(button:GetName(), "center", "center", 0, 0);
	
	return frame;
	
end

function CooldownPulse:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)

	WindowClearAnchors(self:GetName());
	WindowAddAnchor(self:GetName(), pointOnAnchor, anchorFrame, pointOnSelf, xOffset, yOffset);

end

function CooldownPulse:SetIcon(iconNum)

	if (self.Icon == iconNum) then return end
	self.Icon = iconNum;
	
	local tex, texX, texY = GetIconData(iconNum);
	DynamicImageSetTexture(self:GetName() .. "Icon", tex, texX, texY)
	DynamicImageSetTextureScale(self:GetName() .. "Icon", 1);
	DynamicImageSetTextureDimensions(self:GetName() .. "Icon", 64, 64);
			
end

function CooldownPulse:BeginPulseIn(seconds)

	if (self.IsActive) then return end
	self.PulseIn = seconds;

end

function CooldownPulse:BeginPulse()

	if (self.IsActive) then
		self:StopPulse();
	end
	
	self.IsActive = true;
	self.ActiveAnimation = 1;
	self.TimeRemaining = animation[self.ActiveAnimation].Duration;
	
	self:SetScale(animation[self.ActiveAnimation].StartScale);
	self:Show(true, Frame.FORCE_OVERRIDE);

end

function CooldownPulse:StopPulse()

	self.PulseIn = nil;
	if (not self.IsActive) then return end

	self.IsActive = false;
	self:Show(false, Frame.FORCE_OVERRIDE);

end

function CooldownPulse:Update(elapsed)

	if (self.PulseIn) then
		self.PulseIn = self.PulseIn - elapsed;
		if (self.PulseIn <= 0) then
			elapsed = elapsed - self.PulseIn;
			self.PulseIn = nil;
			self:BeginPulse();
		end
	end

	if (not self.IsActive) then return end
	
	self.TimeRemaining = self.TimeRemaining - elapsed;
	local activeAnimation = animation[self.ActiveAnimation];
	
	if (self.TimeRemaining <= 0) then
		self.ActiveAnimation = self.ActiveAnimation + 1;
		if (not animation[self.ActiveAnimation]) then
			self:StopPulse();
			return;
		else
			activeAnimation = animation[self.ActiveAnimation]
			self.TimeRemaining = activeAnimation.Duration;
		end
	end
	
	self:SetAlpha((activeAnimation.StartAlpha - ((activeAnimation.StartAlpha - activeAnimation.EndAlpha) * (1 - (self.TimeRemaining / activeAnimation.Duration)))));
	self:SetScale((activeAnimation.StartScale - ((activeAnimation.StartScale - activeAnimation.EndScale) * (1 - (self.TimeRemaining / activeAnimation.Duration)))) * self.ActionButton:GetScale());

end