DeleteGameMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	backAction = "PainMenu:ActivateScreen(LoadSaveMenu)",

	items		=
	{
		SaveList =
		{
			text = "SaveList",
			desc = "",
			x = 130,
			y = 180,
			fontBigSize = 22,
			action = "",
			disabledColor = R3D.RGB( 200, 200, 200 ),
			fullWidth = 1,
			type = MenuItemTypes.LoadSave,
		},

		DeleteButton =
		{
			text = "Delete",
			desc = "",
			x	 = 952,
			y	 = 660,
			fontBigSize = 36,
			align = MenuAlign.Right,
			action = "PainMenu:AskYesNo('Are you sure?','PainMenu:ActivateScreen(DeleteGameMenu)','PainMenu:ActivateScreen(DeleteGameMenu)')",
			useItemBG = false,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
		},
	}
}
