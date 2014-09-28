HUDConfig =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	fontBigSize = 36,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	backAction = "PainMenu:ApplySettings(true); HUD.SetTransparency(Cfg.HUDTransparency); PainMenu:ActivateScreen(OptionsMenu)",
	applyAction = "",

	items =
	{
		HUDBorder =
		{
			type = MenuItemTypes.Border,
			x = 120,
			y = 80,
			width = 784,
			height = 180,
		},
		
		HeadBob =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.HeadBob,
			desc = TXT.MenuDesc.HeadBob,
			option = "HeadBob",
			minValue = 0,
			maxValue = 100,
			x	 = 160,
			y	 = 110,
			action = "",
		},
		
		HUDTransparency =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.HUDTransparency,
			desc = TXT.MenuDesc.HUDTransparency,
			option = "HUDTransparency",
			minValue = 0,
			maxValue = 100,
			x	 = 160,
			y	 = 160,
			action = "",
		},
		
		HUDSize =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.HUDSize,
			desc = TXT.MenuDesc.HUDSize,
			option = "HUDSize",
			values = { 0.6, 1.0, 1.5 },
			visible = { TXT.Menu.Small, TXT.Menu.Normal, TXT.Menu.Large },
			x	 = -1,
			y	 = 210,
			action = "",
			align = MenuAlign.None,
		},

		CrosshairBorder =
		{
			type = MenuItemTypes.Border,
			x = 120,
			y = 290,
			width = 784,
			height = 336,
		},

		CrossImage =
		{
			type = MenuItemTypes.SliderImage,
			text = TXT.Menu.Crosshair,
			desc = TXT.MenuDesc.Crosshair,
			option = "Crosshair",
			minValue = 1,
			maxValue = 35,
			x	 = 160,
			y	 = 330,
			action = "",
			images =
			{
				"HUD/crosshair", "HUD/crossy/cross1", "HUD/crossy/cross2", "HUD/crossy/cross3",
				"HUD/crossy/cross4", "HUD/crossy/cross5", "HUD/crossy/cross6", "HUD/crossy/cross7",
				"HUD/crossy/cross8", "HUD/crossy/cross9", "HUD/crossy/cross91", "HUD/crossy/cross92",
				"HUD/crossy/cross93", "HUD/crossy/cross94", "HUD/crossy/cross95", "HUD/crossy/cross96",
				"HUD/crossy/cross97", "HUD/crossy/cross98", "HUD/crossy/cross99", "HUD/crossy/cross991",
				"HUD/crossy/cross992", "HUD/crossy/cross993", "HUD/crossy/cross994", "HUD/crossy/cross995",
				"HUD/crossy/cross996", "HUD/crossy/cross997", "HUD/crossy/cross998", "HUD/crossy/cross999",
				"HUD/crossy/cross9991", "HUD/crossy/cross9992", "HUD/crossy/cross9993", "HUD/crossy/cross9994",
				"../PKPlusData/Crosshairs/crosshairc", "../PKPlusData/Crosshairs/crosshairb" 
			}
		},
		
		CrosshairTrans =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.CrosshairTrans,
			desc = TXT.MenuDesc.CrosshairTrans,
			option = "CrosshairTrans",
			minValue = 0,
			maxValue = 100,
--			isFloat = true,
			x	 = 160,
			y	 = 390,
			action = "",
		},
		
		CrosshairR =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.CrosshairR,
			desc = TXT.MenuDesc.CrosshairR,
			option = "CrosshairR",
			minValue = 0,
			maxValue = 255,
			x	 = 160,
			y	 = 450,
			action = "",
		},
		
		CrosshairG =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.CrosshairG,
			desc = TXT.MenuDesc.CrosshairG,
			option = "CrosshairG",
			minValue = 0,
			maxValue = 255,
			x	 = 160,
			y	 = 510,
			action = "",
		},
		
		CrosshairB =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.CrosshairB,
			desc = TXT.MenuDesc.CrosshairB,
			option = "CrosshairB",
			minValue = 0,
			maxValue = 255,
			x	 = 160,
			y	 = 570,
			action = "",
		},
	}
}
