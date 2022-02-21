UI5.OnChatLogUpdated = {}

if biccestDmg == nil then biccestDmg = 0 end

function UI5.KillTest()
	local victim, killer = "Wayne", "Ronald"
	AlertTextWindow.AddLine(7, towstring(towstring(victim)..L" was killed by "..towstring(killer)))
end

function UI5.OnChatLogUpdated(updateType, filterType)
	if (updateType ~= SystemData.TextLogUpdate.ADDED) then return end

		if (filterType == SystemData.ChatLogFilters.RVR_KILLS_ORDER or filterType == SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION) and DangerToggle == true then
		
		----------------
		--            --
		--            --
		-- KILL ALERT --
		--            --
		--            --
		----------------
		if KillAlertToggle == true then

			local indexOfLastEntry = TextLogGetNumEntries("Combat") - 1;    
    		local _, _, message = TextLogGetEntry("Combat", indexOfLastEntry);
		
			local victim, verb, killer, weapon, location = message:match(L"([%a]+) has been ([%a]+) by ([%a]+)'s ([%a%d%p  ]+) in ([^%.]+).")
		
			if victim == nil and killer == nil then return end

			if killer == playerName or victim == playerName then
				PlaySound(501)
				AlertTextWindow.AddLine(7, towstring(towstring(victim)..L" was killed by "..towstring(killer)))
			end

		end
		----------------
		--            --
		--            --
		--DANGER LEVEL--
		--            --
		--            --
		----------------
		if DangerToggle == true then
			UI5.DangerLogic()
		end

	elseif filterType == SystemData.ChatLogFilters.YOUR_DMG_FROM_PC or filterType == SystemData.ChatLogFilters.YOUR_DMG_FROM_NPC and extendedAudioToggle == true then
		local indexOfLastEntry = TextLogGetNumEntries("Combat") - 1;    
	    local _, _, message = TextLogGetEntry("Combat", indexOfLastEntry)

		if message:match(L"([^%.]+)'s ([^%.]+) critically hits you for ([^%.]+) damage.") then
			PlaySound(501)
			d("CRITICALLY HIT")
			-- I WAS CRIT
			-- animate an icon flash or something to show you've been crit.
			-- replace current sound with extendedAudio sound.
			--WindowStartAlphaAnimation("PlayerAvatarFlash", Window.AnimationType.SINGLE, 0.2, 0, 1, false, 0, 0)
		end

	elseif filterType == SystemData.ChatLogFilters.YOUR_HITS and extendedAudioToggle == true then

		----------------
		--            --
		--            --
		-- EXTD AUDIO --
		--     AND    --
		--   OVERHUD  --
		--            --
		--            --
		----------------

		local indexOfLastEntry = TextLogGetNumEntries("Combat") - 1;    
	    local _, _, message = TextLogGetEntry("Combat", indexOfLastEntry)

		if message:match(L"Your ([^%.]+) critically hits ([^%.]+) for ([^%.]+) damage.") then

			spellName, targetCritd, dmg = message:match(L"Your ([^%.]+) critically hits ([^%.]+) for ([^%.]+) damage.")
			-- gather the info from the string

			TargetInfo:UpdateFromClient()
			local targetNameCheck = TargetInfo:UnitName("selfhostiletarget")
			-- check our target is same as victim in the string

			if biccestDmg <= tonumber(dmg) then
				biccestDmg = tonumber(dmg)
			end
			-- is this our biggest crit yet?

			if targetNameCheck == targetCritd then
				if DoesWindowExist("UI5_O_Hostile") then
					local critX, critY = WindowGetScreenPosition("UI5_O_Hostile")
					WindowStartPositionAnimation ("UI5_O_Hostile", Window.AnimationType.SINGLE, critX, critY, critX + 5, critY + 5, 0.1, false, 0, 0)
					WindowStartAlphaAnimation("UI5_O_HostileFlash", Window.AnimationType.SINGLE, 0.25, 0, 1, false, 0, 0)
				end
			end
			-- jiggle + flash the overhead window

		elseif message:match(L"Your ([^%.]+) hits ([^%.]+) for ([^%.]+) damage. ([^%.]+) (([^%.]+) absorbed)") then
			-- Your Shrapnel Arrer hits Ziggirus for 0 damage. (265 mitigated) (314 absorbed)

				d("ABSORBED!")
				--UI5.logSoundToPlay(sndAbsorbed)

		elseif message:match(L"([^%.]+) parried your ([^%.]+).") then
			TargetInfo:UpdateFromClient()
			local targetNameCheck = TargetInfo:UnitName("selfhostiletarget")
			local stringName = message:match(L"([^%.]+) parried your ([^%.]+).")
			if WStringToString(targetNameCheck) == WStringToString(stringName) then
			--
				d("PARRIED!")
		    	--UI5.logSoundToPlay(sndParried)

		    end
		elseif message:match(L"([^%.]+) dodged your ([^%.]+).") then
			TargetInfo:UpdateFromClient()
			local targetNameCheck = TargetInfo:UnitName("selfhostiletarget")
			local stringName = message:match(L"([^%.]+) dodged your ([^%.]+).")
			if WStringToString(targetNameCheck) == WStringToString(stringName) then
			--
				d("DODGED!")
		    	--UI5.logSoundToPlay(sndDodged)

	    	end
		elseif message:match(L"([^%.]+) blocked your ([^%.]+).") then
			TargetInfo:UpdateFromClient()
			local targetNameCheck = TargetInfo:UnitName("selfhostiletarget")
			local stringName = message:match(L"([^%.]+) blocked your ([^%.]+).")
			if WStringToString(targetNameCheck) == WStringToString(stringName) then
			--
				d("BLOCKED!")
		    	--UI5.logSoundToPlay(sndBlocked)

	    	end
		elseif message:match(L"([^%.]+) disrupted your ([^%.]+).") then
			TargetInfo:UpdateFromClient()
			local targetNameCheck = TargetInfo:UnitName("selfhostiletarget")
			local stringName = message:match(L"([^%.]+) disrupted your ([^%.]+).")
			if WStringToString(targetNameCheck) == WStringToString(stringName) then
			--
				d("DISRUPTED!")
		    	--UI5.logSoundToPlay(sndDisrupt)

	    	end
		end
	end
