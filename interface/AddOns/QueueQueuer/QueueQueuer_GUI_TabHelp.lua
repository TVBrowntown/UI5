--[[ 
Queue Queuer
Warhammer Online: Age of Reckoning UI modification that simplifies warband
scenario queueing with other scenario-oriented features as well.
    
Copyright (C) 2008-2010  Dillon "Rhekua" DeLoss
rhekua@msn.com		    www.rhekua.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

QueueQueuer_GUI_TabHelp = {}

function QueueQueuer_GUI_TabHelp.OnInitialize()
	LabelSetText( "QueueQueuer_GUI_TabHelp_BlacklistDescriptionLabel", 	
		L"* Press \"Join Queues\" to queue solo, group, or issue the warband command for all Group Queuers to queue their groups!" ..
		L"\n\n* Press \"Leave Queues\" to leave all solo, group, or issue the warband command for all members with QQ installed to leave queues. Members without QQ must manually leave queues." ..
		L"\n\n* In a warband, each group must have ONE Group Queuer." ..
		L"\n\n* In a warband, all Group Queuers will sync up blacklists automatically with the player that issued the join command." ..
		L"\n\n* It is not guaranteed that your warband will join the same scenario. Be patient and try varying blacklists." ..
		L"\n\n* A checked box disables queuing for that scenario." ..
		L"\n\n* If you encounter a bug, please report it!" )
end

function QueueQueuer_GUI_TabHelp.OnShutdown()
end
