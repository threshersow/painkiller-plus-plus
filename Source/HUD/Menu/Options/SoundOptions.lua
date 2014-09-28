SoundOptions =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	fontBigSize = 36,
	sliderWidth = 340,
	fontBig		= "timesbd",
	fontSmall	= "timesbd",

--	backAction = "PainMenu:ActivateScreen(OptionsMenu)",
	backAction = "PainMenu:ApplySettings(); PainMenu:ApplyAudioSettings(true); PainMenu:ActivateScreen(OptionsMenu)",
	applyAction = "PainMenu:ApplySettings(); PainMenu:ApplyAudioSettings(true); PainMenu:ActivateScreen(OptionsMenu)",

	items =
	{
		VolumeBorder =
		{
			type = MenuItemTypes.Border,
			x = 100,
			y = 100,
			width = 824,
			height = 260,
		},

		MasterVolume =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.MasterVolume,
			desc = TXT.MenuDesc.MasterVolume,
			option = "MasterVolume",
			minValue = 0,
			maxValue = 100,
			x	 = 160,
			y	 = 140,
			action = "PainMenu:ApplyAudioSettings(false)",
		},

		MusicVolume =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.MusicVolume,
			desc = TXT.MenuDesc.MusicVolume,
			option = "MusicVolume",
			minValue = 0,
			maxValue = 100,
			x	 = 160,
			y	 = 190,
			action = "PainMenu:ApplyAudioSettings(false)",
		},
		
		AmbientVolume =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.AmbientVolume,
			desc = TXT.MenuDesc.AmbientVolume,
			option = "AmbientVolume",
			minValue = 0,
			maxValue = 100,
			x	 = 160,
			y	 = 240,
			action = "PainMenu:ApplyAudioSettings(false)",
		},

		SfxVolume =
		{
			type = MenuItemTypes.Slider,
			text = TXT.Menu.SoundVolume,
			desc = TXT.MenuDesc.SoundVolume,
			option = "SfxVolume",
			minValue = 0,
			maxValue = 100,
			x	 = 160,
			y	 = 290,
			action = "PainMenu:ApplyAudioSettings(false)",
		},

		SoundBorder =
		{
			type = MenuItemTypes.Border,
			x = 100,
			y = 410,
			width = 824,
			height = 200,
		},
--[[
		ReverseStereo =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.ReverseStereo,
			desc = TXT.MenuDesc.ReverseStereo,
			option = "ReverseStereo",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 445,
			action = "",
			fontBigSize = 26,
		},
]]--		
		SpeakersSetup =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.SpeakersSetup,
			desc = TXT.MenuDesc.SpeakersSetup,
			option = "SpeakersSetup",
			values = { "Two Speakers", "Headphones", "Surround", "Four Speakers", "Five-One", "Seven-One" },
			visible = { TXT.Menu.TwoSpeakers, TXT.Menu.Headphones, TXT.Menu.Surround, TXT.Menu.FourSpeakers, TXT.Menu.FiveOne, TXT.Menu.SevenOne },
			x	 = -1,
			y	 = 440,
			action = "",
			fontBigSize = 26,
		},

		SoundProvider =
		{
			type = MenuItemTypes.TextButtonEx,
			text = TXT.Menu.SoundProvider,
			desc = TXT.MenuDesc.SoundProvider,
			option = "SoundProvider3D",
			values = {},
			visible = {},
			x	 = -1,
			y	 = 475,
			action = "",
			fontBigSize = 26,
		},
		
		EAXAcoustics =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.EAXAcoustics,
			desc = TXT.MenuDesc.EAXAcoustics,
			option = "EAXAcoustics",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 500,
			action = "",
			fontBigSize = 26,
		},
		
		AmbientSounds =
		{
			type = MenuItemTypes.Checkbox,
			text = TXT.Menu.AmbientSounds,
			desc = TXT.MenuDesc.AmbientSounds,
			option = "AmbientSounds",
			valueOn = true,
			valueOff = false,
			x	 = -1,
			y	 = 545,
			action = "",
			fontBigSize = 26,
		},
	}
}
