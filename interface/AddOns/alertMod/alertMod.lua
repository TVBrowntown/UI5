alertMod = {}

local function print(text)
	EA_ChatWindow.Print(towstring(text))
end

local hasChanged = false

local alertFont = {}
	alertFont[1] = "font_alert_outline_half_tiny"
	alertFont[2] = "font_alert_outline_half_small"
	alertFont[3] = "font_alert_outline_half_medium"
	alertFont[4] = "font_alert_outline_half_large"
	alertFont[5] = "font_alert_outline_half_huge"
	alertFont[6] = "font_alert_outline_half_giant"
	alertFont[7] = "font_alert_outline_half_gigantic"
	alertFont[8] = "font_alert_outline_large"
	alertFont[9] = "font_alert_outline_huge"
	alertFont[10] = "font_alert_outline_giant"
	alertFont[11] = "font_alert_outline_gigantic"

local fontOffset = {}
	fontOffset["DEFAULT"] =  3
	fontOffset["COMBAT"] =  3
	fontOffset["QUEST_NAME"] = 0
	fontOffset["QUEST_CONDITION"] = 3
	fontOffset["QUEST_END"] = 4
	fontOffset["OBJECTIVE"] =  3
	fontOffset["RVR"] = 5
	fontOffset["SCENARIO"] = 3
	fontOffset["MOVEMENT_RVR"] = 5
	fontOffset["ENTERAREA"] = 3
	fontOffset["STATUS_ERRORS"] = 3
	fontOffset["STATUS_ACHIEVEMENTS_GOLD"] = 2
	fontOffset["STATUS_ACHIEVEMENTS_PURPLE"] = 2
	fontOffset["STATUS_ACHIEVEMENTS_RANK"] = 6
	fontOffset["STATUS_ACHIEVEMENTS_RENOUN"] = 6
	fontOffset["PQ_ENTER"] = 1
	fontOffset["PQ_NAME"] = 4
	fontOffset["PQ_DESCRIPTION"] = 1
	fontOffset["ENTERZONE"] = 4
	fontOffset["ORDER"] = 2
	fontOffset["DESTRUCTION"] = 2
	fontOffset["NEUTRAL"] = 2
	fontOffset["ABILITY"] = 3
	fontOffset["BO_ENTER"] = 1
	fontOffset["BO_NAME"] = 4
	fontOffset["BO_DESCRIPTION"] = 1
	fontOffset["ENTER_CITY"] = 4
	fontOffset["CITY_RATING"] = 4
	fontOffset["GUILD_RANK"] = 6

-- OnInitialize Handler()
function alertMod.Initialize()
	WindowSetShowing( "alertMod", false )
	if (alertModSettings == nil) then
		alertMod.SetDefaults()
	else
		alertMod.LoadSettings()
	end
	alertMod.SetLabels()	
	alertMod.RegisterSlash()
end

function alertMod.LoadSettings()
	for k, v in pairs (alertModSettings) do
		if (k ~= "Fonts" and k ~= "FONT_SCALE") then
			AlertTextWindow[k] = alertModSettings[k]
		end
	end
	
	AlertTextWindow["ALERT_LIFE_TIME"] = alertModSettings["DISPLAY_TIME"] + alertModSettings["FADE_OUT_TIME"]
	--Load Fonts
	for k, v in pairs (alertModSettings.Fonts) do
		AlertTextWindow.TypeInfo[SystemData.AlertText.Types[k]].font = alertModSettings.Fonts[k]
	end
	
	hasChanged = false
end

function alertMod.SaveChanges()
	alertModSettings["MIN_HEIGHT_SHIFT"] = alertMod.Round( (SliderBarGetCurrentPosition( "alertModHeightShiftRowSlider" ) * 200) + 75, 0 )
	alertModSettings["FADE_IN_TIME"] = alertMod.Round( SliderBarGetCurrentPosition( "alertModFadeInRowSlider" ) * 4, 2 )
	alertModSettings["DISPLAY_TIME"] = alertMod.Round( SliderBarGetCurrentPosition( "alertModDisplayTimeRowSlider" ) * 4, 2 )
	alertModSettings["FADE_OUT_TIME"] = alertMod.Round( SliderBarGetCurrentPosition( "alertModFadeOutRowSlider" ) * 4, 2 )
	alertModSettings["TIME_BETWEEN_ALERTS"] = alertMod.Round( SliderBarGetCurrentPosition( "alertModTimeBetweenRowSlider" ) * 4, 2 )
	alertModSettings["MESSAGE_HEIGHT_PADDING"] = alertMod.Round( SliderBarGetCurrentPosition( "alertModPaddingRowSlider" ) * 10, 0 )
	
	local newFontScale = ComboBoxGetSelectedMenuItem( "alertModFontScaleRowCombo" )
	local oldFontScale = alertModSettings["FONT_SCALE"]
	--Check if Font Scale changed 
	if (newFontScale ~= oldFontScale) then
		alertMod.SetFonts(newFontScale)
		
		alertModSettings["FONT_SCALE"] = newFontScale
	end
	
	alertMod.LoadSettings()
end

function alertMod.SetFonts(scale)
	for k, v in pairs (fontOffset) do
		alertModSettings.Fonts[k] = alertFont[scale + v]
	end
end

function alertMod.SetDefaults()
	if (alertModSettings == nil) then
		alertModSettings = {}
		alertModSettings["Fonts"] = {}
	end
	
	alertModSettings["MIN_HEIGHT_SHIFT"] = 275
	alertModSettings["FADE_IN_TIME"] = 0.5
	alertModSettings["DISPLAY_TIME"] = 3.5
	alertModSettings["FADE_OUT_TIME"] = 1.5
	alertModSettings["TIME_BETWEEN_ALERTS"] = 1.5
	alertModSettings["MESSAGE_HEIGHT_PADDING"] = 10
	
	alertModSettings["FONT_SCALE"] = 2
	alertMod.SetFonts(2)
	
	alertMod.LoadSettings()
	alertMod.SetSliders()
