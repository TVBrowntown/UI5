<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	
  <UiMod name="CMap_config" version="1.0" date="30/01/2011" >		
    <Author name="gutgut"/>		
    <Description text="Configuration for CustomMap" />    
    <Dependencies>      
      <Dependency name="LibSlash" />    
    </Dependencies>    
    <VersionSettings gameVersion="1.5" windowsVersion="1.0" savedVariablesVersion="1.0" />      		
    <Files>      
      <File name="LibStub.lua" />      
      <File name="LibGUI.lua" />             
      <File name="LibConfig.lua" />      
      <File name="CMap_config.lua" />		
    </Files>		 		
    <OnInitialize>      
      <CallFunction name="CMap_config.OnInitialize" />		
    </OnInitialize>		 	
  </UiMod>
</ModuleFile>