GameMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	firstTimeShowItems = 80,
	
	textColor	= R3D.RGBA( 100, 100, 100, 255 ),
	disabledColor = R3D.RGBA( 155, 155, 155, 255 ),
	
	fontBigTex  = "../PKPlusData/font_texturka_alpha",
	fontSmallTex  = "../PKPlusData/font_texturka_alpha",
	descColor	= R3D.RGB( 255, 255, 255 ),

	useItemBG = true,

	backAction = "PainMenu:ActivateScreen(MainMenu)",

	items		=
	{
		GameBorder =
		{
			type = MenuItemTypes.Border,
			x = 280,
			y = 120,
			width = 464,
			height = 60,
		},
		
		Game =
		{
			type = MenuItemTypes.StaticText,
			text = TXT.Menu.SelectGame,
			x	 = -1,
			y	 = 144,
			action = "",
			useItemBG = false,
			fontBigSize = 26,
			fontBigTex = "",
			textColor	= R3D.RGBA( 255, 186, 122, 255 ),
		},

		Painkiller =
		{
			text = TXT.Menu.Painkiller,
			desc = "",
			x	 = -1,
			y	 = 300,
			action = "PainMenu:SignAPact(1,false)",
			sndLightOn = "menu/menu/option-light-on_main",
		},
		
		BattleOutOfHell =
		{
			text = TXT.Menu.BattleOutOfHell,
			desc = "",
			x	 = -1,
			y	 = 380,
			action = "PainMenu:SignAPact(1,true)",
			sndLightOn = "menu/menu/option-light-on_main",
		},
	}
}
