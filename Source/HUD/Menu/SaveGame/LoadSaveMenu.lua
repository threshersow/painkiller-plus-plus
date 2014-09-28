LoadSaveMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	backAction = "PainMenu:ActivateScreen(MainMenu)",
	
	menuWidth   = 880,

	items		=
	{
		SortLevelButton =
		{
			text = TXT.Menu.Level,
			desc = "",
			x	 = 280,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','level')",
		},

		SortTimeButton =
		{
			text = TXT.SPStats.Playtime,
			desc = "",
			x	 = 544,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','time')",
		},

		SortDateButton =
		{
			text = TXT.Menu.SaveTime,
			desc = "",
			x	 = 710,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','date')",
		},
		
		SortDiffButton =
		{
			text = TXT.SPStats.Difficulty,
			desc = "",
			x	 = 870,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','diff')",
		},

		SaveList =
		{
			text = "SaveList",
			desc = "",
			x = 100,
			y = 180,
			fontBigSize = 18,
			action = "",
			disabledColor = R3D.RGB( 200, 200, 200 ),
			fullWidth = 1,
			type = MenuItemTypes.LoadSave,
		},
		
		DeleteButton =
		{
			text = TXT.Menu.Delete,
			desc = "",
			x	 = -1,
			y	 = 660,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "PainMenu:DeleteSaveGame()",
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},

		SaveButton =
		{
			text = TXT.Menu.Save,
			desc = "",
			x	 = 832,
			y	 = 660,
			fontBigSize = 36,
			align = MenuAlign.Right,
			action = "PainMenu:SaveGame()",
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},

		LoadButton =
		{
			text = TXT.Menu.Load,
			desc = "",
			x	 = 952,
			y	 = 660,
			fontBigSize = 36,
			align = MenuAlign.Right,
			action = "SaveGame:Load(PMENU.GetSelectedSGSlot())",
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},
			
		AutoSavesBorder =
		{
			type = MenuItemTypes.Border,
			x = 264,
			y = 114,
			width = 176,
			height = 52,
		},
		
		CustomSavesBorder =
		{
			type = MenuItemTypes.Border,
			x = 80,
			y = 106,
			width = 190,
			height = 60,
		},
		
		CustomSaves =
		{
			text = TXT.Menu.Saves,
			desc = "",
			x	 = 170,
			y	 = 124,
			align = MenuAlign.Center,
			action = "",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		AutoSaves =
		{
			text = TXT.Menu.AutoSaves,
			desc = "",
			x	 = 350,
			y	 = 132,
			align = MenuAlign.Center,
			action = "PainMenu:ActivateScreen(AutoLoadSaveMenu)",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
	}
}


AutoLoadSaveMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	backAction = "PainMenu:ActivateScreen(MainMenu)",
	
	menuWidth   = 880,

	items		=
	{
		SortLevelButton =
		{
			text = TXT.Menu.Level,
			desc = "",
			x	 = 280,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','level')",
		},

		SortTimeButton =
		{
			text = TXT.SPStats.Playtime,
			desc = "",
			x	 = 544,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','time')",
		},

		SortDateButton =
		{
			text = TXT.Menu.SaveTime,
			desc = "",
			x	 = 710,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','date')",
		},
		
		SortDiffButton =
		{
			text = TXT.SPStats.Difficulty,
			desc = "",
			x	 = 870,
			y	 = 180,
			fontBigSize = 18,
			align = MenuAlign.Center,
			action = "PainMenu:ReloadSaveGameList('SaveList','diff')",
		},

		SaveList =
		{
			text = "SaveList",
			desc = "",
			x = 100,
			y = 180,
			fontBigSize = 18,
			action = "",
			disabledColor = R3D.RGB( 200, 200, 200 ),
			fullWidth = 1,
			type = MenuItemTypes.LoadSave,
		},

		DeleteButton =
		{
			text = TXT.Menu.Delete,
			desc = "",
			x	 = -1,
			y	 = 660,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "PainMenu:DeleteAutoSaveGame()",
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},

		SaveButton =
		{
			text = TXT.Menu.Save,
			desc = "",
			x	 = 832,
			y	 = 660,
			fontBigSize = 36,
			align = MenuAlign.Right,
			action = "PainMenu:SaveGame()",
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},

		LoadButton =
		{
			text = TXT.Menu.Load,
			desc = "",
			x	 = 952,
			y	 = 660,
			fontBigSize = 36,
			align = MenuAlign.Right,
			action = "SaveGame:Load(PMENU.GetSelectedSGSlot())",
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
			disabled = 1,
		},
		
		AutoSavesBorder =
		{
			type = MenuItemTypes.Border,
			x = 264,
			y = 106,
			width = 176,
			height = 60,
		},
		
		CustomSavesBorder =
		{
			type = MenuItemTypes.Border,
			x = 80,
			y = 114,
			width = 190,
			height = 52,
		},
				
		CustomSaves =
		{
			text = TXT.Menu.Saves,
			desc = "",
			x	 = 170,
			y	 = 132,
			align = MenuAlign.Center,
			action = "PainMenu:ActivateScreen(LoadSaveMenu)",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		AutoSaves =
		{
			text = TXT.Menu.AutoSaves,
			desc = "",
			x	 = 350,
			y	 = 124,
			align = MenuAlign.Center,
			action = "PainMenu:ActivateScreen(AutoLoadSaveMenu)",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
	}
}
