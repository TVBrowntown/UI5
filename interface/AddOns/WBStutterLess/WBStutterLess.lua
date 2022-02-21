WBStutterLess = {}

function WBStutterLess.Initialize()
	RegisterEventHandler( SystemData.Events.ALL_MODULES_INITIALIZED, 	"WBStutterLess.OnInitialize")
end

function WBStutterLess.OnInitialize()
	UnregisterEventHandler( SystemData.Events.BATTLEGROUP_UPDATED, 	"GroupWindow.OnGroupUpdated")
	UnregisterEventHandler( SystemData.Events.GROUP_PLAYER_ADDED, 	"GroupWindow.OnGroupPlayerAdded")
	UnregisterEventHandler( SystemData.Events.GROUP_EFFECTS_UPDATED,"GroupWindow.OnEffectsUpdated")
	UnregisterEventHandler( SystemData.Events.GROUP_STATUS_UPDATED, "GroupWindow.OnStatusUpdated")

	GroupWindow.OnScenarioBegin	= function () end
	GroupWindow.ConditionalShow = function () end

	GroupWindow.OnScenarioEnd = function () 
		GroupWindow.inScenarioGroup = false 
		GroupWindow.UpdateGroupMembers()
	end
	
	GroupWindow.UpdateGroupMembers 	= function () 
		if ( GroupWindow.groupData == nil ) then return end
		
		GroupWindow.inWorldGroup = GroupWindow.IsMemberValid( 1 )
		
		if( GameData.Player.isInScenario or GameData.Player.isInSiege )  then
			if( GroupWindow.inScenarioGroup == false ) then
				GroupWindow.inWorldGroup = false
			end
		end
	end
	
	WBStutterLess.DestroyGroupMembers()
end

function WBStutterLess.DestroyGroupMembers()
	for index = 1, GroupWindow.MAX_GROUP_MEMBERS do
		if ( GroupWindow.groupMembers[ index ] ~= nil ) then
			local unitId = GroupWindow.groupMembers[index].m_unitId
			
			GroupWindow.groupMembers[index].m_RvRFrame:Destroy()
			GroupWindow.groupMembers[index]:Destroy()
			
			UnitFrames.m_UnitIdToFrameMapping[ unitId ] = nil
			GroupWindow.groupMembers[index] = nil
		end
		
		if ( GroupWindow.Buffs[ index ] ~= nil ) then
			GroupWindow.Buffs[index]:Shutdown()
			GroupWindow.Buffs[index] = nil
		end
	end
end