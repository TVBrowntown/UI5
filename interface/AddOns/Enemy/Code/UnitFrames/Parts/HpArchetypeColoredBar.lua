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
	textureFullResize =	{ key = "textureFullResize",	order = 3,		name = L"Full resize",		type = "bool",							default = false },
	tankColor =			{ key = "tankColor",			order = 4,		name = L"Tanks color",			type = "color",			size = 3,		default = {150, 190, 255},		min = {0, 0, 0},			max = {255, 255, 255} },
	dpsColor =			{ key = "dpsColor",				order = 5,		name = L"Dps color",			type = "color",			size = 3,		default = {255, 190, 100},		min = {0, 0, 0},			max = {255, 255, 255} },
	healColor =			{ key = "healColor",			order = 6,		name = L"Healers color",		type = "color",			size = 3,		default = {190, 255, 100},		min = {0, 0, 0},			max = {255, 255, 255} }
}

function Enemy.UnitFramesParts_HpArchetypeColoredBarInitialize ()
	g = Enemy.unitFramesParts
	
	g.archetypeToPropertyName =
	{
		[Enemy.Archetypes.Tank] = "tankColor",
		[Enemy.Archetypes.Dps] = "dpsColor",
		[Enemy.Archetypes.Healer] = "healColor"
	}
	
	g.types["hpacbar"] =
	{
		key = "hpacbar",
		name = L"HP Bar (archetype colored)",
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
				end
			end
			
			if (cache.career ~= player.career)
			then
				cache.career = player.career
				local color = data[g.archetypeToPropertyName[Enemy.careerArchetypes[cache.career]]];
				WindowSetTintColor (t.windowName, color[1], color[2], color[3])
			end
			
			Enemy.UnitFramePart_OnUpdate_ProceedStateExceptColor (part, player, cache.hideByDefult)
		end
	}
end



