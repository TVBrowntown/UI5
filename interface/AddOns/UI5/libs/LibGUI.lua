local MAJOR, MINOR = "LibGUI", 10

local LibGUI, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibGUI then return end

-- Make utility functions local for performance
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local tonumber = tonumber
local towstring = towstring
local max = math.max
local min = math.min
local LabelSetText = LabelSetText
local LabelSetTextColor = LabelSetTextColor
local WindowAddAnchor = WindowAddAnchor
local WindowClearAnchors = WindowClearAnchors
local WindowGetScale = WindowGetScale
local WindowGetShowing = WindowGetShowing
local WindowSetAlpha = WindowSetAlpha
local WindowSetDimensions = WindowSetDimensions
local WindowSetShowing = WindowSetShowing
local WindowSetTintColor = WindowSetTintColor
local WindowSetScale = WindowSetScale

-- Initialize any of our element objects that don't exist yet
if not LIBGUI_ELEMENT then LIBGUI_ELEMENT = {} LIBGUI_ELEMENT.__index = LIBGUI_ELEMENT end

local function newElement()
    local i = setmetatable({}, LIBGUI_ELEMENT)
    i.__index = i
    return i
end

LIBGUI_Window       = LIBGUI_Window         or newElement()
LIBGUI_Label        = LIBGUI_Label          or newElement()
LIBGUI_Button       = LIBGUI_Button         or newElement()
LIBGUI_Textbox      = LIBGUI_Textbox        or newElement()
LIBGUI_MultiTextbox = LIBGUI_MultiTextbox   or newElement()
LIBGUI_Checkbox     = LIBGUI_Checkbox       or newElement()
LIBGUI_Slider       = LIBGUI_Slider         or newElement()
LIBGUI_Combobox     = LIBGUI_Combobox       or newElement()
LIBGUI_Scrollbar    = LIBGUI_Scrollbar      or newElement()
LIBGUI_Statusbar    = LIBGUI_Statusbar      or newElement()
LIBGUI_Optionbutton = LIBGUI_Optionbutton   or newElement()
LIBGUI_Closebutton  = LIBGUI_Closebutton    or newElement()
LIBGUI_Image        = LIBGUI_Image          or newElement()

---------------------------------------- LIBGUI Core ----------------------------------------------

if not LibGUI.elements then LibGUI.elements = {} end
if not LibGUI.elementCount then LibGUI.elementCount = 0 end

local function getNewElementName(elementType)
    return "LIBGUI_"..elementType..(LibGUI.elementCount + 1)
end

local function getNewWindowElementName(elementType, window)
    return window..elementType..(LibGUI.elementCount + 1)
end

