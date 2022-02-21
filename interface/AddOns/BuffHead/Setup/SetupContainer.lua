BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.Container = 
{
	WindowName = "BuffHeadSetupContainerWindow",
};

local windowName = BuffHead.Setup.Container.WindowName;
local localization = BuffHead.Localization.GetMapping();

local MAX_PADDING_SLIDER = 10;
local MAX_ROWS_SLIDER = 10;
local MAX_COLUMNS_SLIDER = 20;
local SQUARE_SIZE = 30;

local containerAnchor = {};
containerAnchor.AlwaysShow = { Anchor = 1, Buffs = 2, Debuffs = 3 };
containerAnchor.Buffs = { Anchor = 1, AlwaysShow = 2, Debuffs = 3 };
containerAnchor.Debuffs = { Anchor = 1, AlwaysShow = 2, Buffs = 3 };
local containerPlacement = { After = 1, Below = 2 };

local ContainerType = { AlwaysShow, Buffs, Debuffs };
local containers = {};
local activeContainer = nil

local function OnSettingsChanged()
	BuffHead.ContainerRevision = (BuffHead.ContainerRevision or 0) + 1;
end

local function SetContainer(container)
	
	activeContainer = container.Settings;
	
	SliderBarSetCurrentPosition(windowName .. "ContainerColumnsSlider", math.min(1, activeContainer.Size.Columns / MAX_COLUMNS_SLIDER));
	SliderBarSetCurrentPosition(windowName .. "ContainerRowsSlider", math.min(1, activeContainer.Size.Rows / MAX_ROWS_SLIDER));
	BuffHead.Setup.Container.OnSlideColumns();
	BuffHead.Setup.Container.OnSlideRows();

end

local function SetAnchors()

	local toAnchor =
	{
		[BuffHead.Container.Anchor.Anchor] = containerAnchor.AlwaysShow.Anchor;
		[BuffHead.Container.Anchor.Buffs] = containerAnchor.AlwaysShow.Buffs;
		[BuffHead.Container.Anchor.Debuffs] = containerAnchor.AlwaysShow.Debuffs;
	};
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerAlwaysShowAnchorCombo", toAnchor[BuffHead.Settings.Containers.AlwaysShow.Anchor]);
	
	toAnchor =
	{
		[BuffHead.Container.Anchor.Anchor] = containerAnchor.Buffs.Anchor;
		[BuffHead.Container.Anchor.AlwaysShow] = containerAnchor.Buffs.AlwaysShow;
		[BuffHead.Container.Anchor.Debuffs] = containerAnchor.Buffs.Debuffs;
	};
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerBuffsAnchorCombo", toAnchor[BuffHead.Settings.Containers.Buffs.Anchor]);
	
	toAnchor =
	{
		[BuffHead.Container.Anchor.Anchor] = containerAnchor.Debuffs.Anchor;
		[BuffHead.Container.Anchor.Buffs] = containerAnchor.Debuffs.Buffs;
		[BuffHead.Container.Anchor.AlwaysShow] = containerAnchor.Debuffs.AlwaysShow;
	};
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerDebuffsAnchorCombo", toAnchor[BuffHead.Settings.Containers.Debuffs.Anchor]);
	
end

local function GetAnchorOf(anchor)
	local child = nil;
	
	if (anchor == BuffHead.Container.Anchor.AlwaysShow) then
		child = BuffHead.Settings.Containers.AlwaysShow.Anchor;
	elseif (anchor == BuffHead.Container.Anchor.Buffs) then
		child = BuffHead.Settings.Containers.Buffs.Anchor;
	elseif (anchor == BuffHead.Container.Anchor.Debuffs) then
		child = BuffHead.Settings.Containers.Debuffs.Anchor;
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
				BuffHead.Settings.Containers.AlwaysShow.Anchor = BuffHead.Container.Anchor.Anchor;
				SetAnchors();
			elseif (anchor == BuffHead.Container.Anchor.Buffs) then
				BuffHead.Settings.Containers.Buffs.Anchor = BuffHead.Container.Anchor.Anchor;
				SetAnchors();
			elseif (anchor == BuffHead.Container.Anchor.Debuffs) then
				BuffHead.Settings.Containers.Debuffs.Anchor = BuffHead.Container.Anchor.Anchor;
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
	
	if (placementType == BuffHead.Container.Placement.After) then
		x, y = BuffHead.Settings.Containers.Padding.X, 0;
		point = "topright";
	else -- below
		x, y = 0, BuffHead.Settings.Containers.Padding.Y;
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
	
	if (anchorTo == square) then return end
	
	WindowAddAnchor(square, point, anchorTo, relativePoint, x, y);	

end

