local ImportWindowName = "AdvancedRenownTrainingImportWindow"
local PresetWindowName = "AdvancedRenownTrainingPresetsWindow"
local ImportNameInputWindowName = "AdvancedRenownTrainingImportNameInputWindow"
local ExportWindowName = "AdvancedRenownTrainingExportWindow"
local LinkWindowName = "AdvancedRenownTrainingLinkWindow"

local BuildPattern = L"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"
local arsenalUrl = L"http://builder.arsenalofwar.com/RenownBuilder.aspx#"
local wardrobeUrl = L"http://builder.arsenalofwar.com/RenownBuilder.aspx#"

local ImportExportTable = {
	9902,
	9932,
	9926,
	9914,
	9944,
	9908,
	9920,
	9938,
	9977,
	9989,
	9983,
	9995,
	10001,
	10007,
	9952,
	9958,
	9970,
	9959,
	10022,
	10028,
	10016,
	10034,
	10051,
	10057,
	10063,
	10069
}

local hyperlinkPrefix = L"ART:"
local ERASE = L""

local savedata = nil
local savelink = nil

local HyperLinkHook = nil

local function SetImportExportLabels()
	LabelSetText(ImportWindowName.."TitleBarText",L"Import Renown Build")
	ButtonSetText(ImportWindowName.."OkButton",L"Ok")
	ButtonSetText(ImportWindowName.."CancelButton",L"Cancel")
	LabelSetText(ImportWindowName.."LinkLabel",L"Builder link:")
	LabelSetText(ImportWindowName.."PresetLabel",L"New preset name:")
	ButtonSetText(PresetWindowName.."WardrobeButton", L"Wardrobe")
	ButtonSetText(PresetWindowName.."ExportButton", L"Export")

	LabelSetText(ImportNameInputWindowName.."TitleBarText",L"New Preset Name")
	ButtonSetText(ImportNameInputWindowName.."OkButton",L"Ok")
	ButtonSetText(ImportNameInputWindowName.."CancelButton",L"Cancel")
	LabelSetText(ImportNameInputWindowName.."NameLabel",L"New preset name:")
	
	ButtonSetText(ExportWindowName.."HyperLinkButton",L"Hyperlink")
	ButtonSetText(ExportWindowName.."WardrobeButton",L"Arsenal")
	ButtonSetText(ExportWindowName.."CancelButton",L"Cancel")
	
	LabelSetText(LinkWindowName.."TitleBarText", L"Wardrobe link")
	ButtonSetText(LinkWindowName.."CloseButton",L"Close")
end

function GenerateLinkByPresetData(name)
	local preset = AdvancedRenownTraining.Presets[name]
	local t = AdvancedRenownTraining.GetLookUpTable()
	local linkData = L""
	for i=1,26 do
		local l = 0
		local id = ImportExportTable[i]
		for _,v in pairs(preset["t1"]) do
			if v == id then
				l = l+1
				local n = t[id].followedBy
				for j=2,5 do
					if n then
						for __,va in pairs(preset["t"..j]) do
							if va == n then
								l = l+1
								n = t[n].followedBy
							end
						end
					else
						break
					end
				end
			end
		end
		linkData = linkData..l
	end
	savelink = linkData
end

function GeneratePresetByLinkData(data, name)
	d(data)
	if name ~= L"" then
		local t = AdvancedRenownTraining.GetLookUpTable()
		local save = {
			t1 = {},
			t2 = {},
			t3 = {},
			t4 = {},
			t5 = {}
		}
		for i=1,26 do
			local n = tonumber(wstring.sub(data, i,i))
			if (n > 0) then
				for j=1, n do
					if j > 1 then
						local s = t[ImportExportTable[i]+(j-1)]
						if s ~= nil then
							table.insert(save[s.tier], ImportExportTable[i]+j-1)
						else
							d("Failed to create preset: Invalid Linkdata")
							return
						end
					else
						local s = t[ImportExportTable[i]]
						table.insert(save[s.tier], ImportExportTable[i])
					end
				end
			end
		end
		local pointsNeeded = 0
		for _,v in pairs(save) do
			for __,n in pairs(v) do
				pointsNeeded = pointsNeeded + t[n].pointCost
			end
		end
		if pointsNeeded > 100 then
			d("point > 100")
			return
		end
		AdvancedRenownTraining.Presets[name] = save
		ComboBoxClearMenuItems("AdvancedRenownTrainingPresetsWindowLoadComboBox")
		for k,v in pairs (AdvancedRenownTraining.Presets) do
			ComboBoxAddMenuItem("AdvancedRenownTrainingPresetsWindowLoadComboBox", k)
		end
	end
