YesNoAlert =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

--	fontBigTex  = "../PKPlusData/font_texturka_alpha",
--	fontSmallTex  = "../PKPlusData/font_texturka_alpha",
	descColor	= R3D.RGB( 255, 255, 255 ),

	items		=
	{
		DialogBorder = 
		{
			type = MenuItemTypes.Border,
			x = 200,
			y = 200,
			width = 624,
			height = 300,
		},

		YesButton =
		{
			text = TXT.Yes,
			desc = "",
			x	 = 360,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},

		NoButton =
		{
			text = TXT.No,
			desc = "",
			x	 = 600,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},
	}
}


InfoAlert =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	items		=
	{
		DialogBorder = 
		{
			type = MenuItemTypes.Border,
			x = 200,
			y = 200,
			width = 624,
			height = 300,
		},

		OKButton =
		{
			text = TXT.OK,
			desc = "",
			x	 = -1,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},
	}
}


Info2Alert =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	items		=
	{
		DialogBorder = 
		{
			type = MenuItemTypes.Border,
			x = 200,
			y = 200,
			width = 624,
			height = 300,
		},

		OKButton =
		{
			text = TXT.OK,
			desc = "",
			x	 = -1,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},
		
		ShowAgain =
		{
			type = MenuItemTypes.Checkbox,
			text = "",
			desc = "",
			option = "",
			valueOn = false,
			valueOff = true,
			x	 = 80,
			y	 = 650,
			action = "",
			fontBigSize = 22,
			align = MenuAlign.Left,
		}
	}
}


AskForPassword =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	items		=
	{
		DialogBorder = 
		{
			type = MenuItemTypes.Border,
			x = 200,
			y = 200,
			width = 624,
			height = 300,
		},

		Password =
		{
			type = MenuItemTypes.Password,
			text = TXT.Menu.Password..":",
			desc = TXT.MenuDesc.Password,
			option = "",
			x	 = 260,
			y	 = 360,
			action = "",
			maxLength = 10,
			fontBigSize = 36,
			align = MenuAlign.Left,
		},

		OKButton =
		{
			text = "OK",
			desc = "",
			x	 = 360,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Left,
			action = "",
		},
		
		BackButton =
		{
			text = TXT.Menu.Back,
			desc = "",
			x	 = 600,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},
	}
}


WarningAlert =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

--	fontBigTex  = "HUD/font_texturka_alpha",
--	fontSmallTex  = "HUD/font_texturka_alpha",
	descColor	= R3D.RGB( 255, 255, 255 ),

	items		=
	{
		DialogBorder = 
		{
			type = MenuItemTypes.Border,
			x = 200,
			y = 200,
			width = 624,
			height = 300,
		},

		YesButton =
		{
			text = TXT.Yes,
			desc = "",
			x	 = 360,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},

		NoButton =
		{
			text = TXT.No,
			desc = "",
			x	 = 600,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},
		
		ShowAgain =
		{
			type = MenuItemTypes.Checkbox,
			text = "",
			desc = "",
			option = "",
			valueOn = false,
			valueOff = true,
			x	 = 80,
			y	 = 650,
			action = "",
			fontBigSize = 22,
			align = MenuAlign.Left,
		}
	}
}

NoCDAlert =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	descColor	= R3D.RGB( 255, 255, 255 ),

	items		=
	{
		DialogBorder = 
		{
			type = MenuItemTypes.Border,
			x = 200,
			y = 200,
			width = 624,
			height = 300,
		},

		YesButton =
		{
			text = TXT.OK,
			desc = "",
			x	 = 360,
			y	 = 440,
			fontBigSize = 36,
			action = "",
		},

		NoButton =
		{
			text = TXT.Menu.Quit,
			desc = "",
			x	 = 600,
			y	 = 440,
			fontBigSize = 36,
--			align = MenuAlign.Right,
			action = "",
		},
	}
}
