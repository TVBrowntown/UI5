BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.Layout = 
{
	WindowName = "BuffHeadSetupLayoutWindow",
	ControlFrames = {},
	Frames = { Size = 1, Icon = 2, StatusBar = 3, Duration = 4, StackCount = 5, Name = 6 },
};
local this = BuffHead.Setup.Layout;

local windowName = BuffHead.Setup.Layout.WindowName;
local localization = BuffHead.Localization.GetMapping();

local LayoutFrames = this.Frames;

local isEventRegistered = false;
local layoutFrames = {};
local activeSettings = nil;

local function CopyTable(t)
	local copiedTable = {};
	for k, v in pairs(t) do
		if (type(v) == "table") then
			copiedTable[k] = CopyTable(v);
		else
			copiedTable[k] = v;
		end
	end
	return copiedTable;
end

local function SaveLayout()
	local x, y = layoutFrames[LayoutFrames.Size].X, layoutFrames[LayoutFrames.Size].Y;
		
	for id, layoutFrame in pairs(layoutFrames) do		
		layoutFrame.Settings.Width = layoutFrame.Size.Width;
		layoutFrame.Settings.Height = layoutFrame.Size.Height;
		layoutFrame.Settings.Scale = layoutFrame.Scale;
		
		if (id ~= LayoutFrames.Size) then
			layoutFrame.Settings.X = math.floor((layoutFrame.X - x) + 0.5);
			layoutFrame.Settings.Y = math.floor((layoutFrame.Y - y) + 0.5);
		end
	end
	
	BuffHead.Settings.Layout = CopyTable(activeSettings);
	BuffHead.LayoutRevision = (BuffHead.LayoutRevision or 0) + 1;
end

local function UpdateLayers()
	local showLayer = {};
	for index = 0, 4 do
		showLayer[index] = ButtonGetPressedFlag(windowName .. "LayerWindowLayer" .. index .. "CheckboxButton");
	end
	
	for id, layoutFrame in pairs(layoutFrames) do
		local show = true;
		if (id == LayoutFrames.Size) then
			show = showLayer[0];
		else
			show = showLayer[layoutFrame.Settings.Layer or 1];
		end
		if (not show and layoutFrame:IsActive()) then
			BuffHead.Setup.Layout.RemoveControlFrame(layoutFrame);
		end
		layoutFrame:Show(show);
	end
end

local function InitializeLayoutFrame(id, windowName, name, settings, allowScaling)
	if (not layoutFrames[id]) then
		layoutFrames[id] = BuffHead.Setup.LayoutFrame:Create(windowName, this.WindowName .. "Container", id, name, settings, allowScaling);
	end
end

local function DestroyLayoutFrames()
	for id, layoutFrame in pairs(layoutFrames) do
		layoutFrame:Destroy();
	end
	layoutFrames = {};
end

local function InitializeLayoutFrames()
	if (activeSettings == nil) then
		activeSettings = CopyTable(BuffHead.Settings.Layout);
	end
	local settings = activeSettings;
	
	InitializeLayoutFrame(LayoutFrames.Size, "Size", localization["Layout.Size"], settings, false);
	InitializeLayoutFrame(LayoutFrames.Icon, "Icon", localization["Layout.Icon"], settings.Icon, true);
	InitializeLayoutFrame(LayoutFrames.StatusBar, "StatusBar", localization["Layout.StatusBar"], settings.StatusBar, true);
	InitializeLayoutFrame(LayoutFrames.Duration, "Duration", localization["Layout.Duration"], settings.Duration, true);
	InitializeLayoutFrame(LayoutFrames.StackCount, "StackCount", localization["Layout.StackCount"], settings.StackCount, true);
	InitializeLayoutFrame(LayoutFrames.Name, "Name", localization["Layout.Name"], settings.Name, true);
end

local function LoadLayout()
	InitializeLayoutFrames();
	
	-- find the top-most and left-most elements to start anchoring from
	local x, y = 0, 0;
	
	for id, layoutFrame in pairs(layoutFrames) do
		if (id ~= LayoutFrames.Size) then
			x = math.min(x, layoutFrame.Settings.X or 0);
			y = math.min(y, layoutFrame.Settings.Y or 0);
		end
	end
	
	for id, layoutFrame in pairs(layoutFrames) do
		BuffHead.Setup.LayoutControlFrame.SetPosition(layoutFrame, -x + (layoutFrame.Settings.X or 0), -y + (layoutFrame.Settings.Y or 0));
		--layoutFrame:SetPosition(-x + (layoutFrame.Settings.X or 0), -y + (layoutFrame.Settings.Y or 0));
	end	
	
	BuffHead.Setup.Demo.OnSettingsChanged();
