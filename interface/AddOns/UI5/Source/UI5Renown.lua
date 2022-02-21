UI5Renown = {}

local BARSIZEX = 186
local BARSIZEY = 14

function UI5.DrawRenownBar()
	-- UnitFrame EXP BG
	CreateWindow("UI5_RenownBar", true)
	--WindowAddAnchor ("UI5_RenownBar", "center", "Root", "center", 0, 0)
	--DynamicImageSetTexture("UI5_RenownBar", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI5_RenownBar", BARSIZEX+4, BARSIZEY+4) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	LayoutEditor.RegisterWindow ("UI5_RenownBar", L"UI5_RenownBar", L"UI5_RenownBar", false, false, false, nil)
	WindowSetTintColor("UI5_RenownBar", BGColour[1], BGColour[2], BGColour[3])
	--WindowSetMovable("UI6_RenownBar", true)
-- UnitFrame EXP Fill_BG
	CreateWindowFromTemplate("UI6_EXP_Fill_BG", "EA_DynamicImage_DefaultSeparatorRight", "UI5_RenownBar")
	WindowAddAnchor ("UI6_EXP_Fill_BG", "center", "UI5_RenownBar", "center", 0, 0)
	DynamicImageSetTexture("UI6_EXP_Fill_BG", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI6_EXP_Fill_BG", BARSIZEX, BARSIZEY) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI6_EXP_Fill_BG", "UI5_RenownBar")
	WindowSetTintColor("UI6_EXP_Fill_BG", GreyColour[1], GreyColour[2], GreyColour[3])

if GameData.Player.level ~= 40 then
	BARSIZEY = BARSIZEY / 2
	CreateWindowFromTemplate("UI6_XP_Fill", "EA_DynamicImage_DefaultSeparatorRight", "Root")
	WindowAddAnchor ("UI6_XP_Fill", "topleft", "UI6_EXP_Fill_BG", "topleft", 0, 0)
	DynamicImageSetTexture("UI6_XP_Fill", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI6_XP_Fill", BARSIZEX, BARSIZEY) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI6_XP_Fill", "UI5_RenownBar")
	WindowSetTintColor("UI6_XP_Fill", 70, 190, 190)
	RegisterEventHandler(SystemData.Events.PLAYER_EXP_UPDATED, "UI5.ExpUpdate")
	CreateWindowFromTemplate("UI6_XP_Flash", "EA_DynamicImage_DefaultSeparatorRight", "Root")
	WindowAddAnchor ("UI6_XP_Flash", "topleft", "UI6_EXP_Fill_BG", "topleft", 0, 0)
	DynamicImageSetTexture("UI6_XP_Flash", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI6_XP_Flash", BARSIZEX, BARSIZEY) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI6_XP_Flash", "UI5_RenownBar")
	WindowSetTintColor("UI6_XP_Flash", 255, 255, 255)
	WindowSetAlpha("UI6_XP_Flash", 0)
end

-- UnitFrame EXP Fill
	CreateWindowFromTemplate("UI6_EXP_Fill", "EA_DynamicImage_DefaultSeparatorRight", "Root")
	WindowAddAnchor ("UI6_EXP_Fill", "bottomleft", "UI6_EXP_Fill_BG", "bottomleft", 0, 0)
	DynamicImageSetTexture("UI6_EXP_Fill", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI6_EXP_Fill", BARSIZEX, BARSIZEY) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI6_EXP_Fill", "UI5_RenownBar")
	WindowSetTintColor("UI6_EXP_Fill", 165, 65, 205)
-- flash for renown
	CreateWindowFromTemplate("UI6_EXP_Flash", "EA_DynamicImage_DefaultSeparatorRight", "Root")
	WindowAddAnchor ("UI6_EXP_Flash", "bottomleft", "UI6_EXP_Fill_BG", "bottomleft", 0, 0)
	DynamicImageSetTexture("UI6_EXP_Flash", solidBlack[1], solidBlack[2], solidBlack[3])
	WindowSetDimensions("UI6_EXP_Flash", BARSIZEX, BARSIZEY) -- EDIT THIS TO CHANGE DIMENSIONS OF WINDOW
	WindowSetParent("UI6_EXP_Flash", "UI5_RenownBar")
	WindowSetTintColor("UI6_EXP_Flash", 255, 255, 255)
	WindowSetAlpha("UI6_EXP_Flash", 0)

-- UnitFrame LAYER settings
	WindowSetLayer("UI5_RenownBar", Window.Layers.BACKGROUND)
	WindowSetLayer("UI6_EXP_Fill_BG", Window.Layers.BACKGROUND)
	WindowSetLayer("UI6_EXP_Fill", Window.Layers.BACKGROUND)
	WindowSetLayer("UI6_EXP_Flash", Window.Layers.BACKGROUND) 
	if DoesWindowExist("UI6_XP_Fill") then 
		WindowSetLayer("UI6_XP_Fill", Window.Layers.BACKGROUND)
		WindowSetLayer("UI6_XP_Flash", Window.Layers.BACKGROUND)  
		UI5.ExpUpdate()
	end
	UI5.RenownUpdate()
end

function UI5.RenownUpdate()

	local renownBar = (GameData.Player.Renown.curRenownEarned / GameData.Player.Renown.curRenownNeeded) * BARSIZEX
	renownPer = round((GameData.Player.Renown.curRenownEarned / GameData.Player.Renown.curRenownNeeded) * 100)

	if renownBar >= BARSIZEX then
		renownBar = BARSIZEX
	end

	if renownBar < 0 then
		renownBar = 0
	end
	WindowSetDimensions( "UI6_EXP_Fill", renownBar, BARSIZEY)
	WindowSetDimensions( "UI6_EXP_Flash", renownBar, BARSIZEY)
	WindowSetShowing( "UI6_EXP_Fill", true )
	WindowStartAlphaAnimation("UI6_EXP_Flash", Window.AnimationType.SINGLE, 0.2, 0, 1, false, 0, 0)
end

function UI5.ExpUpdate()

	local expBar = (GameData.Player.Experience.curXpEarned / GameData.Player.Experience.curXpNeeded) * BARSIZEX
	expPer = round((GameData.Player.Experience.curXpEarned / GameData.Player.Experience.curXpNeeded) * 100)

	if expBar >= BARSIZEX then
		expBar = BARSIZEX
	end

	if expBar < 0 then
		expBar = 0
	end
	WindowSetDimensions("UI6_XP_Fill", expBar, BARSIZEY)
	WindowSetDimensions( "UI6_XP_Flash", expBar, BARSIZEY)
	WindowSetShowing("UI6_XP_Fill", true )
	WindowStartAlphaAnimation("UI6_XP_Flash", Window.AnimationType.SINGLE, 0.2, 0, 1, false, 0, 0)
end