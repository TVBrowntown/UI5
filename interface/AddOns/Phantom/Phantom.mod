<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="Phantom" version="2.321" date="02/03/2011" >

		<Author name="Aiiane author main | Wothor clone" email="aiiane@aiiane.net" />
		<Description text="Allows hiding of various default frames and other screen objects." />
        
        <VersionSettings gameVersion="1.4.1" windowsVersion="1.0" savedVariablesVersion="1.0" />
        
		<Files>
            <File name="PhantomLib\LibStub.lua" />
			<File name="PhantomLib\PhantomLib.lua" />
            <File name="Phantom.xml" />
            <File name="Phantom.lua" />
		</Files>
		
		<SavedVariables>
            <SavedVariable name="Phantom.Settings" />
		</SavedVariables>
		
		<OnInitialize>
            <CallFunction name="Phantom.Initialize" />
        </OnInitialize>
		<OnUpdate/>
		<OnShutdown/>
        
        <WARInfo>
    <Categories>
        <Category name="ACTION_BARS" />
        <Category name="BUFFS_DEBUFFS" />
        <Category name="RVR" />
        <Category name="GROUPING" />
        <Category name="CAREER_SPECIFIC" />
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
        <Career name= "MARAUDER" />
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