end

local function AutoSize()
	local x, y = 0, 0;

	-- find the top-most and left-most elements to start anchoring from
	for id, layoutFrame in pairs(layoutFrames) do
		if (id ~= LayoutFrames.Size) then
			x = math.min(x, layoutFrame.Settings.X or 0);
			y = math.min(y, layoutFrame.Settings.Y or 0);
		end
	end
	
	if (x < 0 or y < 0) then
		-- recalculate to be coords to be 0-based
		for id, layoutFrame in pairs(layoutFrames) do
			if (id ~= LayoutFrames.Size) then
				layoutFrame.Settings.X = layoutFrame.Settings.X + -x;
				layoutFrame.Settings.Y = layoutFrame.Settings.Y + -y;
			end
		end
	end
	
	-- calculate farthest x, y
    local interfaceScale = InterfaceCore.GetScale();
	for id, layoutFrame in pairs(layoutFrames) do
		if (id ~= LayoutFrames.Size) then
			local frameWidth = layoutFrame.Settings.Width * layoutFrame.Settings.Scale;
			local frameHeight = layoutFrame.Settings.Height * layoutFrame.Settings.Scale;
			
			x = math.max(x, frameWidth + layoutFrame.Settings.X);
			y = math.max(y, frameHeight + layoutFrame.Settings.Y);
		end
	end
	
	local sizeFrame = layoutFrames[LayoutFrames.Size];
	sizeFrame.Settings.Width = x;
	sizeFrame.Settings.Height = y;
	
	this.ClearActiveFrames();
	BuffHead.Setup.LayoutControlFrame.SetSize(sizeFrame, x, y, sizeFrame.Settings.Scale or 1);
	LoadLayout();
end

function BuffHead.Setup.Layout.Initialize()
	BuffHead.Setup.Layout.Properties.Initialize();
	BuffHead.Setup.Layout.Manager.Initialize();

	WindowSetShowing(windowName .. "LayerWindow", false);
	WindowSetTintColor(windowName .. "LayerWindowBackground", 0, 0, 0);
	WindowSetAlpha(windowName .. "LayerWindowBackground", 0.8);
	WindowClearAnchors(windowName .. "LayerWindow");
	WindowAddAnchor(windowName .. "LayerWindow", "topleft", windowName .. "LayerButton", "topright", 0, 0);
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.Layout.Title"]);
	ButtonSetText(windowName .. "ApplyButton", localization["Setup.Layout.Apply"]);
	ButtonSetText(windowName .. "ManagerButton", localization["Setup.Layout.Manager"]);
	
	LabelSetText(windowName .. "LayerWindowLayersLabel", localization["Layout.Layers"]);
	
	for index = 0, 4 do
		LabelSetText(windowName .. "LayerWindowLayer" .. index .. "CheckBoxLabel", localization["Layout.Layers.Layer" .. index]);
		ButtonSetPressedFlag(windowName .. "LayerWindowLayer" .. index .. "CheckboxButton", true);
	end
	
	this.LoadSettings();
	LoadLayout();
	UpdateLayers();
end

function BuffHead.Setup.Layout.LoadLayout()
	LoadLayout();
end

function BuffHead.Setup.Layout.GenerateUniqueId()
	local lastId = 0;

	for index, layout in ipairs(BuffHead.Settings.Layouts) do
		if (layout.Settings and layout.Settings.Id and layout.Settings.Id > lastId) then
			lastId = layout.Settings.Id;
		end
	end
	
	return lastId + 1;
end

function BuffHead.Setup.Layout.AutoSize()
	AutoSize();
end

function BuffHead.Setup.Layout.GetActiveSettings()
	return activeSettings;
end

function BuffHead.Setup.Layout.ImportSettings(settings)
	BuffHead.Setup.Layout.Properties.Hide();
	this.ClearActiveFrames();
	DestroyLayoutFrames();
	activeSettings = settings;
	LoadLayout();
	UpdateLayers();
