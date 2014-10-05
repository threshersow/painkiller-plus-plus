Pkgui =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	fontBigSize = 32,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	backAction = "PainMenu:ApplySettings(false); PainMenu:ActivateScreen(OptionsMenu)",
	applyAction = "PainMenu:ApplySettings(true); WORLD.SetMaxFPS(Cfg.MaxFpsMP); PainMenu:ReloadFOV(); PainMenu:ApplyVideoSettings(); PainMenu:ReloadBrightskins(); Hud.CrossScale = Cfg.CrosshairSize; PMENU.SetItemVisibility('ApplyButton',false)",
	items =
	{

		GeneralTab =
		{
			type = MenuItemTypes.TabGroup,
			x = 122,
			y = 70,
			width = 750,
			height = 450,
			visible = true,
			align = MenuAlign.Left,
			
			items =
			{


		ColoredIcons =
		{
			type = MenuItemTypes.Checkbox,
			text = "ColoredIcons",
			desc = "Changes your icons",
			option = "ColouredIcons",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 150,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,
		},


		ShowFPS =
		{
			type = MenuItemTypes.Checkbox,
			text = "FPS",
			desc = "Shows your current fps",
			option = "FPS",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 200,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,
		},
		
		ShowFragmsg=
		{
			type = MenuItemTypes.Checkbox,
			text = "Shows FragMessages",
			desc = "Extra fragmessage when killing your opponent",
			option = "HUD_FragMessage",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 250,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,

		},

		ShowCurrentweapon =
		{
			type = MenuItemTypes.Checkbox,
			text = "Weapon Icon",
			desc = "Shows the current weapon you have equiped",
			option = "HUD_CurrentWeapon_Icon",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 300,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,

		},

		Simplehud =
		{
			type = MenuItemTypes.Checkbox,
			text = "Simplehud",
			desc = "Simple hud graphics",
			option = "Simplehud",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 350,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,

		},



		ShowTimer =
		{
			type = MenuItemTypes.Checkbox,
			text = "Timer",
			desc = "Shows the timer on the hud",
			option = "ShowTimer",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 400,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,
		},


	
		
		Ammolistpos =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "AmmolistPos",
			desc = "Place your ammolist to the left, right or disable it",
			option = "HUD_AmmoList",
			values = { 1, 2, 0},
			visible = { "Left", "Right", "Off"},
			x	 = -1,
			y	 = 150,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},



		Timerpos =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "TimerPos",
			desc = "Place your timer to left, right or to the center of the screen",
			option = "ShowTimerX",
			values = { 0.009766, -1, 0.8789},
			visible = { "Left", "Center", "Right"},
			x	 = -1,
			y	 = 200,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,

		},

		Crosshairsize =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "Crosshairsize",
			desc = "Changes the size of your crosshair",
			option = "CrosshairSize",
			values = { 0.5, 1, 1.5, 2 },
			visible = { "Small", "Normal", "Big", "Biggest" },
			x	 = -1,
			y	 = 250,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},

		Shadows =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "ShowTimerShadow",
			desc = "Choose the shadow for showtimer font",
			option = "ShowTimerShadow",
			values = { true, false},
			visible = { "On", "Off" },
			x	 = -1,
			y	 = 300,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},
		
		Shadows2 =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "ShowFPSShadow",
			desc = "Choose the shadow for showfps font",
			option = "ShowFPSShadow",
			values = { true, false},
			visible = { "On", "Off" },
			x	 = -1,
			y	 = 350,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},
		
						Shadows4 =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "TeamScoresShadow",
			desc = "Choose the shadow for teamscores font",
			option = "TeamScoresShadow",
			values = { true, false},
			visible = { "On", "Off" },
			x	 = -1,
			y	 = 400,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},
								Shadows5 =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "SimplehudShadow",
			desc = "Choose the shadow for simplehud font",
			option = "SimplehudShadow",
			values = { true, false},
			visible = { "On", "Off" },
			x	 = -1,
			y	 = 450,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},
		
		
},
},

		AdvancedTab =
		{
			type = MenuItemTypes.TabGroup,
			x = 122,
			y = 70,
			width = 750,
			height = 450,
			visible = false,
			align = MenuAlign.Right,

			items = 
			{



		BrightskinEnemy =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "Enemy Color",
			desc = "Color of your enemy",
			option = "BrightskinEnemy",
			values = { "White", "Green", "Blue", "Red", "Cyan", "Magenta", "Yellow", "Pink", "Orange"},
			visible = { "White", "Green", "Blue", "Red", "Cyan", "Magenta", "Yellow", "Pink", "Orange"},
			x	 = -1,
			y	 = 275,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},
		BrightskinTeam =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "Team Color",
			desc = "Color of your team",
			option = "BrightskinTeam",
			values = { "White", "Green", "Blue", "Red", "Cyan", "Magenta", "Yellow", "Pink", "Orange"},
			visible = { "White", "Green", "Blue", "Red", "Cyan", "Magenta", "Yellow", "Pink", "Orange"},
			x	 = -1,
			y	 = 325,
			action = "",
			align = MenuAlign.Left,
			applyRequired = true,
		},

		SetCameraFOV =
				{
					type = MenuItemTypes.Slider,
					text = "FOV",
					desc = "Changes your ingame FOV",
					option = "FOV",
					minValue = 60,
					maxValue = 110,
					x	 = 150,
					y	 = 150,
					action = "",
					applyRequired = true,
                		},

		SetMaxFps =
				{
					type = MenuItemTypes.Slider,
					text = "MaxFps",
					desc = "Set your MaxFps",
					option = "MaxFpsMP",
					minValue = 60,
					maxValue = 150,
					x	 = 150,
					y	 = 200,
					action = "",
					applyRequired = true,
				},

		Hitsounds2 =
		{
			type = MenuItemTypes.Checkbox,
			text = "        HitSounds",
			desc = "Apply for hitsounds on/off",
			option = "HitSounds",
			valueOn = true,
			valueOff = false,
			x	 = 193,
			y	 = 350,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Right,
		},

		Hitsounds =
		{
			type = MenuItemTypes.Checkbox,
			text = "NewHitsounds",
			desc = "Apply for newstyle hitsounds",
			option = "Newhitsound",
			valueOn = true,
			valueOff = false,
			x	 = 200,
			y	 = 400,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Right,
		},

		Timercountup =
		{
			type = MenuItemTypes.Checkbox,
			text = "CountUp",
			desc = "Makes your timer count up",
			option = "ShowTimerCountUp",
			valueOn = true,
			valueOff = false,
			x	 = 270,
			y	 = 450,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Right,
		},


		Autorecord =
		{
			type = MenuItemTypes.Checkbox,
			text = "Autorecord",
			desc = "Autorecording of demos",
			option = "Autorecord",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 350,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,
		},
		Scoreboard2 =
		{
			type = MenuItemTypes.Checkbox,
			text = "AltScoreboard (restart)",
			desc = "Shows the alternative scoreboard.",
			option = "AltScoreboard",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 400,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,
		},
		Scoreboard =
		{
			type = MenuItemTypes.Checkbox,
			text = "OldScoreboard (restart)",
			desc = "Shows the old crappy pcf scoreboard.",
			option = "OldScoreboard",
			valueOn = true,
			valueOff = false,
			x	 = 500,
			y	 = 450,
			action = "",
			fontBigSize = 30,
			applyRequired = true,
			align = MenuAlign.Left,
		},

		},
		},
		GeneralSettings =
		{
			text = "HUD",
			desc = TXT.MenuDesc.General,
			x	 = 212,
			y	 = 96,
			align = MenuAlign.Center,
			action = "PainMenu:HideTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab')",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		AdvancedSettings =
		{
			text = "Misc",
			desc = TXT.MenuDesc.Advanced,
			x	 = 392,
			y	 = 96,
			align = MenuAlign.Center,
			action = "PainMenu:HideTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab')",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
	}
}
