--[[TargetInfo:UpdateFromClient fix, coded by Aiiane
	Solves the problem of bad target data if multiple addons are calling TargetInfo:UpdateFromClient()
	Updated to just ignore nil returns, since this does not appear to have detrimental effect
	31 Dec. 2008]]

local version = 2
if TargetInfoFix and TargetInfoFix.version >= version then return end
if TargetInfoFix then
	TargetInfoFix.oldversion = TargetInfoFix.version
	TargetInfoFix.version = version
else
	TargetInfoFix = {}
	TargetInfoFix.version = version
end

if TargetInfoFix.ptuEventRegistered then
	UnregisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "TargetInfoFix.SET_TARGETINFO_FIX_UPDATE_FLAG_DONOTTOUCH")
	TargetInfoFix.ptuEventRegistered = false
end

if not TargetInfoFix.upEventRegistered then
	RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TargetInfoFix.APPLY_TARGETINFO_FIX_DONOTTOUCH")
	TargetInfoFix.upEventRegistered = true
end

function TargetInfoFix.APPLY_TARGETINFO_FIX_DONOTTOUCH()
	if SystemData.LoadingData.isLoading then return end
	if TargetInfoFix.fixApplied then return end

	TargetInfoFix.fixApplied = true
	
	-- Yes, this isn't nice hooking, it's replacement. I know.
	TargetInfo.UpdateFromClient =
		function(self, ...)
			local targets = GetUpdatedTargets ()

			if (targets ~= nil) then
				for unitId, targetData in pairs (targets) do
					self:SetUnitInfo (unitId, targetData)
				end
			else
				-- Totally ignore nil results. Does not seem to negatively influence target handling.
			end
		end

	UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "TargetInfoFix.APPLY_TARGETINFO_FIX_DONOTTOUCH")
	TargetInfoFix.upEventRegistered = false
	d("TargetInfo fix applied.")
end
