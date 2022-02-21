Obsidian.Settings = 
{
	Version = 3,
	GlobalCooldown = 
	{
		Enabled = false,
		Spark = 
		{
			Color = 
			{
				R = 255,
				G = 255,
				B = 255,
			},
			Alpha = 1,
		},
		Divider = 
		{
			Color = 
			{
				R = 255,
				G = 255,
				B = 255,
			},
			Alpha = 1,
		},
		Width = "100%",
		Y = 0,
		X = 0,
		Position = 2,
		Reverse = false,
		FillReady = 
		{
			Color = 
			{
				R = 0,
				G = 0,
				B = 0,
			},
			Alpha = 0.8,
		},
		Background = 
		{
			Color = 
			{
				R = 0,
				G = 0,
				B = 0,
			},
			Alpha = 0.8,
		},
		Height = 4,
		Fill = 
		{
			Color = 
			{
				R = 0,
				G = 0,
				B = 0,
			},
			Alpha = 0.8,
		},
	},
	EffectTracker = 
	{
		Hostile = 
		{
			Enabled = false,
			Color = 
			{
				R = 0,
				G = 22,
				B = 165,
			},
			ShowBuffs = false,
			FillType = 1,
			Y = -1,
			MaximumEffects = 5,
			Position = 2,
			ShowDebuffs = true,
			Icon = 
			{
				Enabled = true,
				X = 3,
				Position = 2,
				Scale = 1,
				Alpha = 1,
				Y = 0,
			},
			X = 0,
		},
		General = 
		{
			Size = 
			{
				Height = 15,
				Border = 0,
				Width = 170,
			},
			MaximumThreshold = 3600,
			Name = 
			{
				Enabled = true,
				Scale = 0.8,
				Alpha = 1,
				Width = 0.75,
				Y = 0,
				X = 4,
				Alignment = "leftcenter",
				Font = "font_clear_small",
				Color = 
				{
					R = 255,
					G = 255,
					B = 255,
				},
			},
			Spacing = 1,
			Timer = 
			{
				Enabled = true,
				X = -4,
				Alignment = "rightcenter",
				Y = 0,
				Scale = 0.8,
				Color = 
				{
					R = 255,
					G = 255,
					B = 255,
				},
				Alpha = 1,
				Font = "font_clear_small",
			},
			Background = 
			{
				Color = 
				{
					R = 0,
					G = 0,
					B = 0,
				},
				TextureDimensions = 
				{
					Height = 1,
					Width = 1,
				},
				Alpha = 0.6,
				Texture = "EA_TintableImage",
			},
			FixedDuration = 0,
			Fill = 
			{
				TextureDimensions = 
				{
					Height = 32,
					Width = 256,
				},
				Priority = 2,
				Alpha = 1,
				Texture = "SharedMediaBantoBar",
			},
		},
		Friendly = 
		{
			Enabled = false,
			Color = 
			{
				R = 0,
				G = 22,
				B = 165,
			},
			ShowBuffs = true,
			FillType = 1,
			Y = -1,
			MaximumEffects = 5,
			Position = 1,
			ShowDebuffs = false,
			Icon = 
			{
				Enabled = true,
				X = -3,
				Position = 1,
				Scale = 1,
				Alpha = 1,
				Y = 0,
			},
			X = 0,
		},
	},
	Castbar = 
	{
		Spark = 
		{
			Color = 
			{
				R = 255,
				G = 255,
				B = 255,
			},
			Alpha = 1,
		},
		Scale = 0.80000001192093,
		Range = 
		{
			Enabled = true,
			Color = 
			{
				R = 255,
				G = 0,
				B = 0,
			},
		},
		Size = 
		{
			Height = 8,
			Border = 2,
			Width = 384,
		},
		Fill = 
		{
			Colors = 
			{
				Normal = 
				{
					R = 255,
					G = 146,
					B = 155,
				},
				Success = 
				{
					R = 0,
					G = 255,
					B = 0,
				},
				Failed = 
				{
					R = 255,
					G = 0,
					B = 0,
				},
				Channeled = 
				{
					R = 82,
					G = 77,
					B = 255,
				},
			},
			TextureDimensions = 
			{
				Height = 32,
				Width = 256,
			},
			Priority = 3,
			Alpha = 1,
			Texture = "SharedMediaAluminium",
		},
		Accurate = true,
		Name = 
		{
			Enabled = true,
			Scale = 1,
			Alpha = 1,
			Width = 0.75,
			Y = -16,
			X = 2,
			Alignment = "leftcenter",
			Font = "font_clear_medium_bold",
			Color = 
			{
				R = 255,
				G = 255,
				B = 255,
			},
		},
		Position = 
		{
			Y = 1021.5580902009,
			X = 1143.9999392018,
		},
		Timer = 
		{
			Enabled = true,
			Decimals = 1,
			Scale = 1,
			Alpha = 1,
			Y = -16,
			X = -2,
			Alignment = "rightcenter",
			Font = "font_clear_medium_bold",
			Color = 
			{
				R = 255,
				G = 255,
				B = 255,
			},
		},
		Background = 
		{
			Color = 
			{
				R = 0,
				G = 0,
				B = 0,
			},
			TextureDimensions = 
			{
				Height = 1,
				Width = 1,
			},
			Alpha = 0.75698244571686,
			Texture = "EA_TintableImage",
		},
		Icon = 
		{
			Enabled = true,
			X = -4,
			Position = 1,
			Scale = 2.8,
			Alpha = 1,
			Y = -10,
		},
		Latency = 
		{
			Enabled = true,
			Text = 
			{
				Enabled = true,
				Font = "font_clear_tiny",
				Color = 
				{
					R = 178,
					G = 178,
					B = 178,
				},
				Alpha = 0.8,
				Scale = 0.6,
			},
			Alpha = 0.6,
			Color = 
			{
				R = 255,
				G = 0,
				B = 0,
			},
		},
	},
}



