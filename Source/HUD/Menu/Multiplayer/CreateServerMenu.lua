CreateServerMenu =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	fontBigSize = 26,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

	backAction = "PainMenu:ApplySettings(); PainMenu:SaveMapsOnServer(); PainMenu:ActivateScreen(MultiplayerMenu)",

	items =
	{
		GeneralTab =
		{
			type = MenuItemTypes.TabGroup,
			x = 122,
			y = 70,
			width = 776,
			height = 300,
			visible = true,
			align = MenuAlign.Left,
			
			items = 
			{
				ServerName =
				{
					type = MenuItemTypes.TextEdit,
					text = TXT.Menu.ServerName..":",
					desc = TXT.MenuDesc.ServerName,
					option = "ServerName",
					x	 = -1,
					y	 = 160,
					action = "",
					maxLength = 20,
					align = MenuAlign.Left,
				},
				
				ServerPass =
				{
					type = MenuItemTypes.Password,
					text = TXT.Menu.ServerPassword..":",
					desc = TXT.MenuDesc.ServerPassword,
					option = "ServerPassword",
					x	 = -1,
					y	 = 200,
					action = "",
					maxLength = 10,
					align = MenuAlign.Left,
				},
				
				ServerPort =
				{
					type = MenuItemTypes.NumEdit,
					text = TXT.Menu.ServerPort..":",
					desc = TXT.MenuDesc.ServerPort,
					option = "ServerPort",
					x	 = -1,
					y	 = 240,
					action = "",
					maxLength = 4,
					align = MenuAlign.Left,
				},
				
				GameMode =
				{
					type = MenuItemTypes.TextButtonEx,
					text = TXT.Menu.Mode,
					desc = TXT.MenuDesc.Mode,
					option = "GameMode",
					values = { "Free For All", "Team Deathmatch", "Voosh", "The Light Bearer", "People Can Fly", "Capture The Flag", "Duel", "Last Man Standing"}, --  , "Clan Arena"
					visible = { TXT.Menu.FreeForAll, TXT.Menu.TeamDeathmatch, TXT.Menu.Voosh, TXT.Menu.TheLightBearer, TXT.Menu.PeopleCanFly, TXT.Menu.CaptureTheFlag, TXT.Menu.Duel, TXT.Menu.LastManStanding}, -- , "Clan Area"
					x	 = -1,
					y	 = 280,
					action = "",
					align = MenuAlign.Left,
				},

				MaxPlayers =
				{
					type = MenuItemTypes.NumRange,
					text = TXT.Menu.MaxPlayers,
					desc = TXT.MenuDesc.MaxPlayers,
					option = "MaxPlayers",
					x	 = 856,
					y	 = 160,
					action = "",
					minVal = 2,
					maxVal = 16,
					currValue = 8,
					align = MenuAlign.Right,
				},

				MaxSpectators =
				{
					type = MenuItemTypes.NumRange,
					text = TXT.Menu.MaxSpectators,
					desc = TXT.MenuDesc.MaxSpectators,
					option = "MaxSpectators",
					x	 = 856,
					y	 = 200,
					action = "",
					minVal = 0,
					maxVal = 8,
					currValue = 0,
					align = MenuAlign.Right,
				},

				FragLimit =
				{
					type = MenuItemTypes.NumEdit,
					text = TXT.Menu.FragLimit..":",
					desc = TXT.MenuDesc.FragLimit,
					option = "FragLimit",
					x	 = -1,
					y	 = 240,
					action = "",
					maxLength = 3,
					align = MenuAlign.Right,
				},
				
				TimeLimit =
				{
					type = MenuItemTypes.NumEdit,
					text = TXT.Menu.TimeLimit..":",
					desc = TXT.MenuDesc.TimeLimit,
					option = "TimeLimit",
					x	 = -1,
					y	 = 280,
					action = "",
					maxLength = 3,
					align = MenuAlign.Right,
				},

				Overtime =
				{
					type = MenuItemTypes.NumEdit,
					text = "Overtime"..":",
					desc = "Amount of overtime minutes, 0 = disabled",
					option = "overtime",
					x	 = -1,
					y	 = 320,
					action = "",
					maxLength = 3,
					align = MenuAlign.Right,
				},
				
				CaptureLimit =
				{
					type = MenuItemTypes.NumEdit,
					text = TXT.Menu.CaptureLimit..":",
					desc = TXT.MenuDesc.CaptureLimit,
					option = "CaptureLimit",
					x	 = -1,
					y	 = 320,
					action = "",
					maxLength = 3,
					align = MenuAlign.Right,
				},
				
				LMSLives =
				{
					type = MenuItemTypes.NumEdit,
					text = TXT.Menu.LMSLives..":",
					desc = TXT.MenuDesc.LMSLives,
					option = "LMSLives",
					x	 = -1,
					y	 = 320,
					action = "",
					maxLength = 3,
					align = MenuAlign.Right,
				},
				
				PublicServer =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.PublicServer,
					desc = TXT.MenuDesc.PublicServer,
					option = "PublicServer",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 306,
					action = "",
					align = MenuAlign.Left,
				},
			},
		},
		
		AdvancedTab =
		{
			type = MenuItemTypes.TabGroup,
			x = 122,
			y = 70,
			width = 776,
			height = 300,
			visible = false,
			align = MenuAlign.Right,

			items = 
			{
				TeamDamage =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.TeamDamage,
					desc = TXT.MenuDesc.TeamDamage,
					option = "TeamDamage",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 146,
					action = "",
					align = MenuAlign.Left,
--					disabled = 1,
				},
				
				WeaponsStay =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.WeaponsStay,
					desc = TXT.MenuDesc.WeaponsStay,
					option = "WeaponsStay",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 186,
					action = "",
					align = MenuAlign.Left,
				},
				
				Powerups =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.Powerups,
					desc = TXT.MenuDesc.Powerups,
					option = "Powerups",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 226,
					action = "",
					align = MenuAlign.Left,
