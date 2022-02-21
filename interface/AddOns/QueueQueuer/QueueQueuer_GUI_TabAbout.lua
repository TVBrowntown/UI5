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

QueueQueuer_GUI_TabAbout = {}

function QueueQueuer_GUI_TabAbout.OnInitialize()
	LabelSetText( "QueueQueuer_GUI_TabAbout_AboutLabel", 	
		L"Queue Queuer" ..
		L"\nVersion " .. towstring(QueueQueuer.GetVersion()) ..
		L"\n\nCreated By:" ..
		L"\nDillon \"Rhekua\" DeLoss" ..
		L"\nrhekua@msn.com" .. 
		L"\nwww.rhekua.com" .. 
		L"\n\nwww.somethingawful.com" .. 
		L"\nPay us :10bux: so we can ban you for shit-posting, TIA!!!" .. 
		L"\n\n2/18/2009 - R.I.P. AZAZEL" ..
		L"\n\nVolkmar" ..
		L"\nClompastompa Jibblesmasha" ..
		L"\nStompaclompa Jibblesmasha" ..
		L"\nShroomgobbla Pilesteala" )
end

function QueueQueuer_GUI_TabAbout.OnShutdown()
end
