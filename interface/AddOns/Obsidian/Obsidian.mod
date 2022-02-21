<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	
  <UiMod name="Obsidian" version="1.0.4-gcdmod" date="11/17/2010" >    
    <VersionSettings gameVersion="1.9.9" windowsVersion="1.0" savedVariablesVersion="1.0" />  		
    <Author name="Healix" email="" />		
    <Description text="Customizable castbar replacement. Modded by anon" />        		
    <Dependencies>			
      <Dependency name="EA_CastTimerWindow" />			
      <Dependency name="EA_ActionBars" />			
      <Dependency name="EASystem_LayoutEditor" />		
    </Dependencies>		
    <Files>			
      <File name="Localization.lua" />			
      <File name="Localization/enUS.lua" />			 			
      <File name="Core.lua" />			
      <File name="Display.xml" />			
      <File name="Textures.lua" />			
      <File name="Textures.xml" />			
      <File name="Castbar.lua" />			
      <File name="GlobalCooldown.lua" />			 			
      <File name="EffectTracker/RBTree.lua" />			
      <File name="EffectTracker/EffectContainer.lua" />			
      <File name="EffectTracker/EffectBar.lua" />			 			
      <File name="Setup/Setup.lua" />			
      <File name="Setup/SetupMenu.xml" />			
      <File name="Setup/General.xml" />			
      <File name="Setup/Demo.lua" />			
      <File name="Setup/SelectFont.lua" />			
      <File name="Setup/SelectTexture.lua" />			
      <File name="Setup/SelectColor.lua" />			
      <File name="Setup/SetupCastbar.lua" />			
      <File name="Setup/SetupCastbar.xml" />			
      <File name="Setup/SetupEffectTracker.lua" />			
      <File name="Setup/SetupEffectTracker.xml" />		
    </Files>		 		
    <SavedVariables>			
      <SavedVariable name="Obsidian.Settings" />		   		
    </SavedVariables>		 		
    <OnInitialize>			
      <CreateWindow name="ObsidianSetupMenuWindow" show="false" />			
      <CreateWindow name="ObsidianSetupSelectTextureWindow" show="false" />			
      <CreateWindow name="ObsidianSetupSelectColorWindow" show="false" />			
      <CreateWindow name="ObsidianSetupCastbarWindow" show="false" />			
      <CreateWindow name="ObsidianSetupEffectTrackerWindow" show="false" />			
      <CallFunction name="Obsidian.Initialize" />		
    </OnInitialize>		
    <OnUpdate>			
      <CallFunction name="Obsidian.OnUpdate" />		
    </OnUpdate>		
    <OnShutdown/>		
    <WARInfo>		
    </WARInfo>	
  </UiMod>
</ModuleFile>