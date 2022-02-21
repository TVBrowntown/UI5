<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="BuffThrottle" version="1.3.4" date="22/09/2008" >

		<Author name="Aiiane" email="aiiane@aiiane.net" />
		<Description text="Adds performance throttling to the default buff trackers." />
		
        <Dependencies>
            <Dependency name="EATemplate_UnitFrames" />
        </Dependencies>
        
		<Files>
			<File name="BuffThrottle.lua" />
		</Files>
		
		<SavedVariables>
		  <SavedVariable name="BuffRefreshDelay" />
		</SavedVariables>
		
		<OnInitialize>
		  <CallFunction name="BuffThrottle.Initialize" />
		</OnInitialize>
		<OnUpdate>
          <CallFunction name="BuffThrottle.OnUpdate" />
        </OnUpdate>
		<OnShutdown/>
		
	</UiMod>
</ModuleFile>
