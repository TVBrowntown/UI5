BuffHead.Setup.LayoutControlFrame = Frame:Subclass("BuffHeadLayoutControlFrameWindow");

local MIN_SIZE = 60;

local containerWindow = BuffHead.Setup.Layout.WindowName .. "Container";
local localization = BuffHead.Localization.GetMapping();

local function GetRelativeScreenPosition(windowName)
	local interfaceScale = InterfaceCore.GetScale();
	local containerX, containerY = WindowGetScreenPosition(containerWindow);
	local x, y = WindowGetScreenPosition(windowName);
	
	return (x - containerX) / interfaceScale, (y - containerY) / interfaceScale;
end

local function GetRelativeScreenSize()
	local width, height = WindowGetDimensions(containerWindow);

	return width, height;
end

local function CopyScreenPosition(sourceFrame, destFrame, xOffset, yOffset)
	local screenX, screenY = GetRelativeScreenPosition(sourceFrame:GetName());
	
	local xPos = (screenX + xOffset);
	local yPos = (screenY + yOffset);
	
	local anchor = { Point = "topleft", RelativeTo = containerWindow, RelativePoint = "topleft", XOffset = xPos, YOffset = yPos };
	destFrame:SetAnchor(anchor);
end

local function UpdateFramePosition(controlFrame)
	local screenX, screenY = GetRelativeScreenPosition(controlFrame:GetName());
	
	local offset = LayoutControlFrame.OFFSET;
	local layoutFrame = controlFrame.ActiveFrame;
	layoutFrame.X = math.floor(screenX + offset + 0.5);
	layoutFrame.Y = math.floor(screenY + offset + 0.5);
end

local function CopySizeControlsToLayout(sourceFrame, destFrame)
	LayoutEditorUtils.CopySize(sourceFrame, destFrame, -2 * LayoutControlFrame.OFFSET, -2 * LayoutControlFrame.OFFSET, true);
end

local function CopySizeLayoutToControls(sourceFrame, destFrame)
	LayoutEditorUtils.CopySize(sourceFrame, destFrame, 2 * LayoutControlFrame.OFFSET, 2 * LayoutControlFrame.OFFSET, false);
end

local function AnchorFrame(frame, anchorToFrame, anchorId)
	local anchorData = LayoutControlFrame.RESIZE_CONTROL_ANCHORS[anchorId];
	local anchor = { Point = anchorData.point, RelativeTo = anchorToFrame:GetName(), RelativePoint = anchorData.point, XOffset = anchorData.xOffset, YOffset = anchorData.yOffset };
	frame:SetAnchor(anchor);
end

function BuffHead.Setup.LayoutControlFrame:Create(windowName, parentWindow)
	local frame = self:CreateFromTemplate(windowName, parentWindow);

	frame.ActiveFrame = nil;
	frame.IsResizing = false;
	frame.IsMoving = false;
	frame.AdjustOffset = { X = 0, Y = 0 };
	
    DefaultColor.SetWindowTint(windowName, DefaultColor.YELLOW);
	
    WindowAddAnchor(windowName .. "ResizeFrame", "topleft", windowName, "topleft", LayoutControlFrame.OFFSET, LayoutControlFrame.OFFSET);
    WindowAddAnchor(windowName .. "ResizeFrame", "bottomright", windowName, "bottomright", -LayoutControlFrame.OFFSET, -LayoutControlFrame.OFFSET);
    WindowSetShowing(windowName .. "ResizeFrame", false);
	
	return frame
end

function BuffHead.Setup.LayoutControlFrame:CreateContextMenu()
	EA_Window_ContextMenu.CreateContextMenu();
	
	if (self.ActiveFrame.FrameId) then
		EA_Window_ContextMenu.AddMenuItem(localization["Layout.Context.Properties"], function() BuffHead.Setup.Layout.Properties.ShowProperties(self.ActiveFrame.FrameId, self.ActiveFrame.Settings, self.ActiveFrame) end, false, true);
	end
	
    local text = GetStringFromTable("CustomizeUiStrings", (self.ActiveFrame:IsLocked() and StringTables.CustomizeUi.LABEL_UNLOCK_FRAME) or StringTables.CustomizeUi.LABEL_LOCK_FRAME);
    EA_Window_ContextMenu.AddMenuItem(text, function() self.ActiveFrame:SetLocked(not self.ActiveFrame:IsLocked()) end, false, true);
    
	EA_Window_ContextMenu.Finalize();
