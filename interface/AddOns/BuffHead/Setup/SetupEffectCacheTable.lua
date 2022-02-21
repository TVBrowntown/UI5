BuffHead = BuffHead or {}; 
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.EffectCacheTable = 
{
	WindowName = "BuffHeadSetupEffectCacheTableWindow",
};

local windowName = BuffHead.Setup.EffectCacheTable.WindowName;
local localization = BuffHead.Localization.GetMapping();

function BuffHead.Setup.EffectCacheTable.Initialize()
	
end

function BuffHead.Setup.EffectCacheTable.Show()

	if (WindowGetShowing(windowName)) then return end

	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, "topright", BuffHead.Setup.EffectCache.WindowName, "topleft", 0, 0);

	WindowSetShowing(windowName, true);
	
	WindowUtils.AddToOpenList(windowName, BuffHead.Setup.EffectCacheTable.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	
	Sound.Play(Sound.WINDOW_OPEN);

end

function BuffHead.Setup.EffectCacheTable.Hide()

	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	
	Sound.Play(Sound.WINDOW_CLOSE);
	
	WindowUtils.RemoveFromOpenList(windowName);

end

function BuffHead.Setup.EffectCacheTable.OnHidden()

end

function BuffHead.Setup.EffectCacheTable.OnCloseLUp()

	BuffHead.Setup.EffectCacheTable.Hide();

end

-- insert this below for strings, to see hidden characters
local function ReplaceTags(text)

	text = string.gsub(tostring(text),"%<","< ");
	text = string.gsub(tostring(text),"%{","{ ");
	text = string.gsub(tostring(text),"%[","[ ");
	text = string.gsub(tostring(text),"\r","\\r");
	text = string.gsub(tostring(text),"\n","\\n");
	
	return text;

end

function BuffHead.Setup.EffectCacheTable.ShowTable(effectData)

	local seenText = nil;

	if (effectData.Count == 1) then
		seenText = string.format(tostring(localization["Setup.EffectCacheTable.Seen1"]), effectData.Count);
	else
		seenText = string.format(tostring(localization["Setup.EffectCacheTable.Seen"]), effectData.Count);
	end
	
	LabelSetText(windowName .. "SeenLabel", towstring(seenText));
	LabelSetText(windowName .. "NameLabel", towstring(effectData.Data.name));
	
	local tableData = L"";
	local variableNames = {};
	
	for variableName, _ in pairs(effectData.Data) do
		table.insert(variableNames, variableName);
	end
	table.sort(variableNames);
	
	for _, variableName in ipairs(variableNames) do
		local variableValue = effectData.Data[variableName];
		
		if (tableData:len() > 0) then
			tableData = tableData .. L"\n";
		end
		
		tableData = tableData .. towstring(variableName) .. L" = ";
		local variableType = type(variableValue);
		
		if (variableType == "string") then
			tableData = tableData .. L"\"" .. towstring(variableValue) .. L"\"";
		elseif (variableType == "wstring") then
			tableData = tableData .. L"L\"" .. towstring(variableValue) .. L"\"";
		else
			tableData = tableData .. towstring(tostring(variableValue)); -- because certain values will convert to a string
		end
	end
	
	TextEditBoxSetText(windowName .. "TableEditBox", tableData);
	
	BuffHead.Setup.EffectCacheTable.Show();

end