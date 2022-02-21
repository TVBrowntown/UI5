Enemy =
{
	DefaultSettings =
	{
		version = 279.0,
		debug = false,

		stateMachineThrottle = 0.3,

		chatDelay = 1,
		chatThrottleDelay = 1,

		intercomPrivate = true,

		targetShowDelay = 8,
		markNewTarget = true,
		assistTargetOnNotifyClick = true,

		killSpamReparseChunkSize = 20,
		killSpamEnabled = true,
		killSpamListBottomUp = true,
		killSpamKilledByYouSound = GameData.Sound.QUEST_OBJECTIVES_COMPLETED,
		playerKills = 0,
		playerDeaths = 0,
		playerKDRDisplayMode = 5,

		soundOnNewTarget = false,
		soundOnNewTargetId = GameData.Sound.HELP_TIPS_NEW,

		objectWindowsTimeout = 20,
		objectWindowsInactiveTimeout = 1200,

		markTemplates =
		{
			{
				color =
				{
					191,
					255,
					0,
				},
				layer = 3,
				text = L"",
				scale = 1,
				targetOnClick = true,
				alpha = 1,
				showCareerIcon = true,
				font = "font_clear_large_bold",
				name = L"A",
				firstLetters = 4,
				display = 2,
				offsetY = 50,
				neverExpire = false,
				canClearOnClick = true,
				permanent = false,
				permanentTargets = {}
			},

			{
				color =
				{
					255,
					64,
					255,
				},
				layer = 3,
				text = L"",
				scale = 1,
				targetOnClick = true,
				alpha = 1,
				showCareerIcon = true,
				font = "font_clear_large_bold",
				name = L"B",
				firstLetters = 4,
				display = 2,
				offsetY = 50,
				neverExpire = false,
				canClearOnClick = true,
				permanent = true,
				permanentTargets = {}
			},

			{
				color =
				{
					65,
					150,
					255,
				},
				layer = 3,
				text = L"G",
				scale = 1,
				targetOnClick = true,
				alpha = 1,
				showCareerIcon = false,
				font = "font_default_text_giant",
				name = L"G",
				firstLetters = 4,
				display = 1,
				offsetY = 50,
				neverExpire = false,
				canClearOnClick = true,
				permanent = false,
				permanentTargets = {}
			},
		},

		groupIconsEnabled = true,
		groupIconsTargetOnClick = true,
		groupIconsHideOnSelf = true,
		groupIconsShowOtherGroups = true,
		groupIconsShowOnMarkedPlayers = false,

		groupIconsScale = 1.0,
		groupIconsLayer = 0,
		groupIconsAlpha = 1.0,
		groupIconsOffset = { 0, 50 },
		groupIconsHPColor = { 200, 255, 0 },
		groupIconsHPBGColor = { 0, 100, 0 },
		groupIconsBGColor = { 200, 255, 0 },
		groupIconsBGAlpha = 0.5,

		groupIconsOtherGroupsScale = 0.6,
		groupIconsOtherGroupsLayer = 0,
		groupIconsOtherGroupsAlpha = 1.0,
		groupIconsOtherGroupsOffset = { 0, 50 },
		groupIconsOtherGroupsHPColor = { 200, 255, 255 },
		groupIconsOtherGroupsHPBGColor = { 50, 100, 100 },
		groupIconsOtherGroupsBGColor = { 200, 255, 255 },
		groupIconsOtherGroupsBGAlpha = 0.5,

		groupIconsPetScale = 1.0,
		groupIconsPetLayer = 0,
		groupIconsPetAlpha = 1.0,
		groupIconsPetOffset = { 0, 20 },
		groupIconsPetIconColor = { 255, 100, 200 },
		groupIconsPetHPColor = { 255, 225, 255 },
		groupIconsPetHPBGColor = { 100, 0, 0 },
		groupIconsPetBGColor = { 255, 225, 255 },
		groupIconsPetBGAlpha = 0.5,

		groupIconsParts = {},

		unitFramesEnabled = true,
		unitFramesTestMode = false,
		unitFramesSortingEnabled = true,
		unitFramesSorting = { 1, 2, 3 },
		unitFramesMyGroupOnly = false,
		unitFramesMyGroupFirst = true,
		unitFramesDetachMyGroup = false,
		unitFramesHideMyGroup = false,
		unitFramesHideWhenSolo = false,
		unitFramesTooltipMode = "always",

		unitFramesIsVertical = false,

		unitFramesSize = { 164, 32 },
		unitFramesLayer = 1,
		unitFramesScale = 1,

		unitFramesDirection1 = 2,
		unitFramesPadding1 = 3,
		unitFramesCount1 = 6,
		unitFramesDirection2 = 4,
		unitFramesPadding2 = 20,
		unitFramesGroupsDirection1 = 2,
		unitFramesGroupsPadding1 = 40,
		unitFramesGroupsCount1 = 2,
		unitFramesGroupsDirection2 = 4,
		unitFramesGroupsPadding2 = 40,

		unitFramesParts =
		{
			{
				isEnabled = true,
				type = "selectionFrame",
				id = "30",
				data =
				{
					offlineHide = true,
					anchorTo = "topleft",
					color =
					{
						255,
						255,
						255,
					},
					layer = 0,
					anchorFrom = "topleft",
					texture = "rect",
					vertical = false,
					alpha = 1,
					deadHide = false,
					scale = 1,
					distHide = false,
					size =
					{
						136,
						37,
					},
					pos =
					{
						31,
						-1,
					},
				},
				exceptMe = false,
				name = L"Selection",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "panel",
				id = "31",
				data =
				{
					offlineColor =
					{
						150,
						150,
						150,
					},
					offlineHide = false,
					anchorTo = "topleft",
					color =
					{
						0,
						0,
						0,
					},
					layer = 0,
					anchorFrom = "topleft",
					texture = "default2",
					alpha = 0.75,
					vertical = false,
					scale = 1,
					deadHide = false,
					deadColor =
					{
						200,
						50,
						50,
					},
					distHide = false,
					size =
					{
						136,
						37,
					},
					pos =
					{
						31,
						-1,
					},
				},
				exceptMe = false,
				name = L"Background",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "hpbar",
				id = "32",
				data =
				{
					anchorTo = "topleft",
					color =
					{
						150,
						190,
						255,
					},
					anchorFrom = "topleft",
					vertical = false,
					distHide = false,
					size =
					{
						129,
						30,
					},
					distAlpha = 0.5,
					wrap = false,
					alpha = 1,
					textureFullResize = true,
					deadHide = true,
					texture = "default",
					offlineHide = true,
					scale = 1,
					layer = 1,
					pos =
					{
						35,
						3,
					},
				},
				exceptMe = false,
				name = L"HP",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "apbar",
				id = "33",
				data =
				{
					offlineHide = true,
					texture = "plain",
					anchorTo = "bottomleft",
					textureFullResize = true,
					layer = 2,
					anchorFrom = "bottomleft",
					size =
					{
						128,
						3,
					},
					color =
					{
						255,
						220,
						100,
					},
					deadHide = true,
					scale = 1,
					vertical = false,
					alpha = 1,
					distHide = false,
					distAlpha = 0.5,
					pos =
					{
						35,
						0,
					},
				},
				exceptMe = false,
				name = L"AP",
				playerType = 3,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "nameText",
				id = "34",
				data =
				{
					anchorTo = "bottomleft",
					scale = 1,
					anchorFrom = "bottomleft",
					vertical = false,
					distHide = false,
					size =
					{
						129,
						30,
					},
					distColor =
					{
						190,
						225,
						255,
					},
					distAlpha = 0.5,
					align = "bottomleft",
					layer = 4,
					alpha = 1,
					deadHide = false,
					font = "font_clear_small_bold",
					texture = "aluminium",
					offlineHide = false,
					wrap = false,
					color =
					{
						255,
						255,
						255,
					},
					pos =
					{
						37,
						0,
					},
					maxLength = 10
				},
				exceptMe = false,
				name = L"Name",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "careerIcon",
				id = "35",
				data =
				{
					anchorTo = "topleft",
					color =
					{
						255,
						255,
						255,
					},
					layer = 1,
					alpha = 1,
					vertical = false,
					texture = "aluminium",
					size =
					{
						28,
						28,
					},
					anchorFrom = "topleft",
					scale = 1,
					pos =
					{
						0,
						4,
					},
				},
				exceptMe = false,
				name = L"Icon",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "levelText",
				id = "36",
				data =
				{
					anchorTo = "bottomleft",
					scale = 0.8,
					layer = 2,
					anchorFrom = "bottomleft",
					texture = "aluminium",
					vertical = false,
					alpha = 1,
					color =
					{
						255,
						255,
						255,
					},
					font = "font_clear_small_bold",
					align = "center",
					size =
					{
						30,
						20,
					},
					pos =
					{
						12,
						5,
					},
				},
				exceptMe = false,
				name = L"Level",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "groupLeaderIcon",
				id = "37",
				data =
				{
					anchorTo = "topleft",
					color =
					{
						150,
						190,
						255,
					},
					layer = 2,
					alpha = 1,
					vertical = false,
					texture = "star",
					size =
					{
						16,
						16,
					},
					anchorFrom = "topleft",
					scale = 1,
					pos =
					{
						-5,
						-1,
					},
				},
				exceptMe = false,
				name = L"Leader",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				type = "moraleBar",
				id = "38",
				data =
				{
					anchorTo = "topleft",
					color =
					{
						120,
						200,
						255,
					},
					anchorFrom = "topleft",
					vertical = false,
					prefix = L"M ",
					suffix = L"",
					distHide = false,
					texture = "4dots",
					offlineHide = true,
					layer = 3,
					alpha = 1,
					deadHide = true,
					textureFullResize = false,
					size =
					{
						38,
						10,
					},
					scale = 1,
					pos =
					{
						37,
						4,
					},
				},
				exceptMe = false,
				name = L"Morale",
				playerType = 3,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = false,
				type = "distanceText",
				id = "39",
				data =
				{
					anchorTo = "topright",
					color =
					{
						255,
						255,
						255,
					},
					farValue = 151,
					anchorFrom = "topright",
					farText = L"FAR",
					prefix = L"",
					suffix = L"",
					distHide = false,
					size =
					{
						30,
						30,
					},
					offlineHide = true,
					align = "right",
					layer = 2,
					alpha = 1,
					deadHide = true,
					font = "font_clear_small_bold",
					texture = "aluminium",
					scale = 0.9,
					vertical = false,
					pos =
					{
						-3,
						3,
					},
				},
				exceptMe = true,
				name = L"Distance",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				archetypeMatch = 1,
				playerTypeMatch = 1,
			},

			{
				isEnabled = true,
				archetypeMatch = 1,
				id = "11",
				data =
				{
					anchorTo = "topright",
					color =
					{
						190,
						255,
						50,
					},
					level1 = 65,
					anchorFrom = "topright",
					level2 = 100,
					distHide = false,
					texture = "4dots",
					offlineHide = true,
					textureFullResize = false,
					layer = 2,
					alpha = 1,
					color1 =
					{
						255,
						150,
						50,
					},
					color2 =
					{
						255,
						50,
						50,
					},
					deadHide = true,
					color3 =
					{
						255,
						50,
						50,
					},
					scale = 1,
					level3 = 150,
					size =
					{
						40,
						10,
					},
					vertical = false,
					pos =
					{
						-3,
						4,
					},
				},
				exceptMe = false,
				name = L"Distance bar",
				playerType = 1,
				archetypes =
				{
					false,
					false,
					false,
				},
				type = "distanceBar",
				playerTypeMatch = 1,
			},

			{
				archetypeMatch = 1,
				id = "254",
				data =
				{
					anchorTo = "right",
					color =
					{
						255,
						255,
						255,
					},
					anchorFrom = "right",
					vertical = false,
					prefix = L"",
					suffix = L"%",
					distHide = false,
					size =
					{
						50,
						30,
					},
					offlineHide = true,
					textureFullResize = false,
					layer = 2,
					alpha = 1,
					deadHide = true,
					scale = 0.7,
					font = "font_clear_small_bold",
					align = "rightcenter",
					texture = "3dots",
					pos =
					{
						-3,
						1,
					},
				},
				exceptMe = false,
				name = L"HP %",
				playerType = 1,
				isEnabled = false,
				archetypes =
				{
					false,
					false,
					false,
				},
				type = "hppText",
				playerTypeMatch = 1,
			},
		},

		effectsIndicators =
		{
			{
				archetypes =
				{
					false,
					false,
					false,
				},
				anchorTo = 5,
				color =
				{
					b = 127,
					g = 243,
					r = 191,
				},
				anchorFrom = 8,
				exceptMe = true,
				offsetX = 10,
				icon = "guard",
				canDispell = 1,
				isCircleIcon = false,
				id = "13",
				alpha = 1,
				archetypeMatch = 1,
				scale = 1,
				labelScale = 1,
				name = L"My guard",
				isEnabled = true,
				playerType = 3,
				offsetY = 2,
				effectFilters =
				{
					[1] =
					{
						durationType = 3,
						type = "guard",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 2,
						filterName = L"MyGuard",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					true,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						durationType = 3,
						type = "guard",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 3,
						filterName = L"NotMyGuard",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				color =
				{
					b = 255,
					g = 181,
					r = 127,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 8,
				icon = "guard",
				canDispell = 1,
				isCircleIcon = false,
				id = "14",
				alpha = 1,
				archetypeMatch = 2,
				name = L"Other guard",
				scale = 0.8,
				playerType = 3,
				anchorTo = 5,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				anchorTo = 9,
				color =
				{
					b = 119,
					g = 60,
					r = 255,
				},
				anchorFrom = 9,
				exceptMe = false,
				offsetX = -25,
				icon = "dot",
				canDispell = 2,
				isCircleIcon = false,
				id = "15",
				alpha = 1,
				archetypeMatch = 1,
				scale = 1,
				name = L"Any dispellable",
				isEnabled = true,
				playerType = 1,
				offsetY = 0,
				effectFilters =
				{
					[1] =
					{
						descriptionMatch = 2,
						castedByMe = 1,
						durationType = 2,
						hasDurationLimit = false,
						filterName = L"Any",
						nameMatch = 1,
						typeMatch = 1,
					},
				},
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				anchorTo = 9,
				color =
				{
					b = 0,
					g = 191,
					r = 255,
				},
				anchorFrom = 9,
				exceptMe = false,
				offsetX = -14,
				icon = "dot",
				canDispell = 1,
				isCircleIcon = false,
				id = "16",
				alpha = 1,
				archetypeMatch = 1,
				scale = 1,
				name = L"HoT",
				isEnabled = true,
				playerType = 1,
				offsetY = 0,
				effectFilters =
				{
					[1] =
					{
						durationType = 2,
						type = "isHealing",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 2,
						filterName = L"MyHealing",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{

					{
						durationType = 2,
						type = "isBuff",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 2,
						filterName = L"MyBuff",
						nameMatch = 1,
						descriptionMatch = 2,
					},

					{
						durationType = 2,
						type = "isHealing",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 2,
						filterName = L"MyHealing",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				color =
				{
					b = 255,
					g = 200,
					r = 50,
				},
				anchorFrom = 9,
				exceptMe = true,
				offsetX = -3,
				icon = "dot",
				canDispell = 1,
				isCircleIcon = false,
				id = "17",
				alpha = 1,
				logic = L"MyBuff and not MyHealing",
				archetypeMatch = 1,
				scale = 1,
				name = L"Buff",
				anchorTo = 9,
				playerType = 1,
				offsetY = 0,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{

					{
						durationType = 2,
						type = "isBlessing",
						filterName = L"MyBlessing",
						descriptionMatch = 2,
						castedByMe = 2,
						durationMax = 59,
						nameMatch = 1,
						hasDurationLimit = true,
						typeMatch = 1,
					},

					{
						durationType = 2,
						type = "isHealing",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 2,
						filterName = L"MyHealing",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				color =
				{
					b = 255,
					g = 200,
					r = 50,
				},
				anchorFrom = 9,
				exceptMe = false,
				offsetX = -3,
				icon = "dot",
				canDispell = 1,
				isCircleIcon = false,
				id = "18",
				alpha = 1,
				logic = L"MyBlessing and not MyHealing",
				archetypeMatch = 1,
				scale = 1,
				name = L"Blessing",
				anchorTo = 9,
				playerType = 1,
				offsetY = 0,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					true,
				},
				anchorTo = 8,
				color =
				{
					b = 64,
					g = 255,
					r = 191,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = -53,
				icon = "heal",
				canDispell = 1,
				isCircleIcon = false,
				id = "19",
				alpha = 1,
				archetypeMatch = 1,
				scale = 0.6,
				name = L"Outgoing 50% heal debuff",
				isEnabled = true,
				playerType = 1,
				offsetY = -5,
				effectFilters =
				{
					[1] =
					{
						durationType = 1,
						type = "healDebuffOut50",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 3,
						filterName = L"OutHealDebuff",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				anchorTo = 8,
				color =
				{
					b = 64,
					g = 64,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = -40,
				icon = "heal",
				canDispell = 1,
				isCircleIcon = false,
				id = "20",
				alpha = 1,
				archetypeMatch = 1,
				scale = 0.6,
				name = L"Incomming 50% heal debuff",
				isEnabled = true,
				playerType = 1,
				offsetY = -5,
				effectFilters =
				{
					[1] =
					{
						durationType = 1,
						type = "healDebuffIn50",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 3,
						filterName = L"InHealDebuff",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						durationType = 2,
						type = "stagger",
						typeMatch = 1,
						hasDurationLimit = false,
						castedByMe = 1,
						filterName = L"Stagger",
						nameMatch = 1,
						descriptionMatch = 2,
					},
				},
				color =
				{
					b = 128,
					g = 255,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 5,
				icon = "stagger",
				canDispell = 1,
				isCircleIcon = false,
				id = "21",
				alpha = 1,
				archetypeMatch = 1,
				name = L"Stagger",
				scale = 0.75,
				playerType = 1,
				anchorTo = 5,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					true,
				},
				anchorTo = 8,
				color =
				{
					b = 128,
					g = 64,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = -65,
				icon = "disabled",
				canDispell = 1,
				isCircleIcon = false,
				id = "22",
				alpha = 1,
				archetypeMatch = 1,
				scale = 0.5,
				name = L"DoK/WP regen",
				isEnabled = true,
				playerType = 1,
				offsetY = -5,
				effectFilters =
				{
					[1] =
					{
						typeMatch = 1,
						filterName = L"DoK_WP_Regen",
						abilityIds = L"9561, 8237",
						castedByMe = 1,
						nameMatch = 1,
						descriptionMatch = 2,
						abilityIdsHash =
						{
							[9561] = true,
							[8237] = true,
						},
						hasDurationLimit = false,
						durationType = 1,
					},
				},
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						typeMatch = 1,
						filterName = L"ID",
						abilityIds = L"613",
						castedByMe = 1,
						nameMatch = 1,
						descriptionMatch = 2,
						abilityIdsHash =
						{
							[613] = true,
						},
						hasDurationLimit = false,
						durationType = 2,
					},
				},
				color =
				{
					b = 255,
					g = 255,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 5,
				customIcon = 23175,
				icon = "other",
				canDispell = 1,
				isCircleIcon = false,
				id = "23",
				alpha = 1,
				archetypeMatch = 1,
				name = L"Immaculate Defense",
				scale = 0.5,
				playerType = 3,
				anchorTo = 2,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					true,
				},
				effectFilters =
				{
					[1] =
					{
						typeMatch = 1,
						filterName = L"FM",
						abilityIds = L"653, 674, 695, 3882",
						castedByMe = 1,
						nameMatch = 1,
						descriptionMatch = 2,
						abilityIdsHash =
						{
							[3882] = true,
							[674] = true,
							[653] = true,
							[695] = true,
						},
						hasDurationLimit = false,
						durationType = 2,
					},
				},
				color =
				{
					b = 255,
					g = 255,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 5,
				customIcon = 23153,
				icon = "other",
				canDispell = 1,
				isCircleIcon = false,
				id = "24",
				alpha = 1,
				archetypeMatch = 1,
				name = L"Focused Mind",
				scale = 0.5,
				playerType = 3,
				anchorTo = 2,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						typeMatch = 1,
						filterName = L"TODB",
						abilityIds = L"9616",
						castedByMe = 1,
						nameMatch = 1,
						descriptionMatch = 2,
						abilityIdsHash =
						{
							[9616] = true,
						},
						hasDurationLimit = false,
						durationType = 2,
					},
				},
				color =
				{
					b = 255,
					g = 255,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 5,
				customIcon = 10965,
				icon = "other",
				canDispell = 1,
				isCircleIcon = false,
				id = "25",
				alpha = 1,
				archetypeMatch = 1,
				name = L"1001 Dark Blessings",
				scale = 0.5,
				playerType = 3,
				anchorTo = 2,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						typeMatch = 1,
						filterName = L"GOF",
						abilityIds = L"8308",
						castedByMe = 1,
						nameMatch = 1,
						descriptionMatch = 2,
						abilityIdsHash =
						{
							[8308] = true,
						},
						hasDurationLimit = false,
						durationType = 2,
					},
				},
				color =
				{
					b = 255,
					g = 255,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 5,
				customIcon = 8042,
				icon = "other",
				canDispell = 1,
				isCircleIcon = false,
				id = "25",
				alpha = 1,
				archetypeMatch = 1,
				name = L"Gift of Life",
				scale = 0.5,
				playerType = 3,
				anchorTo = 2,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						typeMatch = 1,
						filterName = L"AnyMarkOrRune",
						abilityIds = L"3746, 8551, 8617, 3748, 8560, 8619, 20458, 3747, 8556, 8618, 3038, 3773, 8567, 8620, 1591, 3670, 20476, 1588, 1600, 3570, 1608, 3650, 3671",
						castedByMe = 2,
						nameMatch = 1,
						descriptionMatch = 2,
						abilityIdsHash =
						{
							[8560] = true,
							[1608] = true,
							[3746] = true,
							[3748] = true,
							[20458] = true,
							[8617] = true,
							[3570] = true,
							[8556] = true,
							[3671] = true,
							[20476] = true,
							[1588] = true,
							[8619] = true,
							[1600] = true,
							[3650] = true,
							[3773] = true,
							[8620] = true,
							[3670] = true,
							[3038] = true,
							[8551] = true,
							[3747] = true,
							[8567] = true,
							[1591] = true,
							[8618] = true,
						},
						hasDurationLimit = false,
						durationType = 1,
					},
				},
				color =
				{
					b = 221,
					g = 255,
					r = 0,
				},
				anchorFrom = 9,
				exceptMe = false,
				offsetX = -36,
				icon = "dot",
				canDispell = 1,
				isCircleIcon = false,
				id = "26",
				alpha = 1,
				archetypeMatch = 1,
				name = L"My marks/runes",
				scale = 1,
				playerType = 3,
				anchorTo = 9,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						durationType = 2,
						filterName = L"WordOfPain",
						descriptionMatch = 2,
						castedByMe = 1,
						abilityIds = L"9475, 20535",
						durationMax = 5,
						hasDurationLimit = true,
						abilityIdsHash =
						{
							[9475] = true,
							[20535] = true,
						},
						nameMatch = 1,
						typeMatch = 1,
					},
				},
				color =
				{
					b = 255,
					g = 255,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 6,
				customIcon = 10908,
				icon = "other",
				canDispell = 1,
				isCircleIcon = false,
				id = "27",
				alpha = 1,
				archetypeMatch = 1,
				name = L"Improved Word of Pain",
				scale = 0.5,
				playerType = 3,
				anchorTo = 2,
				isEnabled = true,
				playerTypeMatch = 1,
			},

			{
				archetypes =
				{
					false,
					false,
					false,
				},
				effectFilters =
				{
					[1] =
					{
						durationType = 2,
						filterName = L"BoilingBlood",
						descriptionMatch = 2,
						castedByMe = 1,
						abilityIds = L"8165",
						durationMax = 5,
						hasDurationLimit = true,
						abilityIdsHash =
						{
							[8165] = true,
						},
						nameMatch = 1,
						typeMatch = 1,
					},
				},
				color =
				{
					b = 255,
					g = 255,
					r = 255,
				},
				anchorFrom = 8,
				exceptMe = false,
				offsetX = 6,
				customIcon = 8015,
				icon = "other",
				canDispell = 1,
				isCircleIcon = false,
				id = "28",
				alpha = 1,
				archetypeMatch = 1,
				name = L"Improved Boiling Blood",
				scale = 0.5,
				playerType = 3,
				anchorTo = 2,
				isEnabled = true,
				playerTypeMatch = 1,
			},
		},

		clickCastings = {},

		guardEnabled = true,
		guardDistanceIndicator = 2,
		guardDistanceIndicatorMovable = true,
		guardDistanceIndicatorClickThrough = false,
		guardDistanceIndicatorWarningDistance = 30,
		guardDistanceIndicatorColorNormal = { 127, 181, 255 },
		guardDistanceIndicatorColorWarning = { 255, 50, 50 },
		guardDistanceIndicatorAlphaNormal = 0.75,
		guardDistanceIndicatorAlphaWarning = 1,
		guardDistanceIndicatorScaleNormal = 1,
		guardDistanceIndicatorScaleWarning = 1.5,
		guardDistanceIndicatorAnimation = true,
		guardMarkEnabled = true,

		scenarioAlerterEnabled = true,

		scenarioInfoEnabled = true,
		scenarioInfoReplaceStandardWindow = false,
		scenarioInfoSelection =
		{
			{
				id = "All",
				id2 = "1",
				id3 = nil,
				columns = { "db", "deaths" },
				sortColumn = "value1",
				sortDirection = false
			},
			{
				id = "All",
				id2 = "2",
				id3 = nil,
				columns = { "db", "deaths" },
				sortColumn = "value1",
				sortDirection = false
			}
		},

		talismanAlerterEnabled = true,
		talismanAlerterDisplayMode = 2,
		talismanAlerterColorWarning = { 255, 255, 100 },
		talismanAlerterAnimation = true,

		timerEnabled = true,
		timerActiveColor = { 255, 255, 75 },
		timerInactiveColor = { 255, 255, 255 },

		combatLogEnabled = true,
		combatLogIgnoreNpc = false,
		combatLogIgnoreWhenPolymorphed = true,

		combatLogLogParseErrors = true,

		combatLogStatisticsEnabled = true,
		combatLogIgnoreAbilityMinValue = 20000,

		combatLogEPSEnabled =
		{
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true
		},
		combatLogEPSTimeframe = 7.5,
		combatLogEPSMaxValueMinTime = 4.5,

		combatLogEPSShow =
		{
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true
		},

		combatLogIDSEnabled = true,
		combatLogIDSTimeframe = 7.5,
		combatLogIDSType = "dps",
		combatLogIDSMaxRows = 5,
		combatLogIDSDisplayTime = 20,
		combatLogIDSRowSize = { 250, 30 },
		combatLogIDSRowPadding = 3,
		combatLogIDSRowScale = 1,
		combatLogIDSRowBackground = { 225, 50, 50 },
		combatLogIDSRowBackgroundAlpha = 0.7,

		combatLogTargetDefenseEnabled = true,
		combatLogTargetDefenseTimeframe = 7.5,
		combatLogTargetDefenseHideTimeout = 10,
		combatLogTargetDefenseShow =
		{
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true,
			[5] = true,
			[6] = true
		},
		combatLogTargetDefenseSize = { 60, 20 },
		combatLogTargetDefenseScale = 1,
		combatLogTargetDefenseBackground = { 0, 0, 0 },
		combatLogTargetDefenseBackgroundAlpha = 0.5,
		combatLogTargetDefenseTotalEnabled = true,
		combatLogTargetDefenseTotalCalculate =
		{
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true,
			[5] = true,
			[6] = true
		},
		combatLogTargetDefenseTotalBackground = { 0, 0, 0 },
		combatLogTargetDefenseTotalBackgroundAlpha = 0.5,
	}
}
