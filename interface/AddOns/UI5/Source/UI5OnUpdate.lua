UI5OnUpdate = {}

local x
local y
local px
local py
local throttle = 0

function UI5.OnUpdate(elapsed)
	--[[
			Why? Because for some reason the overhead bar gets stuck sometimes and won't change, 
			even though it is checking... so... what's a guy to do, eh? Heck, this might not
			work either. But it has the good chance of fixing it as its happening.
	]]
	throttle = throttle + elapsed
	if throttle >= 0.33 then
		if DoesWindowExist("UI5_O_HostileFade") and WindowGetAlpha("UI5_O_HostileFade") ~= 1 and WindowGetAlpha("UI5_O_HostileFade") ~= 0 then
			x = WindowGetAlpha("UI5_O_HostileFade")
			if x == px and x ~= 0 then
				-- reset the alpha
				WindowSetAlpha("UI5_O_HostileFade", 0)
				--d("OnUpdate: clear x")
			end
			px = x
		end

		if DoesWindowExist("UI5_O_FriendlyFade") and WindowGetAlpha("UI5_O_FriendlyFade") ~= 1 and WindowGetAlpha("UI5_O_FriendlyFade") ~= 0 then
			y = WindowGetAlpha("UI5_O_FriendlyFade")
			if y == py and y ~= 0 then
				-- reset the alpha
				WindowSetAlpha("UI5_O_FriendlyFade", 0)
				--d("OnUpdate: clear y")
			end
			py = y
		end
		throttle = 0
	end
end