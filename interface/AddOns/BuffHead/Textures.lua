BuffHead.Textures = {};

local textures = 
{
	[1]="SharedMediaAluminium",
	[2]="SharedMediaArmory",
	[3]="SharedMediaBantoBar",
	[4]="SharedMediaBars",
	[5]="SharedMediaBumps",
	[6]="SharedMediaButton",
	[7]="SharedMediaCharcoal",
	[8]="SharedMediaCilo",
	[9]="SharedMediaCloud",
	[10]="SharedMediacombo",
	[11]="SharedMediaComet",
	[12]="SharedMediaDabs",
	[13]="SharedMediaDarkBottom",
	[14]="SharedMediaDiagonal",
	[15]="SharedMediaEmpty",
	[16]="SharedMediaFalumn",
	[17]="SharedMediaFifths",
	[18]="SharedMediaFlat",
	[19]="SharedMediaFourths",
	[20]="SharedMediaFrost",
	[21]="SharedMediaGlamour",
	[22]="SharedMediaGlamour2",
	[23]="SharedMediaGlamour3",
	[24]="SharedMediaGlamour4",
	[25]="SharedMediaGlamour5",
	[26]="SharedMediaGlamour6",
	[27]="SharedMediaGlamour7",
	[28]="SharedMediaGlass",
	[29]="SharedMediaGlaze",
	[30]="SharedMediaGlaze2",
	[31]="SharedMediaGloss",
	[32]="SharedMediaGraphite",
	[33]="SharedMediaGrid",
	[34]="SharedMediaHatched",
	[35]="SharedMediaHealbot",
	[36]="SharedMediaLiteStep",
	[37]="SharedMediaLiteStepLite",
	[38]="SharedMediaLyfe",
	[39]="SharedMediaMelli",
	[40]="SharedMediaMelliDark",
	[41]="SharedMediaMelliDarkRough",
	[42]="SharedMediaMinimalist",
	[43]="SharedMediaOtravi",
	[44]="SharedMediaOutline",
	[45]="SharedMediaPerl",
	[46]="SharedMediaPerl2",
	[47]="SharedMediaPill",
	[48]="SharedMediaRain",
	[49]="SharedMediaRocks",
	[50]="SharedMediaRound",
	[51]="SharedMediaRuben",
	[52]="SharedMediaRunes",
	[53]="SharedMediaSkewed",
	[54]="SharedMediaSmooth",
	[55]="SharedMediaSmoothv2",
	[56]="SharedMediaSmudge",
	[57]="SharedMediaSteel",
	[58]="SharedMediaStriped",
	[59]="SharedMediaTube",
	[60]="SharedMediaWater",
	[61]="SharedMediaWglass",
	[62]="SharedMediaWisps",
	[63]="SharedMediaXeon",
	[64]="EA_TintableImage",
};

local displaynames = 
{
	[1]="SM-Aluminium",
	[2]="SM-Armory",
	[3]="SM-BantoBar",
	[4]="SM-Bars",
	[5]="SM-Bumps",
	[6]="SM-Button",
	[7]="SM-Charcoal",
	[8]="SM-Cilo",
	[9]="SM-Cloud",
	[10]="SM-combo",
	[11]="SM-Comet",
	[12]="SM-Dabs",
	[13]="SM-DarkBottom",
	[14]="SM-Diagonal",
	[15]="SM-Empty",
	[16]="SM-Falumn",
	[17]="SM-Fifths",
	[18]="SM-Flat",
	[19]="SM-Fourths",
	[20]="SM-Frost",
	[21]="SM-Glamour",
	[22]="SM-Glamour2",
	[23]="SM-Glamour3",
	[24]="SM-Glamour4",
	[25]="SM-Glamour5",
	[26]="SM-Glamour6",
	[27]="SM-Glamour7",
	[28]="SM-Glass",
	[29]="SM-Glaze",
	[30]="SM-Glaze2",
	[31]="SM-Gloss",
	[32]="SM-Graphite",
	[33]="SM-Grid",
	[34]="SM-Hatched",
	[35]="SM-Healbot",
	[36]="SM-LiteStep",
	[37]="SM-LiteStepLite",
	[38]="SM-Lyfe",
	[39]="SM-Melli",
	[40]="SM-MelliDark",
	[41]="SM-MelliDarkRough",
	[42]="SM-Minimalist",
	[43]="SM-Otravi",
	[44]="SM-Outline",
	[45]="SM-Perl",
	[46]="SM-Perl2",
	[47]="SM-Pill",
	[48]="SM-Rain",
	[49]="SM-Rocks",
	[50]="SM-Round",
	[51]="SM-Ruben",
	[52]="SM-Runes",
	[53]="SM-Skewed",
	[54]="SM-Smooth",
	[55]="SM-Smoothv2",
	[56]="SM-Smudge",
	[57]="SM-Steel",
	[58]="SM-Striped",
	[59]="SM-Tube",
	[60]="SM-Water",
	[61]="SM-Wglass",
	[62]="SM-Wisps",
	[63]="SM-Xeon",
	[64]="Plain",
};