end

--[[

501 - chime
220 - dragon

SystemData.Events.ADD_USER_MAP_POINT
SystemData.Events.ALLIANCE_UPDATED
SystemData.Events.ALL_MODULES_INITIALIZED
SystemData.Events.APPLICATION_ONE_BUTTON_DIALOG
SystemData.Events.APPLICATION_REMOVE_DIALOG
SystemData.Events.APPLICATION_TWO_BUTTON_DIALOG
SystemData.Events.AUCTION_BID_RESULT_RECEIVED
SystemData.Events.AUCTION_INIT_RECEIVED
SystemData.Events.AUCTION_SEARCH_RESULT_RECEIVED
SystemData.Events.AUTHENTICATION_ERROR
SystemData.Events.AUTHENTICATION_LOGIN_START
SystemData.Events.AUTHENTICATION_RESPONSE
SystemData.Events.AUTHENTICATION_START
SystemData.Events.AUTOMATED_CHARACTER_CREATE
SystemData.Events.AUTO_LOOT
SystemData.Events.BATTLEGROUP_ACCEPT_INVITATION
SystemData.Events.BATTLEGROUP_DECLINE_INVITATION
SystemData.Events.BATTLEGROUP_MEMBER_UPDATED
SystemData.Events.BATTLEGROUP_UPDATED
SystemData.Events.BEGIN_CREATE_CHARACTER
SystemData.Events.BEGIN_CUSTOMIZE
SystemData.Events.BEGIN_ENTER_CHAT
SystemData.Events.BEGIN_REALM_SELECT
SystemData.Events.BOLSTER_ACCEPT
SystemData.Events.BOLSTER_CANCEL
SystemData.Events.BOLSTER_DECLINE
SystemData.Events.BOLSTER_OFFER
SystemData.Events.BRACKET_CHAT
SystemData.Events.CAMPAIGN_CITY_UPDATED
SystemData.Events.CAMPAIGN_PAIRING_UPDATED
SystemData.Events.CAMPAIGN_ZONE_UPDATED
SystemData.Events.CANCEL_LOGIN
SystemData.Events.CHANNEL_NAMES_UPDATED
SystemData.Events.CHARACTER_CHARACTER_SELECTION_UPDATED
SystemData.Events.CHARACTER_CREATE_CAREER_UPDATED
SystemData.Events.CHARACTER_CREATE_FEATURES_UPDATED
SystemData.Events.CHARACTER_CREATE_GENDER_UPDATED
SystemData.Events.CHARACTER_CREATE_RACE_UPDATED
SystemData.Events.CHARACTER_DATA_LUA_VARS_UPDATED
SystemData.Events.CHARACTER_LIST_RESPONSE
SystemData.Events.CHARACTER_LIST_START
SystemData.Events.CHARACTER_MOUSE_OVER_UPDATED
SystemData.Events.CHARACTER_PREGAME_ANIMATION_FINISHED
SystemData.Events.CHARACTER_PREGAME_ANIMATION_STARTED
SystemData.Events.CHARACTER_PREGAME_FORCED_RANDOM_NAME_ACCEPT
SystemData.Events.CHARACTER_PREGAME_FORCED_RANDOM_NAME_START
SystemData.Events.CHARACTER_PREGAME_NAMING_CONFLICT_POP_UP_WINDOW
SystemData.Events.CHARACTER_PREGAME_NAMING_CONFLICT_RESPONSE
SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_LIST_RECEIVED
SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_REQUESTED
SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_UPDATE_CHAR_SELECT
SystemData.Events.CHARACTER_PREGAME_RANDOM_NAME_UPDATE_FORCED_SELECT
SystemData.Events.CHARACTER_PREGAME_TRANSFER_FLAG_UPDATED
SystemData.Events.CHARACTER_QUEUE_UPDATED
SystemData.Events.CHARACTER_REALM_OVER_UPDATED
SystemData.Events.CHARACTER_REALM_UPDATED
SystemData.Events.CHARACTER_SELECT_CURRENT_PAGE_UPDATED
SystemData.Events.CHARACTER_SELECT_LOCKOUT_TIMER_UPDATED
SystemData.Events.CHARACTER_SELECT_PAGES_UPDATED
SystemData.Events.CHARACTER_SETTINGS_ON_CHARACTER_DELETED
SystemData.Events.CHARACTER_SETTINGS_UPDATED
SystemData.Events.CHARACTER_STATE_UPDATED
SystemData.Events.CHARACTER_TEMPLATES_UPDATED
SystemData.Events.CHAT_REPLY
SystemData.Events.CHAT_TEXT_ARRIVED
SystemData.Events.CINEMA_INTRO_ENDED
SystemData.Events.CINEMA_INTRO_STARTED
SystemData.Events.CITY_CAPTURE_FLEE
SystemData.Events.CITY_CAPTURE_LEAVE_QUEUE
SystemData.Events.CITY_CAPTURE_REQUEST_INSTANCE_DATA
SystemData.Events.CITY_CAPTURE_SHOW_JOIN_PROMPT
SystemData.Events.CITY_CAPTURE_SHOW_LOW_LEVEL_JOIN_PROMPT
SystemData.Events.CITY_RATING_UPDATED
SystemData.Events.CITY_SCENARIO_BEGIN
SystemData.Events.CITY_SCENARIO_END
SystemData.Events.CITY_SCENARIO_INSTANCE_ID_SELECTED
SystemData.Events.CITY_SCENARIO_UPDATE_POINTS
SystemData.Events.CITY_SCENARIO_UPDATE_STATUS
SystemData.Events.CITY_SCENARIO_UPDATE_TIME
SystemData.Events.CLEAR_USER_MAP_POINT
SystemData.Events.CONTESTED_INSTANCE_CANCEL
SystemData.Events.CONTESTED_INSTANCE_ENTER
SystemData.Events.CONTESTED_SCENARIO_SELECT_INSTANCE
SystemData.Events.CONVERSATION_TEXT_ARRIVED
SystemData.Events.CRAFTING_SHOW_WINDOW
SystemData.Events.CREATE_CHARACTER
SystemData.Events.CURRENT_EVENTS_JUMP_TIMER_UPDATED
SystemData.Events.CURRENT_EVENTS_LIST_UPDATED
SystemData.Events.CUSTOM_UI_SCALE_CHANGED
SystemData.Events.DELETE_CHARACTER
SystemData.Events.END_ITEM_ENHANCEMENT
SystemData.Events.ENTER_KEY_PROCESSED
SystemData.Events.ENTER_WORLD
SystemData.Events.EQUIPMENT_UPGRADE_COST
SystemData.Events.EQUIPMENT_UPGRADE_RESULT
SystemData.Events.ESCAPE_KEY_PROCESSED
SystemData.Events.EXIT_GAME
SystemData.Events.GO_BACK
SystemData.Events.GROUP_ACCEPT_INVITATION
SystemData.Events.GROUP_ACCEPT_REFERRAL
SystemData.Events.GROUP_DECLINE_INVITATION
SystemData.Events.GROUP_DECLINE_REFERRAL
SystemData.Events.GROUP_EFFECTS_UPDATED
SystemData.Events.GROUP_INVITE_PLAYER
SystemData.Events.GROUP_KICK_PLAYER
SystemData.Events.GROUP_LEAVE
SystemData.Events.GROUP_PLAYER_ADDED
SystemData.Events.GROUP_REFER_PLAYER
SystemData.Events.GROUP_SETTINGS_PRIVACY_UPDATED
SystemData.Events.GROUP_SETTINGS_UPDATED
SystemData.Events.GROUP_SET_LEADER
SystemData.Events.GROUP_SET_MAIN_ASSIST
SystemData.Events.GROUP_SET_MASTER_LOOT_ON
SystemData.Events.GROUP_STATUS_UPDATED
SystemData.Events.GROUP_UPDATED
SystemData.Events.GUILD_ABILITIES_AVAILABLE_UPDATED
SystemData.Events.GUILD_ABILITIES_PURCHASED_UPDATED
SystemData.Events.GUILD_APPOINTMENTS_UPDATED
SystemData.Events.GUILD_BANNERS_UPDATED
SystemData.Events.GUILD_COMMAND_ALLIANCE_INVITE_ACCEPT
SystemData.Events.GUILD_COMMAND_ALLIANCE_INVITE_DECLINE
SystemData.Events.GUILD_COMMAND_ASSIGN
SystemData.Events.GUILD_COMMAND_CLAIM_ENTITY_ACCEPT
SystemData.Events.GUILD_COMMAND_CLAIM_ENTITY_DECLINE
SystemData.Events.GUILD_COMMAND_CLAIM_ENTITY_LOW_FUNDS_ACCEPT
SystemData.Events.GUILD_COMMAND_CREATE
SystemData.Events.GUILD_COMMAND_DEMOTE
SystemData.Events.GUILD_COMMAND_INVITE
SystemData.Events.GUILD_COMMAND_INVITE_ACCEPT
SystemData.Events.GUILD_COMMAND_INVITE_DECLINE
SystemData.Events.GUILD_COMMAND_LEAVE
SystemData.Events.GUILD_COMMAND_PROMOTE
SystemData.Events.GUILD_COMMAND_PURCHASE_TACTIC
SystemData.Events.GUILD_COMMAND_REMOVE
SystemData.Events.GUILD_COMMAND_RENAME
SystemData.Events.GUILD_COMMAND_UNCLAIM_ENTITY_DECLINE
SystemData.Events.GUILD_COMMAND_UNCLAIM_ENTITY_NOPENALTY_ACCEPT
SystemData.Events.GUILD_COMMAND_UNCLAIM_ENTITY_PENALTY_ACCEPT
SystemData.Events.GUILD_EXP_UPDATED
SystemData.Events.GUILD_HERALDRY_UPDATED
SystemData.Events.GUILD_INFO_UPDATED
SystemData.Events.GUILD_KEEP_UPDATED
SystemData.Events.GUILD_MEMBER_ADDED
SystemData.Events.GUILD_MEMBER_NOTES_UPDATED
SystemData.Events.GUILD_MEMBER_REMOVED
SystemData.Events.GUILD_MEMBER_UPDATED
SystemData.Events.GUILD_NEWBIE_GUILD_STATUS_UPDATED
SystemData.Events.GUILD_NEWS_UPDATED
SystemData.Events.GUILD_PERMISSIONS_UPDATED
SystemData.Events.GUILD_PERSONAL_STATISTICS_UPDATED
SystemData.Events.GUILD_POLL_UPDATED
SystemData.Events.GUILD_RECRUITMENT_PROFILE_UPDATED
SystemData.Events.GUILD_RECRUITMENT_SEARCH_RESULTS_UPDATED
SystemData.Events.GUILD_REFRESH
SystemData.Events.GUILD_REWARDS_UPDATED
SystemData.Events.GUILD_ROSTER_INIT
SystemData.Events.GUILD_STATISTICS_UPDATED
SystemData.Events.GUILD_TAX_TITHE_UPDATED
SystemData.Events.GUILD_UNGUILDED
SystemData.Events.GUILD_VAULT_CAPACITY_UPDATED
SystemData.Events.GUILD_VAULT_COIN_UPDATED
SystemData.Events.GUILD_VAULT_ITEMS_UPDATED
SystemData.Events.GUILD_VAULT_SLOT_LOCKED
SystemData.Events.GUILD_VAULT_SLOT_UNLOCKED
SystemData.Events.HELP_LOG_UPDATED
SystemData.Events.HELP_STATUS_UPDATED
SystemData.Events.HELP_TIP_UPDATED
SystemData.Events.INFO_ALERT
SystemData.Events.INTERACT_ACCEPT_QUEST
SystemData.Events.INTERACT_ALLIANCE_FORM_ACCEPT
SystemData.Events.INTERACT_ALLIANCE_FORM_DECLINE
SystemData.Events.INTERACT_BARBERSHOP_FEATURE_UPDATE
SystemData.Events.INTERACT_BARBERSHOP_OPEN
SystemData.Events.INTERACT_BARBERSHOP_RESULT
SystemData.Events.INTERACT_BIND
SystemData.Events.INTERACT_BUY_BACK_ITEM
SystemData.Events.INTERACT_BUY_ITEM
SystemData.Events.INTERACT_BUY_ITEM_WITH_ALT_CURRENCY
SystemData.Events.INTERACT_CLOSE
SystemData.Events.INTERACT_COMPLETE_QUEST
SystemData.Events.INTERACT_DEFAULT
SystemData.Events.INTERACT_DIVINEFAVORALTAR_OPEN
SystemData.Events.INTERACT_DIVINEFAVORALTAR_UPDATE
SystemData.Events.INTERACT_DONE
SystemData.Events.INTERACT_DYE_MERCHANT
SystemData.Events.INTERACT_DYE_MERCHANT_DYE_ALL
SystemData.Events.INTERACT_DYE_MERCHANT_DYE_SINGLE
SystemData.Events.INTERACT_EQUIPMENT_UPGRADE_OPEN
SystemData.Events.INTERACT_FLIGHT_TRAVEL
SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE
SystemData.Events.INTERACT_GROUP_JOIN_SCENARIO_QUEUE_ALL
SystemData.Events.INTERACT_GUILD_CREATION_COMPLETE
SystemData.Events.INTERACT_GUILD_FORM_ACCEPT
SystemData.Events.INTERACT_GUILD_FORM_DECLINE
SystemData.Events.INTERACT_GUILD_NPC_ERROR
SystemData.Events.INTERACT_GUILD_RENAME_BEGIN
SystemData.Events.INTERACT_GUILD_SHOW_FORM
SystemData.Events.INTERACT_GUILD_VAULT_CLOSED
SystemData.Events.INTERACT_GUILD_VAULT_OPEN
SystemData.Events.INTERACT_HEALER
SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE
SystemData.Events.INTERACT_JOIN_SCENARIO_QUEUE_ALL
SystemData.Events.INTERACT_KEEP_UPGRADE_OPEN
SystemData.Events.INTERACT_KEEP_UPGRADE_UPDATE
SystemData.Events.INTERACT_LAST_NAME_MERCHANT
SystemData.Events.INTERACT_LAST_NAME_MERCHANT_BUY
SystemData.Events.INTERACT_LEAVE_SCENARIO_QUEUE
SystemData.Events.INTERACT_LOOT_CLOSE
SystemData.Events.INTERACT_LOOT_ROLL_FIRST_ITEM
SystemData.Events.INTERACT_MAILBOX_CLOSED
SystemData.Events.INTERACT_MAILBOX_OPEN
SystemData.Events.INTERACT_OPEN_BANK
SystemData.Events.INTERACT_PURCHASE_HEAL
SystemData.Events.INTERACT_REPAIR
SystemData.Events.INTERACT_SELECT_FLIGHTMASTER
SystemData.Events.INTERACT_SELECT_FLIGHT_POINT
SystemData.Events.INTERACT_SELECT_QUEST
SystemData.Events.INTERACT_SELECT_STORE
SystemData.Events.INTERACT_SELECT_TRAINING
SystemData.Events.INTERACT_SELL_ITEM
SystemData.Events.INTERACT_SHOW_EVENT_REWARDS
SystemData.Events.INTERACT_SHOW_FLIGHTMASTER
SystemData.Events.INTERACT_SHOW_HEALER
SystemData.Events.INTERACT_SHOW_INFLUENCE_REWARDS
SystemData.Events.INTERACT_SHOW_ITEM_CONTAINER_LOOT
SystemData.Events.INTERACT_SHOW_LIBRARIAN
SystemData.Events.INTERACT_SHOW_LOOT
SystemData.Events.INTERACT_SHOW_LOOT_ROLL_DATA
SystemData.Events.INTERACT_SHOW_PQ_LOOT
SystemData.Events.INTERACT_SHOW_QUEST
SystemData.Events.INTERACT_SHOW_SCENARIO_QUEUE_LIST
SystemData.Events.INTERACT_SHOW_SIEGE_PAD_BUILD_LIST
SystemData.Events.INTERACT_SHOW_STORE
SystemData.Events.INTERACT_SHOW_TRAINING
SystemData.Events.INTERACT_UPDATED_SCENARIO_QUEUE_LIST
SystemData.Events.INTERACT_UPDATE_LIBRARIAN
SystemData.Events.INTERFACE_RELOADED
SystemData.Events.ITEM_SET_DATA_ARRIVED
SystemData.Events.ITEM_SET_DATA_UPDATED
SystemData.Events.KEYBINDINGS_UPDATED
SystemData.Events.KILLER_NAME_UPDATED
SystemData.Events.LANGUAGE_TOGGLED
SystemData.Events.LOADING_BEGIN
SystemData.Events.LOADING_END
SystemData.Events.LOADING_PROGRESS_UPDATED
SystemData.Events.LOCKOUTS_UPDATED
SystemData.Events.LOGIN
SystemData.Events.LOGIN_LOCAL
SystemData.Events.LOGIN_PROGRESS_STARTING
SystemData.Events.LOGIN_PROGRESS_UPDATED
SystemData.Events.LOG_OUT
SystemData.Events.LOOT_ALL
SystemData.Events.LOOT_GREED
SystemData.Events.LOOT_NEED
SystemData.Events.LOOT_PASS
SystemData.Events.L_BUTTON_DOWN_PROCESSED
SystemData.Events.L_BUTTON_UP_PROCESSED
SystemData.Events.MACROS_LOADED
SystemData.Events.MACRO_UPDATED
SystemData.Events.MAILBOX_HEADERS_UPDATED
SystemData.Events.MAILBOX_HEADER_UPDATED
SystemData.Events.MAILBOX_MESSAGE_DELETED
SystemData.Events.MAILBOX_MESSAGE_OPENED
SystemData.Events.MAILBOX_POSTAGE_COST_UPDATED
SystemData.Events.MAILBOX_RESULTS_UPDATED
SystemData.Events.MAILBOX_UNREAD_COUNT_CHANGED
SystemData.Events.MAIN_ASSIST_TARGET_UPDATED
SystemData.Events.MAP_SETTINGS_UPDATED
SystemData.Events.MOUSEOVER_WORLD_OBJECT
SystemData.Events.MOUSE_DOWN_ON_CHAR_SELECT_NIF
SystemData.Events.MOUSE_DOWN_ON_NIF
SystemData.Events.MOUSE_UP_ON_CHAR_SELECT_NIF
SystemData.Events.MOUSE_UP_ON_NIF
SystemData.Events.MOVE_INVENTORY_OBJECT
SystemData.Events.M_BUTTON_DOWN_PROCESSED
SystemData.Events.M_BUTTON_UP_PROCESSED
SystemData.Events.OBJECTIVE_AREA_EXIT
SystemData.Events.OBJECTIVE_CONTROL_POINTS_UPDATED
SystemData.Events.OBJECTIVE_MAP_TIMER_UPDATED
SystemData.Events.OBJECTIVE_OWNER_UPDATED
SystemData.Events.OPEN_LFM_WINDOW
SystemData.Events.PAIRING_MAP_HOTSPOT_DATA_UPDATED
SystemData.Events.PAPERDOLL_SPIN_LEFT
SystemData.Events.PAPERDOLL_SPIN_RIGHT
SystemData.Events.PET_AGGRESSIVE
SystemData.Events.PET_DEFENSIVE
SystemData.Events.PET_PASSIVE
SystemData.Events.PLAY
SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED
SystemData.Events.PLAYER_ABILITIES_QUEUED_UPDATED
SystemData.Events.PLAYER_ABILITY_TOGGLED
SystemData.Events.PLAYER_ACTIVE_TACTICS_UPDATED
SystemData.Events.PLAYER_ACTIVE_TITLE_UPDATED
SystemData.Events.PLAYER_ADVANCE_ALERT
SystemData.Events.PLAYER_AGRO_MODE_UPDATED
SystemData.Events.PLAYER_AREA_CHANGED
SystemData.Events.PLAYER_AREA_NAME_CHANGED
SystemData.Events.PLAYER_BANK_SLOT_UPDATED
SystemData.Events.PLAYER_BATTLE_LEVEL_UPDATED
SystemData.Events.PLAYER_BEGIN_CAST
SystemData.Events.PLAYER_BLOCKED_ABILITIES_UPDATED
SystemData.Events.PLAYER_CAREER_CATEGORY_UPDATED
SystemData.Events.PLAYER_CAREER_LINE_UPDATED
SystemData.Events.PLAYER_CAREER_RANK_UPDATED
SystemData.Events.PLAYER_CAREER_RESOURCE_UPDATED
SystemData.Events.PLAYER_CAST_TIMER_SETBACK
SystemData.Events.PLAYER_CHAPTER_UPDATED
SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED
SystemData.Events.PLAYER_COOLDOWN_TIMER_SET
SystemData.Events.PLAYER_CRAFTING_INVENTORY_UPDATED
SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED
SystemData.Events.PLAYER_CRAFTING_UPDATED
SystemData.Events.PLAYER_CULTIVATION_UPDATED
SystemData.Events.PLAYER_CURRENCY_SLOT_UPDATED
SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED
SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED
SystemData.Events.PLAYER_DATA_RESPONSE
SystemData.Events.PLAYER_DATA_START
SystemData.Events.PLAYER_DEATH
SystemData.Events.PLAYER_DEATH_CLEARED
SystemData.Events.PLAYER_EFFECTS_UPDATED
SystemData.Events.PLAYER_END_CAST
SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED
SystemData.Events.PLAYER_EXP_TABLE_UPDATED
SystemData.Events.PLAYER_EXP_UPDATED
SystemData.Events.PLAYER_FAKEBUFF_STATE_UPDATED
SystemData.Events.PLAYER_GROUP_LEADER_STATUS_UPDATED
SystemData.Events.PLAYER_HEALTH_FADE_UPDATED
SystemData.Events.PLAYER_HOT_BAR_ENABLED_STATE_CHANGED
SystemData.Events.PLAYER_HOT_BAR_PAGE_UPDATED
SystemData.Events.PLAYER_HOT_BAR_UPDATED
SystemData.Events.PLAYER_INFLUENCE_RANK_UPDATED
SystemData.Events.PLAYER_INFLUENCE_REWARDS_UPDATED
SystemData.Events.PLAYER_INFLUENCE_UPDATED
SystemData.Events.PLAYER_INFO_CHANGED
SystemData.Events.PLAYER_INTERNAL_BUFF_UPDATED
SystemData.Events.PLAYER_INVENTORY_OVERFLOW_UPDATED
SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED
SystemData.Events.PLAYER_IS_DISARMED
SystemData.Events.PLAYER_IS_IMMUNE_TO_DISABLES
SystemData.Events.PLAYER_IS_IMMUNE_TO_MOVEMENT_IMPARING
SystemData.Events.PLAYER_IS_SILENCED
SystemData.Events.PLAYER_IS_UNABLE_TO_MOVE
SystemData.Events.PLAYER_KILLING_SPREE_UPDATED
SystemData.Events.PLAYER_LEARNED_ABOUT_UI_ELEMENT
SystemData.Events.PLAYER_MAIN_ASSIST_UPDATED
SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED
SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED
SystemData.Events.PLAYER_MONEY_UPDATED
SystemData.Events.PLAYER_MORALE_BAR_UPDATED
SystemData.Events.PLAYER_MORALE_UPDATED
SystemData.Events.PLAYER_NEW_ABILITY_LEARNED
SystemData.Events.PLAYER_NEW_NUMBER_OF_BACKPACK_SLOTS
SystemData.Events.PLAYER_NEW_NUMBER_OF_BANK_SLOTS
SystemData.Events.PLAYER_NEW_PET_ABILITY_LEARNED
SystemData.Events.PLAYER_NUM_TACTIC_SLOTS_UPDATED
SystemData.Events.PLAYER_OBJECTIVES_UPDATED
SystemData.Events.PLAYER_OBJECTIVE_CONTRIBUTION_UPDATED
SystemData.Events.PLAYER_OFFER_ITEMS_UPDATED
SystemData.Events.PLAYER_PET_HEALTH_UPDATED
SystemData.Events.PLAYER_PET_STATE_UPDATED
SystemData.Events.PLAYER_PET_TARGET_HEALTH_UPDATED
SystemData.Events.PLAYER_PET_TARGET_UPDATED
SystemData.Events.PLAYER_PET_UPDATED
SystemData.Events.PLAYER_POSITION_UPDATED
SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED
SystemData.Events.PLAYER_RACE_UPDATED
SystemData.Events.PLAYER_REALM_BONUS_UPDATED
SystemData.Events.PLAYER_REMOVED_ITEM
SystemData.Events.PLAYER_RENOWN_RANK_UPDATED
SystemData.Events.PLAYER_RENOWN_TITLE_UPDATED
SystemData.Events.PLAYER_RENOWN_UPDATED
SystemData.Events.PLAYER_RVR_FLAG_UPDATED
SystemData.Events.PLAYER_RVR_STATS_UPDATED
SystemData.Events.PLAYER_SET_ACTIVE_WEAPON_SET
SystemData.Events.PLAYER_SINGLE_ABILITY_UPDATED
SystemData.Events.PLAYER_SKILLS_UPDATED
SystemData.Events.PLAYER_STANCE_UPDATED
SystemData.Events.PLAYER_START_INTERACT_TIMER
SystemData.Events.PLAYER_START_RVR_FLAG_TIMER
SystemData.Events.PLAYER_STATS_UPDATED
SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED
SystemData.Events.PLAYER_TARGET_HIT_POINTS_UPDATED
SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_DISABLES
SystemData.Events.PLAYER_TARGET_IS_IMMUNE_TO_MOVEMENT_IMPARING
SystemData.Events.PLAYER_TARGET_STATE_UPDATED
SystemData.Events.PLAYER_TARGET_UPDATED
SystemData.Events.PLAYER_TRADE_ACCEPTED
SystemData.Events.PLAYER_TRADE_CANCELLED
SystemData.Events.PLAYER_TRADE_INITIATED
SystemData.Events.PLAYER_TRADE_ITEMS_UPDATED
SystemData.Events.PLAYER_TROPHY_SLOT_UPDATED
SystemData.Events.PLAYER_WEAPON_SETS_UPDATED
SystemData.Events.PLAYER_ZONE_CHANGED
SystemData.Events.PLAY_AS_MONSTER_STATUS
SystemData.Events.PREGAME_CLEAR_RANDOM_NAME_LIST
SystemData.Events.PREGAME_EULA_ACCEPTED
SystemData.Events.PREGAME_GO_TO_CHARACTER_SELECT
SystemData.Events.PREGAME_LAUNCH_SERVER_SELECT
SystemData.Events.PREGAME_PLAY_ANIMATION
SystemData.Events.PREGAME_ROC_ACCEPTED
SystemData.Events.PREGAME_SET_STATE
SystemData.Events.PRE_MODULE_SHUTDOWNS
SystemData.Events.PUBLIC_QUEST_ADDED
SystemData.Events.PUBLIC_QUEST_COMPLETED
SystemData.Events.PUBLIC_QUEST_CONDITION_UPDATED
SystemData.Events.PUBLIC_QUEST_FAILED
SystemData.Events.PUBLIC_QUEST_FORCEDOUT
SystemData.Events.PUBLIC_QUEST_HIDE_WINOMETER
SystemData.Events.PUBLIC_QUEST_INFO_UPDATED
SystemData.Events.PUBLIC_QUEST_LIST_UPDATED
SystemData.Events.PUBLIC_QUEST_OPTOUT
SystemData.Events.PUBLIC_QUEST_REMOVED
SystemData.Events.PUBLIC_QUEST_RESETTING
SystemData.Events.PUBLIC_QUEST_SHOW_SCOREBOARD
SystemData.Events.PUBLIC_QUEST_SHOW_WINOMETER
SystemData.Events.PUBLIC_QUEST_UPDATED
SystemData.Events.PUBLIC_QUEST_WINOMETER_UPDATED
SystemData.Events.QUEST_CONDITION_UPDATED
SystemData.Events.QUEST_INFO_UPDATED
SystemData.Events.QUEST_LIST_UPDATED
SystemData.Events.QUIT
SystemData.Events.RALLY_CALL_INVITE
SystemData.Events.RALLY_CALL_JOIN
SystemData.Events.RELEASE_CORPSE
SystemData.Events.RELOAD_INTERFACE
SystemData.Events.REPORT_GOLD_SELLER
SystemData.Events.RESOLUTION_CHANGED
SystemData.Events.RESURRECTION_ACCEPT
SystemData.Events.RESURRECTION_DECLINE
SystemData.Events.RRQ_LIST_UPDATED
SystemData.Events.RVR_UNDERDOG_RATING_UPDATED
SystemData.Events.R_BUTTON_DOWN_PROCESSED
SystemData.Events.R_BUTTON_UP_PROCESSED
SystemData.Events.SCENARIO_ACTIVE_QUEUE_UPDATED
SystemData.Events.SCENARIO_BEGIN
SystemData.Events.SCENARIO_END
SystemData.Events.SCENARIO_FINAL_SCOREBOARD_CLOSED
SystemData.Events.SCENARIO_GROUP_JOIN
SystemData.Events.SCENARIO_GROUP_LEAVE
SystemData.Events.SCENARIO_GROUP_UPDATED
SystemData.Events.SCENARIO_INSTANCE_CANCEL
SystemData.Events.SCENARIO_INSTANCE_JOIN_NOW
SystemData.Events.SCENARIO_INSTANCE_JOIN_WAIT
SystemData.Events.SCENARIO_INSTANCE_LEAVE
SystemData.Events.SCENARIO_PLAYERS_LIST_GROUPS_UPDATED
SystemData.Events.SCENARIO_PLAYERS_LIST_RESERVATIONS_UPDATED
SystemData.Events.SCENARIO_PLAYERS_LIST_STATS_UPDATED
SystemData.Events.SCENARIO_PLAYERS_LIST_UPDATED
SystemData.Events.SCENARIO_PLAYER_HITS_UPDATED
SystemData.Events.SCENARIO_POST_MODE
SystemData.Events.SCENARIO_SHOW_JOIN_PROMPT
SystemData.Events.SCENARIO_SHOW_LEVELED_NEED_REJOIN_BRACKET
SystemData.Events.SCENARIO_SHOW_LEVELED_OUT_OF_BRACKETS
SystemData.Events.SCENARIO_STARTING_SCENARIO_UPDATED
SystemData.Events.SCENARIO_START_UPDATING_PLAYERS_STATS
SystemData.Events.SCENARIO_STOP_UPDATING_PLAYERS_STATS
SystemData.Events.SCENARIO_UPDATE_POINTS
SystemData.Events.SELECT_CHARACTER
SystemData.Events.SERVER_LIST_RESPONSE
SystemData.Events.SERVER_LIST_START
SystemData.Events.SERVER_LOAD_STATUS
SystemData.Events.SETTINGS_CHAT_UPDATED
SystemData.Events.SHOW_ALERT_TEXT
SystemData.Events.SIEGE_WEAPON_CONTROL_TIMER_UPDATED
SystemData.Events.SIEGE_WEAPON_FIRE_RESULTS
SystemData.Events.SIEGE_WEAPON_GOLF_BEGIN
SystemData.Events.SIEGE_WEAPON_GOLF_END
SystemData.Events.SIEGE_WEAPON_GOLF_RESET
SystemData.Events.SIEGE_WEAPON_GOLF_START_BACK_SWING
SystemData.Events.SIEGE_WEAPON_GOLF_START_FORWARD_SWING
SystemData.Events.SIEGE_WEAPON_HEALTH_UPDATED
SystemData.Events.SIEGE_WEAPON_RELEASE
SystemData.Events.SIEGE_WEAPON_REUSE_TIMER_UPDATED
SystemData.Events.SIEGE_WEAPON_SCORCH_BEGIN
SystemData.Events.SIEGE_WEAPON_SCORCH_END
SystemData.Events.SIEGE_WEAPON_SCORCH_POWER_UPDATED
SystemData.Events.SIEGE_WEAPON_SCORCH_WIND_UPDATED
SystemData.Events.SIEGE_WEAPON_SNIPER_AIM_TARGET_LOS_UPDATED
SystemData.Events.SIEGE_WEAPON_SNIPER_AIM_TARGET_UPDATED
SystemData.Events.SIEGE_WEAPON_SNIPER_AIM_TIME_UPDATED
SystemData.Events.SIEGE_WEAPON_SNIPER_BEGIN
SystemData.Events.SIEGE_WEAPON_SNIPER_END
SystemData.Events.SIEGE_WEAPON_STATE_UPDATED
SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_BEGIN
SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_END
SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_FIRE_RESULTS
SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_RESET
SystemData.Events.SIEGE_WEAPON_SWEET_SPOT_START_MOVING
SystemData.Events.SIEGE_WEAPON_UPDATED
SystemData.Events.SIEGE_WEAPON_USERS_UPDATED
SystemData.Events.SOCIAL_BRAGGING_RIGHTS_UPDATED
SystemData.Events.SOCIAL_FRIENDS_UPDATED
SystemData.Events.SOCIAL_IGNORE_UPDATED
SystemData.Events.SOCIAL_INSPECTION_UPDATED
SystemData.Events.SOCIAL_OPENPARTYINTEREST_UPDATED
SystemData.Events.SOCIAL_OPENPARTYWORLD_SETTINGS_UPDATED
SystemData.Events.SOCIAL_OPENPARTY_NOTIFY
SystemData.Events.SOCIAL_OPENPARTY_UPDATED
SystemData.Events.SOCIAL_OPENPARTY_WORLD_UPDATED
SystemData.Events.SOCIAL_OPTIONS_UPDATED
SystemData.Events.SOCIAL_SEARCH_UPDATED
SystemData.Events.SOCIAL_YOU_HAVE_BEEN_FRIENDED
SystemData.Events.SPELL_CAST_CANCEL
SystemData.Events.STREAMING_STATUS_UPDATED
SystemData.Events.SUMMON_ACCEPT
SystemData.Events.SUMMON_DECLINE
SystemData.Events.SUMMON_SHOW_PROMPT
SystemData.Events.SURVEY_POPUP
SystemData.Events.SURVEY_UPDATED
SystemData.Events.TARGET_GROUP_MEMBER_1
SystemData.Events.TARGET_GROUP_MEMBER_1_PET
SystemData.Events.TARGET_GROUP_MEMBER_2
SystemData.Events.TARGET_GROUP_MEMBER_2_PET
SystemData.Events.TARGET_GROUP_MEMBER_3
SystemData.Events.TARGET_GROUP_MEMBER_3_PET
SystemData.Events.TARGET_GROUP_MEMBER_4
SystemData.Events.TARGET_GROUP_MEMBER_4_PET
SystemData.Events.TARGET_GROUP_MEMBER_5
SystemData.Events.TARGET_GROUP_MEMBER_5_PET
SystemData.Events.TARGET_GROUP_MEMBER_6
SystemData.Events.TARGET_GROUP_MEMBER_6_PET
SystemData.Events.TARGET_PET
SystemData.Events.TARGET_SELF
SystemData.Events.TITLE_SCREEN_INIT_LOADING_UI
SystemData.Events.TITLE_SCREEN_INIT_LOADING_UI_COMPLETE
SystemData.Events.TOGGLE_ABILITIES_WINDOW
SystemData.Events.TOGGLE_BACKPACK_WINDOW
SystemData.Events.TOGGLE_BATTLEGROUP_WINDOW
SystemData.Events.TOGGLE_CHARACTER_WINDOW
SystemData.Events.TOGGLE_CURRENT_EVENTS_WINDOW
SystemData.Events.TOGGLE_FULLSCREEN
SystemData.Events.TOGGLE_GUILD_WINDOW
SystemData.Events.TOGGLE_HELP_WINDOW
SystemData.Events.TOGGLE_HOTBAR
SystemData.Events.TOGGLE_MENU
SystemData.Events.TOGGLE_MENU_WINDOW
SystemData.Events.TOGGLE_PARTY_WINDOW
SystemData.Events.TOGGLE_SCENARIO_SUMMARY_WINDOW
SystemData.Events.TOGGLE_SOCIAL_WINDOW
SystemData.Events.TOGGLE_TOME_WINDOW
SystemData.Events.TOGGLE_USER_SETTINGS_WINDOW
SystemData.Events.TOGGLE_WORLD_MAP_WINDOW
SystemData.Events.TOME_ACHIEVEMENTS_SUBTYPE_UPDATED
SystemData.Events.TOME_ACHIEVEMENTS_TOC_UPDATED
SystemData.Events.TOME_ACHIEVEMENTS_TYPE_UPDATED
SystemData.Events.TOME_ALERTS_UPDATED
SystemData.Events.TOME_ALERT_ADDED
SystemData.Events.TOME_BESTIARY_SPECIES_KILL_COUNT_UPDATED
SystemData.Events.TOME_BESTIARY_SPECIES_UPDATED
SystemData.Events.TOME_BESTIARY_SUBTYPE_KILL_COUNT_UPDATED
SystemData.Events.TOME_BESTIARY_SUBTYPE_UPDATED
SystemData.Events.TOME_BESTIARY_TOC_UPDATED
SystemData.Events.TOME_BESTIARY_TOTAL_KILL_COUNT_UPDATED
SystemData.Events.TOME_CARD_LIST_UPDATED
SystemData.Events.TOME_GAME_FAQ_TOC_UPDATED
SystemData.Events.TOME_HISTORY_AND_LORE_ENTRY_UPDATED
SystemData.Events.TOME_HISTORY_AND_LORE_PAIRING_UPDATED
SystemData.Events.TOME_HISTORY_AND_LORE_TOC_UPDATED
SystemData.Events.TOME_HISTORY_AND_LORE_ZONE_UPDATED
SystemData.Events.TOME_ID_UNLOCKED_FOR_PLAYER
SystemData.Events.TOME_INITIALIZED_FOR_PLAYER
SystemData.Events.TOME_ITEM_REWARDS_LIST_UPDATED
SystemData.Events.TOME_LIVE_EVENT_ENDED
SystemData.Events.TOME_LIVE_EVENT_LOADED
SystemData.Events.TOME_LIVE_EVENT_OVERALL_COUNTER_UPDATED
SystemData.Events.TOME_LIVE_EVENT_REMOVED
SystemData.Events.TOME_LIVE_EVENT_TASKS_UPDATED
SystemData.Events.TOME_LIVE_EVENT_TASK_COUNTER_UPDATED
SystemData.Events.TOME_NOTEWORTHY_PERSONS_ENTRY_UPDATED
SystemData.Events.TOME_NOTEWORTHY_PERSONS_PAIRING_UPDATED
SystemData.Events.TOME_NOTEWORTHY_PERSONS_TOC_UPDATED
SystemData.Events.TOME_NOTEWORTHY_PERSONS_ZONE_UPDATED
SystemData.Events.TOME_OLD_WORLD_ARMORY_ARMOR_SET_UPDATED
SystemData.Events.TOME_OLD_WORLD_ARMORY_TOC_UPDATED
SystemData.Events.TOME_PLAYER_TITLES_TOC_UPDATED
SystemData.Events.TOME_PLAYER_TITLES_TYPE_UPDATED
SystemData.Events.TOME_SIGIL_ENTRY_UPDATED
SystemData.Events.TOME_SIGIL_TOC_UPDATED
SystemData.Events.TOME_STAT_PLAYED_TIME_UPDATED
SystemData.Events.TOME_STAT_TOTAL_CARDS_UPDATED
SystemData.Events.TOME_STAT_TOTAL_ITEM_REWARDS_UPDATED
SystemData.Events.TOME_STAT_TOTAL_TACTIC_REWARDS_UPDATED
SystemData.Events.TOME_STAT_TOTAL_TITLE_REWARDS_UPDATED
SystemData.Events.TOME_STAT_TOTAL_UNLOCKS_UPDATED
SystemData.Events.TOME_STAT_TOTAL_XP_UPDATED
SystemData.Events.TOME_TACTIC_REWARDS_LIST_UPDATED
SystemData.Events.TOME_WAR_JOURNAL_ENTRY_UPDATED
SystemData.Events.TOME_WAR_JOURNAL_STORYLINE_UPDATED
SystemData.Events.TOME_WAR_JOURNAL_TOC_UPDATED
SystemData.Events.TRADE_SKILL_UPDATED
SystemData.Events.TRANSFER_GUILD
SystemData.Events.TRIAL_ALERT_POPUP
SystemData.Events.UPDATE_CREATION_CHARACTER
SystemData.Events.UPDATE_GUILDHERALDRY
SystemData.Events.UPDATE_GUILDSTANDARD
SystemData.Events.UPDATE_ITEM_ENHANCEMENT
SystemData.Events.UPDATE_PROCESSED
SystemData.Events.USER_SETTINGS_CHANGED
SystemData.Events.VIDEO_PLAYER_START
SystemData.Events.VIDEO_PLAYER_STOP
SystemData.Events.VISIBLE_EQUIPMENT_UPDATED
SystemData.Events.WORLD_EVENT_TEXT_ARRIVED
SystemData.Events.WORLD_MAP_POINTS_LOADED
SystemData.Events.WORLD_OBJ_COMBAT_EVENT
SystemData.Events.WORLD_OBJ_HEALTH_CHANGED
SystemData.Events.WORLD_OBJ_INFLUENCE_GAINED
SystemData.Events.WORLD_OBJ_RENOWN_GAINED
SystemData.Events.WORLD_OBJ_XP_GAINED
SystemData.Events.ZONE_CONFIRMATION_NO
SystemData.Events.ZONE_CONFIRMATION_YES

]]