local Enemy = Enemy
local g = {}

function Enemy.IntercomInitialize ()

	Enemy.intercom = g
	g.queue = {}


	-- UI
	CreateWindow ("EnemyIntercomDialog", false)
	LabelSetText ("EnemyIntercomDialogTitleBarText", L"Enemy intercom channel")
	ButtonSetText ("EnemyIntercomDialogCancelButton", L"Close")
	LabelSetText ("EnemyIntercomDialogCreateText5", L"Join Guild intercom channel?\n(Requires guild officer chat permissions)")
	ButtonSetText ("EnemyIntercomDialogCreateButton5", L"Guild")
	LabelSetText ("EnemyIntercomDialogCreateText6", L"Join Party intercom channel?")
	ButtonSetText ("EnemyIntercomDialogCreateButton6", L"Party")
	LabelSetText ("EnemyIntercomDialogCreateText7", L"Join Scenario Party intercom channel?")
	ButtonSetText ("EnemyIntercomDialogCreateButton7", L"Scenario Party")
		LabelSetText ("EnemyIntercomDialogCreateText4", L"Join Warband intercom channel?")
ButtonSetText ("EnemyIntercomDialogCreateButton4", L"Warband")
	LabelSetText ("EnemyIntercomDialogCreateText3", L"Join Scenario intercom channel?")
ButtonSetText ("EnemyIntercomDialogCreateButton3", L"Scenario")
LabelSetText ("EnemyIntercomDialogCreateText2", L"Join Alliance  intercom channel?")
ButtonSetText ("EnemyIntercomDialogCreateButton2", L"Alliance")
LabelSetText ("EnemyIntercomDialogCreateText", L"Leave current intercom channel?")
ButtonSetText ("EnemyIntercomDialogCreateButton", L"Leave")
LabelSetText ("EnemyIntercomDialogMessage", L"You're currently not in any intercom channel")
	--LabelSetText ("EnemyIntercomDialogAskText", L"Ask for existing intercom channel?")
	--ButtonSetText ("EnemyIntercomDialogAskButton", L"Ask")
	--LabelSetText ("EnemyIntercomDialogAskText", L"Ask for existing intercom channel?")
	--ButtonSetText ("EnemyIntercomDialogAskButton", L"Ask")
	LabelSetText ("EnemyIntercomDialogInviteText", L"Invite others to intercom channel?")
	ButtonSetText ("EnemyIntercomDialogInviteButton", L"Invite")

	CreateWindow ("EnemyChooseChannelDialog", false)
	LabelSetText ("EnemyChooseChannelDialogTitleBarText", L"Select chat")
	LabelSetText ("EnemyChooseChannelDialogTellDetailsText", L"Name")

	CreateWindow ("EnemyIntercomJoinDialog", false)
	LabelSetText ("EnemyIntercomJoinDialogTitleBarText", L"Available intercoms")
	ButtonSetText ("EnemyIntercomJoinDialogOkButton", L"Join")

	-- setup chat listening filters
	Enemy.chatFilters[SystemData.ChatLogFilters.SCENARIO] = true
	Enemy.chatFilters[SystemData.ChatLogFilters.SCENARIO_GROUPS] = true
	Enemy.chatFilters[SystemData.ChatLogFilters.GROUP] = true
	Enemy.chatFilters[SystemData.ChatLogFilters.BATTLEGROUP] = true
	--Enemy.chatFilters[SystemData.ChatLogFilters.SAY] = true
	--Enemy.chatFilters[SystemData.ChatLogFilters.SHOUT] = true
	--Enemy.chatFilters[SystemData.ChatLogFilters.CHANNEL_1] = true
	Enemy.chatFilters[SystemData.ChatLogFilters.TELL_RECEIVE] = true
	--Enemy.chatFilters[SystemData.ChatLogFilters.GUILD] = true
	Enemy.chatFilters[SystemData.ChatLogFilters.ALLIANCE] = true
	Enemy.chatFilters[SystemData.ChatLogFilters.GUILD_OFFICER] = true
	--Enemy.chatFilters[SystemData.ChatLogFilters.CHANNEL_9] = true
	--Enemy.chatFilters[SystemData.ChatLogFilters.ALLIANCE_OFFICER] = true

	-- private channels
	--g.privateChannels = {}
	--g.privateChannels[SystemData.ChatLogFilters.GROUP] = true
	--g.privateChannels[SystemData.ChatLogFilters.BATTLEGROUP] = true
  --g.privateChannels[SystemData.ChatLogFilters.GUILD] = true
	--g.privateChannels[SystemData.ChatLogFilters.ALLIANCE] = true


	-- FDO
