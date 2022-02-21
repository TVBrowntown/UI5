BuffHead.AdvancedCompression = {};

local compressionSettings = nil;
local compression = nil;

function BuffHead.AdvancedCompression.Register(compressedEffect)
	compressionSettings = compressionSettings or {};
	compression = compression or {};
	
	table.insert(compressionSettings, compressedEffect);
	local settingsIndex = #compressionSettings;
	
	for index, item in ipairs(compressedEffect.Items) do
		compression[item.AbilityId] = compression[item.AbilityId] or {};
		compression[item.AbilityId][item.Type] = settingsIndex;
	end

end

function BuffHead.AdvancedCompression.Clear()
	compressionSettings = nil;
	compression = nil;
end

function BuffHead.AdvancedCompression.Load()
	for index, compressedItem in ipairs(BuffHead.Settings.AdvancedCompression) do
		BuffHead.AdvancedCompression.Register(compressedItem);
	end
end

function BuffHead.AdvancedCompression.GetCompression(ability)
	if (compression == nil) then return end
	local compressedEffect = compression[ability.abilityId];
	if (not compressedEffect) then return end
	
	if (compressedEffect[BuffHead.Compression.All]) then
		return compressedEffect[BuffHead.Compression.All];
	end
	
	if (ability.castByPlayer) then
		return compressedEffect[BuffHead.Compression.OnlyMine];
	else
		return compressedEffect[BuffHead.Compression.OnlyOthers];
	end
end

function BuffHead.AdvancedCompression.GetCompressionSettings(index)
	return compressionSettings[index];
end