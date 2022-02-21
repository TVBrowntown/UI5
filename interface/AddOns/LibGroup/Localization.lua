LibGroup = LibGroup or {};
if (not LibGroup.Localization) then
	LibGroup.Localization = {};
	LibGroup.Localization.Language = {};
end

local localizationWarning = false;

function LibGroup.Localization.GetMapping()

	local lang = LibGroup.Localization.Language[SystemData.Settings.Language.active];
	
	if (not lang) then
		if (not localizationWarning) then
			d("Your current language is not supported. English will be used instead.");
			localizationWarning = true;
		end
		lang = LibGroup.Localization.Language[SystemData.Settings.Language.ENGLISH];
	end
	
	return lang;
	
end