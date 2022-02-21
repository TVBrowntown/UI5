local Enemy = Enemy
local pairs = pairs
local g = {}

local mfloor = math.floor

--------------------------------------------------------------- EnemyObjectWindow class
EnemyObjectWindow = {}
EnemyObjectWindow.__index = EnemyObjectWindow


-- data:
--
--	windowName 					window name
--	id 							world object id
--	playerName					[optional] player name (if world object is player)
--	data						[optional] any data to store with the item
--	removeCallback				[optional] function (item), usually: function (item) DestroyWindow (item.name) end"
--	activeChangedCallback		[optional] function (item), usually: none
--	timeout						[optional] timeout for became inactive (seconds). If -1 then disables deactivation.
--	inactiveTimeout				[optional] timeout for inactive state before being removed (seconds). If -1 then disables removing.
--
function EnemyObjectWindow.New (data)
	local obj = {}
	setmetatable (obj, EnemyObjectWindow)
	
	obj.windowName = data.windowName
	obj.id = data.id
	obj.playerName = Enemy.FixString (data.playerName)
		
	obj.data = data.data or {}
		
	obj.removeCallback = data.removeCallback
	obj.activeChangedCallback = data.activeChangedCallback
		
	obj.t = Enemy.time
	obj.timeout = data.timeout or Enemy.Settings.objectWindowsTimeout
	obj.inactiveTimeout = data.inactiveTimeout or Enemy.Settings.objectWindowsInactiveTimeout
	
	if (data.id == GameData.Player.worldObjNum)
	then
		obj.timeout = -1
		obj.inactiveTimeout = -1
	end
	
	obj.oldScale = WindowGetScale (obj.windowName)
	obj.isActive = true
	obj.isMoving = true
	
	g.windows[obj.windowName] = obj
	
	if (obj.playerName)
	then
		local windows = g.windowsByPlayerName[obj.playerName]
	
		if (not windows)
		then
			windows = {}
			g.windowsByPlayerName[obj.playerName] = windows
		end
		
		windows[obj.windowName] = obj
	end
	
	obj.isAttached = false
	obj:Attach ()
	
	return obj
end


function EnemyObjectWindow:Detach (silent)

	if (not self.windowName or not self.id) then return end

	local was_attached = self.isAttached
	self.isAttached = false
	
	DetachWindowFromWorldObject (self.windowName, self.id)
	
	if (not silent and self.playerName and was_attached)
	then
		Enemy.TriggerEvent ("PlayerObjectWindowsChanged", self.playerName, self)
	end
end


function EnemyObjectWindow:Attach ()

	if (not self.windowName or not self.id) then return end

	self:Detach (true)
	
	local was_attached = self.isAttached
	self.isAttached = true
	
	AttachWindowToWorldObject (self.windowName, self.id)
	
	if (self.playerName and not was_attached)
	then
		Enemy.TriggerEvent ("PlayerObjectWindowsChanged", self.playerName, self)
	end
end


function EnemyObjectWindow:Remove ()

	local was_attached = self.isAttached
	
	self:Detach (true)
	g.windows[self.windowName] = nil
	
	if (self.playerName)
	then
		local windows = g.windowsByPlayerName[self.playerName]
		if (not windows) then return end
		windows[self.windowName] = nil
	end
	
	if (self.removeCallback) then self.removeCallback (self) end
	
	if (self.playerName and was_attached)
	then
		Enemy.TriggerEvent ("PlayerObjectWindowsChanged", self.playerName, self)
	end
end


function EnemyObjectWindow:Deactivate ()

	if (not self.isActive) then return end
	
	self.isActive = false
	self.t = Enemy.time
	
	-- Mythic made yet another stupid fix and now you can't just hide window that attached to 3d object
	self.oldScale = WindowGetScale (self.windowName)
	WindowSetScale (self.windowName, 0.000001)
	WindowSetShowing (self.windowName, false)
	
	if (self.activeChangedCallback) then self.activeChangedCallback (self) end
end


function EnemyObjectWindow:Activate ()

	if (self.isActive) then return end
	
	self.isActive = true
	self.t = Enemy.time

	WindowSetScale (self.windowName, self.oldScale)
	WindowSetShowing (self.windowName, true)
	
	if (self.activeChangedCallback) then self.activeChangedCallback (self) end
end


function EnemyObjectWindow:_Check ()

	local remove = false

	local x, y = WindowGetScreenPosition (self.windowName)
	x = mfloor (x)
	y = mfloor (y)
	
	if (self.x ~= x or self.y ~= y)
	then
		-- screen position changed
		self.isMoving = true
		
		if (not self.isActive)
		then
			-- we were inactive and now moved - that means that our world object is still on the screen
			-- and we need to active ourself
			
			self:Activate ()
		end
		
		self.x = x
		self.y = y
		self.t = Enemy.time
	else
		-- screen position is not changed
		self.isMoving = false
		
		if (self.isActive and self.timeout ~= -1 and Enemy.time - self.t >= self.timeout)
		then
			-- switch to inactive mode
			self:Deactivate ()
		
		elseif (not self.isActive and self.inactiveTimeout ~= -1 and Enemy.time - self.t >= self.inactiveTimeout)
		then
			-- we were too long in inactive mode - remove the window
			remove = true
		end
	end
	
	if (remove)
	then
		self:Remove ()
	end
	
	return remove
end


function EnemyObjectWindow:_CheckPlayerNewId (id)

	if (id == 0)
	then
		if (self.isActive)
		then
			self:Deactivate ()
		end
	else
		if (self.id ~= id)
		then
			-- targeted player world object id have been changed - store new id and reattach window
			self:Detach ()
			self.id = id
			self:Attach ()
		else
			-- update last time seen
			self.t = Enemy.time
		end
		
		if (not self.isActive)
		then
			self:Activate ()
		end
	end
end


--------------------------------------------------------------- Main
function Enemy.ObjectWindowsInitialize ()

	Enemy.objectWindows = g
	g.windows = {}
	g.windowsByPlayerName = {}
	
	if (Enemy.Settings.prevVersion > 0 and Enemy.Settings.prevVersion < 67)
	then
		Enemy.Settings.objectWindowsTimeout = Enemy.DefaultSettings.objectWindowsTimeout
		Enemy.Settings.objectWindowsInactiveTimeout = Enemy.DefaultSettings.objectWindowsInactiveTimeout
	end
	
	Enemy.AddEventHandler ("ObjectWindows", "PlayerTargetUpdated", function (target)
		if (not target.isNpc)
		then
			Enemy._ObjectWindowsCheckPlayerNewId (target.name, target.id)
		end
	end)
	
	Enemy.AddEventHandler ("ObjectWindows", "GroupsPlayerWorldObjectIdUpdated", function (player)
		Enemy._ObjectWindowsCheckPlayerNewId (player.name, player.worldObjectId)
	end)
	
	-- tasks
	Enemy.AddTaskAction ("check object windows", Enemy._ObjectWindowsCheck)
	
	Enemy.TriggerEvent ("ObjectWindowsInitialized")
end


function Enemy.GetObjectWindow (windowName)
	return g.windows[windowName]
end


function Enemy.GetObjectWindowsForPlayer (name)
	return g.windowsByPlayerName[name]
end


function Enemy._ObjectWindowsCheck ()

	for _, object_window in pairs (g.windows)
	do
		object_window:_Check ()
	end
end


function Enemy._ObjectWindowsCheckPlayerNewId (name, id)

	local windows = g.windowsByPlayerName [name]
	if (not windows) then return end
	
	for _, object_window in pairs (windows)
	do
		object_window:_CheckPlayerNewId (id)
	end
end









