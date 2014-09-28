VoteMenuMode =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	--backAction = "PainMenu:ApplySettings(false); PainMenu:ActivateScreen(VoteMenu)",
	--applyAction = "PainMenu:ApplySettings(true)",

	items =
	{	
		
	Duel =
		{
			text = "Callvote Gamemode Duel",
			desc = "Callvote Gamemode Duel",
			x	 = 15,
			y	 = 150,
			action = "Console:Cmd_CALLVOTE (\"gamemode duel\")",
			sndLightOn = "menu/menu/option-light-on_main4",
			fontBigSize = 22,
		},

	FFA =
		{
			text = "Callvote Gamemode FFA",
			desc = "Callvote Gamemode FFA",
			x	 = 15,
			y	 = 180,
			action = "Console:Cmd_CALLVOTE (\"gamemode ffa\")",
			sndLightOn = "menu/menu/option-light-on_main4",
			fontBigSize = 22,
		},

	TDM =
		{
			text = "Callvote Gamemode TDM",
			desc = "Callvote Gamemode TDM",
			x	 = 15,
			y	 = 210,
			action = "Console:Cmd_CALLVOTE (\"gamemode tdm\")",
			sndLightOn = "menu/menu/option-light-on_main4",
			fontBigSize = 22,
		},

	ProPlus =
		{
			text = "Callvote Gamemode ProPlus",
			desc = "Callvote Gamemode ProPlus",
			x	 = 15,
			y	 = 240,
			action = "Console:Cmd_CALLVOTE (\"gamemode proplus\")",
			sndLightOn = "menu/menu/option-light-on_main4",
			fontBigSize = 22,
		},

	PCF =
		{
			text = "Callvote Gamemode PCF",
			desc = "Callvote Gamemode PCF",
			x	 = 15,
			y	 = 270,
			action = "Console:Cmd_CALLVOTE (\"gamemode PCF\")",
			sndLightOn = "menu/menu/option-light-on_main4",
			fontBigSize = 22,
		},


		modcredits =
		{
			text = "PK++ Mod Credits",
			desc = "PK++ Developers and Contributions",
			x	 = 500,
			y	 = 750,
			action = "PainMenu:ActivateScreen(PKpluscredits)",
			align = MenuAlign.Center,
			sndLightOn = "menu/menu/option-light-on_main4",
			textColor	= R3D.RGBA( 255, 255, 255, 255 ),
			fontBigSize = 26,
		},

		Multiplayer =
		{
			text = "Multiplayer",
			desc = TXT.MenuDesc.Multiplayer,
			x	 = 15,
			y	 = 550,
			action = "PainMenu:ActivateScreen(MultiplayerMenu)",
			sndLightOn = "menu/menu/option-light-on_main3",
--			disabled = 1,
		},

		Options =
		{
			text = TXT.Menu.Options,
			desc = TXT.MenuDesc.Options,
			x	 = 15,
			y	 = 630,
			action = "PainMenu:ActivateScreen(OptionsMenu)",
			sndLightOn = "menu/menu/option-light-on_main4",
		},
		
		callvote =
		{
			text = "-VoteMenu-",
			desc = "VoteMenu",
			x	 = 15,
			y	 = 100,
			action = "PainMenu:ActivateScreen(VoteMenu)",
			sndLightOn = "menu/menu/option-light-on_main4",
			fontBigSize = 24,
		},
		Quit =
		{
			text = TXT.Menu.Quit,
			desc = TXT.MenuDesc.Quit,
			x	 = 15,
			y	 = 710,
			action = "PainMenu:AskYesNo( Languages.Texts[469], 'Exit()', 'PainMenu:ActivateScreen(MainMenu)' )",
--			action = "PainMenu:AskYesNo( Languages.Texts[469], 'PainMenu:ActivateScreen(DemoEnd)', 'PainMenu:ActivateScreen(MainMenu)' )",
			sndLightOn = "menu/menu/option-light-on_main5",
		},
		
		BackButton =
		{
			text = TXT.Menu.Return,
			desc = TXT.MenuDesc.Return,
			textColor	= R3D.RGBA( 255, 255, 255, 255 ),
			x	 = 800,
			y	 = 50,
			fontBigSize = 36,
			inGameOnly = 1,
			action = "PMENU.ResumeSounds(); PMENU.ReturnToGame(); PainMenu:ReloadBrightskins()",
			useItemBG = false,
		},
		
		BackToMap =
		{
			text = TXT.Menu.ReturnToMap,
			desc = TXT.MenuDesc.ReturnToMap,
			textColor	= R3D.RGBA( 255, 255, 255, 255 ),
			x	 = 952,
			y	 = 660,
			fontBigSize = 36,
			align = MenuAlign.Right,
			inGameOnly = 1,
			action = "PainMenu:AskReturnToMap()",
			useItemBG = false,
		},
		
		Disconnect =
		{
			text = TXT.Menu.Disconnect,
			desc = TXT.MenuDesc.Disconnect,
			textColor = R3D.RGBA( 255, 255, 255, 255 ),
			x	 = 50,
			y	 = 50,
			fontBigSize = 36,
			inGameOnly = 1,
			action = "PainMenu:Disconnect()",
			useItemBG = false,
		},

--[[
		Quit =
		{
			text = TXT.Menu.Quit,
			desc = TXT.MenuDesc.Quit,
			textColor	= R3D.RGBA( 255, 255, 255, 255 ),
			x	 = 952,
			y	 = 660,
			fontBigSize = 36,
--			exitStart = 170,
--			exitEnd = 240,
			align = MenuAlign.Right,
--			action = "Exit()",
			action = "PainMenu:AskYesNo( Languages.Texts[469], 'Exit()', 'PainMenu:ActivateScreen(MainMenu)' )",
--			action = "PainMenu:AskYesNo( 'Are you sure you want to quit Painkiller?\\nPeople Can Fly', 'Exit()', 'PainMenu:ActivateScreen(MainMenu)' )",
			useItemBG = false,
			sndAccept   = "menu/menu/quit-accept",
			sndLightOn  = "menu/menu/quit-light-on",
		},

		Image =
		{
			type = MenuItemTypes.ImageButton,
			text = "",
			desc = "ImageButton test",
			image = "HUD/Map/karta_swiec",
			imageUnder = "HUD/Map/karta_wcisnieta",
			x	 = 10,
			y	 = 520,
			action = "",
		},

		Weapons =
		{
			text		= "Weapons",
			desc		= "Go to weapon configuration screen",
			action		= "PainMenu:ActivateScreen(WeaponsConfig)",
			x			= 492,
			y			= 660,
			fontBigSize = 36,
			align		= MenuAlign.Right,
			useItemBG	= false,
			textColor	= R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			sndAccept   = "menu/menu/apply-accept",
			sndLightOn  = "menu/menu/back-light-on",
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex= "../PKPlusData/font_texturka_alpha",
		},
]]--
	}
}