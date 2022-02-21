<?xml version="1.0" encoding="UTF-8"?>
<!--
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
-->
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Queue Queuer" version="2.8.7" date="8/12/2020" >
		<VersionSettings gameVersion="1.3.6" windowsVersion="1.0" savedVariablesVersion="1.1" />
		<Author name="Rhekua (fixes by sxe)" email="rhekua@msn.com (sxxe@gmx.de)" />
		<Description text="Scenario Queue manager" />
		<Dependencies>
			<Dependency name="LibSlash" />
      		<Dependency name="EA_ChatWindow"/>
      		<Dependency name="EA_ChatSystem"/>
			<Dependency name="EA_ScenarioLobbyWindow" />
			<Dependency name="EA_GroupWindow" />
      		<Dependency name="EATemplate_DefaultWindowSkin" />
		</Dependencies>
		<Files>
			<File name="QueueQueuer.lua" />
			<File name="QueueQueuer_GUI_TabTier1.xml" />
			<File name="QueueQueuer_GUI_TabTier2.xml" />
			<File name="QueueQueuer_GUI_TabTier3.xml" />
			<File name="QueueQueuer_GUI_TabTier4.xml" />
			<File name="QueueQueuer_GUI_TabHelp.xml" />
			<File name="QueueQueuer_GUI_TabAbout.xml" />
			<File name="QueueQueuer_GUI.xml" />
		</Files>
		<SavedVariables>
			<SavedVariable name="QueueQueuer_SavedVariables" />
		</SavedVariables>
		<OnInitialize>
			<CallFunction name="QueueQueuer.OnInitialize" />
      		<CreateWindow name="QueueQueuer_GUI" show="false" />
      		<CreateWindow name="QueueQueuer_GUI_MapButtons" show="true" />
      		<CreateWindow name="QueueQueuer_GUI_MapButton" show="true" />
		</OnInitialize>
		<OnShutdown>
			<CallFunction name="QueueQueuer.OnShutdown" />
    		</OnShutdown>
		<OnUpdate>
			<CallFunction name="QueueQueuer.OnUpdate" />
		</OnUpdate>
	</UiMod>
</ModuleFile>
