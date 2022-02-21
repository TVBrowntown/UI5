LibGroup = LibGroup or {};
if (not LibGroup.Localization) then
	LibGroup.Localization = {};
	LibGroup.Localization.Language = {};
end

LibGroup.Localization.Language[SystemData.Settings.Language.ENGLISH] = 
{
	["Setup.Title"] = L"LibGroup Settings",
	["Setup.GroupUpdate"] = L"Group Update Delay",
	["Setup.GroupUpdate.Info"] = L"The group will be updated every",
	
	["Setup.GroupDistance"] = L"Group Distance",
	["Setup.GroupDistance.Enable"] = L"Enable group distances",
	
	["Setup.GroupDistance.CacheUpdate"] = L"Update Delay",
	["Setup.GroupDistance.CacheUpdate.Info"] = L"Group member's distances will be re-cached every",
	
	["Setup.GroupDistance.SearchUpdate"] = L"Search Delay",
	["Setup.GroupDistance.SearchUpdate.Info"] = L"If there is no cache, distance information will be searched for every",
};

