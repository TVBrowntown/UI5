<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="HealAll" version="1.0" date="10/10/2008" >        
        <Author name="Gobbo" email="matthewmhall@gmail.com" />
        <Description text="Automatically Heals at the Healer" />
        <Dependencies>
			<Dependency name="EA_InteractionWindow" />
        </Dependencies>
        <Files>
            <File name="HealAll.lua"/>
        </Files>
        <OnInitialize>
            <CallFunction name="HealAll.Initialize" />
        </OnInitialize>
		<OnUpdate>
		</OnUpdate>
        <OnShutdown/>
    </UiMod>
</ModuleFile>
