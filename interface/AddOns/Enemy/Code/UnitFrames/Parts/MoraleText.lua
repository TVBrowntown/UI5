local Enemy = Enemy
local g
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs

local properties =
{
	font =		{ key = "font",			order = 1,		name = L"Font",					type = "select",						default = "font_clear_medium_bold",						values = Enemy.ConfigurationWindowGetFontsSelectValues },
	align =		{ key = "align",		order = 2,		name = L"Align",				type = "select",						default = "left",										values = Enemy.ConfigurationWindowGetTextAlignsSelectValues },
	prefix =	{ key = "prefix",		order = 3,		name = L"Prefix",				type = "string",						default = L"M" },
	suffix =	{ key = "suffix",		order = 4,		name = L"Suffix",				type = "string",						default = L"" }
}


function Enemy.UnitFramesParts_MoraleTextInitialize ()
	g = Enemy.unitFramesParts
	
	g.types["moraleText"] =
	{
		key = "moraleText",
		name = L"Morale text",
		properties = properties,
		
		CreateConfigurationWindow = function (wn, root)
			Enemy.CreateConfigurationWindow (wn, root, properties, Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample)
		end,
		
		LoadConfigurationWindow = function (wn, part)
			Enemy.ConfigurationWindowLoadData (wn, part.data)
		end,
		
		SaveConfigurationWindow = function (wn, part)
			Enemy.ConfigurationWindowSaveData (wn, part.data)
		end,
		
		OnRemove = Enemy.UnitFramePart_OnRemove,
		
		OnBind = function (part)
		
			local t = part._t
			local data = part.data
			
			t.cache = {}
		
			t.windowName = part._frame.windowName..Enemy.NewId ()
			CreateWindowFromTemplate (t.windowName, "EA_Label_DefaultText", part._frame.windowName)

			Enemy.UnitFramePart_OnUpdate_ProceedTextWindowInitialization (part, player)
		end,
		
		OnUpdate = function (part, player)
		
			local t = part._t
			local data = part.data
			local cache = t.cache
			
			if (cache.morale ~= player.morale)
			then
				cache.morale = player.morale
				
				if (cache.morale == 0)
				then
					cache.hideByDefult = true
					WindowSetShowing (t.windowName, false)
				else
					cache.hideByDefult = false
					WindowSetShowing (t.windowName, true)
					
					LabelSetText (t.windowName, data.prefix..Enemy.toWStringOrEmpty (cache.morale)..data.suffix)
				end
			end
			
			Enemy.UnitFramePart_OnUpdate_ProceedTextState (part, player, cache.hideByDefult)
		end
	}
end



