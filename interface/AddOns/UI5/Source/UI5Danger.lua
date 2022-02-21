UI5.Danger = {}

BBplayers = {}
BBscore = {}

playerName = wstring.sub(GameData.Player.name,1,-3)
modType = true
pointsAmount = 1

local ClearThisSession = ClearThisSession
local InevitableCity = 4
local Altdorf = 3

function UI5.DangerSetup()
	RegisterEventHandler(TextLogGetUpdateEventId("Combat"), "UI5.OnChatLogUpdated")
	LibSlash.RegisterWSlashCmd(L"danger", function(args1) UI5.CheckAScore(args1) end)
	LibSlash.RegisterWSlashCmd(L"dangerclear", UI5.DangerClear())
	--RegisterEventHandler(SystemData.Events.ENTER_WORLD, "UI5.DangerClear")
	RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "UI5.DangerClear")
end

function UI5.DangerLogic()
	----------------
	--            --
	--            --
	--DANGER LEVEL--
	--            --
	--            --
	----------------

	local victimFound = false
	local killerFound = false
	
    local indexOfLastEntry = TextLogGetNumEntries("Combat") - 1;    
    local _, _, message = TextLogGetEntry("Combat", indexOfLastEntry);

	local victim, verb, killer, weapon, location = message:match(L"([%a]+) has been ([%a]+) by ([%a]+)'s ([%a%d%p  ]+) in ([^%.]+).")

	if victim == nil and killer == nil then return end

	--check for killer
	for k, v in pairs(BBplayers) do
		if v == killer then
			local scoreMod = BBscore[k]
			if victim == killer then
				-- you, or someone else, kill yourself/themselves, dumbass. 
				pointsAmount = 0
			elseif killer == playerName then
				-- the killer was you, extra points
				pointsAmount = 2
			else
				-- they just killed somewhere
				pointsAmount = 1
			end
			--give them their points
			BBscore[k] = scoreMod + pointsAmount
			killerFound = true
		end

	--check for victim
		if v == victim then
			local scoreMod = BBscore[k]
			if victim == killer then
				-- you, or someone else, kill yourself/themselves, dumbass. 
				pointsAmount = 2
			elseif victim == playerName then
				-- the killer of the victim was you, extra points
				pointsAmount = 2
			else
				-- they just died somewhere, nothing to do with you.
				pointsAmount = 1
			end
			--take from their points
			BBscore[k] = scoreMod - pointsAmount

			if BBscore[k] > 0 then 
				BBscore[k] = 0
				-- prevent negative scores
			end

			victimFound = true
		end
	end
	-- end looping
	
	if victimFound == false then
		--victim not found, let's insert them in
		table.insert(BBplayers, victim)
		table.insert(BBscore, 0)
	end
	if killerFound == false then
		--killer not found, let's insert them in
		table.insert(BBplayers, killer)
		table.insert(BBscore, 1)
	end
end

function UI5.YourScore()
	local Found = false

	TargetInfo:UpdateFromClient()
	local targetNameCheck = TargetInfo:UnitName("selffriendlytarget")

	for k, v in pairs(BBplayers) do
		if v == targetNameCheck then
			--give them their points
			BBscore[k] = 4
			Found = true
		end
	end

	if Found == false then
		--killer not found, let's insert them in
		table.insert(BBplayers, targetNameCheck)
		table.insert(BBscore, 4)
	end
end

function UI5.MyScore()
	local Found = false

	TargetInfo:UpdateFromClient()
	local targetNameCheck = GameData.Player.name

	for k, v in pairs(BBplayers) do
		if v == targetNameCheck then
			--give them their points
			BBscore[k] = 4
			Found = true
		end
	end

	if Found == false then
		--killer not found, let's insert them in
		table.insert(BBplayers, targetNameCheck)
		table.insert(BBscore, 4)
	end
end

