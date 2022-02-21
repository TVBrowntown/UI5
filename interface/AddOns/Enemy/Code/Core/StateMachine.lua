local Enemy = Enemy
local EnemyLinkedList = EnemyLinkedList
local g = {}

--------------------------------------------------------------- EnemyTimer class

EnemyTimer = {}
EnemyTimer.__index = EnemyTimer


--
-- key can be null (if not null the existed timer with the same key will be replaced)
-- duration is seconds
-- callback: function (timer, data) - should return true if timer must be removed or false if timer must be reset
-- data will be passed to callback (can be null)
--
function EnemyTimer.New (key, duration, callback, data)
	local obj = {}
	setmetatable (obj, EnemyTimer)

	obj.key = key
	obj.duration = duration
	obj.callback = callback
	obj.data = data

	obj.enabled = true

	if (obj.key) then g.timers:Remove (obj.key) end
	obj.item = g.timers:Add (obj.key, obj)

	obj:Reset ()

	return obj
end


function EnemyTimer:Remove ()
	g.timers:Remove (self.item)
end


function EnemyTimer:Reset ()
	self.timeout = Enemy.time + self.duration
end

function EnemyTimer:_Update ()

	if (Enemy.time >= self.timeout)
	then
		if (self.callback (self, self.data))
		then
			self:Remove ()
		else
			self:Reset ()
		end
	end
end


--------------------------------------------------------------- Main

function Enemy.StateMachineInitialize ()

	Enemy.stateMachine = g
	g.settings = Enemy.Settings
	g.throttle = g.settings.stateMachineThrottle

	g.tasks = EnemyLinkedList.New ()
	g.timers = EnemyLinkedList.New ()

	Enemy.time = 0
	Enemy.date = Enemy.GetCurrentDateInSeconds ()

	Enemy.TriggerEvent ("StateMachineInitialized")
end


--------------------------------------------------------------- tasks
function Enemy.GetTask (name)

	local task_item = g.tasks:Get (name)
	if (task_item == nil) then return nil end

	return task_item.data
end


function Enemy.AddTask (name)

	local task_item = g.tasks:Get (name)
	if (task_item) then return task_item.data end

	local task =
	{
		name = name,
		actions = EnemyLinkedList.New ()
	}

	task_item = g.tasks:Add (name, task)

	return task
end


--
-- Callback should return true for action to be removed or false for action to stay in queue
--
function Enemy.AddTaskAction (name, callback)

	local task = Enemy.AddTask (name)
	task.actions:Add (callback)

	return task
end


function Enemy.RemoveTask (name)

	local task_item = g.tasks:Get (name)
	if (task_item ~= nil)
	then
		g.tasks:Remove (task_item)
	end
end


--------------------------------------------------------------- Update
function Enemy.Update (elapsed)

	if (not Enemy.initialized) then return end

	-- global time
	Enemy.time = Enemy.time + elapsed

	-- global throttle
	g.throttle = g.throttle - elapsed
	if (g.throttle > 0) then return end
	g.throttle = g.settings.stateMachineThrottle

	-- global datetime
	Enemy.today = Enemy.GetCurrentDateInSeconds ()

	-- run all timers
	local timer_item = g.timers.first
	while (timer_item)
	do
		timer_item.data:_Update ()
		timer_item = timer_item.next
	end

	-- run all tasks
	local task_item = g.tasks.first

	while (task_item)
	do


		local task_is_done = true

		local action_item = task_item.data.actions.first

		while (action_item)
		do




			if (action_item.data ())
			then

				task_item.data.actions:Remove (action_item)


			else
				task_is_done = false
				break
			end

			action_item = action_item.next
		end

		if (task_is_done)
		then
			g.tasks:Remove (task_item)
		end

		task_item = task_item.next
	end
end
