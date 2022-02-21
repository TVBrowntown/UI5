function UI5.CreateBox(boxType, frontColor1, frontColor2, frontColor3, box1, box2, hasLabel, labelAmounts, labAmounts, attachToObj)

--[[
	requires the Name of the box, it's colors, then its dimensions
]]

	local solidTexture = {
												"solid", 
												64, 
												64
	}

	local boxName 	= {
												"Bar",
												"Fill_BG",
												"Fill"
	}

	local boxDimsX	= {
												box1,
												(box1 - 4),
												(box1 - 4)
	}
	local boxDimsY	= {
												box2,
												(box2 - 4),
												(box2 - 4)
	}
	local boxColor1	=	{
												BGColour[1],
												GreyColour[1],
												frontColor1
	}
	local boxColor2	=	{
												BGColour[2],
												GreyColour[2],
												frontColor2
	}
	local boxColor3	=	{
												BGColour[3],
												GreyColour[3],
												frontColor3
}	


for k, v in pairs(boxName) do
	CreateWindowFromTemplate("UI6_"..boxType..boxName[k], "EA_DynamicImage_DefaultSeparatorRight", "Root")
	DynamicImageSetTexture("UI6_"..boxType..boxName[k], solidTexture[1], solidTexture[2], solidTexture[3])
	WindowSetDimensions("UI6_"..boxType..boxName[k], boxDimsX[k], boxDimsY[k]) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetTintColor("UI6_"..boxType..boxName[k], boxColor1[k], boxColor3[k], boxColor3[k])
	WindowSetLayer("UI6_"..boxType..boxName[k], Window.Layers.BACKGROUND)
	if boxName[k] == "Bar" then
		WindowAddAnchor ("UI6_"..boxType..boxName[k], "center", "Root", "center", 0, 0)
		WindowAddAnchor ("UI6_"..boxType..boxName[k], "center", "UI6_"..boxType.."Bar", "center", 0, 0)
		--Box naming needs fixing. stupid wstrings/strings.
	elseif boxName[k] == "Fill_BG" then
		WindowAddAnchor ("UI6_"..boxType..boxName[k], "center", "UI6_"..boxType.."Bar", "center", 0, 0)
		WindowSetParent("UI6_"..boxType..boxName[k], "UI6_"..boxType.."Bar")
	else
		WindowAddAnchor ("UI6_"..boxType..boxName[k], "topleft", "UI6_"..boxType.."Fill_BG", "topleft", 0, 0)
		WindowSetParent("UI6_"..boxType..boxName[k], "UI6_"..boxType.."Bar")
	end
end

	if hasLabel == true then
		d("this has a label, let's make a label text for it")
		-- how many labels?? labAmounts = how many!
		for i = 1, labAmounts do
	    --code to execute
			CreateWindowFromTemplate("UI6_"..boxType.."Text"..tostring(i), "UI6_BoxText", "UI6_"..boxType.."Bar")
			LabelSetFont("UI6_"..boxType.."Text"..tostring(i), "font_journal_small_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
			LabelSetText("UI6_"..boxType.."Text"..tostring(i), L"LOPSUM IPSUM")
			WindowSetParent("UI6_"..boxType.."Text"..tostring(i), "UI6_"..boxType.."Bar")
	    --	
	    d("loop #"..i)
		end

	end

	UI5.ApplyToBox(boxType)
end

function UI5.ApplyToBox(boxType)

	--"UI6_"..boxType.."Bar" <-- apply to this box
	d(boxType)
	d("Building box completed.")
	d("Now to give it a function when clicked, L mouse and R mouse click, etc.")

end