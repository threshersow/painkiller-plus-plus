OptionsMenu =
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
		ConfigureControls =
		{
			text = TXT.Menu.Controls,
			desc = TXT.MenuDesc.Controls,
			x	 = 15,
			y	 = 630,
			action = "PainMenu:ActivateScreen(ControlsConfig)",
		},
		
		ConfigureHUD =
		{
			text = TXT.Menu.HUD,
			desc = TXT.MenuDesc.HUD,
			x	 = 15,
			y	 = 390,
			action = "PainMenu:ActivateScreen(HUDConfig)",
		},

		SoundOptions =
		{
			text = TXT.Menu.Sound,
			desc = TXT.MenuDesc.Sound,
			x	 = 15,
			y	 = 470,
			action = "PainMenu:ActivateScreen(SoundOptions)",
		},

		VideoOptions =
		{
			text = TXT.Menu.Video,
			desc = TXT.MenuDesc.Video,
			x	 = 15,
			y	 = 550,
			action = "PainMenu:ActivateScreen(VideoOptions)",
		},
		PkGui =
		{
			text = "PK++GUI",
			desc = "Extra multiplayer tweakings for tournament play",
			x	 = 15,
			y	 = 710,
			action = "PainMenu:ActivateScreen(Pkgui)",
		},
--[[		
		AdvancedOptions =
		{
			text = TXT.Menu.AdvancedVideo,
			desc = TXT.MenuDesc.AdvancedVideo,
			x	 = 15,
			y	 = 550,
			action = "PainMenu:ActivateScreen(AdvancedVideoOptions)",
		},]]--
	}
}
