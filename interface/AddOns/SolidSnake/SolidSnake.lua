SolidSnake = {}

function SolidSnake.OnInit()
	RegisterEventHandler(SystemData.Events.ENTER_WORLD, "SolidSnake.Shh")
	RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED, "SolidSnake.Shh")
	RegisterEventHandler(SystemData.Events.LOADING_END, "SolidSnake.Shh")
end

function SolidSnake.Shh()
	Sound.BUTTON_CLICK = 0
end