Enemy.Settings = 
{
	combatLogIgnoreAbilityMinValue = 20000,
	combatLogTargetDefenseShow = 
	{
		true,
		true,
		true,
		true,
		true,
		true,
	},
	prevVersion = 279,
	combatLogTargetDefenseHideTimeout = 10,
	guardDistanceIndicatorAnimation = true,
	groupIconsOtherGroupsAlpha = 1,
	debug = false,
	combatLogIDSEnabled = true,
	unitFramesDirection1 = 2,
	groupIconsPetScale = 1,
	unitFramesMyGroupOnly = false,
	soundOnNewTarget = false,
	guardDistanceIndicatorAlphaNormal = 0.75,
	talismanAlerterColorWarning = 
	{
		255,
		255,
		100,
	},
	talismanAlerterAnimation = true,
	combatLogIDSRowPadding = 3,
	killSpamKilledByYouSound = 219,
	combatLogTargetDefenseSize = 
	{
		60,
		20,
	},
	guardDistanceIndicatorWarningDistance = 30,
	combatLogTargetDefenseTotalBackgroundAlpha = 0.5,
	groupIconsPetLayer = 0,
	combatLogIDSDisplayTime = 20,
	combatLogIgnoreNpc = false,
	groupIconsEnabled = true,
	groupIconsBGColor = 
	{
		200,
		255,
		0,
	},
	groupIconsOffset = 
	{
		0,
		50,
	},
	combatLogTargetDefenseBackgroundAlpha = 0.5,
	combatLogIDSType = "dps",
	groupIconsPetIconColor = 
	{
		255,
		100,
		200,
	},
	combatLogIDSRowBackgroundAlpha = 0.7,
	clickCastings = 
	{
		[1] = 
		{
			keyModifiers = 
			{
				false,
				false,
				false,
			},
			action = 1,
			mouseButton = 1,
			exceptMe = false,
			abilityId = 1674,
			name = L"Guard",
			archetypes = 
			{
				false,
				false,
				false,
			},
			playerType = 1,
			isEnabled = true,
			archetypeMatch = 1,
			playerTypeMatch = 1,
		},
	},
	unitFramesDetachMyGroup = true,
	unitFramesHideWhenSolo = true,
	groupIconsBGAlpha = 0.5,
	effectsIndicators = 
	{
		
		{
			archetypes = 
			{
				false,
				false,
				false,
			},
			labelScale = 1,
			anchorTo = 5,
			scale = 1,
			left = 0,
			exceptMe = true,
			ticked = 0,
			offsetX = 10,
			icon = "guard",
			canDispell = 1,
			isCircleIcon = false,
			id = "2860",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 8,
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
			name = L"My guard",
			isEnabled = true,
			playerType = 3,
			offsetY = 2,
			color = 
			{
				b = 127,
				g = 243,
				r = 191,
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
			scale = 0.8,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = 8,
			icon = "guard",
			canDispell = 1,
			isCircleIcon = false,
			id = "2861",
			alpha = 1,
			archetypeMatch = 2,
			anchorFrom = 8,
			name = L"Other guard",
			anchorTo = 5,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 255,
				g = 181,
				r = 127,
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
			scale = 1,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = -25,
			icon = "dot",
			canDispell = 2,
			isCircleIcon = false,
			id = "2862",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 9,
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
			name = L"Any dispellable",
			isEnabled = true,
			playerType = 1,
			offsetY = 0,
			color = 
			{
				b = 119,
				g = 60,
				r = 255,
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
			scale = 1,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = -14,
			icon = "dot",
			canDispell = 1,
			isCircleIcon = false,
			id = "2863",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 9,
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
			name = L"HoT",
			isEnabled = true,
			playerType = 1,
			offsetY = 0,
			color = 
			{
				b = 0,
				g = 191,
				r = 255,
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
			scale = 1,
			left = 0,
			exceptMe = true,
			ticked = 0,
			offsetX = -3,
			logic = L"MyBuff and not MyHealing",
			canDispell = 1,
			isCircleIcon = false,
			id = "2864",
			icon = "dot",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 9,
			isEnabled = true,
			name = L"Buff",
			color = 
			{
				b = 255,
				g = 200,
				r = 50,
			},
			playerType = 1,
			offsetY = 0,
			anchorTo = 9,
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
			scale = 1,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = -3,
			logic = L"MyBlessing and not MyHealing",
			canDispell = 1,
			isCircleIcon = false,
			id = "2865",
			icon = "dot",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 9,
			isEnabled = true,
			name = L"Blessing",
			color = 
			{
				b = 255,
				g = 200,
				r = 50,
			},
			playerType = 1,
			offsetY = 0,
			anchorTo = 9,
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
			scale = 0.6,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = -53,
			icon = "heal",
			canDispell = 1,
			isCircleIcon = false,
			id = "2866",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 8,
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
			name = L"Outgoing 50% heal debuff",
			isEnabled = true,
			playerType = 1,
			offsetY = -5,
			color = 
			{
				b = 64,
				g = 255,
				r = 191,
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
			scale = 0.6,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = -40,
			icon = "heal",
			canDispell = 1,
			isCircleIcon = false,
			id = "2867",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 8,
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
			name = L"Incomming 50% heal debuff",
			isEnabled = true,
			playerType = 1,
			offsetY = -5,
			color = 
			{
				b = 64,
				g = 64,
				r = 255,
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
			scale = 0.75,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = 5,
			icon = "stagger",
			canDispell = 1,
			isCircleIcon = false,
			id = "2868",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 8,
			name = L"Stagger",
			anchorTo = 5,
			playerType = 1,
			isEnabled = true,
			color = 
			{
				b = 128,
				g = 255,
				r = 255,
			},
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
			scale = 0.5,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = -65,
			icon = "disabled",
			canDispell = 1,
			isCircleIcon = false,
			id = "2869",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 8,
			effectFilters = 
			{
				[1] = 
				{
					typeMatch = 1,
					filterName = L"DoK_WP_Regen",
					abilityIds = L"9561, 8237",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[9561] = true,
						[8237] = true,
					},
					hasDurationLimit = false,
					durationType = 1,
				},
			},
			name = L"DoK/WP regen",
			isEnabled = true,
			playerType = 1,
			offsetY = -5,
			color = 
			{
				b = 128,
				g = 64,
				r = 255,
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
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[613] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			scale = 0.5,
			anchorFrom = 8,
			exceptMe = false,
			ticked = 0,
			offsetX = 5,
			customIcon = 23175,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "2870",
			alpha = 1,
			archetypeMatch = 1,
			left = 0,
			name = L"Immaculate Defense",
			anchorTo = 2,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
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
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[3882] = true,
						[695] = true,
						[674] = true,
						[653] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			scale = 0.5,
			anchorFrom = 8,
			exceptMe = false,
			ticked = 0,
			offsetX = 5,
			customIcon = 23153,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "2871",
			alpha = 1,
			archetypeMatch = 1,
			left = 0,
			name = L"Focused Mind",
			anchorTo = 2,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
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
					filterName = L"TODB",
					abilityIds = L"9616",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[9616] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			scale = 0.5,
			anchorFrom = 8,
			exceptMe = false,
			ticked = 0,
			offsetX = 5,
			customIcon = 10965,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "2872",
			alpha = 1,
			archetypeMatch = 1,
			left = 0,
			name = L"1001 Dark Blessings",
			anchorTo = 2,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
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
					filterName = L"GOF",
					abilityIds = L"8308",
					castedByMe = 1,
					descriptionMatch = 2,
					nameMatch = 1,
					abilityIdsHash = 
					{
						[8308] = true,
					},
					hasDurationLimit = false,
					durationType = 2,
				},
			},
			scale = 0.5,
			anchorFrom = 8,
			exceptMe = false,
			ticked = 0,
			offsetX = 5,
			customIcon = 8042,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "2873",
			alpha = 1,
			archetypeMatch = 1,
			left = 0,
			name = L"Gift of Life",
			anchorTo = 2,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
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
					filterName = L"AnyMarkOrRune",
					abilityIds = L"3746, 8551, 8617, 3748, 8560, 8619, 20458, 3747, 8556, 8618, 3038, 3773, 8567, 8620, 1591, 3670, 20476, 1588, 1600, 3570, 1608, 3650, 3671",
					castedByMe = 2,
					descriptionMatch = 2,
					nameMatch = 1,
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
			scale = 1,
			left = 0,
			exceptMe = false,
			ticked = 0,
			offsetX = -36,
			icon = "dot",
			canDispell = 1,
			isCircleIcon = false,
			id = "2874",
			alpha = 1,
			archetypeMatch = 1,
			anchorFrom = 9,
			name = L"My marks/runes",
			anchorTo = 9,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 221,
				g = 255,
				r = 0,
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
			scale = 0.5,
			anchorFrom = 8,
			exceptMe = false,
			ticked = 0,
			offsetX = 6,
			customIcon = 10908,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "2875",
			alpha = 1,
			archetypeMatch = 1,
			left = 0,
			name = L"Improved Word of Pain",
			anchorTo = 2,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
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
			scale = 0.5,
			anchorFrom = 8,
			exceptMe = false,
			ticked = 0,
			offsetX = 6,
			customIcon = 8015,
			icon = "other",
			canDispell = 1,
			isCircleIcon = false,
			id = "2876",
			alpha = 1,
			archetypeMatch = 1,
			left = 0,
			name = L"Improved Boiling Blood",
			anchorTo = 2,
			playerType = 3,
			isEnabled = true,
			color = 
			{
				b = 255,
				g = 255,
				r = 255,
			},
			playerTypeMatch = 1,
		},
	},
	groupIconsPetHPBGColor = 
	{
		100,
		0,
		0,
	},
	unitFramesDirection2 = 4,
	guardMarkTemplate = 
	{
		color = 
		{
			65,
			150,
			255,
		},
		unique = false,
		firstLetters = 4,
		showCareerIcon = false,
		canClearOnClick = false,
		permanentTargets = 
		{
		},
		id = 5,
		targetOnClick = true,
		alpha = 1,
		layer = 3,
		text = L"G",
		font = "font_default_text_giant",
		name = L"",
		scale = 0.8,
		display = 1,
		offsetY = 75,
		neverExpire = true,
		permanent = false,
	},
	groupIconsOtherGroupsHPBGColor = 
	{
		50,
		100,
		100,
	},
	unitFramesSorting = 
	{
		1,
		2,
		3,
	},
	objectWindowsInactiveTimeout = 1200,
	unitFramesGroupsCount1 = 3,
	killSpamEnabled = true,
	groupIconsParts = 
	{
	},
	groupIconsOtherGroupsOffset = 
	{
		0,
		50,
	},
	groupIconsOtherGroupsBGColor = 
	{
		200,
		255,
		255,
	},
	unitFramesGroupsPadding2 = 40,
	talismanAlerterEnabled = true,
	groupIconsLayer = 0,
	groupIconsPetHPColor = 
	{
		255,
		225,
		255,
	},
	combatLogIDSTimeframe = 7.5,
	unitFramesHideMyGroup = false,
	groupIconsHPBGColor = 
	{
		0,
		100,
		0,
	},
	timerEnabled = true,
	killSpamListBottomUp = true,
	groupIconsScale = 1,
	playerKills = 12,
	combatLogIDSMaxRows = 5,
	groupIconsPetAlpha = 1,
	combatLogTargetDefenseTimeframe = 7.5,
	combatLogTargetDefenseEnabled = true,
	markNewTarget = true,
	unitFramesTooltipMode = "always",
	unitFramesGroupsDirection1 = 2,
	combatLogEPSTimeframe = 7.5,
	combatLogEPSMaxValueMinTime = 4.5,
	combatLogTargetDefenseTotalBackground = 
	{
		0,
		0,
		0,
	},
	objectWindowsTimeout = 20,
	combatLogIgnoreWhenPolymorphed = true,
	combatLogIDSRowBackground = 
	{
		225,
		50,
		50,
	},
	unitFramesPadding2 = 20,
	combatLogEPSEnabled = 
	{
		true,
		true,
		true,
		true,
	},
	unitFramesLayer = 1,
	groupIconsOtherGroupsScale = 0.6,
	targetShowDelay = 8,
	assistTargetOnNotifyClick = true,
	scenarioInfoReplaceStandardWindow = false,
	unitFramesTestMode = false,
	markTemplates = 
	{
		
		{
			scale = 1,
			firstLetters = 4,
			showCareerIcon = true,
			canClearOnClick = true,
			permanentTargets = 
			{
			},
			id = 1,
			layer = 3,
			alpha = 1,
			text = L"",
			color = 
			{
				191,
				255,
				0,
			},
			font = "font_clear_large_bold",
			name = L"A",
			targetOnClick = true,
			display = 2,
			offsetY = 50,
			neverExpire = false,
			permanent = false,
		},
		
		{
			scale = 1,
			firstLetters = 4,
			showCareerIcon = true,
			canClearOnClick = true,
			permanentTargets = 
			{
				[L"Rhalli"] = false,
				[L"Brodda"] = false,
				[L"Gaera"] = false,
				[L"Pumpkin"] = false,
				[L"Lewis"] = false,
			},
			id = 2,
			layer = 3,
			alpha = 1,
			text = L"",
			color = 
			{
				255,
				64,
				255,
			},
			font = "font_clear_large_bold",
			name = L"B",
			targetOnClick = true,
			display = 2,
			offsetY = 50,
			neverExpire = false,
			permanent = true,
		},
		
		{
			scale = 1,
			firstLetters = 4,
			showCareerIcon = false,
			canClearOnClick = true,
			permanentTargets = 
			{
			},
			id = 3,
			layer = 3,
			alpha = 1,
			text = L"G",
			color = 
			{
				65,
				150,
				255,
			},
			font = "font_default_text_giant",
			name = L"G",
			targetOnClick = true,
			display = 1,
			offsetY = 50,
			neverExpire = false,
			permanent = false,
		},
	},
	talismanAlerterDisplayMode = 2,
	unitFramesSize = 
	{
		164,
		32,
	},
	guardDistanceIndicatorScaleWarning = 1.5,
	scenarioInfoPlayers = 
	{
		
		{
			deaths = 1,
			renown = 0,
			healing = 4314,
			soloKills = 0,
			damage = 14370,
			kills = 1,
			name = L"Sepulture",
			exp = 320,
			db = 0,
			level = 40,
			career = 22,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 3774,
			soloKills = 0,
			damage = 6974,
			kills = 2,
			name = L"Pblpblcka",
			exp = 50,
			db = 0,
			level = 40,
			career = 8,
			realm = 2,
		},
		
		{
			deaths = 2,
			renown = 0,
			healing = 0,
			soloKills = 369,
			damage = 7920,
			kills = 1,
			name = L"Sabateczka",
			exp = 1245,
			db = 0,
			level = 40,
			career = 22,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 8865,
			soloKills = 0,
			damage = 18419,
			kills = 2,
			name = L"Badteef",
			exp = 0,
			db = 1,
			level = 40,
			career = 6,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 2,
			healing = 8957,
			soloKills = 852,
			damage = 11500,
			kills = 13,
			name = L"Gaffamoi",
			exp = 2215,
			db = 0,
			level = 40,
			career = 12,
			realm = 1,
		},
		
		{
			deaths = 3,
			renown = 0,
			healing = 2845,
			soloKills = 3029,
			damage = 812,
			kills = 2,
			name = L"Korhan",
			exp = 100,
			db = 0,
			level = 40,
			career = 14,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 5487,
			soloKills = 2105,
			damage = 159,
			kills = 8,
			name = L"Xoneta",
			exp = 160,
			db = 0,
			level = 40,
			career = 12,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 8928,
			soloKills = 3686,
			damage = 0,
			kills = 1,
			name = L"Toadstool",
			exp = 220,
			db = 0,
			level = 40,
			career = 7,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 0,
			soloKills = 0,
			damage = 5242,
			kills = 8,
			name = L"Fauztus",
			exp = 0,
			db = 0,
			level = 40,
			career = 19,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 1419,
			soloKills = 0,
			damage = 21373,
			kills = 2,
			name = L"Talladega",
			exp = 1235,
			db = 0,
			level = 40,
			career = 24,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 18141,
			soloKills = 6124,
			damage = 252,
			kills = 12,
			name = L"Aruf",
			exp = 3475,
			db = 0,
			level = 40,
			career = 3,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 556,
			soloKills = 4238,
			damage = 16108,
			kills = 10,
			name = L"Steakkos",
			exp = 3735,
			db = 1,
			level = 40,
			career = 1,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 27544,
			soloKills = 7974,
			damage = 24523,
			kills = 5,
			name = L"Rydiak",
			exp = 1670,
			db = 0,
			level = 40,
			career = 12,
			realm = 1,
		},
		
		{
			deaths = 2,
			renown = 0,
			healing = 3330,
			soloKills = 0,
			damage = 16711,
			kills = 2,
			name = L"Plaguegod",
			exp = 1290,
			db = 0,
			level = 40,
			career = 16,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 3815,
			soloKills = 0,
			damage = 24037,
			kills = 9,
			name = L"Tipunch",
			exp = 1405,
			db = 2,
			level = 40,
			career = 19,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 1309,
			soloKills = 1930,
			damage = 1015,
			kills = 1,
			name = L"Mempamal",
			exp = 0,
			db = 0,
			level = 40,
			career = 5,
			realm = 2,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 665,
			soloKills = 8522,
			damage = 1330,
			kills = 1,
			name = L"Bulky",
			exp = 0,
			db = 0,
			level = 40,
			career = 5,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 3,
			healing = 784,
			soloKills = 937,
			damage = 42925,
			kills = 10,
			name = L"Anety",
			exp = 1175,
			db = 4,
			level = 40,
			career = 20,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 0,
			soloKills = 0,
			damage = 17773,
			kills = 12,
			name = L"Methedron",
			exp = 1170,
			db = 3,
			level = 40,
			career = 18,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 2047,
			soloKills = 9621,
			damage = 5561,
			kills = 1,
			name = L"Frowntown",
			exp = 1155,
			db = 0,
			level = 40,
			career = 13,
			realm = 2,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 2096,
			soloKills = 0,
			damage = 8334,
			kills = 6,
			name = L"Hrudtgard",
			exp = 5,
			db = 2,
			level = 40,
			career = 2,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 3,
			healing = 5325,
			soloKills = 8191,
			damage = 8482,
			kills = 6,
			name = L"Dustmaker",
			exp = 0,
			db = 2,
			level = 40,
			career = 20,
			realm = 1,
		},
		
		{
			deaths = 0,
			renown = 0,
			healing = 18926,
			soloKills = 5748,
			damage = 0,
			kills = 12,
			name = L"Mirabella",
			exp = 1060,
			db = 0,
			level = 40,
			career = 3,
			realm = 1,
		},
		
		{
			deaths = 1,
			renown = 0,
			healing = 3421,
			soloKills = 0,
			damage = 23013,
			kills = 1,
			name = L"Kooko",
			exp = 0,
			db = 1,
			level = 40,
			career = 22,
			realm = 2,
		},
	},
	timerInactiveColor = 
	{
		255,
		255,
		255,
	},
	unitFramesSortingEnabled = true,
	newTargetMarkTemplate = 
	{
		color = 
		{
			b = 0,
			g = 0,
			r = 255,
		},
		unique = false,
		firstLetters = 4,
		showCareerIcon = true,
		canClearOnClick = true,
		permanentTargets = 
		{
		},
		id = 1,
		targetOnClick = true,
		alpha = 1,
		layer = 3,
		text = L"KILL",
		font = "font_clear_large_bold",
		name = L"",
		scale = 1,
		display = 1,
		offsetY = 50,
		neverExpire = false,
		permanent = false,
	},
	groupIconsPetBGAlpha = 0.5,
	stateMachineThrottle = 0.3,
	unitFramesScale = 1.05,
	groupIconsOtherGroupsHPColor = 
	{
		200,
		255,
		255,
	},
	combatLogTargetDefenseBackground = 
	{
		0,
		0,
		0,
	},
	groupIconsPetOffset = 
	{
		0,
		20,
	},
	timerActiveColor = 
	{
		255,
		255,
		75,
	},
	scenarioInfoData = 
	{
		maxTimer = 120,
		startingScenario = 0,
		destructionPoints = 43,
		id = 2007,
		queuedWithGroup = false,
		activeQueue = 0,
		pointMax = 500,
		mode = 2,
		timeLeft = 96.178875732236,
		orderPoints = 500,
	},
	guardDistanceIndicator = 2,
	unitFramesIsVertical = false,
	intercomPrivate = true,
	guardMarkEnabled = true,
	groupIconsAlpha = 1,
	combatLogEPSShow = 
	{
		true,
		true,
		true,
		true,
	},
	combatLogLogParseErrors = true,
	guardDistanceIndicatorMovable = true,
	version = 279,
	groupIconsTargetOnClick = true,
	guardDistanceIndicatorClickThrough = false,
	chatThrottleDelay = 1,
	playerDeaths = 9,
	guardDistanceIndicatorAlphaWarning = 1,
	unitFramesEnabled = true,
	killSpamReparseChunkSize = 20,
	groupIconsOtherGroupsLayer = 0,
	groupIconsHPColor = 
	{
		200,
		255,
		0,
	},
	chatDelay = 1,
	combatLogStatisticsEnabled = true,
	combatLogIDSRowSize = 
	{
		250,
		30,
	},
	guardDistanceIndicatorColorNormal = 
	{
		127,
		181,
		255,
	},
	unitFramesParts = 
	{
		
		{
			archetypeMatch = 1,
			id = "2848",
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
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "selectionFrame",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2849",
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
				deadColor = 
				{
					50,
					50,
					50,
				},
				layer = 0,
				alpha = 0.75,
				texture = "default2",
				size = 
				{
					136,
					37,
				},
				deadHide = false,
				scale = 1,
				color = 
				{
					0,
					0,
					0,
				},
				vertical = false,
				distHide = false,
				anchorFrom = "topleft",
				pos = 
				{
					31,
					-1,
				},
			},
			exceptMe = false,
			name = L"Background",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "panel",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2850",
			data = 
			{
				texture = "default",
				offlineHide = true,
				anchorTo = "topleft",
				distAlpha = 0.5,
				scale = 1,
				layer = 1,
				anchorFrom = "topleft",
				color = 
				{
					175,
					0,
					0,
				},
				textureFullResize = true,
				vertical = false,
				alpha = 1,
				deadHide = true,
				size = 
				{
					129,
					30,
				},
				distHide = false,
				wrap = false,
				pos = 
				{
					35,
					3,
				},
			},
			exceptMe = false,
			name = L"HP",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "hpbar",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2851",
			data = 
			{
				offlineHide = true,
				texture = "plain",
				anchorTo = "bottomleft",
				textureFullResize = true,
				layer = 2,
				anchorFrom = "bottomleft",
				distAlpha = 0.5,
				color = 
				{
					255,
					225,
					0,
				},
				deadHide = true,
				alpha = 1,
				scale = 1,
				vertical = false,
				distHide = false,
				size = 
				{
					128,
					3,
				},
				pos = 
				{
					35,
					0,
				},
			},
			exceptMe = false,
			name = L"AP",
			playerType = 3,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "apbar",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2852",
			data = 
			{
				anchorTo = "bottomright",
				scale = 1,
				anchorFrom = "bottomright",
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
				maxLength = 10,
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
			},
			exceptMe = false,
			name = L"Name",
			playerType = 1,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "nameText",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2853",
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
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "careerIcon",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2854",
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
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "levelText",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2855",
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
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "groupLeaderIcon",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2856",
			data = 
			{
				texture = "4dots",
				offlineHide = true,
				alpha = 1,
				anchorTo = "topleft",
				scale = 1,
				layer = 3,
				anchorFrom = "topleft",
				size = 
				{
					38,
					10,
				},
				deadHide = true,
				vertical = false,
				prefix = L"M ",
				suffix = L"",
				textureFullResize = false,
				distHide = false,
				color = 
				{
					120,
					200,
					255,
				},
				pos = 
				{
					37,
					4,
				},
			},
			exceptMe = false,
			name = L"Morale",
			playerType = 3,
			isEnabled = true,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "moraleBar",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2857",
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
			isEnabled = false,
			archetypes = 
			{
				false,
				false,
				false,
			},
			type = "distanceText",
			playerTypeMatch = 1,
		},
		
		{
			archetypeMatch = 1,
			id = "2858",
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
			isEnabled = false,
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
			id = "2859",
			data = 
			{
				anchorTo = "right",
				scale = 0.7,
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
				color = 
				{
					255,
					255,
					255,
				},
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
	unitFramesPadding1 = 3,
	guardEnabled = true,
	guardDistanceIndicatorColorWarning = 
	{
		255,
		50,
		50,
	},
	groupIconsOtherGroupsBGAlpha = 0.5,
	playerKDRDisplayMode = 5,
	groupIconsShowOnMarkedPlayers = false,
	groupIconsHideOnSelf = true,
	scenarioAlerterEnabled = true,
	combatLogTargetDefenseTotalCalculate = 
	{
		true,
		true,
		true,
		true,
		true,
		true,
	},
	unitFramesCount1 = 6,
	guardDistanceIndicatorScaleNormal = 1,
	combatLogIDSRowScale = 1,
	combatLogTargetDefenseTotalEnabled = true,
	groupIconsShowOtherGroups = true,
	groupIconsPetBGColor = 
	{
		255,
		225,
		255,
	},
	unitFramesGroupsPadding1 = 40,
	scenarioInfoSelection = 
	{
		
		{
			sortColumn = "value1",
			columns = 
			{
				"db",
				"deaths",
			},
			sortDirection = false,
			id2 = "1",
			id = "All",
		},
		
		{
			sortColumn = "value1",
			columns = 
			{
				"db",
				"deaths",
			},
			sortDirection = false,
			id2 = "2",
			id = "All",
		},
	},
	scenarioInfoEnabled = true,
	soundOnNewTargetId = 500,
	unitFramesMyGroupFirst = true,
	combatLogTargetDefenseScale = 1,
	unitFramesGroupsDirection2 = 4,
	combatLogEnabled = true,
}



