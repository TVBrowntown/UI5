local Enemy = Enemy
local g = {}
local s = {}

local pairs = pairs

function Enemy.TimerInitialize ()
  --d("timer in")
	Enemy.timer = g

  Enemy.stopwatch = s

	g.isActive = false

	-- UI
	CreateWindow ("EnemyTimer", true)
	LayoutEditor.RegisterWindow ("EnemyTimer", L"Enemy timer", L"Enemy timer", false, false, true, nil)

  -- Stopwatch
	CreateWindow ("EnemyStopwatch", true)
	LayoutEditor.RegisterWindow ("EnemyStopwatch", L"Enemy Stopwatch", L"Enemy Stopwatch", false, false, true, nil)

  Enemy.AddEventHandler ("Stopwatch", "Start", Enemy.StopwatchStart)
  Enemy.AddEventHandler ("Stopwatch", "Stop" , Enemy.StopwatchStop)

	-- UI: config
	g.configDlgSection =
	{
		name = "Timer",
		title = L"Timer",
		templateName = "EnemyTimerConfiguration",
		onInitialize = Enemy.TimerUI_ConfigDialog_OnInitialize,
		onLoad = Enemy.TimerUI_ConfigDialog_OnLoad,
		onSave = Enemy.TimerUI_ConfigDialog_OnSave
	}

	-- static events
	Enemy.AddEventHandler ("Timer", "SettingsChanged", Enemy.Timer_OnSettingsChanged)

	Enemy.AddEventHandler ("Timer", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections, g.configDlgSection)
	end)

	Enemy.TriggerEvent ("TimerInitialized")
	Enemy.Timer_Reset()
  Enemy.StopwatchReset()
end



function Enemy.StopwatchButtonClick()
  --d("Stopwatch click")
  s.state = (s.state+1)%2
  if s.state == nil then s.state = 0 end
  if (s.state == 0) then
    Enemy.StopwatchStop()
  else
    Enemy.StopwatchStart()
  end
end

function Enemy.StopwatchStart()
  --d("Stopwatch start")
  s.startTime = Enemy.time
  s.timer = EnemyTimer.New ("EnemyStopwatchUpdate", 0.5, function ()
    s.time = Enemy.time - s.startTime + s.increment
		Enemy.Stopwatch_Update ()
		return false
	end)

end
function Enemy.StopwatchStop()
  --d("Stopwatch stop")
  s.increment = s.time
  s.timer:Remove ()
	s.timer = nil
  Enemy.Stopwatch_Update ()
end

function Enemy.StopwatchReset()
  d("Stopwatch reset")
  --d(g.config_dlg.stopwatchEnabled)
  if s.state == 1 then
    Enemy.StopwatchStop()
  end
  s.state = 0
  s.time = 0
  s.increment = 0
  Enemy.Stopwatch_Update ()
end

function Enemy.StopwatchEnabledChanged(enable)
  if (s.isPluginEnabled == enable) then return end
  WindowSetShowing("EnemyStopwatch", enable)
end

function Enemy._TimerEnabledChanged (enable)
	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable

	if (g.isPluginEnabled)
	then
		Enemy.AddEventHandler ("Timer", "GroupsPlayerInitialized", Enemy.Timer_OnPlayerCombatFlagUpdated)
		Enemy.AddEventHandler ("Timer", "GroupsPlayerCombatUpdated", Enemy.Timer_OnPlayerCombatFlagUpdated)
	else
		Enemy.RemoveEventHandler ("Timer", "GroupsPlayerInitialized")
		Enemy.RemoveEventHandler ("Timer", "GroupsPlayerCombatUpdated")
	end
end


function Enemy.Timer_OnSettingsChanged (settings)
	g.settings = settings
	Enemy._TimerEnabledChanged (g.settings.timerEnabled);
	Enemy.Timer_Update ()
  Enemy.StopwatchEnabledChanged(g.settings.stopwatchEnabled)
  Enemy.Stopwatch_Update()
end


function Enemy.Timer_Reset ()
	g.time = 0
	g.startTime = Enemy.time
	Enemy.Timer_Update ()
end

function Enemy.Timer_OnPlayerCombatFlagUpdated()

	local player = Enemy.groups.player

	if (not g.isPluginEnabled
		or not player
		or g.isActive == player.isInCombat) then return end

	g.isActive = player.isInCombat

	if (g.isActive)
	then
		Enemy.Timer_Reset ()

		g.timer = EnemyTimer.New ("EnemyTimerUpdate", 1,
			function ()

				g.time = Enemy.time - g.startTime
				Enemy.Timer_Update ()

				return false
			end)
	elseif (g.timer)
	then
		g.timer:Remove ()
		g.timer = nil

		Enemy.Timer_Update ()
	end
end


