PUF_BG 		= {"UF_MB_BG", 212, 68}
PUF_Border 	= {"UF_MB_Border", 216, 8}
PUF_HP_Fill = {"UF_MB_HP_Fill", 210, 32}

function UI5.UnitFrameDrawTest()
	local PartyNumber 	= 1
	local PartyMember 	= 1
	local UFbuffer 		= 0
	--temporary numbers to create with
	-- register party window1 for all members of party 1
	CreateWindowFromTemplate("Party"..PartyNumber, "EA_DynamicImage_DefaultSeparatorRight", "Root")
	DynamicImageSetTextureDimensions("Party"..PartyNumber, 1, 1)
	WindowSetDimensions("Party"..PartyNumber, 700, 68) -- 100*6 (600) + 20*5 buffer (100)
	--WindowSetMovable("Party"..PartyNumber, true)
	LayoutEditor.RegisterWindow("Party"..PartyNumber, L"Party"..PartyNumber, L"Party"..PartyNumber, false, false, true, nil)

	--registered our big group
	CreateWindowFromTemplate(PartyNumber.."_"..PartyMember.."_Frame", "EA_DynamicImage_DefaultSeparatorRight", "Party"..PartyNumber)
	WindowSetDimensions(PartyNumber.."_"..PartyMember.."_Frame", 212, 68)

	-- made the click-able frame itself and set the dimensions
	CreateWindowFromTemplate(PartyNumber.."_"..PartyMember.."_BG", "EA_DynamicImage_DefaultSeparatorRight", "Party"..PartyNumber)
	DynamicImageSetTexture(PartyNumber.."_"..PartyMember.."_BG", "UF_MB_BG", 212, 68)
	WindowSetDimensions(PartyNumber.."_"..PartyMember.."_BG", 152, 68)
	-- making a window for the texture now, its done

	--hpfillbar
	CreateWindowFromTemplate(PartyNumber.."_"..PartyMember.."_HPFill", "EA_DynamicImage_DefaultSeparatorRight", "Party"..PartyNumber)
	DynamicImageSetTexture(PartyNumber.."_"..PartyMember.."_HPFill", "UF_MB_HP_Fill", 210, 32)
	WindowSetOffsetFromParent(PartyNumber.."_"..PartyMember.."_HPFill", 4, 4)
	WindowSetDimensions(PartyNumber.."_"..PartyMember.."_HPFill", 140, 52)
	--CreateWindowFromTemplate(WindowCat..UI5.WinNames[k], "EA_DynamicImage_DefaultSeparatorRight", "Root")
end