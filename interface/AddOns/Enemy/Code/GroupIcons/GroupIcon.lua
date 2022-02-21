local Enemy = Enemy
local mabs = math.abs
local mmin = math.min
local mmax = math.max
local mfloor = math.floor
local unpack = unpack

local COLOR_BG_DEAD = { 255, 0, 0}

local PetTargetEvents =
{
	[1] = SystemData.Events.TARGET_PET,
	[2] = SystemData.Events.TARGET_GROUP_MEMBER_1_PET,
	[3] = SystemData.Events.TARGET_GROUP_MEMBER_2_PET,
	[4] = SystemData.Events.TARGET_GROUP_MEMBER_3_PET,
	[5] = SystemData.Events.TARGET_GROUP_MEMBER_4_PET,
	[6] = SystemData.Events.TARGET_GROUP_MEMBER_5_PET
}

--------------------------------------------------------------- EnemyGroupIcon class
EnemyGroupIcon = {}
EnemyGroupIcon.__index = EnemyGroupIcon


function EnemyGroupIcon.New (groupIndex, index, isPet)
	local obj = {}
	setmetatable (obj, EnemyGroupIcon)
	
	obj.groupIndex = groupIndex
	obj.index = index
	obj.isEnabled = false
	obj.isPet = (isPet or false)
	
	obj.settings = Enemy.Settings
	obj:Reset ()
	
	return obj
end


function EnemyGroupIcon:Reset (partial)

	self.playerName = nil
	self.playerWorldObjectId = 0
	self.playerCareer = nil
	self.playerHP = nil
	self.playerIsInPlayerGroup = nil
	
	if (not partial)
	then
		if (self.objectWindow) then self.objectWindow:Remove () end
		
		if (self.windowName) then Enemy.groupIcons.windowNameToCustomTargetEvents[self.windowName] = nil end
		
		self.windowName = nil
		self.objectWindow = nil
	end
end


function EnemyGroupIcon:Disable ()

	if (not self.isEnabled) then return end

	self:Reset ()
	self.isEnabled = false
end


function EnemyGroupIcon:Enable ()
	self.isEnabled = true
end


function EnemyGroupIcon:IsEnabled ()
	return self.isEnabled
end


function EnemyGroupIcon:ApplySettings (settings)

	if (not self.objectWindow) then return end
	
	if (settings) then self.settings = settings end
	
	WindowSetHandleInput (self.windowName, self.settings.groupIconsTargetOnClick)
end


function EnemyGroupIcon:GetSettingsPrefix (player)

	local settings_prefix = "groupIcons"
	
	if (self.isPet)
	then
		settings_prefix = settings_prefix.."Pet"
		
	else
		
		if (not player)
		then
			player = Enemy.groups.players[self.playerName]
		end
		
		if (player and not player.isInPlayerGroup)
		then
			settings_prefix = settings_prefix.."OtherGroups"
		end
	end
	
	return settings_prefix
end


