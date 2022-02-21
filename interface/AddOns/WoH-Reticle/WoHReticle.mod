<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="WoH-Reticle" version="1.1" date="2020-06-02" >

    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

    <Author name="dalen" email="" />
    <Description text="Reticle based on Wrath of Heroes. Use /wohreticle for settings." />
    
    <Dependencies>
      <Dependency name="LibSlash" />
    </Dependencies>

    <Files>
      <File name="libs\LibStub.lua" />
      <File name="libs\LibGUI.lua" />
      <File name="libs\LibConfig.lua" />
      <File name="WoHReticle.xml" />
      <File name="WoHReticle.lua" />
    </Files>

    <SavedVariables>
      <SavedVariable name="WoHReticle.Settings" />
    </SavedVariables>
    <OnInitialize>
      <CallFunction name="WoHReticle.Initialize" />
    </OnInitialize>
        <OnUpdate>
			<CallFunction name="WoHReticle.OnUpdate"/>		
    	</OnUpdate>	
	
  </UiMod>
</ModuleFile>