end

function BuffHead.Setup.LayoutControlFrame:Attach()
	local offset = LayoutControlFrame.OFFSET;

	CopySizeLayoutToControls(self.ActiveFrame, self);
	CopyScreenPosition(self.ActiveFrame, self, -offset, -offset);
	AnchorFrame(self.ActiveFrame, self, LayoutControlFrame.TOP_LEFT);

	local resizeWidth = true;
	local resizeHeight = true;
	
	WindowSetShowing(self:GetName() .. "TopResize", resizeHeight);
	WindowSetShowing(self:GetName() .. "BottomResize", resizeHeight);
	WindowSetShowing(self:GetName() .. "LeftResize", resizeWidth);
	WindowSetShowing(self:GetName() .. "RightResize", resizeWidth);
	
	self:Show(true);
end

function BuffHead.Setup.LayoutControlFrame:Detach()
	self:EndResize();
	self:EndMoving();
	
	local offset = LayoutControlFrame.OFFSET;
	CopyScreenPosition(self, self.ActiveFrame, offset, offset);
	self.ActiveFrame:UpdatePosition();
	WindowClearAnchors(self:GetName());
	
	self:Show(false);
end

function BuffHead.Setup.LayoutControlFrame:GetActiveFrame()
	return self.ActiveFrame;
end

function BuffHead.Setup.LayoutControlFrame:SetActiveFrame(frame)
	if (self.ActiveFrame and frame) then
		if (self.ActiveFrame:GetName() == frame:GetName()) then return end
	end

	if (self.ActiveFrame) then
		self:Detach();
		self.ActiveFrame:SetActive(false);
	end
	
	self.ActiveFrame = frame;
	
	if (frame) then
		frame:SetActive(self);
		self:Attach();
	end
end

function BuffHead.Setup.LayoutControlFrame:BeginResize(buttonId)
	if (not self.ActiveFrame or self.IsResizing or self.ActiveFrame:IsLocked()) then return end
	self.IsResizing = buttonId;
	
	local resizeData = LayoutControlFrame.RESIZE_PARAMS[buttonId];
	WindowSetResizing(self:GetName(), true, resizeData.sizePoint, resizeData.lockAspect);
	WindowSetShowing(self:GetName() .. "ResizeFrame", true);
	   
	local width, height = WindowGetDimensions(self:GetName());
	local screenX, screenY = GetRelativeScreenPosition(self:GetName()); 
	local offsetX = screenX;
	local offsetY = screenY;
	local screenWidth, screenHeight = GetRelativeScreenSize();
	
	self.MaximumSize = { Width = width, Height = height };
	
	if (buttonId == LayoutControlFrame.TOP_LEFT or buttonId == LayoutControlFrame.BOTTOM_LEFT or buttonId == LayoutControlFrame.LEFT) then
		self.MaximumSize.Width = screenX + width;
	else
		self.MaximumSize.Width = (screenWidth - screenX);
	end
	
	if (buttonId == LayoutControlFrame.TOP_LEFT or buttonId == LayoutControlFrame.TOP_RIGHT or buttonId == LayoutControlFrame.TOP) then
		self.MaximumSize.Height = screenY + height;
	else
		self.MaximumSize.Height = (screenHeight - screenY);
	end
	
	local anchorData = LayoutControlFrame.ANCHOR_OFFSETS[resizeData.anchorPoint];
	if (anchorData.addWidth) then
		offsetX = offsetX + width;
	end
	
	if (anchorData.addHeight) then
		offsetY = offsetY + height;
	end
	
	local anchor = { Point = "topleft", RelativeTo = containerWindow, RelativePoint = resizeData.anchorPoint, XOffset = offsetX, YOffset = offsetY };	
	self:SetAnchor(anchor);
	
	AnchorFrame(self.ActiveFrame, self, buttonId);