-- GENERIC ELEMENT MANIPULATORS
do
    -- the events we want to register for all LibGUI elements
    local elementEvents = {
        "OnLButtonUp",
        "OnLButtonDown",
        "OnRButtonUp",
        "OnRButtonDown",
        "OnMouseOver", 
        "OnMouseOverEnd"
    }

    function LIBGUI_ELEMENT:Show()
        if (not self.name) or (self.name=="") then return end
        WindowSetShowing(self.name, true)
    end
    
    function LIBGUI_ELEMENT:Hide()
        if (not self.name) or (self.name=="") then return end
        WindowSetShowing(self.name, false)
    end
    
    function LIBGUI_ELEMENT:Showing()
        if (not self.name) or (self.name=="") then return end
        return WindowGetShowing(self.name)
    end
    
    function LIBGUI_ELEMENT:CaptureInput()
        if (not self.name) or (self.name=="") then return end
        WindowSetHandleInput(self.name, true)
    end
    
    function LIBGUI_ELEMENT:IgnoreInput()
        if (not self.name) or (self.name=="") then return end
        WindowSetHandleInput(self.name, false)
    end
	
	function LIBGUI_ELEMENT:TakesInput()
		if (not self.name) or (self.name=="") then return end
		return WindowGetHandleInput(self.name)
	end
    
    function LIBGUI_ELEMENT:MakeMovable()
        if (not self.name) or (self.name=="") then return end
        WindowSetHandleInput(self.name, true)
        WindowSetMovable(self.name, true)
    end
    
    function LIBGUI_ELEMENT:MakeFixed()
        if (not self.name) or (self.name=="") then return end
        WindowSetMovable(self.name, false)
    end
	
	function LIBGUI_ELEMENT:ProcessAnchors()
        if (not self.name) or (self.name=="") then return end
        WindowForceProcessAnchors(self.name)
    end
    
    function LIBGUI_ELEMENT:Destroy()
        if (not self.name) or (self.name=="") then return end
        if self.events then
            for e,_ in pairs(self.events) do 
                self:UnregisterEvent(e)
            end
        end
        DestroyWindow(self.name)
        LibGUI.elements[self.name] = {["destroyed"]=true}
        self.name = nil
    end
    
    function LIBGUI_ELEMENT:Parent(parent)
        local parent = parent
        if type(parent) == "table" then parent = parent.name end
        if type(parent) ~= "string" then parent = "Root" end
        self.parent = parent
        WindowSetParent(self.name, self.parent)
    end
    
    function LIBGUI_ELEMENT:AddAnchor(anchorWindow, pointOnAnchor, pointOnSelf, xOffset, yOffset)
        if (not self.name) or (self.name=="") then return end
        local anchorWindow = anchorWindow or self.parent
        if type(anchorWindow) == "table" then anchorWindow = anchorWindow.name end
        if type(anchorWindow) ~= "string" then return end
        local pointOnAnchor = pointOnAnchor or "topleft"
        local pointOnSelf = pointOnSelf or "topleft"
        local xOffset = xOffset or 0
        local yOffset = yOffset or 0
        WindowAddAnchor(self.name, pointOnAnchor, anchorWindow, pointOnSelf, xOffset, yOffset)
    end
    
    function LIBGUI_ELEMENT:ClearAnchors()
        if (not self.name) or (self.name=="") then return end
        WindowClearAnchors(self.name)
    end
    
    function LIBGUI_ELEMENT:AnchorTo(anchorWindow, pointOnAnchor, pointOnSelf, xOffset, yOffset)
        if (not self.name) or (self.name=="") then return end
        local anchorWindow = anchorWindow
        if type(anchorWindow) == "table" then anchorWindow = anchorWindow.name end
        if type(anchorWindow) ~= "string" then return end
        self:ClearAnchors()
        self:AddAnchor(anchorWindow, pointOnAnchor, pointOnSelf, xOffset, yOffset)
    end
    
    function LIBGUI_ELEMENT:Position(x,y)
        if (not self.name) or (self.name=="") then return end
        self:ClearAnchors()
        self:AddAnchor(self.parent or "Root", "topleft", "topleft", x, y)
    end
    
    function LIBGUI_ELEMENT:GetPosition()
        if (not self.name) or (self.name=="") then return end
        local point,relpoint,relwin,x,y = WindowGetAnchor(self.name, 1)
        return x,y
    end
    
    function LIBGUI_ELEMENT:Layer(layer)
        local layer = layer
        if (not self.name) or (self.name=="") then return end
        if layer == nil then
            return WindowGetLayer(self.name)
        else
            if type(layer) == "string" then layer = Window.Layers[layer:upper()] end
            if type(layer) ~= "number" then return end
            WindowSetLayer(self.name, layer)
            return layer
        end
    end
    
    function LIBGUI_ELEMENT:Popable(val)
        if (not self.name) or (self.name=="") then return end
        if val == nil then
            return WindowGetPopable(self.name)
        else
            WindowSetPopable(self.name, val)
        end
    end
    
    function LIBGUI_ELEMENT:Alpha(alpha)
        local alpha = alpha
        if (not self.name) or (self.name=="") then return end
        if alpha == nil then
            return WindowGetAlpha(self.name)
        else
            if type(alpha) ~= "number" then return end
            alpha = max(0, min(1, alpha))
            WindowSetAlpha(self.name, alpha)
            return alpha
        end
    end
	
	function LIBGUI_ELEMENT:FontAlpha(alpha)
        local alpha = alpha
        if (not self.name) or (self.name=="") then return end
        if alpha == nil then
            return WindowGetFontAlpha(self.name)
        else
            if type(alpha) ~= "number" then return end
            alpha = max(0, min(1, alpha))
            WindowSetFontAlpha(self.name, alpha)
            return alpha
        end
    end
	
	function LIBGUI_ELEMENT:Focus()
		if (not self.name) or (self.name=="") then return end
		WindowAssignFocus(self.name, true)
	end
	
	function LIBGUI_ELEMENT:Defocus()
		if (not self.name) or (self.name=="") then return end
		WindowAssignFocus(self.name, false)
	end
    
    function LIBGUI_ELEMENT:Scale(scale, relative)
        if (not self.name) or (self.name=="") then return end
        if not scale then
            return WindowGetScale(self.name)
        else
            if relative then
                scale = scale * InterfaceCore.GetScale()
            end
            WindowSetScale(self.name, scale)
            return scale
        end
    end
    
    function LIBGUI_ELEMENT:Tint(r,g,b)
        if (not self.name) or (self.name=="") then return end
        if type(r) == "table" then
            r,g,b = unpack(r)
        end
        if r and g and b then
            WindowSetTintColor(self.name, r, g, b)
            return r,g,b
        else
            return false
        end
    end
	
	function LIBGUI_ELEMENT:SetId(id)
		if (not self.name) or (self.name=="") then return end
		if type(id) == "string" then id = tonumber(id) end
		if type(id) ~= "number" then return end
		WindowSetId(self.name, id)
	end
	
	function LIBGUI_ELEMENT:GetId()
		if (not self.name) or (self.name=="") then return end
		return WindowGetId(self.name)
	end
            
    function LIBGUI_ELEMENT:RegisterDefaultEvents()
        if (not self.name) or (self.name=="") then return end
        if not self.rEvents then self.rEvents = {} end
        for _,e in ipairs(elementEvents) do
            if not self.rEvents[e] then
                WindowRegisterCoreEventHandler(self.name, e, "LIBGUI_ELEMENT.events."..e.."."..self.name)
                self.rEvents[e] = true
            end
        end
    end
    
    function LIBGUI_ELEMENT:RegisterEvent(e)
        if (not self.name) or (self.name=="") then return end
        if not self.rEvents then self.rEvents = {} end
        if not self.rEvents[e] then
            WindowRegisterCoreEventHandler(self.name, e, "LIBGUI_ELEMENT.events."..e.."."..self.name)
            self.rEvents[e] = true
        end
    end
    
    function LIBGUI_ELEMENT:UnregisterEvent(e)
        if (not self.name) or (self.name=="") then return end
        if not self.rEvents then self.rEvents = {} end
        if self.rEvents[e] then
            WindowUnregisterCoreEventHandler(self.name, e)
            self.rEvents[e] = false
        end
    end
    
    function LIBGUI_ELEMENT:UnregisterDefaultEvents()
        if (not self.name) or (self.name=="") then return end
        if not self.rEvents then self.rEvents = {} end
        for _,e in ipairs(elementEvents) do
            if self.rEvents[e] then
                WindowUnregisterCoreEventHandler(self.name, e)
                self.rEvents[e] = false
            end
        end
    end
    
    -- Event handler tables (automatically generate handler functions)
    --    LIBGUI_ELEMENT.events.<EVENTNAME>.<ELEMENTNAME> will redirect to the proper element handler functions
    local function GetHandlerMT(handlerType)
        return {
            __index = function(self,index)
                        self[index]=function(...)
                            if LibGUI.elements[index][handlerType] then
                                LibGUI.elements[index][handlerType](LibGUI.elements[index], ...)
                            else return end
                          end
                          
                        return self[index]
                      end
        }
    end
    
    local eventMT={
        __index = function(self,index)
                    self[index]=setmetatable({}, GetHandlerMT(index))
                    return self[index]
                  end
    }
    LIBGUI_ELEMENT.events = setmetatable({}, eventMT)
    
