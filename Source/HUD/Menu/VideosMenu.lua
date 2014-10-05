VideosMenu =
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
		VideoBorder =
		{
			type = MenuItemTypes.Border,
			x = 280,
			y = 120,
			width = 464,
			height = 60,
		},
		
		Videos =
		{
			type = MenuItemTypes.StaticText,
			text = TXT.Menu.SelectVideo,
			x	 = -1,
			y	 = 144,
			action = "",
			useItemBG = false,
			fontBigSize = 26,
			fontBigTex = "",
			textColor	= R3D.RGBA( 255, 186, 122, 255 ),
		},

		MakingOf =
		{
			text = TXT.Menu.MakingOf,
			desc = "",
			x	 = -1,
			y	 = 270,
			action = "PMENU.PlayMovie('../Data/Movies/making_of.bik')",
			sndLightOn = "menu/menu/option-light-on_main",
		},
		
		XBox =
		{
			text = TXT.Menu.XBoxTrailer,
			desc = "",
			x	 = -1,
			y	 = 350,
			action = "PMENU.PlayMovie('../Data/Movies/xbox_trailer.bik')",
			sndLightOn = "menu/menu/option-light-on_main",
		},
		
		Mech =
		{
			text = TXT.Menu.Mech,
			desc = "",
			x	 = -1,
			y	 = 430,
			action = "PMENU.PlayMovie('../Data/Movies/mech_video.bik')",
			sndLightOn = "menu/menu/option-light-on_main",
		},
	}
}
