UI5.Defensives = {}

color = {
	"255,0,127", 	-- 01 pink
	"153,51,255", 	-- 02 violet
	"255,54,54", 	-- 03 red
	"51,51,255",	-- 04 deep blue
	"51,153,255", 	-- 05 sky blue
	"51,255,153", 	-- 06 lime green
	"153,153,0", 	-- 07 nurgle turd
	"255,128,0"
}

CurStats  = {}
BaseStats = {}
CalcStats = {}
StatIcons = {}

StatIcons[0]  = L"<icon=100>"
StatIcons[1]  = L"<icon=107>"
StatIcons[2]  = L"<icon=108>"
StatIcons[3]  = L"<icon=102>"
StatIcons[4]  = L"<icon=106>"
StatIcons[5]  = L"<icon=105>"
StatIcons[6]  = L"<icon=103>"
StatIcons[7]  = L"<icon=104>"	
StatIcons[8]  = L"<icon=121>"
StatIcons[9]  = L"<icon=155>"
StatIcons[10] = L"<icon=162>"
StatIcons[11] = L"<icon=164>"
StatIcons[12] = L"<icon=165>"
StatIcons[13] = L"<icon=110>"
StatIcons[14] = L"<icon=111>"
StatIcons[15] = L"<icon=112>"

function UI5.DefensivesOnInit()
	RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "UI5.DefensivesUpdateLabels")
	RegisterEventHandler(SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED, "UI5.DefensivesSetBase")
	UI5.DefensivesSetBase()
	UI5.DefensivesDraw()
	--RegisterEventHandler(SystemData.Events.PLAYER_SKILLS_UPDATED, "UI5.DefensivesUpdateLabels")
	--RegisterEventHandler(SystemData.Events.PLAYER_STATS_UPDATED, "UI5.DefensivesUpdateLabels")
end

function UI5.DefensivesUpdate(careerId)
	if careerId ~= 0 then 
		d("careerId: "..careerId) 
	else
		--draw basic stats
		--LabelSetText("Defensives1", L""..StatIcons[8]..L" : "..BaseStats[8])
		--d("0; drawing basic")
	end
	-- depending on the career you are targeting your defensives will display appropriately to them
	-- for example, if you are fighting a Sword Master it will display toughness, spirit resist, etc.
	-- it will also know your baselevel defensive stats so if it is below there will be a color indicator
	-- as well as a percentage representation toggle. 
	-- eg.
	-- Tough: -23%		or		Tough: 178 (but colored)
	--
	-- we can anchor this to the left of the player avatar window and display 3 stats
end