--	local channel, channel_id = Enemy.FindCustomChannel ("addontest")
--	Enemy.chatFilters[channel_id] = true

	-- events
	Enemy.AddEventHandler ("Intercom", "ChatTextArrived", Enemy.Intercom_OnChatTextArrived)
	Enemy.AddEventHandler ("Intercom", "BroadcastMessageAsk", Enemy.Intercom_OnBroadcastMessageAsk)
	Enemy.AddEventHandler ("Intercom", "BroadcastMessageInvite", Enemy.Intercom_OnBroadcastMessageInvite)
	Enemy.AddEventHandler ("Intercom", "IconLButtonUp", Enemy.IntercomUI_IntercomDialog_Open)

	Enemy.AddEventHandler ("Intercom", "IconCreateContextMenu", function (data)
		if (Enemy.CanSendIntercomMessage ())
		then
			table.insert (data,
				{
					text = L"Leave intercom channel '"..g.name..L"'",
					callback = Enemy.OnLeaveButton
				})

			table.insert (data,
				{
					text = L"Invite others to your intercom channel",
					callback = Enemy.IntercomUI_IntercomDialog_OnInviteButton
				})
		else
			table.insert (data,
				{
					text = L"Join Party intercom channel",
					callback = Enemy.IntercomUI_IntercomDialog_OnCreateButton
				})
				table.insert (data,
					{
						text = L"Join Warband intercom channel",
						callback = Enemy.IntercomUI_IntercomDialog_OnCreateButton4
					})
					table.insert (data,
						{
							text = L"Join Guild intercom channel",
							callback = Enemy.IntercomUI_IntercomDialog_OnCreateButton5
						})
						table.insert (data,
							{
								text = L"Join Alliance intercom channel",
								callback = Enemy.IntercomUI_IntercomDialog_OnCreateButton2
							})
					table.insert (data,
						{
					text = L"Join Scenario intercom channel",
					callback = Enemy.IntercomUI_IntercomDialog_OnCreateButton3
				})
					table.insert (data,
			{
				text = L"Join Scenario party intercom channel",
				callback = Enemy.IntercomUI_IntercomDialog_OnCreateButton7
			})
		end
	end)

	Enemy.AddEventHandler ("Intercom", "IconCreateTooltip", function (data)

		if (Enemy.CanSendIntercomMessage ())
		then
			table.insert (data, L"You're currently in '"..g.name..L"' intercom channel.")
		else
			table.insert (data, L"You're currently not in any intercom channel.")
		end

		table.insert (data, L"Left-click to open intercom channel dialog.")
	end)

	Enemy.AddEventHandler ("Intercom", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections,
		{
			name = "Intercom",
			title = L"Intercom channel",
			templateName = "EnemyIntercomConfiguration",
			onInitialize = Enemy.IntercomUI_ConfigDialog_OnInitialize,
			onLoad = Enemy.IntercomUI_ConfigDialog_OnLoad,
			onSave = Enemy.IntercomUI_ConfigDialog_OnSave
		})
	end)

	Enemy.TriggerEvent ("IntercomInitialized")
end

