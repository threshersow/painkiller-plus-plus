DemoEnd =
{
	firstTimeShowItems = 80,

	bgStartFrame = { 120, 243, 267 },
	bgEndFrame   = { 180, 266, 291 },

	background = "HUD/demoend",

	wait = 0,
	hideCursor = true,

	items =
	{
		OrderButton =
		{
			type = MenuItemTypes.ImageButton,
			text = "",
			desc = "",
			x = 882,
			y = 692,
			action = "PMENU.LaunchURL('http://www.painkillergame.com/demo_preorder.php'); Exit()",
			image = "HUD/demoend_preorder",
			imageUnder = "HUD/demoend_preorder",
			imagePressed = "HUD/demoend_preorder",
		},

		QuitButton =
		{
			type = MenuItemTypes.ImageButton,
			text = "",
			desc = "",
			x = 882,
			y = 725,
			action = "Exit()",
			image = "HUD/demoend_quit",
			imageUnder = "HUD/demoend_quit",
			imagePressed = "HUD/demoend_quit",
		},
--[[
		BackButton =
		{
			type = MenuItemTypes.ImageButton,
			text = "",
			desc = "",
			x = 0,
			y = 0,
			action = "Exit()",
			image = "HUD/demoend",
			imageUnder = "HUD/demoend",
			imagePressed = "HUD/demoend",
		}
]]--
	}
}
