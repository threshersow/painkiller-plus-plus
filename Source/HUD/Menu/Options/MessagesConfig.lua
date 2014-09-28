MessagesConfig =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	backAction = "PainMenu:ApplySettings(); PainMenu:ActivateScreen(OptionsMenu)",
	applyAction = "",

	menuWidth   = 880,
	fontBigSize = 26,

	items =
	{
		MessagesBorder =
		{
			type = MenuItemTypes.Border,
			x = 50,
			y = 110,
			width = 924,
			height = 526,
			header = 50,
		},

		WeaponsSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 404,
			y = 68,
			width = 180,
			height = 52,
		},
		
		GeneralSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 50,
			y = 68,
			width = 190,
			height = 52,
		},
		
		AdvancedSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 234,
			y = 68,
			width = 176,
			height = 52,
		},
		
		MessagesSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 576,
			y = 60,
			width = 180,
			height = 60,
			dark = true,
		},
		
		GeneralSettings =
		{
			text = TXT.Menu.General,
			desc = TXT.MenuDesc.General,
			x	 = 140,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PainMenu:ApplySettings(); PainMenu:ActivateScreen(ControlsConfig); PMENU.SetBorderSize( 'KeyBorder', 924, 410 ); PMENU.SetScrollerHeight('KeyScroller',440); PainMenu:HideTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab')",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		AdvancedSettings =
		{
			text = TXT.Menu.Advanced,
			desc = TXT.MenuDesc.Advanced,
			x	 = 320,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PainMenu:ApplySettings(); PainMenu:ActivateScreen(ControlsConfig); PMENU.SetBorderSize( 'KeyBorder', 924, 524 ); PMENU.SetScrollerHeight('KeyScroller',546); PainMenu:HideTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab')",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		WeaponsSettings =
		{
			text = TXT.Menu.Weapons,
			desc = TXT.MenuDesc.WeaponsConfig,
			x	 = 490,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PainMenu:ApplySettings(); PainMenu:ActivateScreen(WeaponsConfig)",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		MessagesSettings =
		{
			text = TXT.Menu.Messages,
			desc = TXT.MenuDesc.Messages,
			x	 = 666,
			y	 = 78,
			align = MenuAlign.Center,
			action = "",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},

		KeyText =
		{
			type = MenuItemTypes.StaticText,
			text = TXT.Menu.Key,
			desc = "",
			x = 122,
			y = 130,
			align = MenuAlign.Center,
		},
		
		SAText =
		{
			text = TXT.Menu.SA,
			desc = TXT.MenuDesc.SA,
			x = 215,
			y = 130,
			align = MenuAlign.Center,
			underMouseColor = R3D.RGBA( 255, 186, 122, 255 ),
		},
		
		MessageText =
		{
			type = MenuItemTypes.StaticText,
			text = TXT.Menu.Message,
			desc = "",
			x = 600,
			y = 130,
			align = MenuAlign.Center,
		},

		MessagesKeys =
		{
			type = MenuItemTypes.MessagesKeys,
			count = 18,
		},
	},
}