end

function BuffHead.Setup.LayoutControlFrame:EndResize()
	if (not self.ActiveFrame or not self.IsResizing) then return end

	WindowSetResizing(self:GetName(), false, "", false);
	WindowSetShowing(self:GetName() .. "ResizeFrame", false);
	
	local width, height = WindowGetDimensions(self:GetName());
	width  = width - 2 * LayoutControlFrame.OFFSET;
	height = height - 2 * LayoutControlFrame.OFFSET;
	local allowScaling = self.ActiveFrame.AllowScaling;
	
	-- If the aspect ratio is locked, we want to scale the window instead of re-sizing.
	local resizeData = LayoutControlFrame.RESIZE_PARAMS[self.IsResizing];
	if (resizeData.lockAspect and allowScaling) then 
		self.ActiveFrame:ScaleWindowToDimensions(width, height);
		CopySizeLayoutToControls(self.ActiveFrame, self);
	else 
		self.ActiveFrame:SizeWindowToDimensions(width, height);
	end          
	
	self.IsResizing = false;
end

function BuffHead.Setup.LayoutControlFrame:BeginMoving()
	if(not self.ActiveFrame or self.IsMoving or self.ActiveFrame:IsLocked()) then return end
	
	self.IsMoving = true;
	WindowSetMoving(self:GetName(), true);
end

function BuffHead.Setup.LayoutControlFrame:EndMoving()
	if (not self.IsMoving) then return end
	
	self.IsMoving = false;
	WindowSetMoving(self:GetName(), false);

	UpdateFramePosition(self);
	self.ActiveFrame:UpdateScreenRect();
end

function BuffHead.Setup.LayoutControlFrame:OnLButtonUpProcessed()
	if (not self.ActiveFrame) then return end
	self:EndMoving();
	self:EndResize();
end

function BuffHead.Setup.LayoutControlFrame:OnLButtonDown()
    if (not self.ActiveFrame) then return end
    self:BeginMoving();
end

function BuffHead.Setup.LayoutControlFrame:OnRButtonDown()
    if (not self.ActiveFrame) then return end
end

function BuffHead.Setup.LayoutControlFrame:OnRButtonUp()
    if (not self.ActiveFrame) then return end
    self:CreateContextMenu();
end

function BuffHead.Setup.LayoutControlFrame:OnRawDeviceInput(deviceId, itemId, itemDown)
	if (deviceId ~= SystemData.InputDevice.KEYBOARD or self.ActiveFrame:IsLocked()) then return end
	
	local UP_ARROW_BUTTON_ID = 200;
	local DOWN_ARROW_BUTTON_ID = 208;
	local LEFT_ARROW_BUTTON_ID = 203;
	local RIGHT_ARROW_BUTTON_ID = 205;
	
	if (itemId == UP_ARROW_BUTTON_ID) then
		if (itemDown == 1) then
			self.AdjustOffset.Y = -1;
		else
			self.AdjustOffset.Y = 0;
		end
	elseif (itemId == DOWN_ARROW_BUTTON_ID) then
		if (itemDown == 1) then
			self.AdjustOffset.Y = 1;
		else
			self.AdjustOffset.Y = 0;
		end
	elseif (itemId == LEFT_ARROW_BUTTON_ID) then
		if (itemDown == 1) then
			self.AdjustOffset.X = -1;
		else
			self.AdjustOffset.X = 0;
		end
	elseif (itemId == RIGHT_ARROW_BUTTON_ID) then
		if (itemDown == 1) then
			self.AdjustOffset.X = 1;
		else
			self.AdjustOffset.X = 0;
		end
	end
end