end -- ELEMENT
    
    
    
-- WINDOW
do
    function LIBGUI_Window:New(windowName, base, parent)
        local base = base or "EA_Window_Default"
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
        w.elements = {}
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
            w.width = 500
            w.height = 300
            w:Resize(w.width, w.height)
            w:CaptureInput()
            w:MakeFixed()
            w:Layer("DEFAULT")
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end

    function LIBGUI_Window:Resize(width, height)
        if (not self.name) or (self.name=="") then return end
        self.width = width or self.width
        self.height = height or self.height
        WindowSetDimensions(self.name, self.width, self.height)
    end
    
    function LIBGUI_Window:Add(elementType, elementName, elementBase)
        if (not self.name) or (self.name=="") then return end
        
        local newElement = nil
        if type(elementType) == "table" then
            -- if it's a table, we'll assume it's an existing LibGUI object and just parent/associate it with ourself (instead of creating a new element)
            -- this lets us do myWindow:Add(myObject) to just associate something, instead of myWindow:Add("typename") to get a new element
            newElement = elementType
        else
            elementName = elementName or getNewWindowElementName(elementType, self.name)
            newElement = LibGUI:New(elementType, elementName, elementBase)
        end
        
        if not newElement then return end
        newElement:Parent(self)
        table.insert(self.elements, newElement)
        return newElement
    end
    
end -- WINDOW



-- LABEL
do
    function LIBGUI_Label:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        local base = base or "EA_Label_DefaultText"
        w.name = windowName
        w.parent = parent or "Root"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
            w.width = 200
            w.height = 30
            w:Resize(w.width, w.height)
            w:RegisterDefaultEvents()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Label:Resize(width, height)
        if (not self.name) or (self.name=="") then return end
        self.width = width or 200
        self.height = height or 30
        WindowSetDimensions(self.name, self.width, self.height)
    end
    
    function LIBGUI_Label:SetText(text)
        if (not self.name) or (self.name=="") then return end
        
        local text = text
        if type(text) == "boolean" then text = text and L"true" or L"false" end
        LabelSetText(self.name, towstring(text))
    end
    
    function LIBGUI_Label:GetText()
        if (not self.name) or (self.name=="") then return end
        return LabelGetText(self.name)
    end
    
    function LIBGUI_Label:Clear()
        if (not self.name) or (self.name=="") then return end
        return LabelSetText(self.name, L"")
    end
    
    function LIBGUI_Label:Font(font, linespacing)
        if (not self.name) or (self.name=="") then return end
        local font = font or "font_default_text"
        local linespacing = linespacing or WindowUtils.FONT_DEFAULT_TEXT_LINESPACING
        LabelSetFont(self.name, font, linespacing)
    end
    
    function LIBGUI_Label:WordWrap(newVal)
        if (not self.name) or (self.name=="") then return end
        if newVal == nil then return LabelGetWordWrap(self.name) end
        if newVal then
            LabelSetWordWrap(self.name, true)
            return true
        else
            LabelSetWordWrap(self.name, false)
            return false
        end
    end
    
    function LIBGUI_Label:Color(red, green, blue)
        if (not self.name) or (self.name=="") then return end
        if not red then return LabelGetTextColor(self.name) end
        local red = min(255, max(0, red))
        local green = min(255, max(0, green))
        local blue = min(255, max(0, blue))
        LabelSetTextColor(self.name, red, green, blue)
        return red, green, blue
    end
    
    function LIBGUI_Label:Align(align)
        if (not self.name) or (self.name=="") then return end
        local align = align
        -- We'll be forgiving with some common directions that aren't ambiguous
        if align == "topleft" then align = "left" end
        if align == "topright" then align = "right" end
        if align == "centerleft" then align = "leftcenter" end
        if align == "centerright" then align = "rightcenter" end
        local validAligns = {
            ["left"] = 1,
            ["center"] = 1,
            ["right"] = 1,
            ["leftcenter"] = 1,
            ["rightcenter"] = 1,
            ["top"] = 1,
            ["bottom"] = 1,
            ["bottomleft"] = 1,
            ["bottomright"] = 1,
        }
        if validAligns[align] then
            LabelSetTextAlign(self.name, align)
            return align
        else
            return nil
        end
    end
    
