-- first, we need LibGUI
local LibGUI = LibStub("LibGUI")
if (not LibGUI) then return end

-- create an instance of LibConfig
local MAJOR, MINOR = "LibConfig", 1
local LibConfig, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

-- sanity check
if (not LibConfig) then return end

-- create table of config menus
if (not LibConfig.configurations) then LibConfig.configurations = {} end

-- create menu object metatable
if (not LibConfigMenu) then LibConfigMenu = {} end

-- create 

------------------------------------------------------------------------------------
------ Core Functions
------------------------------------------------------------------------------------

-- creates a new config menu
function LibConfig:New(title, settings, isTabbed, callbackFunction)

	-- new menu object
	local configMenu = {}
	-- forward the function calls of the menu object to LibConfigMenu
	setmetatable(configMenu, {__index = LibConfigMenu, __call = LibConfigMenu.Add})
	-- save this menu for later purposes
	table.insert(LibConfig.configurations, configMenu)
	
	configMenu.callbackFunction = callbackFunction
	configMenu.settings = settings
	configMenu.title = title
	configMenu.isTabbed = isTabbed
	configMenu.currentTab = 0
	configMenu.currentTabPage = 1
	configMenu.firstShown = false
	
	if (isTabbed) then
		configMenu.width = 700
	else
		configMenu.width = 500
	end
	configMenu.height = 550
	
	-- create the window object
	local window = LibGUI("blackframe")
	configMenu.window = window
	
	window:Resize(configMenu.width, configMenu.height);
	window:MakeMovable()
	window:AnchorTo("Root","center","center")
	window:Hide()
	
	window.closeButton = window("closebutton")
	window.closeButton.OnLButtonUp = function() configMenu:Hide() end
	
	window.titleText = window("label")
	window.titleText:Resize(configMenu.width)
	window.titleText:AnchorTo(window, "top", "top", 0, 5)
	window.titleText:Font("font_clear_large_bold")
	window.titleText:Align("center")
	window.titleText:IgnoreInput()
	window.titleText:SetText(configMenu.title)

	window.cancelButton = window("button")
	window.cancelButton:Resize(100)
	if (isTabbed) then
		window.cancelButton:AnchorTo(window, "bottom", "bottom", 110, -12)
	else
		window.cancelButton:AnchorTo(window, "bottom", "bottom", 0, -12)
	end
	window.cancelButton:SetText("Cancel")
	window.cancelButton.OnLButtonUp = function() configMenu:Hide() end

	window.saveButton = window("button")
	window.saveButton:Resize(100)
	window.saveButton:AnchorTo(window.cancelButton, "left", "right", -5)
	window.saveButton:SetText("Save")
	window.saveButton.OnLButtonUp = function() configMenu:Save() end
	
	window.revertButton = window("button")
	window.revertButton:Resize(100)
	window.revertButton:AnchorTo(window.cancelButton, "right", "left", 5)
	window.revertButton:SetText("Revert")
	window.revertButton.OnLButtonUp = function() configMenu:Reset() end
	
	window.leftPageButton = window("button")
	window.leftPageButton:Resize(50)
	window.leftPageButton:AnchorTo(window.saveButton, "left", "right", -5)
	window.leftPageButton:SetText("<<")
	window.leftPageButton.OnLButtonUp = function() configMenu:SwapPage(-1) end
	
	window.rightPageButton = window("button")
	window.rightPageButton:Resize(50)
	window.rightPageButton:AnchorTo(window.revertButton, "right", "left", 5)
	window.rightPageButton:SetText(">>")
	window.rightPageButton.OnLButtonUp = function() configMenu:SwapPage(1) end
	
	if (isTabbed) then
		window.tabUpButton = window("button")
		window.tabUpButton:Resize(180)
		window.tabUpButton:AnchorTo(window, "topleft", "topleft", 20, 40)
		window.tabUpButton:SetText("^")
		window.tabUpButton.OnLButtonUp = function() configMenu:SwapTabs(-1) end
	
		window.tabDownButton = window("button")
		window.tabDownButton:Resize(180)
		window.tabDownButton:AnchorTo(window, "topleft", "topleft", 20, 480)
		window.tabDownButton:SetText("v")
		window.tabDownButton.OnLButtonUp = function() configMenu:SwapTabs(1) end
	end
	
	-- set up the layers for this menu
	configMenu.layers = {}
	-- non-tabbed menus only have one layer, create now
	if (not isTabbed) then
		local layer = window("window")
		table.insert(configMenu.layers, layer)
		
		layer:Resize(configMenu.width - 40, configMenu.height - 100)
		layer:AnchorTo(window, "topleft", "topleft", 20, 40)
		layer.pages = {{elements = {}}}
		layer.currentPage = 1
		
		configMenu.currentTab = 1
	end

	
	return configMenu
