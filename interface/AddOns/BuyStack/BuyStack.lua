BuyStack = {}

local default_cmd = "bs"
local keys = {}
keys["shift"] = tonumber(SystemData.ButtonFlags.SHIFT)
keys["ctrl"] = tonumber(SystemData.ButtonFlags.CONTROL)
keys["alt"] = tonumber(SystemData.ButtonFlags.ALT)
keys["shift+ctrl"] = keys["shift"] + keys["ctrl"]
keys["shift+alt"] =  keys["shift"] + keys["alt"]
keys["alt+ctrl"] =  keys["alt"] + keys["ctrl"]
keys["shift+alt+ctrl"] =  keys["shift"] + keys["alt"] + keys["ctrl"]

local PlayerName = WStringToString(GameData.Player.name)
PlayerName = string.sub(PlayerName,1,string.len(PlayerName)-2) 

	local function print(txt)
	EA_ChatWindow.Print(towstring("[BS] "..txt))
end

local defaultsettings =
{
	StackSize = 20, -- how much to buy with one click
	BuyMouse = "left",
	BuyKey = keys["ctrl"],
	AutoBuyMouse = "left",
	AutoBuyKey = keys["alt"] + keys["ctrl"],
	AutoBuy = {},
}

function GetModifier(key)
  for k, v in pairs(keys) do
		if v == key then
			return k
		end
	end
	return ""
end	
	
function BuyStack.Initialize()
	if not BuyStackSettings then
		BuyStackSettings = {}
	end

	BuyStackSettings.Version = "1.2"

	if not BuyStackSettings[PlayerName] then
		BuyStackSettings[PlayerName] = {}
	end

	for k,v in pairs(defaultsettings) do
		if not BuyStackSettings[PlayerName][k] then BuyStackSettings[PlayerName][k] = v end
	end

	if LibSlash.IsSlashCmdRegistered("bs") then
		default_cmd = "buystack"
	end

	LibSlash.RegisterSlashCmd(default_cmd, function(args) BuyStack.SlashHandler(args) end)
	
	hookedOnItemRButtonUp = EA_Window_InteractionStore.OnItemRButtonUp
	EA_Window_InteractionStore.OnItemRButtonUp = BuyStack.OnItemRButtonUp
	hookedOnItemLButtonUp = EA_Window_InteractionStore.OnItemLButtonUp
	EA_Window_InteractionStore.OnItemLButtonUp = BuyStack.OnItemLButtonUp
	print("BuyStack "..BuyStackSettings.Version.." loaded, use /"..default_cmd.." for settings.") 
end

function BuyStack.SlashHandler(args)
	local opt, val = args:match("([a-z0-9]+)[ ]?(.*)")

	if not opt then
		print("BuyStack Commands: /"..default_cmd.." option [values]")
		print("s[ettings] -- list the current settings.")
		print("size 'value' -- set the stacksize to 'value'")
		print("b 'value' -- set mouse and key(s) for buying to 'value' (combination of ('left' or 'right'), 'shift', 'alt' and 'ctrl'), example: 'left shift alt'")
		print("ab 'value' -- set mouse and key(s) for autobuying to 'value' (combination of ('left' or 'right'), 'shift', 'alt' and 'ctrl'), example: 'right ctrl alt'")
	elseif opt == "settings" or opt == "s" then
		BuyStack.ShowSettings()
	elseif opt == "b" then
		if val:match("(left)") then
			BuyStackSettings[PlayerName].BuyMouse = "left"
			print("BuyMouse set to: "..BuyStackSettings[PlayerName].BuyMouse)
		elseif val:match("(right)") then
			BuyStackSettings[PlayerName].BuyMouse = "right"
			print("BuyMouse set to: "..BuyStackSettings[PlayerName].BuyMouse)
		end
		temp_keys = 0
		if val:match("(shift)") then
			temp_keys = temp_keys + keys["shift"]
		end
		if val:match("(ctrl)") then
			temp_keys = temp_keys + keys["ctrl"]
		end
		if val:match("(alt)") then
			temp_keys = temp_keys + keys["alt"]
		end
		if temp_keys > 0 then
			BuyStackSettings[PlayerName].BuyKey = temp_keys
			print("BuyKey set to: "..GetModifier(BuyStackSettings[PlayerName].BuyKey))
		end
	elseif opt == "ab" then
		if val:match("(left)") then
			BuyStackSettings[PlayerName].AutoBuyMouse = "left"
			print("AutoBuyMouse set to: "..BuyStackSettings[PlayerName].AutoBuyMouse)
		elseif val:match("(right)") then
			BuyStackSettings[PlayerName].AutoBuyMouse = "right"
			print("AutoBuyMouse set to: "..BuyStackSettings[PlayerName].AutoBuyMouse)
		end
		temp_keys = 0
		if val:match("(shift)") then
			temp_keys = temp_keys + keys["shift"]
		end
		if val:match("(ctrl)") then
			temp_keys = temp_keys + keys["ctrl"]
		end
		if val:match("(alt)") then
			temp_keys = temp_keys + keys["alt"]
		end
		if temp_keys > 0 then
			BuyStackSettings[PlayerName].AutoBuyKey = temp_keys
			print("AutoBuyKey set to: "..GetModifier(BuyStackSettings[PlayerName].AutoBuyKey))
		end
	elseif opt == "size" then
		size = val * 1
		if size > 0 then
			BuyStackSettings[PlayerName].StackSize = size
			print("Stacksize set to : ".. BuyStackSettings[PlayerName].StackSize)
		end
	else
		print("Invalid option. Do /"..default_cmd.." for a list of valid ones.")
	end
