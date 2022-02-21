local Enemy = Enemy
local g = {}
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs
local mmin = math.min
local mmax = math.max
local InterfaceCore = InterfaceCore

local Textures =
{
	{ key = "plain",			title = L"Plain",				name = "EA_TintableImage",				x = 0,		y = 0,		dx = 136,		dy = 36 },
	{ key = "default",			title = L"Default",				name = "enemy_bar_fill_shadow",			x = 0,		y = 0,		dx = 136,		dy = 36	},
	{ key = "default2",			title = L"Default2",			name = "enemy_bar_fill_shadow2",		x = 0,		y = 0,		dx = 136,		dy = 36 },
	{ key = "rect",				title = L"Rectangle",			name = "enemy_bar_rect",				x = 0,		y = 0,		dx = 136,		dy = 36 },
	{ key = "star",				title = L"Star",				name = "enemy_star",					x = 0,		y = 0,		dx = 32,		dy = 32 },
	{ key = "4dots",			title = L"4 dots",				name = "enemy_4dots",					x = 0,		y = 0,		dx = 40,		dy = 10 },
	{ key = "3dots",			title = L"3 dots",				name = "enemy_3dots",					x = 0,		y = 0,		dx = 30,		dy = 10 },
	{ key = "4dots_vertical",	title = L"4 dots (vertical)",	name = "enemy_4dots_vertical",			x = 0,		y = 0,		dx = 10,		dy = 40 },
	{ key = "3dots_vertical",	title = L"3 dots (vertical)",	name = "enemy_3dots_vertical",			x = 0,		y = 0,		dx = 10,		dy = 30 },

	{ key = "aluminium",		title = L"Aluminium",			name = "SharedMediaAluminium",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "armory",			title = L"Armory",				name = "SharedMediaArmory",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "bantobar",			title = L"BantoBar",			name = "SharedMediaBantoBar",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "bars",				title = L"Bars",				name = "SharedMediaBars",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "bumps",			title = L"Bumps",				name = "SharedMediaBumps",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "button",			title = L"Button",				name = "SharedMediaButton",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "charcoal",			title = L"Charcoal",			name = "SharedMediaCharcoal",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "cilo",				title = L"Cilo",				name = "SharedMediaCilo",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "cloud",			title = L"Cloud",				name = "SharedMediaCloud",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "combo",			title = L"combo",				name = "SharedMediacombo",				x = 0,		y = 0,		dx = 32,		dy = 32 },
	{ key = "comet",			title = L"Comet",				name = "SharedMediaComet",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "dabs",				title = L"Dabs",				name = "SharedMediaDabs",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "darkbottom",		title = L"DarkBottom",			name = "SharedMediaDarkBottom",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "diagonal",			title = L"Diagonal",			name = "SharedMediaDiagonal",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "empty",			title = L"Empty",				name = "SharedMediaEmpty",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "falumn",			title = L"Falumn",				name = "SharedMediaFalumn",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "fifths",			title = L"Fifths",				name = "SharedMediaFifths",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "flat",				title = L"Flat",				name = "SharedMediaFlat",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "fourths",			title = L"Fourths",				name = "SharedMediaFourths",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "frost",			title = L"Frost",				name = "SharedMediaFrost",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glamour",			title = L"Glamour",				name = "SharedMediaGlamour",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glamour2",			title = L"Glamour2",			name = "SharedMediaGlamour2",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glamour3",			title = L"Glamour3",			name = "SharedMediaGlamour3",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glamour4",			title = L"Glamour4",			name = "SharedMediaGlamour4",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glamour5",			title = L"Glamour5",			name = "SharedMediaGlamour5",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glamour6",			title = L"Glamour6",			name = "SharedMediaGlamour6",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glamour7",			title = L"Glamour7",			name = "SharedMediaGlamour7",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glass",			title = L"Glass",				name = "SharedMediaGlass",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glaze",			title = L"Glaze",				name = "SharedMediaGlaze",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "glaze2",			title = L"Glaze2",				name = "SharedMediaGlaze2",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "gloss",			title = L"Gloss",				name = "SharedMediaGloss",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "graphite",			title = L"Graphite",			name = "SharedMediaGraphite",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "grid",				title = L"Grid",				name = "SharedMediaGrid",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "hatched",			title = L"Hatched",				name = "SharedMediaHatched",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "healbot",			title = L"Healbot",				name = "SharedMediaHealbot",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "litestep",			title = L"LiteStep",			name = "SharedMediaLiteStep",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "litesteplite",		title = L"LiteStepLite",		name = "SharedMediaLiteStepLite",		x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "lyfe",				title = L"Lyfe",				name = "SharedMediaLyfe",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "melli",			title = L"Melli",				name = "SharedMediaMelli",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "mellidark",		title = L"MelliDark",			name = "SharedMediaMelliDark",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "mellidarkrough",	title = L"MelliDarkRough",		name = "SharedMediaMelliDarkRough",		x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "minimalist",		title = L"Minimalist",			name = "SharedMediaMinimalist",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "otravi",			title = L"Otravi",				name = "SharedMediaOtravi",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "outline",			title = L"Outline",				name = "SharedMediaOutline",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "perl",				title = L"Perl",				name = "SharedMediaPerl",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "perl2",			title = L"Perl2",				name = "SharedMediaPerl2",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "pill",				title = L"Pill",				name = "SharedMediaPill",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "rain",				title = L"Rain",				name = "SharedMediaRain",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "rocks",			title = L"Rocks",				name = "SharedMediaRocks",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "round",			title = L"Round",				name = "SharedMediaRound",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "ruben",			title = L"Ruben",				name = "SharedMediaRuben",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "runes",			title = L"Runes",				name = "SharedMediaRunes",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "skewed",			title = L"Skewed",				name = "SharedMediaSkewed",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "smooth",			title = L"Smooth",				name = "SharedMediaSmooth",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "smoothv2",			title = L"Smoothv2",			name = "SharedMediaSmoothv2",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "smudge",			title = L"Smudge",				name = "SharedMediaSmudge",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "steel",			title = L"Steel",				name = "SharedMediaSteel",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "striped",			title = L"Striped",				name = "SharedMediaStriped",			x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "tube",				title = L"Tube",				name = "SharedMediaTube",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "water",			title = L"Water",				name = "SharedMediaWater",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "wglass",			title = L"Wglass",				name = "SharedMediaWglass",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "wisps",			title = L"Wisps",				name = "SharedMediaWisps",				x = 0,		y = 0,		dx = 256,		dy = 32 },
	{ key = "xeon",				title = L"Xeon",				name = "SharedMediaXeon",				x = 0,		y = 0,		dx = 256,		dy = 32 }
}

Enemy.UnitFramePartTextures = Textures		-- for other addons

local commonProperties =
{
	anchorFrom =	{ key = "anchorFrom",	order = 1,		name = L"Anchor (from)",		type = "select",						default = "topleft",			values = Enemy.ConfigurationWindowGetAnchorsSelectValues },
	anchorTo =		{ key = "anchorTo",		order = 2,		name = L"Anchor (to)",			type = "select",						default = "topleft",			values = Enemy.ConfigurationWindowGetAnchorsSelectValues },
	pos =			{ key = "pos",			order = 3,		name = L"Position (XY)",		type = "int[]",			size = 2,		default = {0, 0},				min = {-5000, -5000},		max = {5000, 5000} },
	size =			{ key = "size",			order = 4,		name = L"Size (XY)",			type = "int[]",			size = 2,		default = {50, 50},				min = {0, 0},				max = {5000, 5000} },
	scale =			{ key = "scale",		order = 5,		name = L"Scale",				type = "float",							default = 1,					min = 0,					max = 5 },
	layer =			{ key = "layer",		order = 6,		name = L"Layer",				type = "select",						default = 1,					values = Enemy.ConfigurationWindowGetLayersSelectValues },
	
	alpha =			{ key = "alpha",		order = 7,		name = L"Opacity",				type = "float",							default = 1,					min = 0,					max = 1,		paddingTop = 30,		tooltip = "Not working for text labels" },
	color =			{ key = "color",		order = 8,		name = L"Color",				type = "color",							default = {255, 255, 255} },
	
	offlineHide =	{ key = "offlineHide",	order = 9,		name = L"Hide when offline",	type = "bool",							default = true,				paddingTop = 30 },
	offlineAlpha =	{ key = "offlineAlpha",	order = 10,		name = L"Offline opacity",		type = "float",							default = nil,					min = 0,					max = 1 },
	offlineColor =	{ key = "offlineColor",	order = 11,		name = L"Offline color",		type = "color" },
	
	deadHide =		{ key = "deadHide",		order = 12,		name = L"Hide when dead",		type = "bool",							default = true,				paddingTop = 30 },
	deadAlpha =		{ key = "deadAlpha",	order = 13,		name = L"Dead opacity",			type = "float",							default = nil,					min = 0,					max = 1 },
	deadColor =		{ key = "deadColor",	order = 14,		name = L"Dead color",			type = "color" },
	
	distHide =		{ key = "distHide",		order = 15,		name = L"Hide when distant",	type = "bool",							default = false,				paddingTop = 30 },
	distAlpha =		{ key = "distAlpha",	order = 16,		name = L"Distant opacity",		type = "float",							default = nil,					min = 0,					max = 1 },
	distColor =		{ key = "distColor",	order = 17,		name = L"Distant color",		type = "color" }
}


function Enemy.UnitFramesPartsInitialize ()

	Enemy.PlayerStates =
	{
		Normal = 0,
		Distant = 1,
		Offline = 2,
		Dead = 3
	}
	
	g.playerStateToPropertyPrefix =
	{
		[Enemy.PlayerStates.Offline] = "offline",
		[Enemy.PlayerStates.Dead] = "dead",
		[Enemy.PlayerStates.Distant] = "dist"
	}
	
	Enemy.unitFramesParts = g
	g.types = {}
	
	Enemy.UnitFramesParts_HpBarInitialize ()
	Enemy.UnitFramesParts_ApBarInitialize ()
	Enemy.UnitFramesParts_CareerIconInitialize ()
	Enemy.UnitFramesParts_SelectionFrameInitialize ()
	Enemy.UnitFramesParts_PanelInitialize ()
	Enemy.UnitFramesParts_NameTextInitialize ()
	Enemy.UnitFramesParts_LevelTextInitialize ()
	Enemy.UnitFramesParts_HpPercentTextInitialize ()
	Enemy.UnitFramesParts_MoraleTextInitialize ()
	Enemy.UnitFramesParts_HpArchetypeColoredBarInitialize ()
	Enemy.UnitFramesParts_HpLevelColoredBarInitialize ()
	Enemy.UnitFramesParts_HpCareerColoredBarInitialize ()
	Enemy.UnitFramesParts_GroupLeaderIconInitialize ()
	Enemy.UnitFramesParts_DistanceTextInitialize ()
	Enemy.UnitFramesParts_MoraleBarInitialize ()
	Enemy.UnitFramesParts_DistanceBarInitialize ()
	
	Enemy.TriggerEvent ("UnitFramesPartsInitialize")		-- for other addons
	
	-- add textures from effects indicators
	for _, v in ipairs (Enemy.EffectsIndicatorIcons)
	do
		tinsert (Textures,
		{
			key = tostring (v.name),
			title = v.name,
			name = v.texture,
			x = v.x,
			y = v.y,
			dx = v.width,
			dy = v.height
		})
	end
	
	g.texturesByKeys = {}
	for _, v in ipairs (Textures)
	do
		g.texturesByKeys[v.key] = v
	end
end


--------------------------------------------------------------- Helpers (used in parts implementation)
function Enemy.UnitFramePart_OnRemove (part)

	local t = part._t

	if (t.windowName and DoesWindowExist (t.windowName))
	then
		DestroyWindow (t.windowName)
	end
	
	t.windowName = nil
end


function Enemy.UnitFramePart_OnUpdate_ProceedWindowInitialization (part, player)
	
	local t = part._t
	local data = part.data
	local frame = part._frame
	
	local global_scale = InterfaceCore.GetScale ()
	
	WindowSetHandleInput (t.windowName, false)
	WindowAddAnchor (t.windowName, data.anchorTo, frame.windowName, data.anchorFrom, data.pos[1], data.pos[2])
	WindowSetDimensions (t.windowName, data.size[1], data.size[2])
	WindowSetScale (t.windowName, data.scale * frame.settings.unitFramesScale * global_scale)
	WindowSetAlpha (t.windowName, data.alpha)
	WindowSetTintColor (t.windowName, data.color[1], data.color[2], data.color[3])
	WindowSetLayer (t.windowName, data.layer)
end


function Enemy.UnitFramePart_OnUpdate_ProceedTextWindowInitialization (part, player)
	
	local t = part._t
	local data = part.data
	local frame = part._frame
	
	local global_scale = InterfaceCore.GetScale ()
	
	WindowSetHandleInput (t.windowName, false)
	WindowAddAnchor (t.windowName, data.anchorTo, frame.windowName, data.anchorFrom, data.pos[1], data.pos[2])
	WindowSetDimensions (t.windowName, data.size[1], data.size[2])
	WindowSetScale (t.windowName, data.scale * frame.settings.unitFramesScale * global_scale)
	WindowSetAlpha (t.windowName, data.alpha)
	WindowSetLayer (t.windowName, data.layer)
	
	LabelSetTextColor (t.windowName, data.color[1], data.color[2], data.color[3])
	LabelSetFont (t.windowName, data.font, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	LabelSetTextAlign (t.windowName, data.align)
	LabelSetWordWrap (t.windowName, data.wrap == true)
end


function Enemy.UnitFramePart_OnUpdate_ProceedState (part, player, hideByDefult)

	local t = part._t
	local data = part.data
	local cache = t.cache
	
	if (cache.state == t.playerState) then return end
	cache.state = t.playerState

	hideByDefult = Enemy.isNil (hideByDefult, false)
	
	if (cache.state == Enemy.PlayerStates.Normal)
	then
		WindowSetShowing (t.windowName, not hideByDefult)
		WindowSetAlpha (t.windowName, data.alpha)
		WindowSetTintColor (t.windowName, data.color[1], data.color[2], data.color[3])
	else
		local prefix = g.playerStateToPropertyPrefix[cache.state]
		
		if (data[prefix.."Hide"])
		then
			WindowSetShowing (t.windowName, false)
		else
			WindowSetShowing (t.windowName, not hideByDefult)
		end
		
		local alpha = data[prefix.."Alpha"]
		if (alpha) then WindowSetAlpha (t.windowName, alpha) end
		
		local color = data[prefix.."Color"] or data.color
		WindowSetTintColor (t.windowName, color[1], color[2], color[3])
	end
end


function Enemy.UnitFramePart_OnUpdate_ProceedTextState (part, player, hideByDefult)

	local t = part._t
	local data = part.data
	local cache = t.cache
	
	if (cache.state == t.playerState) then return end
	cache.state = t.playerState
	
	hideByDefult = Enemy.isNil (hideByDefult, false)
	
	if (cache.state == Enemy.PlayerStates.Normal)
	then
		WindowSetShowing (t.windowName, not hideByDefult)
		
		-- uncomment when Mythic implements alpha on text labels
		--WindowSetAlpha (t.windowName, data.alpha)
		
		LabelSetTextColor (t.windowName, data.color[1], data.color[2], data.color[3])
	else
		local prefix = g.playerStateToPropertyPrefix[cache.state]
		
		if (data[prefix.."Hide"])
		then
			WindowSetShowing (t.windowName, false)
		else
			WindowSetShowing (t.windowName, not hideByDefult)
		end
		
		-- uncomment when Mythic implements alpha on text labels
		--local alpha = data[prefix.."Alpha"]
		--if (alpha) then WindowSetAlpha (t.windowName, alpha) end
		
		local color = data[prefix.."Color"] or data.color
		if (color) then LabelSetTextColor (t.windowName, color[1], color[2], color[3]) end
	end
end


function Enemy.UnitFramePart_OnUpdate_ProceedStateExceptColor (part, player, hideByDefult)

	local t = part._t
	local data = part.data
	local cache = t.cache
	
	if (cache.state == t.playerState) then return end
	cache.state = t.playerState
	
	hideByDefult = Enemy.isNil (hideByDefult, false)
	
	if (cache.state == Enemy.PlayerStates.Normal)
	then
		WindowSetShowing (t.windowName, not hideByDefult)
		WindowSetAlpha (t.windowName, data.alpha)
	else
		local prefix = g.playerStateToPropertyPrefix[cache.state]
		
		if (data[prefix.."Hide"])
		then
			WindowSetShowing (t.windowName, false)
		else
			WindowSetShowing (t.windowName, not hideByDefult)
		end
		
		local alpha = data[prefix.."Alpha"]
		if (alpha) then WindowSetAlpha (t.windowName, alpha) end
	end
end


function Enemy.UnitFramePart_OnUpdate_ProceedStateExceptShowing (part, player)

	local t = part._t
	local data = part.data
	local cache = t.cache
	
	if (cache.state == t.playerState) then return end
	
	cache.state = t.playerState
	
	if (cache.state == Enemy.PlayerStates.Normal)
	then
		WindowSetAlpha (t.windowName, data.alpha)
		WindowSetTintColor (t.windowName, data.color[1], data.color[2], data.color[3])
	else
		local prefix = g.playerStateToPropertyPrefix[cache.state]
		
		local alpha = data[prefix.."Alpha"]
		if (alpha) then WindowSetAlpha (t.windowName, alpha) end
		
		local color = data[prefix.."Color"] or data.color
		if (color) then WindowSetTintColor (t.windowName, color[1], color[2], color[3]) end
	end
end


function Enemy.UnitFramePart_GetTexturesSelectValues ()
	return Enemy.ConfigurationWindowGetSelectValuesHelper (Textures, "title", "key", true)
end


function Enemy.ConfigurationWindowGetLayersSelectValues ()
	return Enemy.ConfigurationWindowGetSelectValuesHelper (Window.Layers, "$key", "$value", true)
end


function Enemy.ConfigurationWindowGetAnchorsSelectValues ()
	return Enemy.ConfigurationWindowGetSelectValuesHelper (Enemy.Anchors, "$value", "$value", false)
end


function Enemy.ConfigurationWindowGetFontsSelectValues ()
	return Enemy.ConfigurationWindowGetSelectValuesHelper (Enemy.Fonts, "$value", "$value", true)
end


function Enemy.ConfigurationWindowGetTextAlignsSelectValues ()
	return Enemy.ConfigurationWindowGetSelectValuesHelper (Enemy.TextAligns, "$value", "$value", true)
end


function Enemy.UnitFramePart_GetTexture (key)
	return g.texturesByKeys[key]
end


function Enemy.UnitFramePart_ApplyTexture (textureKey, windowName)
	
	local texture = Enemy.UnitFramePart_GetTexture (textureKey)
	if (not texture) then return end
	
	DynamicImageSetTexture (windowName, texture.name, texture.x or 0, texture.y or 0)
	
	if (texture.dx ~= nil and texture.dy ~= nil)
	then
		DynamicImageSetTextureDimensions (windowName, texture.dx, texture.dy)
	end
end


function Enemy.UnitFramePart_ApplyTexturePercentResize (part, value)

	local t = part._t
	local data = part.data
	local cache = t.cache

	if (data.textureFullResize)
	then
		if (not data.vertical)
		then
			WindowSetDimensions (t.windowName, value * data.size[1], data.size[2])
		else
			WindowSetDimensions (t.windowName, data.size[1], value * data.size[2])
		end
	else
		local texture = Enemy.UnitFramePart_GetTexture (data.texture)
		
		if (not data.vertical)
		then
			WindowSetDimensions (t.windowName, value * data.size[1], data.size[2])
			DynamicImageSetTextureDimensions (t.windowName, value * texture.dx, texture.dy)
		else
			WindowSetDimensions (t.windowName, data.size[1], value * data.size[2])
			DynamicImageSetTextureDimensions (t.windowName, texture.dx, value * texture.dy)
		end
	end
end


--------------------------------------------------------------- EnemyUnitFramePart class
EnemyUnitFramePart = {}
EnemyUnitFramePart.__index = EnemyUnitFramePart

function EnemyUnitFramePart.New (data)
	local obj = {}
	setmetatable (obj, EnemyUnitFramePart)
	
	-- defaults
	obj.id = tostring (Enemy.NewId ())
	obj.isEnabled = true
	obj.name = nil
	obj.playerTypeMatch = 1
	obj.playerType = 1
	obj.exceptMe = false
	obj.archetypeMatch = 1
	obj.archetypes = { false, false, false }
	
	obj.type = "hpbar"
	obj.data = {}
	
	if (data)
	then
		obj:Load (data)
	else
		obj:Reset ()
		obj:OnLoaded ()
	end
	
	return obj
end


function EnemyUnitFramePart:Remove ()
	if (self._type) then self._type.OnRemove (self) end
	self:BoundingBoxSetShowing (false)
end


function EnemyUnitFramePart:BoundingBoxSetShowing (show)

	local t = self._t
	local frame = self._frame
	
	if (self._boundingBoxWindowName)
	then
		if (DoesWindowExist (self._boundingBoxWindowName)) then DestroyWindow (self._boundingBoxWindowName) end
		self._boundingBoxWindowName = nil
	end
	
	if (show and frame and frame.windowName and t.windowName)
	then
		self._boundingBoxWindowName = "BoundingBox"..Enemy.NewId ()
		CreateWindowFromTemplate (self._boundingBoxWindowName, "EnemyRectangleTemplate", frame.windowName)
		WindowSetLayer (self._boundingBoxWindowName, Window.Layers.OVERLAY)
		WindowAddAnchor (self._boundingBoxWindowName, "topleft", t.windowName, "topleft", 0, 0)
		WindowAddAnchor (self._boundingBoxWindowName, "bottomright", t.windowName, "bottomright", 0, 0)
	end
end


function EnemyUnitFramePart:Load (data)

	self:Remove ()

	self.name = data.name
	self.isEnabled = data.isEnabled
	self.playerTypeMatch = data.playerTypeMatch
	self.playerType = data.playerType
	self.exceptMe = data.exceptMe
	self.archetypeMatch = data.archetypeMatch

	if (data.archetypes)
	then
		self.archetypes =
		{
			data.archetypes[1] or false,
			data.archetypes[2] or false,
			data.archetypes[3] or false
		}
	end
	
	self.type = data.type
	self:Reset ()
	
	self.data = Enemy.clone (data.data)

	self:OnLoaded ()
end


function EnemyUnitFramePart:OnLoaded ()

	self._archetypesFilterPresent = (self.archetypes[1] or self.archetypes[2] or self.archetypes[3])
	self._type = g.types[self.type]
	self._t = {}
end


local function Reset (data, properties)

	if (not properties) then return end
	
	for _, p in pairs (properties)
	do
		data[p.key] = Enemy.clone (p.default)
	end
end


function EnemyUnitFramePart:Reset ()
	
	self.data = {}
	
	Reset (self.data, commonProperties)
	
	if (self._type)
	then
		Reset (self.data, self._type.properties)
	end
end


function EnemyUnitFramePart:Edit (settings, onOkCallback)
	
	Enemy.UnitFramesUI_UnitFramePartDialog_Open (self, settings, self.name, function (old, new)
		
		old:Load (new)
		
		if (onOkCallback)
		then
			onOkCallback (self)
		end
	end)
end


function EnemyUnitFramePart:Bind (frame)
	self:Remove ()
	self._frame = frame
	self._type.OnBind (self)
end

--
-- Check wherever specified player can possibly match this unit frame part
--
function EnemyUnitFramePart:CanMatch (player)
	
	return not
		(
			-- player type filter
			(
				(
					self.playerType == 2
					and not (player.isSelf == (self.playerTypeMatch == 1))
				)
				or
				(
					self.playerType == 3
					and not (player.isInPlayerGroup == (self.playerTypeMatch == 1))
				)
			)
			
			or
			
			-- except me
			(
				self.exceptMe and player.isSelf
			)
			
			or
	
			-- archetypes filter		
			(
				self._archetypesFilterPresent
				and
				(self.archetypes[Enemy.careerArchetypes[player.career]] ~= (self.archetypeMatch == 1))
			)
		)
end


function EnemyUnitFramePart:Update (player, testMode)

	local t = self._t
	
	t.playerState = Enemy.PlayerStates.Normal
	
	if (not player.isOnline)
	then
		t.playerState = Enemy.PlayerStates.Offline
	elseif (player.hp == 0)
	then
		t.playerState = Enemy.PlayerStates.Dead
	elseif (player.isDistant or player.isLOS)
	then
		t.playerState = Enemy.PlayerStates.Distant
	end

	self._type.OnUpdate (self, player)
end


----------------------------------------------------------------- UI: Unit frame part dialog
local dlg =
{
	isInitialized = false,
	exampleConfigParameters =
	{
		exampleShowBoundingBox =
		{
			key = "exampleShowBoundingBox",
			order = 10,
			name = L"Show bounding box",
			type = "bool",
			default = false,
			tooltip = L"Make sure currently edited visual part bounding box is withing unit frame bounding box or otherwise this visual part will be not mouse clickable.",
			windowWidth = 300
		},
		exampleShowUnitFrameBoundingBox =
		{
			key = "exampleShowUnitFrameBoundingBox",
			order = 20,
			name = L"Show unit frame bounding box",
			type = "bool",
			default = false,
			tooltip = L"Make sure currently edited visual part bounding box is withing unit frame bounding box or otherwise this visual part will be not mouse clickable.",
			windowWidth = 300
		},
		exampleHideEffectsIndicators =
		{
			key = "exampleHideEffectsIndicators",
			order = 30,
			name = L"Hide effects indicators",
			type = "bool",
			default = true,
			windowWidth = 300
		},
		exampleNew =
		{
			key = "exampleNew",
			order = 40,
			name = L"New example",
			type = "button",
			windowWidth = 150
		}
	}
}


function Enemy.UnitFramesUI_UnitFramePartDialog_IsOpen ()
	return WindowGetShowing ("EnemyUnitFramePartDialog")
end


function Enemy.UnitFramesUI_UnitFramePartDialog_Hide ()

	dlg.example:Remove ()
	dlg.obj:Remove ()
	if (dlg.wnExampleCfg and DoesWindowExist (dlg.wnExampleCfg)) then DestroyWindow (dlg.wnExampleCfg) end
	
	WindowSetShowing ("EnemyUnitFramePartDialog", false)
end


function Enemy.UnitFramesUI_UnitFramePartDialog_Open (data, settings, ignoreName, onOkCallback)

	dlg.isLoading = true

	if (not dlg.isInitialized)
	then
		-- initialize dialog UI
		CreateWindow ("EnemyUnitFramePartDialog", false)
		
		LabelSetText ("EnemyUnitFramePartDialogTitleBarText", L"Unit frame part")
		ButtonSetText ("EnemyUnitFramePartDialogOkButton", L"OK")
		ButtonSetText ("EnemyUnitFramePartDialogCancelButton", L"Cancel")
		
		LabelSetText ("EnemyUnitFramePartDialogContentScrollChildNameLabel", L"Name")
		
		ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerTypeMatch", L"Only on")
		ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerTypeMatch", L"Except for")
		ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerType", L"all")
		ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerType", L"me")
		ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerType", L"my group")
		LabelSetText ("EnemyUnitFramePartDialogContentScrollChildExceptMeLabel", L"except me")
		
		ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildArchetypeMatch", L"Only on")
		ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildArchetypeMatch", L"Except for")
		LabelSetText ("EnemyUnitFramePartDialogContentScrollChildArchetype1Label", L"tanks")
		LabelSetText ("EnemyUnitFramePartDialogContentScrollChildArchetype2Label", L"dps")
		LabelSetText ("EnemyUnitFramePartDialogContentScrollChildArchetype3Label", L"healers")
		
		dlg.wncp = "EnemyUnitFramePartDialogContentScrollChildCommonProperties"
		Enemy.CreateConfigurationWindow (dlg.wncp, "EnemyUnitFramePartDialogContentScrollChild", commonProperties, Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample)
		WindowAddAnchor (dlg.wncp, "bottomleft", "EnemyUnitFramePartDialogContentScrollChildTypeLabel", "topleft", 0, 30)
		
		LabelSetText ("EnemyUnitFramePartDialogContentScrollChildTypeLabel", L"Type")
		
		dlg.types = {}
		
		for _, v in pairs (g.types)
		do
			tinsert (dlg.types, v)
		end
		
		tsort (dlg.types, function (a, b)
			return (a.name < b.name)
		end)
		
		for _, v in ipairs (dlg.types)
		do
			ComboBoxAddMenuItem ("EnemyUnitFramePartDialogContentScrollChildType", v.name)
		end
		
		dlg.isInitialized = true
	end
	
	-- proceed parameters
	dlg.oldData = data
	dlg.onOkCallback = onOkCallback
	
	dlg.obj = EnemyUnitFramePart.New (data)
	
	dlg.settings =
	{
		unitFramesParts = {},
		effectsIndicators = {},
		clickCastings = {}
	}
	
	if (settings)
	then
		for k, v in pairs (settings)
		do
			if (not k:match("^unitFrames.*") or k == "unitFramesParts") then continue end
			dlg.settings[k] = v
		end
		
		if (settings.effectsIndicators)
		then
			for _, v in pairs (settings.effectsIndicators)
			do
				if (not v.isEnabled) then continue end
				tinsert (dlg.settings.effectsIndicators, Enemy.clone (v))
			end
		end
		
		if (settings.unitFramesParts)
		then
			for _, v in pairs (settings.unitFramesParts)
			do
				if (v.name == ignoreName or not v.isEnabled) then continue end
				tinsert (dlg.settings.unitFramesParts, Enemy.clone (v))
			end
		end
	end
	
	dlg.settings.unitFramesTestMode = true
	
	-- example
	dlg.example = EnemyUnitFrame.New (100 + Enemy.NewId (), 100 + Enemy.NewId ())
	dlg.example:ApplySettings (dlg.settings)
	dlg.example:Enable ()
	
	dlg.examplePlayer = EnemyPlayer.GetRandomExample ()
	dlg.example:Update (dlg.examplePlayer)

	WindowClearAnchors (dlg.example.windowName)
	WindowAddAnchor (dlg.example.windowName, "topright", "EnemyUnitFramePartDialog", "topleft", 50, 200)
	WindowSetLayer (dlg.example.windowName, Window.Layers.OVERLAY)
	
	dlg.wnExampleCfg = "EnemyUnitFramePartDialogExampleCfg"
	dlg.exampleConfigParameters.exampleNew.onClick = Enemy.UnitFramesUI_UnitFramePartDialog_OnNewExampleClick
	Enemy.CreateConfigurationWindow (dlg.wnExampleCfg, "Root", dlg.exampleConfigParameters, Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample)
	WindowClearAnchors (dlg.wnExampleCfg)
	WindowAddAnchor (dlg.wnExampleCfg, "bottomleft", dlg.example.windowName, "topleft", 0, 50)
	
	-- fill form
	dlg.firstLoad = true
	
	TextEditBoxSetText ("EnemyUnitFramePartDialogContentScrollChildName", Enemy.isNil (dlg.obj.name, L""))

	ComboBoxSetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerTypeMatch", dlg.obj.playerTypeMatch)
	ComboBoxSetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerType", dlg.obj.playerType)
	ButtonSetPressedFlag ("EnemyUnitFramePartDialogContentScrollChildExceptMe", dlg.obj.exceptMe)
	
	ComboBoxSetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildArchetypeMatch", dlg.obj.archetypeMatch)
	for k, a in pairs(dlg.obj.archetypes)
	do
		ButtonSetPressedFlag ("EnemyUnitFramePartDialogContentScrollChildArchetype"..k, a)
	end
	
	for k, v in ipairs (dlg.types)
	do
		if (v.key == dlg.obj.type)
		then
			ComboBoxSetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildType", k)
			break
		end
	end
	
	local twn = "EnemyUnitFramePartDialogContentScrollChildTypeConfig"
	if (DoesWindowExist (twn)) then DestroyWindow (twn) end
	
	Enemy.ConfigurationWindowLoadData (dlg.wncp, dlg.obj.data)
	Enemy.ConfigurationWindowReset (dlg.wnExampleCfg, dlg)
	
	dlg.isLoading = false
	
	WindowSetShowing ("EnemyUnitFramePartDialog", true)
	Enemy.UnitFramesUI_UnitFramePartDialog_OnTypeSelChanged ()
	ScrollWindowSetOffset ("EnemyUnitFramePartDialogContent", 0)
	
	dlg.firstLoad = false
end


function Enemy.UnitFramesUI_UnitFramePartDialog_OnExceptMeChanged ()

	if (dlg.isLoading) then return end
	
	dlg.obj.exceptMe = not dlg.obj.exceptMe
	ButtonSetPressedFlag ("EnemyUnitFramePartDialogContentScrollChildExceptMe", dlg.obj.exceptMe)
end


local function _OnArchetypeChanged (n)

	if (dlg.isLoading) then return end
	
	dlg.obj.archetypes[n] = not dlg.obj.archetypes[n]
	ButtonSetPressedFlag ("EnemyUnitFramePartDialogContentScrollChildArchetype"..n, dlg.obj.archetypes[n])
end


function Enemy.UnitFramesUI_UnitFramePartDialog_OnArchetype1Changed ()
	_OnArchetypeChanged (1)
end

function Enemy.UnitFramesUI_UnitFramePartDialog_OnArchetype2Changed ()
	_OnArchetypeChanged (2)
end


function Enemy.UnitFramesUI_UnitFramePartDialog_OnArchetype3Changed ()
	_OnArchetypeChanged (3)
end


function Enemy.UnitFramesUI_UnitFramePartDialog_OnTypeSelChanged ()
	
	if (dlg.isLoading) then return end
	
	dlg.isLoading = true
	
	local t = dlg.types[ComboBoxGetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildType")]
	local twn = "EnemyUnitFramePartDialogContentScrollChildTypeConfig"

	if (dlg.obj.type ~= t.key or not DoesWindowExist (twn))
	then
		if (DoesWindowExist (twn)) then DestroyWindow (twn) end
		t.CreateConfigurationWindow (twn, "EnemyUnitFramePartDialogContentScrollChild")
		
		WindowClearAnchors (twn)
		WindowAddAnchor (twn, "bottomleft", dlg.wncp, "topleft", 0, 0)
	
		if (not dlg.firstLoad)
		then
			for _, p in pairs (t.properties)
			do
				dlg.obj.data[p.key] = Enemy.clone (p.default)
			end
		end
		
		dlg.obj.type = t.key
	end
	
	t.LoadConfigurationWindow (twn, dlg.obj)
	
	ScrollWindowUpdateScrollRect ("EnemyUnitFramePartDialogContent")
	
	dlg.isLoading = false
	Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample ()
end


function Enemy.UnitFramesUI_UnitFramePartDialog_OnPartPropertyBoolValueClick ()
	
	if (dlg.isLoading) then return end
	
	local wn = SystemData.ActiveWindow.name
	if (ButtonGetDisabledFlag (wn.."Value")) then return end
	
	local v = ButtonGetPressedFlag (wn.."Value")
	ButtonSetPressedFlag (wn.."Value", not v)
	
	Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample ()
end


function Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample ()

	if (dlg.isLoading) then return end
	
	dlg.obj:Remove ()
	
	-- get data from form
	dlg.obj.name = Enemy.isEmpty (TextEditBoxGetText ("EnemyUnitFramePartDialogContentScrollChildName"), nil)
	
	dlg.obj.playerTypeMatch = ComboBoxGetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerTypeMatch")
	dlg.obj.playerType = ComboBoxGetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildPlayerType")
	
	dlg.obj.archetypeMatch = ComboBoxGetSelectedMenuItem ("EnemyUnitFramePartDialogContentScrollChildArchetypeMatch")
	dlg.obj.archetypes =
	{
		ButtonGetPressedFlag ("EnemyUnitFramePartDialogContentScrollChildArchetype1"),
		ButtonGetPressedFlag ("EnemyUnitFramePartDialogContentScrollChildArchetype2"),
		ButtonGetPressedFlag ("EnemyUnitFramePartDialogContentScrollChildArchetype3")
	}
	
	Enemy.ConfigurationWindowSaveData (dlg.wncp, dlg.obj.data)
	Enemy.ConfigurationWindowSaveData (dlg.wnExampleCfg, dlg)
	
	local t = g.types[dlg.obj.type]
	local twn = "EnemyUnitFramePartDialogContentScrollChildTypeConfig"
	t.SaveConfigurationWindow (twn, dlg.obj)
	
	dlg.obj:OnLoaded ()
	dlg.obj:Bind (dlg.example)
	dlg.obj:Update (dlg.examplePlayer, true)
	dlg.obj:BoundingBoxSetShowing (dlg.exampleShowBoundingBox)
	
	for _, v in pairs (dlg.settings.effectsIndicators)
	do
		v.isEnabled = not dlg.exampleHideEffectsIndicators
	end
	
	dlg.example.forcePlayerChanged = true
	dlg.example:Update (dlg.examplePlayer)
	dlg.example:UpdateEffects (dlg.examplePlayer)
	dlg.example:BoundingBoxSetShowing (dlg.exampleShowUnitFrameBoundingBox)
end



function Enemy.UnitFramesUI_UnitFramePartDialog_OnNewExampleClick ()

	dlg.obj:Remove ()
	
	for _, v in pairs (dlg.settings.effectsIndicators)
	do
		v.isEnabled = not dlg.exampleHideEffectsIndicators
	end	
	
	dlg.examplePlayer = EnemyPlayer.GetRandomExample ()
	dlg.example.forcePlayerChanged = true
	dlg.example:Update (dlg.examplePlayer)
	
	dlg.obj:OnLoaded ()
	dlg.obj:Bind (dlg.example)
	dlg.obj:Update (dlg.examplePlayer, true)
	dlg.obj:BoundingBoxSetShowing (dlg.exampleShowBoundingBox)
	
	dlg.example:UpdateEffects (dlg.examplePlayer)
	dlg.example:BoundingBoxSetShowing (dlg.exampleShowUnitFrameBoundingBox)
end



function Enemy.UnitFramesUI_UnitFramePartDialog_Ok ()

	if (dlg.isLoading or not Enemy.UnitFramesUI_UnitFramePartDialog_IsOpen ()) then return end
	
	Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample ()
	
	if (not dlg.obj.name)
	then
		DialogManager.MakeOneButtonDialog (L"You must enter a name.", L"Ok")
		return
	end
	
	if (dlg.onOkCallback)
	then
		dlg.onOkCallback (dlg.oldData, dlg.obj)
	end

	Enemy.UnitFramesUI_UnitFramePartDialog_Hide ()
end



