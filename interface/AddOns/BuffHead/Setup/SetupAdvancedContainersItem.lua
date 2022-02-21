BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.AdvancedContainersItem = 
{
	WindowName = "BuffHeadSetupAdvancedContainersItemWindow",
	Frames = { Container = 1, AlwaysShow = 2, Buffs = 3, Debuffs = 4 },
};
local this = BuffHead.Setup.AdvancedContainersItem;

local windowName = BuffHead.Setup.AdvancedContainersItem.WindowName;
local localization = BuffHead.Localization.GetMapping();

local MAX_PADDING = 10;
local MAX_ROWS_SLIDER = 10;
local MAX_COLUMNS_SLIDER = 20;
local SQUARE_SIZE = 30;
local MAX_SQUARE_SIZE = 60;

local LayoutFrame = this.Frames;
local existingItem = {};
local indexToTargetType = { BuffHead.TargetType.Self, BuffHead.TargetType.Friendly, BuffHead.TargetType.Hostile };
local activeSettings = nil;

local lastFixedSquare = nil;
local containerAnchor = {};
containerAnchor.AlwaysShow = { Anchor = 1, Buffs = 2, Debuffs = 3 };
containerAnchor.Buffs = { Anchor = 1, AlwaysShow = 2, Debuffs = 3 };
containerAnchor.Debuffs = { Anchor = 1, AlwaysShow = 2, Buffs = 3 };
local containerPlacement = { After = 1, Below = 2 };

local ContainerType = { AlwaysShow, Buffs, Debuffs };
local containers = {};

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

local function ShowButtons(showApply, showCreate)

	if (WindowGetShowing(windowName .. "ApplyButton") == showApply and WindowGetShowing(windowName .. "CreateButton") == showCreate) then return end

	WindowSetShowing(windowName .. "ApplyButton", showApply);
	WindowSetShowing(windowName .. "CreateButton", showCreate);
	
	if (showCreate) then
		WindowClearAnchors(windowName .. "CreateButton");
		if (showApply) then
			WindowAddAnchor(windowName .. "CreateButton", "topleft", windowName .. "ApplyButton", "topright", 0, 0);
		else
			WindowAddAnchor(windowName .. "CreateButton", "bottomright", windowName, "bottomright", -20, -20);
		end
	end

end

local function SetAnchors()

	local toAnchor =
	{
		[BuffHead.Container.Anchor.Anchor] = containerAnchor.AlwaysShow.Anchor;
		[BuffHead.Container.Anchor.Buffs] = containerAnchor.AlwaysShow.Buffs;
		[BuffHead.Container.Anchor.Debuffs] = containerAnchor.AlwaysShow.Debuffs;
	};
	--ComboBoxSetSelectedMenuItem(windowName .. "ContainerAlwaysShowAnchorCombo", toAnchor[BuffHead.Settings.Containers.AlwaysShow.Anchor]);
	
	toAnchor =
	{
		[BuffHead.Container.Anchor.Anchor] = containerAnchor.Buffs.Anchor;
		[BuffHead.Container.Anchor.AlwaysShow] = containerAnchor.Buffs.AlwaysShow;
		[BuffHead.Container.Anchor.Debuffs] = containerAnchor.Buffs.Debuffs;
	};
	--ComboBoxSetSelectedMenuItem(windowName .. "ContainerBuffsAnchorCombo", toAnchor[BuffHead.Settings.Containers.Buffs.Anchor]);
	
	toAnchor =
	{
		[BuffHead.Container.Anchor.Anchor] = containerAnchor.Debuffs.Anchor;
		[BuffHead.Container.Anchor.Buffs] = containerAnchor.Debuffs.Buffs;
		[BuffHead.Container.Anchor.AlwaysShow] = containerAnchor.Debuffs.AlwaysShow;
	};
	--ComboBoxSetSelectedMenuItem(windowName .. "ContainerDebuffsAnchorCombo", toAnchor[BuffHead.Settings.Containers.Debuffs.Anchor]);
	
end

local function GetAnchorOf(anchor)
	local child = nil;
	
	if (anchor == BuffHead.Container.Anchor.AlwaysShow) then
		child = activeSettings.Containers.AlwaysShow.Anchor;
	elseif (anchor == BuffHead.Container.Anchor.Buffs) then
		child = activeSettings.Containers.Buffs.Anchor;
	elseif (anchor == BuffHead.Container.Anchor.Debuffs) then
		child = activeSettings.Containers.Debuffs.Anchor;
	end
	
	return child;
	
end

