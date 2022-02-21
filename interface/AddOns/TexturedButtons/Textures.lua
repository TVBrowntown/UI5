--[[

Add your textures here. Copy and paste one of the below methods to add your own texture

[ Method 1 ]:

TexturedButtons.Register({
	Name = "NAME/IDENTIFIER",
	Author = "AUTHOR",
	Description = "DESCRIPTION",
	Textures = {
		Normal = "TEXTURE",
		Highlighted = "TEXTURE",
		Pressed = "TEXTURE",
		PressedHighlighted = "TEXTURE",
	},
});

[ Method 1 with optional parameters ]:

TexturedButtons.Register({
	Name = "NAME/IDENTIFIER",
	Author = "AUTHOR",
	Description = "DESCRIPTION",
	Textures = {
		Normal = "TEXTURE",
		Highlighted = "TEXTURE",
		Pressed = "TEXTURE",
		PressedHighlighted = "TEXTURE",
	},
	Slices = {
		Normal = "SLICE",
		Highlighted = "SLICE",
		Pressed = "SLICE",
		PressedHighlighted = "SLICE",
	},
	Size = {
		X = 0,
		Y = 0,
		Width = 64,
		Height = 64,
	},
	KeybindOffset = {
		X = -5,
		Y = 5,
	}
});

[ Method 2 ]:

TexturedButtons.Register("NAME/IDENTIFIER", "AUTHOR", "DESCRIPTION", "NORMAL_TEXTURE", "HIGHLIGHTED_TEXTURE", "PRESSED_TEXTURE", "PRESSED_HIGHLIGHTED_TEXTURE");

]]--

TexturedButtons.Register({
	Name = "Gloss",
	Author = "Sunspots",
	Description = "Custom glossy textures",
	Textures = {
		Normal = "TexturedButtons_Gloss",
		Highlighted = "TexturedButtons_Gloss",
		Pressed = "TexturedButtons_Gloss_Down",
		PressedHighlighted = "TexturedButtons_Gloss",
	},
});

TexturedButtons.Register({
	Name = "Neo1 Gloss",
	Author = "Neo2121",
	Description = "Custom glossy textures",
	Textures = {
		Normal = "TexturedButtons_GlossNeo1",
		Highlighted = "TexturedButtons_GlossNeo1",
		Pressed = "TexturedButtons_GlossNeo1",
		PressedHighlighted = "TexturedButtons_GlossNeo1",
	},
});

TexturedButtons.Register({
	Name = "Neo2 Gloss",
	Author = "Neo2121",
	Description = "Custom glossy textures",
	Textures = {
		Normal = "TexturedButtons_GlossNeo2",
		Highlighted = "TexturedButtons_GlossNeo2",
		Pressed = "TexturedButtons_GlossNeo2",
		PressedHighlighted = "TexturedButtons_GlossNeo2",
	},
});

TexturedButtons.Register({
	Name = "Neo3 Gloss",
	Author = "Neo2121",
	Description = "Custom glossy textures",
	Textures = {
		Normal = "TexturedButtons_GlossNeo3",
		Highlighted = "TexturedButtons_GlossNeo3",
		Pressed = "TexturedButtons_GlossNeo3",
		PressedHighlighted = "TexturedButtons_GlossNeo3",
	},
});

TexturedButtons.Register({
	Name = "NAMBLA (None)",
	Author = "N/A",
	Description = "Removes the textures from buttons",
	Textures = {
		Normal = "",
		Highlighted = "",
		Pressed = "",
		PressedHighlighted = "",
	},
});

TexturedButtons.Register({
	Name = "SNT Skin 01",
	Author = "SNT",
	Description = "SNT Buttons skin #1",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin1_Normal",
		Highlighted = "Skin1_Highlighted",
		Pressed = "Skin1_Pressed",
		PressedHighlighted = "Skin1_PressedHighlighted",
	},
});

TexturedButtons.Register({
	Name = "SNT Skin 02",
	Author = "SNT",
	Description = "SNT Buttons skin #2\n\nNote: This is the same texture as Neo1 Gloss",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin2_Normal",
		Highlighted = "Skin2_Highlighted",
		Pressed = "Skin2_Pressed",
		PressedHighlighted = "Skin2_PressedHighlighted",
	},
});