function EnemyGroupIcon:Attach (player)

	self:Reset ()
	
	self.windowName = "EnemyGroupIcon"..self.groupIndex.."_"..self.index
	
	if (self.isPet)
	then
		self.windowName = self.windowName.."_pet"
		Enemy.groupIcons.windowNameToCustomTargetEvents[self.windowName.."Content"] = PetTargetEvents[player.owner.index]
	end
	
	self.playerName = player.name
	self.playerWorldObjectId = player.worldObjectId
	self.playerCareer = player.career
	
	local settings_prefix = self:GetSettingsPrefix(player)
	
	-- create icon window
	CreateWindowFromTemplate (self.windowName, "EnemyGroupIcon", "Root")
	self.windowWidth, self.windowHeight = WindowGetDimensions (self.windowName)
	
	-- icon
	if (not self.isPet)
	then
		local texture, texture_x, texture_y = GetIconData (Icons.GetCareerIconIDFromCareerLine (self.playerCareer))
		DynamicImageSetTexture (self.windowName.."ContentIcon", texture, texture_x, texture_y)
	else
		DynamicImageSetTexture (self.windowName.."ContentIcon", "enemy_group_icon_pet", 0, 0)
		WindowSetTintColor (self.windowName.."ContentIcon", unpack (self.settings[settings_prefix.."IconColor"]))
	end
	
	-- size
	local scale = self.settings[settings_prefix.."Scale"]
	
	local dx = (self.windowWidth + mabs (2 * self.settings[settings_prefix.."Offset"][1])) * scale
	local dy = (self.windowHeight + mmin (0, self.settings[settings_prefix.."Offset"][2])) * scale
	
	if (self.settings[settings_prefix.."Offset"][2] >= 0)
	then	
		dy = dy + self.settings[settings_prefix.."Offset"][2] * scale
	end
	
	WindowSetDimensions (self.windowName, dx, dy)
	
	-- positions
	WindowClearAnchors (self.windowName.."Content")
	WindowAddAnchor (self.windowName.."Content", "topleft", self.windowName, "topleft",
		mabs (self.settings[settings_prefix.."Offset"][1]) + self.settings[settings_prefix.."Offset"][1],
		mmax (0, -self.settings[settings_prefix.."Offset"][2]))
	
	WindowSetLayer (self.windowName, self.settings[settings_prefix.."Layer"])
	
	if (not self.isPet)
	then
		WindowSetGameActionData (self.windowName.."Content", GameData.PlayerActions.SET_TARGET, 0, self.playerName)
	end
	
	-- color
	WindowSetAlpha (self.windowName.."ContentBackground", self.settings[settings_prefix.."BGAlpha"])
	WindowSetTintColor (self.windowName.."ContentHPBG", unpack (self.settings[settings_prefix.."HPBGColor"]))
	WindowSetScale (self.windowName.."Content", scale)
	WindowSetAlpha (self.windowName.."Content", self.settings[settings_prefix.."Alpha"])
	
	-- attach it to player world object
	self.objectWindow = EnemyObjectWindow.New (
	{
		windowName = self.windowName,
		id = self.playerWorldObjectId,
		objectName = self.playerName,
		
		data = { groupIcon = self },
		timeout = 10,
		inactiveTimeout = -1,		-- disable automatic removing
		
		removeCallback = function (item)
		
			if (DoesWindowExist (item.windowName))
			then
				DestroyWindow (item.windowName)
			end
			
			self.windowName = nil
			self.objectWindow = nil
		end,
		
		activeChangedCallback = function (item)
		
			if (item.isActive)
			then
				WindowSetScale (item.windowName.."Content", self.settings[settings_prefix.."Scale"])
			end
		end
	})
	
	self:ApplySettings ()
	self:Update (player)
end



function EnemyGroupIcon:Update (player)

	if (not self.isEnabled) then return end
	
	if (player.worldObjectId == 0)
	then
		if (self.playerName or self.windowName)
		then
			self:Reset ()
		end
		
		return
	end
	
	if (
			not self.objectWindow
			or self.playerName ~= player.name
			or self.playerWorldObjectId ~= player.worldObjectId
		)
	then
		self:Attach (player)
		return
	end
	
	local settings_prefix = self:GetSettingsPrefix(player)
	
	if (self.playerHP ~= player.hp)
	then
		self.playerHP = player.hp
	
		if (self.playerHP > 0)
		then
			WindowSetTintColor (self.windowName.."ContentBackground", unpack (self.settings[settings_prefix.."BGColor"]))
			WindowSetTintColor (self.windowName.."ContentHP", unpack (self.settings[settings_prefix.."HPColor"]))
			WindowSetShowing (self.windowName.."ContentHPBG", true)
			
			local image_index = mfloor (self.playerHP / 20 + 0.5)
			if (image_index == 0)
			then
				WindowSetShowing (self.windowName.."ContentHP", false)
			else
				WindowSetShowing (self.windowName.."ContentHP", true)
				DynamicImageSetTexture (self.windowName.."ContentHP", "enemy_group_icon_hp"..image_index, 0, 0)
			end
		else
			WindowSetTintColor (self.windowName.."ContentBackground", unpack (COLOR_BG_DEAD))
			WindowSetShowing (self.windowName.."ContentHPBG", false)
			WindowSetShowing (self.windowName.."ContentHP", false)
		end
	end
end


