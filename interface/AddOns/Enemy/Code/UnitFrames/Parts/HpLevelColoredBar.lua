local Enemy = Enemy
local g
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs

local properties =
{
	texture =			{ key = "texture",				order = 1,		name = L"Texture",				type = "select",						default = "default",			values = Enemy.UnitFramePart_GetTexturesSelectValues },
	vertical =			{ key = "vertical",				order = 2,		name = L"Vertical mode",		type = "bool",							default = false },
	textureFullResize =	{ key = "textureFullResize",	order = 3,		name = L"Full resize",			type = "bool",							default = false },
	level1 =			{ key = "level1",				order = 4,		name = L"If HP% is less than",	type = "int",							default = 25,					min = 0,					max = 100 },
	color1 =			{ key = "color1",				order = 5,		name = L"Then set color",		type = "color",			size = 3,		default = {255, 75, 75},		min = {0, 0, 0},			max = {255, 255, 255} },
	level2 =			{ key = "level2",				order = 6,		name = L"If HP% is less than",	type = "int",							default = 50,					min = 0,					max = 100 },
	color2 =			{ key = "color2",				order = 7,		name = L"Then set color",		type = "color",			size = 3,		default = {255, 190, 150},		min = {0, 0, 0},			max = {255, 255, 255} },
	level3 =			{ key = "level3",				order = 8,		name = L"If HP% is less than",	type = "int",							default = 75,					min = 0,					max = 100 },
	color3 =			{ key = "color3",				order = 9,		name = L"Then set color",		type = "color",			size = 3,		default = {190, 255, 150},		min = {0, 0, 0},			max = {255, 255, 255} }
}

function Enemy.UnitFramesParts_HpLevelColoredBarInitialize ()
	g = Enemy.unitFramesParts
	
	g.types["hplcbar"] =
	{
		key = "hplcbar",
		name = L"HP Bar (level colored)",
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
			CreateWindowFromTemplate (t.windowName, "EA_DynamicImage_DefaultSeparatorRight", part._frame.windowName)

			Enemy.UnitFramePart_OnUpdate_ProceedWindowInitialization (part, player)
			Enemy.UnitFramePart_ApplyTexture (data.texture, t.windowName)
		end,
		
		OnUpdate = function (part, player)
		
			local t = part._t
			local data = part.data
			local cache = t.cache
			
			if (cache.hp ~= player.hp)
			then
				cache.hp = player.hp
				
				if (cache.hp == 0)
				then
					cache.hideByDefult = true
					WindowSetShowing (t.windowName, false)
				else
					cache.hideByDefult = false
					WindowSetShowing (t.windowName, true)
					
					Enemy.UnitFramePart_ApplyTexturePercentResize (part, 0.01 * cache.hp)
					
					local color = data.color
					
					for k = 1, 3
					do
						if (cache.hp <= data["level"..k])
						then
							color = data["color"..k]
							break
						end
					end
					
					WindowSetTintColor (t.windowName, color[1], color[2], color[3])
				end
			end
			
			Enemy.UnitFramePart_OnUpdate_ProceedStateExceptColor (part, player, cache.hideByDefult)
		end
	}
end



