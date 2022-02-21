UI5PlayerMechanic = {}

local M_BUFFERX = 10
local M_BUFFERY = 4
local STYLES = {

	"ORBS",
	"BAR"
}

local MECH_COLORS = {}

function UI5.UpdateMechanics()
	if CareerResourceData:GetMaximum() == 0 or CareerResourceData:GetMaximum() == nil then 
		WindowUnregisterEventHandler(SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED, "UI5.UpdateMechanics")
		return 
	end
	local CURRENT_RESOURCES = CareerResourceData:GetCurrent()
	local MAX_RESOURCES = CareerResourceData:GetMaximum()

	if CareerResourceData:GetMaximum() == 100 then
		CURRENT_RESOURCES = CURRENT_RESOURCES * 0.05 
		MAX_RESOURCES = MAX_RESOURCES * 0.05
		--100 now is 5.
	end

	if CURRENT_RESOURCES < 0 then
		for i = -1, -5, -1
		do
			-- LESS THAN 0
			if i >= CURRENT_RESOURCES then
			WindowSetTintColor("UI5_M"..-i, 0, 255, 0) --r, g, b
			WindowStopScaleAnimation("UI5_M"..-i)
			local curWinScale = WindowGetScale("UI5_M"..-i)
			WindowStartScaleAnimation ("UI5_M"..-i, Window.AnimationType.SINGLE, curWinScale, curWinScale+0.5, 0.1, false, 0, 0)
			else
			WindowSetTintColor("UI5_M"..-i, 255, 0, 0)
			end

		end
	else
		for i = 1, MAX_RESOURCES, 1 
		do 
			-- 0 OR ABOVE RESOURCES
			if i <= CURRENT_RESOURCES then
				WindowSetTintColor("UI5_M"..i, 255, 0, 0)
				WindowStopScaleAnimation("UI5_M"..i)
				local curWinScale = WindowGetScale("UI5_M"..i)
				WindowStartScaleAnimation ("UI5_M"..i, Window.AnimationType.SINGLE, curWinScale, curWinScale+0.5, 0.1, false, 0, 0)
			else
				WindowSetTintColor("UI5_M"..i, 0, 255, 255)
			end
		end
	end

end

function UI5.BuildMechanics()
	if DoesWindowExist("UI5_Mechanics") == true then return end

	local Resources
	if CareerResourceData:GetMaximum() == 100 then
		Resources = CareerResourceData:GetMaximum() * 0.05
	elseif CareerResourceData:GetMaximum() == 0 or CareerResourceData:GetMaximum() == nil then
		return
	else
		Resources = CareerResourceData:GetMaximum()
	end
	UI5.MechanicGenerator(Resources, "ORBS")
end

function UI5.MechanicGenerator(maxResources, style)
	if style == "ORBS" then
		-- create the anchor
		CreateWindow("UI5_Mechanics", true)
		local WindowDims = (maxResources * 40) + ((maxResources - 1) * M_BUFFERX)
		WindowSetDimensions("UI5_Mechanics", WindowDims, 40 + M_BUFFERY)
		WindowSetAlpha ("UI5_Mechanics", 0)
		LayoutEditor.RegisterWindow ("UI5_Mechanics", L"UI5: Mechanics", L"UI5_Mechanics", false, false, false, nil)

		for i = 1, maxResources, 1 
		do 
		CreateWindowFromTemplate("UI5_MBG"..i, "EA_DynamicImage_DefaultSeparatorRight", "Root")

		if i == 1 then 
			WindowAddAnchor ("UI5_MBG"..i, "center", "Root", "center", 0, 0)
		else
			WindowAddAnchor ("UI5_MBG"..i, "right", "UI5_MBG"..i-1, "left", M_BUFFERX, 0)
		end

		DynamicImageSetTexture("UI5_MBG"..i, "UF_Orb_BG", 40, 40)
		DynamicImageSetTextureDimensions("UI5_MBG"..i, 40, 40)
		WindowSetDimensions("UI5_MBG"..i, 40, 40)
		WindowSetScale("UI5_MBG"..i, .7)
		WindowSetAlpha("UI5_MBG"..i, 1)
		WindowSetShowing("UI5_MBG"..i, true)
		--bg1
		CreateWindowFromTemplate("UI5_M"..i, "EA_DynamicImage_DefaultSeparatorRight", "Root")
		WindowAddAnchor ("UI5_M"..i, "center", "UI5_MBG"..i, "center", 1, 0)
		DynamicImageSetTexture("UI5_M"..i, "UF_Orb_FG", 28, 28)
		DynamicImageSetTextureDimensions("UI5_M"..i, 28, 28)
		WindowSetDimensions("UI5_M"..i, 28, 28)
		WindowSetScale("UI5_M"..i, .8)
		WindowSetAlpha("UI5_M"..i, 1)
		WindowSetShowing("UI5_M"..i, true)
		WindowSetTintColor("UI5_M"..i, 0, 255, 255)
		--orb
		end

		local AnchorPos
		if maxResources == 5 then
			--anchor to number 3
			AnchorPos = 3
		elseif maxResources == 3 then
			--anchor to number 2
			AnchorPos = 2
		else
			--anchor to number 1
			AnchorPos = 1
		end

		WindowClearAnchors("UI5_MBG1")
		WindowAddAnchor ("UI5_MBG1", "left", "UI5_Mechanics", "left", 0, 0)
	else
		--"BAR"
	end
end

function UI5.DrawMechanics()
	if DoesWindowExist("UI5Mechanics") == true then return end
	-- if the window exists then we done here
	UIMAX_RESOURCES = CareerResourceData:GetMaximum()
	UICURRENT_RESOURCES = CareerResourceData:GetCurrent()
	--
	-- UIMAX_RESOURCES will be used to determine how many to draw
end