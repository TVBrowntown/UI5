Obsidian.Castbar = Frame:Subclass("ObsidianCastbarTemplate");
Obsidian.Castbar.IconPosition = { Left = 1, Right = 2 };
Obsidian.Castbar.LatencyPosition = { Left = 1, Right = 2 };
Obsidian.Castbar.FillPriority = { Low = 1, Normal = 2, High = 3 };

local HIDE_DURATION = 0.5;
local MAX_OVERTIME = 5;
local SPARK_WIDTH = 15;

local IconPosition = Obsidian.Castbar.IconPosition;
local LatencyPosition = Obsidian.Castbar.LatencyPosition;

local itemIcons = {}

local function CacheItemIcons(abilityId)
	local itemData = DataUtils.GetItems();
	
	for index, item in ipairs(itemData) do
		if (item.bonus ~= nil and item.bonus[1] ~= nil and type(item.bonus[1].reference) == "number") then
			local id = item.bonus[1].reference;
			itemIcons[id] = item.iconNum or 0;

			if (id == abilityId) then
				return true;
			end
		end
	end

	itemIcons[abilityId] = 0; -- not found, and will not be searched for again

	return false;
end

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

local function SetLatencyPosition(self, position)
	local windowName = self:GetName();
	if (self.Layout.Latency.Position == position) then return end
	self.Layout.Latency.Position = position;
	
	if (position == LatencyPosition.Right) then
		SetAnchor(windowName .. "Latency", windowName, "right", "right", -self.Size.Border, 0);
		WindowSetLayer(windowName .. "Latency", 1);
	elseif (position == LatencyPosition.Left) then
		SetAnchor(windowName .. "Latency", windowName, "left", "left", self.Size.Border, 0);
		WindowSetLayer(windowName .. "Latency", 2);
	end
end

