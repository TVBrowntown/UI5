<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="TexturedButtons" version="1.3.10" date="12/28/2010">
		<Author name="Healix" email="" />
		<Description text="Custom textures for action bars." />
		<VersionSettings gameVersion="1.4.1" windowsVersion="1.0" savedVariablesVersion="1.0" />
		
		<Dependencies>
			<Dependency name="EA_ActionBars" />
            <Dependency name="EASystem_ActionBarClusterManager" />
            <Dependency name="EA_SettingsWindow" />
		</Dependencies>
		
		<Files>
			<File name="Localization.lua" />
			<File name="Localization/enUS.lua" />
			
			<File name="TexturedButtons.lua" />
			
			<File name="Setup/Setup.lua" />
			<File name="Setup/SetupMenu.xml" />
			<File name="Setup/General.xml" />
			<File name="Setup/SelectFont.lua" />
			<File name="Setup/SelectColor.lua" />
			<File name="Setup/SetupTextures.lua" />
			<File name="Setup/SetupTextures.xml" />
			<File name="Setup/SetupAdvancedTextures.lua" />
			<File name="Setup/SetupAdvancedTextures.xml" />
			<File name="Setup/SetupCooldown.lua" />
			<File name="Setup/SetupCooldown.xml" />
			<File name="Setup/SetupFonts.lua" />
			<File name="Setup/SetupFonts.xml" />
			<File name="Setup/SetupTint.lua" />
			<File name="Setup/SetupTint.xml" />
			<File name="Setup/SetupMisc.lua" />
			<File name="Setup/SetupMisc.xml" />
			<File name="Setup/SetupActionbar.lua" />
			<File name="Setup/SetupActionbar.xml" />
			
			<File name="CooldownPulse.lua" />
			<File name="CooldownPulse.xml" />
			<File name="Textures.lua" />
			<File name="Textures.xml" />
		</Files>
		
		<SavedVariables>
			<SavedVariable name="TexturedButtons.Settings" />
		</SavedVariables>
		
		<OnInitialize>
			<CreateWindow name="TexturedButtonsSetupSelectColorWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupMenuWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupTexturesWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupAdvancedTexturesWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupCooldownWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupFontsWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupTintWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupMiscWindow" show="false" />
			<CreateWindow name="TexturedButtonsSetupActionbarWindow" show="false" />
			<CallFunction name="TexturedButtons.Initialize" />
		</OnInitialize>
		<OnUpdate />
		<OnShutdown>
			<CallFunction name="TexturedButtons.Unload" />
		</OnShutdown>
	</UiMod>
</ModuleFile>
