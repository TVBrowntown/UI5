<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >    
  <UiMod name="CMap" version="5.1" date="15/05/2021" >        
    <Author name="N/A" email="N/A" />        
    <Description text="CustomMap" />        
    <Dependencies>            
      <Dependency name="EASystem_Utils" />            
      <Dependency name="EASystem_WindowUtils" />            
      <Dependency name="EA_LegacyTemplates" />            
      <Dependency name="EASystem_Tooltips" />            
      <Dependency name="EA_WorldMapWindow" />            
      <Dependency name="EA_ScenarioSummaryWindow" />            
      <Dependency name="LibSlash" />  
      <Dependency name="Queue Queuer" optional="true" forceEnable="false" />          
      <!-- <Dependency name="cmapconfig" />  -->             
    </Dependencies>        
    <VersionSettings gameVersion="1.9.9" windowsVersion="1.5" savedVariablesVersion="1.2" />          
    <Files>            
      <File name="Cmap_Templates_OverheadMap.xml" />            
      <File name="CMap.xml" />        
    </Files>        
    <OnInitialize>           
      <!--<CallFunction name="CMapWindow.Initialize" /> -->            
      <CreateWindow name="CMapWindowPinFilterMenu" show="false" />            
      <CreateWindow name="CMapWindowResize"        show="false" />            
      <!-- The script in EA_Window_OverheadMap actuates the pin filter menu, so load it last -->            
      <CreateWindow name="CMapWindow"              show="false" />                         
      <!--<CreateWindow name="CMapWindow2"              show="true" /> -->         
    </OnInitialize>        
    <SavedVariables>            
      <SavedVariable name="CMapWindow.Settings" />            
      <SavedVariable name="CMapWindow.VisSettings" />        
    </SavedVariables>    
  </UiMod>
</ModuleFile>