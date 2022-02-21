<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	
  <UiMod name="LibGroup" version="1.0.5" date="10/11/2010">		
    <Author name="Healix" email="" />		
    <Description text="Library for group information" />		
    <VersionSettings gameVersion="1.9.9" windowsVersion="1.0" savedVariablesVersion="1.0" />	 		
    <Dependencies>		
    </Dependencies>		
    <Files>			
      <File name="Localization.lua" />			
      <File name="Localization/enUS.lua" />			
      <File name="Setup/Setup.lua" />			
      <File name="Setup/Setup.xml" />			
      <File name="LibGroup.lua" />		
    </Files>		 		
    <SavedVariables>			
      <SavedVariable name="LibGroup.Settings" />		
    </SavedVariables>		 		
    <OnInitialize>			
      <CreateWindow name="LibGroupSetupWindow" show="false" />			
      <CallFunction name="LibGroup.Initialize" />		
    </OnInitialize>		
    <OnUpdate>			
      <CallFunction name="LibGroup.OnUpdate" />		
    </OnUpdate>		
    <OnShutdown/>		
    <WARInfo>			
      <Categories>				
        <Category name="OTHER" />			
      </Categories>		
    </WARInfo>	
  </UiMod>
</ModuleFile>