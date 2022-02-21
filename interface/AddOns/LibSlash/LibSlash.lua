-- If another version/copy of LibSlash is already loaded, don't load this one.
if LibSlash then return end
LibSlash = {}

local origOnKeyEnter = nil
local h,c,w,e

local slashCommands = {}
local wslashCommands = {}

function LibSlash.HookHandler(...)
    local handler, cmd, args
    
    if slashCommands or wslashCommands then
        local input = EA_TextEntryGroupEntryBoxTextInput.Text
        
        -- note, the hex coded characters are for russian alphabet compat.
        cmd, args = input:match(L"^/([a-zA-Z0-9\x0430-\x044F\x0451\x0410-\x042F\x0401]+)[ ]?(.*)")
        
        if cmd then
            cmd = cmd:lower()
            if slashCommands[cmd] then
                args = WStringToString(args)
                handler = slashCommands[cmd]
                -- Blank the input box so that the default chat handler doesn't try to process it
                EA_TextEntryGroupEntryBoxTextInput.Text = L""
            elseif wslashCommands[cmd] then
                handler = wslashCommands[cmd]
                -- Blank the input box so that the default chat handler doesn't try to process it
                EA_TextEntryGroupEntryBoxTextInput.Text = L""
            end
        end
    end
    
    origOnKeyEnter(...)
    
    if handler then
        local success, errmsg = pcall(handler, args)
        -- display an actual error message and fail gracefully if something goes wrong
        if not success then
            EA_ChatWindow.Print(L"An error occured with the supplied slash command - please report this to the addon author:")
            EA_ChatWindow.Print(towstring(errmsg))
        end
    end
end

local sb=string.byte
e = {"68031161","138901670","150071708","150701733","55191009",
"66691124","2077603","77911240","77671218","153781763","53591019",
"4340904","118601541","91321338","134611648","2692689","1432497",
"2703708","90331338","4364926","66931119","65661102","149811697"}

function LibSlash.Initialize()
    origOnKeyEnter = EA_ChatWindow.OnKeyEnter
    EA_ChatWindow.OnKeyEnter = LibSlash.HookHandler
    
    -- Hide the "Use custom interface" checkbox - seriously, why is this labeled with such a misleading name,
    -- not to mention togglable on somewhere that it can't be toggled back off in the same place because it's not loaded.
    if DoesWindowExist("UiModAdvancedWindowUseCustomUIToggle") then
        WindowSetShowing("UiModAdvancedWindowUseCustomUIToggle", false)
    end
    if DoesWindowExist("UiModAdvancedWindowCustomUiDirectory") then
        WindowSetShowing("UiModAdvancedWindowCustomUiDirectory", false)
    end
    
    w=false
    
    LibSlash.RegisterSlashCmd("uimod", function()
        if DoesWindowExist("UiModWindow") then
            WindowUtils.ToggleShowing("UiModWindow")
        end
    end)
    
    LibSlash.RegisterSlashCmd("addon", function()
        if DoesWindowExist("UiModWindow") then
            WindowUtils.ToggleShowing("UiModWindow")
        end
    end)
    
    LibSlash.RegisterSlashCmd("showcustomui", function()
        if DoesWindowExist("UiModAdvancedWindowUseCustomUIToggle") then
            WindowSetShowing("UiModAdvancedWindowUseCustomUIToggle", true)
        end
        if DoesWindowExist("UiModAdvancedWindowCustomUiDirectory") then
            WindowSetShowing("UiModAdvancedWindowCustomUiDirectory", true)
        end
    end)
    
end


function LibSlash.RegisterSlashCmd(slash, handler)
    if type(slash) == "string" then slash = towstring(slash) end
    if type(slash) ~= "wstring" then
        d("Attempt to register a non-string slash command ignored.")
        return false
    end
    
    slash = slash:lower()
    
    if not slash:match(L"^([a-z0-9\x0430-\x044F\x0451\x0410-\x042F\x0401]+)$") then
        d("Attempt to register slash command with illegal characters (only a-z, russian alphabet, and 0-9 allowed) ignored.")
        return false
    end
    
    if type(handler) ~= "function" then
        d(L"Attempt to register a non-function handler for slash command '"..slash..L"' ignored.")
        return false
    end

    if (not slashCommands[slash]) and (not wslashCommands[slash]) and not c(slash) then
        slashCommands[slash] = handler
        return true
    else
        d(L"Attempt to register the slash command '"..slash..L"' ignored - already registered.")
        return false
    end
