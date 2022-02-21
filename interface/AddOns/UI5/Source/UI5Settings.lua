UI5Settings = {}

DebugToggle					= false
SplashGFXToggle				= true --the fancy shit at the bottom
UI5Active					= true
BBFirstRun					= true
ShitlistToggle				= true
DangerToggle				= true
SpellSuggesterToggle 		= false
oldUIMode					= true
ChallengerDeepToggle		= false
extendedAudioToggle			= true
CNCToggle					= true
SoloQueuingToggle			= false
DefensivesToggle			= false
FunLogoutToggle				= true
PeaceOutToggle 				= true
GhettoAssistToggle 			= false
KillAlertToggle				= true
MechanicToggle				= true

function UI5.DrawSettingsButtons()
	if DoesWindowExist("UI5 Settings") then DestroyWindow("UI5 Settings") end
	CreateWindowFromTemplate("UI5 Settings", "UI5 Settings", "Root")
	WindowSetDimensions("UI5 Settings", 200, 46)
	LayoutEditor.RegisterWindow ("UI5 Settings", L"UI5 Settings", L"UI5 Settings", false, false, false, nil)
end

function UI5.CallSettings()
	MainMenuWindow.ToggleSettingsWindow()
end

function UI5.CallCharacterSheet()
	CharacterWindow.ToggleShowing()
end

function UI5.CallCharacterSheet()
	CharacterWindow.ToggleShowing()
end

function UI5.CallSpellbook()
	AbilitiesWindow.ToggleShowing()
end

function UI5.CallTalents()
	TomeWindow.ToggleShowing()
end