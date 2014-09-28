OptionsMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	firstTimeShowItems = 80,

	backAction = "PainMenu:ActivateScreen(MainMenu)",
	
	textColor	= R3D.RGBA( 100, 100, 100, 255 ),
	disabledColor = R3D.RGBA( 155, 155, 155, 255 ),
	
	fontBigTex  = "HUD/font_texturka_alpha",
	fontSmallTex  = "HUD/font_texturka_alpha",
	descColor	= R3D.RGB( 255, 255, 255 ),
	
	useItemBG = true,

	items =
	{
		ConfigureControls =
		{
			text = TXT.Menu.Controls,
			desc = TXT.MenuDesc.Controls,
			x	 = -1,
			y	 = 210,
			action = "PainMenu:ActivateScreen(ControlsConfig)",
		},
		
		ConfigureHUD =
		{
			text = TXT.Menu.HUD,
			desc = TXT.MenuDesc.HUD,
			x	 = -1,
			y	 = 290,
			action = "PainMenu:ActivateScreen(HUDConfig)",
		},

		SoundOptions =
		{
			text = TXT.Menu.Sound,
			desc = TXT.MenuDesc.Sound,
			x	 = -1,
			y	 = 370,
			action = "PainMenu:ActivateScreen(SoundOptions)",
		},

		VideoOptions =
		{
			text = TXT.Menu.Video,
			desc = TXT.MenuDesc.Video,
			x	 = -1,
			y	 = 450,
			action = "PainMenu:ActivateScreen(VideoOptions)",
		},
		
		Credits =
		{
			text = TXT.Menu.Credits,
			desc = TXT.MenuDesc.Credits,
			x	 = -1,
			y	 = 530,
			action = "if not IsPKInstalled() then PainMenu:Disconnect(); PMENU.ShowCredits(true) else PainMenu:ActivateScreen(CreditsMenu) end",
		},
--[[		
		AdvancedOptions =
		{
			text = TXT.Menu.AdvancedVideo,
			desc = TXT.MenuDesc.AdvancedVideo,
			x	 = -1,
			y	 = 550,
			action = "PainMenu:ActivateScreen(AdvancedVideoOptions)",
		},]]--
	}
}
