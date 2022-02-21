BuffHead = BuffHead or {};
BuffHead.Setup = BuffHead.Setup or {};
BuffHead.Setup.AdvancedCompressionItemEffect = 
{
	WindowName = "BuffHeadSetupAdvancedCompressionItemEffectWindow",
	Entries = {},
};
local this = BuffHead.Setup.AdvancedCompressionItemEffect;

local windowName = BuffHead.Setup.AdvancedCompressionItemEffect.WindowName;
local localization = BuffHead.Localization.GetMapping();

local indexToCastBy = { BuffHead.Compression.OnlyMine, BuffHead.Compression.OnlyOthers, BuffHead.Compression.All };
local existingItem = {};

local function ShowButtons(showApply, showCreate)

	if (WindowGetShowing(windowName .. "ApplyButton") == showApply and WindowGetShowing(windowName .. "CreateButton") == showCreate) then return end

	WindowSetShowing(windowName .. "ApplyButton", showApply);
	WindowSetShowing(windowName .. "CreateButton", showCreate);
	
	if (showCreate) then
		WindowClearAnchors(windowName .. "CreateButton");
		if (showApply) then
			WindowAddAnchor(windowName .. "CreateButton", "topleft", windowName .. "ApplyButton", "topright", 0, 0);
		else
			WindowAddAnchor(windowName .. "CreateButton", "bottomright", windowName, "bottomright", -20, -20);
		end
	end

end

local function LoadItem(index)

	local item = nil;
	existingItem = { Index = index };
	
	if (index) then
		item = BuffHead.Setup.AdvancedCompressionItem.Effects[index];
	end
	
	local abilityId = L"";
	local castBy = 1;
	
	if (item) then
		--existing
		abilityId = towstring(item.AbilityId or "");
		for index, castType in ipairs(indexToCastBy) do
			if (castType == item.Type) then
				castBy = index;
				break;
			end
		end
	else
		--new
	end
	
	TextEditBoxSetText(windowName .. "AbilityEditBox", abilityId);
	ComboBoxSetSelectedMenuItem(windowName .. "CastByComboBox", castBy);
	
	if (item) then
		ShowButtons(true, true);
	else
		ShowButtons(false, true);
	end

end

function BuffHead.Setup.AdvancedCompressionItemEffect.Initialize()
	
	LabelSetText(windowName .. "TitleLabel", localization["Setup.AdvancedCompressionItemEffect.Title"]);
	LabelSetText(windowName .. "AbilityLabel", localization["Setup.AdvancedCompressionItemEffect.Ability"]);
	LabelSetText(windowName .. "CastByLabel", localization["Setup.AdvancedCompressionItemEffect.CastBy"]);
	ComboBoxClearMenuItems(windowName .. "CastByComboBox");
	ComboBoxAddMenuItem(windowName .. "CastByComboBox", localization["Setup.AdvancedCompressionItemEffect.CastBy.Self"]);
	ComboBoxAddMenuItem(windowName .. "CastByComboBox", localization["Setup.AdvancedCompressionItemEffect.CastBy.Others"]);
	ComboBoxAddMenuItem(windowName .. "CastByComboBox", localization["Setup.AdvancedCompressionItemEffect.CastBy.Any"]);

	ButtonSetText(windowName .. "ApplyButton", localization["Setup.AdvancedCompressionItemEffect.Apply"]);
	ButtonSetText(windowName .. "CreateButton", localization["Setup.AdvancedCompressionItemEffect.Create"]);
	
	ShowButtons(false, true);
end

function BuffHead.Setup.AdvancedCompressionItemEffect.Show()
	if (WindowGetShowing(windowName)) then return end
	
	WindowClearAnchors(windowName);
	WindowAddAnchor(windowName, "topright", BuffHead.Setup.AdvancedCompressionItem.WindowName, "topleft", 0, 0);
	
	WindowSetShowing(windowName, true);
	WindowUtils.AddToOpenList(windowName, this.OnCloseLUp, WindowUtils.Cascade.MODE_NONE);
	Sound.Play(Sound.WINDOW_OPEN);
end

function BuffHead.Setup.AdvancedCompressionItemEffect.Hide()
	if (not WindowGetShowing(windowName)) then return end
	
	WindowSetShowing(windowName, false);
	Sound.Play(Sound.WINDOW_CLOSE);
	WindowUtils.RemoveFromOpenList(windowName);
end

function BuffHead.Setup.AdvancedCompressionItemEffect.OnHidden()

end

function BuffHead.Setup.AdvancedCompressionItemEffect.OnCloseLUp()
	this.Hide();
end

function BuffHead.Setup.AdvancedCompressionItemEffect.ShowNew()
	LoadItem(nil);
	this.Show();
end

function BuffHead.Setup.AdvancedCompressionItemEffect.ShowEdit(index)
	LoadItem(index);
	this.Show();
end

function BuffHead.Setup.AdvancedCompressionItemEffect.GetActiveItem()
	return existingItem or {};
end

local function SaveItem(abilityId)
	local item = {};
	local abilityId = abilityId or TextEditBoxGetText(windowName .. "AbilityEditBox");
	if (abilityId:len() == 0) then return end
	
	item.Type = indexToCastBy[ComboBoxGetSelectedMenuItem(windowName .. "CastByComboBox")];
	item.AbilityId = tonumber(abilityId);
	
	return item;
end

function BuffHead.Setup.AdvancedCompressionItemEffect.OnApplyLClick()
	local item = SaveItem();
	if (item) then
		BuffHead.Setup.AdvancedCompressionItem.Effects[existingItem.Index] = item;
		BuffHead.Setup.AdvancedCompressionItem.Update();
		this.Hide();
	end
end

function BuffHead.Setup.AdvancedCompressionItemEffect.OnCreateLClick()
	local abilityText = tostring(TextEditBoxGetText(windowName .. "AbilityEditBox"));
	if (abilityText:match(",")) then
		local abilityId;
		while (abilityText) do
			abilityId, abilityText = abilityText:match("(%d+),?%s*(.*)");
			if (abilityId) then
				local item = SaveItem(abilityId);
				if (item) then
					table.insert(BuffHead.Setup.AdvancedCompressionItem.Effects, item);
				end
			end
		end
		BuffHead.Setup.AdvancedCompressionItem.Update();
		this.Hide();
	else
		local item = SaveItem();
		if (item) then
			table.insert(BuffHead.Setup.AdvancedCompressionItem.Effects, item);
			BuffHead.Setup.AdvancedCompressionItem.Update();
			this.Hide();
		end
	end
end