TexturedButtons.Register({
	Name = "SNT Skin 03",
	Author = "SNT",
	Description = "SNT Buttons skin #3\n\nNote: This is the same texture as Neo3 Gloss",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin3_Normal",
		Highlighted = "Skin3_Highlighted",
		Pressed = "Skin3_Pressed",
		PressedHighlighted = "Skin3_PressedHighlighted",
	},
});

TexturedButtons.Register({
	Name = "SNT Skin 04",
	Author = "SNT",
	Description = "SNT Buttons skin #4",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin4_Normal",
		Highlighted = "Skin4_Highlighted",
		Pressed = "Skin4_Pressed",
		PressedHighlighted = "Skin4_PressedHighlighted",
	},
	Size = {
		Width = 48,
		Height = 48,
		X = 8,
		Y = 8,
	},
});

TexturedButtons.Register({
	Name = "SNT Skin 05",
	Author = "SNT",
	Description = "SNT Buttons skin #5",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin5_Normal",
		Highlighted = "Skin5_Highlighted",
		Pressed = "Skin5_Pressed",
		PressedHighlighted = "Skin5_PressedHighlighted",
	},
	Size = {
		Width = 48,
		Height = 48,
		X = 8,
		Y = 8,
	},
});

TexturedButtons.Register({
	Name = "SNT Skin 06",
	Author = "SNT",
	Description = "SNT Buttons skin #6",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin6_Normal",
		Highlighted = "Skin6_Highlighted",
		Pressed = "Skin6_Pressed",
		PressedHighlighted = "Skin6_PressedHighlighted",
	},
	Size = {
		Width = 44,
		Height = 44,
		X = 12,
		Y = 12,
	},
	KeybindOffset = {
		X = -7,
		Y = 4,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 07",
	Author = "SNT",
	Description = "SNT Buttons skin #7",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin7_Normal",
		Highlighted = "Skin7_Highlighted",
		Pressed = "Skin7_Pressed",
		PressedHighlighted = "Skin7_PressedHighlighted",
	},
	Size = {
		Width = 46,
		Height = 46,
		X = 10,
		Y = 10,
	},
	KeybindOffset = {
		X = -7,
		Y = 7,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 08",
	Author = "SNT",
	Description = "SNT Buttons skin #8",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin8_Normal",
		Highlighted = "Skin8_Highlighted",
		Pressed = "Skin8_Pressed",
		PressedHighlighted = "Skin8_PressedHighlighted",
	},
	Size = {
		Width = 40,
		Height = 40,
		X = 12,
		Y = 12,
	},
	KeybindOffset = {
		X = -4,
		Y = 6,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 09",
	Author = "SNT",
	Description = "SNT Buttons skin #9",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin9_Normal",
		Highlighted = "Skin9_Highlighted",
		Pressed = "Skin9_Pressed",
		PressedHighlighted = "Skin9_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 10",
	Author = "SNT",
	Description = "SNT Buttons skin #10",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin10_Normal",
		Highlighted = "Skin10_Highlighted",
		Pressed = "Skin10_Pressed",
		PressedHighlighted = "Skin10_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 11",
	Author = "SNT",
	Description = "SNT Buttons skin #11",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin11_Normal",
		Highlighted = "Skin11_Highlighted",
		Pressed = "Skin11_Pressed",
		PressedHighlighted = "Skin11_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 12",
	Author = "SNT",
	Description = "SNT Buttons skin #12",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin12_Normal",
		Highlighted = "Skin12_Highlighted",
		Pressed = "Skin12_Pressed",
		PressedHighlighted = "Skin12_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 13",
	Author = "SNT",
	Description = "SNT Buttons skin #13",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin13_Normal",
		Highlighted = "Skin13_Highlighted",
		Pressed = "Skin13_Pressed",
		PressedHighlighted = "Skin13_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 14",
	Author = "SNT",
	Description = "SNT Buttons skin #14",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin14_Normal",
		Highlighted = "Skin14_Highlighted",
		Pressed = "Skin14_Pressed",
		PressedHighlighted = "Skin14_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 15",
	Author = "SNT",
	Description = "SNT Buttons skin #15",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin15_Normal",
		Highlighted = "Skin15_Highlighted",
		Pressed = "Skin15_Pressed",
		PressedHighlighted = "Skin15_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "SNT Skin 16",
	Author = "SNT",
	Description = "SNT Buttons skin #16",
	Textures = {
		Normal = "TexturedButtons_SNT_Buttons",
		Highlighted = "TexturedButtons_SNT_Buttons",
		Pressed = "TexturedButtons_SNT_Buttons",
		PressedHighlighted = "TexturedButtons_SNT_Buttons",
	},
	Slices = {
		Normal = "Skin16_Normal",
		Highlighted = "Skin16_Highlighted",
		Pressed = "Skin16_Pressed",
		PressedHighlighted = "Skin16_PressedHighlighted",
	},
	KeybindOffset = {
		X = -10,
		Y = 10,
	}
});

