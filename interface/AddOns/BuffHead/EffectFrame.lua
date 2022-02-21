BuffHeadEffectFrame = Frame:Subclass("BuffHeadBuffTemplate");

local ANIMATED_BORDER_FRAMES = 8;
local ANIMATED_BORDER_THICK_FRAMES = 8;

local EffectType = { Buff = 1, Debuff = 2 };
local effectCount = 0;
local activeMouseOver = nil;

local WindowSetDimensions, DynamicImageSetTextureDimensions, LabelSetText, WindowClearAnchors, WindowAddAnchor, WindowSetAlpha, WindowSetFontAlpha, WindowSetParent = 
	WindowSetDimensions, DynamicImageSetTextureDimensions, LabelSetText, WindowClearAnchors, WindowAddAnchor, WindowSetAlpha, WindowSetFontAlpha, WindowSetParent;

local function ResetFrame(frame)

	frame:ResetAlpha();
		
end

local function IsColorEqual(colorA, colorB)

	if (not colorA or not colorB) then
		return false;
	end

	return (colorA.r == colorB.r and colorA.g == colorB.g and colorA.b == colorB.b);

end

local function AnchorFrame(parent, window, settings)
	local windowName = parent .. window;
	
	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, "topleft", parent, "topleft", settings.X, settings.Y);
end

local function SetupCoreFrame(parent, window, layoutSettings)
	local windowName = parent .. window;
	
	if (layoutSettings.Alpha > 0) then
		WindowSetDimensions(windowName, layoutSettings.Width, layoutSettings.Height);
		WindowClearAnchors(windowName);
		WindowAddAnchor(windowName, "topleft", parent, "topleft", layoutSettings.X, layoutSettings.Y);
		WindowSetLayer(windowName, layoutSettings.Layer);
		WindowSetShowing(windowName, true);
	else
		WindowSetShowing(windowName, false);
	end
	
	return (layoutSettings.Alpha > 0);
end