local function FixLoops(anchor, childAnchor)

	if (not childAnchor) then
		childAnchor = anchor;
	end
	childAnchor = GetAnchorOf(childAnchor);
	
	if (childAnchor == nil or childAnchor == BuffHead.Container.Anchor.Anchor) then
		return;
	else
		if (childAnchor == anchor) then
			if (anchor == BuffHead.Container.Anchor.AlwaysShow) then
				activeSettings.Containers.AlwaysShow.Anchor = BuffHead.Container.Anchor.Anchor;
				SetAnchors();
			elseif (anchor == BuffHead.Container.Anchor.Buffs) then
				activeSettings.Containers.Buffs.Anchor = BuffHead.Container.Anchor.Anchor;
				SetAnchors();
			elseif (anchor == BuffHead.Container.Anchor.Debuffs) then
				activeSettings.Containers.Debuffs.Anchor = BuffHead.Container.Anchor.Anchor;
				SetAnchors();
			end
		else
			FixLoops(anchor, childAnchor);
		end
	end

end

local function RepairChildAnchor(anchor)

	FixLoops(anchor, anchor);

end

local function AnchorSquare(settings, square)

	local anchor = windowName .. "ContainerAnchorLabel";
	local alwaysShow = windowName .. "ContainerAlwaysSquare";
	local buffs = windowName .. "ContainerBuffsSquare";
	local debuffs = windowName .. "ContainerDebuffsSquare";
	local placementType, anchorType = settings.Placement, settings.Anchor;
	
	local point, anchorTo, relativePoint, x, y;
	
	relativePoint = "topleft";
	
	if (placementType == BuffHead.Container.Placement.Fixed) then
		if (lastFixedSquare) then
			x, y = 10, 0;
			point = "topright";
			anchorTo = lastFixedSquare;
		else
			x, y = 300, 0;
			point = "topleft";
			anchorTo = anchor;
		end
		lastFixedSquare = square;
	else
		if (placementType == BuffHead.Container.Placement.After) then
			x, y = math.min(activeSettings.Containers.Padding.X, MAX_PADDING), 0;
			point = "topright";
		else -- below
			x, y = 0, math.min(activeSettings.Containers.Padding.Y, MAX_PADDING);
			point = "bottomleft";
		end
		
		if (anchorType == BuffHead.Container.Anchor.Anchor) then
			x, y = 0, 0;
			point = "topleft";
			anchorTo = anchor;
		elseif (anchorType == BuffHead.Container.Anchor.AlwaysShow) then
			anchorTo = alwaysShow;
		elseif (anchorType == BuffHead.Container.Anchor.Buffs) then
			anchorTo = buffs;
		else -- debuffs
			anchorTo = debuffs;
		end
	end
	
	if (anchorTo == square) then return end
	
	WindowAddAnchor(square, point, anchorTo, relativePoint, x, y);	

end

local function ResizeSquare(settings, square)

	local max = math.max(MAX_ROWS_SLIDER, MAX_COLUMNS_SLIDER);
	local width = math.min(SQUARE_SIZE + (math.max(settings.Size.Columns, 1) - 1) * (SQUARE_SIZE / max), MAX_SQUARE_SIZE);
	local height = math.min(SQUARE_SIZE + (math.max(settings.Size.Rows, 1) - 1) * (SQUARE_SIZE / max), MAX_SQUARE_SIZE);
	
	WindowSetDimensions(square, width, height);
	
end

local function ArrangeSquares()

	local anchor = windowName .. "ContainerAnchorLabel";
	local alwaysShow = windowName .. "ContainerAlwaysSquare";
	local buffs = windowName .. "ContainerBuffsSquare";
	local debuffs = windowName .. "ContainerDebuffsSquare";
	
	ResizeSquare(activeSettings.Containers.AlwaysShow, alwaysShow);
	ResizeSquare(activeSettings.Containers.Buffs, buffs);
	ResizeSquare(activeSettings.Containers.Debuffs, debuffs);
	
	WindowClearAnchors(alwaysShow);	
	WindowClearAnchors(buffs);	
	WindowClearAnchors(debuffs);
	
	lastFixedSquare = nil;
	AnchorSquare(activeSettings.Containers.AlwaysShow, alwaysShow);
	AnchorSquare(activeSettings.Containers.Buffs, buffs);
	AnchorSquare(activeSettings.Containers.Debuffs, debuffs);

end

local function GetTargetTypeIndex(targetType)
	for index, target in ipairs(indexToTargetType) do
		if (targetType == target) then
			return index;
		end
	end
	return 1;
end

