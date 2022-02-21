BuffHead = BuffHead or {};
if (not BuffHead.Localization) then
	BuffHead.Localization = {};
	BuffHead.Localization.Language = {};
end

local localizationWarning = false;

function BuffHead.Localization.GetMapping()

	local lang = BuffHead.Localization.Language[SystemData.Settings.Language.active];
	
	if (not lang) then
		if (not localizationWarning) then
			d("Your current language is not supported. English will be used instead.");
			localizationWarning = true;
		end
		lang = BuffHead.Localization.Language[SystemData.Settings.Language.ENGLISH];
	end
	
	return lang;
	
end