end

function AdvancedRenownTraining.InitializeImportExport()
	CreateWindow(ImportWindowName,false)
	CreateWindow(ImportNameInputWindowName,false)
	CreateWindow(ExportWindowName,false)
	CreateWindow(LinkWindowName,false)
	SetImportExportLabels()
	HyperLinkHook = EA_ChatWindow.OnHyperLinkLButtonUp
	EA_ChatWindow.OnHyperLinkLButtonUp = AdvancedRenownTraining.OnHyperLinkLButtonUp
end

function AdvancedRenownTraining.OnHyperLinkLButtonUp(linkData, flags, x, y)
	data, findCount = wstring.gsub(linkData, hyperlinkPrefix, ERASE)
	if findCount > 0 then
		savedata = data
		WindowSetShowing(ImportNameInputWindowName,true)
		return
	end
	HyperLinkHook(linkData, flags, x,y)
end

function AdvancedRenownTraining.ImportCancelButtonPressed()
	WindowSetShowing(ImportWindowName,false)
end

function AdvancedRenownTraining.ImportOkButtonPressed()
	local name = TextEditBoxGetText(ImportWindowName.."NameInputBox")
	local link = TextEditBoxGetText(ImportWindowName.."LinkInputBox")
	if wstring.match(link, arsenalUrl..BuildPattern) and name ~= L"" then
		GeneratePresetByLinkData(wstring.match(link, BuildPattern), name)
	elseif wstring.match(link, wardrobeUrl..BuildPattern) and name ~= L"" then
		GeneratePresetByLinkData(wstring.match(link, BuildPattern), name)
	end
	WindowSetShowing(ImportWindowName,false)
end

function AdvancedRenownTraining.ShowWardrobeImport()
	WindowSetShowing(ImportWindowName,true)
end

function AdvancedRenownTraining.OnImportHidden()
	TextEditBoxSetText(ImportWindowName.."NameInputBox", ERASE)
	TextEditBoxSetText(ImportWindowName.."LinkInputBox", ERASE)
end

function AdvancedRenownTraining.OnExportButtonPressed()
	local presetitem = ComboBoxGetSelectedText(PresetWindowName.."LoadComboBox")
	if ComboBoxGetSelectedMenuItem(PresetWindowName.."LoadComboBox") == 0 then
		return
	end
	WindowSetShowing(ExportWindowName,true)
	GenerateLinkByPresetData(presetitem)
end

function AdvancedRenownTraining.ImportNameInputOkButtonPressed()
	local name = TextEditBoxGetText(ImportNameInputWindowName.."NameInputBox")
	if name ~= L"" then
		GeneratePresetByLinkData(savedata,name)
	end
	WindowSetShowing(ImportNameInputWindowName,false)
end

function AdvancedRenownTraining.ImportNameInputCancelButtonPressed()
	WindowSetShowing(ImportNameInputWindowName,false)
end

function AdvancedRenownTraining.OnImportNameInputHidden()
	TextEditBoxSetText(ImportNameInputWindowName.."NameInputBox", ERASE)
	savedata = nil
end

function AdvancedRenownTraining.ExportToWardrobe()
	TextEditBoxSetText(LinkWindowName.."LinkBox", wardrobeUrl..savelink)
	WindowSetShowing(LinkWindowName,true)
	savelink = nil
	WindowSetShowing(ExportWindowName, false)
end

function AdvancedRenownTraining.ExportToLink()
	local hl = CreateHyperLink(hyperlinkPrefix..savelink, L"[ART-Preset:"..ComboBoxGetSelectedText(PresetWindowName.."LoadComboBox")..L"]", {230,230,50},{})
	EA_ChatWindow.InsertText(hl)
	savelink = nil
	WindowSetShowing(ExportWindowName, false)
end

function AdvancedRenownTraining.ExportCancelButtonPressed()
	WindowSetShowing(ExportWindowName, false)
end

function AdvancedRenownTraining.OnExportShown()
	ComboBoxSetDisabledFlag("AdvancedRenownTrainingPresetsWindowLoadComboBox", true)
end

function AdvancedRenownTraining.OnExportHidden()
	ComboBoxSetDisabledFlag("AdvancedRenownTrainingPresetsWindowLoadComboBox", false)
end

function AdvancedRenownTraining.LinkWindowClose()
	WindowSetShowing(LinkWindowName,false)
end

function AdvancedRenownTraining.OnLinkHidden()
	TextEditBoxSetText(LinkWindowName.."LinkBox", ERASE)
end