local function LoadItem(index)

	local item = nil;
	existingItem = { Index = index };
	
	if (index) then
		item = BuffHead.Settings.AdvancedContainers[index];
	end

	local targetType = 1;
	local screenPosition = 2;

	if (item) then
		--existing
		targetType = GetTargetTypeIndex(item.Type);
		screenPosition = item.ScreenPosition;
		
		activeSettings = CopyTable(item);
	else
		--new
		activeSettings =
		{
			Layout = nil, -- nil = current layout
			ScreenPosition = BuffHead.ScreenPosition.Attached,
			Type = BuffHead.TargetType.Self,
			Layer = 1,
			Scale = 1,
			AlwaysShow = {},
			AlwaysIgnore = {},
			AlwaysShowEnabled = true,
			Buffs = BuffHead.BuffType.Friendly.CastByMe,
			Debuffs = BuffHead.DebuffType.Friendly.CurableByMe,
			Permanent = false,
			MaximumThreshold = 60,
			
			Offset =
			{
				X = 0,
				Y = -20,
			},
			Indicators = 
			{
				Padding = 
				{
					X = 0,
					Y = 5
				},
			},
			Containers =
			{
				AlwaysShow = 
				{
					Placement = BuffHead.Container.Placement.After,
					Anchor = BuffHead.Container.Anchor.Anchor,
					Size = { Rows = 1, Columns = 10 },
					Offset = { X = 0, Y = 0 },
					Growth =
					{
						Vertical = BuffHead.Container.Growth.Vertical.Down,
						Horizontal = BuffHead.Container.Growth.Horizontal.Right,
					},
				},
				Buffs = 
				{
					Placement = BuffHead.Container.Placement.After,
					Anchor = BuffHead.Container.Anchor.AlwaysShow,
					Size = { Rows = 1, Columns = 10 },
					Offset = { X = 0, Y = 0 },
					Growth =
					{
						Vertical = BuffHead.Container.Growth.Vertical.Down,
						Horizontal = BuffHead.Container.Growth.Horizontal.Right,
					},
				},
				Debuffs = 
				{
					Placement = BuffHead.Container.Placement.After,
					Anchor = BuffHead.Container.Anchor.Buffs,
					Size = { Rows = 1, Columns = 10 },
					Offset = { X = 0, Y = 0 },
					Growth =
					{
						Vertical = BuffHead.Container.Growth.Vertical.Down,
						Horizontal = BuffHead.Container.Growth.Horizontal.Right,
					},
				},
				Padding = 
				{
					X = 0,
					Y = 5
				},
			},
		};
	end
	
	BuffHead.Setup.ContainerDemo.Enable(windowName, activeSettings);
	
	ComboBoxSetSelectedMenuItem(windowName .. "TargetComboBox", targetType);
	ComboBoxSetSelectedMenuItem(windowName .. "PositionComboBox", screenPosition);
	ArrangeSquares();
	
	if (item) then
		ShowButtons(true, true);
	else
		ShowButtons(false, true);
	end

end

function BuffHead.Setup.AdvancedContainersItem.Initialize()
	BuffHead.Setup.AdvancedContainersItem.Properties.Initialize()
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.AdvancedContainersItem.Title"]);
	
	LabelSetText(windowName .. "TargetLabel", localization["Setup.AdvancedContainersItem.Target"]);
	LabelSetText(windowName .. "TargetInfoLabel", localization["Setup.AdvancedContainersItem.Target.Info"]);
	LabelSetText(windowName .. "PositionLabel", localization["Setup.AdvancedContainersItem.Position"]);
	LabelSetText(windowName .. "ContainerLayoutLabel", localization["Setup.AdvancedContainersItem.ContainerLayout"]);
	LabelSetText(windowName .. "ContainerLayoutInfoLabel", localization["Setup.AdvancedContainersItem.ContainerLayout.Info"]);
	LabelSetText(windowName .. "ContainerAnchorLabel", L"");
	LabelSetText(windowName .. "ContainerLegendAlwaysShowLabel", localization["Setup.Containers.Container.AlwaysShow"]);
	LabelSetText(windowName .. "ContainerLegendBuffsLabel", localization["Setup.Containers.Container.Buffs"]);
	LabelSetText(windowName .. "ContainerLegendDebuffsLabel", localization["Setup.Containers.Container.Debuffs"]);
	
	ComboBoxClearMenuItems(windowName .. "TargetComboBox");
	ComboBoxAddMenuItem(windowName .. "TargetComboBox", localization["Setup.AdvancedContainersItem.Target.Self"]);
	ComboBoxAddMenuItem(windowName .. "TargetComboBox", localization["Setup.AdvancedContainersItem.Target.Friendly"]);
	ComboBoxAddMenuItem(windowName .. "TargetComboBox", localization["Setup.AdvancedContainersItem.Target.Hostile"]);
	
	ComboBoxClearMenuItems(windowName .. "PositionComboBox");
	ComboBoxAddMenuItem(windowName .. "PositionComboBox", localization["Setup.AdvancedContainersItem.Position.Fixed"]);
	ComboBoxAddMenuItem(windowName .. "PositionComboBox", localization["Setup.AdvancedContainersItem.Position.Attached"]);

	ButtonSetText(windowName .. "ApplyButton", localization["Setup.AdvancedContainersItem.Apply"]);
	ButtonSetText(windowName .. "CreateButton", localization["Setup.AdvancedContainersItem.Create"]);
	
	ShowButtons(false, true);
