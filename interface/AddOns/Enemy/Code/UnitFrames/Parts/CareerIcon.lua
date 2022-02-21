local Enemy = Enemy
local g
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs

local properties =
{
}


function Enemy.UnitFramesParts_CareerIconInitialize ()
	g = Enemy.unitFramesParts
	
	g.types["careerIcon"] =
	{
		key = "careerIcon",
		name = L"Career icon",
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
			DynamicImageSetTextureDimensions (t.windowName, 32, 32)
		end,
		
		OnUpdate = function (part, player)
		
			local t = part._t
			local data = part.data
			local cache = t.cache
			
			if (cache.career ~= player.career and player.career > 0)
			then
				cache.career = player.career

				local icon, icon_x, icon_y = GetIconData (Icons.GetCareerIconIDFromCareerLine (cache.career))
				DynamicImageSetTexture (t.windowName, icon, icon_x, icon_y)
			end
			
			Enemy.UnitFramePart_OnUpdate_ProceedState (part, player)
		end
	}
end



