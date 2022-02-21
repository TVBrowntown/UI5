Obsidian.EffectBar = Frame:Subclass("ObsidianEffectTemplate");
Obsidian.EffectBar.IconPosition = { Left = 1, Right = 2 };
Obsidian.EffectBar.FillPriority = { Low = 1, Normal = 2, High = 3 };
Obsidian.EffectBar.FillType = { EffectType = 1, BuffDebuff = 2, Custom = 3 };

--[[
	Note: This code is a slight modification of the castbar
--]]

local HIDE_DURATION = 0.5;

local FillType = Obsidian.EffectBar.FillType;
local IconPosition = Obsidian.EffectBar.IconPosition;

local function IsColorEqual(colorA, colorB)
	if (not colorA or not colorB) then
		return false;
	end

	return (colorA.R == colorB.R and colorA.G == colorB.G and colorA.B == colorB.B);
end

local function SetAnchor(frame, anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)
	WindowClearAnchors(frame);
	WindowAddAnchor(frame, pointOnAnchor, anchorFrame, pointOnSelf, xOffset, yOffset);
end

function Obsidian.EffectBar:SetLayout()
	local generalSettings = Obsidian.Settings.EffectTracker.General;	
	local effectSettings = self.Settings;
	local layout = self.Layout;
	local windowName = self:GetName();
	local scale = self:GetScale();
	local width, height, borderSize = generalSettings.Size.Width, generalSettings.Size.Height, generalSettings.Size.Border;
	
	self.Size = { Width = width, Height = height, Border = borderSize };
	layout.FixedDuration = nil;
	if (generalSettings.FixedDuration > 0) then
		layout.FixedDuration  = generalSettings.FixedDuration;
	end
	self.GeneralSettings = generalSettings;
	
	WindowSetDimensions(windowName, width + (borderSize * 2), height + (borderSize * 2));

	local color = generalSettings.Background.Color;
	WindowSetAlpha(windowName .. "Background", generalSettings.Background.Alpha);
	WindowSetTintColor(windowName .. "Background", color.R, color.G, color.B);
	DynamicImageSetTexture(windowName .. "Background", generalSettings.Background.Texture, 0, 0);
	DynamicImageSetTextureDimensions(windowName .. "Background", generalSettings.Background.TextureDimensions.Width, generalSettings.Background.TextureDimensions.Height);
	
	layout.Background.Alpha = generalSettings.Background.Alpha;

	WindowSetAlpha(windowName .. "Fill", generalSettings.Fill.Alpha);
	DynamicImageSetTexture(windowName .. "Fill", generalSettings.Fill.Texture, 0, 0);
	SetAnchor(windowName .. "Fill", windowName, "left", "left", borderSize, 0);
	
	layout.Fill.Size = { Width = width, Height = height };
	layout.Fill.Alpha = generalSettings.Fill.Alpha;
	layout.Fill.Texture = generalSettings.Fill.Texture;
	self.Values.Fill.Color = nil;

	if (generalSettings.Timer.Enabled) then
		color = generalSettings.Timer.Color;
		WindowSetDimensions(windowName .. "Timer", width, math.max(height, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING));
		LabelSetFont(windowName .. "Timer", generalSettings.Timer.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
		LabelSetTextAlign(windowName .. "Timer", generalSettings.Timer.Alignment);
		LabelSetTextColor(windowName .. "Timer", color.R, color.G, color.B);
		SetAnchor(windowName .. "Timer", windowName, "right", "right", generalSettings.Timer.X - borderSize, generalSettings.Timer.Y);
		WindowSetScale(windowName .. "Timer", generalSettings.Timer.Scale * scale);
		if (self.Alpha ~= 0) then
			WindowSetFontAlpha(windowName .. "Timer", generalSettings.Timer.Alpha);
		end
	end
	WindowSetShowing(windowName .. "Timer", (generalSettings.Timer.Enabled == true));
	
	layout.Timer.Enabled = generalSettings.Timer.Enabled;
	layout.Timer.Scale = generalSettings.Timer.Scale;
	layout.Timer.Alpha = generalSettings.Timer.Alpha;

	if (generalSettings.Name.Enabled) then
		color = generalSettings.Name.Color;
		WindowSetDimensions(windowName .. "Name", math.max(width / generalSettings.Name.Scale * generalSettings.Name.Width, 0), math.max(height, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING));
		LabelSetFont(windowName .. "Name", generalSettings.Name.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
		LabelSetTextAlign(windowName .. "Name", generalSettings.Name.Alignment);
		LabelSetTextColor(windowName .. "Name", color.R, color.G, color.B);
		SetAnchor(windowName .. "Name", windowName, "left", "left", generalSettings.Name.X + borderSize, generalSettings.Name.Y);
		WindowSetScale(windowName .. "Name", generalSettings.Name.Scale * scale);
		if (self.Alpha ~= 0) then
			WindowSetFontAlpha(windowName .. "Name", generalSettings.Name.Alpha);
		end
	end
	WindowSetShowing(windowName .. "Name", (generalSettings.Name.Enabled == true));
	
	layout.Name.Enabled = generalSettings.Name.Enabled;
	layout.Name.Scale = generalSettings.Name.Scale;
	layout.Name.Alpha = generalSettings.Name.Alpha;

	if (effectSettings.Icon.Enabled) then
		WindowSetDimensions(windowName .. "Icon", height + (borderSize * 2), height + (borderSize * 2));
		if (effectSettings.Icon.Position == IconPosition.Left) then
			SetAnchor(windowName .. "Icon", windowName, "left", "right", effectSettings.Icon.X, effectSettings.Icon.Y);
		elseif (effectSettings.Icon.Position == IconPosition.Right) then
			SetAnchor(windowName .. "Icon", windowName, "right", "left", effectSettings.Icon.X, effectSettings.Icon.Y);
		end
		WindowSetScale(windowName .. "Icon", effectSettings.Icon.Scale * scale);
		WindowSetAlpha(windowName .. "Icon", effectSettings.Icon.Alpha);
	end
	WindowSetShowing(windowName .. "Icon", (effectSettings.Icon.Enabled == true));
	
	layout.Icon.Enabled = effectSettings.Icon.Enabled;
	layout.Icon.Showing = layout.Icon.Enabled;
	layout.Icon.Alpha = effectSettings.Icon.Alpha;
	layout.Icon.Scale = effectSettings.Icon.Scale;
end

function Obsidian.EffectBar:Create(parent, name, settings)

	frame = self:CreateFromTemplate(name, "Root");
	frame.Parent = parent;
	frame.Layout = 
	{
		Background = {},
		Icon = {},
		Fill = {},
		Name = {},
		Timer = {},
	};
	frame.Values = 
	{
		Icon = nil,
		Timer = {},
		Fill = {},
		Background = {},
		Name = {},
	};
	frame.Alpha = 1;
	frame.Settings = settings;
	
	frame:SetLayout();
	
	return frame;
	
end

function Obsidian.EffectBar:FadeOut(duration)
	if (self.Alpha == 0) then return end
	self.Alpha = 0;
	self:StopAlphaAnimation();
	self:StartAlphaAnimation(Window.AnimationType.SINGLE_NO_RESET, 1, 0, duration, 0, 0);
end

function Obsidian.EffectBar:ResetAlpha()
	if (self.Alpha == 1) then return end
	self.Alpha = 1;
	self:StopAlphaAnimation();
	
	local layout = self.Layout;	
	local windowName = self:GetName();
	WindowSetAlpha(windowName, 1);
	WindowSetAlpha(windowName .. "Background", layout.Background.Alpha or 1);
	WindowSetAlpha(windowName .. "Fill", layout.Fill.Alpha or 1);
	WindowSetAlpha(windowName .. "Icon", layout.Icon.Alpha or 1);
	WindowSetFontAlpha(windowName .. "Name", layout.Name.Alpha);
	WindowSetFontAlpha(windowName .. "Timer", layout.Timer.Alpha);
end

function Obsidian.EffectBar:SetScale(scale)
	local windowName = self:GetName();
	WindowSetScale(windowName, scale);
	if (self.Layout.Name.Scale) then
		WindowSetScale(windowName .. "Name", self.Layout.Name.Scale * scale);
	end
	if (self.Layout.Timer.Scale) then
		WindowSetScale(windowName .. "Timer", self.Layout.Timer.Scale * scale);
	end
	if (self.Layout.Icon.Scale) then
		WindowSetScale(windowName .. "Icon", self.Layout.Icon.Scale * scale);
	end
end

function Obsidian.EffectBar:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)
	WindowClearAnchors(self:GetName());
	WindowAddAnchor(self:GetName(), pointOnAnchor, anchorFrame, pointOnSelf, xOffset, yOffset);
end

local function SetFill(self, color)
	if (IsColorEqual(color, self.Values.Fill.Color)) then return end
	self.Values.Fill.Color = color;
	WindowSetTintColor(self:GetName() .. "Fill", color.R, color.G, color.B);
end

local function SetIcon(self, texture)
	local iconName = self:GetName() .. "Icon";
	local iconLayout = self.Layout.Icon;
	local showing = false;
	
	if (texture ~= "icon000000") then
		showing = true;
		if (self.Values.Icon ~= texture) then
			self.Values.Icon = texture;
			DynamicImageSetTexture(iconName, texture, 0, 0);
		end
	end
	
	if (iconLayout.Showing ~= showing) then
		iconLayout.Showing = showing;
		WindowSetShowing(iconName, showing);
	end
end

local function SetName(self, name)
	local nameLabel = self:GetName() .. "Name";
	local displayName = name;
	
	if (self.Values.Name.Override) then
		displayName = self.Values.Name.Override;
		self.Values.Name.Override = nil;
	end
	
	if (type(displayName) ~= "wstring") then
		displayName = towstring(displayName);
	end
	
	if (self.Values.Name.Text ~= displayName) then
		self.Values.Name.Text = displayName;
		LabelSetText(nameLabel, displayName);
	end
end

local function FormatTime(value)
	local value = math.max(0, value);
	
	--[[
		Note: The space on the end of the format is magic and keeps the
		text from bouncing when #.1 is hit
	--]]
	
	if (value <= 9.9) then
		-- seconds
		return string.format("%.1f ", value);
	elseif (value < 60) then
		-- seconds
		return string.format("%d ", value);
	elseif (value < 3599) then
		-- minutes
		return string.format("%dm ", value / 60);
	else
		-- hours
		return string.format("%dh ", value / 3600);
	end
end

local function SetTimer(self, value, maximum)
	local displayValue = towstring(FormatTime(value)); 
	if (self.Values.Timer.Text == displayValue) then return end
	self.Values.Timer.Text = displayValue;
	LabelSetText(self:GetName() .. "Timer", displayValue);
end

local function ResizeFill(self, value, maximum)
	local percent = math.min(1, value / maximum);
	local priority = self.GeneralSettings.Fill.Priority;
	
	if (priority == Obsidian.EffectBar.FillPriority.Low) then
		percent = math.floor(percent * 10) / 10;
	elseif (priority == Obsidian.EffectBar.FillPriority.Normal) then
		percent = math.floor(percent * 100) / 100;
	end
	
	if (self.Values.Fill.Value == percent) then return end
	self.Values.Fill.Value = percent;
	
	WindowSetDimensions(self:GetName() .. "Fill", self.Layout.Fill.Size.Width * percent, self.Layout.Fill.Size.Height);
	
	local textureDimensions = self.GeneralSettings.Fill.TextureDimensions;
	DynamicImageSetTextureDimensions(self:GetName() .. "Fill", textureDimensions.Width * percent, textureDimensions.Height);
end

function Obsidian.EffectBar:Hide(hideNow)
	if (not self.Effect) then return end

--[[	
	if (hideNow) then
		self:Show(false);
	else
		self:FadeOut(HIDE_DURATION);
	end
--]]

	self:Show(false);
	self.Effect = nil;
end

function Obsidian.EffectBar:ShowEffect(abilityData)
	local ability = abilityData.Data;
	local abilityId = ability.abilityId;
	local maximum = ability.duration;
	local duration = ability.duration - (Obsidian.SystemTime - abilityData.TimeAdded);

	if (self.Values.Ability ~= abilityId) then
		self.Values.Ability = abilityId;
		if (self.Layout.Icon.Enabled) then
			local icon = ability.iconNum;			
			local texture = GetIconData(icon);
			SetIcon(self, texture);
		end
		
		if (self.Layout.Name.Enabled) then
			SetName(self, ability.name or L"");
		end
	end
	
	self.Effect =
	{
		AbilityData = abilityData,
		Current = duration,
		Maximum = maximum,
	};
	
	local color = { R = 0, G = 0, B = 0 };
	local fillType = self.Settings.FillType;
	
	if (fillType == FillType.Custom) then
		color = self.Settings.Color;
	elseif (fillType == FillType.BuffDebuff) then
		color = DefaultColor.AbilityType.BUFF;
		if (abilityData.Type == Obsidian.EffectContainer.EffectType.Debuff) then
			color = DefaultColor.AbilityType.DEBUFF
		end
		color = { R = color.r, G = color.g, B = color.b };
	else -- effect type
		local _, _, _, red, green, blue = DataUtils.GetAbilityTypeTextureAndColor(abilityData.Data);
		if (red and green and blue) then
			color = { R = red, G = green, B = blue };
		end
	end
			
	SetFill(self, color);
	ResizeFill(self, duration, self.Layout.FixedDuration or maximum);
	
	self:ResetAlpha();
	self:Show(true);
end

function Obsidian.EffectBar:Update(elapsed)
	local effect = self.Effect;
	if (not effect) then return end
	
	effect.Current = effect.Current - elapsed;
	
	local value, maximum = effect.Current, effect.Maximum;

	if (self.Layout.Timer.Enabled) then
		SetTimer(self, value);
	end

	if (value > maximum or value < 0) then
		ResizeFill(self, 0, self.Layout.FixedDuration or maximum);
		self.Parent:RemoveEffect(self.Effect.AbilityData.Index);
		--self:Hide(false);
	else
		ResizeFill(self, value, self.Layout.FixedDuration or maximum);
	end
end