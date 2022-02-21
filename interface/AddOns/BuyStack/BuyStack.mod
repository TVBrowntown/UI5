<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<UiMod name="BuyStack" version="1.2" date="10/11/2008" >

		<Author name="VincentGdG" email="strassenflirt@gmail.com" />
		<Description text="buys stacks of items when CTRL-rightclicking." />
		
    <Dependencies>
      <Dependency name="LibSlash" />

		<Dependency name="EATemplate_DefaultWindowSkin" />
		<Dependency name="EASystem_DialogManager" />
			<Dependency name="EASystem_WindowUtils" />
			<Dependency name="EASystem_Utils" />
      <Dependency name="EASystem_Tooltips" />
      <Dependency name="EA_Cursor" />
			<Dependency name="EA_ContextMenu" />
    </Dependencies>
        
		<Files>
			<File name="BuyStack.lua" />
			<File name="BuyStack.xml" />
		</Files>
		
		<SavedVariables>
		  <SavedVariable name="BuyStackSettings" />
		</SavedVariables>
		
		<OnInitialize>
		  <CallFunction name="BuyStack.Initialize" />
		</OnInitialize>
		<OnUpdate/>
		<OnShutdown/>
	</UiMod>
</ModuleFile>
