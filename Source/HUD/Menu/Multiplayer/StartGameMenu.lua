StartGameMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	firstTimeShowItems = 80,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	backAction = "PainMenu:ActivateScreen(MultiplayerMenu)",
	
	textColor	= R3D.RGBA( 255, 255, 255, 255 ),
	disabledColor = R3D.RGBA( 155, 155, 155, 255 ),
	
	useItemBG = true,

	items =
	{
		FreeForAll =
		{
			text = "Free For All",
			desc = "Fragfest for everyone",
			x	 = -1,
			y	 = 210,
			action = "PainMenu:ActivateScreen(CreateServerMenu)",
		},

		TeamDeathmatch =
		{
			text = "Team Deathmatch",
			desc = "Two teams compete against each other",
			x	 = -1,
			y	 = 290,
			action = "PainMenu:ActivateScreen(CreateServerMenu)",
		},

		Voosh =
		{
			text = "Voosh",
			desc = "Same weapons and powerups for everyone",
			x	 = -1,
			y	 = 370,
			action = "PainMenu:ActivateScreen(CreateServerMenu)",
		},
		
		TheLightBearer =
		{
			text = "The Light Bearer",
			desc = "Quad damage never dies",
			x	 = -1,
			y	 = 450,
			action = "PainMenu:ActivateScreen(CreateServerMenu)",
		},
		
		PeopleCanFly =
		{
			text = "People Can Fly",
			desc = "Blow your opponent sky high and finish him midair",
			x	 = -1,
			y	 = 530,
			action = "PainMenu:ActivateScreen(CreateServerMenu)",
		},
		
		ClanArena =
		{
			text = "Clan Arena",
			desc = "Prove your worth",
			x	 = -1,
			y	 = 530,
			action = "PainMenu:ActivateScreen(CreateServerMenu)",
		},
	}
}
