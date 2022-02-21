<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="alertMod" version="1.0" date="10/23/2008" >
        <VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.1" />
        <Author name="Snotrocket" email="snotrocketwar@gmail.com" />
        <Description text="Provides customization options for the appearance of alert messages." />
        
        <Dependencies>
	    	<Dependency name="LibSlash" optional="true" forceEnable="true" />
        </Dependencies>
        
        <Files>
			<File name="alertMod.xml" />
            <File name="alertMod.lua" />
        </Files>
        
        <OnInitialize>
			<CreateWindow name="alertMod" />
        </OnInitialize>

        <OnUpdate/>

        <OnShutdown/>
		
		<SavedVariables>
			<SavedVariable name="alertModSettings" />
		</SavedVariables>
        
    </UiMod>
</ModuleFile>