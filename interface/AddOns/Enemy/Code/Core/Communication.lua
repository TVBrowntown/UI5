local Enemy = Enemy

function Enemy.CommunicationInitialize ()

	Enemy.chatAdditionalDelay = 0
	Enemy.chatLastTimeSend = -1
	Enemy.chatFilters = {}
	Enemy.chatDelay = 1
	Enemy.chatThrottleDelay = 1


	RegisterEventHandler (SystemData.Events.CHAT_TEXT_ARRIVED, "Enemy.OnChatTextArrived")
	Enemy.TriggerEvent ("CommunicationInitialized")
end

function Enemy.CanSendChatMessage ()
	return (Enemy.time >= Enemy.chatLastTimeSend + Enemy.chatDelay + Enemy.chatAdditionalDelay)
end

function Enemy.SendChatMessage (text)

	--SystemData.UserInput.ChatText = text;
	--BroadcastEvent (SystemData.Events.SEND_CHAT_TEXT);
	SendChatText (text, L"")

	--d(L"SendChatMessage: "..Enemy.toWString (text))

	Enemy.chatLastTimeSend = Enemy.time
	Enemy.chatAdditionalDelay = 0
end

function Enemy.ThrottleChat ()
	Enemy.chatAdditionalDelay = Enemy.chatAdditionalDelay + Enemy.chatThrottleDelay
	end

function Enemy.UnthrottleChat ()

	Enemy.chatAdditionalDelay = Enemy.chatAdditionalDelay - Enemy.chatThrottleDelay

	if (Enemy.chatAdditionalDelay < 0)
	then
		Enemy.chatAdditionalDelay = 0
	end
end

function Enemy.OnChatTextArrived ()

	local chat_type = GameData.ChatData.type
	local chat_filters = SystemData.ChatLogFilters

	local text = Enemy.toWString (GameData.ChatData.text)
	if (text == nil or text == L"") then return end

	if (chat_type == chat_filters.USER_ERROR)
	then
		if (text:find (L"Slow down!"))
		then
			Enemy.ThrottleChat ()
		end
	elseif (Enemy.chatFilters[chat_type] == true)
	then
		Enemy.UnthrottleChat ()
		Enemy.TriggerEvent ("ChatTextArrived", chat_type, Enemy.FixString (GameData.ChatData.name), text)
	end
end

--------------------------------------------------------------- Helpers
function Enemy.FindCustomChannel (name)

local name = Enemy.toWString (name:lower ())

--	local name = L": "..Enemy.toWString (name:lower ())..L"]"

	for k, v in pairs (ChatSettings.Channels)
	do
		if (v.labelText ~= nil)
		then
			local str = Enemy.toWString (v.labelText:lower ())

			if (str:find (name))
			then
			--	d(towstring(v.serverCmd)..L" - "..towstring(k))
						return v.serverCmd, k
			end
		end
	end
	--	return L"/p", 4
    return false, false
end


function Enemy.HideChannel (channelId)
	for _,wndGroup in ipairs (EA_ChatWindowGroups)
	do
		if (wndGroup.used == true)
		then
			for tabId, tab in ipairs (wndGroup.Tabs)
			do
				local tabName = EA_ChatTabManager.GetTabName (tab.tabManagerId)

				if (tabName) then
					if (tab.tabText ~= L"Enemy")
					then
						--LogDisplaySetFilterState (tabName.."TextLog", "Chat", channelId, false)
					else
						-- LogDisplaySetFilterState (tabName.."TextLog", "Chat", channelId, true)
						--LogDisplaySetFilterColor (tabName.."TextLog", "Chat", channelId, 150, 250, 100)
					end
				end
			end
		end
	end
end

function Enemy.JoinChannel (name, callback)

	--d (L"Enemy.JoinChannel: "..Enemy.toWString (name))

	-- send command to join the channel
	--d("communication joinchannel")
	--d(name)
	--name = L"Warband"


	Enemy.AddTaskAction ("channel",
		function ()

			local channel, channelId = Enemy.FindCustomChannel (name)
			--d(channel)
      --d(channelId)
			if (not channel)
			then
				if (not Enemy.CanSendChatMessage ()) then return false end
				Enemy.SendChatMessage (L"/channeljoin "..name);
				--Enemy.SendChatMessage(L"/ra I want to assist: "..name)
			end

			return true
		end
	)

	-- waiting for join the channel
	Enemy.AddTaskAction ("channel",
		function ()

			local channel, channelId = Enemy.FindCustomChannel (name)
			if (channel)
			then
				callback (name, channel, channelId)
				return true
			end

			return false
		end
	)
end

function Enemy.LeaveChannel (name, callback)

	-- send command to leave the channel
	Enemy.AddTaskAction ("channel",
		function (data)

			if (not Enemy.CanSendChatMessage ()) then return false end

			Enemy.SendChatMessage (L"/channelleave "..name)
			callback ()

			return true
		end
	)
end
