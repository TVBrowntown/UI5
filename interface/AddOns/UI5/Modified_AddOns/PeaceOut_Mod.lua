----------------------------------------------------------------
-- Peace Out
--
--    Peace Out provides a logout dialog to give more direct feel
--	  to the logoff/exit process. If libslash is enabled, you can 
--	  optionally enable the registering of the /exit and /logoff 
--	  commands with PeaceOut_M by using /PeaceOut_M to toggle the 
--	  usage of these commands.
--
-- Written By NigelTufnel ( Adam.Dew@gmail.com )
----------------------------------------------------------------

----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

PeaceOut_M = {}
-- PO_UseSlash = false

----------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------
local PO_Monitor = false
local TickIsReg = TickIsReg
local PO_Status = 0
local PO_Val = 0
local PO_ValRange = 0
local PO_Msg, PO_MsgCnt

local PO_TimeDelay = .1
local PO_Time = PO_TimeDelay
local PO_Tick

local PO_MenuHook

----------------------------------------------------------------
-- PeaceOut_M Functions
----------------------------------------------------------------

function PeaceOut_M.Init()
	if not PeaceOut_M.settings then
		PeaceOut_M.settings = {}
		PeaceOut_M.settings.sounds = {enable = true, start = 500, cancel = 220}
		PeaceOut_M.settings.vignette = false
	end
	-- Init some values here
	-- if PO_UseSlash == nil then PO_UseSlash = false end
	RegisterEventHandler(TextLogGetUpdateEventId("System"), "PeaceOut_M.LogOut")
	
	-- Basic events to use
	--RegisterEventHandler(SystemData.Events.LOG_OUT, "PeaceOut_M.LogOut")
	RegisterEventHandler(SystemData.Events.EXIT_GAME, "PeaceOut_M.ExitGame")
	
	-- Set window for use
	CreateWindow("PeaceOut_M", true)  
	WindowSetShowing("PeaceOut_M", false)
	-- ButtonSetText("PeaceOut_MCancel", L"Cancel")
	--WindowSetTintColor("PeaceOut_MBg", 220, 220, 220)
	LabelSetText("PeaceOut_MDisplay", L"Logging out")

	-- Setup our message check
	PO_MsgCnt = TextLogGetNumEntries("System")
	if PO_MsgCnt > 0 then 
		PO_Msg = select(3, TextLogGetEntry("System", TextLogGetNumEntries("System") - 1))
	end
	
	-- Hook the menu toggle to utilize escaping out of logout
	PO_MenuHook = MainMenuWindow.ToggleShowing
	MainMenuWindow.ToggleShowing = PeaceOut_M.MenuHook
	RegisterEventHandler(SystemData.Events.LOADING_END, "PeaceOut_M.DelayInit")
	RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "PeaceOut_M.DelayInit")
end 

function PeaceOut_M.DelayInit()
	if LibSlash then LibSlash.RegisterSlashCmd("PeaceOut_M", function(input) PeaceOut_M.Slash(input) end) end
	UnregisterEventHandler(SystemData.Events.LOADING_END, "PeaceOut_M.DelayInit")
	UnregisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "PeaceOut_M.DelayInit")
end

-- Allows us to press escape to end logout
function PeaceOut_M.MenuHook(...)
	-- Bail if our window is open and end logout process
	if WindowGetShowing("PeaceOut_M") then 
		PeaceOut_M.Cancel()
		return
	end
	PO_MenuHook(...)
end

function PO_Tick()
	
	local _, filterId, msg = TextLogGetEntry( "System", TextLogGetNumEntries("System") - 1 ) 
	-- If we have a new message
	if msg ~= PO_Msg then
		PO_Msg = msg
		-- Init if we have a 20s message, adjust at other time intervals
		if msg:find(L"You will finish logging out in 20 seconds.") then--GetFormatStringFromTable("Hardcoded", 464, {20}) then
			PO_Monitor = true
			PO_Val = .5
			PO_ValRange = 0
			PeaceOut_M.UpdateLabel()
			WindowSetShowing("PeaceOut_M", true)
			WindowStopAlphaAnimation("PeaceOut_M")
			WindowStartAlphaAnimation("PeaceOut_M", Window.AnimationType.SINGLE_NO_RESET, 0, 1, .1, false, 0, 0)

			if PeaceOut_M.settings.sounds.enable then
				PlaySound(PeaceOut_M.settings.sounds.start)
			end

			LabelSetTextColor("PeaceOut_MDisplay", 255, 255, 255)

		elseif msg:find(L"You will finish logging out in 15 seconds.") then--GetFormatStringFromTable("Hardcoded", 464, {15}) then
			PO_Val = 5
			PO_ValRange = 5
			PeaceOut_M.UpdateLabel()
		elseif msg:find(L"You will finish logging out in 10 seconds.") then--GetFormatStringFromTable("Hardcoded", 464, {10}) then
			PO_Val = 10
			PO_ValRange = 10
			PeaceOut_M.UpdateLabel()
		elseif msg:find(L"You will finish logging out in 5 seconds.") then--GetFormatStringFromTable("Hardcoded", 464, {5}) then
			PO_Val = 15
			PO_ValRange = 15
			PeaceOut_M.UpdateLabel()
			LabelSetTextColor("PeaceOut_MDisplay", 255, 0, 0)
			
		-- Bail us out if we are done logging out
		elseif msg:find(L"You are no longer logging out.") then--GetStringFromTable("Hardcoded", 465) then
			-- Hide window + disable updater
			PO_Monitor = false
			WindowSetShowing("PeaceOut_M", false)
			UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "PeaceOut_M.TickCheck")
			TickIsReg = false
			PO_Status = 0

			if PeaceOut_M.settings.sounds.enable then
				PlaySound(PeaceOut_M.settings.sounds.cancel)
			end
			-- Re-init slash checker if we want to use it
			-- if PO_UseSlash then 
			-- 	PO_TimeDelay = .8
			-- 	RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "PeaceOut_M.SlashCheck") 
			-- end
			return
		end
	end
	
	-- If the current time is in allowable range then update the label to have it
	if math.floor(PO_Val) ~= PO_ValRange and math.floor(PO_Val) < PO_ValRange + 5 then
		PeaceOut_M.UpdateLabel()
	end