end

function BuffHead.Setup.AdvancedContainersItem.LoadSettings()

end

function BuffHead.Setup.AdvancedContainersItem.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.AdvancedContainersItem.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.AdvancedContainersItem.OnHidden()
	BuffHead.Setup.SetActiveWindow();
	BuffHead.Setup.AdvancedContainersItem.Properties.Hide();
	BuffHead.Setup.ContainerDemo.Disable();
end

function BuffHead.Setup.AdvancedContainersItem.OnCloseLUp()
	this.Hide();
	BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedContainers);
end

function BuffHead.Setup.AdvancedContainersItem.ShowNew()
	LoadItem(nil);
	this.Show();
end

function BuffHead.Setup.AdvancedContainersItem.ShowEdit(index)
	LoadItem(index);
	this.Show();
end

function BuffHead.Setup.AdvancedContainersItem.GetActiveItem()
	return existingItem or {};
end

function BuffHead.Setup.AdvancedContainersItem.GetSettings(propertyId)
	if (propertyId == LayoutFrame.AlwaysShow) then
		return activeSettings.Containers.AlwaysShow;
	elseif (propertyId == LayoutFrame.Buffs) then
		return activeSettings.Containers.Buffs;
	elseif (propertyId == LayoutFrame.Debuffs) then
		return activeSettings.Containers.Debuffs;
	elseif (propertyId == LayoutFrame.Container) then
		return activeSettings;
	end
	
	return activeSettings;
end

function BuffHead.Setup.AdvancedContainersItem.UpdateAnchor(anchor)
	RepairChildAnchor(anchor);
end

function BuffHead.Setup.AdvancedContainersItem.UpdateLayout()
	ArrangeSquares();
end

function BuffHead.Setup.AdvancedContainersItem.OnContainerRClick()
	local id = WindowGetId(SystemData.MouseOverWindow.name);
	if (id == 1) then
		id = LayoutFrame.AlwaysShow;
	elseif (id == 2) then
		id = LayoutFrame.Buffs;
	elseif (id == 3) then
		id = LayoutFrame.Debuffs;
	end

	EA_Window_ContextMenu.CreateContextMenu(SystemData.ActiveWindow.name);
	EA_Window_ContextMenu.AddMenuItem(localization["Layout.Context.Properties"], function() BuffHead.Setup.AdvancedContainersItem.Properties.ShowProperties(id, this.GetSettings(id)) end, false, true);
	EA_Window_ContextMenu.AddMenuItem(localization["Setup.AdvancedContainersItem.Context.ContainerProperties"], function() BuffHead.Setup.AdvancedContainersItem.Properties.ShowProperties(LayoutFrame.Container, this.GetSettings(LayoutFrame.Container)) end, false, true);
	EA_Window_ContextMenu.Finalize();
end

function BuffHead.Setup.AdvancedContainersItem.OnTargetTypeChanged()
	local value = indexToTargetType[ComboBoxGetSelectedMenuItem(windowName .. "TargetComboBox")];
	
	local isFriendly = (value == BuffHead.TargetType.Friendly or value == BuffHead.TargetType.Self);
	local wasFriendly = (activeSettings.Type == BuffHead.TargetType.Friendly or activeSettings.Type == BuffHead.TargetType.Self);
	
	activeSettings.Type = value;
	
	if (isFriendly ~= wasFriendly) then
		if (BuffHead.Setup.AdvancedContainersItem.Properties.GetActiveProperty() == LayoutFrame.Container) then
			BuffHead.Setup.AdvancedContainersItem.Properties.ReloadSettings();
		end
	end
end

function BuffHead.Setup.AdvancedContainersItem.OnPositionChanged()
	local value = ComboBoxGetSelectedMenuItem(windowName .. "PositionComboBox");
	activeSettings.ScreenPosition = value;
	BuffHead.Setup.ContainerDemo.OnSettingsChanged();
end

local function SaveItem()
	local item = activeSettings;
	
	return item;
end

function BuffHead.Setup.AdvancedContainersItem.OnApplyLClick()
	local item = SaveItem();
	if (item) then
		BuffHead.Settings.AdvancedContainers[existingItem.Index] = item;
		this.Hide();
		BuffHead.Setup.AdvancedContainers.Update();
		BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedContainers);
	end
end

function BuffHead.Setup.AdvancedContainersItem.OnCreateLClick()
	local item = SaveItem();
	if (item) then
		table.insert(BuffHead.Settings.AdvancedContainers, item);
		this.Hide();
		BuffHead.Setup.AdvancedContainers.Update();
		BuffHead.Setup.SetActiveWindow(BuffHead.Setup.AdvancedContainers);
	end
end