end


------------------------------------------------------------------------------------
------ Menu Functions
------------------------------------------------------------------------------------

function LibConfigMenu:Show()
	if (not self.firstShown) then
		self.currentTab = 1
		self.firstShown = true
	end

	self.window:Show()
	
	-- reset all values on all tabs
	for id, layer in ipairs(self.layers) do
		layer:Hide()
		self:ResetTab(id)
	end
	
	-- show the tab we're interested in
	self.layers[self.currentTab]:Show()
	
	if (self.layers[self.currentTab].currentPage == 1) then
		self.window.leftPageButton:Disable()
	else
		self.window.leftPageButton:Enable()
	end
	
	if (self.layers[self.currentTab].currentPage == #self.layers[self.currentTab].pages) then
		self.window.rightPageButton:Disable()
	else
		self.window.rightPageButton:Enable()
	end
	
	self:UpdateTabButtons()
end

function LibConfigMenu:UpdateTabButtons()
	if (not self.isTabbed) then return end
	
	for _, layer in pairs(self.layers) do
		layer.correspondingButton:Hide()
	end
	self.window.tabDownButton:Hide()
	self.window.tabUpButton:Hide()
	
	local delta = 0
	local numberOfTabs = 12
	local firstTab = 1
	
	if (self.currentTabPage > 1) then
		firstTab = self.currentTabPage * 10 - 8
	end
	
	if (self.currentTabPage > 1) then
		self.window.tabUpButton:Show()
		numberOfTabs = numberOfTabs - 1
		delta = 40
	end
	
	for i=0,numberOfTabs-1 do
		if (firstTab+i > #self.layers) then return end
		self.layers[firstTab+i].correspondingButton:Show()
		self.layers[firstTab+i].correspondingButton:AnchorTo(self.window, "topleft", "topleft", 20, 40 * (i + 1) + delta)
		if (i == numberOfTabs-1) then
			if (#self.layers > firstTab+i) then
				self.window.tabDownButton:Show()
				self.layers[firstTab+i].correspondingButton:Hide()
			end
		end
		if (self.currentTab == firstTab+i) then
			ButtonSetPressedFlag(self.layers[firstTab+i].correspondingButton.name, true)
		else
			ButtonSetPressedFlag(self.layers[firstTab+i].correspondingButton.name, false)
		end
	end
end

function LibConfigMenu:Hide()
	self.window:Hide()
	LibConfig.colorizer:Hide()
end

function LibConfigMenu:Reset()
	for id, _ in ipairs(self.layers) do
		self:ResetTab(id)
	end
end

function LibConfigMenu:Save()
	local settingsChanged = false

	for _, layer in ipairs(self.layers) do
		for _, page in ipairs(layer.pages) do
			for _, element in ipairs(page.elements) do
				if (element.settingsPath and element.elementType ~= "label") then
					
					local oldValue = self.settings
					for _, path in ipairs(element.settingsPath) do
						oldValue = oldValue[path]
					end
					
					local newValue
					if (element.elementType == "textbox") then
						newValue = WStringToString(element.edit:GetText())
					elseif (element.elementType == "checkbox") then
						newValue = element.check:GetValue()
					elseif (element.elementType == "combobox") then
						newValue = element.combo:Selected()
					elseif (element.elementType == "color") then
						local r, g, b = WindowGetTintColor(element.overlay.name)
						newValue = {r, g, b}
					end
					
					if (newValue ~= nil) then
						if (type(oldValue) == "string" and type(newValue) == "wstring") then
							newValue = WStringToString(newValue)
						end
						
						if (type(oldValue) == "wstring" and type(newValue) == "string") then
							newValue = StringToWString(newValue)
						end
						
						if (type(oldValue) == "number") then
							newValue = tonumber(newValue)
						end
						
						if (element.callbackFunction) then
							newValue = element.callbackFunction(newValue)
						end
						
						if (newValue ~= oldValue) then
							settingsChanged = true
							local reference = self.settings
							for i=1, #element.settingsPath - 1 do
								reference = reference[element.settingsPath[i]]
							end
							reference[element.settingsPath[#element.settingsPath]] = newValue
						end
					end
				end
			end
		end
	end
	
	if (settingsChanged and self.callbackFunction) then
		self.callbackFunction()
	end
end

function LibConfigMenu:SelectTab(id)
	self.layers[self.currentTab]:Hide()
	self.currentTab = id
	self.layers[self.currentTab]:Show()
	
	if (self.layers[self.currentTab].currentPage == 1) then
		self.window.leftPageButton:Disable()
	else
		self.window.leftPageButton:Enable()
	end
	
	if (self.layers[self.currentTab].currentPage == #self.layers[self.currentTab].pages) then
		self.window.rightPageButton:Disable()
	else
		self.window.rightPageButton:Enable()
	end
	
	self:UpdateTabButtons()
end

function LibConfigMenu:SwapTabs(delta)
	self.currentTabPage = self.currentTabPage + delta
	self:UpdateTabButtons()
end

function LibConfigMenu:SwapPage(delta)
	local pageNumber = self.layers[self.currentTab].currentPage
	local numPages = #self.layers[self.currentTab].pages
	
	pageNumber = pageNumber + delta
	if (pageNumber < 1) or (pageNumber > numPages) then
		return
	else
		for _, element in pairs(self.layers[self.currentTab].pages[pageNumber - delta].elements) do
			element:Hide()
		end
		
		for _, element in pairs(self.layers[self.currentTab].pages[pageNumber].elements) do
			element:Show()
		end
		
		self.layers[self.currentTab].currentPage = pageNumber
		
		if (pageNumber == 1) then
			self.window.leftPageButton:Disable()
		else
			self.window.leftPageButton:Enable()
		end
		
		if (pageNumber == numPages) then
			self.window.rightPageButton:Disable()
		else
			self.window.rightPageButton:Enable()
		end
	end
end

function LibConfigMenu:ResetTab(id)
	local layer = self.layers[id]
	
	-- cycle through all elements on all pages
	for pageNumber, page in pairs(layer.pages) do
		for _, element in pairs(page.elements) do
			
			if (element.settingsPath) then
				-- get the value of the element
				local value = self.settings
				for _, path in ipairs(element.settingsPath) do
					value = value[path]
				end
				
				-- set the value depending on elementType
				if (element.elementType == "textbox") then
					element.edit:SetText(value)
				elseif (element.elementType == "checkbox") then
					element.check:SetValue(value)
				elseif (element.elementType == "label") then
					element.text:SetText(value)
				elseif (element.elementType == "combobox") then
					element.combo:Select(value)
				elseif (element.elementType == "color") then
					element.overlay:Tint(value)
				end
			end
			
			-- show only the elements of the current page
			if (pageNumber ~= layer.currentPage) then
				element:Hide()
			else
				element:Show()
			end
		end
	end
end

function LibConfigMenu:AddTab(name)
	-- ignore call if not a tabbed menu
	if (not self.isTabbed) then return end

	local currentTab = self.currentTab + 1
	self.currentTab = currentTab
	
	-- add a new layer
	local layer = self.window("window")
	layer:Resize(self.width - 240, self.height - 100)
	layer:AnchorTo(self.window, "topleft", "topleft", 220, 40)
	layer.pages = {{elements = {}}}
	layer.currentPage = 1
	
	table.insert(self.layers, layer)
	
	-- add a new tab button
	local button = self.window("button")
	button:Resize(180)
	button:SetText(name)
	button.OnLButtonUp = function() self:SelectTab(currentTab) end
	button:AnchorTo(self.window, "topleft", "topleft", 20, 40 * currentTab)
	button:Show()
	
	-- register that button with the layer
	layer.correspondingButton = button
end

function LibConfigMenu:Add(elementType, labelText, settingsPath, callbackFunction)
	-- if we don't have set up any tabs yet, ignore
	if (self.currentTab == 0) then return end

	-- get the current working layer
	local layer = self.layers[self.currentTab]
	
	-- get to the latest page of the current layer
	local pageNumber = #layer.pages
	local page = layer.pages[pageNumber]
	
	-- just skip the rest of the page and create a new one
	if (settingsPath == "newpage") then
		table.insert(layer.pages, {elements = {}})
		pageNumber = pageNumber + 1
		page = layer.pages[pageNumber]
		
		return
	end
	
	-- if there are already 5 elements on that page, create a new one
	if (#page.elements >= 5) then
		table.insert(layer.pages, {elements = {}})
		pageNumber = pageNumber + 1
		page = layer.pages[pageNumber]
	end
	
	-- create the window that holds our configuration element
	local element = layer("window")
	table.insert(page.elements, element)
	
	element:Resize(layer.width, 80)
	element:AnchorTo(layer, "topleft", "topleft", 0, (#page.elements - 1) * 80)
	
	if (type(settingsPath) == "string") then settingsPath = {settingsPath} end
	element.settingsPath = settingsPath
	element.elementType = elementType
	element.callbackFunction = callbackFunction
	
	if (elementType == "textbox") then
		element.label = element("label")
		element.label:Resize(element.width)
		element.label:AnchorTo(element, "top", "top")
		element.label:SetText(labelText)

		element.edit = element("textbox")
		element.edit:Resize(element.width * 0.8)
		element.edit:AnchorTo(element.label, "bottom", "top")
	elseif (elementType == "checkbox") then
		element.check = element("checkbox")
		element.check:AnchorTo(element, "left", "left", 48, -5)
		
		element.label = element("label")
		element.label:Resize(element.width - 50)
		element.label:AnchorTo(element.check, "right", "left", 10, 5)
		element.label:SetText(labelText)
		element.label:Align("left")
	elseif (elementType == "combobox") then
		element.label = element("label")
		element.label:Resize(element.width)
		element.label:AnchorTo(element, "top", "top")
		element.label:SetText(labelText)

		element.combo = element("combobox")
		element.combo:AnchorTo(element.label, "bottom", "top")
--	elseif (elementType == "slider") then
--		element.label = element("label")
--		element.label:Resize(element.width)
--		element.label:AnchorTo(element, "top", "top")
--		element.label:SetText(labelText)
--
--		element.slider = element("slider")
--		element.slider:AnchorTo(element.label, "bottom", "top")
	elseif (elementType == "color") then
		element.label = element("label")
		element.label:Resize(element.width)
		element.label:AnchorTo(element, "top", "top")
		element.label:SetText(labelText)

		element.overlay = element("image")
		element.overlay:Resize(element.width * 0.6, 40)
		element.overlay:AnchorTo(element.label, "bottom", "top")
		element.overlay:IgnoreInput()
		element.overlay:Texture("EA_HUD_01")
		element.overlay:TexSlice("CastBar")
		element.overlay:TexDims(50,14)

		element.button = element("button")
		element.button:Resize(element.overlay.width, element.overlay.height)
		element.button:AnchorTo(element.overlay, "topleft", "topleft")
		element.button:Alpha(0)
		element.button.OnLButtonUp = function()
										LibConfig.colorizer:Show()
										LibConfig.colorizer:AnchorTo(element.overlay, "topright", "topleft", 20, 0)
										LibConfig.colorizer.object = element.overlay
										local r, g, b = WindowGetTintColor(LibConfig.colorizer.object.name)
										LibConfig.colorizer.r:SetValue(r)
										LibConfig.colorizer.g:SetValue(g)
										LibConfig.colorizer.b:SetValue(b)
									 end
		
	elseif (elementType == "label") then
		if (settingsPath) then
			-- case 1: we have a title and a text field
			element.label = element("label")
			element.label:Resize(element.width)
			element.label:AnchorTo(element, "top", "top")
			element.label:SetText(labelText)
		
			element.text = element("label")
			element.text:Resize(element.width)
			element.text:AnchorTo(element.label, "bottom", "top")
		else
			-- case 2: we don't have a variable specified. this is special to label elements
			element.label = element("label")
			element.label:Resize(element.width, element.height)
			element.label:AnchorTo(element, "top", "top")
			element.label:WordWrap(true)
			element.label:Align("center")
			element.label:SetText(labelText)
		end
	end

	return element
end


------------------------------------------------------------------------------------
------ Color Picker Menu
------------------------------------------------------------------------------------

if (not LibConfig.colorizer) then
	LibConfig.colorizer = LibGUI("Blackframe")
	LibConfig.colorizer:Resize(250,250)
	LibConfig.colorizer:Position(500,200)
	LibConfig.colorizer:Hide()
	
	LibConfig.colorizer.rLabel = LibConfig.colorizer("Label")
	LibConfig.colorizer.rLabel:SetText("red")
	LibConfig.colorizer.rLabel:Position(20,0)
	LibConfig.colorizer.rLabel:Color(255,50,50)
	
	LibConfig.colorizer.r = LibConfig.colorizer("Slider")
	LibConfig.colorizer.r:Position(20,20)
	LibConfig.colorizer.r:SetRange(0,255)
	
	LibConfig.colorizer.gLabel = LibConfig.colorizer("Label")
	LibConfig.colorizer.gLabel:SetText("green")
	LibConfig.colorizer.gLabel:Position(20,60)
	LibConfig.colorizer.gLabel:Color(50,255,50)
	
	LibConfig.colorizer.g = LibConfig.colorizer("Slider")
	LibConfig.colorizer.g:Position(20,80)
	LibConfig.colorizer.g:SetRange(0,255)

	LibConfig.colorizer.bLabel = LibConfig.colorizer("Label")
	LibConfig.colorizer.bLabel:SetText("blue")
	LibConfig.colorizer.bLabel:Position(20,120)
	LibConfig.colorizer.bLabel:Color(50,50,255)
	
	LibConfig.colorizer.b = LibConfig.colorizer("Slider")
	LibConfig.colorizer.b:Position(20,140)
	LibConfig.colorizer.b:SetRange(0,255)
	
	LibConfig.colorizer.okayButton = LibConfig.colorizer("Button")
	LibConfig.colorizer.okayButton:SetText("Okay")
	LibConfig.colorizer.okayButton:Resize(200)
	LibConfig.colorizer.okayButton:AnchorTo(LibConfig.colorizer, "bottom", "bottom", 0, -20)
	LibConfig.colorizer.okayButton.OnLButtonUp =
		function()
			LibConfig.colorizer:Hide()
		end
end

function LibConfig.OnUpdate()
	if (LibConfig.colorizer:Showing()) then
		WindowSetTintColor(LibConfig.colorizer.object.name,
							 LibConfig.colorizer.r:GetValue(),
							 LibConfig.colorizer.g:GetValue(),
							 LibConfig.colorizer.b:GetValue())
	end		
end


------------------------------------------------------------------------------------
------ Metafunctions
------------------------------------------------------------------------------------

-- call of LibConfig results in LibConfig:New()
setmetatable(LibConfig, {__call = LibConfig.New})

RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "LibConfig.OnUpdate")