local function ResizeSquare(settings, square)

	local max = math.max(MAX_ROWS_SLIDER, MAX_COLUMNS_SLIDER);
	local width = SQUARE_SIZE + (math.max(settings.Size.Columns, 1) - 1) * (SQUARE_SIZE / max);
	local height = SQUARE_SIZE + (math.max(settings.Size.Rows, 1) - 1) * (SQUARE_SIZE / max);
	
	WindowSetDimensions(square, width, height);
	
end

local function ArrangeSquares()

	local anchor = windowName .. "ContainerAnchorLabel";
	local alwaysShow = windowName .. "ContainerAlwaysSquare";
	local buffs = windowName .. "ContainerBuffsSquare";
	local debuffs = windowName .. "ContainerDebuffsSquare";
	
	ResizeSquare(BuffHead.Settings.Containers.AlwaysShow, alwaysShow);
	ResizeSquare(BuffHead.Settings.Containers.Buffs, buffs);
	ResizeSquare(BuffHead.Settings.Containers.Debuffs, debuffs);
	
	WindowClearAnchors(alwaysShow);	
	WindowClearAnchors(buffs);	
	WindowClearAnchors(debuffs);
	
	AnchorSquare(BuffHead.Settings.Containers.AlwaysShow, alwaysShow);
	AnchorSquare(BuffHead.Settings.Containers.Buffs, buffs);
	AnchorSquare(BuffHead.Settings.Containers.Debuffs, debuffs);

end

function BuffHead.Setup.Container.Initialize()

	LabelSetText(windowName .. "ContainerLabel", localization["Setup.Containers.Title"]);
	LabelSetText(windowName .. "ContainerExampleLabel", localization["Setup.Containers.Example"]);
	
	LabelSetText(windowName .. "ContainerLayoutLabel", localization["Setup.Containers.Layout"]);
	LabelSetText(windowName .. "ContainerAnchorLabel", L"");
	LabelSetText(windowName .. "ContainerLegendAlwaysShowLabel", localization["Setup.Containers.Container.AlwaysShow"]);
	LabelSetText(windowName .. "ContainerLegendBuffsLabel", localization["Setup.Containers.Container.Buffs"]);
	LabelSetText(windowName .. "ContainerLegendDebuffsLabel", localization["Setup.Containers.Container.Debuffs"]);
	LabelSetText(windowName .. "ContainerPaddingLabel", localization["Setup.Padding.Container"]);
	LabelSetText(windowName .. "ContainerPaddingHorizontalDescriptionLabel", localization["Setup.Padding.Horizontal"]);
	LabelSetText(windowName .. "ContainerPaddingVerticalDescriptionLabel", localization["Setup.Padding.Vertical"]);
	LabelSetText(windowName .. "ContainerTypeLabel", localization["Setup.Containers.Container"]);
	LabelSetText(windowName .. "ContainerColumnsDescriptionLabel", localization["Setup.Containers.Size.Columns"]);
	LabelSetText(windowName .. "ContainerRowsDescriptionLabel", localization["Setup.Containers.Size.Rows"]);
	
	LabelSetText(windowName .. "ContainerAlwaysShowLabel", localization["Setup.Containers.Show.AlwaysShow"]);
	
	ComboBoxClearMenuItems(windowName .. "ContainerAlwaysShowPlacementCombo");
	ComboBoxAddMenuItem(windowName .. "ContainerAlwaysShowPlacementCombo", localization["Setup.Containers.Placement.After"]);
	ComboBoxAddMenuItem(windowName .. "ContainerAlwaysShowPlacementCombo", localization["Setup.Containers.Placement.Below"]);
	
	ComboBoxClearMenuItems(windowName .. "ContainerAlwaysShowAnchorCombo");
	ComboBoxAddMenuItem(windowName .. "ContainerAlwaysShowAnchorCombo", localization["Setup.Containers.Container.Anchor"]);
	ComboBoxAddMenuItem(windowName .. "ContainerAlwaysShowAnchorCombo", localization["Setup.Containers.Container.Buffs"]);
	ComboBoxAddMenuItem(windowName .. "ContainerAlwaysShowAnchorCombo", localization["Setup.Containers.Container.Debuffs"]);
	
	LabelSetText(windowName .. "ContainerBuffsLabel", localization["Setup.Containers.Show.Buffs"]);
	
	ComboBoxClearMenuItems(windowName .. "ContainerBuffsPlacementCombo");
	ComboBoxAddMenuItem(windowName .. "ContainerBuffsPlacementCombo", localization["Setup.Containers.Placement.After"]);
	ComboBoxAddMenuItem(windowName .. "ContainerBuffsPlacementCombo", localization["Setup.Containers.Placement.Below"]);
	
	ComboBoxClearMenuItems(windowName .. "ContainerBuffsAnchorCombo");
	ComboBoxAddMenuItem(windowName .. "ContainerBuffsAnchorCombo", localization["Setup.Containers.Container.Anchor"]);
	ComboBoxAddMenuItem(windowName .. "ContainerBuffsAnchorCombo", localization["Setup.Containers.Container.AlwaysShow"]);
	ComboBoxAddMenuItem(windowName .. "ContainerBuffsAnchorCombo", localization["Setup.Containers.Container.Debuffs"]);
	
	LabelSetText(windowName .. "ContainerDebuffsLabel", localization["Setup.Containers.Show.Debuffs"]);
	
	ComboBoxClearMenuItems(windowName .. "ContainerDebuffsPlacementCombo");
	ComboBoxAddMenuItem(windowName .. "ContainerDebuffsPlacementCombo", localization["Setup.Containers.Placement.After"]);
	ComboBoxAddMenuItem(windowName .. "ContainerDebuffsPlacementCombo", localization["Setup.Containers.Placement.Below"]);
	
	ComboBoxClearMenuItems(windowName .. "ContainerDebuffsAnchorCombo");
	ComboBoxAddMenuItem(windowName .. "ContainerDebuffsAnchorCombo", localization["Setup.Containers.Container.Anchor"]);
	ComboBoxAddMenuItem(windowName .. "ContainerDebuffsAnchorCombo", localization["Setup.Containers.Container.AlwaysShow"]);
	ComboBoxAddMenuItem(windowName .. "ContainerDebuffsAnchorCombo", localization["Setup.Containers.Container.Buffs"]);
	
	ComboBoxClearMenuItems(windowName .. "ContainerTypeList");
	ComboBoxAddMenuItem(windowName .. "ContainerTypeList", localization["Setup.Containers.Container.AlwaysShow"]);
	ComboBoxAddMenuItem(windowName .. "ContainerTypeList", localization["Setup.Containers.Container.Buffs"]);
	ComboBoxAddMenuItem(windowName .. "ContainerTypeList", localization["Setup.Containers.Container.Debuffs"]);
	
	BuffHead.Setup.Container.LoadSettings();
	
