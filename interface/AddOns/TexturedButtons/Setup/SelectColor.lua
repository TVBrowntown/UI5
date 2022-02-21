TexturedButtons.Setup.SelectColor = 
{
	WindowName = "TexturedButtonsSetupSelectColorWindow",
};

local windowName = TexturedButtons.Setup.SelectColor.WindowName;
local callbackFunction = nil;
local colorLock = false;
local lockSettings = false;
local callbackLock = false;
local activeWindow = nil;

local localization = TexturedButtons.Localization.GetMapping();

function TexturedButtons.Setup.SelectColor.Initialize()

	WindowSetShowing(windowName, false);
	WindowSetTintColor(windowName .. "Background", 0, 0, 0);
	WindowSetAlpha(windowName .. "Background", 0.8);
	
	LabelSetText(windowName .. "TintRed", localization["Strings.Color.Red"]);
	LabelSetText(windowName .. "TintGreen", localization["Strings.Color.Green"]);
	LabelSetText(windowName .. "TintBlue", localization["Strings.Color.Blue"]);
	
end

function TexturedButtons.Setup.SelectColor.Show(window, anchorWindow, callback, color, pointOnAnchor, pointOnSelf)
	if (WindowGetShowing(windowName) and anchorWindow == activeWindow) then
		WindowSetShowing(windowName, false);
		return;
	end	
	activeWindow = anchorWindow;
	
	color = color or {};
	pointOnAnchor = pointOnAnchor or "topright";
	pointOnSelf = pointOnSelf or "topleft";
	
	callbackFunction = nil; -- will cause the OnTintChanged to no update the callback
	lockSettings = true;
	TextEditBoxSetText(windowName .. "TintRedEditBox", towstring(color.R or 255));
	TextEditBoxSetText(windowName .. "TintGreenEditBox", towstring(color.G or 255));
	TextEditBoxSetText(windowName .. "TintBlueEditBox", towstring(color.B or 255));
	lockSettings = false;
	TexturedButtons.Setup.SelectColor.OnTintChanged();
	
	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, pointOnAnchor, anchorWindow, pointOnSelf, 0, 0);
	
	callbackFunction = callback;
	WindowSetLayer(windowName, WindowGetLayer(window) + 1);
	WindowSetShowing(windowName, true);	
end

function TexturedButtons.Setup.SelectColor.Hide()
	if (WindowGetShowing(windowName)) then
		WindowSetShowing(windowName, false);
	end
end

function TexturedButtons.Setup.SelectColor.OnSlideTint()

	if (lockSettings) then return end

	local r = math.floor(SliderBarGetCurrentPosition(windowName .. "TintRedSlider") * 255);
	local g = math.floor(SliderBarGetCurrentPosition(windowName .. "TintGreenSlider") * 255);
	local b = math.floor(SliderBarGetCurrentPosition(windowName .. "TintBlueSlider") * 255);
	
	colorLock = true;
	TextEditBoxSetText(windowName .. "TintRedEditBox", towstring(r));
	TextEditBoxSetText(windowName .. "TintGreenEditBox", towstring(g));
	TextEditBoxSetText(windowName .. "TintBlueEditBox", towstring(b));
	colorLock = false;
	
	TexturedButtons.Setup.SelectColor.OnTintChanged(true);

end

function TexturedButtons.Setup.SelectColor.OnTintChanged(value)

	if (colorLock or lockSettings) then return end

	local r = tonumber(TextEditBoxGetText(windowName .. "TintRedEditBox"));
	local g = tonumber(TextEditBoxGetText(windowName .. "TintGreenEditBox"));
	local b = tonumber(TextEditBoxGetText(windowName .. "TintBlueEditBox"));
	
	if (value ~= true) then
		SliderBarSetCurrentPosition(windowName .. "TintRedSlider", r / 255);
		SliderBarSetCurrentPosition(windowName .. "TintGreenSlider", g / 255);
		SliderBarSetCurrentPosition(windowName .. "TintBlueSlider", b / 255);
	end
	
	if (type(callbackFunction) == "function") then
		callbackFunction({ R = r, G = g, B = b });
	end

end