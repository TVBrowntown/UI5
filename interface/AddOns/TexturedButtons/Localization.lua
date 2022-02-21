TexturedButtons = TexturedButtons or {};
if (not TexturedButtons.Localization) then
	TexturedButtons.Localization = {};
	TexturedButtons.Localization.Language = {};
end

local localizationWarning = false;

function TexturedButtons.Localization.GetMapping()

	local lang = TexturedButtons.Localization.Language[SystemData.Settings.Language.active];
	
	if (not lang) then
		if (not localizationWarning) then
			d("Your current language is not supported. English will be used instead.");
			localizationWarning = true;
		end
		lang = TexturedButtons.Localization.Language[SystemData.Settings.Language.ENGLISH];
	end
	
	return lang;
	
end