end

function PeaceOut_M.UpdateLabel()
	-- Clean up the label setting a bit
	-- if PO_Status == 1 then 
	-- 	LabelSetText("PeaceOut_MDisplay", GetFormatStringFromTable("Hardcoded", 464, {20 - math.floor(PO_Val)}))
	-- else
	-- 	if towstring("You will finish logging out in " .. 20 - math.floor(PO_Val) .. " seconds.") == GetFormatStringFromTable("Hardcoded", 464, {20 - math.floor(PO_Val)}) then
		LabelSetText("PeaceOut_MDisplay", towstring("" .. 20 - math.floor(PO_Val) .. " seconds left"))
	-- 	else
			-- LabelSetText("PeaceOut_MDisplay", GetFormatStringFromTable("Hardcoded", 464, {20 - math.floor(PO_Val)}))
	-- 	end
	-- end
end

function PeaceOut_M.TickCheck(elapsed)
	-- Basic throttle for updating time left till logout
	if PO_Monitor == true then
		PO_Time = PO_Time - elapsed
		PO_Val = PO_Val + elapsed
		if PO_Time > 0 then return end
		PO_Time = PO_TimeDelay
		
		PO_Tick()

	end
end

function SetupAction(state)

	-- Canceling the logout so bail
	if WindowGetShowing("PeaceOut_M") then return end
	
	-- Hide window and make sure event registers are all good
	WindowSetShowing("MainMenuWindow", false)

	if TickIsReg ~= true then
	RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "PeaceOut_M.TickCheck")
	end
	TickIsReg = true

	-- if PO_UseSlash then UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "PeaceOut_M.SlashCheck") PO_TimeDelay = .1 end
	
	if state == 2 then LabelSetText("PeaceOut_MTitle", L"Exiting Game")
	elseif state == 1 then LabelSetText("PeaceOut_MTitle", L"Logging Out") end
	
	-- Apply the 1st tick
	PO_Status = state
	PO_Tick()
end

-- Basic toggle for slash exit and logout command registration
-- function PeaceOut_M.Slash(input)
-- 	PO_UseSlash = not PO_UseSlash
	
-- 	if WindowGetShowing("PeaceOut_M") then return end
	
-- 	if PO_UseSlash then
-- 		RegisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "PeaceOut_M.SlashCheck")
-- 		PO_TimeDelay = .8
-- 		EA_ChatWindow.Print(L"PeaceOut_M will now use /exit and /logout")
-- 	else
-- 		UnregisterEventHandler(SystemData.Events.UPDATE_PROCESSED, "PeaceOut_M.SlashCheck") 
-- 		PO_TimeDelay = .1
-- 		EA_ChatWindow.Print(L"PeaceOut_M will no longer use /exit and /logout")
-- 	end
-- end

-- Some ultra basic utilities

function PeaceOut_M.LogOut()
	SetupAction(1)
end

function PeaceOut_M.ExitGame()
	SetupAction(2)
end 

function PeaceOut_M.Cancel()
	BroadcastEvent( SystemData.Events.SPELL_CAST_CANCEL )
	--BroadcastEvent( SystemData.Events.LOG_OUT )
end 

function PeaceOut_M.OnRButtonUp()
	EA_Window_ContextMenu.CreateContextMenu( SystemData.ActiveWindow.name)
	local function getCheckboxIconText(state)
    	if state then
    		return L"<icon00057> "
    	else
    		return L"<icon00058> "
    	end
    end

	EA_Window_ContextMenu.AddMenuItem( getCheckboxIconText(PeaceOut_M.settings.sounds.enable)..L"Sounds", 
		function() PeaceOut_M.settings.sounds.enable = not PeaceOut_M.settings.sounds.enable end, false, true )

	EA_Window_ContextMenu.Finalize()
end