<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Bloody Frame" version="1.1" date="09/03/2021" >
		<Author name="Bset" email="--" />
		<Description text="Blood effect around your screen when you're taking a beating!" />
		<Files>
			<File name="BloodyFrame.lua" />
			<File name="BloodyFrame.xml" />
		</Files>
		<OnInitialize>
			<CallFunction name="BloodyFrame.OnInit" />
		</OnInitialize>
		<OnShutdown>
			<CallFunction name="BloodyFrame.Shutdown" />
    	</OnShutdown>
	</UiMod>
</ModuleFile>