function UI5.EnemyScore()
	local Found = false

	TargetInfo:UpdateFromClient()
	local targetNameCheck = TargetInfo:UnitName("selfhostiletarget")

	for k, v in pairs(BBplayers) do
		if v == targetNameCheck then
			--give them their points
			BBscore[k] = 4
			Found = true
		end
	end

	if Found == false then
		--killer not found, let's insert them in
		table.insert(BBplayers, targetNameCheck)
		table.insert(BBscore, 4)
	end
end

function UI5.DangerClear()
	if GameData.Player.City.id == InevitableCity or GameData.Player.City.id == Altdorf then
		if BBplayers ~= nil and BBscore ~= nil then
			BBplayers = {} 
			BBscore = {}
			d("Danger Records CLEARED.")
			TextLogAddEntry("Chat", 0, L"<icon57> UI5: Danger records CLEARED.")
		end
	end
	-- OLD METHOD BELOW
	--[[
	if ClearThisSession ~= true then
		BBplayers = {} 
		BBscore = {}
		d("Danger Records CLEARED.")
		TextLogAddEntry("Chat", 0, L"<icon57> UI5: Danger records CLEARED.")
		ClearThisSession = true
	else
		--TextLogAddEntry("Chat", 0, L"<icon57> UI5: Danger has already cleared this session.")
	end
	]]
end

function UI5.DangerSilentCheck(args1)
	for k, v in pairs(BBplayers) do
		if UI5.CompareString(WStringToString(v), WStringToString(args1)) then
			return BBscore[k]
		end
	end
	return nil
end

function UI5.ExportScores()
	for k, v in pairs(BBplayers) do
		d(tostring(BBplayers[k]).." : "..BBscore[k])
	end
	d("...FINISHED")
end

function UI5.CheckAScore(args1)
	for k, v in pairs(BBplayers) do
		if tostring(v) == tostring(args1) then
			TextLogAddEntry("Chat", 0, L"<icon57> UI5: "..StringToWString(tostring(BBplayers[k]))..L" : "..StringToWString(tostring(BBscore[k]))..L"")
			return
		end
	end
	TextLogAddEntry("Chat", 0, L"<icon57> UI5: Player not found!")
end

function UI5.DrawGlow(WindowCat, dangerScore)
	if DoesWindowExist(WindowCat.."Glow") then
		AnimatedImageStopAnimation(WindowCat.."Glow")
		DestroyWindow(WindowCat.."Glow")
	end

	CreateWindowFromTemplate(WindowCat.."Glow", "DangerGlow"..WindowCat, "Root")

	local animTex = ""

	if dangerScore == nil then
		return 
	end

	--d("DANGERSCORE: "..dangerScore)

		local glowLevel = math.floor(dangerScore / 2)

		if glowLevel > 5 then 
			--prevent anything above it
			glowLevel = 5 
		elseif glowLevel <= 0 then
			--stop
			glowLevel = 0
			--d("GLOW IS ZERO")
			AnimatedImageStopAnimation(WindowCat.."Glow")
			return
		end

		if WindowCat == "Hostile" then
			if GameData.Player.realm == 2 then
				-- target is order
				animTex = "anim_fury_round_"
			else
				-- target is destro
				animTex = "anim_waaagh_round_"
			end
			-- the target is hostile, what realm am I? this determines who the target is

		elseif WindowCat == "Friendly" then
			if GameData.Player.realm == 2 then
				-- target is destro
				animTex = "anim_waaagh_round_"
			else
				-- target is order
				animTex = "anim_fury_round_"
			end
			-- the target is friendly, what realm am I? this determines who the target is

		elseif WindowCat == "Player" then
			if GameData.Player.realm == 2 then
				-- i am destro
				animTex = "anim_waaagh_round_"
			else
				-- i am order
				animTex = "anim_fury_round_"
			end

		else
			animTex = "anim_fury_round_"
			-- just incase this doesn't work somehow?
		end
		-- TEXTURE SET
		AnimatedImageSetTexture(WindowCat.."Glow", animTex..glowLevel)
		WindowSetParent(WindowCat.."Glow", WindowCat.."MainBar")
		AnimatedImageStartAnimation(WindowCat.."Glow", 0, true, false, 0)
end