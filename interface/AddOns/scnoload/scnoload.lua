if not scnoload then scnoload = {} end


local firstLoad = true
local oldEA_Window_LoadingScreenOnLoadBegin = nil
local oldScenarioSummaryWindowSetDisplayMode = nil
local oldScenarioSummaryWindowToggleShowing = nil

-- generic print function
local function print(txt)
	EA_ChatWindow.Print(towstring(txt))
end

function scnoload.Initialize()
	RegisterEventHandler(SystemData.Events.LOADING_END, "scnoload.OnLoad")
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "scnoload.OnLoad")
end

function scnoload.OnLoad()
	if firstLoad == true then
		firstLoad = false
		
		if not scnoload.Settings then
			scnoload.Settings = {mode = "sc",oldway=false}
		end
		
		scnoload.setHook()
				
		-- register slash commands with libslash
		LibSlash.RegisterSlashCmd("scnoload", function(input) scnoload.SlashHandler(input) end)
		if not LibSlash.IsSlashCmdRegistered("snl") then
			LibSlash.RegisterSlashCmd("snl", function(input) scnoload.SlashHandler(input) end)
		end

	end
end

-- LibSlash slash handler
function scnoload.SlashHandler(input)
    local opt, val = input:match("([a-z0-9]+)[ ]?(.*)")
	
    -- NO OPTION SPECIFIED
    if not opt or opt == "help" then
	
		print ("\n")
		print ("scnoload slash commands:")
		print ("/snl help - displays this help")
		print ("/snl mode (all/sc)")
		print ("/snl oldway")
		
	elseif opt == "mode" then
		if val ~= "" then
			
			if val == "all" or val == "sc" then
				scnoload.Settings["mode"] = val
				print ("scnoload mode set to " .. val)
			else
				print ("/snl mode - must be \"all\" or \"sc\"")
			end
		else
			print ("scnoload mode is currently set to " .. scnoload.Settings["mode"])
		end
	elseif opt == "oldway" then
		scnoload.Settings["oldway"] = not scnoload.Settings["oldway"]
		print ("scnoload oldway set to " .. tostring(scnoload.Settings["oldway"]))
	end
end

function scnoload.setHook()
	if oldEA_Window_LoadingScreenOnLoadBegin == nil then
		oldEA_Window_LoadingScreenOnLoadBegin = EA_Window_LoadingScreen.OnLoadBegin
		EA_Window_LoadingScreen.OnLoadBegin = scnoload.newEA_Window_LoadingScreenOnLoadBegin
		
		oldScenarioSummaryWindowSetDisplayMode = ScenarioSummaryWindow.SetDisplayMode
		ScenarioSummaryWindow.SetDisplayMode = scnoload.newScenarioSummaryWindowSetDisplayMode
		
		oldScenarioSummaryWindowToggleShowing = ScenarioSummaryWindow.ToggleShowing
		ScenarioSummaryWindow.ToggleShowing = scnoload.newScenarioSummaryWindowToggleShowing
		
		--d("HOOKS SET")
	end
end

function scnoload.newEA_Window_LoadingScreenOnLoadBegin()

	if( GameData.ScenarioData.id ~= 0 or scnoload.Settings.mode == "all") then
		
		local loadingData = LoadingScreenGetCurrentData()
		
		if GameData.Player.zone ~= loadingData.zoneId then
			-- player is changing the zone...
			oldEA_Window_LoadingScreenOnLoadBegin()
		else
			-- skipping... yay!
			if not scnoload.Settings["oldway"] then
				oldEA_Window_LoadingScreenOnLoadBegin()
				WindowSetShowing( "EA_Window_LoadingScreen",false )
				BroadcastEvent( SystemData.Events.ENTER_WORLD )
			else
				BroadcastEvent( SystemData.Events.ENTER_WORLD )
			end
		end
		
		return
		
	end
	
	oldEA_Window_LoadingScreenOnLoadBegin()
end

-- unhide the close button...
function scnoload.newScenarioSummaryWindowSetDisplayMode(mode)
	oldScenarioSummaryWindowSetDisplayMode(mode) -- call the original function
	
	local shouldShow = GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE and ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_POST_MODE

	if shouldShow == true then
		WindowSetShowing( "ScenarioSummaryWindowClose", shouldShow ) 
	end
end

-- ...and re-enable the button functionality :)
function scnoload.newScenarioSummaryWindowToggleShowing()
	oldScenarioSummaryWindowToggleShowing()

    if ( GameData.Player.isInScenario or WindowGetShowing("ScenarioSummaryWindow") ) then
		local shouldShow = GameData.ScenarioData.mode == GameData.ScenarioMode.POST_MODE and ScenarioSummaryWindow.currentMode == ScenarioSummaryWindow.MODE_POST_MODE
        if shouldShow == true then
            WindowUtils.ToggleShowing( "ScenarioSummaryWindow" )
        end
    end
end