end

function BuffHead.Setup.Layout.GetLayoutFrame(id)
	return layoutFrames[id];
end

function BuffHead.Setup.Layout.LoadSettings()
	BuffHead.Setup.Layout.Properties.Hide();
	this.ClearActiveFrames();
	DestroyLayoutFrames();
	
	activeSettings = nil;
		
	LoadLayout();
	UpdateLayers();
end

function BuffHead.Setup.Layout.Show()
	if (WindowGetShowing(windowName)) then return end
	
	BuffHead.Setup.Layout.LoadSettings();
	if (not isEventRegistered) then
		isEventRegistered = true;
		RegisterEventHandler(SystemData.Events.L_BUTTON_UP_PROCESSED, "BuffHead.Setup.Layout.OnLButtonUpProcessed");
	end
	
	BuffHead.Setup.Demo.Enable(windowName);
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.Layout.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.Layout.OnHidden()
	if (isEventRegistered) then
		isEventRegistered = false;
		UnregisterEventHandler(SystemData.Events.L_BUTTON_UP_PROCESSED, "BuffHead.Setup.Layout.OnLButtonUpProcessed"); 
	end
	BuffHead.Setup.Demo.Disable();
	BuffHead.Setup.Layout.Properties.Hide();
	BuffHead.Setup.Layout.Manager.Hide();
	BuffHead.Setup.SetActiveWindow();
end

function BuffHead.Setup.Layout.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.Layout.UpdateFrameSettings(layoutFrame)
	local sizeFrame = layoutFrames[LayoutFrames.Size];
	local x, y = sizeFrame.X, sizeFrame.Y;
	
	layoutFrame.Settings.Width = layoutFrame.Size.Width;
	layoutFrame.Settings.Height = layoutFrame.Size.Height;
		
	if (layoutFrame ~= sizeFrame) then
		layoutFrame.Settings.Scale = layoutFrame.Scale;
		layoutFrame.Settings.X = math.floor((layoutFrame.X - x) + 0.5);
		layoutFrame.Settings.Y = math.floor((layoutFrame.Y - y) + 0.5);
	else
		-- the size frame is being moved, update the locations of all other frames
		for id, layoutFrame in pairs(layoutFrames) do
			if (id ~= LayoutFrames.Size) then
				layoutFrame.Settings.X = math.floor((layoutFrame.X - x) + 0.5);
				layoutFrame.Settings.Y = math.floor((layoutFrame.Y - y) + 0.5);
				if (BuffHead.Setup.Layout.Properties.GetActiveFrame() == layoutFrame) then
					BuffHead.Setup.Layout.Properties.ReloadSettings();
				end
			end
		end
	end
	
	if (BuffHead.Setup.Layout.Properties.GetActiveFrame() == layoutFrame) then
		BuffHead.Setup.Layout.Properties.ReloadSettings();
	end
	
	BuffHead.Setup.Demo.OnSettingsChanged();
end

function BuffHead.Setup.Layout.GetControlFrame(frame)
	for _, controlFrame in pairs(this.ControlFrames) do
		if (controlFrame:GetActiveFrame() == frame) then
			return controlFrame;
		end
	end

	local windowName = frame:GetName() .. "Controls";
	local controlFrame = BuffHead.Setup.LayoutControlFrame:Create(windowName, this.WindowName .. "Container");
	controlFrame:SetActiveFrame(frame);
	
	table.insert(this.ControlFrames, controlFrame);
    
	return controlFrame;
end

function BuffHead.Setup.Layout.RemoveControlFrame(frame)
	for index, controlFrame in pairs(this.ControlFrames) do
		if (controlFrame:GetActiveFrame() == frame) then
			controlFrame:SetActiveFrame(nil);
			controlFrame:Destroy();
			table.remove(this.ControlFrames, index);
		end
	end      
end

function BuffHead.Setup.Layout.ClearActiveFrames()
	for _, controlFrame in pairs(this.ControlFrames) do
		controlFrame:SetActiveFrame(nil);
		controlFrame:Destroy();
	end
    this.ControlFrames = {};
end

function BuffHead.Setup.Layout.OnLButtonUpProcessed()
	for _, controlFrame in pairs(this.ControlFrames) do
		controlFrame:OnLButtonUpProcessed();
	end
end

