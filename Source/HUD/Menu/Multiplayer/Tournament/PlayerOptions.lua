PlayerOptions =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },
	fontBig		= "timesbd",
	fontSmall	= "timesbd",


	fontBigSize = 36,
	backAction = "PainMenu:ApplySettings(); PainMenu:ActivateScreen(MultiplayerMenu)",
	applyAction = "PainMenu:ApplySettings(); PainMenu:ActivateScreen(MultiplayerMenu)",

	items =
	{
		PlayerBorder = 
		{
			type = MenuItemTypes.Border,
			x = 60,
			y = 60,
			width = 554,
			height = 415,
		},

		PlayerName =
		{
			type = MenuItemTypes.TextEdit,
			text = TXT.Menu.Name..":",
			desc = TXT.MenuDesc.Name,
			option = "PlayerName",
			x	 = 80,
			y	 = 100,
			action = "",
			maxLength = 16,
		},

		Team =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.TeamName,
			desc = TXT.MenuDesc.TeamName,
			option = "Team",
			values = { 0, 1 },
			visible = { TXT.Menu.Blue, TXT.Menu.Red },
			x	 = 80,
			y	 = 160,
			action = "",
		},

		ConnectionSpeed =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.ConnectionSpeed,
			desc = TXT.MenuDesc.ConnectionSpeed,
			option = "ConnectionSpeed",
			values = {4},
			visible = {TXT.Menu.LANT1,},
			x	 = 80,
			y	 = 220,
			action = "",
		},

		CDKey =
		{
			type = MenuItemTypes.TextEdit,
			text = TXT.Menu.CDKey..":",
			desc = TXT.MenuDesc.CDKey,
			option = "CDKey",
			x	 = 80,
			y	 = 280,
			action = "",
			maxLength = 20,
		},
		
		ModelBorder = 
		{
			type = MenuItemTypes.Border,
			x = 630,
			y = 60,
			width = 330,
			height = 415,
		},
		
--		ModelSelect =
--		{
--			type = MenuItemTypes.TextButtonEx,
--			text = TXT.Menu.PlayerModel,
--			desc = TXT.MenuDesc.PlayerModel,
--			option = "PlayerModel",
--			values = {2},
--			visible = {TXT.Menu.Model2},
--			x	 = 80,
--			y	 = 340,
--			action = "",
--		},
		
		
		PlayerModel =
		{
			type = MenuItemTypes.PlayerModel,
			text = "",
			desc = "",
			option = "",
			x	 = -1,
			y	 = 500,
			action = "",
		},
		
		LPickerBorder = 
		{
			type = MenuItemTypes.Border,
			x = 60,
			y = 495,
			width = 904,
			height = 100,
		},
		
		CharPicker =
		{
			type = MenuItemTypes.CharPicker,
			text = "",
			desc = "",
			option = "",
			x	 = 78,
			y	 = 513,
			action = "",
			fontBigSize = 24,
		},
		
		CPickerBorder = 
		{
			type = MenuItemTypes.Border,
			x = 320,
			y = 615,
			width = 640,
			height = 60,
		},

		DelButton =
		{
			text = TXT.Menu.Delete,
			desc = "",
			x	 = 902,
			y	 = 525,
			align = MenuAlign.Center,
			action = "",
			fontBigSize = 26,
		},
		
		EnterButton =
		{
			text = TXT.Menu.Enter,
			desc = "",
			x	 = 902,
			y	 = 555,
			align = MenuAlign.Center,
			action = "",
			fontBigSize = 26,
			sndAccept   = "menu/menu/key-set",
		},
		
		ColorPicker =
		{
			type = MenuItemTypes.ColorPicker,
			text = "",
			desc = "",
			option = "",
			x	 = 338,
			y	 = 633,
			action = "",
		}
	}
}
