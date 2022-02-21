<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	
  <UiMod name="BuffHead" version="2.2.5" date="12/25/2010" >		
    <VersionSettings gameVersion="1.9.9" windowsVersion="1.0" savedVariablesVersion="1.1" />		
    <Author name="Healix" email="" />		
    <Description text="Overhead buff/debuff indicators. To open settings input '/bh', to open cache input '/bh c'" />        		
    <Dependencies>			
      <Dependency name="LibGroup" />		
    </Dependencies>		
    <Files>			
      <File name="Localization.lua" />			
      <File name="Localization/enUS.lua" />			 			
      <File name="Core.lua" />			
      <File name="Display.xml" />			
      <File name="Container.lua" />			
      <File name="EffectContainer.lua" />			
      <File name="Effect.lua" />			
      <File name="EffectFrame.lua" />			
      <File name="RBTree.lua" />			
      <File name="FrameManager.lua" />			
      <File name="Textures.lua" />			
      <File name="Textures.xml" />			
      <File name="AdvancedCompression.lua" />			
      <File name="AdvancedContainers.lua" />			 			
      <File name="Setup/SetupMenu.xml" />			
      <File name="Setup/Setup.lua" />			
      <File name="Setup/General.xml" />			
      <File name="Setup/SelectFont.lua" />			
      <File name="Setup/SelectColor.lua" />			
      <File name="Setup/SelectTexture.lua" />			
      <File name="Setup/SetupGeneral.xml" />			
      <File name="Setup/SetupGeneral.lua" />			 			
      <File name="Setup/SetupLayout.xml" />			
      <File name="Setup/SetupLayout.lua" />			
      <File name="Setup/SetupLayoutManager.lua" />			
      <File name="Setup/SetupLayoutManager.xml" />			
      <File name="Setup/SetupLayoutProperties.lua" />			
      <File name="Setup/SetupLayoutProperties.xml" />			
      <File name="Setup/LayoutFrame.lua" />			
      <File name="Setup/LayoutControlFrame.lua" />			
      <File name="Setup/LayoutDemo.lua" />			 			
      <File name="Setup/SetupAdvancedContainers.xml" />			
      <File name="Setup/SetupAdvancedContainers.lua" />			
      <File name="Setup/SetupAdvancedContainersItem.xml" />			
      <File name="Setup/SetupAdvancedContainersItem.lua" />			
      <File name="Setup/SetupAdvancedContainersItemProperties.xml" />			
      <File name="Setup/SetupAdvancedContainersItemProperties.lua" />			
      <File name="Setup/ContainerDemo.lua" />			 			
      <File name="Setup/SetupPriorityEffects.xml" />			
      <File name="Setup/SetupPriorityEffects.lua" />			
      <File name="Setup/SetupPriorityEffectsItem.xml" />			
      <File name="Setup/SetupPriorityEffectsItem.lua" />			 			
      <File name="Setup/SetupAdvancedCompression.xml" />			
      <File name="Setup/SetupAdvancedCompression.lua" />			
      <File name="Setup/SetupAdvancedCompressionItem.xml" />			
      <File name="Setup/SetupAdvancedCompressionItem.lua" />			
      <File name="Setup/SetupAdvancedCompressionItemEffect.xml" />			
      <File name="Setup/SetupAdvancedCompressionItemEffect.lua" />			 			
      <File name="Setup/SetupPerformance.xml" />			
      <File name="Setup/SetupPerformance.lua" />			
      <File name="Setup/SetupDisplay.xml" />			
      <File name="Setup/SetupDisplay.lua" />			
      <File name="Setup/SetupTrackers.xml" />			
      <File name="Setup/SetupTrackers.lua" />			
      <File name="Setup/SetupContainer.xml" />			
      <File name="Setup/SetupContainer.lua" />			
      <File name="Setup/SetupFilter.xml" />			
      <File name="Setup/SetupFilter.lua" />			
      <File name="Setup/SetupEffectCache.xml" />			
      <File name="Setup/SetupEffectCache.lua" />			
      <File name="Setup/SetupEffectCacheTable.xml" />			
      <File name="Setup/SetupEffectCacheTable.lua" />		
    </Files>		 		
    <SavedVariables>			
      <SavedVariable name="BuffHead.Settings" />		   		
    </SavedVariables>		 		
    <OnInitialize>			
      <CreateWindow name="BuffHeadSetupSelectTextureWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupSelectColorWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupLayoutManagerWindow" show="false" />			 			
      <CreateWindow name="BuffHeadSetupAdvancedCompressionWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupAdvancedCompressionItemWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupAdvancedCompressionItemEffectWindow" show="false" />			 			
      <CreateWindow name="BuffHeadSetupAdvancedContainersWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupAdvancedContainersItemWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupAdvancedContainersItemPropertiesWindow" show="false" />			 			
      <CreateWindow name="BuffHeadSetupPriorityEffectsWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupPriorityEffectsItemWindow" show="false" />		 			
      <CreateWindow name="BuffHeadSetupFilterWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupGeneralWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupLayoutWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupLayoutPropertiesWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupPerformanceWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupDisplayWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupContainerWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupTrackersWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupMenuWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupEffectCacheWindow" show="false" />			
      <CreateWindow name="BuffHeadSetupEffectCacheTableWindow" show="false" />			
      <CallFunction name="BuffHead.Initialize" />		
    </OnInitialize>		
    <OnUpdate>			
      <CallFunction name="BuffHead.OnUpdate" />		
    </OnUpdate>		
    <OnShutdown/>		
    <WARInfo>			
      <Categories>				
        <Category name="BUFFS_DEBUFFS" />			
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