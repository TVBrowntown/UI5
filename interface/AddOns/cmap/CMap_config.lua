-- loads an instance of LibConfig
LibConfig = LibStub("LibConfig")

CMap_config = {}

local GUI

function CMap_config.OnInitialize()
  CMap_config.Settings = {
    version = 1.0,
    author = "gutgut",
    desc = "Configuration for CustomMap",
    cool = true,
    label = {
      text = L"Hi World",
      font = "font_journal_text",
      color = {
        active = {100,255,0},
        inactive = {255,100,0},
        },
      },
    box = {
      width = 200,
      height = 100,
      color = {50,100,200}
      },
    }

  LibSlash.RegisterSlashCmd("vcmap",function(msg) CMap_config.Slash(msg) end)
end

function CMap_config.Slash(msg)
  if (not GUI) then
    -- parameters: title text, settings table, callback-function
    -- note that you need to have a settings table!
    GUI = LibConfig("CustomMap Configuration", CMap_config.Settings, true, CMap_config.SettingsChanged)
    
    GUI:AddTab("General")
    	-- page 1
    	local label = GUI("label", "Welcome to LibConfig. This is a label text that is used to simply display text "..
    				 			   "inside your configuration menus. You can also use labels to display variables, as "..
    				 			   "you will see.").label
		label:Align("left")
		GUI("label", "Author", "author")
		GUI("label", "Mod Version", "version")
		GUI("textbox", "Mod Description", "desc")
		GUI("checkbox", "is this cool?", "cool")
		
		-- page 2
		label = GUI("label", "You can put 5 configuration elements onto one page. A new page will be created automatically "..
					 		 "as you create more elements.").label
		label:Align("left")
		local comboBox = GUI("combobox", "select font:", {"label", "font"}).combo
		comboBox:Add("font_chat_text")
    	comboBox:Add("font_default_text")
    	comboBox:Add("font_clear_large_bold")
    	comboBox:Add("font_journal_text")
    	GUI("color", "active color", {"label","color", "active"})
    	GUI("color", "inactive color", {"label","color", "inactive"})
    
    GUI:AddTab("More Options")
    	-- page 1
    	label = GUI("label", "You have selected another tab of this menu. Elements can be sorted into any number of different tabs.").label
    	label:Align("left")
		GUI("textbox", "Message to world", {"label", "text"})
    
   end
  
  -- fills in all the values and shows the config GUI
  GUI:Show()
end

-- will get called after the apply-button has been hit and the settings have been changed
function CMap_config.SettingsChanged()
  d(CMap_config.Settings)
end