end

function BuyStack.ShowSettings()
	print ("BuyStack Settings")
	print ("-------------------")
	d(PlayerName)
	d(BuyStackSettings[PlayerName].BuyKey)
	d(BuyStackSettings[PlayerName].BuyMouse)
	
	print ("buy with: " .. GetModifier(BuyStackSettings[PlayerName].BuyKey) .. " + " .. BuyStackSettings[PlayerName].BuyMouse .. " mouse")
	print ("set Autobuy with: " .. GetModifier(BuyStackSettings[PlayerName].AutoBuyKey) .. " + " .. BuyStackSettings[PlayerName].AutoBuyMouse .. " mouse")
	print ("Stacksize: ".. BuyStackSettings[PlayerName].StackSize)
	print("Autobuy items:")
	for k,v in pairs(BuyStackSettings[PlayerName].AutoBuy) do
		print(k.."("..v..")")
	end
end

function GetAmount(ItemName)
	local amount = 0
	BpData = GetInventoryItemData()
	for i = 1,#BpData do
		if WStringToString(BpData[i].name) == ItemName then
			amount = amount + BpData[i].stackCount
		end
	end
	return amount
end

function BuyStack.OnItemLButtonUp(flags)
	if not (BuyStackSettings[PlayerName].BuyMouse == "left" or BuyStackSettings[PlayerName].AutoBuyMouse == "left") then
		return hookedOnItemLButtonUp(flags)
	end

	local rowIdx = WindowGetId(SystemData.MouseOverWindow.name)
	if (rowIdx == 0) then
		return
	end
	if Cursor.IconOnCursor() then
		Cursor.Clear()
	end
	local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionStoreList", rowIdx)
  local itemName = WStringToString(Tooltips.curItemData.name)
	if flags == BuyStackSettings[PlayerName].BuyKey then
		if BuyStackSettings[PlayerName].AutoBuy[itemName] then
			tobuy = BuyStackSettings[PlayerName].AutoBuy[itemName] - GetAmount(itemName)
			if tobuy > 0 then
				EA_Window_InteractionStore.ConfirmThenBuyItem( dataIdx, tobuy )
			else
				print("Autobuy amount already in bags, buying nothing.")
			end
		else
			EA_Window_InteractionStore.ConfirmThenBuyItem( dataIdx, BuyStackSettings[PlayerName].StackSize )
		end
	elseif flags == BuyStackSettings[PlayerName].AutoBuyKey then
		if BuyStackSettings[PlayerName].AutoBuy[itemName] and BuyStackSettings[PlayerName].AutoBuy[itemName] == BuyStackSettings[PlayerName].StackSize then
			BuyStackSettings[PlayerName].AutoBuy[itemName] = nil
			print("Autobuy setting for '"..itemName.."' deleted.")
		else
			BuyStackSettings[PlayerName].AutoBuy[itemName] = BuyStackSettings[PlayerName].StackSize
			print("setting Autobuy stack size of '"..itemName.."' to "..BuyStackSettings[PlayerName].StackSize)
		end
	else
		return hookedOnItemLButtonUp(flags)
	end
end

function BuyStack.OnItemRButtonUp(flags)
	d("BuyStack.OnItemRButtonUp flags: "..flags)
	if not (BuyStackSettings[PlayerName].BuyMouse == "right" or BuyStackSettings[PlayerName].AutoBuyMouse == "right") then
		return hookedOnItemRButtonUp(flags)
	end
	local rowIdx = WindowGetId(SystemData.MouseOverWindow.name)
	if (rowIdx == 0) then
		return
	end
	if Cursor.IconOnCursor() then
		Cursor.Clear()
	end

	local dataIdx = ListBoxGetDataIndex ("EA_Window_InteractionStoreList", rowIdx)
  local itemName = WStringToString(Tooltips.curItemData.name)
	if flags == BuyStackSettings[PlayerName].BuyKey then
		if BuyStackSettings[PlayerName].AutoBuy[itemName] then
			tobuy = BuyStackSettings[PlayerName].AutoBuy[itemName] - GetAmount(itemName)
			if tobuy > 0 then
				EA_Window_InteractionStore.ConfirmThenBuyItem( dataIdx, tobuy )
			else
				print("Autobuy amount already in bags, buying nothing.")
			end
		else
			EA_Window_InteractionStore.ConfirmThenBuyItem( dataIdx, BuyStackSettings[PlayerName].StackSize )
		end
	elseif flags == BuyStackSettings[PlayerName].AutoBuyKey then
		if BuyStackSettings[PlayerName].AutoBuy[itemName] and BuyStackSettings[PlayerName].AutoBuy[itemName] == BuyStackSettings[PlayerName].StackSize then
			BuyStackSettings[PlayerName].AutoBuy[itemName] = nil
			print("Autobuy setting for '"..itemName.."' deleted.")
		else
			BuyStackSettings[PlayerName].AutoBuy[itemName] = BuyStackSettings[PlayerName].StackSize
			print("setting Autobuy stack size of '"..itemName.."' to "..BuyStackSettings[PlayerName].StackSize)
		end
	else
		return hookedOnItemRButtonUp(flags)
	end
end
