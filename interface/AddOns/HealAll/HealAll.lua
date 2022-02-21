if not HealAll then HealAll = {} end

local function Print(str)
	EA_ChatWindow.Print(towstring(str))
end

function HealAll.Initialize()

	RegisterEventHandler(SystemData.Events.INTERACT_SHOW_HEALER , "HealAll.Heal");
	Print(L"<LINK data=\"0\" text=\"[HealAll]\" color=\"50,255,10\"> Addon initialized.");
	
	WindowSetShowing("EA_Window_InteractionHealer", false);
	
end

-- /script EA_Window_InteractionHealer.HealAllPenalties();
local healingInProgress = false;
function HealAll.Heal()

	WindowSetShowing("EA_Window_InteractionHealer", false);

	if (healingInProgress == true) then return end
	
	healingInProgress = true;
	
	local penalties = tonumber(EA_Window_InteractionHealer.penaltyCount);
	if not penalties or (penalties == 0) then return end

	local cost = tonumber(EA_Window_InteractionHealer.costToRemoveSinglePenalty);
	local totalCost = MoneyFrame.FormatMoneyString(penalties * cost);
	EA_Window_InteractionHealer.HealAllPenalties();
	
	if totalCost and (totalCost ~= L"") then
		Print(L"<LINK data=\"0\" text=\"[HealAll]\" color=\"50,255,10\"> Healer services cost you " .. totalCost .. L".");
	end
	
	healingInProgress = false;
	
end