end --LABEL


    
-- BUTTON
do
    function LIBGUI_Button:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
	local base = base or "DefaultHorizResizeButton"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            w:Resize(w.width)
            w:RegisterDefaultEvents()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Button:Resize(width)
        if (not self.name) or (self.name=="") then return end
        self.width = width or 200
        WindowSetDimensions(self.name, width, self.height)
    end
    
    function LIBGUI_Button:SetText(text)
        if (not self.name) or (self.name=="") then return end
        if type(text) == "boolean" then
            -- handle booleans specially because towstring() isn't properly defined for booleans
            ButtonSetText(self.name, text and L"true" or L"false")
        else
            ButtonSetText(self.name, towstring(text))
        end
    end
    
    function LIBGUI_Button:TextColor(red, green, blue)
        if (not self.name) or (self.name=="") then return end
        if not red then return ButtonGetTextColor(self.name) end
        local red = min(255, max(0, red))
        local green = min(255, max(0, green))
        local blue = min(255, max(0, blue))
        ButtonSetTextColor(self.name, red, green, blue)
        return red, green, blue
    end
    
    function LIBGUI_Button:SetEnabled(flag)
        if (not self.name) or (self.name=="") then return end
        ButtonSetDisabledFlag(self.name, not flag)
    end
    
    function LIBGUI_Button:Enabled()
        if (not self.name) or (self.name=="") then return end
        return (not ButtonGetDisabledFlag(self.name))
    end
    
    function LIBGUI_Button:Enable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(true)
    end
    
    function LIBGUI_Button:Disable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(false)
    end
    
    function LIBGUI_Button:Action(actionType, numArg, wstringArg)
        if (not self.name) or (self.name=="") then return end
        WindowSetGameActionData(self.name, actionType, numArg, wstringArg)
    end
    
    function LIBGUI_Button:Trigger(action)
        if (not self.name) or (self.name=="") then return end
        if type(action) == "string" then
            action = GetActionIdFromName(action)
        else
            action = tonumber(action)
        end
        if (not action) or (action < 0) then return end
        WindowSetGameActionTrigger(self.name, action)
    end
    
end -- BUTTON