TexturedButtons.Register({
	Name = "Aion",
	Description = "Modified ButtonFacade texture for WAR",
	Textures = {
		Normal = "TexturedButtons_Aion_Normal",
		Highlighted = "TexturedButtons_Aion_Highlight",
		Pressed = "TexturedButtons_Aion_Pressed",
		PressedHighlighted = "TexturedButtons_Aion_Highlight",
	},
	KeybindOffset = {
		X = -7,
		Y = 7,
	}
});

TexturedButtons.Register({
	Name = "Entropy",
	Description = "Modified ButtonFacade texture for WAR",
	Textures = {
		Normal = "TexturedButtons_Entropy_Normal",
		Highlighted = "TexturedButtons_Entropy_Highlight",
		Pressed = "TexturedButtons_Entropy_Gloss",
		PressedHighlighted = "TexturedButtons_Entropy_Highlight",
	},
	Size = {
		Width = 52,
		Height = 52,
		X = 6,
		Y = 6,
	}
});

TexturedButtons.Register({
	Name = "Vista",
	Description = "Modified ButtonFacade texture for WAR",
	Textures = {
		Normal = "TexturedButtons_Vista_Normal",
		Highlighted = "TexturedButtons_Vista_Highlight",
		Pressed = "TexturedButtons_Vista_Border",
		PressedHighlighted = "TexturedButtons_Vista_Highlight",
	},
	Size = {
		Width = 50,
		Height = 50,
		X = 6,
		Y = 6,
	}
});

TexturedButtons.Register({
	Name = "FFXIV",
	Description = "FFXIV ButtonFacade texture for WAR",
	Textures = {
		Normal = "TexturedButtons_FFXIV_Normal",
		Highlighted = "TexturedButtons_FFXIV_Highlight",
		Pressed = "TexturedButtons_FFXIV_Border",
		PressedHighlighted = "TexturedButtons_FFXIV_PHighlight"
	},
		Size = {
		Width = 52,
		Height = 52,
		X = 7,
		Y = 8,
	}
});

TexturedButtons.Register({
	Name = "League of Legends",
	Description = "League of Legends inspired ButtonFacade texture for WAR",
	Textures = {
		Normal = "TexturedButtons_LoL_Border",
		Highlighted = "TexturedButtons_Vista_Highlight",
		Pressed = "TexturedButtons_Vista_Border",
		PressedHighlighted = "TexturedButtons_Vista_Highlight",
	},
	Size = {
		Width = 56,
		Height = 56,
		X = 5,
		Y = 5,
	}
});

TexturedButtons.Register({
	Name = "Ryver1",
	Description = "Sleek, modern- not so grubby",
	Textures = {
		Normal = "Ryver_border",
		Highlighted = "Ryver_gloss",
		Pressed = "Ryver_pushed",
		PressedHighlighted = "Ryver_flash",
	},
	Size = {
		Width = 54,
		Height = 54,
		X = 5,
		Y = 5,
	}
});

TexturedButtons.Register({
	Name = "Ryver2",
	Description = "Sleek, modern- not so grubby",
	Textures = {
		Normal = "Ryver_hover",
		Highlighted = "Ryver_backdrop",
		Pressed = "Ryver_checked",
		PressedHighlighted = "Ryver_backdrop",
	},
	Size = {
		Width = 56,
		Height = 56,
		X = 4,
		Y = 4,
	}
});