function BuffHeadEffectFrame:SetLayout(abilityData, layoutSettingsOverride, settings)

	local settingsModified = (layoutSettingsOverride ~= nil); -- only used by the demo	
	local settings = settings or BuffHead.Settings;
	local layoutSettings = layoutSettingsOverride or settings.Layout or BuffHead.Settings.Layout;
	self.Layout = self.Layout or {};
	self.StatusBar = self.StatusBar or {};
	
	local frameName = self:GetName();
	local ability = abilityData.Data;
	local statusBar = { Visible = false, Width = 0, Height = 0, Max = 0, Value = 0, Type = 0 };
	local coreSettingsChanged = false;
	
	if (self.Layout.SettingsRevision ~= BuffHead.LayoutRevision or settingsModified or self.Layout.Id ~= layoutSettings.Id) then
		self.Layout.Settings = layoutSettings;
		self.Layout.Id = layoutSettings.Id;
		self.Layout.SettingsRevision = BuffHead.LayoutRevision;
		coreSettingsChanged = true;
		
		local scale = settings.Scale * InterfaceCore.GetScale();

		WindowSetDimensions(frameName, layoutSettings.Width, layoutSettings.Height);
		
		if (SetupCoreFrame(frameName, "Icon", layoutSettings.Icon)) then
			WindowSetScale(frameName .. "Icon", scale * layoutSettings.Icon.Scale);
			WindowSetAlpha(frameName .. "IconIcon", layoutSettings.Icon.Alpha);
			
			if (layoutSettings.Icon.Border.Alpha > 0) then
				WindowSetAlpha(frameName .. "IconBorder", layoutSettings.Icon.Border.Alpha);
			end
			WindowSetShowing(frameName .. "IconBorder", (layoutSettings.Icon.Border.Alpha > 0));
		end
		
		if (layoutSettings.StatusBar.Enabled) then
			statusBar.Width = layoutSettings.StatusBar.Width;
			statusBar.Height = layoutSettings.StatusBar.Height;
			statusBar.Type = layoutSettings.StatusBar.Orientation;
			statusBar.Visible = true;
			
			WindowSetDimensions(frameName .. "StatusBar", statusBar.Width, statusBar.Height);
			AnchorFrame(frameName, "StatusBar", layoutSettings.StatusBar);
			WindowSetScale(frameName .. "StatusBar", scale * layoutSettings.StatusBar.Scale);
			
			WindowClearAnchors(frameName .. "StatusBarForeground");
			if (layoutSettings.StatusBar.Reverse) then
				WindowAddAnchor(frameName .. "StatusBarForeground", "bottomright", frameName .. "StatusBar", "bottomright", 0, 0);
			else
				WindowAddAnchor(frameName .. "StatusBarForeground", "topleft", frameName .. "StatusBar", "topleft", 0, 0);
			end
			WindowSetDimensions(frameName .. "StatusBarForeground", statusBar.Width, statusBar.Height);
			WindowSetAlpha(frameName .. "StatusBarForeground", layoutSettings.StatusBar.Foreground.Alpha);
			DynamicImageSetTexture(frameName .. "StatusBarForeground", layoutSettings.StatusBar.Foreground.Texture, 0, 0);
			DynamicImageSetTextureDimensions(frameName .. "StatusBarForeground", layoutSettings.StatusBar.Foreground.TextureDimensions.Width, layoutSettings.StatusBar.Foreground.TextureDimensions.Height);
			
			WindowSetAlpha(frameName .. "StatusBarBackground", layoutSettings.StatusBar.Background.Alpha);
			DynamicImageSetTexture(frameName .. "StatusBarBackground", layoutSettings.StatusBar.Background.Texture, 0, 0);
			DynamicImageSetTextureDimensions(frameName .. "StatusBarBackground", layoutSettings.StatusBar.Background.TextureDimensions.Width, layoutSettings.StatusBar.Background.TextureDimensions.Height);
			local color = layoutSettings.StatusBar.Background.Color;
			WindowSetTintColor(frameName .. "StatusBarBackground", color.R, color.G, color.B);
			
			WindowSetLayer(frameName .. "StatusBar", layoutSettings.StatusBar.Layer);
		end
		WindowSetShowing(frameName .. "StatusBar", layoutSettings.StatusBar.Enabled);
		WindowSetShowing(frameName .. "StatusBarBackground", layoutSettings.StatusBar.Enabled);
		
		if (SetupCoreFrame(frameName, "Time", layoutSettings.Duration)) then
			WindowSetScale(frameName .. "Time", scale * layoutSettings.Duration.Scale);
			LabelSetFont(frameName .. "Time", layoutSettings.Duration.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
			LabelSetTextAlign(frameName .. "Time", layoutSettings.Duration.Alignment);
			WindowSetFontAlpha(frameName .. "Time", layoutSettings.Duration.Alpha);
			local color = layoutSettings.Duration.Color;
			LabelSetTextColor(frameName .. "Time", color.R, color.G, color.B);
		end
		self.Layout.Duration = (layoutSettings.Duration.Alpha > 0);
		
		if (SetupCoreFrame(frameName, "Stacks", layoutSettings.StackCount)) then
			WindowSetScale(frameName .. "Stacks", scale * layoutSettings.StackCount.Scale);
			LabelSetFont(frameName .. "Stacks", layoutSettings.StackCount.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
			LabelSetTextAlign(frameName .. "Stacks", layoutSettings.StackCount.Alignment);
			WindowSetFontAlpha(frameName .. "Stacks", layoutSettings.StackCount.Alpha);
			local color = layoutSettings.StackCount.Color;
			LabelSetTextColor(frameName .. "Stacks", color.R, color.G, color.B);
		end
		self.Layout.StackCount = (layoutSettings.StackCount.Alpha > 0);
		
		if (SetupCoreFrame(frameName, "Name", layoutSettings.Name)) then
			WindowSetScale(frameName .. "Name", scale * layoutSettings.Name.Scale);
			LabelSetFont(frameName .. "Name", layoutSettings.Name.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
			LabelSetTextAlign(frameName .. "Name", layoutSettings.Name.Alignment);
			WindowSetFontAlpha(frameName .. "Name", layoutSettings.Name.Alpha);
			local color = layoutSettings.Name.Color;
			LabelSetTextColor(frameName .. "Name", color.R, color.G, color.B);
		end
		self.Layout.Name = (layoutSettings.Name.Alpha > 0);
		
	end
	
	if (ability.permanentUntilDispelled) then
		statusBar.Visible = false;
		if (self.Values.Duration) then
			LabelSetText(frameName .. "Time", L"");
			self.Values.Duration = nil;
		end
	elseif (not statusBar.Visible and self.Layout.Settings.StatusBar.Enabled) then
		statusBar.Visible = true;
	end
	
	local displayOverlay = nil;
	if (ability.priority ~= nil) then
		displayOverlay = BuffHead.Settings.PriorityEffects.Animation;
	end
	
	if (self.Layout.Overlay ~= displayOverlay or coreSettingsChanged) then
		self.Layout.Overlay = displayOverlay;
		if (displayOverlay) then
			self.Layout.OverlayFrame = 1;
			
			if (displayOverlay == BuffHead.PriorityAnimation.AnimatedBorder) then
				DynamicImageSetTexture(frameName .. "IconOverlay", "BuffHead_Effect_Border_Frame1", 0, 0);
			elseif (displayOverlay == BuffHead.PriorityAnimation.AnimatedBorder) then
				DynamicImageSetTexture(frameName .. "IconOverlay", "BuffHead_Effect_Border_Thick_Frame1", 0, 0);
			end
			
			if (displayOverlay ~= BuffHead.PriorityAnimation.None) then
				if (layoutSettings.Icon.Border.Alpha > 0) then
					WindowSetShowing(frameName .. "IconBorder", false);
				end
			else
				if (layoutSettings.Icon.Border.Alpha > 0) then
					WindowSetShowing(frameName .. "IconBorder", true);
				end
			end
		else
			if (layoutSettings.Icon.Border.Alpha > 0) then
				WindowSetShowing(frameName .. "IconBorder", true);
			end
		end
		WindowSetShowing(frameName .. "IconOverlay", (displayOverlay ~= nil and displayOverlay ~= BuffHead.PriorityAnimation.None));
	end
	
	if (displayOverlay) then
		-- color animated border as if it were the border
		local color = nil;
		if (displayOverlay == BuffHead.PriorityAnimation.AnimatedBorder or displayOverlay == BuffHead.PriorityAnimation.AnimatedBorderThick) then
			if (layoutSettings.Icon.Border.Type == BuffHead.ColorType.EffectColor) then
				color = abilityData.Data.color;
			elseif (layoutSettings.Icon.Border.Type == BuffHead.ColorType.EffectType) then
				if (abilityData.Type == EffectType.Debuff) then
					color = DefaultColor.AbilityType.DEBUFF
				else
					color = DefaultColor.AbilityType.BUFF;
				end
			elseif (layoutSettings.Icon.Border.Type == BuffHead.ColorType.Custom) then
				color = layoutSettings.Icon.Border.Color;
				color = { r = color.R, g = color.G, b = color.B };
			end
			
			color = color or { r = 0, g = 0, b = 0 };
		end
			
		if (color and not IsColorEqual(self.Layout.OverlayColor, color)) then
			WindowSetTintColor(frameName .. "IconOverlay", color.r, color.g, color.b);
			self.Layout.OverlayColor = color;
		end
	end
	
	if (statusBar.Visible) then
		statusBar.Max = abilityData.Duration;
	end
	
	if (self.StatusBar.Visible ~= statusBar.Visible) then
		WindowSetShowing(frameName .. "StatusBar", (statusBar.Visible == true));
	end
	
	if (coreSettingsChanged) then
		self.StatusBar = statusBar;
	else
		self.StatusBar.Max = abilityData.Duration;
		self.StatusBar.Visible = statusBar.Visible;
	end
	
	if (layoutSettings.Icon.Border.Alpha > 0) then
		local color = nil;
		
		if (layoutSettings.Icon.Border.Type == BuffHead.ColorType.EffectColor) then
			color = abilityData.Data.color;
		elseif (layoutSettings.Icon.Border.Type == BuffHead.ColorType.EffectType) then
			if (abilityData.Type == EffectType.Debuff) then
				color = DefaultColor.AbilityType.DEBUFF
			else
				color = DefaultColor.AbilityType.BUFF;
			end
		elseif (layoutSettings.Icon.Border.Type == BuffHead.ColorType.Custom) then
			color = layoutSettings.Icon.Border.Color;
			color = { r = color.R, g = color.G, b = color.B };
		end
		
		color = color or { r = 0, g = 0, b = 0 };
		
		if (not IsColorEqual(self.Layout.BorderColor, color)) then
			WindowSetTintColor(frameName .. "IconBorder", color.r, color.g, color.b);
			self.Layout.BorderColor = color;
		end
	end
	
	if (ability.iconTexture) then
		if (self.Layout.Icon ~= ability.iconTexture) then
			DynamicImageSetTexture(frameName .. "IconIcon", ability.iconTexture, 0, 0);
			self.Layout.Icon = ability.iconTexture;
		end
	else
		if (self.Layout.Icon ~= ability.iconNum) then
			local tex, texX, texY = GetIconData(ability.iconNum);
			DynamicImageSetTexture(frameName .. "IconIcon", tex, texX, texY);
			self.Layout.Icon = ability.iconNum;
		end
	end
	
	if (self.Layout.Name) then
		local name = ability.name or L"";
		if (self.Values.Name ~= name) then
			self.Values.Name = name;
			LabelSetText(frameName .. "Name", name);
		end
	end
	
	if (statusBar.Visible) then
		local color = nil;
		
		if (layoutSettings.StatusBar.Foreground.Type == BuffHead.ColorType.EffectColor) then
			color = abilityData.Data.color;
		elseif (layoutSettings.StatusBar.Foreground.Type == BuffHead.ColorType.EffectType) then
			if (abilityData.Type == EffectType.Debuff) then
				color = DefaultColor.AbilityType.DEBUFF
			else
				color = DefaultColor.AbilityType.BUFF;
			end
		elseif (layoutSettings.StatusBar.Foreground.Type == BuffHead.ColorType.Custom) then
			color = layoutSettings.StatusBar.Foreground.Color;
			color = { r = color.R, g = color.G, b = color.B };
		end
		
		color = color or { r = 0, g = 0, b = 0 };
	
		if (not IsColorEqual(self.Layout.StatusBarColor, color)) then
			WindowSetTintColor(frameName .. "StatusBarForeground", color.r, color.g, color.b);
			self.Layout.StatusBarColor = color;
		end
	end
	
	if (self.Layout.Scale ~= settings.Scale) then
		self.Layout.Scale = settings.Scale;
		WindowSetScale(frameName, settings.Scale * InterfaceCore.GetScale());
	end

end

function BuffHeadEffectFrame:Create(parent, effect, handleInput)
	--d("buffhead effect frame create")
	local frame = BuffHead.FrameManager.GetFrame();
	--d("get frame check")
	if (not frame) then
		effectCount = effectCount + 1;
		local frameName = "BuffHeadEffectFrame" .. effectCount;

		--frame = self:CreateFromTemplate(frameName, "Root");
		frame = self:CreateFromTemplate(frameName, "RootFrame");
		frame.Values = 
		{
			Duration = nil,
			Stacks = 0,
			Name = nil,
		};
		frame.Alpha = 1;
		frame.HandleInput = handleInput;
		WindowSetHandleInput(frameName, (handleInput == true));
	else
		--d("frame not nil")
		if ((frame.HandleInput or false) ~= (handleInput or false)) then		
			frame.HandleInput = handleInput;
			WindowSetHandleInput(frame:GetName(), (handleInput == true));
		end
		ResetFrame(frame);
	end
	if (effect) then
		--d("effect not nil")
		local settings = nil;
		if (parent) then
			settings = parent.Settings;
		end
		
		frame.AbilityData = effect.AbilityData;
		if (settings and frame.HandleInput) then
			frame.ShowTooltips = settings.ShowTooltips;
			local handleRemovable = nil;
			if (settings.HandleRemovable) then
				handleRemovable = (parent.Parent.TargetType == BuffHead.TargetType.Self);
			end
			frame.HandleRemovable = handleRemovable;
		end
		frame:SetLayout(effect.AbilityData, nil, settings);
	end
	
	if (parent) then
		--d("parent not nil")
		WindowSetParent(frame:GetName(), parent:GetName());
	end
	--d("returning frame")
	--d(frame.m_Name)
	return frame;
	
end

function BuffHeadEffectFrame:Update()
	if (not self.Layout.Overlay) then return end
	
	-- note that time calculations are done by the container to reduce the possibility of a large useless loop to occur every few milliseconds
	if (self.Layout.Overlay == BuffHead.PriorityAnimation.AnimatedBorder) then
		local frame = ((self.Layout.OverlayFrame or 0) % ANIMATED_BORDER_FRAMES) + 1;
		self.Layout.OverlayFrame = frame;
	
		DynamicImageSetTexture(self:GetName() .. "IconOverlay", "BuffHead_Effect_Border_Frame" .. frame, 0, 0);
	elseif (self.Layout.Overlay == BuffHead.PriorityAnimation.AnimatedBorderThick) then
		local frame = ((self.Layout.OverlayFrame or 0) % ANIMATED_BORDER_THICK_FRAMES) + 1;
		self.Layout.OverlayFrame = frame;
	
		DynamicImageSetTexture(self:GetName() .. "IconOverlay", "BuffHead_Effect_Border_Thick_Frame" .. frame, 0, 0);
	end
end

function BuffHeadEffectFrame:OnRButtonDown(flags, mouseX, mouseY)
	if (not self.HandleRemovable or not self.AbilityData) then return end
	RemoveEffect(self.AbilityData.Index);
end

function BuffHeadEffectFrame:OnMouseOver(flags, mouseX, mouseY)
	if (not self.ShowTooltips) then return end
	local buffData = self.AbilityData.Data.source;
	activeMouseOver = buffData;

	Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name, nil);
	Tooltips.SetTooltipColorDef(1, 1, Tooltips.COLOR_HEADING);
	Tooltips.SetTooltipColorDef(1, 2, Tooltips.COLOR_HEADING);
	Tooltips.SetTooltipActionText(GetString(StringTables.Default.TEXT_R_CLICK_TO_REMOVE_EFFECT));
	
	BuffFrame.PopulateTooltipFields(buffData, true);
	
	local tooltipAnchor = { Point = "bottom",  RelativeTo = self:GetName(), RelativePoint = "top", XOffset = 0, YOffset = 20 };
	
	Tooltips.AnchorTooltip(tooltipAnchor);
	Tooltips.SetUpdateCallback(BuffHeadEffectFrame.MouseOverUpdate);
end

function BuffHeadEffectFrame.MouseOverUpdate()
	if (not activeMouseOver) then return end
	BuffFrame.PopulateTooltipFields(activeMouseOver, false);
end

function BuffHeadEffectFrame:OnMouseOverEnd(flags, mouseX, mouseY)
	activeMouseOver = nil;
end

function BuffHeadEffectFrame:SetAbility(abilityData)
	self.AbilityData = abilityData.AbilityData;
	self:SetLayout(abilityData.AbilityData);
end

function BuffHeadEffectFrame:Destroy()
        --d("effect frame destroy 1")
	--d(self:GetName())
	-- Note that we don't actually want to destroy the window, since it can cause lag	
	if (BuffHead.Settings.Fading.Enable) then
		self:StopAlphaAnimation();
	end

	self:Show(false);
	WindowClearAnchors(self:GetName());
	--WindowSetParent(self:GetName(), "Root");
	WindowSetParent(self:GetName(), "RootFrame");
	BuffHead.FrameManager.ReleaseFrame(self);
	--d("-effect frame destroy 1")	
    --FrameManager:Remove(self:GetName()); -- The FrameManager can cause the game to lag/pause for a second

end

function BuffHeadEffectFrame:SetShowing(showing)
	if (self:IsShowing() ~= showing) then
		self:Show(showing);
	end
end

function BuffHeadEffectFrame:FadeOut(duration)
	if (self.Alpha == 0.1) then return end
	self.Alpha = 0.1;
	self:StopAlphaAnimation();
	self:StartAlphaAnimation(Window.AnimationType.EASE_OUT, 1, 0.1, duration, 0, 0);
end

function BuffHeadEffectFrame:ResetAlpha()
	if (self.Alpha == 1) then return end
	self.Alpha = 1;
	self:StopAlphaAnimation();
	
	-- Since reseting the frame's alpha using the animation would randomly fail, each
	-- window will have to be manually reset
	local layoutSettings = self.Layout.Settings;
	local windowName = self:GetName();
	WindowSetAlpha(windowName, 1);
	--WindowSetAlpha(windowName .. "Icon", 1);
	WindowSetAlpha(windowName .. "IconIcon", layoutSettings.Icon.Alpha);
	WindowSetAlpha(windowName .. "IconBorder", layoutSettings.Icon.Border.Alpha);
	WindowSetAlpha(windowName .. "IconOverlay", 1);
	WindowSetFontAlpha(windowName .. "Stacks", layoutSettings.StackCount.Alpha);
	--WindowSetAlpha(windowName .. "StatusBar", 1);
	WindowSetAlpha(windowName .. "StatusBarForeground", layoutSettings.StatusBar.Foreground.Alpha);
	WindowSetAlpha(windowName .. "StatusBarBackground", layoutSettings.StatusBar.Background.Alpha);
	WindowSetFontAlpha(windowName .. "Time", layoutSettings.Duration.Alpha);
	WindowSetFontAlpha(windowName .. "Name", layoutSettings.Name.Alpha);
end

function BuffHeadEffectFrame:AnchorTo(anchorFrame, pointOnAnchor, pointOnSelf, xOffset, yOffset)

	WindowClearAnchors(self:GetName());
	WindowAddAnchor(self:GetName(), pointOnAnchor, anchorFrame, pointOnSelf, xOffset, yOffset);

end

function BuffHeadEffectFrame:SetStackCount(stackCount)

	if (not self.Layout.StackCount) then return end
	
	if (not stackCount or stackCount <= 1) then
		stackCount = 0;
	end

	if (self.Values.Stacks == stackCount) then
		return;
	end
	self.Values.Stacks = stackCount;
	
	local text = "";
	if (stackCount > 1) then
		text = "x" .. stackCount;
	end
	LabelSetText(self:GetName() .. "Stacks", towstring(text));

end

local function FormatTime(time, format)

	local timeString = "";
	local timeEnding = nil;
	local showSeconds = true;
	
	if (time > 90) then
		if (time >= 3600) then
			if (time >= 86400) then
				-- days
				time = math.floor(time / 86400);
				timeEnding = "d";
			else
				-- hours
				time = math.floor(time / 3600);
				timeEnding = "h";
			end
		else
			-- minutes
			time = math.floor(time / 60);
			timeEnding = "m";
		end
	else
		timeEnding = "s";
	end
	
	if (format == BuffHead.Display.Duration.Format.SimpleWithSeconds) then -- 0s
		timeString = ("%d"):format(time);
	elseif (format == BuffHead.Display.Duration.Format.CompactingWithSeconds or format == BuffHead.Display.Duration.Format.SimpleCompacting) then -- 0.#s or 0.#
		if (format == BuffHead.Display.Duration.Format.SimpleCompacting) then -- 0.#
			showSeconds = false;
		end
		local decimal = (time * 10) - (math.ceil(time) * 10);
		if (decimal == 0) then
			timeString = ("%d"):format(time);
		else
			timeString = ("%.1f"):format(time);
		end
	else -- 0.0
		timeString = ("%.1f"):format(time);
		showSeconds = false;
	end
	
	if (showSeconds) then
		timeString = timeString .. timeEnding;
	end
	
	return timeString;
	
end

function BuffHeadEffectFrame:SetStatusBar(timeLeft)

	if (not self.StatusBar or not self.StatusBar.Visible) then return end
	
	local percent = math.max(math.min(timeLeft / self.StatusBar.Max or 1, 1), 0);
	
	if (self.StatusBar.Type == BuffHead.Display.StatusBar.Orientation.Horizontal) then
		local value = math.floor(percent * self.StatusBar.Width);
		if (value == self.StatusBar.Value) then return end
		self.StatusBar.Value = value;
		
		WindowSetDimensions(self:GetName() .. "StatusBarForeground", value, self.StatusBar.Height);
		
		if (not self.Layout.Settings.StatusBar.Foreground.Stretch) then
			local textureDimensions = self.Layout.Settings.StatusBar.Foreground.TextureDimensions;
			DynamicImageSetTextureDimensions(self:GetName() .. "StatusBarForeground", textureDimensions.Width * percent, textureDimensions.Height);
		end
	elseif (self.StatusBar.Type == BuffHead.Display.StatusBar.Orientation.Vertical) then
		local value = math.floor(percent * self.StatusBar.Height);
		if (value == self.StatusBar.Value) then return end
		self.StatusBar.Value = value;
		
		WindowSetDimensions(self:GetName() .. "StatusBarForeground", self.StatusBar.Width, value);
		
		if (not self.Layout.Settings.StatusBar.Foreground.Stretch) then
			local textureDimensions = self.Layout.Settings.StatusBar.Foreground.TextureDimensions;
			DynamicImageSetTextureDimensions(self:GetName() .. "StatusBarForeground", textureDimensions.Width * percent, textureDimensions.Height);
		end
	end
	
end

function BuffHeadEffectFrame:SetDuration(timeLeft)

	self:SetStatusBar(timeLeft);

	if (not self.Layout.Duration) then return end

	local formattedTimeLeft = 0;
		
	if (timeLeft > 0) then
		if (BuffHead.Settings.Performance.PriorityUpdate and timeLeft < BuffHead.Settings.Performance.PriorityStart) then
			formattedTimeLeft = math.ceil(timeLeft / BuffHead.Settings.Performance.PriorityDelay) * BuffHead.Settings.Performance.PriorityDelay;
		else
			formattedTimeLeft = math.ceil(timeLeft / BuffHead.Settings.Performance.GeneralDelay) * BuffHead.Settings.Performance.GeneralDelay;
		end
	end
	
	local timeString = FormatTime(formattedTimeLeft, self.Layout.Settings.Duration.Format);
	
	if (self.Values.Duration == timeString) then
		return;
	end
	self.Values.Duration = timeString;
	
	LabelSetText(self:GetName() .. "Time", towstring(timeString));

end