function Enemy.Timer_Update ()

	if (not g.isPluginEnabled) then return end

	local d, h, m, s = Enemy.GetTimeFromSeconds (g.time)
	local str_time = L""

	if (d > 0)
	then
		str_time = str_time..d..L"."
	end

	if (h > 0)
	then
		if (h < 10) then str_time = str_time..L"0"..h else str_time = str_time..h end
		str_time = str_time..L":"
	end

	if (m < 10) then str_time = str_time..L"0"..m else str_time = str_time..m end
	if (s < 10) then str_time = str_time..L":0"..s else str_time = str_time..L":"..s end

	LabelSetText ("EnemyTimerText", str_time)

	if (g.isActive)
	then
		LabelSetTextColor ("EnemyTimerText", unpack (g.settings.timerActiveColor))
	else
		LabelSetTextColor ("EnemyTimerText", unpack (g.settings.timerInactiveColor))
	end
end

function Enemy.Stopwatch_Update ()

  if s.time > 999 then
    Enemy.StopwatchReset()
  else
    local str_time = Enemy.toWString(math.floor(s.time))
    if str_time == L"-1" then str_time = L"0" end
    LabelSetText ("EnemyStopwatchText", str_time)
  end

end


--------------------------------------------------------------- UI: Main window
function Enemy.TimerUI_OnMouseOver ()

	if (not g.isPluginEnabled) then return end

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)

	Tooltips.SetTooltipText (1, 1, L"Combat timer")
	Tooltips.SetTooltipText (2, 1, L"Automatically starts/stop when entering/exiting combat")
	Tooltips.SetTooltipText (3, 1, L"Right click to reset")
	Tooltips.SetTooltipText (4, 1, L"Shift + Right click to open configuration")

	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.TimerUI_OnLButtonUp ()
end


function Enemy.TimerUI_OnRButtonUp (flags)

	if (Enemy.IsShiftPressed (flags))
	then
		Enemy.UI_ConfigDialog_Open ("Timer")
	else
		Enemy.Timer_Reset ()
	end
end


--------------------------------------------------------------- UI: Configuration
local config_dlg = {}

config_dlg.properties =
{
	timerEnabled =
	{
		key = "timerEnabled",
		order = 10,
		name = L"Enable timer window",
		type = "bool",
		default = Enemy.DefaultSettings.timerEnabled
	},
	timerActiveColor =
	{
		key = "timerActiveColor",
		order = 20,
		name = L"Running color",
		type = "color",
		default = Enemy.DefaultSettings.timerActiveColor
	},
	timerInactiveColor =
	{
		key = "timerInactiveColor",
		order = 30,
		name = L"Paused color",
		type = "color",
		default = Enemy.DefaultSettings.timerInactiveColor
	},
  stopwatchEnabled =
	{
		key = "stopwatchEnabled",
		order = 40,
		name = L"Enable stopwatch window",
		type = "bool",
		default = Enemy.DefaultSettings.stopwatchEnabled
	}
}


function Enemy.TimerUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section

	local root = config_dlg.section.windowName.."ContentScrollChild"
	config_dlg.cwn = root.."Config"
	Enemy.CreateConfigurationWindow (config_dlg.cwn, root, config_dlg.properties, Enemy.TimerUI_ConfigDialog_TestSettings)

	ScrollWindowUpdateScrollRect (config_dlg.section.windowName.."Content")
end


function Enemy.TimerUI_ConfigDialog_OnLoad (section)

	config_dlg.isLoading = true

	config_dlg.timerEnabled = Enemy.Settings.timerEnabled
	config_dlg.timerActiveColor = Enemy.clone (Enemy.Settings.timerActiveColor)
	config_dlg.timerInactiveColor = Enemy.clone (Enemy.Settings.timerInactiveColor)
	config_dlg.stopwatchEnabled = Enemy.Settings.stopwatchEnabled

	Enemy.ConfigurationWindowLoadData (config_dlg.cwn, config_dlg)

	config_dlg.isLoading = false

	Enemy.TimerUI_ConfigDialog_TestSettings ()
end



function Enemy.TimerUI_ConfigDialog_OnReset (section)

	for k, v in pairs (Enemy.Settings)
	do
		if (not k:match("^timer.*")) then continue end
		Enemy.Settings[k] = nil
	end

	Enemy.Print ("Timer settings has been reset")
	InterfaceCore.ReloadUI ()
end



function Enemy.TimerUI_ConfigDialog_TestSettings ()

	if (config_dlg.isLoading) then return end

	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, config_dlg)
	Enemy.Timer_OnSettingsChanged (config_dlg)
end


function Enemy.TimerUI_ConfigDialog_OnSave (section)

	Enemy.TimerUI_ConfigDialog_TestSettings ()

	Enemy.Settings.timerEnabled = config_dlg.timerEnabled
	Enemy.Settings.timerActiveColor = Enemy.clone (config_dlg.timerActiveColor)
	Enemy.Settings.timerInactiveColor = Enemy.clone (config_dlg.timerInactiveColor)
  Enemy.Settings.stopwatchEnabled = config_dlg.stopwatchEnabled

	return true
end