function BuffHead.Setup.Layout.OnLayoutWindowLButtonDown(flags, x, y)
    this.OnLayoutFrameButtonDown(flags);
	for _, controlFrame in pairs(this.ControlFrames) do 
		controlFrame:OnLButtonDown();
	end
end

function BuffHead.Setup.Layout.OnLayoutWindowRButtonDown(flags, x, y)
    local controlFrame = this.OnLayoutFrameButtonDown(flags);
    controlFrame:OnRButtonDown();
end

function BuffHead.Setup.Layout.OnLayoutFrameButtonDown(flags)
	local frame = GetFrame(SystemData.ActiveWindow.name);

	if (flags ~= SystemData.ButtonFlags.SHIFT) then
		this.ClearActiveFrames();
	end
	
    local controlFrame = this.GetControlFrame(frame);
    return controlFrame
end

function BuffHead.Setup.Layout.OnControlFrameLButtonDown()
	if (flags == SystemData.ButtonFlags.SHIFT) then
		local controlFrame = GetFrame(SystemData.ActiveWindow.name);
		this.RemoveControlFrame(controlFrame:GetActiveFrame());
		return;
	end
	
	for _, controlFrame in pairs(this.ControlFrames) do 
		controlFrame:OnLButtonDown();
	end
end

function BuffHead.Setup.Layout.OnControlFrameLButtonUp()
	for _, controlFrame in pairs(this.ControlFrames) do 
		controlFrame:OnLButtonUp();
	end
end

function BuffHead.Setup.Layout.OnControlFrameRButtonDown()
	local frame = GetFrame(SystemData.ActiveWindow.name);
	frame:OnRButtonDown();
end

function BuffHead.Setup.Layout.OnControlFrameRButtonUp()
	local frame = GetFrame(SystemData.ActiveWindow.name);
	frame:OnRButtonUp();
end

function BuffHead.Setup.Layout.BeginResize()
	local buttonId = WindowGetId(SystemData.ActiveWindow.name);
	for _, controlFrame in pairs(this.ControlFrames) do 
		controlFrame:BeginResize(buttonId);
	end
end
				
function BuffHead.Setup.Layout.ClearSelection()
	this.ClearActiveFrames();
end
				
function BuffHead.Setup.Layout.TrapClick()

end
				
function BuffHead.Setup.Layout.OnRawDeviceInput(deviceId, itemId, itemDown)
	for _, controlFrame in pairs(this.ControlFrames) do 
		controlFrame:OnRawDeviceInput(deviceId, itemId, itemDown);
	end
end
				
function BuffHead.Setup.Layout.OnUpdate(elapsed)
	for _, controlFrame in pairs(this.ControlFrames) do
		controlFrame:Update(elapsed);
	end
end

function BuffHead.Setup.Layout.OnLayerLClick()
	WindowSetShowing(windowName .. "LayerWindow", not WindowGetShowing(windowName .. "LayerWindow"));
end

function BuffHead.Setup.Layout.OnLayerMouseOver()
	local windowName = SystemData.ActiveWindow.name;
	
	Tooltips.CreateTextOnlyTooltip(windowName, nil);
	Tooltips.SetTooltipText(1, 1, localization["Setup.Layout.Layers.Tooltip"]);
	Tooltips.Finalize();
	
	local anchor = { Point = "left", RelativeTo = windowName, RelativePoint = "right", XOffset = -10, YOffset = 0 };
	Tooltips.AnchorTooltip(anchor);
	Tooltips.SetTooltipAlpha(1);
end

function BuffHead.Setup.Layout.OnLayersChanged()
	local isChecked = ButtonGetPressedFlag(SystemData.ActiveWindow.name .. "Button") == false;
	ButtonSetPressedFlag(SystemData.ActiveWindow.name .. "Button", isChecked);
	UpdateLayers();
end

function BuffHead.Setup.Layout.UpdateLayers()
	UpdateLayers();
end

function BuffHead.Setup.Layout.OnApplyLClick()
	this.ClearActiveFrames();
	SaveLayout();
	
	BuffHead.DestroyAllContainers();
	BuffHead.AdvancedContainers.Clear();
	BuffHead.AdvancedContainers.Load();
	BuffHead.RefreshPlayerBuffs();
end

function BuffHead.Setup.Layout.OnManagerLClick()
	BuffHead.Setup.Layout.Manager.Show();
end