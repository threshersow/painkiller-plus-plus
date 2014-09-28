WeaponsConfig =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	backAction = "PainMenu:ApplySettings(); PainMenu:SaveWeaponConfig(); PainMenu:ActivateScreen(OptionsMenu)",
	applyAction = "",

	menuWidth   = 880,
	fontBigSize = 20,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	items =
	{
		FireBorder =
		{
			type = MenuItemTypes.Border,
			x = 50,
			y = 110,
			width = 924,
			height = 220,
			header = 40,
		},

		PrimaryFire =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Primary,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 128,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		SecondaryFire =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Secondary,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 128,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Weapon1 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Weapon1,
			desc		= "",
			action		= "",
			x			= 70,
			y			= 168,
			useItemBG	= false,
		},
		
		Primary1 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Pain,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 168,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Secondary1 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Killer,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 168,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Switch1 =
		{
			text		= TXT.Menu.Switch,
			desc		= "",
			action		= "PainMenu:SwitchFire(1)",
			x			= 855,
			y			= 168,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Weapon2 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Weapon2,
			desc		= "",
			action		= "",
			x			= 70,
			y			= 188,
			useItemBG	= false,
		},
		
		Primary2 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Shotgun,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 188,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Secondary2 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Freezer,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 188,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Switch2 =
		{
			text		= TXT.Menu.Switch,
			desc		= "",
			action		= "PainMenu:SwitchFire(2)",
			x			= 855,
			y			= 188,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Weapon3 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Weapon3,
			desc		= "",
			action		= "",
			x			= 70,
			y			= 208,
			useItemBG	= false,
		},
		
		Primary3 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Stakegun,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 208,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Secondary3 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.GranadeLauncher,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 208,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},

		Switch3 =
		{
			text		= TXT.Menu.Switch,
			desc		= "",
			action		= "PainMenu:SwitchFire(3)",
			x			= 855,
			y			= 208,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Weapon4 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Weapon4,
			desc		= "",
			action		= "",
			x			= 70,
			y			= 228,
			useItemBG	= false,
		},
		
		Primary4 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.RocketLauncher,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 228,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Secondary4 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Minigun,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 228,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},

		Switch4 =
		{
			text		= TXT.Menu.Switch,
			desc		= "",
			action		= "PainMenu:SwitchFire(4)",
			x			= 855,
			y			= 228,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Weapon5 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Weapon5,
			desc		= "",
			action		= "",
			x			= 70,
			y			= 248,
			useItemBG	= false,
		},
		
		Primary5 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Shurikens,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 248,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Secondary5 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Electro,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 248,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},

		Switch5 =
		{
			text		= TXT.Menu.Switch,
			desc		= "",
			action		= "PainMenu:SwitchFire(5)",
			x			= 855,
			y			= 248,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Weapon6 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Weapon6,
			desc		= "",
			action		= "",
			x			= 70,
			y			= 268,
			useItemBG	= false,
		},
		
		Primary6 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Rifle,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 268,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Secondary6 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.FlameThrower,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 268,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},

		Switch6 =
		{
			text		= TXT.Menu.Switch,
			desc		= "",
			action		= "PainMenu:SwitchFire(6)",
			x			= 855,
			y			= 268,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Weapon7 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Menu.Weapon7,
			desc		= "",
			action		= "",
			x			= 70,
			y			= 288,
			useItemBG	= false,
		},
		
		Primary7 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.BoltGun,
			desc		= "",
			action		= "",
			x			= 420,
			y			= 288,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},
		
		Secondary7 =
		{
			type		= MenuItemTypes.StaticText,
			text		= TXT.Weapons.Heater,
			desc		= "",
			action		= "",
			x			= 670,
			y			= 288,
			align		= MenuAlign.Center,
			useItemBG	= false,
		},

		Switch7 =
		{
			text		= TXT.Menu.Switch,
			desc		= "",
			action		= "PainMenu:SwitchFire(7)",
			x			= 855,
			y			= 288,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
	
		AutoChangeWeapon =
		{
			type = MenuItemTypes.Checkbox,
			text = "",
			desc = TXT.MenuDesc.AutoChangeWeapon,
			option = "AutoChangeWeapon",
			valueOn = true,
			valueOff = false,
			x	 = 306,
			y	 = 323,
			action = "",
			align = MenuAlign.Right,
			fontBigSize = 16,
		},
		
		PickupOrder =
		{
			type = MenuItemTypes.WeaponList,
			text = TXT.Menu.Pickup,
			desc = "",
			x	 = 70,
			y	 = 345,
			action = "",
			width = 308,
			listMaxHeight = 220,
			useHeader = true,
			elems =
			{
				TXT.Menu.Pickup,
			},
		},
		
		PickupBorder =
		{
			type = MenuItemTypes.Border,
			x = 50,
			y = 580,
			width = 312,
			height = 56,
		},

		PickupUp =
		{
			text		= TXT.Menu.Up,
			desc		= "",
			action		= "PMENU.MoveListItemUp('PickupOrder')",
			x			= 80,
			y			= 600,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		PickupDown =
		{
			text		= TXT.Menu.Down,
			desc		= "",
			action		= "PMENU.MoveListItemDown('PickupOrder')",
			x			= 330,
			y			= 600,
			align		= MenuAlign.Right,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},

		Custom1Order =
		{
			type = MenuItemTypes.WeaponList,
			text = TXT.Menu.Custom1,
			desc = "",
			x	 = 372,
			y	 = 345,
			action = "",
			width = 320,
			listMaxHeight = 220,
			useHeader = true,
			elems =
			{
				TXT.Menu.Custom1,
			},
		},

		Custom1Border =
		{
			type = MenuItemTypes.Border,
			x = 353,
			y = 580,
			width = 320,
			height = 56,
		},
		
		Custom1Up =
		{
			text		= TXT.Menu.Up,
			desc		= "",
			action		= "PMENU.MoveListItemUp('Custom1Order')",
			x			= 380,
			y			= 600,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Custom1Down =
		{
			text		= TXT.Menu.Down,
			desc		= "",
			action		= "PMENU.MoveListItemDown('Custom1Order')",
			x			= 640,
			y			= 600,
			align		= MenuAlign.Right,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Custom2Order =
		{
			type = MenuItemTypes.WeaponList,
			text = TXT.Menu.Custom2,
			desc = "",
			x	 = 685,
			y	 = 345,
			action = "",
			width = 308,
			listMaxHeight = 220,
			useHeader = true,
			elems =
			{
				TXT.Menu.Custom2,
			},
		},
		
		Custom2Border =
		{
			type = MenuItemTypes.Border,
			x = 665,
			y = 580,
			width = 308,
			height = 56,
		},
		
		Custom2Up =
		{
			text		= TXT.Menu.Up,
			desc		= "",
			action		= "PMENU.MoveListItemUp('Custom2Order')",
			x			= 695,
			y			= 600,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},
		
		Custom2Down =
		{
			text		= TXT.Menu.Down,
			desc		= "",
			action		= "PMENU.MoveListItemDown('Custom2Order')",
			x			= 945,
			y			= 600,
			align		= MenuAlign.Right,
			useItemBG	= false,
			sndAccept   = "menu/magicboard/card-take",
		},

		WeaponsBorder =
		{
			type = MenuItemTypes.Border,
			x = 50,
			y = 110,
			width = 924,
			height = 526,
		},

		WeaponsSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 404,
			y = 60,
			width = 180,
			height = 60,
			dark = true,
		},
		
		GeneralSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 50,
			y = 68,
			width = 190,
			height = 52,
		},
		
		AdvancedSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 234,
			y = 68,
			width = 176,
			height = 52,
		},
		
		MessagesSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 576,
			y = 68,
			width = 180,
			height = 52,
		},
		
		GeneralSettings =
		{
			text = TXT.Menu.General,
			desc = TXT.MenuDesc.General,
			x	 = 140,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PainMenu:ApplySettings(); PainMenu:SaveWeaponConfig(); PainMenu:ActivateScreen(ControlsConfig); PMENU.SetBorderSize( 'KeyBorder', 924, 410 ); PMENU.SetScrollerHeight('KeyScroller',440); PainMenu:HideTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab')",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		AdvancedSettings =
		{
			text = TXT.Menu.Advanced,
			desc = TXT.MenuDesc.Advanced,
			x	 = 320,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PainMenu:ApplySettings(); PainMenu:SaveWeaponConfig(); PainMenu:ActivateScreen(ControlsConfig); PMENU.SetBorderSize( 'KeyBorder', 924, 524 ); PMENU.SetScrollerHeight('KeyScroller',546); PainMenu:HideTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab')",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		WeaponsSettings =
		{
			text = TXT.Menu.Weapons,
			desc = TXT.MenuDesc.WeaponsConfig,
			x	 = 490,
			y	 = 78,
			align = MenuAlign.Center,
			action = "",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		MessagesSettings =
		{
			text = TXT.Menu.Messages,
			desc = TXT.MenuDesc.Messages,
			x	 = 666,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PainMenu:ApplySettings(); PainMenu:SaveWeaponConfig(); PainMenu:ActivateScreen(MessagesConfig)",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
	},
}