function Obsidian.Castbar:SetLayout()
	local castbarSettings = Obsidian.Settings.Castbar;	
	local layout = self.Layout;
	local windowName = self:GetName();
	local scale = self:GetScale();
	local width, height, borderSize = castbarSettings.Size.Width, castbarSettings.Size.Height, castbarSettings.Size.Border;
	
	self.Size = { Width = width, Height = height, Border = borderSize };
	self.Settings = castbarSettings;
	
	WindowSetDimensions(windowName, width + (borderSize * 2), height + (borderSize * 2));

	local color = castbarSettings.Background.Color;
	WindowSetAlpha(windowName .. "Background", castbarSettings.Background.Alpha);
	WindowSetTintColor(windowName .. "Background", color.R, color.G, color.B);
	DynamicImageSetTexture(windowName .. "Background", castbarSettings.Background.Texture, 0, 0);
	DynamicImageSetTextureDimensions(windowName .. "Background", castbarSettings.Background.TextureDimensions.Width, castbarSettings.Background.TextureDimensions.Height);
	
	-- UI5 SHIT --

	DynamicImageSetTexture(windowName .. "FlareBG", "CastBar_BG_UI5", 0, 0);
	DynamicImageSetTextureDimensions(windowName .. "FlareBG", 512, 80);

	--

	layout.Background.Alpha = castbarSettings.Background.Alpha;

	WindowSetAlpha(windowName .. "Fill", castbarSettings.Fill.Alpha);
	DynamicImageSetTexture(windowName .. "Fill", castbarSettings.Fill.Texture, 0, 0);
	SetAnchor(windowName .. "Fill", windowName, "left", "left", borderSize, 0);
	
	layout.Fill.Size = { Width = width, Height = height };
	layout.Fill.Alpha = castbarSettings.Fill.Alpha;
	layout.Fill.Texture = castbarSettings.Fill.Texture;
	self.Values.Fill.Color = nil;
	
	color = castbarSettings.Spark.Color;
	WindowSetDimensions(windowName .. "Spark", SPARK_WIDTH, height);
	WindowSetAlpha(windowName .. "Spark", castbarSettings.Spark.Alpha);
	WindowSetTintColor(windowName .. "Spark", color.R, color.G, color.B);
	
	layout.Spark.Alpha = castbarSettings.Spark.Alpha;
	
	if (castbarSettings.Latency.Enabled) then
		color = castbarSettings.Latency.Color;
		WindowSetAlpha(windowName .. "Latency", castbarSettings.Latency.Alpha);
		WindowSetTintColor(windowName .. "Latency", color.R, color.G, color.B);
		
		if (castbarSettings.Latency.Text.Enabled) then
			color = castbarSettings.Latency.Text.Color;
			LabelSetTextColor(windowName .. "LatencyText", color.R, color.G, color.B);
			LabelSetFont(windowName .. "LatencyText", castbarSettings.Latency.Text.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
			if (self.Alpha ~= 0) then
				WindowSetFontAlpha(windowName .. "LatencyText", castbarSettings.Latency.Text.Alpha);
			end
			WindowSetScale(windowName .. "LatencyText", castbarSettings.Latency.Text.Scale * scale);
		end
	end
	WindowSetShowing(windowName .. "Latency", (castbarSettings.Latency.Enabled == true));
	WindowSetShowing(windowName .. "LatencyText", (castbarSettings.Latency.Enabled == true and castbarSettings.Latency.Text.Enabled == true));
	
	layout.Latency.Enabled = castbarSettings.Latency.Enabled;
	layout.Latency.Showing = layout.Latency.Enabled;
	layout.Latency.Alpha = castbarSettings.Latency.Alpha;
	layout.LatencyText.Enabled = castbarSettings.Latency.Text.Enabled;
	layout.LatencyText.Alpha = castbarSettings.Latency.Text.Alpha;
	layout.LatencyText.Scale = castbarSettings.Latency.Text.Scale;

	if (castbarSettings.Timer.Enabled) then
		color = castbarSettings.Timer.Color;
		WindowSetDimensions(windowName .. "Timer", width, math.max(height, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING));
		LabelSetFont(windowName .. "Timer", castbarSettings.Timer.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
		LabelSetTextAlign(windowName .. "Timer", castbarSettings.Timer.Alignment);
		LabelSetTextColor(windowName .. "Timer", color.R, color.G, color.B);
		SetAnchor(windowName .. "Timer", windowName, "right", "right", castbarSettings.Timer.X - borderSize, castbarSettings.Timer.Y);
		WindowSetScale(windowName .. "Timer", castbarSettings.Timer.Scale * scale);
		if (self.Alpha ~= 0) then
			WindowSetFontAlpha(windowName .. "Timer", castbarSettings.Timer.Alpha);
		end
	end
	WindowSetShowing(windowName .. "Timer", (castbarSettings.Timer.Enabled == true));
	
	layout.Timer.Enabled = castbarSettings.Timer.Enabled;
	layout.Timer.Scale = castbarSettings.Timer.Scale;
	layout.Timer.Alpha = castbarSettings.Timer.Alpha;
	layout.Timer.Format = towstring("%." .. (castbarSettings.Timer.Decimals or 0) .. "f/%.1f");

	if (castbarSettings.Name.Enabled) then
		color = castbarSettings.Name.Color;
		WindowSetDimensions(windowName .. "Name", math.max(width / castbarSettings.Name.Scale * castbarSettings.Name.Width, 0), math.max(height, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING));
		LabelSetFont(windowName .. "Name", castbarSettings.Name.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
		LabelSetTextAlign(windowName .. "Name", castbarSettings.Name.Alignment);
		LabelSetTextColor(windowName .. "Name", color.R, color.G, color.B);
		SetAnchor(windowName .. "Name", windowName, "left", "left", castbarSettings.Name.X + borderSize, castbarSettings.Name.Y);
		WindowSetScale(windowName .. "Name", castbarSettings.Name.Scale * scale);
		if (self.Alpha ~= 0) then
			WindowSetFontAlpha(windowName .. "Name", castbarSettings.Name.Alpha);
		end
	end
	WindowSetShowing(windowName .. "Name", (castbarSettings.Name.Enabled == true));
	
	layout.Name.Enabled = castbarSettings.Name.Enabled;
	layout.Name.Scale = castbarSettings.Name.Scale;
	layout.Name.Alpha = castbarSettings.Name.Alpha;

	if (castbarSettings.Icon.Enabled) then
		WindowSetDimensions(windowName .. "Icon", height + (borderSize * 2), height + (borderSize * 2));
		if (castbarSettings.Icon.Position == IconPosition.Left) then
			SetAnchor(windowName .. "Icon", windowName, "left", "right", castbarSettings.Icon.X, castbarSettings.Icon.Y);
		elseif (castbarSettings.Icon.Position == IconPosition.Right) then
			SetAnchor(windowName .. "Icon", windowName, "right", "left", castbarSettings.Icon.X, castbarSettings.Icon.Y);
		end
		WindowSetScale(windowName .. "Icon", castbarSettings.Icon.Scale * scale);
		WindowSetAlpha(windowName .. "Icon", castbarSettings.Icon.Alpha);

		-- UI5 insert the Icon skin overlay ontop of the Icon --
--[[
		WindowSetDimensions(windowName .. "IconFrame", height + (borderSize * 2), height + (borderSize * 2));
		if (castbarSettings.Icon.Position == IconPosition.Left) then
			SetAnchor(windowName .. "IconFrame", windowName, "left", "right", castbarSettings.Icon.X, castbarSettings.Icon.Y);
		elseif (castbarSettings.Icon.Position == IconPosition.Right) then
			SetAnchor(windowName .. "IconFrame", windowName, "right", "left", castbarSettings.Icon.X, castbarSettings.Icon.Y);
		end
		WindowSetScale(windowName .. "IconFrame", castbarSettings.Icon.Scale * scale);
		WindowSetAlpha(windowName .. "IconFrame", castbarSettings.Icon.Alpha);
]]
		WindowAddAnchor (windowName .. "IconFrame", "center", windowName .. "Icon", "center", 0, 0)
		DynamicImageSetTexture(windowName .. "IconFrame", "CastBar_IconBorder_UI5", 0, 0);
		DynamicImageSetTextureDimensions(windowName .. "IconFrame", height + (borderSize * 2), height + (borderSize * 2));

		--

	end
	WindowSetShowing(windowName .. "Icon", (castbarSettings.Icon.Enabled == true));
	
	layout.Icon.Enabled = castbarSettings.Icon.Enabled;
	layout.Icon.Showing = layout.Icon.Enabled;
	layout.Icon.Alpha = castbarSettings.Icon.Alpha;
	layout.Icon.Scale = castbarSettings.Icon.Scale;
	
	local position = layout.Latency.Position;
	layout.Latency.Position = nil;
	if (layout.Latency.Enabled and self.Alpha == 1 and self:IsShowing() and position) then
		SetLatencyPosition(self, position);
	end	
end

function Obsidian.Castbar:Create(name)

	frame = self:CreateFromTemplate(name, "Root");
	frame.Casting = nil;
	frame.Layout = 
	{
		Background = {},
		Icon = {},
		Fill = {},
		Name = {},
		Timer = {},
		Latency = {},
		LatencyText = {},
		Spark = {},
	};
	frame.Values = 
	{
		Icon = nil,
		Timer = {},
		Fill = {},
		Background = {},
		Name = {},
		Latency = nil,
	};
	frame.Alpha = 1;
	
	frame:SetLayout();
	
	return frame;
	
end

function Obsidian.Castbar:FadeOut(duration)
	if (self.Alpha == 0) then return end
	self.Alpha = 0;
	self:StopAlphaAnimation();
	self:StartAlphaAnimation(Window.AnimationType.SINGLE_NO_RESET, 1, 0, duration, 0, 0);
end

function Obsidian.Castbar:ResetAlpha()
	if (self.Alpha == 1) then return end
	self.Alpha = 1;
	self:StopAlphaAnimation();
	
	local layout = self.Layout;	
	local windowName = self:GetName();
	WindowSetAlpha(windowName, 1);
	WindowSetAlpha(windowName .. "Background", layout.Background.Alpha or 1);
	WindowSetAlpha(windowName .. "Fill", layout.Fill.Alpha or 1);
	WindowSetAlpha(windowName .. "Latency", layout.Latency.Alpha or 1);
	WindowSetAlpha(windowName .. "Icon", layout.Icon.Alpha or 1);
	WindowSetAlpha(windowName .. "Spark", layout.Spark.Alpha or 1);
	WindowSetFontAlpha(windowName .. "Name", layout.Name.Alpha);
	WindowSetFontAlpha(windowName .. "Timer", layout.Timer.Alpha);
	WindowSetFontAlpha(windowName .. "LatencyText", layout.LatencyText.Alpha or 1);
end

function Obsidian.Castbar:SetScale(scale)
	local windowName = self:GetName();
	WindowSetScale(windowName, scale);
	if (self.Layout.LatencyText.Scale) then
		WindowSetScale(windowName .. "LatencyText", self.Layout.LatencyText.Scale * scale);
	end
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

function Obsidian.Castbar:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)
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
		if (displayName:len() == 0) then
			-- only override if the casting spell has no name
			-- this is done to fix the error that can occur by an override being set, but not activating ie, mounting and trying to 
			-- salvage at the same time, forcing the next cast to display as salvaging even though it isn't
			displayName = self.Values.Name.Override;
		end
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

local function SetTimer(self, value, maximum)
	local displayValue = wstring.format(self.Layout.Timer.Format or L"%.1f/%.1f", value, maximum); 
	if (self.Values.Timer.Text == displayValue) then return end
	self.Values.Timer.Text = displayValue;
	LabelSetText(self:GetName() .. "Timer", displayValue);
end

local function ResizeLatency(self, value, maximum)
	local percent = math.min(1, value / maximum);
	if (self.Values.Latency == percent) then return end
	self.Values.Latency = percent;
	
	LabelSetText(self:GetName() .. "LatencyText", towstring(string.format("%dms", value * 1000)));
	WindowSetDimensions(self:GetName() .. "Latency", self.Layout.Fill.Size.Width * percent, self.Layout.Fill.Size.Height);

	local textureDimensions = self.Settings.Fill.TextureDimensions;
	if (self.Layout.Latency.Position == LatencyPosition.Right) then
		DynamicImageSetTexture(self:GetName() .. "Latency", self.Layout.Fill.Texture, textureDimensions.Width - (textureDimensions.Width * percent), 0);
	else
		DynamicImageSetTexture(self:GetName() .. "Latency", self.Layout.Fill.Texture, 0, 0);
	end
	DynamicImageSetTextureDimensions(self:GetName() .. "Latency", textureDimensions.Width * percent, textureDimensions.Height);
end

local function ResizeFill(self, value, maximum)
	local percent = math.min(1, value / maximum);
	local priority = self.Settings.Fill.Priority;
	
	if (priority == Obsidian.Castbar.FillPriority.Low) then
		percent = math.floor(percent * 10) / 10;
	elseif (priority == Obsidian.Castbar.FillPriority.Normal) then
		percent = math.floor(percent * 100) / 100;
	end
	
	if (self.Values.Fill.Value == percent) then return end
	self.Values.Fill.Value = percent;
	
	WindowSetDimensions(self:GetName() .. "Fill", self.Layout.Fill.Size.Width * percent, self.Layout.Fill.Size.Height);
	
	local textureDimensions = self.Settings.Fill.TextureDimensions;
	DynamicImageSetTextureDimensions(self:GetName() .. "Fill", textureDimensions.Width * percent, textureDimensions.Height);
	
	-- this isn't actually required. when done automatically, the frame is moved the update after, causing a minor lag feeling
	SetAnchor(self:GetName() .. "Spark", self:GetName() .. "Fill", "right", "left", -8, 0);
end

local function SetLatency(self)
	local showing = false;
	
	if (Obsidian.Latency) then
		local casting = self.Casting;
		if (casting.Channeled) then
			SetLatencyPosition(self, LatencyPosition.Left);
		else
			SetLatencyPosition(self, LatencyPosition.Right);
		end
		ResizeLatency(self, Obsidian.Latency, casting.Maximum);
		showing = true;
	end	
	
	if (self.Layout.Latency.Showing ~= showing) then
		self.Layout.Latency.Showing = showing;
		WindowSetShowing(self:GetName() .. "Latency", showing);
	end
end

function Obsidian.Castbar:Hide(failed)
	if (not self.Casting) then return end
	
	if (failed) then
		SetFill(self, self.Settings.Fill.Colors.Failed);
	else
		local maximum = self.Casting.Current, self.Casting.Maximum;
		ResizeFill(self, maximum, maximum);
		SetFill(self, self.Settings.Fill.Colors.Success);
	end
	self:FadeOut(HIDE_DURATION);
	self.Casting = nil;
end

function Obsidian.Castbar:SetName(name, override)
	if (self.Layout.Name.Enabled) then
		if (override) then
			self.Values.Name.Override = name;
		else
			SetName(self, name);
		end
	end
end

function Obsidian.Castbar:UpdateOutOfRangeState(outOfRange)
	if (outOfRange) then
		SetFill(self, self.Settings.Range.Color);
	else
		if (self.Casting and self.Casting.Channeled) then
			SetFill(self, self.Settings.Fill.Colors.Channeled);
		else
			SetFill(self, self.Settings.Fill.Colors.Normal);
		end
	end
end

function Obsidian.Castbar:StartInteraction()
	self.Casting =
	{
		Current = 0,
		Maximum = GameData.InteractTimer.time,
		Channeled = false,
	};
	
	if (self.Layout.Name.Enabled) then
		SetName(self, GameData.InteractTimer.objectName);
	end
	SetFill(self, self.Settings.Fill.Colors.Normal);
	SetLatencyPosition(self, LatencyPosition.Right);
	ResizeFill(self, 0, self.Casting.Maximum);
		
	self:ResetAlpha();
	self:Show(true);
end

function Obsidian.Castbar:StartCasting(abilityId, isChannel, castTime, holdCastBar)
	if (castTime == 0) then return end

	if (self.Values.Ability ~= abilityId) then
		self.Values.Ability = abilityId;
		if (self.Layout.Icon.Enabled) then
			local abilityData = GetAbilityData(abilityId);
			local icon = abilityData.iconNum;
		
			if (abilityData.id == 0) then
				-- is an item
				if (itemIcons[abilityId] == nil) then
					CacheItemIcons(abilityId);
				end
				icon = itemIcons[abilityId];
			end
			
			local texture = GetIconData(icon);
			SetIcon(self, texture);
		end
	end
		
	if (self.Layout.Name.Enabled) then
		local name = GetAbilityName(abilityId) or L"";
		SetName(self, name);
	end
	
	--[[
	if (self.Casting and self.Casting.Current > 1 and self.Casting.Current < castTime) then
		self.Casting.Maximum = castTime + (castTime - self.Casting.Current);
	else
		-- below part was here
	end
	--]]
	
	self.Casting =
	{
		Ability = abilityId,
		Current = 0,
		Maximum = castTime,
		Channeled = isChannel,
	};
		
	if (self.Layout.Latency.Enabled) then
		SetLatency(self);
	end
	
	local value = 0;
	if (isChannel) then
		value = castTime;
	end
	
	if (isChannel) then
		SetFill(self, self.Settings.Fill.Colors.Channeled);
	else
		SetFill(self, self.Settings.Fill.Colors.Normal);
	end
	ResizeFill(self, value, castTime);
	
	self:ResetAlpha();
	self:Show(true);
end

function Obsidian.Castbar:Setback(time)
	if (not self.Casting) then return end
	self.Casting.Current = math.max(0, self.Casting.Maximum - time);
end

function Obsidian.Castbar:Update(elapsed)
	local casting = self.Casting;
	if (not casting) then return end
	
	casting.Current = casting.Current + elapsed;
		
	if (casting.Current - casting.Maximum > MAX_OVERTIME) then
		self:Hide();
		return;
	end
	
	local value, maximum = casting.Current, casting.Maximum;
	if (casting.Channeled) then
		value = maximum - value;
	end
	if (self.Layout.Timer.Enabled) then
		SetTimer(self, value, maximum);
	end

	if (value > maximum or value < 0) then
		if (casting.Channeled) then
			value = 0;
		else
			value = maximum;
		end
		ResizeFill(self, value, maximum);
		if (self.Settings.Accurate) then
			self:Hide(false);
		end
	else
		ResizeFill(self, value, maximum);
	end
end