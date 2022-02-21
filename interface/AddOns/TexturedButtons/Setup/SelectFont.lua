TexturedButtons.Setup.SelectFont = {};

local MAX_WIDTH = 1000;
local callbackFunction = nil;

local fonts = 
{
	{ Font = "font_journal_body", Name = "Cronos Pro - Small" },
	{ Font = "font_journal_text", Name = "Cronos Pro - Medium" },
	{ Font = "font_default_text_small", Name = "Age of Reckoning - Small" },
	{ Font = "font_default_text_large", Name = "Age of Reckoning - Large" },
	{ Font = "font_default_text_huge", Name = "Age of Reckoning - Huge" },
	{ Font = "font_heading_large", Name = "Age of Reckoning - Heading" },
	{ Font = "font_clear_tiny", Name = "Myriad Pro - Very Small" },
	{ Font = "font_clear_small", Name = "Myriad Pro - Small" },
	{ Font = "font_clear_medium", Name = "Myriad Pro - Medium" },
	{ Font = "font_clear_large", Name = "Myriad Pro - Large" },
	{ Font = "font_clear_small_bold", Name = "Myriad Pro SemiExt - Small" },
	{ Font = "font_clear_medium_bold", Name = "Myriad Pro SemiExt - Medium" },
	{ Font = "font_clear_large_bold", Name = "Myriad Pro SemiExt - Large" },
};

function TexturedButtons.Setup.SelectFont.Initialize()

	local greatestWidth = 0;

	for index, font in ipairs(fonts) do
        CreateWindowFromTemplate("TexturedButtonsContextMenuItemFontMenuItem" .. index, "TexturedButtonsContextMenuItemFontSelection", "Root");
        LabelSetFont("TexturedButtonsContextMenuItemFontMenuItem" .. index .. "Label", font.Font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING);
        LabelSetText("TexturedButtonsContextMenuItemFontMenuItem" .. index .. "Label", towstring(font.Name));
		
        WindowSetDimensions("TexturedButtonsContextMenuItemFontMenuItem" .. index .. "Label", MAX_WIDTH, 90);
        local x, y = LabelGetTextDimensions("TexturedButtonsContextMenuItemFontMenuItem" .. index .. "Label");
		if (x > greatestWidth) then
			greatestWidth = x;
		end
        WindowRegisterCoreEventHandler("TexturedButtonsContextMenuItemFontMenuItem" .. index, "OnLButtonUp", "TexturedButtons.Setup.SelectFont.SetFont");
        WindowSetShowing("TexturedButtonsContextMenuItemFontMenuItem" .. index, false);
        WindowSetId("TexturedButtonsContextMenuItemFontMenuItem" .. index, index);
	end
	
	greatestWidth = math.min(MAX_WIDTH, greatestWidth);
	
	for index, font in ipairs(fonts) do
        local _, y = LabelGetTextDimensions("TexturedButtonsContextMenuItemFontMenuItem" .. index .. "Label");
        WindowSetDimensions("TexturedButtonsContextMenuItemFontMenuItem" .. index, greatestWidth, y);
        WindowSetDimensions("TexturedButtonsContextMenuItemFontMenuItem" .. index .. "Label", greatestWidth, y);
	end
	
end

function TexturedButtons.Setup.SelectFont.GetFontName(f)

	for index, font in pairs(fonts) do
		if (font.Font == f) then
			return font.Name;
		end
	end
	
	return f;

end

function TexturedButtons.Setup.SelectFont.SetFont()
	local menu = 1;
	local index = WindowGetId(SystemData.ActiveWindow.name);
	if (index) then
		local font = fonts[index];
		if (font) then
			if (type(callbackFunction) == "function") then
				callbackFunction(font);
			end
		end
	end
	EA_Window_ContextMenu.Hide(menu)
end

function TexturedButtons.Setup.SelectFont.Show(callback)
	callbackFunction = callback;
	local menu = 1;
	EA_Window_ContextMenu.CreateContextMenu(SystemData.ActiveWindow.name, menu);
	for index, font in ipairs(fonts) do
       EA_Window_ContextMenu.AddUserDefinedMenuItem("TexturedButtonsContextMenuItemFontMenuItem" .. index, menu);
	end
	EA_Window_ContextMenu.Finalize(menu);
end