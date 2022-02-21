local Enemy = Enemy
local LastId = 0
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local tsort = table.sort
local mmin = math.min
local mmax = math.max
local mfloor = math.floor
local mhuge = math.huge
local sformat = string.format
local wsformat = wstring.format
local GetTodaysDate = GetTodaysDate
local GetComputerTime = GetComputerTime


function Enemy.Nop ()
end


function Enemy.extendTable (t1, t2)
	for key,val in pairs (t2)
	do
		if (type (val) == "table")
		then
			if (not t1[key] or type (t1[key]) ~= "table")
			then
				t1[key] = {}
			end

			Enemy.extendTable (t1[key], val)
		end

		if (t1[key] == nil)
		then
			t1[key] = val
		end
	end
end


function Enemy.clone (t)

	if (not t) then return nil end
	if (type (t) ~= "table") then return t end

	local res = {}

	for k,v in pairs (t)
	do
		if (type (v) == "table")
		then
			res[k] = Enemy.clone (v)
		elseif (type (v) ~= "function")
		then
			res[k] = v
		end
	end

	return res
end


function Enemy.clone2 (t)

	local res = {}

	if (t)
	then
		for k,v in pairs (t)
		do
			if (
					(type (k) == "string" and k:sub (1, 1) == "_")
					or
					(type (k) == "wstring" and k:sub (1, 1) == L"_")
					or
					type (v) == "function"
				)
			then
				continue
			end

			if (type (v) == "table")
			then
				res[k] = Enemy.clone2 (v)
			else
				res[k] = v
			end
		end
	end

	return res
end


function Enemy.tableReverse (t)

	local max = #t
	local max_k = mfloor (max / 2)

	for k = 1, max_k
	do
		local tmp = t[k]
		local k2 = max - k + 1
		t[k] = t[k2]
		t[k2] = tmp
	end
end


function Enemy.each (t, callback)

	if (not t) then return end

	for k,v in pairs (t)
	do
		callback (t, k, v)
		v = t[k]	-- callback could set t[k] to nil, so we must get value again

		if (type (v) == "table")
		then
			Enemy.each (v, callback, t)
		end
	end
end


function Enemy.clamp (min, max, value)
	if (value == nil) then return nil end
	return mmax (min, mmin (max, value))
end


function Enemy.trim (str)

	if (str == nil) then return nil end

	if (type (str) == "string")
	then
		local res = str:match ("^%s*(.-)%s*$")
		if (res) then return res end
	elseif (type (str) == "wstring")
	then
		local res = str:match (L"^%s*(.-)%s*$")
		if (res) then return res end
	end

	return str
end


function Enemy.UnpackRGB (v)
	return v.r, v.g, v.b
end


function Enemy.capitalize (str)
	return str:sub(1,1):upper()..str:sub(2)
end


function Enemy.isNil (value, nilReturnValue)
	if (value == nil) then return nilReturnValue end
	return value
end


function Enemy.isEmpty (value, emptyReturnValue)
	if (not value or value:len() < 1) then return emptyReturnValue end
	return value
end


function Enemy.toWString (str)
	if (str ~= nil) then return towstring (str) end
	return nil
end


function Enemy.toWStringOrEmpty (str)
	if (str ~= nil) then return towstring (str) end
	return L""
end


function Enemy.toString (str)
	if (str ~= nil) then return tostring (str) end
	return nil
end

function Enemy.toStringOrEmpty (str)
	if (str ~= nil) then return tostring (str) end
	return ""
end


function Enemy.Print (str)
	EA_ChatWindow.Print (L"[Enemy addon]: "..Enemy.toWString (str))
end


function Enemy.FixString (str)

	if (str == nil) then return nil end

	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end

	return str
end


function Enemy.IsInGroup ()
	return (GetNumGroupmates () > 0)
end


function Enemy.IsInWarband ()

	local data = GetBattlegroupMemberData ()

	for _,g in pairs (data)
	do
		for _,p in pairs (g.players)
		do
			if (Enemy.FixString (p.name) == Enemy.playerName) then return true end
		end
	end

	return false
end


function Enemy.Split (str, separator, skipEmptyEntries)

	local res = {}

	if (str == nil or str == L"")
	then
		return res
	end

	if (separator == nil or separator == L"")
	then
		tinsert (res, str)
		return res
	end

	local str = str
	local pos = 1
	local len = str:len ()
	local endpos

	while (pos <= len)
	do
		endpos = str:find (separator, pos, true)
		if (endpos == nil) then endpos = len + 1 end

		local s = str:sub (pos, endpos - 1)
		if (s ~= L"" or not skipEmptyEntries)
		then
			tinsert (res, s)
		end

		pos = endpos + 1
	end

	return res