function BuffHead.Setup.LayoutControlFrame:Update(timePassed)
    if (not self.ActiveFrame) then return end
	
	if (self.IsResizing) then
		local width, height = WindowGetDimensions(self:GetName());
		local clampedX = math.min(math.max(width, MIN_SIZE), self.MaximumSize.Width);
		local clampedY = math.min(math.max(height, MIN_SIZE), self.MaximumSize.Height);
		
		if (clampedX ~= x or clampedY ~= y) then
			WindowSetDimensions(self:GetName(), clampedX, clampedY);   
		end
	end
		
	if (self.IsMoving) then
		local screenWidth, screenHeight = GetRelativeScreenSize();
		local screenX, screenY = GetRelativeScreenPosition(self:GetName());
		local width, height = WindowGetDimensions(self:GetName());
		
		local clampedX = screenX;
		local clampedY = screenY;
		
		-- unlike the default editor, we do not want to account for the control frame, since if it's
		-- outside of the container, it can't be clicked on
		
		if (screenX < 0) then
			clampedX = 0;
		end
		
		if (screenY < 0) then
			clampedY = 0;
		end
		
		if (screenX + width > screenWidth) then
			clampedX = screenWidth - width;
		end
		
		if (screenY + height > screenHeight) then
			clampedY = screenHeight - height;
		end
		
		if(clampedX ~= screenX or clampedY ~= screenY) then
			clampedX = clampedX;
			clampedY = clampedY;
			
			local anchor = { Point = "topleft", RelativeTo = containerWindow, RelativePoint = "topleft", XOffset = clampedX, YOffset = clampedY };
			self:SetAnchor(anchor); 
		end
		
		self.ActiveFrame:UpdateScreenRect();
	elseif(self.AdjustOffset.X ~= 0 or self.AdjustOffset.Y ~= 0) then
		self:AdjustPosition(self.AdjustOffset.X, self.AdjustOffset.Y);
		UpdateFramePosition(self);
		self.ActiveFrame:UpdateScreenRect();
	end
end

function BuffHead.Setup.LayoutControlFrame:AdjustPosition(xOffset, yOffset)
	local screenX, screenY = GetRelativeScreenPosition(self:GetName());
	local screenWidth, screenHeight = GetRelativeScreenSize();   
	local width, height = WindowGetDimensions(self:GetName());     
	
	local xPos = math.min(math.max(0, screenX + xOffset), screenWidth - width);
	local yPos = math.min(math.max(0, screenY + yOffset), screenHeight - height);
		
	local anchor = { Point = "topleft", RelativeTo = containerWindow, RelativePoint = "topleft", XOffset = xPos, YOffset = yPos };
	self:SetAnchor(anchor);
end

function BuffHead.Setup.LayoutControlFrame.SetSize(frame, width, height, scale)
	local screenX, screenY = GetRelativeScreenPosition(frame:GetName());
	local screenWidth, screenHeight = GetRelativeScreenSize();
	
	local maximumSize = 
	{
		Width = (screenWidth - screenX - LayoutControlFrame.OFFSET) / scale, 
		Height = (screenHeight - screenY - LayoutControlFrame.OFFSET) / scale 
	};
	
	width = math.min(maximumSize.Width, width);
	height = math.min(maximumSize.Height, height);
	
    local frameWidth = width * scale;
    local frameHeight = height * scale;
    frame:SetDimensions(frameWidth, frameHeight);
	
	frame.Size = { Width = width, Height = height };
	frame.Scale = scale;
end

function BuffHead.Setup.LayoutControlFrame.SetPosition(frame, x, y)
	local screenWidth, screenHeight = GetRelativeScreenSize();
    local frameWidth = frame.Size.Width * frame.Scale;
    local frameHeight = frame.Size.Height * frame.Scale;
	
	x, y = x + LayoutControlFrame.OFFSET, y + LayoutControlFrame.OFFSET;
	
	local maximumOffset = 
	{
		X = (screenWidth - frameWidth - LayoutControlFrame.OFFSET), 
		Y = (screenHeight - frameHeight - LayoutControlFrame.OFFSET) 
	};
	
	x = math.max(math.min(maximumOffset.X, x), 0);
	y = math.max(math.min(maximumOffset.Y, y), 0);
	
	local anchor = { Point = "topleft", RelativeTo = containerWindow, RelativePoint = "topleft", XOffset = x, YOffset = y };
	
	frame:SetAnchor(anchor);
	frame.X = x;
	frame.Y = y;
end