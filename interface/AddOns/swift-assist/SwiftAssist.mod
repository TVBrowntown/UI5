<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="Swift Assist" version="2.4.4" date="13/08/2020" >

	<Author name="Yakar, Wothor, Aktheon" email="" />
	<Description text="This addon will let you mark selected player as Assisted player with SwiftSetAssist macro and select his target with SwiftAssist macro. You can use SwiftAssistMe macro to ask in chat to assist on your target (uses same broadcast options as SwiftSetAssist, use /swift set/sc/city). If /swift smart enabled - your macro SwiftSmartAssist will be set to assist last player that has used SwiftAssistMe macro. Use /swift for settings and help" />
	<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />
	<Dependencies>
		<Dependency name="EASystem_Utils" />
		<Dependency name="EA_MacroWindow" />
		<Dependency name="LibSlash" optional="true" forceEnable="true" />
	</Dependencies>

	<Files>
		<File name="TargetInfoFix.lua" />
		<File name="SwiftAssist.lua" />
		<File name="SwiftAssist.xml" />
	</Files>

	<OnInitialize>
		<CallFunction name="SwiftAssist.Initialize" />
	</OnInitialize>
	<SavedVariables>
		<SavedVariable name="SwiftAssist.Settings" global="true"/>
	</SavedVariables>
		<WARInfo>
			<Categories>
				<Category name="COMBAT" />
				<Category name="RVR" />
				<Category name="GROUPING" />
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