-- CLOSE BUTTON
do
    function LIBGUI_Closebutton:New(windowName, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
        
        if CreateWindowFromTemplate(w.name, "EA_Button_DefaultWindowClose", w.parent) then
            -- window successfully created, initialize it and return our new object
            w.width = 37
            w.height = 37
            w:RegisterDefaultEvents()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
end -- CLOSE BUTTON



-- TEXTBOX
do
    function LIBGUI_Textbox:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_EditBox_DefaultFrame"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			if base == "EA_EditBox_DefaultFrame" then
				w.width = 200
				w.height = 32
			else
				local x,y = WindowGetDimensions(w.name)
				w.width = x
				w.height = y > 0 and y or 32
			end
            w:Resize(w.width)
            w:RegisterDefaultEvents()
            w:RegisterEvent("OnKeyEnter")
            w:RegisterEvent("OnKeyTab")
            w:RegisterEvent("OnKeyEscape")
            w:RegisterEvent("OnTextChanged") -- not working in 1.0.2
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Textbox:Resize(width)
        if (not self.name) or (self.name=="") then return end
        self.width = width or self.width or 200
        WindowSetDimensions(self.name, width, self.height)
    end
    
    function LIBGUI_Textbox:SetText(text)
        if (not self.name) or (self.name=="") then return end
        
        local text = text
        if type(text) == "boolean" then text = text and L"true" or L"false" end
        TextEditBoxSetText(self.name, towstring(text))
    end
    
    function LIBGUI_Textbox:GetText()
        if (not self.name) or (self.name=="") then return end
        return TextEditBoxGetText(self.name)
    end
    
    function LIBGUI_Textbox:Clear()
        if (not self.name) or (self.name=="") then return end
        return TextEditBoxSetText(self.name, L"")
    end
    
end --TEXTBOX



-- MULTITEXTBOX
do
    function LIBGUI_MultiTextbox:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_EditBox_DefaultFrame_Multiline"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            w:Resize(w.width, w.height)
            w:RegisterDefaultEvents()
            w:RegisterEvent("OnKeyEnter")
            w:RegisterEvent("OnKeyTab")
            w:RegisterEvent("OnKeyEscape")
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_MultiTextbox:Resize(width, height)
        if (not self.name) or (self.name=="") then return end
        self.width = width or self.width or 200
        self.height = height or self.height or 96
        WindowSetDimensions(self.name, self.width, self.height)
    end
    
    function LIBGUI_MultiTextbox:SetText(text)
        if (not self.name) or (self.name=="") then return end
        
        local text = text
        if type(text) == "boolean" then text = text and L"true" or L"false" end
        TextEditBoxSetText(self.name, towstring(text))
    end
    
    function LIBGUI_MultiTextbox:GetText()
        if (not self.name) or (self.name=="") then return end
        return TextEditBoxGetText(self.name)
    end
    
    function LIBGUI_MultiTextbox:Clear()
        if (not self.name) or (self.name=="") then return end
        return TextEditBoxSetText(self.name, L"")
    end
    
end --TEXTBOX



-- CHECKBOX
do
    function LIBGUI_Checkbox:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_Button_DefaultCheckBox"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            ButtonSetCheckButtonFlag(w.name, true)
            w:RegisterDefaultEvents()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Checkbox:GetValue()
        if (not self.name) or (self.name=="") then return end
        return ButtonGetPressedFlag(self.name)
    end
    
    function LIBGUI_Checkbox:SetValue(checkState)
        if (not self.name) or (self.name=="") then return end
        ButtonSetPressedFlag(self.name, checkState)
    end
    
    function LIBGUI_Checkbox:Check()
        self:SetValue(true)
    end
    
    function LIBGUI_Checkbox:Clear()
        self:SetValue(false)
    end
    
    function LIBGUI_Checkbox:Toggle()
        self:SetValue(not self:GetValue())
    end
    
    function LIBGUI_Checkbox:SetEnabled(flag)
        if (not self.name) or (self.name=="") then return end
        ButtonSetDisabledFlag(self.name, not flag)
    end
    
    function LIBGUI_Checkbox:Enabled()
        if (not self.name) or (self.name=="") then return end
        return (not ButtonGetDisabledFlag(self.name))
    end
    
    function LIBGUI_Checkbox:Enable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(true)
    end
    
    function LIBGUI_Checkbox:Disable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(false)
    end

end -- CHECKBOX



-- OPTION BUTTON
do
    function LIBGUI_Optionbutton:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_Button_DefaultToggleCircle"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            ButtonSetCheckButtonFlag(w.name, true)
            w:RegisterDefaultEvents()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Optionbutton:GetValue()
        if (not self.name) or (self.name=="") then return end
        return ButtonGetPressedFlag(self.name)
    end
    
    function LIBGUI_Optionbutton:SetValue(checkState)
        if (not self.name) or (self.name=="") then return end
        ButtonSetPressedFlag(self.name, checkState)
    end
    
    function LIBGUI_Optionbutton:Check()
        self:SetValue(true)
    end
    
    function LIBGUI_Optionbutton:Clear()
        self:SetValue(false)
    end
    
    function LIBGUI_Optionbutton:SetEnabled(flag)
        if (not self.name) or (self.name=="") then return end
        ButtonSetDisabledFlag(self.name, not flag)
    end
    
    function LIBGUI_Optionbutton:Enabled()
        if (not self.name) or (self.name=="") then return end
        return (not ButtonGetDisabledFlag(self.name))
    end
    
    function LIBGUI_Optionbutton:Enable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(true)
    end
    
    function LIBGUI_Optionbutton:Disable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(false)
    end

end -- OPTION BUTTON


-- SLIDER
do
    function LIBGUI_Slider:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_Default_SliderBar"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            w.max = 1
            w.min = 0
            w:RegisterDefaultEvents()
            w:RegisterEvent("OnSlide") -- not working as of client version 1.0.2
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Slider:MakeMovable()
        -- Override the default element MakeMovable - it doesn't work for sliders and will just break the slide behavior.
        d("Attempt to make slider movable ignored - this doesn't work.")
        return
    end
    
    function LIBGUI_Slider:GetValue()
        if (not self.name) or (self.name=="") then return end
        local value = SliderBarGetCurrentPosition(self.name)
        value = self.min + ((self.max - self.min) * value)
        return value
    end
    
    function LIBGUI_Slider:SetValue(value)
        if (not self.name) or (self.name=="") then return end
        if self.max - self.min == 0 then return end -- make sure we don't divide by zero
        local value = (value - self.min) / (self.max - self.min)
        if value > 1 then value = 1 end -- cap the value at the range endpoints
        if value < 0 then value = 0 end
        SliderBarSetCurrentPosition(self.name, value)
    end
    
    function LIBGUI_Slider:SetRange(minVal, maxVal)
        local minVal, maxVal = minVal, maxVal
        if (not self.name) or (self.name=="") then return end
        local oldValue = self:GetValue()
        if not maxVal then minVal, maxVal = 0, minVal end -- if we only specify one number, make it the max and make the min 0
        self.min = minVal
        self.max = maxVal
        --restore old value in new scaling (might get capped)
        self:SetValue(oldValue)
    end
    
    function LIBGUI_Slider:GetRange()
        if (not self.name) or (self.name=="") then return end
        return self.min, self.max
    end
    
    function LIBGUI_Slider:SetEnabled(flag)
        if (not self.name) or (self.name=="") then return end
        SliderBarSetDisabledFlag(self.name, not flag)
    end
    
    function LIBGUI_Slider:Enable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(true)
    end
    
    function LIBGUI_Slider:Disable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(false)
    end
    
    function LIBGUI_Slider:Enabled()
        if (not self.name) or (self.name=="") then return end
        return (not SliderBarGetDisabledFlag(self.name))
    end

end -- SLIDER



-- STATUSBAR
do
    function LIBGUI_Statusbar:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_StatusBar_DefaultTintable"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            w:Resize(w.width)
            w.max = 1
            w.min = 0
            StatusBarSetMaximumValue(w.name, 1)
            w:ForeColor(255, 255, 255)
            w:BackColor(100, 100, 100)
            w:RegisterDefaultEvents()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Statusbar:Resize(width)
        if (not self.name) or (self.name=="") then return end
        self.width = width or self.width or 200
        WindowSetDimensions(self.name, width, self.height)
    end
    
    function LIBGUI_Statusbar:GetValue()
        if (not self.name) or (self.name=="") then return end
        local value = StatusBarGetCurrentValue(self.name)
        value = self.min + ((self.max - self.min) * value)
        return value
    end
    
    function LIBGUI_Statusbar:SetValue(value)
        if (not self.name) or (self.name=="") then return end
        if self.max - self.min == 0 then return end -- make sure we don't divide by zero
        local value = (value - self.min) / (self.max - self.min)
        if value > 1 then value = 1 end -- cap the value at the range endpoints
        if value < 0 then value = 0 end
        StatusBarSetCurrentValue(self.name, value)
        return self:GetValue()
    end
    
    function LIBGUI_Statusbar:SetRange(minVal, maxVal)
        local minVal, maxVal = minVal, maxVal
        if (not self.name) or (self.name=="") then return end
        local oldValue = self:GetValue()
        if not maxVal then minVal, maxVal = 0, minVal end -- if we only specify one number, make it the max and make the min 0
        self.min = minVal
        self.max = maxVal
        --restore old value in new scaling (might get capped)
        self:SetValue(oldValue)
    end
    
    function LIBGUI_Statusbar:GetRange()
        if (not self.name) or (self.name=="") then return end
        return self.min, self.max
    end
    
    function LIBGUI_Statusbar:ForeColor(red, green, blue)
        if (not self.name) or (self.name=="") then return end
        if not (red and green and blue) then return end
        local red = min(255, max(0, red))
        local green = min(255, max(0, green))
        local blue = min(255, max(0, blue))
        StatusBarSetForegroundTint(self.name, red, green, blue)
    end
    
    function LIBGUI_Statusbar:BackColor(red, green, blue)
        if (not self.name) or (self.name=="") then return end
        if not (red and green and blue) then return end
        local red = min(255, max(0, red))
        local green = min(255, max(0, green))
        local blue = min(255, max(0, blue))
        StatusBarSetBackgroundTint(self.name, red, green, blue)
    end

end -- STATUSBAR



-- COMBOBOX
do
    function LIBGUI_Combobox:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        local base = base or "EA_ComboBox_DefaultResizable"
        
        w.name = windowName
        w.parent = parent or "Root"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
            local width, height = WindowGetDimensions(w.name)
            w.width = width
            w.height = height
            w:Clear()
            w:RegisterDefaultEvents()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Combobox:Add(itemText)
        if (not self.name) or (self.name=="") then return end
        local itemText = itemText
        if type(itemText) == "boolean" then itemText = itemText and L"true" or L"false" end
        if type(itemText) == "nil" then itemText = L"nil" end
        itemText = towstring(itemText)
        table.insert(self.items, itemText)
        ComboBoxAddMenuItem(self.name, itemText)
    end
    
    function LIBGUI_Combobox:Clear()
        if (not self.name) or (self.name=="") then return end
        ComboBoxClearMenuItems(self.name)
        self.items = {}
    end
    
    function LIBGUI_Combobox:SetEnabled(flag)
        if (not self.name) or (self.name=="") then return end
        ComboBoxSetDisabledFlag(self.name, not flag)
    end
    
    function LIBGUI_Combobox:Enable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(true)
    end
    
    function LIBGUI_Combobox:Disable()
        if (not self.name) or (self.name=="") then return end
        self:SetEnabled(false)
    end
    
    function LIBGUI_Combobox:Enabled()
        if (not self.name) or (self.name=="") then return end
        return (not ComboBoxGetDisabledFlag(self.name))
    end
    
    function LIBGUI_Combobox:Selected()
        if (not self.name) or (self.name=="") then return end
        if #self.items == 0 then return nil end
        return self.items[self:SelectedIndex()]
    end
    
    function LIBGUI_Combobox:SelectedIndex()
        if (not self.name) or (self.name=="") then return end
        if #self.items == 0 then return nil end
        return ComboBoxGetSelectedMenuItem(self.name)
    end
    
    function LIBGUI_Combobox:SelectIndex(index)
        if (not self.name) or (self.name=="") then return end
        local index = tonumber(index)
        if not index then return end
        if index <= 0 or index > #self.items then return end
        ComboBoxSetSelectedMenuItem(self.name, index)
    end
    
    function LIBGUI_Combobox:Select(value)
        if (not self.name) or (self.name=="") then return end
        local value = value
        if type(value) ~= "number" then
            if type(value) == "boolean" then value = value and L"true" or L"false" end
            if type(value) == "nil" then value = L"nil" end
            value = towstring(value)
            for k,v in ipairs(self.items) do
                if v == value then
                    value = k
                    break
                end
            end
        end
        -- if we're still not a number, we didn't find anything
        if type(value) ~= "number" then return end
        self:SelectIndex(value)
    end
    
end -- COMBOBOX



-- SCROLLBAR
do
    function LIBGUI_Scrollbar:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_ScrollBar_DefaultVerticalChain"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            w.max = 10
            w.min = 1
            w:Resize(w.height)
            w:SetRange(w.min, w.max)
            w:RegisterDefaultEvents()
            w:RegisterEvent("OnScrollPosChanged") -- not working in 1.0.2
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Scrollbar:Resize(height)
        if (not self.name) or (self.name=="") then return end
        self.height = height or self.height or 100
        WindowSetDimensions(self.name, self.width, self.height)
    end
    
    function LIBGUI_Scrollbar:GetValue()
        if (not self.name) or (self.name=="") then return end
        local value = VerticalScrollbarGetScrollPosition(self.name)
        value = self.min + ((self.max - self.min) * value)
        return value
    end
    
    function LIBGUI_Scrollbar:SetValue(value)
        if (not self.name) or (self.name=="") then return end
        local value = min(self.max, value)
        value = max(self.min, value)
        VerticalScrollbarSetScrollPosition(self.name, value - self.min + 1)
    end
    
    function LIBGUI_Scrollbar:SetRange(minVal, maxVal)
        local minVal, maxVal = minVal, maxVal
        if (not self.name) or (self.name=="") then return end
        local oldValue = self:GetValue()
        if not maxVal then minVal, maxVal = 0, minVal end -- if we only specify one number, make it the max and make the min 0
        self.min = minVal
        self.max = maxVal
        VerticalScrollbarSetMaxScrollPosition(self.name, self.max - self.min + 1)
        --restore old value in new scaling (might get capped)
        self:SetValue(oldValue)
    end
    
    function LIBGUI_Scrollbar:GetRange()
        if (not self.name) or (self.name=="") then return end
        return self.min, self.max
    end
    
    -- CLIENT BUG - as of client version 1.0.2, VerticalScrollbarSetPageSize and VerticalScrollbarSetLineSize are mixed up!
    -- The former sets the line size, and the latter sets the page size. So no, the functions below are not typos.
    
    function LIBGUI_Scrollbar:MajorSize(newVal)
        if (not self.name) or (self.name=="") then return end
        if not newVal then return VerticalScrollbarGetPageSize(self.name) end
        local pageSize = min(newVal, VerticalScrollbarGetMaxScrollPosition(self.name))
        VerticalScrollbarSetLineSize(self.name, pageSize) --Change when fixed in client
        return pageSize
    end
    
    function LIBGUI_Scrollbar:MinorSize(newVal)
        if (not self.name) or (self.name=="") then return end
        if not newVal then return VerticalScrollbarGetPageSize(self.name) end
        local lineSize = min(newVal, VerticalScrollbarGetMaxScrollPosition(self.name))
        VerticalScrollbarSetPageSize(self.name, lineSize) --Change when fixed in client
        return lineSize
    end

end -- SCROLLBAR



-- IMAGE
do

    function LIBGUI_Image:New(windowName, base, parent)
        local w = setmetatable({}, self)
        
        w.name = windowName
        w.parent = parent or "Root"
		local base = base or "EA_DynamicImage_DefaultSeparatorRight"
        
        if CreateWindowFromTemplate(w.name, base, w.parent) then
            -- window successfully created, initialize it and return our new object
			local x,y = WindowGetDimensions(w.name)
            w.width = x
            w.height = y
            w.texInfo = {}
            w:Resize(w.width, w.height)
            w:Texture("tint_square", 0, 0)
            w:RegisterDefaultEvents()
			w:CaptureInput()
            return w
        else
            -- window creation failed, oh noes
            return nil
        end
    end
    
    function LIBGUI_Image:Resize(width, height)
        if (not self.name) or (self.name=="") then return end
        width = width or self.width or 64
        height = height or self.width or 64
        self.width = width
        self.height = height
        WindowSetDimensions(self.name, width, height)
    end
    
    function LIBGUI_Image:Texture(texture, x, y)
        if (not self.name) or (self.name=="") then return end
        x = x or 0
        y = y or 0
        texture = texture or ""
        -- Only actually change the texture if we really need to
        if (self.texInfo.texture ~= texture) or (self.texInfo.x ~= x) or (self.texInfo.y ~= y) then
            DynamicImageSetTexture(self.name, texture, x, y)
            self.texInfo.texture = texture
            self.texInfo.x = x
            self.texInfo.y = y
        end
    end
    
    function LIBGUI_Image:TexSlice(slice)
        if (not self.name) or (self.name=="") then return end
        if (type(slice) ~= "string") or (slice == "") then return end
        -- Only actually change the slice if we really need to
        if self.texInfo.slice ~= slice then
            DynamicImageSetTextureSlice(self.name, slice)
            self.texInfo.slice = slice
        end
    end
    
    function LIBGUI_Image:Rotate(angle)
        if (not self.name) or (self.name=="") then return end
        angle = tonumber(angle) or 0
        -- Only actually change the rotation if we really need to
        if self.texInfo.angle ~= angle then
            DynamicImageSetRotation(self.name, angle)
            self.texInfo.angle = angle
        end
    end
    
    function LIBGUI_Image:TexDims(width, height)
        if (not self.name) or (self.name=="") then return end
        width = width or 64
        height = height or 64
        -- Only actually change the rotation if we really need to
        if (self.texInfo.width ~= width) or (self.texInfo.height ~= height) then
            DynamicImageSetTextureDimensions(self.name, width, height)
            self.texInfo.width = width
            self.texInfo.height = height
        end
    end
    
    function LIBGUI_Image:TexFlip(flipped)
        if (not self.name) or (self.name=="") then return end
        flipped = flipped or false
        -- Only actually change the orientation if we really need to
        if self.texInfo.flipped ~= flipped then
            DynamicImageSetTextureOrientation(self.name, flipped)
            self.texInfo.flipped = flipped
        end
    end
    
    function LIBGUI_Image:TexScale(scale)
        if (not self.name) or (self.name=="") then return end
        scale = scale or 1
        -- Only actually change the scale if we really need to
        if self.texInfo.scale ~= scale then
            DynamicImageSetTextureScale(self.name, scale)
            self.texInfo.scale = scale
        end
    end

end -- IMAGE

--------------------------------------- LIBGUI API ------------------------------------------------

function LibGUI:New(elementType, elementName, elementBase)
    local elementType = elementType or "Window"
    local elementName = (elementName ~= "") and elementName or getNewElementName(elementType)
    
    elementType = elementType:lower()
    
    local newElement
    if elementType == "window" then
        newElement = LIBGUI_Window:New(elementName, elementBase)
    elseif elementType == "frame" then
        newElement = LIBGUI_Window:New(elementName, "DefaultWindowBackground")
    elseif elementType == "blackframe" then
        newElement = LIBGUI_Window:New(elementName, "EA_Window_DefaultFrame")
    elseif elementType == "button" then
        newElement = LIBGUI_Button:New(elementName, elementBase)
    elseif elementType == "textbox" then
        newElement = LIBGUI_Textbox:New(elementName, elementBase)
    elseif elementType == "multitextbox" then
        newElement = LIBGUI_MultiTextbox:New(elementName, elementBase)
    elseif elementType == "checkbox" then
        newElement = LIBGUI_Checkbox:New(elementName, elementBase)
    elseif elementType == "slider" then
        newElement = LIBGUI_Slider:New(elementName, elementBase)
    elseif elementType == "combobox" then
        newElement = LIBGUI_Combobox:New(elementName, elementBase)
    elseif elementType == "smallcombobox" then
        newElement = LIBGUI_Combobox:New(elementName, "EA_ComboBox_DefaultResizableSmall")
    elseif elementType == "tinycombobox" then
        newElement = LIBGUI_Combobox:New(elementName, "EA_ComboBox_DefaultResizableTiny")
    elseif elementType == "scrollbar" then
        newElement = LIBGUI_Scrollbar:New(elementName, elementBase)
    elseif elementType == "label" then
        newElement = LIBGUI_Label:New(elementName, elementBase)
    elseif elementType == "statusbar" then
        newElement = LIBGUI_Statusbar:New(elementName, elementBase)
    elseif elementType == "optionbutton" then
        newElement = LIBGUI_Optionbutton:New(elementName, elementBase)
    elseif elementType == "closebutton" then
        newElement = LIBGUI_Closebutton:New(elementName, elementBase)
    elseif elementType == "image" then
        newElement = LIBGUI_Image:New(elementName)
    else
        error("Attempt to create LibGUI element of unknown type '"..elementType.."'.")
    end
    
    LibGUI.elementCount = LibGUI.elementCount + 1
    LibGUI.elements[elementName] = newElement
    return newElement
end

--------------- Final bits and pieces for metatable fun -------------------------
LIBGUI_Window.__call = LIBGUI_Window.Add
setmetatable(LibGUI, { __call = LibGUI.New })
