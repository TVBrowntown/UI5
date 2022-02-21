<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	
  <UiMod name="UI5" version="1" date="2021-03-25" >		
    <Author name="Bset" email="--" />		
    <Description text="Bset's Bars with dat WeakAura A E S T H E T I C C" />       
      <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />		
      <Dependencies>			
	
      </Dependencies>		
      <Files>		
        <File name="libs/LibStub.lua" />
        <File name="libs/LibGUI.lua" />
        <File name="libs/LibConfig.lua" />

        <File name="TargetInfoFix.lua" />
        <File name="UI5.lua" />			
        <File name="UI5.xml" />

        <File name="Source/UI5Constants.lua" /> 

        <File name="Source/UI5OnUpdate.lua" />

        <File name="Source/UI5Player.lua" />
        <File name="Source/UI5PlayerMechanic.lua" />
        
        <File name="Source/UI5OverheadBars.lua" />
        <File name="Source/UI5OverheadBars.xml" />
           
        <File name="Source/UI5Renown.lua" />
        <File name="Source/UI5Renown.xml" />

        <File name="Source/UI5Mainbars.lua" />
        <File name="Source/UI5Anchors.xml" />

        <File name="Source/UI5Settings.lua" />
        <File name="Source/UI5Settings.xml" />

        <File name="Source/UI5Shitlist.lua" />
        <File name="Source/UI5Danger.lua" />
        <File name="Source/UI5Fixes.lua" />

        <File name="Source/UI5UnitFrames.lua" />
        <File name="Source/UI5BoxMaker.lua" />
        
        <File name="Source/UI5OnChatLogUpdated.lua" />

        <File name="Source/UI5extendedAudio.lua" /> 

        <File name="Source/UI5Defensives.lua" />
        <File name="Source/UI5Defensives.xml" />

        <File name="Modified_AddOns/PeaceOut_Mod.lua" />
        <File name="Modified_AddOns/PeaceOut_Mod.xml" />

      </Files>
      <SavedVariables>
        <SavedVariable name="Shitlist" global="true" />
        <SavedVariable name="PeaceOut_M.settings"/>
      </SavedVariables>		
      <OnInitialize>			
        <CallFunction name="UI5.OnInit" />		
      </OnInitialize>		
      <OnUpdate>
        <CallFunction name="UI5.OnUpdate" /> 
      </OnUpdate>
      <OnShutdown>
        <CallFunction name ="UI5.OnShutdown" /> 
        <CallFunction name ="UI5.clearLogFile" />  		
      </OnShutdown>	
  </UiMod>
</ModuleFile>