function UI5.DefensivesDraw()
	UI5.DefensivesGetBaseStats()
	CreateWindow(tostring("UI5Defensives"), true)
	WindowSetDimensions("UI5Defensives", 100, 100)
	WindowSetAlpha ("UI5Defensives", 1)
	--WindowAddAnchor ("UI5Defensives", "right", "TargetUI5_Player", "left", 0, 0)
	LayoutEditor.RegisterWindow ("UI5Defensives", L"UI5: Defensives", L"UI5Defensives", false, false, false, nil)
	
	--CreateWindowFromTemplate("Defensives1", "Defensives1", "UI5Defensives")
	LabelSetFont("Defensives1", "font_journal_small_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	WindowSetParent("Defensives1", "UI5Defensives")
	LabelSetFont("Defensives2", "font_journal_small_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	WindowSetParent("Defensives2", "UI5Defensives")
	LabelSetFont("Defensives3", "font_journal_small_heading", WindowUtils.FONT_DEFAULT_TEXT_LINESPACING)
	WindowSetParent("Defensives3", "UI5Defensives")
	UI5.DefensivesUpdateLabels()

end

function UI5.DefensivesSetBase()
	if GameData.Player.inCombat == false then
		UI5.DefensivesGetBaseStats()
	end
end

function UI5.DefensivesUpdateLabels()
	UI5.DefensivesCurStats()

	--LabelSetTextColor("Defensives1", 51, 255, 153)
	--LabelSetText("Defensives1", L""..CurStats[1]..L" : "..StatIcons[1]) -- ballistic
	--LabelSetText("Defensives2", L""..CurStats[4]..L" : "..StatIcons[4]) -- weaponskill
	--LabelSetText("Defensives3", L""..CurStats[8]..L" : "..StatIcons[8])


	local currentStat = CurStats[1]
	local baseStat = BaseStats[1]

	stat1per = round((CurStats[1] / BaseStats[1]) * 100)
	stat2per = round((CurStats[4] / BaseStats[4]) * 100)
	stat3per = round((CurStats[8] / BaseStats[8]) * 100)

	LabelSetText("Defensives1", L""..stat1per..L"% "..StatIcons[1]) -- ballistic
	LabelSetText("Defensives2", L""..stat2per..L"% "..StatIcons[4]) -- weaponskill
	LabelSetText("Defensives3", L""..stat3per..L"% "..StatIcons[8])

	if currentStat > baseStat then
		LabelSetTextColor("Defensives1", 51, 255, 153)
	elseif currentStat < baseStat then
		LabelSetTextColor("Defensives2", 255, 54, 54)
	elseif currentStat == baseStat then
		LabelSetTextColor("Defensives1", 255, 255, 255)
	end


	if CurStats[4] > BaseStats[4] then
		LabelSetTextColor("Defensives2", 51, 255, 153)
	elseif CurStats[4] < BaseStats[4] then
		LabelSetTextColor("Defensives2", 255, 54, 54)
	else
		LabelSetTextColor("Defensives2", 255, 255, 255)
	end


	if CurStats[8] > BaseStats[8] then
		LabelSetTextColor("Defensives3", 51, 255, 153)
	elseif CurStats[8] < BaseStats[8] then
		LabelSetTextColor("Defensives3", 255, 54, 54)
	else
		LabelSetTextColor("Defensives3", 255, 255, 255)
	end

	--local perStat1 = round((CurStats[1] / BaseStats[1]) * 100)
	--local perStat2 = round((CurStats[4] / BaseStats[4]) * 100)
	--local perStat3 = round((CurStats[8] / BaseStats[8]) * 100)

	--LabelSetTextColor("Defensives1", 51, 255, 153)
	--LabelSetTextColor("Defensives2", 51, 255, 153)
	--LabelSetTextColor("Defensives3", 255, 54, 54)
	 -- armour
end

--[[
function UI5.IconSlam()
	for k, v in pairs(Icons.careers) do
		local spits = Icons.careers[k]
		TextLogAddEntry("Chat", 0, L"<icon"..spits..L">")
		d(Icons.careers[k])
	end
end
]]

function UI5.DefensivesGetBaseStats()
	BaseStats[0]  = GetBonus(GameData.BonusTypes.EBONUS_STRENGTH, GameData.Player.Stats[GameData.Stats.STRENGTH].baseValue)
	BaseStats[1]  = GetBonus(GameData.BonusTypes.EBONUS_BALLISTICSKILL, GameData.Player.Stats[GameData.Stats.BALLISTICSKILL].baseValue)
	BaseStats[2]  = GetBonus(GameData.BonusTypes.EBONUS_INTELLIGENCE, GameData.Player.Stats[GameData.Stats.INTELLIGENCE].baseValue)
	BaseStats[3]  = GetBonus(GameData.BonusTypes.EBONUS_WILLPOWER, GameData.Player.Stats[GameData.Stats.WILLPOWER].baseValue)
	BaseStats[4]  = GetBonus(GameData.BonusTypes.EBONUS_WEAPONSKILL, GameData.Player.Stats[GameData.Stats.WEAPONSKILL].baseValue)
	BaseStats[5]  = GetBonus(GameData.BonusTypes.EBONUS_INITIATIVE, GameData.Player.Stats[GameData.Stats.INITIATIVE].baseValue)
	BaseStats[6]  = GetBonus(GameData.BonusTypes.EBONUS_TOUGHNESS, GameData.Player.Stats[GameData.Stats.TOUGHNESS].baseValue)	
	BaseStats[7]  = GetBonus(GameData.BonusTypes.EBONUS_WOUNDS, GameData.Player.Stats[GameData.Stats.WOUNDS].baseValue)
	BaseStats[8]  = GameData.Player.armorValue
	BaseStats[9]  = GetBonus(GameData.BonusTypes.EBONUS_SPIRIT_RESIST, GameData.Player.Stats[GameData.Stats.SPIRITRESIST].baseValue)
	BaseStats[10] = GetBonus(GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST, GameData.Player.Stats[GameData.Stats.ELEMENTALRESIST].baseValue)
	BaseStats[11] = GetBonus(GameData.BonusTypes.EBONUS_CORPOREAL_RESIST, GameData.Player.Stats[GameData.Stats.CORPOREALRESIST].baseValue)
	BaseStats[12] = GetBonus(GameData.BonusTypes.EBONUS_BLOCK, GameData.Player.Stats[GameData.Stats.BLOCKSKILL].baseValue)
	BaseStats[13] = (GetBonus(GameData.BonusTypes.EBONUS_WEAPONSKILL, GameData.Player.Stats[GameData.Stats.WEAPONSKILL].baseValue)/(GameData.Player.level*7.5+50)*13.5)+(GetBonus(GameData.BonusTypes.EBONUS_PARRY, (GameData.Player.Stats[GameData.Stats.PARRYSKILL].baseValue / 100)))
	BaseStats[14] = (GetBonus(GameData.BonusTypes.EBONUS_INITIATIVE, GameData.Player.Stats[GameData.Stats.INITIATIVE].baseValue)/(GameData.Player.level*7.5+50)*13.5)+(GetBonus(GameData.BonusTypes.EBONUS_EVADE, (GameData.Player.Stats[GameData.Stats.EVADESKILL].baseValue / 100)))
	BaseStats[15] = ((GetBonus(GameData.BonusTypes.EBONUS_WILLPOWER, GameData.Player.Stats[GameData.Stats.WILLPOWER].baseValue)/(GameData.Player.level*7.5+50)*13.5)+(GetBonus(GameData.BonusTypes.EBONUS_DISRUPT, (GameData.Player.Stats[GameData.Stats.DISRUPTSKILL].baseValue / 100))))
end

function UI5.DefensivesCurStats()
	CurStats[0] = GetBonus(GameData.BonusTypes.EBONUS_STRENGTH, GameData.Player.Stats[GameData.Stats.STRENGTH].baseValue)
	CurStats[1] = GetBonus(GameData.BonusTypes.EBONUS_BALLISTICSKILL, GameData.Player.Stats[GameData.Stats.BALLISTICSKILL].baseValue)
	CurStats[2] = GetBonus(GameData.BonusTypes.EBONUS_INTELLIGENCE, GameData.Player.Stats[GameData.Stats.INTELLIGENCE].baseValue)
	CurStats[3] = GetBonus(GameData.BonusTypes.EBONUS_WILLPOWER, GameData.Player.Stats[GameData.Stats.WILLPOWER].baseValue)
	CurStats[4] = GetBonus(GameData.BonusTypes.EBONUS_WEAPONSKILL, GameData.Player.Stats[GameData.Stats.WEAPONSKILL].baseValue)
	CurStats[5] = GetBonus(GameData.BonusTypes.EBONUS_INITIATIVE, GameData.Player.Stats[GameData.Stats.INITIATIVE].baseValue)
	CurStats[6] = GetBonus(GameData.BonusTypes.EBONUS_TOUGHNESS, GameData.Player.Stats[GameData.Stats.TOUGHNESS].baseValue)
	CurStats[7] = GetBonus(GameData.BonusTypes.EBONUS_WOUNDS, GameData.Player.Stats[GameData.Stats.WOUNDS].baseValue)
	CurStats[8] = GameData.Player.armorValue
	CurStats[9] = GetBonus(GameData.BonusTypes.EBONUS_SPIRIT_RESIST, GameData.Player.Stats[GameData.Stats.SPIRITRESIST].baseValue)
	CurStats[10] = GetBonus(GameData.BonusTypes.EBONUS_ELEMENTAL_RESIST, GameData.Player.Stats[GameData.Stats.ELEMENTALRESIST].baseValue)
	CurStats[11] = GetBonus(GameData.BonusTypes.EBONUS_CORPOREAL_RESIST, GameData.Player.Stats[GameData.Stats.CORPOREALRESIST].baseValue)
	CurStats[12] = GetBonus(GameData.BonusTypes.EBONUS_BLOCK, GameData.Player.Stats[GameData.Stats.BLOCKSKILL].baseValue)
	CurStats[13] = (GetBonus(GameData.BonusTypes.EBONUS_WEAPONSKILL, GameData.Player.Stats[GameData.Stats.WEAPONSKILL].baseValue)/(GameData.Player.level*7.5+50)*13.5)+(GetBonus(GameData.BonusTypes.EBONUS_PARRY, (GameData.Player.Stats[GameData.Stats.PARRYSKILL].baseValue / 100)))	
	CurStats[14] = (GetBonus(GameData.BonusTypes.EBONUS_INITIATIVE, GameData.Player.Stats[GameData.Stats.INITIATIVE].baseValue)/(GameData.Player.level*7.5+50)*13.5)+(GetBonus(GameData.BonusTypes.EBONUS_EVADE, (GameData.Player.Stats[GameData.Stats.EVADESKILL].baseValue / 100)))
	CurStats[15] = ((GetBonus(GameData.BonusTypes.EBONUS_WILLPOWER, GameData.Player.Stats[GameData.Stats.WILLPOWER].baseValue)/(GameData.Player.level*7.5+50)*13.5)+(GetBonus(GameData.BonusTypes.EBONUS_DISRUPT, (GameData.Player.Stats[GameData.Stats.DISRUPTSKILL].baseValue / 100))))
--[[
	for k, v in pairs(CurStats) do
		d(CurStats[k])
	end
]]
end

function UI5.DefensivesCalStats()
	-- something else?
	CalcStats[0] = L"+"..math.floor((CurStats[0]/5))
	CalcStats[1] = L"+"..math.floor((CurStats[1]/5))
	CalcStats[2] = L"+"..math.floor((CurStats[2]/5))
	CalcStats[3] = L"+"..math.floor((CurStats[3]/5))
	CalcStats[4] = math.floor(((CurStats[4]/(GameData.Player.level*7.5+50)*.25)*100.0))..L"%"
	CalcStats[5] = math.floor((GameData.Player.level*7.5+50)/10/(CurStats[5])*100)..L"%"
	CalcStats[6] = L"-"..math.floor((CurStats[6]/5))
	CalcStats[7] = CurStats[7]*10
	CalcStats[8] = wstring.format(L"%.01f", (CurStats[8] * 0.909) / GameData.Player.level)..L"%"
	CalcStats[9] = wstring.format(L"%.01f",CurStats[9]/ (GameData.Player.level * 0.42))..L"%"
	CalcStats[10] = wstring.format(L"%.01f",CurStats[10]/ (GameData.Player.level * 0.42))..L"%"
	CalcStats[11] = wstring.format(L"%.01f",CurStats[11]/ (GameData.Player.level * 0.42))..L"%"
	CalcStats[12] = math.floor(((CharacterWindow.equipmentData[GameData.EquipSlots.LEFT_HAND].blockRating)/(GameData.Player.level*7.5+50)*20))..L"%"
	CalcStats[13] = math.floor(CurStats[4] / (GameData.Player.level * 7.5 + 50) * 13.5)..L"%"
	CalcStats[14] = math.floor(CurStats[5] / (GameData.Player.level * 7.5 + 50) * 13.5)..L"%"
	CalcStats[15] = math.floor(CurStats[3] / (GameData.Player.level * 7.5 + 50) * 13.5)..L"%"
end