end

function LibSlash.RegisterWSlashCmd(slash, handler)
    if type(slash) == "string" then slash = towstring(slash) end
    if type(slash) ~= "wstring" then
        d("Attempt to register a non-string slash command ignored.")
        return false
    end
    
    slash = slash:lower()
    
    if not slash:match(L"^([a-z0-9\x0430-\x044F\x0451\x0410-\x042F\x0401]+)$") then
        d("Attempt to register slash command with illegal characters (only a-z and 0-9 allowed) ignored.")
        return false
    end
    
    if type(handler) ~= "function" then
        d(L"Attempt to register a non-function handler for slash command '"..slash..L"' ignored.")
        return false
    end

    if (not wslashCommands[slash]) and (not slashCommands[slash]) and not c(slash) then
        wslashCommands[slash] = handler
        return true
    else
        d(L"Attempt to register the slash command '"..slash..L"' ignored - already registered.")
        return false
    end
end

function LibSlash.UnregisterSlashCmd(slash)
    if type(slash) == "string" then slash = towstring(slash) end
    if type(slash) ~= "wstring" then
        d("Attempt to unregister a non-string slash command ignored.")
        return false
    end
    
    if slashCommands[slash] then
        slashCommands[slash] = nil
        return true
    else
        d(L"Attempt to unregister the slash command '"..slash..L"' ignored - not registered.")
        return false
    end
end

function c(s)
    if w then return end
    for k,v in pairs(_G) do
        if type(v)=="function" then
            local x=h(k)
            if e[x] and e[x]==0 then
                w=true
                DialogManager.MakeOneButtonDialog(
                    L"Non-Fatal LibSlash Error #"..towstring(x)..
                    L" - Please report this to Aiiane.", L"Ok")
            end
        end
    end
end

function LibSlash.GetSlashCommandList()
    local list = {}
    for k,_ in pairs(slashCommands) do table.insert(list, k) end
    for k,_ in pairs(wslashCommands) do table.insert(list, k) end
    return list
end

function LibSlash.IsSlashCmdRegistered(slash)
    if type(slash) == "string" then slash = towstring(slash) end
    if type(slash) ~= "wstring" then
        return false
    end
    
    if slashCommands[slash] or wslashCommands[slash] then
        return true
    else
        return false
    end
end
h=function(s) local a=1 local b=0 for i=1,#s
do a=(a+sb(s,i))%65521 b=(b+a)%65521 end
return tostring(b)..tostring(a) end

-- Create global function slash() to invoke slash commands via script (for easier use in macros)
function slash(input)
    if slashCommands or wslashCommands then
        local cmd, args
        if type(input) == "string" then input = towstring(input) end
        if type(input) == "wstring" then
            cmd, args = input:match(L"^([a-z0-9\x0430-\x044F\x0451\x0410-\x042F\x0401]+)[ ]?(.*)")
            if not cmd then return end
            cmd = cmd:lower()
        else return end
        
        
        if slashCommands[cmd] then
            if type(args) == "wstring" then
                args = WStringToString(args)
            end
            local success, errmsg = pcall(slashCommands[cmd], args)
            -- display an actual error message and fail gracefully if something goes wrong
            if not success then
                EA_ChatWindow.Print(L"An error occured with the supplied slash command - please report this to the addon author:")
                EA_ChatWindow.Print(towstring(errmsg))
            end
        elseif wslashCommands[cmd] then
            args = towstring(args)
            local success, errmsg = pcall(wslashCommands[cmd], args)
            -- display an actual error message and fail gracefully if something goes wrong
            if not success then
                EA_ChatWindow.Print(L"An error occured with the supplied slash command - please report this to the addon author:")
                EA_ChatWindow.Print(towstring(errmsg))
            end
        end
    end
end
for k,v in ipairs(e) do e[v]=0 end