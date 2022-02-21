UI5.Party = {}

UI5.Party.Settings = {

	buffs = 			true,
	buffsAmount = 		8,
	debuffs = 			true,
	debuffAmount = 		8,
	priorityDebuffs = 	true,
	morale = 			true,
	ap = 				true,
	HUDprioDebuffs = 	true -- show the priority debuffs above your target

}

local FramesMode = {

	"HEALER",
	"DPS",
	"TANK"

}

if priorityDebuffs == nil then priorityDebuffs = {} end

function UI5.PartyOnInit()
	--register necessary events
end

function UI5.PartyBuild()
	--build the party
	if UI5.GetGroupType() == "BATTLEGROUP" then
		-- build warband frames
	elseif UI5.GetGroupType() == "GROUP" then
		-- build party frames
	else
		-- nothing
end

function UI5.PartyUpdate()
	--update data
	local UI5PartyData = PartyUtils.GetPartyData()
end

function UI5.PartyEffects()
	--update effects
end

function UI5.PartyPriorityDebuffs()
	--add a debuff to the priority debuffs
end

function UI5.GetGroupType()
	-- I want to convert the party info and the warband info into the same dataset so I can just call one thing, 
	-- build it the same, and then  build based around one type of information.
  if IsWarBandActive() then
    return "BATTLEGROUP"
  end
  if GetNumGroupmates() > 0 then
    return "GROUP"
  end
  return nil
end