--					disabled = 1,
				},
				
				PowerupDrop =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.PowerupDrop,
					desc = TXT.MenuDesc.PowerupDrop,
					option = "PowerupDrop",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 266,
					action = "",
					align = MenuAlign.Left,
--					disabled = 1,
				},
				
				WeaponRespawnTime =
				{
					type = MenuItemTypes.NumEdit,
					text = TXT.Menu.WeaponRespawnTime..":",
					desc = TXT.MenuDesc.WeaponRespawnTime,
					option = "WeaponRespawnTime",
					x	 = -1,
					y	 = 320,
					action = "",
					maxLength = 3,
					align = MenuAlign.Left,
				},
				
				AllowBunnyhopping =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.AllowBunnyhopping,
					desc = TXT.MenuDesc.AllowBunnyhopping,
					option = "AllowBunnyhopping",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 146,
					action = "",
					align = MenuAlign.Right,
--					disabled = 1,
				},
				
				AllowBrightskins =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.AllowBrightskins,
					desc = TXT.MenuDesc.AllowBrightskins,
					option = "AllowBrightskins",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 186,
					action = "",
					align = MenuAlign.Right,
--					disabled = 1,
				},
				
				AllowForwardRJ =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.AllowForwardRocketJump,
					desc = TXT.MenuDesc.AllowForwardRocketJump,
					option = "AllowForwardRJ",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 226,
					action = "",
					align = MenuAlign.Right,
--					disabled = 1,
				},
				
				ConsoleLock =
				{
					type = MenuItemTypes.Checkbox,
					text = TXT.Menu.ConsoleLock,
					desc = TXT.MenuDesc.ConsoleLock,
					option = "ClientConsoleLockdown",
					valueOn = true,
					valueOff = false,
					x	 = -1,
					y	 = 266,
					action = "",
					align = MenuAlign.Right,
--					disabled = 1,
				},
				
				ServerFPS =
				{
					type = MenuItemTypes.NumEdit,
					text = TXT.Menu.ServerFPS..":",
					desc = TXT.MenuDesc.ServerFPS,
					option = "ServerFPS",
					x	 = -1,
					y	 = 320,
					action = "",
					maxLength = 2,
					align = MenuAlign.Right,
				},
				
--[[
				BrightskinTeam =
				{
					type = MenuItemTypes.TextButtonEx,
					text = TXT.Menu.BrightskinTeam,
					desc = TXT.MenuDesc.BrightskinTeam,
					option = "BrightskinTeam",
					values = { "White", "Red" },
					visible = { TXT.Menu.White, TXT.Menu.RedBSkin },
					x	 = 856,
					y	 = 280,
					action = "",
					align = MenuAlign.Right,
--					disabled = 1,
				},
				
				BrightskinOthers =
				{
					type = MenuItemTypes.TextButtonEx,
					text = TXT.Menu.BrightskinEnemy,
					desc = TXT.MenuDesc.BrightskinEnemy,
					option = "BrightskinEnemy",
					values = { "White", "Red" },
					visible = { TXT.Menu.White, TXT.Menu.RedBSkin },
					x	 = 856,
					y	 = 320,
					action = "",
					align = MenuAlign.Right,
--					disabled = 1,
				},
]]--
			},
		},
		
		GeneralSettings =
		{
			text = TXT.Menu.General,
			desc = TXT.MenuDesc.General,
			x	 = 212,
			y	 = 96,
			align = MenuAlign.Center,
			action = "PainMenu:HideTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab')",
			sndAccept   = "menu/magicboard/card-take",
		},
		
		AdvancedSettings =
		{
			text = TXT.Menu.Advanced,
			desc = TXT.MenuDesc.Advanced,
			x	 = 392,
			y	 = 96,
			align = MenuAlign.Center,
			action = "PainMenu:HideTabGroup(PainMenu.currScreen.items.GeneralTab, 'GeneralTab'); PainMenu:ShowTabGroup(PainMenu.currScreen.items.AdvancedTab, 'AdvancedTab')",
			sndAccept   = "menu/magicboard/card-take",
		},

		MapSelect =
		{
			type = MenuItemTypes.MapTable,
			text = "",
			desc = "",
			x	 = 130,
			y	 = 420,
			action = "",
			disabledColor = R3D.RGB( 200, 200, 200 ),
--			fontBig = "arial",
			fontBigSize = 22,
			align = MenuAlign.Right,
			listMaxHeight = 180,
		},

		Start =
		{
			text = TXT.Menu.Start,
			desc = TXT.MenuDesc.Start,
			x	 = 952,
			y	 = 660,
			action = "PainMenu:SaveMapsOnServer(); PainMenu.lastScreen='server'; PainMenu:ApplySettings(); PainMenu:StartMultiplayerServer()",
			fontBigSize = 36,
			align = MenuAlign.Right,
			fontBigTex  = "../PKPlusData/font_texturka_alpha",
			fontSmallTex  = "../PKPlusData/font_texturka_alpha",
			textColor   = R3D.RGBA( 255, 255, 255, 255 ),
			descColor	= R3D.RGB( 255, 255, 255 ),
		},
		

	}
}
