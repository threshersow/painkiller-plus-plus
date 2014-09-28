LANGameMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	firstTimeShowItems = 80,
	menuWidth   = 880,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	backAction = "PainMenu:ActivateScreen(MultiplayerMenu)",

	items =
	{
		InternetBorder =
		{
			type = MenuItemTypes.Border,
			x = 164,
			y = 68,
			width = 148,
			height = 58,
		},

		InternetGame = 
		{
			text = TXT.Menu.Internet,
			desc = TXT.MenuDesc.Internet,
			x	 = 180,
			y	 = 88,
			action = "PainMenu:StopServerList(); PainMenu:ActivateScreen(InternetGameMenu)",
			fontBigSize = 30,
			align = MenuAlign.Left,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			sndAccept   = "menu/magicboard/card-take",
		},

		LANBorder =
		{
			type = MenuItemTypes.Border,
			x = 74,
			y = 60,
			width = 96,
			height = 64,
			dark = true,
		},

		LANGame = 
		{
			text = TXT.Menu.LAN,
			desc = TXT.MenuDesc.LAN,
			x	 = 90,
			y	 = 80,
			action = "",
			fontBigSize = 30,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			sndAccept   = "menu/magicboard/card-take",
		},

		FavBorder =
		{
			type = MenuItemTypes.Border,
			x = 304,
			y = 68,
			width = 154,
			height = 58,
		},

		Favorites = 
		{
			text = TXT.Menu.Favorites,
			desc = TXT.MenuDesc.Favorites,
			x	 = 320,
			y	 = 88,
			action = "PainMenu:StopServerList(); PainMenu:ActivateScreen(FavoritesGameMenu)",
			fontBigSize = 30,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			sndAccept   = "menu/magicboard/card-take",
		},
		
		AddToFavorites = 
		{
			text = TXT.Menu.AddToFavorites,
			desc = TXT.MenuDesc.AddToFavorites,
			x	 = -1,
			y	 = 80,
			action = "PainMenu:AddServerToFavorites()",
			fontBigSize = 30,
			align = MenuAlign.Right,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
--			disabled = 1,
			visible = false,
			sndAccept   = "menu/magicboard/card-take",
		},

		ServerList =
		{
			text = "",
			desc = "",
			action = "",
--			fontBig = "default",
--			fontBigSize = 0,
			fontBig = "timesbd",
			fontBigSize = 18,
			disabledColor = R3D.RGB( 200, 0, 0 ),
			type = MenuItemTypes.ServerList,
			lanOnly = true,
		},

		RefreshStop =
		{
			text = TXT.Menu.Refresh,
			desc = TXT.MenuDesc.Refresh,
			x	 = -1,
			y	 = 660,
			action = "PainMenu:RefreshServerList()",
			fontBigSize = 36,
--			align = MenuAlign.Center,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Spectate =
		{
			text = TXT.Menu.Spectate,
			desc = TXT.MenuDesc.Spectate,
			x	 = 952,
			y	 = 620,
			action = "PainMenu.lastScreen='joinlan'; PainMenu:JoinServer( false, true )",
			fontBigSize = 36,
			align = MenuAlign.Right,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},
		
		Join =
		{
			text = TXT.Menu.Join,
			desc = TXT.MenuDesc.Join,
			x	 = 952,
			y	 = 660,
			action = "PainMenu.lastScreen='joinlan'; PainMenu:JoinServer( false )",
			fontBigSize = 36,
			align = MenuAlign.Right,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},
		

	}
}
