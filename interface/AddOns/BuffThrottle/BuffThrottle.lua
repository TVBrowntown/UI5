BuffThrottle = {}

local oldBuffRefresh = nil
local oldBuffClearAll = nil
local oldBuffShutdown = nil
local curTimeCount = 0

local DelayedRefreshQueue = {}

local eventRatioTracker = { {eventCount = 0, permittedCount = 0} }
local lastEventReset = 0

BuffRefreshDelay = 0.5

local function print(val)
    EA_ChatWindow.Print(towstring(val))
end

function BuffThrottle.GetQueueSize()
    return #DelayedRefreshQueue
end

function BuffThrottle.GetSeg(seg)
    return eventRatioTracker[seg or 1]
end

function BuffThrottle.Ratio(seg)
    local permittedCount = 0
    local eventCount = 0
    if seg then
        permittedCount = eventRatioTracker[seg].permittedCount
        eventCount = eventRatioTracker[seg].eventCount
    else
        for k,v in ipairs(eventRatioTracker) do
            permittedCount = permittedCount + v.permittedCount
            eventCount = eventCount + v.eventCount
        end
    end
    local ratio = (eventCount > 0) and permittedCount / eventCount or 0
    ratio = string.format("%1.3f", ratio)
    print("Update throttling ratio for last "..#eventRatioTracker.." minutes: "..ratio)
end

function BuffThrottle.Verify()
    local status = ""
    
    if BuffTracker.Refresh ~= BuffThrottle.RefreshHookHandler then
        print("Anomaly - BuffTracker.Refresh is not set to direct BuffThrottle control.")
        status = status.."R"
    else status = status.."r" end
    
    if BuffTracker.ClearAllBuffs ~= BuffThrottle.ClearAllHookHandler then
        print("Anomaly - BuffTracker.Refresh is not set to direct BuffThrottle control.")
        status = status.."C"
    else status = status.."c" end
    
    if BuffTracker.Shutdown ~= BuffThrottle.ShutdownHookHandler then
        print("Anomaly - BuffTracker.Refresh is not set to direct BuffThrottle control.")
        status = status.."S"
    else status = status.."s" end
    
    if status == "rcs" then
        print("BuffThrottle hooks are all properly activated, with a BuffRefreshDelay of "..BuffRefreshDelay.." seconds.")
    else
        print("At least one BuffThrottle hook may not be properly set. Please inform Aiiane (status code: "..status..").")
    end
    
end

function BuffThrottle.Initialize()
    oldBuffRefresh = BuffTracker.Refresh
    BuffTracker.Refresh = BuffThrottle.RefreshHookHandler
    oldBuffClearAll = BuffTracker.ClearAllBuffs
    BuffTracker.ClearAllBuffs = BuffThrottle.ClearAllHookHandler
    oldBuffShutdown = BuffTracker.Shutdown
    BuffTracker.Shutdown = BuffThrottle.ShutdownHookHandler
    d("BuffThrottle loaded.")
end

function BuffThrottle.OnUpdate(timePassed)
    curTimeCount = curTimeCount + timePassed
    
    -- move to a new time slice every minute
    if lastEventReset < curTimeCount then
        table.insert(eventRatioTracker, 1, {eventCount = 0, permittedCount = 0})
        if #eventRatioTracker > 5 then
            -- only store 5 time slices max
            table.remove(eventRatioTracker)
        end
        lastEventReset = curTimeCount + 60
    end
    
    for k,v in ipairs(DelayedRefreshQueue) do
        if v.LastUpdateTime + BuffRefreshDelay <= curTimeCount then
            v.LastUpdateTime = curTimeCount
            if not v.LastUpdateType or v.LastUpdateClear == false then
                oldBuffRefresh(v)
                v.lastEventClear = false
            else
                oldBuffClearAll(v)
                v.LastUpdateClear = false
                v.lastEventClear = true
            end
            table.remove(DelayedRefreshQueue, k)
            v.refreshqueued = false
        else
            -- optimization: only look through the list up to the oldest non-ready-for-refresh buff item
            -- (this might in some cases make it take up to 2xBuffRefreshDelay to update, but it's better than iterating the whole list all the time)
            break
        end
    end
end

function BuffThrottle.RefreshHookHandler(self)
    eventRatioTracker[1].eventCount = eventRatioTracker[1].eventCount + 1
    if not self.LastUpdateTime then
        self.LastUpdateTime = curTimeCount
        oldBuffRefresh(self)
        eventRatioTracker[1].permittedCount = eventRatioTracker[1].permittedCount + 1
        self.lastEventClear = false
    elseif self.LastUpdateTime + BuffRefreshDelay <= curTimeCount and self.LastUpdateClear then
        self.LastUpdateTime = curTimeCount
        if not self.lastEventClear then
            oldBuffClearAll(self)
            self.lastEventClear = true
            eventRatioTracker[1].permittedCount = eventRatioTracker[1].permittedCount + 1
        end
        self.LastUpdateClear = false
    elseif self.LastUpdateTime + BuffRefreshDelay <= curTimeCount then
        self.LastUpdateTime = curTimeCount
        oldBuffRefresh(self)
        eventRatioTracker[1].permittedCount = eventRatioTracker[1].permittedCount + 1
        self.lastEventClear = false
    elseif not self.refreshqueued then
        table.insert(DelayedRefreshQueue, self)
        self.refreshqueued = true
    end
end

function BuffThrottle.ClearAllHookHandler(self)
    eventRatioTracker[1].eventCount = eventRatioTracker[1].eventCount + 1
    for k,v in ipairs(DelayedRefreshQueue) do
        if v == self then
            table.remove(DelayedRefreshQueue, k)
            self.refreshqueued = false
            break
        end
    end
    oldBuffClearAll(self)
    self.lastEventClear = true
    eventRatioTracker[1].permittedCount = eventRatioTracker[1].permittedCount + 1
end

function BuffThrottle.ShutdownHookHandler(self)
    eventRatioTracker[1].eventCount = eventRatioTracker[1].eventCount + 1
    for k,v in ipairs(DelayedRefreshQueue) do
        if v == self then
            table.remove(DelayedRefreshQueue, k)
            self.refreshqueued = false
            break
        end
    end
    oldBuffShutdown(self)
    eventRatioTracker[1].permittedCount = eventRatioTracker[1].permittedCount + 1
end
