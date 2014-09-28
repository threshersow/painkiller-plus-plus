AdvancedVideoOptions =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	fontBigSize = 32,

	backAction = "PainMenu:ApplySettings(); HUD.SetTransparency(Cfg.HUDTransparency); PainMenu:ActivateScreen(OptionsMenu)",
	applyAction = "PainMenu:ApplySettings(true); PainMenu:ReloadWeaponsTextures(); PainMenu:SetShadowsQuality(); PainMenu:ApplyVideoSettings()",

	items =
	{
		VideoBorder =
		{
			type = MenuItemTypes.Border,
			x = 124,
			y = 140,
			width = 784,
			height = 440,
		},

		Shadows =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.Shadows,
			desc = TXT.MenuDesc.Shadows,
			option = "Shadows",
			valueOn = 1,
			valueOff = 0,
			x	 = -1,
			y	 = 192,
			action = "",
			applyRequired = true,
			align = MenuAlign.Left,
		},
		
		WeatherEffects =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.WeatherEffects,
			desc = TXT.MenuDesc.WeatherEffects,
			option = "WeatherEffects",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 242,
			action = "",
			align = MenuAlign.Left,
		},
		
		RenderSky =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.Sky,
			desc = TXT.MenuDesc.Sky,
			option = "RenderSky",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 292,
			action = "",
			align = MenuAlign.Left,
		},

		ViewWeaponModel =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.ViewWeapon,
			desc = TXT.MenuDesc.ViewWeapon,
			option = "ViewWeaponModel",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 342,
			action = "",
			align = MenuAlign.Left,
		},
		
		WeaponSpecular =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.WeaponSpecular,
			desc = TXT.MenuDesc.WeaponSpecular,
			option = "WeaponSpecular",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 392,
			action = "",
			applyRequired = true,
			align = MenuAlign.Left,
		},
		
		WeaponNormalMap =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.WeaponNormalMap,
			desc = TXT.MenuDesc.WeaponNormalMap,
			option = "WeaponNormalMap",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 442,
			action = "PainMenu:CheckWeaponSpecular()",
			applyRequired = true,
			align = MenuAlign.Left,
		},

		TexFiltering =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.TextureFiltering,
			desc = TXT.MenuDesc.TextureFiltering,
			option = "TextureFiltering",
			values = { "Bilinear", "Trilinear", "Anisotropic" },
			visible = { TXT.Menu.Bilinear, TXT.Menu.Trilinear, TXT.Menu.Anisotropic },
			x	 = -1,
			y	 = 502,
			action = "",
			align = MenuAlign.Left,
		},
		
		Multisample =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.Multisample,
			desc = TXT.MenuDesc.Multisample,
			option = "Multisample",
			values = { "x0", "x2", "x4", "x6" },
			visible = { TXT.None, "x2", "x4", "x6" },
			x	 = -1,
			y	 = 502,
			action = "",
			applyRequired = true,
			align = MenuAlign.Right,
		},

		DynLights =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.DynamicLights,
			desc = TXT.MenuDesc.DynamicLights,
			option = "DynamicLights",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 192,
			action = "",
			align = MenuAlign.Right,
		},
		
		Particles =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "Particles detail",
			desc = "Particles detail",
			option = "ParticlesDetail",
			values = { 0, 1, 2 },
			visible = { "Off", "50%", "100%" },
			x	 = -1,
			y	 = 352,
			action = "",
			align = MenuAlign.Right,
		},
		
		DecalsStay =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.DecalsStay,
			desc = TXT.MenuDesc.DecalsStay,
			option = "DecalsStayTime",
			values = { 0, 1, 2, 3, 4, 5 },
			visible = { "Off", "x1", "x2", "x3", "x4", "x5" },
			x	 = -1,
			y	 = 402,
			action = "",
			align = MenuAlign.Right,
		},

		Coronas =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.Coronas,
			desc = TXT.MenuDesc.Coronas,
			option = "Coronas",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 242,
			action = "",
			align = MenuAlign.Right,
		},

		DetailTextures =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.DetailTextures,
			desc = TXT.MenuDesc.DetailTextures,
			option = "DetailTextures",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 292,
			action = "",
			align = MenuAlign.Right,
		},
	}
}









--[[
		Decals =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.Decals,
			desc = TXT.MenuDesc.Decals,
			option = "Decals",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 292,
			action = "",
			disabled = 1,
			align = MenuAlign.Right,
		},
]]--		

--[[
		Projectors =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.Projectors,
			desc = TXT.MenuDesc.Projectors,
			option = "Projectors",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 192,
			action = "",
			disabled = 1,
			align = MenuAlign.Right,
		},
]]--

--[[		Shadows =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.Shadows,
			desc = TXT.MenuDesc.Shadows,
			option = "Shadows",
			values = { 0, 1 },
			visible = { "Off", "On" },
			x	 = -1,
			y	 = 150,
			action = "",
			applyRequired = true,
			align = MenuAlign.Left,
		},
]]--
