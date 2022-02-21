Obsidian = Obsidian or {};
if (not Obsidian.Localization) then
	Obsidian.Localization = {};
	Obsidian.Localization.Language = {};
end

local localizationWarning = false;

function Obsidian.Localization.GetMapping()

	local lang = Obsidian.Localization.Language[SystemData.Settings.Language.active];
	
	if (not lang) then
		if (not localizationWarning) then
			d("Your current language is not supported. English will be used instead.");
			localizationWarning = true;
		end
		lang = Obsidian.Localization.Language[SystemData.Settings.Language.ENGLISH];
	end
	
	return lang;
	
end