end


function Enemy.JoinWStrings (t, separator)
	if (type (t) ~= "table") then return L"" end

	separator = separator or L", "

	local res = L""

	for _, v in ipairs (t)
	do
		if (res:len () > 0) then res = res..separator end
		res = res..v
	end

	return res
end


function Enemy.GetMacroId (text)
	local macros = DataUtils.GetMacros ()

	for slot = 1, EA_Window_Macro.NUM_MACROS
	do
		if macros[slot].text == text
		then
			return slot
		end
	end

	return nil
end


function Enemy.SetMacro (slot, name, text, iconId)
	SetMacroData (name, text, iconId, slot)
	EA_Window_Macro.UpdateDetails (slot)
end


function Enemy.CreateMacro (name, text, iconId)

	local slot = Enemy.GetMacroId (text)
	if (slot) then return slot end

	local macros = DataUtils.GetMacros ()
	for slot = 1, EA_Window_Macro.NUM_MACROS
	do
		if (macros[slot].text == L"")
		then
			Enemy.SetMacro (slot, name, text, iconId)
			return slot
		end
	end

	return nil
end


function Enemy.GetMacro (slot)
	if (slot == nil) then return nil end

	return DataUtils.GetMacros() [slot]
end


function Enemy.GetRandomString (len, letters)

	if (letters == nil) then letters = 26 end
	local ch = string.char (string.byte ('a') + math.random (letters) - 1)

	return ch:rep (len)
end

function Enemy.GetRandomString2 (len, letters)

	if (letters == nil) then letters = 26 end

	local res = ""
	for k = 1, len
	do
		res = res..string.char (string.byte ('a') + math.random (letters) - 1)
	end

	return res
end


function Enemy.NewId ()
	LastId = LastId + 1
	return LastId
end


function Enemy.Round (n, digits)
	return tonumber (string.format ("%." .. (digits or 0) .. "f", n))
end


function Enemy.IsInteger (str)
	if (str == nil or wstring.match (Enemy.toWString (str), L"^%s*([%-]?%d+)%s*") == nil) then return false end
	return true
end


function Enemy.IsFloat (str)
	if (str == nil or wstring.match (Enemy.toWString (str), L"^%s*([%-]?[%d%.]+)%s*") == nil) then return false end
	return true
end


function Enemy.ConvertToInteger (str)
	if (not Enemy.IsInteger (str)) then return nil end

	str = Enemy.trim (str)
	if (str:len () > 10)
	then
		str = str:sub (1, 10)
	end

	return tonumber (str)
end


function Enemy.ConvertToFloat (str)

	if (not Enemy.IsFloat (str)) then return nil end

	str = Enemy.trim (str)
	if (str:len () > 10)
	then
		str = str:sub (1, 10)
	end

	return tonumber (str)
end


function Enemy.ConvertToPercent (str)

	local n = Enemy.ConvertToInteger (str)
	if (not n) then return nil end

	return Enemy.clamp (0, 100, n)
end


function Enemy.CloneTableExceptKey (t, key)

	local res = {}

	for k,v in pairs (t)
	do
		if (k ~= key) then res[k] = v end
	end

	return res
end


function Enemy.IndexOf (t, value)

	for k, v in ipairs (t)
	do
		if (v == value)
		then
			return k
		end
	end

	return nil
end


function Enemy.UI_ColorSliders_Set (baseName, value)
	SliderBarSetCurrentPosition (baseName.."R", value.r / 255.0)
	SliderBarSetCurrentPosition (baseName.."G", value.g / 255.0)
	SliderBarSetCurrentPosition (baseName.."B", value.b / 255.0)
end


function Enemy.UI_ColorSliders_Get (baseName)
	return
		{
			r = math.floor (255.0 * SliderBarGetCurrentPosition (baseName.."R") + 0.5),
			g = math.floor (255.0 * SliderBarGetCurrentPosition (baseName.."G") + 0.5),
			b = math.floor (255.0 * SliderBarGetCurrentPosition (baseName.."B") + 0.5)
		}
end


function Enemy.UI_TextColor_Set (baseName, value)
	TextEditBoxSetText (baseName.."R", towstring (value.r))
	TextEditBoxSetText (baseName.."G", towstring (value.g))
	TextEditBoxSetText (baseName.."B", towstring (value.b))
end