end

function BuffHead.Setup.Container.LoadSettings()

	containers =
	{
		{ Settings = BuffHead.Settings.Containers.AlwaysShow, Type = ContainerType.AlwaysShow },
		{ Settings = BuffHead.Settings.Containers.Buffs, Type = ContainerType.Buffs },
		{ Settings = BuffHead.Settings.Containers.Debuffs, Type = ContainerType.Debuffs },
	};
	
	ArrangeSquares();
	
	SliderBarSetCurrentPosition(windowName .. "ContainerPaddingHorizontalSlider", math.min(1, BuffHead.Settings.Containers.Padding.X / MAX_PADDING_SLIDER));
	SliderBarSetCurrentPosition(windowName .. "ContainerPaddingVerticalSlider", math.min(1, BuffHead.Settings.Containers.Padding.Y / MAX_PADDING_SLIDER));
	BuffHead.Setup.Container.OnSlidePaddingHorizontal();
	BuffHead.Setup.Container.OnSlidePaddingVertical();
	
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerTypeList", 1);
	BuffHead.Setup.Container.OnSizeContainerTypeChanged();
	 
	SetAnchors();
	
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerAlwaysShowPlacementCombo", BuffHead.Settings.Containers.AlwaysShow.Placement);
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerBuffsPlacementCombo", BuffHead.Settings.Containers.Buffs.Placement);
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerDebuffsPlacementCombo", BuffHead.Settings.Containers.Debuffs.Placement);

end

function BuffHead.Setup.Container.Show()

	if (WindowGetShowing(windowName)) then return end
	
	ArrangeSquares();
	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.Container.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function BuffHead.Setup.Container.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	BuffHead.Setup.Filter.Hide();
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function BuffHead.Setup.Container.OnHidden()

	BuffHead.Setup.SetActiveWindow();

end

function BuffHead.Setup.Container.OnCloseLUp()

	BuffHead.Setup.Container.Hide();

end

function BuffHead.Setup.Container.OnContainerAlwaysShowPlacementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ContainerAlwaysShowPlacementCombo");
	
	BuffHead.Settings.Containers.AlwaysShow.Placement = value;
	
	ArrangeSquares();
	OnSettingsChanged();

end

function BuffHead.Setup.Container.OnContainerAlwaysShowAnchorChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ContainerAlwaysShowAnchorCombo");
	
	local toAnchor = {};
	toAnchor[containerAnchor.AlwaysShow.Anchor] = BuffHead.Container.Anchor.Anchor;
	toAnchor[containerAnchor.AlwaysShow.Buffs] = BuffHead.Container.Anchor.Buffs;
	toAnchor[containerAnchor.AlwaysShow.Debuffs] = BuffHead.Container.Anchor.Debuffs;
	
	BuffHead.Settings.Containers.AlwaysShow.Anchor = toAnchor[value];
	
	RepairChildAnchor(BuffHead.Settings.Containers.AlwaysShow.Anchor);
	ArrangeSquares();
	OnSettingsChanged();

