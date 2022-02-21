BuffHead.Setup.LayoutFrame = Frame:Subclass("BuffHeadLayoutFrameWindow");

function BuffHead.Setup.LayoutFrame:Create(windowName, parentWindow, id, displayName, settings, allowScaling)
	local frame = self:CreateFromTemplate(parentWindow .. "Edit" .. windowName, parentWindow);

	local labelName = frame:GetName() .. "Name";
	LabelSetText(labelName, displayName or L"");
	
	local width, height, scale = settings.Width or 10, settings.Height or 10, settings.Scale or 1;
	
	frame.isActive = false;
	frame.isLocked = false;
	frame.Size = { Width = width, Height = height };
	frame.Scale = scale;
	frame.Settings = settings;
	frame.FrameId = id;
	frame.AllowScaling = allowScaling;
	
    local interfaceScale = InterfaceCore.GetScale();
    local frameWidth = width * scale;
    local frameHeight = height * scale;
    frame:SetDimensions(frameWidth, frameHeight);
	
	frame:UpdateFrameColor();
	
	return frame
end

function BuffHead.Setup.LayoutFrame:IsActive()
	return (self.isActive ~= false);
end

function BuffHead.Setup.LayoutFrame:IsLocked()
	return self.isLocked;
end

function BuffHead.Setup.LayoutFrame:SetActive(active)
	self.isActive = active;
	self:UpdateFrameColor();
end

function BuffHead.Setup.LayoutFrame:SetLocked(locked)
	self.isLocked = locked;
	self:UpdateFrameColor();
end

function BuffHead.Setup.LayoutFrame:UpdateFrameColor()
	local frameColor = nil;
	local backgroundColor = nil;
	local nameColor = nil;
	
	if (self.isLocked) then
		frameColor =  LayoutFrame.FRAME_COLOR_HIDDEN;
		backgroundColor = LayoutFrame.BACKGROUND_COLOR_HIDDEN;
		nameColor = LayoutFrame.NAME_COLOR_HIDDEN;
	elseif (self.isActive) then
		frameColor =  LayoutFrame.FRAME_COLOR_ACTIVE;
		backgroundColor = LayoutFrame.BACKGROUND_COLOR_ACTIVE;
		nameColor = LayoutFrame.NAME_COLOR_ACTIVE;
	else
		frameColor = LayoutFrame.FRAME_COLOR_UNLOCKED;     
		backgroundColor = LayoutFrame.BACKGROUND_COLOR_UNLOCKED;
		nameColor = LayoutFrame.NAME_COLOR_UNLOCKED;
	end

	DefaultColor.SetWindowTint(self:GetName() .. "Frame", frameColor);
	DefaultColor.SetWindowTint(self:GetName() .. "Background", backgroundColor);
	DefaultColor.SetLabelColor(self:GetName() .. "Name", nameColor);
end

function BuffHead.Setup.LayoutFrame:ScaleWindowToDimensions(desiredWidth, desiredHeight)
	local interfaceScale = InterfaceCore.GetScale();
	local desiredScaledWidth = desiredWidth;
	local desiredScaledHeight = desiredHeight;  
	local currentWidth, currentHeight = self.Size.Width, self.Size.Height;
	local currentScale = self.Scale;	
	local currentScaledWidth = (currentWidth * currentScale);
	local currentScaledHeight = (currentHeight * currentScale);
	
	local xScale = ((desiredScaledWidth - currentScaledWidth) + currentScaledWidth) / currentScaledWidth;
	local yScale = ((desiredScaledHeight - currentScaledHeight) + currentScaledHeight) / currentScaledHeight;
	
	local scale = math.min(xScale, yScale) * currentScale;
	self.Scale = math.floor(scale * 100) / 100;

	local frameWidth = currentWidth * scale;
	local frameHeight = currentHeight * scale;
	self:SetDimensions(frameWidth, frameHeight);
	
	self:UpdateScreenRect()
end

function BuffHead.Setup.LayoutFrame:SizeWindowToDimensions(desiredWidth, desiredHeight)
	local interfaceScale = InterfaceCore.GetScale();  
	local windowScale = self.Scale; 
	local newWidth = desiredWidth / windowScale;
	local newHeight = desiredHeight / windowScale;

	self.Size = { Width = math.floor(newWidth + 0.5), Height = math.floor(newHeight + 0.5) };
	self:SetDimensions(desiredWidth, desiredHeight);
	
	self:UpdateScreenRect()	
end

function BuffHead.Setup.LayoutFrame:UpdatePosition()
	local interfaceScale = InterfaceCore.GetScale();
	local _, _, _, x, y = WindowGetAnchor(self:GetName(), 1);
	self.X = math.floor(x + 0.5);
	self.Y = math.floor(y + 0.5);
end

function BuffHead.Setup.LayoutFrame:UpdateScreenRect()
	BuffHead.Setup.Layout.UpdateFrameSettings(self);
end