function Enemy.Intercom_OnChatTextArrived (t, from, text)

	if (t == g.channelId)
	then
		local data = Enemy.Split (text, L":")

		if (data[1] ~= L"Target" or #data < 2) then return end
		local command = data[2]

		Enemy.TriggerEvent ("IntercomMessage"..Enemy.toString (command), from, unpack (data, 3))
	else
		local data = Enemy.Split (text, L":")

		if (data[1] ~= L"Target" or #data < 2) then return end
		local command = data[2]

		Enemy.TriggerEvent ("BroadcastMessage"..Enemy.toString (command), t, from, unpack (data, 3))
	end
end

--function Enemy.Intercom_OnBroadcastMessageAsk (channel, from)
--	if (from ~= Enemy.playerName and Enemy.CanSendIntercomMessage ())
--	then
--				Enemy.IntercomInvite (L"/t "..from)
--	end
--end

function Enemy.Intercom_OnBroadcastMessageInvite (channel, from, intercomName)
	if (intercomName ~= nil and intercomName ~= L"" and intercomName ~= g.name and from ~= Enemy.playerName)
	then
		Enemy.IntercomUI_IntercomJoinDialog_AddGroup (intercomName)
	end
end

function Enemy.IntercomJoin (name)
	g.name = name
	Enemy.JoinChannel (g.name,
		function (name, channel, channelId)

			g.name = name
			g.channel = channel
			g.channelId = channelId
			g.isReady = true
			Enemy.chatFilters[g.channelId] = true
			Enemy.Settings.lastIntercomName = name

			Enemy.HideChannel (g.channelId)
			Enemy.UI_Icon_Switch (true)
		end
	)
end

--function Enemy.IntercomCreate ()
--	Enemy.IntercomJoin (Enemy.playerName)
--end

function Enemy.IntercomLeave ()
	if (g.name)
	then
		Enemy.LeaveChannel (g.name,
			function ()

				Enemy.chatFilters[g.channelId] = nil
				g.name = nil
				g.channel = nil
				g.channelId = nil
				g.isReady = false
				Enemy.Settings.lastIntercomName = nil

				Enemy.UI_Icon_Switch (false)
			end
		)
	end
end

function Enemy.CanSendIntercomMessage ()
	return (g.isReady == true)
end

function Enemy.IntercomSendMessage (key, text)

	if (not Enemy.CanSendIntercomMessage ()) then return end

	g.queue[key] =
	{
		key = key,
		text = text,
		t = Enemy.time
	}

	local task_name = "intercom "..Enemy.toString (key)
	if (Enemy.GetTask (task_name) ~= nil) then return end

	Enemy.AddTaskAction (task_name,
		function ()

			local q = g.queue[key]

			-- abort if intercom not ready
			if (q == nil or not Enemy.CanSendIntercomMessage ()) then return true end

			-- wait if can't send chat message
			if (not Enemy.CanSendChatMessage ()) then return false end

			-- sending
			local text = q.text
			if (type (text) == "function") then text = text () end

			text = Enemy.toWString (g.channel)..L" "..Enemy.toWString (text)

			Enemy.SendChatMessage (text)
			g.queue[key] = nil

			return true
		end
	)
end

function Enemy.IntercomInvite (channel)

			Enemy.SendChatMessage (channel..L" Target:Invite:"..g.name)
end

--function Enemy.IntercomAsk (channel)
--	Enemy.SendChatMessage (channel..L" EnemyAddon:Ask")
--end


--------------------------------------------------------------- UI: Intercom dialog
function Enemy.IntercomUI_IntercomDialog_Open ()

	WindowSetShowing ("EnemyIntercomDialog", true)
	WindowAssignFocus ("EnemyIntercomDialog", true)

	if (Enemy.CanSendIntercomMessage ())
	then
			LabelSetText ("EnemyIntercomDialogMessage", L"You're currently in '"..g.name..L"' intercom channel")
		ButtonSetDisabledFlag ("EnemyIntercomDialogCreateButton", false)
		ButtonSetDisabledFlag ("EnemyIntercomDialogInviteButton", false)
		ButtonSetDisabledFlag ("EnemyIntercomDialogAskButton", true)
	else
	LabelSetText ("EnemyIntercomDialogMessage", L"You're currently not in any intercom channel")
	ButtonSetDisabledFlag ("EnemyIntercomDialogCreateButton", true)
	ButtonSetDisabledFlag ("EnemyIntercomDialogInviteButton", true)
	ButtonSetDisabledFlag ("EnemyIntercomDialogAskButton", false)




			LabelSetText ("EnemyIntercomDialogCreateText5", L"Join Guild intercom channel?\n(Requires guild officer chat permissions)")
			ButtonSetText ("EnemyIntercomDialogCreateButton5", L"Guild")


			LabelSetText ("EnemyIntercomDialogCreateText6", L"Join Party intercom channel?")
			ButtonSetText ("EnemyIntercomDialogCreateButton6", L"Party")

			LabelSetText ("EnemyIntercomDialogCreateText7", L"Join Scenario Party intercom channel?")
			ButtonSetText ("EnemyIntercomDialogCreateButton7", L"Scenario Party")

				LabelSetText ("EnemyIntercomDialogCreateText4", L"Join Warband intercom channel?")
		ButtonSetText ("EnemyIntercomDialogCreateButton4", L"Warband")

			LabelSetText ("EnemyIntercomDialogCreateText3", L"Join Scenario intercom channel?")
		ButtonSetText ("EnemyIntercomDialogCreateButton3", L"Scenario")


		LabelSetText ("EnemyIntercomDialogCreateText2", L"Join Alliance  intercom channel?")
		ButtonSetText ("EnemyIntercomDialogCreateButton2", L"Alliance")

		LabelSetText ("EnemyIntercomDialogCreateText", L"Leave current intercom channel?")
		ButtonSetText ("EnemyIntercomDialogCreateButton", L"Leave")

		LabelSetText ("EnemyIntercomDialogMessage", L"You're currently not in any intercom channel")

	end
end

function Enemy.IntercomUI_IntercomDialog_Hide ()
	WindowSetShowing ("EnemyIntercomDialog", false)
end

function Enemy.OnLeaveButton ()
Enemy.IntercomLeave ()
Enemy.IntercomUI_IntercomDialog_Hide ()

end

function Enemy.IntercomUI_IntercomDialog_OnCreateButton ()



	Enemy.SendChatMessage (L"/script Enemy.IntercomJoin \(L\"party\"\) ");

	Enemy.IntercomUI_IntercomDialog_Hide ()
end

function Enemy.IntercomUI_IntercomDialog_OnCreateButton2 ()


	Enemy.SendChatMessage (L"/script Enemy.IntercomJoin \(L\"alliance\"\) ");

	Enemy.IntercomUI_IntercomDialog_Hide ()
end

function Enemy.IntercomUI_IntercomDialog_OnCreateButton4 ()

	Enemy.SendChatMessage (L"/script Enemy.IntercomJoin \(L\"warband\"\) ");

	Enemy.IntercomUI_IntercomDialog_Hide ()
end

function Enemy.IntercomUI_IntercomDialog_OnCreateButton3 ()

	Enemy.SendChatMessage (L"/script Enemy.IntercomJoin \(L\"scenario\"\) ");

	Enemy.IntercomUI_IntercomDialog_Hide ()
end

function Enemy.IntercomUI_IntercomDialog_OnCreateButton5 ()


	Enemy.SendChatMessage (L"/script Enemy.IntercomJoin \(L\"officer\"\) ");

	Enemy.IntercomUI_IntercomDialog_Hide ()
end


function Enemy.IntercomUI_IntercomDialog_OnCreateButton7 ()

	Enemy.SendChatMessage (L"/script Enemy.IntercomJoin \(L\"Scenario party\"\) ");


	Enemy.IntercomUI_IntercomDialog_Hide ()
end

function Enemy.IntercomUI_IntercomDialog_OnAskButton ()
	Enemy.IntercomUI_IntercomDialog_Hide ()

	Enemy.IntercomUI_ChooseChannelDialog_Open (L"Ask", function (result)
		if (result ~= nil)
		then
			Enemy.IntercomAsk (result)
		end
	end)
end

function Enemy.IntercomUI_IntercomDialog_OnInviteButton ()

	Enemy.IntercomUI_ChooseChannelDialog_Open (L"Invite", function (result)
		if (result ~= nil)
		then
			Enemy.IntercomInvite (result)
		end
	end)
end

function Enemy.IntercomUI_IntercomDialog_OnLeaveButton ()
	if (ButtonGetDisabledFlag ("EnemyIntercomDialogLeaveButton")) then return end
	Enemy.IntercomUI_IntercomDialog_Hide ()
end


--------------------------------------------------------------- UI: Choose channel dialog
local chooseChannelDlg

function Enemy.IntercomUI_ChooseChannelDialog_Open (okButtonText, callback)

	ComboBoxClearMenuItems ("EnemyChooseChannelDialogChannelList")
	ButtonSetText ("EnemyChooseChannelDialogOkButton", okButtonText or L"Ok")

	chooseChannelDlg =
	{
		result = nil,
		list = {},
		callback = callback
	}

--	table.insert (chooseChannelDlg.list, L"3")
--	ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"3")

	--if (Enemy.groups.groupType ~= Enemy.GroupTypes.Solo)
	--then
		--table.insert (chooseChannelDlg.list, L"p")
		--ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Party")
	--end

	if  (g.name == L"scenario")
	then
		table.insert (chooseChannelDlg.list, L"sc")
		ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Scenario")
	end

	if  (g.name == L"Scenario party")
	then
		table.insert (chooseChannelDlg.list, L"sp")
		ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Scenario party")
	end

if  (g.name == L"warband")
	then
	table.insert (chooseChannelDlg.list, L"war")
	ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Warband")
	end

 if  (g.name == L"party")
 then
	table.insert (chooseChannelDlg.list, L"p")
	ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Party")
	end

	--table.insert (chooseChannelDlg.list, L"sh")
	--ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Shout")

	--table.insert (chooseChannelDlg.list, L"1")
	--ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Region")

	--table.insert (chooseChannelDlg.list, L"t")
	--ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Tell")

  if  (g.name == L"officer")
	then
 	table.insert (chooseChannelDlg.list, L"o")
	ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Guild")
	end

	if  (g.name == L"alliance")
	then
	table.insert (chooseChannelDlg.list, L"a")
	ComboBoxAddMenuItem ("EnemyChooseChannelDialogChannelList", L"Alliance")
	end
	WindowSetShowing ("EnemyChooseChannelDialogTellDetails", false)
	ComboBoxSetSelectedMenuItem ("EnemyChooseChannelDialogChannelList", 1)
	WindowSetShowing ("EnemyChooseChannelDialog", true)
	WindowAssignFocus ("EnemyChooseChannelDialog", true)
end

function Enemy.IntercomUI_ChooseChannelDialog_Hide ()
	if (chooseChannelDlg.callback) then chooseChannelDlg.callback (chooseChannelDlg.result) end
	WindowSetShowing ("EnemyChooseChannelDialog", false)
end

function Enemy.IntercomUI_ChooseChannelDialog_ChannelListChanged ()
	local ch = chooseChannelDlg.list[ComboBoxGetSelectedMenuItem ("EnemyChooseChannelDialogChannelList")]

	if (ch == L"t")
	then
		WindowSetShowing ("EnemyChooseChannelDialogTellDetails", true)
	else
		WindowSetShowing ("EnemyChooseChannelDialogTellDetails", false)
	end
end

function Enemy.IntercomUI_ChooseChannelDialog_OnOkButton ()
	local ch = chooseChannelDlg.list[ComboBoxGetSelectedMenuItem ("EnemyChooseChannelDialogChannelList")]

	if (ch == L"t")
	then
		local name = TextEditBoxGetText ("EnemyChooseChannelDialogTellDetailsName")
		if (name == nil or name == L"") then return end

		chooseChannelDlg.result = L"/"..ch..L" "..name
	else
		chooseChannelDlg.result = L"/"..ch
	end

	Enemy.IntercomUI_ChooseChannelDialog_Hide ()
end



--------------------------------------------------------------- UI: Intercom join dialog
local joinIntercomDlg

function Enemy.IntercomUI_IntercomJoinDialog_Open ()

	ComboBoxClearMenuItems ("EnemyIntercomJoinDialogGroupList")

	joinIntercomDlg =
	{
		list = {},
		hash = {}
	}

	WindowSetShowing ("EnemyIntercomJoinDialog", true)
	WindowAssignFocus ("EnemyIntercomJoinDialog", true)
end

function Enemy.IntercomUI_IntercomJoinDialog_AddGroup (name)

	if (not WindowGetShowing ("EnemyIntercomJoinDialog"))
	then
		Enemy.IntercomUI_IntercomJoinDialog_Open ()
	end

	if (joinIntercomDlg.hash[name]) then return end

	joinIntercomDlg.hash[name] = name
	table.insert (joinIntercomDlg.list, name)

	ComboBoxAddMenuItem ("EnemyIntercomJoinDialogGroupList", name)

	if (ComboBoxGetSelectedMenuItem ("EnemyIntercomJoinDialogGroupList") < 1)
	then
		ComboBoxSetSelectedMenuItem ("EnemyIntercomJoinDialogGroupList", 1)
	end
end

function Enemy.IntercomUI_IntercomJoinDialog_Hide ()
	WindowSetShowing ("EnemyIntercomJoinDialog", false)
end

function Enemy.IntercomUI_IntercomJoinDialog_OnOkButton ()

	local index = ComboBoxGetSelectedMenuItem ("EnemyIntercomJoinDialogGroupList")
	if (index < 1) then return end

	local group = joinIntercomDlg.list[index]
	if (group == nil) then return end

	Enemy.IntercomJoin (group)
	Enemy.IntercomUI_IntercomJoinDialog_Hide ()
end


--------------------------------------------------------------- UI: Configuration
local config_dlg = {}


function Enemy.IntercomUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section

	LabelSetText (config_dlg.section.windowName.."PrivateLabel", L"WARNING!")
	LabelSetText (config_dlg.section.windowName.."PrivateLabel2", L"Usage of guild intercom requires relevant officer chat permissions!")
	end


function Enemy.IntercomUI_ConfigDialog_OnLoad (section)

  config_dlg.intercomPrivate = Enemy.Settings.intercomPrivate

	ButtonSetPressedFlag (config_dlg.section.windowName.."Private", config_dlg.intercomPrivate)
end


function Enemy.IntercomUI_ConfigDialog_OnPrivateChanged ()
	config_dlg.intercomPrivate = not config_dlg.intercomPrivate
	ButtonSetPressedFlag (config_dlg.section.windowName.."Private", config_dlg.intercomPrivate)
end


function Enemy.IntercomUI_ConfigDialog_OnSave (section)

	Enemy.Settings.intercomPrivate = config_dlg.intercomPrivate

	return true
end