end

function BuffHead.Setup.Container.OnContainerBuffsPlacementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ContainerBuffsPlacementCombo");
	
	BuffHead.Settings.Containers.Buffs.Placement = value;
	
	ArrangeSquares();
	OnSettingsChanged();

end

function BuffHead.Setup.Container.OnContainerBuffsAnchorChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ContainerBuffsAnchorCombo");
	
	local toAnchor = {};
	toAnchor[containerAnchor.Buffs.Anchor] = BuffHead.Container.Anchor.Anchor;
	toAnchor[containerAnchor.Buffs.AlwaysShow] = BuffHead.Container.Anchor.AlwaysShow;
	toAnchor[containerAnchor.Buffs.Debuffs] = BuffHead.Container.Anchor.Debuffs;
	
	BuffHead.Settings.Containers.Buffs.Anchor = toAnchor[value];
	
	RepairChildAnchor(BuffHead.Settings.Containers.Buffs.Anchor);
	ArrangeSquares();
	OnSettingsChanged();

end

function BuffHead.Setup.Container.OnContainerDebuffsPlacementChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ContainerDebuffsPlacementCombo");
	
	BuffHead.Settings.Containers.Debuffs.Placement = value;
	
	ArrangeSquares();
	OnSettingsChanged();

end

function BuffHead.Setup.Container.OnContainerDebuffsAnchorChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ContainerDebuffsAnchorCombo");
	
	local toAnchor = {};
	toAnchor[containerAnchor.Debuffs.Anchor] = BuffHead.Container.Anchor.Anchor;
	toAnchor[containerAnchor.Debuffs.AlwaysShow] = BuffHead.Container.Anchor.AlwaysShow;
	toAnchor[containerAnchor.Debuffs.Buffs] = BuffHead.Container.Anchor.Buffs;
	
	BuffHead.Settings.Containers.Debuffs.Anchor = toAnchor[value];
	
	RepairChildAnchor(BuffHead.Settings.Containers.Debuffs.Anchor);
	ArrangeSquares();
	OnSettingsChanged();

end

function BuffHead.Setup.Container.OnSlidePaddingHorizontal()

	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "ContainerPaddingHorizontalSlider") * MAX_PADDING_SLIDER);
	LabelSetText(windowName .. "ContainerPaddingHorizontalValue", towstring(value));

	if (BuffHead.Settings.Containers.Padding.X ~= value) then
		BuffHead.Settings.Containers.Padding.X = value;
		ArrangeSquares();
		OnSettingsChanged();
	end

end

function BuffHead.Setup.Container.OnSlidePaddingVertical()

	local value = math.floor(SliderBarGetCurrentPosition(windowName .. "ContainerPaddingVerticalSlider") * MAX_PADDING_SLIDER);
	LabelSetText(windowName .. "ContainerPaddingVerticalValue", towstring(value));

	if (BuffHead.Settings.Containers.Padding.Y ~= value) then
		BuffHead.Settings.Containers.Padding.Y = value;	
		ArrangeSquares();
		OnSettingsChanged();
	end

end

function BuffHead.Setup.Container.OnSlideColumns()

	if (not activeContainer) then return end
	local value = 1 + math.floor(SliderBarGetCurrentPosition(windowName .. "ContainerColumnsSlider") * (MAX_COLUMNS_SLIDER - 1));
	LabelSetText(windowName .. "ContainerColumnsValue", towstring(value));

	if (activeContainer.Size.Columns ~= value) then
		activeContainer.Size.Columns = value;	
		ArrangeSquares();
		OnSettingsChanged();
	end

end

function BuffHead.Setup.Container.OnSlideRows()

	if (not activeContainer) then return end
	local value = 1 + math.floor(SliderBarGetCurrentPosition(windowName .. "ContainerRowsSlider") * (MAX_ROWS_SLIDER - 1));
	LabelSetText(windowName .. "ContainerRowsValue", towstring(value));

	if (activeContainer.Size.Rows ~= value) then
		activeContainer.Size.Rows = value;	
		ArrangeSquares();
		OnSettingsChanged();
	end

end

function BuffHead.Setup.Container.OnSizeContainerTypeChanged()

	local value = ComboBoxGetSelectedMenuItem(windowName .. "ContainerTypeList");
	local container = containers[value];
	
	if (container) then
		SetContainer(container);
		OnSettingsChanged();
	end
	
end

function BuffHead.Setup.Container.OnContainerClick()

	local container = WindowGetId(SystemData.ActiveWindow.name);
	ComboBoxSetSelectedMenuItem(windowName .. "ContainerTypeList", container);
	BuffHead.Setup.Container.OnSizeContainerTypeChanged();
	OnSettingsChanged();

end