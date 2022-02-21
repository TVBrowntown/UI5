<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="LibSlash" version="3.00" date="19/05/2010" >

		<Author name="Aiiane" email="aiiane@aiiane.net" />
		<Description text="Simple library for registering handlers for slash commands." />
	
    <VersionSettings gameVersion="1.3.5" windowsVersion="1.0" savedVariablesVersion="1.0" />
	
    <Dependencies>
        <Dependency name="EASystem_LayoutEditor" />
        <Dependency name="EA_ChatWindow" />
        <Dependency name="EA_UiModWindow" />
    </Dependencies>
        
		<Files>
            <File name="LibSlash.xml" />
			<File name="LibSlash.lua" />
		</Files>
		
		<OnInitialize>
			<CallFunction name="LibSlash.Initialize" />
		</OnInitialize>
		<OnUpdate/>
		<OnShutdown/>
        
        <WARInfo>
    <Categories>
        <Category name="CHAT" />
        <Category name="SYSTEM" />
        <Category name="DEVELOPMENT" />
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