function Enemy.UI_TextColor_Get (baseName)
	return
		{
			r = Enemy.clamp (0, 255, Enemy.isNil (Enemy.ConvertToInteger (TextEditBoxGetText (baseName.."R")), 0)),
			g = Enemy.clamp (0, 255, Enemy.isNil (Enemy.ConvertToInteger (TextEditBoxGetText (baseName.."G")), 0)),
			b = Enemy.clamp (0, 255, Enemy.isNil (Enemy.ConvertToInteger (TextEditBoxGetText (baseName.."B")), 0))
		}
end


function Enemy.UI_PrepareComboBoxValuesArray (t, f, sortF)

	local res = {}

	for k, v in pairs (t)
	do
		tinsert (res, f (k, v))
	end

	if (sortF)
	then
		tsort (res, sortF)
	end

	return res
end


function Enemy.UI_SetComboBoxValueByValuesArray (windowName, t, f)

	for k, v in ipairs (t)
	do
		if (f(k, v))
		then
			ComboBoxSetSelectedMenuItem (windowName, k)
			return
		end
	end

	ComboBoxSetSelectedMenuItem (windowName, 1)
end


function Enemy.GetAbilityIds (name)

	name = Enemy.toWString (name):lower ()
	local ids = {}

	for id = 1, 100000
	do
		if (Enemy.FixString (GetAbilityName (id)):lower () == name)
		then
			tinsert (ids, id)
		end
	end

	if (#ids < 1)
	then
		Enemy.Print (L"Ability '"..name..L"' not found.")
	else
		local str = L""

		for _, id in ipairs (ids)
		do
			if (str:len () > 0) then str = str..L", " end
			str = str..towstring (id)
		end

		Enemy.Print (L"Ability ids for '"..name..L"': "..str)
	end
end


function Enemy.SearchAbilities (regex, withDescription, toDebugLog)

	regex = Enemy.toString(regex):lower ()

	local max = 50
	local found = 0

	for id = 1, 100000
	do
		local ability_name = Enemy.toString (Enemy.FixString (GetAbilityName (id)))

		if (ability_name:lower ():match (regex))
		then
			found = found + 1

			if (found >= max)
			then
				Enemy.Print (L"Maximum number of results reached")
				break
			end

			local str = "["..Enemy.toString (id).."] "..ability_name
			if (withDescription)
			then
				local desc = Enemy.toString (GetAbilityDesc (id, 40))
				if (desc:len() > 1)
				then
					str = str.." ("..desc..")"
				end
			end

			if (toDebugLog)
			then
				d(str)
			else
				Enemy.Print (str)
			end
		end
	end

	Enemy.Print (Enemy.toString (found).." abilities found")
end


if (not cls)
then
	function cls ()
		DebugWindow.ClearTextLog()
	end
end


-- directions: 1/2/3/4 -> up/down/left/right
function Enemy.CalculatePositioningMatrix (baseX, baseY, dx, dy, direction1, padding1, count1, direction2, padding2, count2)

	local res = {}
	local x = baseX
	local y = baseY
	local end_x = baseX
	local end_y = baseY

	for k2 = 1, count2
	do
		local start_x = x
		local start_y = y

		for k1 = 1, count1
		do
			tinsert (res, {x = x, y = y})

			if (direction1 == 1)
			then
				y = y - dy - padding1
			elseif (direction1 == 2)
			then
				y = y + dy + padding1
			elseif (direction1 == 3)
			then
				x = x - dx - padding1
			elseif (direction1 == 4)
			then
				x = x + dx + padding1
			end
		end

		end_x = x
		end_y = y

		if (direction1 < 3)
		then
			end_x = end_x + dx
		else
			end_y = end_y + dy
		end

		if (direction2 == 1)
		then
			x = start_x
			y = start_y - math.abs (end_y - start_y) - padding2
		elseif (direction2 == 2)
		then
			x = start_x
			y = start_y + math.abs (end_y - start_y) + padding2
		elseif (direction2 == 3)
		then
			y = start_y
			x = start_x - math.abs (end_x - start_x) - padding2
		elseif (direction2 == 4)
		then
			y = start_y
			x = start_x + math.abs (end_x - start_x) + padding2
		end
	end

	return res, end_x, end_y
end


function Enemy.IsShiftPressed (flags)
	return (flags == SystemData.ButtonFlags.SHIFT or
	        flags == SystemData.ButtonFlags.SHIFT + SystemData.ButtonFlags.CONTROL or
	        flags == SystemData.ButtonFlags.SHIFT + SystemData.ButtonFlags.ALT or
	        flags == SystemData.ButtonFlags.SHIFT + SystemData.ButtonFlags.CONTROL + SystemData.ButtonFlags.ALT)
end


function Enemy.IsControlPressed (flags)
	return (flags == SystemData.ButtonFlags.CONTROL or
	        flags == SystemData.ButtonFlags.CONTROL + SystemData.ButtonFlags.SHIFT or
	        flags == SystemData.ButtonFlags.CONTROL + SystemData.ButtonFlags.ALT or
	        flags == SystemData.ButtonFlags.CONTROL + SystemData.ButtonFlags.SHIFT + SystemData.ButtonFlags.ALT)
end


function Enemy.IsAltPressed (flags)
	return (flags == SystemData.ButtonFlags.ALT or
	        flags == SystemData.ButtonFlags.ALT + SystemData.ButtonFlags.SHIFT or
	        flags == SystemData.ButtonFlags.ALT + SystemData.ButtonFlags.CONTROL or
	        flags == SystemData.ButtonFlags.ALT + SystemData.ButtonFlags.SHIFT + SystemData.ButtonFlags.CONTROL)
end


function Enemy.FormatNumber (number, delimeter)

	if (number == nil or number == mhuge or number == -mhuge) then return L"" end

	if (not delimeter)
	then
		delimeter = L" "
	end

    local formatted_string  = L""
    local number_string     = L""..number

    local number_length     = wstring.len (number_string)
    local commas_needed     = math.ceil (number_length / 3) - 1

    if (commas_needed == 0) then
        formatted_string = number_string
        return formatted_string
    end

    local counter = 0
    for i = number_length, 1, -3 do

        local sub_end       = (number_length) - (counter * 3)
        local sub_begin     = (sub_end - 2)

        local substring = wstring.sub (number_string, sub_begin, sub_end)
        formatted_string = delimeter..substring..formatted_string

        counter = counter + 1

        if (counter == commas_needed)
        then
            local remainder = wstring.sub (number_string, 0, sub_begin-1)
            formatted_string = remainder..formatted_string
            break;
        end
    end

    return formatted_string
end


function Enemy.FormatNumberShort (number, precise)

	if (number == nil or number == mhuge or number == -mhuge) then return L"" end

	if (number > 1000000)
	then
		return wsformat (L"%.2f M", number / 1000000)

	elseif (number > 1000)
	then
		if (precise)
		then
			if (number > 10000)
			then
				return wsformat (L"%.2f K", number / 1000)
			end
		else
			return towstring (mfloor (number / 1000 + 0.5))..L" K"
		end
	end

	return towstring (number)
end


function Enemy.ColorFromRGBString (str, default)

	if (not default) then default = { r = 0, g = 0, b = 0 } end
	if (not str) then return default end

	str = tostring (str)

	local parts = Enemy.Split (str, ";")
	if (#parts < 3) then return default end

	return
		{
			r = Enemy.isNil (tonumber (parts[1]), 0),
			g = Enemy.isNil (tonumber (parts[2]), 0),
			b = Enemy.isNil (tonumber (parts[3]), 0)
		}
end


function Enemy.GetTimeFromSeconds (t)

	if (not t) then return 0, 0, 0 end

	t = mfloor (t + 0.5)

	local d = mfloor (t / 86400.0)
	t = t - (d * 86400)
	local h = mfloor (t / 3600.0)
	t = t - (h * 3600)
	local m = mfloor (t / 60.0)
	t = t - (m * 60)
	local s = mfloor (t + 0.5)

	return d, h, m, s
end


function Enemy.GetCurrentDateInSeconds ()
	local d = GetTodaysDate ()
	return (d.todaysDay + (d.todaysMonth + d.todaysYear * 12) * 31) * 86400
end


function Enemy.GetCurrentDateInSecondsWithTime ()
	return Enemy.GetCurrentDateInSeconds () + GetComputerTime ()
end


function Enemy.GetCurrentDateTime ()

	local t = GetComputerTime ()
	local d = GetTodaysDate ()
	local _d, h, m, s = Enemy.GetTimeFromSeconds (t)
	local ts = t + (d.todaysDay + (d.todaysMonth + d.todaysYear * 12) * 31) * 86400

	return
	{
		year = d.todaysYear,
		month = d.todaysMonth,
		day = d.todaysDay,
		hours = h,
		minutes = m,
		seconds = s,
		totalSeconds = ts
	}
end


function Enemy.DateTimeToString (dt)

	local res = wsformat (L"%02d.%02d.%04d %02d:%02d:%02d",
		dt.day,
		dt.month,
		dt.year,
		dt.hours,
		dt.minutes,
		dt.seconds
	)

	return res
end


function Enemy.TruncateString (str, maxLength, truncateText)

	local len = str:len()
	if (len <= maxLength) then return str end

	return str:sub (1, maxLength)..truncateText
end
