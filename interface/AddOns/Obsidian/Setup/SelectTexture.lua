Obsidian.Setup.SelectTexture = 
{
	WindowName = "ObsidianSetupSelectTextureWindow",
	Textures = {},
	TexturesOrder = {},
};

local windowName = Obsidian.Setup.SelectTexture.WindowName;
local callbackFunction = nil;
local activeRow = nil;
local activeWindow = nil;

local function SetupEntries()

	Obsidian.Setup.SelectTexture.Textures = {};
	Obsidian.Setup.SelectTexture.TexturesOrder = {};
	
	for index, texture in ipairs(Obsidian.Textures.GetTextures()) do
		table.insert(Obsidian.Setup.SelectTexture.Textures, { Name = towstring(texture.Name), Texture = texture.Texture });
		table.insert(Obsidian.Setup.SelectTexture.TexturesOrder, #Obsidian.Setup.SelectTexture.Textures);
	end
	
end

local function TintRow(rowName, isActive)

	local id = WindowGetId(rowName);
	local entry = Obsidian.Setup.SelectTexture.Textures[id];
		
	if (isActive) then
		WindowSetTintColor(rowName .. "Texture", 12, 47, 158);
	else
		WindowSetTintColor(rowName .. "Texture", 255, 255, 255);
	end

end

local function TintRows()
	for rowIndex, dataIndex in ipairs(ObsidianSetupSelectTextureWindowList.PopulatorIndices) do
		local rowName = windowName .. "ListRow" .. rowIndex;
		WindowSetId(rowName, dataIndex);
		local entry = Obsidian.Setup.SelectTexture.Textures[dataIndex];
		
		local texture = entry.Texture;
		local dimensions = Obsidian.Textures.GetDimensions(texture);
		DynamicImageSetTexture(rowName .. "Texture", texture, 0, 0);
		DynamicImageSetTextureDimensions(rowName .. "Texture", dimensions.Width, dimensions.Height);
		
		TintRow(rowName, (rowName == activeRow));
	end
end

function Obsidian.Setup.SelectTexture.Initialize()
	
	SetupEntries();
	
end

function Obsidian.Setup.SelectTexture.Show(window, anchorWindow, callback)
	if (WindowGetShowing(windowName) and anchorWindow == activeWindow) then
		WindowSetShowing(windowName, false);
		return;
	end	
	activeWindow = anchorWindow;
	
	ListBoxSetDisplayOrder(windowName .. "List", {})
	ListBoxSetDisplayOrder(windowName .. "List", Obsidian.Setup.SelectTexture.TexturesOrder);
	
	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, "bottomleft", anchorWindow, "topleft", 0, 0);
	
	callbackFunction = callback;
	WindowSetLayer(windowName, WindowGetLayer(window) + 1);
	WindowSetShowing(windowName, true);	
end

function Obsidian.Setup.SelectTexture.Hide()
	if (WindowGetShowing(windowName)) then
		WindowSetShowing(windowName, false);
	end
end

function Obsidian.Setup.SelectTexture.OnTextureRowMouseOver()
	
	if (activeRow) then
		TintRow(activeRow, false);
	end
	
	activeRow = SystemData.MouseOverWindow.name;
	TintRow(activeRow, true);
		
end

function Obsidian.Setup.SelectTexture.OnTextureRowMouseOut()

	if (activeRow) then
		TintRow(activeRow, false);
		activeRow = nil;
	end
		
end

function Obsidian.Setup.SelectTexture.OnTextureRowLDown()
	
end

function Obsidian.Setup.SelectTexture.OnTextureRowLUp()

	local id = WindowGetId(SystemData.MouseOverWindow.name);
	local entry = Obsidian.Setup.SelectTexture.Textures[id];
	if (not entry) then return end
	
	if (type(callbackFunction) == "function") then
		local dimensions = Obsidian.Textures.GetDimensions(entry.Texture);
		callbackFunction({ Name = entry.Name, Texture = entry.Texture, Dimensions = dimensions});
	end
	
	if (activeRow) then
		TintRow(activeRow, true);
	end
	
	WindowSetShowing(windowName, false);
	
end

function Obsidian.Setup.SelectTexture.OnTextureRowRDown()
	
end

function Obsidian.Setup.SelectTexture.OnTextureRowRUp()
		
end

function Obsidian.Setup.SelectTexture.OnPopulate()

	if (not ObsidianSetupSelectTextureWindowList.PopulatorIndices) then
		return;
	end

	TintRows();
	
end