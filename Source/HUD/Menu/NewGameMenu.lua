NewGameMenu =
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

--	backAction = "PainMenu:ActivateScreen(MainMenu)",
	backAction = "if not IsPKInstalled() then PainMenu:ActivateScreen(MainMenu) elseif not IsBooHInstalled() then PainMenu:ActivateScreen(MainMenu) else PainMenu:ActivateScreen(GameMenu) end",

	items		=
	{
		DifficultyBorder =
		{
			type = MenuItemTypes.Border,
			x = 280,
			y = 120,
			width = 464,
			height = 60,
		},
		
		Difficulty =
		{
			type = MenuItemTypes.StaticText,
			text = TXT.Menu.SelectDiffLevel,
			x	 = -1,
			y	 = 144,
			action = "",
			useItemBG = false,
			fontBigSize = 26,
			fontBigTex = "",
			textColor	= R3D.RGBA( 255, 186, 122, 255 ),
		},

		Daydream =
		{
			text = TXT.Menu.Daydream,
			desc = TXT.MenuDesc.Daydream,
			x	 = -1,
			y	 = 250,
			action = "PainMenu:ShowWarning( Languages.Texts[468], 'PainMenu:SelectDifficulty(0)', 'PainMenu:ActivateScreen(NewGameMenu)', 'ShowDaydreamWarning', Languages.Texts[470] )",
			sndLightOn = "menu/menu/option-light-on_main",
		},
		
		Insomnia =
		{
			text = TXT.Menu.Insomnia,
			desc = TXT.MenuDesc.Insomnia,
			x	 = -1,
			y	 = 330,
			action = "PainMenu:SelectDifficulty(1)",
			sndLightOn = "menu/menu/option-light-on_main",
		},

		Nightmare =
		{
			text = TXT.Menu.Nightmare,
			desc = TXT.MenuDesc.Nightmare,
			x	 = -1,
			y	 = 410,
			action = "PainMenu:SelectDifficulty(2)",
			sndLightOn = "menu/menu/option-light-on_main",
		},
		
		Trauma =
		{
			text = TXT.Menu.Trauma,
			desc = TXT.MenuDesc.TraumaLocked,
			x	 = -1,
			y	 = 490,
			action = "PainMenu:SelectDifficulty(3)",
			disabled = 1,
			sndLightOn = "menu/menu/option-light-on_main",
		},
	}
}
