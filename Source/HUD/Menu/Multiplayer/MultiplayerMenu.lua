MultiplayerMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	firstTimeShowItems = 80,

	backAction = "PainMenu:ActivateScreen(MainMenu)",
	
	textColor	= R3D.RGBA( 255, 255, 255, 255 ),
	disabledColor = R3D.RGBA( 155, 155, 155, 255 ),
	
	fontBigTex  = "../PKPlusData/font_texturka_alpha",
	fontSmallTex  = "../PKPlusData/font_texturka_alpha",
	descColor	= R3D.RGB( 255, 255, 255 ),
	
	useItemBG = false,

	items =
	{
		JoinGame =
		{
			text = TXT.Menu.JoinGame,
			desc = TXT.MenuDesc.JoinGame,
			x	 = 15,
			y	 = 550,
			action = "PainMenu:ActivateScreen(LANGameMenu)",
		},

		StartGame =
		{
			text = TXT.Menu.StartGame,
			desc = TXT.MenuDesc.StartGame,
			x	 = 15,
			y	 = 630,
			action = "PainMenu:ActivateScreen(CreateServerMenu)",
		},

		PlayerSettings =
		{
			text = TXT.Menu.PlayerSettings,
			desc = TXT.MenuDesc.PlayerSettings,
			x	 = 15,
			y	 = 710,
			action = "PainMenu:ActivateScreen(PlayerOptions)",
		},
	}
}
