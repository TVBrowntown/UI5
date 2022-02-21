<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="WBStutterLess" version="2.1" date="01/01/2022" >
		<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
		
		<Author name="Zapz"/>
		<Description text="Reduces stutters in warband during keeps and forts" />
		
		<Files>
			<File name="WBStutterLess.lua" />
		</Files>
		
		<OnInitialize>
			<CallFunction name="WBStutterLess.Initialize" /> 
		</OnInitialize>	
		
		<Dependencies>
			<Dependency name="Enemy" />
		</Dependencies>
		
	</UiMod>
</ModuleFile>