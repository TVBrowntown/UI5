local Enemy = Enemy

function Enemy.LocalizationInitialize ()

	local languages = {"enUS", "frFR", "deDE", "itIT", "esES", "koKR", "zhCN", "zhTW", "jaJP", "ruRU"}
	
	Enemy.lang = languages[SystemData.Settings.Language.active]
	if (Enemy.lang == nil) then Enemy.lang = "enEN" end
	
	Enemy.localization = {}
	Enemy.TriggerEvent ("LocalizationInitialized")
end

function Enemy.Localize (key, params)
	
	local res = Enemy.localization[key]
	if (res == nil) then return nil end
	
	res = res[Enemy.lang]
	if (res == nil) then res = Enemy.localization[key]["enUS"] end
	
	if (res ~= nil and type (res) == "string" and params ~= nil)
	then
		for k,v in ipairs (params)
		do
			res = wstring.gsub (res, L"{"..k..L"}", Enemy.toWString (params[k]))
		end
	end

	return res
end