local dims = 
{
	["SharedMediaAluminium"] = {256,32},
	["SharedMediaArmory"] = {256,32},
	["SharedMediaBantoBar"] = {256,32},
	["SharedMediaBars"] = {256,32},
	["SharedMediaBumps"] = {256,32},
	["SharedMediaButton"] = {256,32},
	["SharedMediaCharcoal"] = {256,32},
	["SharedMediaCilo"] = {256,32},
	["SharedMediaCloud"] = {256,32},
	["SharedMediacombo"] = {256,32},
	["SharedMediaComet"] = {256,32},
	["SharedMediaDabs"] = {256,32},
	["SharedMediaDarkBottom"] = {256,32},
	["SharedMediaDiagonal"] = {256,32},
	["SharedMediaEmpty"] = {256,32},
	["SharedMediaFalumn"] = {256,32},
	["SharedMediaFifths"] = {256,32},
	["SharedMediaFlat"] = {256,32},
	["SharedMediaFourths"] = {256,32},
	["SharedMediaFrost"] = {256,32},
	["SharedMediaGlamour"] = {256,32},
	["SharedMediaGlamour2"] = {256,32},
	["SharedMediaGlamour3"] = {256,32},
	["SharedMediaGlamour4"] = {256,32},
	["SharedMediaGlamour5"] = {256,32},
	["SharedMediaGlamour6"] = {256,32},
	["SharedMediaGlamour7"] = {256,32},
	["SharedMediaGlass"] = {256,32},
	["SharedMediaGlaze"] = {256,32},
	["SharedMediaGlaze2"] = {256,32},
	["SharedMediaGloss"] = {256,32},
	["SharedMediaGraphite"] = {256,32},
	["SharedMediaGrid"] = {256,32},
	["SharedMediaHatched"] = {256,32},
	["SharedMediaHealbot"] = {256,32},
	["SharedMediaLiteStep"] = {256,32},
	["SharedMediaLiteStepLite"] = {256,32},
	["SharedMediaLyfe"] = {256,32},
	["SharedMediaMelli"] = {256,32},
	["SharedMediaMelliDark"] = {256,32},
	["SharedMediaMelliDarkRough"] = {256,32},
	["SharedMediaMinimalist"] = {256,32},
	["SharedMediaOtravi"] = {256,32},
	["SharedMediaOutline"] = {256,32},
	["SharedMediaPerl"] = {256,32},
	["SharedMediaPerl2"] = {256,32},
	["SharedMediaPill"] = {256,32},
	["SharedMediaRain"] = {256,32},
	["SharedMediaRocks"] = {256,32},
	["SharedMediaRound"] = {256,32},
	["SharedMediaRuben"] = {256,32},
	["SharedMediaRunes"] = {256,32},
	["SharedMediaSkewed"] = {256,32},
	["SharedMediaSmooth"] = {256,32},
	["SharedMediaSmoothv2"] = {256,32},
	["SharedMediaSmudge"] = {256,32},
	["SharedMediaSteel"] = {256,32},
	["SharedMediaStriped"] = {256,32},
	["SharedMediaTube"] = {256,32},
	["SharedMediaWater"] = {256,32},
	["SharedMediaWglass"] = {256,32},
	["SharedMediaWisps"] = {256,32},
	["SharedMediaXeon"] = {256,32},
	["EA_TintableImage"] = {128,128},
};

local textureData = nil;

function BuffHead.Textures.GetTextures()
	if (not textureData) then
		textureData = {};
		for index, texture in ipairs(textures) do
			table.insert(textureData, { Name = displaynames[index], Texture = texture });
		end
	end
	
	return textureData;
end

function BuffHead.Textures.GetDimensions(texture)
	local dimensions = { Width = 0, Height = 0 };
	if (dims[texture]) then
		dimensions.Width = dims[texture][1];
		dimensions.Height = dims[texture][2];
	end
	
	return dimensions;
end

function BuffHead.Textures.GetName(texture)
	for index, t in ipairs(textures) do
		if (t == texture) then
			return displaynames[index];
		end
	end
	
	return "";
end