end

function alertMod.SetSliders()
	ComboBoxSetSelectedMenuItem( "alertModFontScaleRowCombo", alertModSettings["FONT_SCALE"] )

	SliderBarSetCurrentPosition( "alertModHeightShiftRowSlider", (alertModSettings["MIN_HEIGHT_SHIFT"] - 75) / 200 )
	SliderBarSetCurrentPosition( "alertModFadeInRowSlider", alertModSettings["FADE_IN_TIME"] / 4 )
	SliderBarSetCurrentPosition( "alertModDisplayTimeRowSlider", alertModSettings["DISPLAY_TIME"] / 4 )
	SliderBarSetCurrentPosition( "alertModFadeOutRowSlider", alertModSettings["FADE_OUT_TIME"] / 4 )
	SliderBarSetCurrentPosition( "alertModTimeBetweenRowSlider", alertModSettings["TIME_BETWEEN_ALERTS"] / 4 )
	SliderBarSetCurrentPosition( "alertModPaddingRowSlider", alertModSettings["MESSAGE_HEIGHT_PADDING"] / 10 )
end

function alertMod.OnSliderChanged()
	alertMod.hasChanged = true
end

function alertMod.OnShown()
	alertMod.SetSliders()
end

function alertMod.OnSetDefaults()
	alertMod.SetDefaults()
end

function alertMod.OnCancelButton()
	alertMod.Hide()
end

function alertMod.OnOkayButton()
	if (alertMod.hasChanged) then
		alertMod.SaveChanges()
	end
	alertMod.Hide()
end

function alertMod.Hide()
	WindowSetShowing( "alertMod", false )
end

function alertMod.SetLabels()
	ComboBoxAddMenuItem( "alertModFontScaleRowCombo", L"Small" )
	ComboBoxAddMenuItem( "alertModFontScaleRowCombo", L"Medium" )
	ComboBoxAddMenuItem( "alertModFontScaleRowCombo", L"Large" )
	ComboBoxAddMenuItem( "alertModFontScaleRowCombo", L"Stupid" )
	
	LabelSetText( "alertModTitleBarText", L"alertMod" )
	ButtonSetText( "alertModOkayButton", L"OK" )
	ButtonSetText( "alertModDefaultsButton", L"Defaults" )
	ButtonSetText( "alertModCancelButton", L"Cancel" )
	
	LabelSetText( "alertModHeightShiftRowName", L"Height Shift" )
	LabelSetText( "alertModHeightShiftRowSliderMinLabel", L"75" )
	LabelSetText( "alertModHeightShiftRowSliderMaxLabel", L"275" )
	LabelSetText( "alertModHeightShiftRowSliderMidLabel", L"175" )
	DefaultColor.SetWindowTint( "alertModHeightShiftRowBackgroundName", DefaultColor.GetRowColor( 2 ) )
	
	LabelSetText( "alertModFadeInRowName", L"Fade In Time" )
	alertMod.SetSliderLabels("alertModFadeInRow")
	DefaultColor.SetWindowTint( "alertModFadeInRowBackgroundName", DefaultColor.GetRowColor( 1 ) )
	
	LabelSetText( "alertModDisplayTimeRowName", L"Display Time" )
	alertMod.SetSliderLabels("alertModDisplayTimeRow")
	DefaultColor.SetWindowTint( "alertModDisplayTimeRowBackgroundName", DefaultColor.GetRowColor( 2 ) )
	
	LabelSetText( "alertModFadeOutRowName", L"Fade Out Time" )
	alertMod.SetSliderLabels("alertModFadeOutRow")
	DefaultColor.SetWindowTint( "alertModFadeOutRowBackgroundName", DefaultColor.GetRowColor( 1 ) )
	
	LabelSetText( "alertModTimeBetweenRowName", L"Time Between Messages" )
	alertMod.SetSliderLabels("alertModTimeBetweenRow")
	DefaultColor.SetWindowTint( "alertModTimeBetweenRowBackgroundName", DefaultColor.GetRowColor( 2 ) )
	
	LabelSetText( "alertModPaddingRowName", L"Message Height Padding" )
	LabelSetText( "alertModPaddingRowSliderMinLabel", L"0" )
	LabelSetText( "alertModPaddingRowSliderMaxLabel", L"10" )
	LabelSetText( "alertModPaddingRowSliderMidLabel", L"5" )
	DefaultColor.SetWindowTint( "alertModPaddingRowBackgroundName", DefaultColor.GetRowColor( 1 ) )
	
	LabelSetText( "alertModFontScaleRowName", L"Font Scale" )
	DefaultColor.SetWindowTint( "alertModFontScaleRowBackgroundName", DefaultColor.GetRowColor( 2 ) )
end

function alertMod.SetSliderLabels(name)
	LabelSetText( name.."SliderMinLabel", L"0" )
	LabelSetText( name.."SliderMaxLabel", L"4" )
	LabelSetText( name.."SliderMidLabel", L"2" )
end

function alertMod.RegisterSlash()
	if( LibSlash.IsSlashCmdRegistered("tw") ) then
		print("alertMod: The slash command /am is in use please use /alertMod instead.")
	else
		LibSlash.RegisterSlashCmd("am", function()alertMod.SlashCommand() end)
	end
	LibSlash.RegisterSlashCmd("alertmod", function()alertMod.SlashCommand() end)
end

function alertMod.SlashCommand()
	WindowSetShowing( "alertMod", true )
end

function alertMod.Round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
