<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="AdvancedRenownTrainer" version="1.6.6" date="2/6/2021" >

		<Author name="Varonth" email="villana@gmx.net" />
		<Description text="Redesigns the Renown Trainer Window." />
	
    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
	
    <Dependencies>
		<Dependency name="EATemplate_DefaultWindowSkin" />
        <Dependency name="EASystem_Utils" />
        <Dependency name="EASystem_WindowUtils" />
        <Dependency name="EASystem_Tooltips" />
        <Dependency name="EASystem_Strings" />
        <Dependency name="EASystem_DialogManager" />
        <Dependency name="EASystem_ResourceFrames" />
    </Dependencies>
        
		<Files>
			<File name="AdvancedRenownTrainingWindow.xml" />
			<File name="AdvancedRenownTraining.lua" />
			<File name="AdvancedRenownTrainingAbilityButton.xml" />
			<File name="AdvancedRenownTrainingAbilities.lua" />
			<File name="AdvancedRenownTrainingTabTemplate.xml" />
			<File name="AdvancedRenownTrainingPresets.xml" />
			<File name="AdvancedRenownTrainingImportDialog.xml" />
			<File name="AdvancedRenownTrainingImportExport.lua" />
		</Files>
		<SavedVariables>
            <SavedVariable name="AdvancedRenownTraining.Presets" />
        </SavedVariables>
		
		<OnInitialize>
			<CreateWindow name="AdvancedRenownTrainingWindow" show="false" />
		</OnInitialize>
		<OnUpdate/>
		<OnShutdown/>
        
        <WARInfo>
    <Categories>
        <Category name="SYSTEM" />
        <Category name="OTHER" />
    </Categories>
    <Careers>
        <Career name="BLACKGUARD" />
        <Career name="WITCH_ELF" />
        <Career name="DISCIPLE" />
        <Career name="SORCERER" />
        <Career name="IRON_BREAKER" />
        <Career name="SLAYER" />
        <Career name="RUNE_PRIEST" />
        <Career name="ENGINEER" />
        <Career name="BLACK_ORC" />
        <Career name="CHOPPA" />
        <Career name="SHAMAN" />
        <Career name="SQUIG_HERDER" />
        <Career name="WITCH_HUNTER" />
        <Career name="KNIGHT" />
        <Career name="BRIGHT_WIZARD" />
        <Career name="WARRIOR_PRIEST" />
        <Career name="CHOSEN" />
        <Career name="MARAUDER" />
        <Career name="ZEALOT" />
        <Career name="MAGUS" />
        <Career name="SWORDMASTER" />
        <Career name="SHADOW_WARRIOR" />
        <Career name="WHITE_LION" />
        <Career name="ARCHMAGE" />
    </Careers>
</WARInfo>

		
	</UiMod>
</ModuleFile>
