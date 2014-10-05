ControlsConfig =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

--	backAction = "PainMenu:ActivateScreen(OptionsMenu)",
	backAction = "PainMenu:ApplySettings(); PainMenu:ApplyControlSettings(); PainMenu:ActivateScreen(OptionsMenu)",
	applyAction = "PainMenu:ApplySettings(); PainMenu:ApplyControlSettings(); PainMenu:ActivateScreen(OptionsMenu)",

	menuWidth   = 880,
	fontBigSize = 26,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	items =
	{
		GeneralTab =
		{
			type = MenuItemTypes.TabGroup,
			x = 50,
			y = 60,
			width = 924,
			height = 576,
			visible = true,
			align = MenuAlign.Left,
			
			items =
			{
				Keys1 =
				{
					text = "",
					desc = TXT.MenuDesc.Keys,
					type = MenuItemTypes.ControlCfg,
					fontBigSize	= 26,
					disabledColor = R3D.RGB( 200, 200, 200 ),
					align = MenuAlign.Left,
					maxVisible = 12,
					keys =
					{
						{ TXT.Menu.MoveForward, "KeyPrimaryMoveForward", "KeyAlternativeMoveForward" },
						{ TXT.Menu.MoveBackward, "KeyPrimaryMoveBackward", "KeyAlternativeMoveBackward" },
						{ TXT.Menu.StrafeLeft, "KeyPrimaryStrafeLeft", "KeyAlternativeStrafeLeft" },
						{ TXT.Menu.StrafeRight, "KeyPrimaryStrafeRight", "KeyAlternativeStrafeRight" },
						{ TXT.Menu.Jump, "KeyPrimaryJump", "KeyAlternativeJump" },
						{ TXT.Menu.Fire, "KeyPrimaryFire", "KeyAlternativeFire" },
						{ TXT.Menu.Zoom, "KeyPrimaryZoom", "KeyAlternativeZoom" },
						{ TXT.Menu.AlternativeFire, "KeyPrimaryAlternativeFire", "KeyAlternativeAlternativeFire" },
		--				{ TXT.Menu.BulletTime, "KeyPrimaryBulletTime", "KeyAlternativeBulletTime" },
						{ TXT.Menu.UseCards, "KeyPrimaryUseCards", "KeyAlternativeUseCards" },
						{ TXT.Menu.Scoreboard, "KeyPrimaryScoreboard", "KeyAlternativeScoreboard" },
						{ TXT.Menu.NextWeapon, "KeyPrimaryNextWeapon", "KeyAlternativeNextWeapon" },
						{ TXT.Menu.PreviousWeapon, "KeyPrimaryPreviousWeapon", "KeyAlternativePreviousWeapon" },
						{ TXT.Menu.QuickLoad, "KeyPrimaryQuickLoad", "KeyAlternativeQuickLoad" },
						{ TXT.Menu.QuickSave, "KeyPrimaryQuickSave", "KeyAlternativeQuickSave" },
					},
					action = "",
				},

				InvertMouse =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.InvertMouse,
					desc = TXT.MenuDesc.InvertMouse,
					option = "InvertMouse",
					valueOn = true,
					valueOff = false,
					x	 = 80,
					y	 = 530,
					align = MenuAlign.Left,
					action = "",
				},
				
				SmoothMouse =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.SmoothMouse,
					desc = TXT.MenuDesc.SmoothMouse,
					option = "SmoothMouse",
					valueOn = true,
					valueOff = false,
					x	 = 80,
					y	 = 580,
					align = MenuAlign.Left,
					action = "",
		--			disabled = 1,
				},

				MouseSensitivity =
				{
					type = MenuItemTypes.Slider,
					text = TXT.Menu.MouseSensitivity,
					desc = TXT.MenuDesc.MouseSensitivity,
					option = "MouseSensitivity",
					minValue = 1,
					maxValue = 100,
					isFloat = true,
					x	 = 380,
					y	 = 544,
					action = "",
					sliderWidth = 280,
					sliderCtrlWidth = 560,
					align = MenuAlign.Right,
				},
				
				WheelSensitivity =
				{
					type = MenuItemTypes.Slider,
					text = TXT.Menu.WheelSensitivity,
					desc = TXT.MenuDesc.WheelSensitivity,
					option = "WheelSensitivity",
					minValue = 0,
					maxValue = 4,
					isFloat = false,
					x	 = 380,
					y	 = 594,
					action = "PainMenu:UpdateWheelSensitivity()",
					sliderWidth = 280,
					sliderCtrlWidth = 560,
					align = MenuAlign.Right,
				},
			},
		},
		
		AdvancedTab =
		{
			type = MenuItemTypes.TabGroup,
			x = 50,
			y = 60,
			width = 924,
			height = 576,
			visible = false,
			align = MenuAlign.Right,
			
			items =
			{
				Keys2 =
				{
					text = "",
					desc = TXT.MenuDesc.Keys,
					type = MenuItemTypes.ControlCfg,
					fontBigSize	= 26,
					disabledColor = R3D.RGB( 200, 200, 200 ),
					align = MenuAlign.Left,
					maxVisible = 12,
					keys =
					{
						{ TXT.Menu.Weapon1, "KeyPrimaryWeapon1", "KeyAlternativeWeapon1" },
						{ TXT.Menu.Weapon2, "KeyPrimaryWeapon2", "KeyAlternativeWeapon2" },
						{ TXT.Menu.Weapon3, "KeyPrimaryWeapon3", "KeyAlternativeWeapon3" },
						{ TXT.Menu.Weapon4, "KeyPrimaryWeapon4", "KeyAlternativeWeapon4" },
						{ TXT.Menu.Weapon5, "KeyPrimaryWeapon5", "KeyAlternativeWeapon5" },
						{ TXT.Menu.Weapon6, "KeyPrimaryWeapon6", "KeyAlternativeWeapon6" },
						{ TXT.Menu.Weapon7, "KeyPrimaryWeapon7", "KeyAlternativeWeapon7" },
						{ TXT.Menu.Weapon8, "KeyPrimaryWeapon8", "KeyAlternativeWeapon8" },
						{ TXT.Menu.Weapon9, "KeyPrimaryWeapon9", "KeyAlternativeWeapon9" },
						{ TXT.Menu.Weapon10, "KeyPrimaryWeapon10", "KeyAlternativeWeapon10" },
						{ TXT.Menu.Weapon11, "KeyPrimaryWeapon11", "KeyAlternativeWeapon11" },
						{ TXT.Menu.Weapon12, "KeyPrimaryWeapon12", "KeyAlternativeWeapon12" },
						{ TXT.Menu.Weapon13, "KeyPrimaryWeapon13", "KeyAlternativeWeapon13" },
						{ TXT.Menu.Weapon14, "KeyPrimaryWeapon14", "KeyAlternativeWeapon14" },
						{ TXT.Menu.Flashlight, "KeyPrimaryFlashlight", "KeyAlternativeFlashlight" },
						{ TXT.Menu.Pause, "KeyPrimaryPause", "KeyAlternativePause" },
						{ TXT.Menu.Screenshot, "KeyPrimaryScreenshot", "KeyAlternativeScreenshot" },
		--				{ TXT.Menu.Menu, "KeyPrimaryMenu", "KeyAlternativeMenu" },
						{ TXT.Menu.SayToAll, "KeyPrimarySayToAll", "KeyAlternativeSayToAll" },
						{ TXT.Menu.SayToTeam, "KeyPrimarySayToTeam", "KeyAlternativeSayToTeam" },
						{ TXT.Menu.RocketJump, "KeyPrimaryRocketJump", "KeyAlternativeRocketJump" },
						{ TXT.Menu.ForwardRocketJump, "KeyPrimaryForwardRocketJump", "KeyAlternativeForwardRocketJump" },
						{ TXT.Menu.FireSwitch, "KeyPrimaryFireSwitch", "KeyAlternativeFireSwitch" },
						{ TXT.Menu.FireSwitchToggle, "KeyPrimaryFireSwitchToggle", "KeyAlternativeFireSwitchToggle" },
						{ TXT.Menu.SelectBestCustom1, "KeyPrimarySelectBestWeapon1", "KeyAlternativeSelectBestWeapon1" },
						{ TXT.Menu.SelectBestCustom2, "KeyPrimarySelectBestWeapon2", "KeyAlternativeSelectBestWeapon2" },
						{ TXT.Menu.FireBestCustom1, "KeyPrimaryFireBestWeapon1", "KeyAlternativeFireBestWeapon1" },
						{ TXT.Menu.FireBestCustom2, "KeyPrimaryFireBestWeapon2", "KeyAlternativeFireBestWeapon2" },
					},
					action = "",
				},
			},
		},
				
		GeneralSettings =
		{
			text = TXT.Menu.General,
			desc = TXT.MenuDesc.General,
			x	 = 140,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PMENU.SetBorderSize( 'KeyBorder', 924, 410 ); PMENU.SetScrollerHeight('KeyScroller',440); PainMenu:HideTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab')",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
		
		AdvancedSettings =
		{
			text = TXT.Menu.Advanced,
			desc = TXT.MenuDesc.Advanced,
			x	 = 320,
			y	 = 78,
			align = MenuAlign.Center,
			action = "PMENU.SetBorderSize( 'KeyBorder', 924, 524 ); PMENU.SetScrollerHeight('KeyScroller',546); PainMenu:HideTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab')",
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
			action = "PainMenu:ApplySettings(); PainMenu:ApplyControlSettings(); PainMenu:ActivateScreen(MessagesConfig)",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},

		WeaponsSettingsBorder =
		{
			type = MenuItemTypes.Border,
			x = 404,
			y = 68,
			width = 180,
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

		EmptyBorder =
		{
			type = MenuItemTypes.Border,
			x = 50,
			y = 110,
			width = 924,
			height = 526,
		},

		WeaponsSettings =
		{
			text = TXT.Menu.Weapons,
			desc = TXT.MenuDesc.WeaponsConfig,
			x	 = 490,
			y	 = 86,
			align = MenuAlign.Center,
			action = "PainMenu:ApplySettings(); PainMenu:ApplyControlSettings(); PainMenu:ActivateScreen(WeaponsConfig)",
			sndAccept   = "menu/magicboard/card-take",
			fontBigSize = 26,
		},
	},
}
