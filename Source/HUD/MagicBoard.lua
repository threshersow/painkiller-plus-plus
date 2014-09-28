BoardSlots =
{
	PermAll =
	{
		type = BoardSlotsTypes.PermAll,
		numSlots = 17,
		x_pk = { 56, 135, 214, 292, 369, 447, 525, 604, 681, 759, 835, 913 },
		x_addon = { 53, 107, 161, 216, 271, 324, 379, 434, 487, 542, 597, 650, 705, 758, 813, 867, 922 },
		y_pk = 55,
		y_addon = 78,
		size_pk = { 55, 92 },
		size_addon = { 46, 74 },
		spaceWidth = 78,
	},

	TimeAll =
	{
		type = BoardSlotsTypes.TimeAll,
		numSlots = 17,
		x_pk = { 56, 135, 214, 292, 369, 447, 525, 604, 681, 759, 835, 913 },
		x_addon = { 53, 107, 161, 216, 271, 324, 379, 434, 487, 542, 597, 650, 705, 758, 813, 867, 922 },
		y_pk = 617,
		y_addon = 638,
		size_pk = { 55, 92 },
		size_addon = { 46, 74 },
		spaceWidth = 78,
	},

	PermSel =
	{
		type = BoardSlotsTypes.PermSel,
		numSlots = 2,
		x_pk = { 59, 231 },
		x_addon = { 59, 231 },
		y_pk = 179,
		y_addon = 179,
		size_pk = { 137, 227 },
		size_addon = { 137, 227 },
		spaceWidth = 173,
	},
	
	TimeSel =
	{
		type = BoardSlotsTypes.TimeSel,
		numSlots = 3,
		x_pk = { 489, 660, 828 },
		x_addon = { 489, 660, 828 },
		y_pk = 364,
		y_addon = 364,
		size_pk = { 138, 228 },
		size_addon = { 138, 228 },
		spaceWidth = 173,
	},
}

MagicCards =
{
	timeCards =
	{
		{
			texture = "HUD/Board/Cards/TC_Speed",
			bigImage = "HUD/Board/Cards/Big/TC_Speed",
			name = Languages.Texts[338],
			desc = Languages.Texts[362],
			cost = 100,
			index = 1,
		},

		{
			texture = "HUD/Board/Cards/TC_Dexterity",
			bigImage = "HUD/Board/Cards/Big/TC_Dexterity",
			name = Languages.Texts[339],
			desc = Languages.Texts[363],
			cost = 300,
			index = 2,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Fury",
			bigImage = "HUD/Board/Cards/Big/TC_Fury",
			name = Languages.Texts[340],
			desc = Languages.Texts[364],
			cost = 200,
			index = 3,
		},

		{
			texture = "HUD/Board/Cards/TC_Rage",
			bigImage = "HUD/Board/Cards/Big/TC_Rage",
			name = Languages.Texts[341],
			desc = Languages.Texts[365],
			cost = 500,
			index = 4,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Confusion",
			bigImage = "HUD/Board/Cards/Big/TC_Confusion",
			name = Languages.Texts[342],
			desc = Languages.Texts[366],
			cost = 200,
			index = 5,
		},

		{
			texture = "HUD/Board/Cards/TC_Endurance",
			bigImage = "HUD/Board/Cards/Big/TC_Endurance",
			name = Languages.Texts[343],
			desc = Languages.Texts[367],
			cost = 100,
			index = 6,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Immunity",
			bigImage = "HUD/Board/Cards/Big/TC_Immunity",
			name = Languages.Texts[344],
			desc = Languages.Texts[368],
			cost = 666,
			index = 7,
		},

		{
			texture = "HUD/Board/Cards/TC_Haste",
			bigImage = "HUD/Board/Cards/Big/TC_Haste",
			name = Languages.Texts[345],
			desc = Languages.Texts[369],
			cost = 100,
			index = 8,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Double_Haste",
			bigImage = "HUD/Board/Cards/Big/TC_Double_Haste",
			name = Languages.Texts[346],
			desc = Languages.Texts[370],
			cost = 300,
			index = 9,
		},

		{
			texture = "HUD/Board/Cards/TC_Triple_Haste",
			bigImage = "HUD/Board/Cards/Big/TC_Triple_Haste",
			name = Languages.Texts[347],
			desc = Languages.Texts[371],
			cost = 500,
			index = 10,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Time_Bonus",
			bigImage = "HUD/Board/Cards/Big/TC_Time_Bonus",
			name = Languages.Texts[348],
			desc = Languages.Texts[372],
			cost = 100,
			index = 11,
		},

		{
			texture = "HUD/Board/Cards/TC_Double_Time_Bonus",
			bigImage = "HUD/Board/Cards/Big/TC_Double_Time_Bonus",
			name = Languages.Texts[349],
			desc = Languages.Texts[373],
			cost = 300,
			index = 12,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Weapon_Modifier",
			bigImage = "HUD/Board/Cards/Big/TC_Weapon_Modifier",
			name = Languages.Texts[783],
			desc = Languages.Texts[793],
			cost = 100,
			index = 25,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Magic_Gun",
			bigImage = "HUD/Board/Cards/Big/TC_Magic_Gun",
			name = Languages.Texts[784],
			desc = Languages.Texts[838],
			cost = 300,
			index = 26,
		},
		
		{
			texture = "HUD/Board/Cards/TC_The_Sceptre",
			bigImage = "HUD/Board/Cards/Big/TC_The_Sceptre",
			name = Languages.Texts[841],
			desc = Languages.Texts[844],
			cost = 300,
			index = 27,
		},

		{
			texture = "HUD/Board/Cards/TC_Demon_Morph",
			bigImage = "HUD/Board/Cards/Big/TC_Demon_Morph",
			name = Languages.Texts[842],
			desc = Languages.Texts[845],
			cost = 666,
			index = 28,
		},
		
		{
			texture = "HUD/Board/Cards/TC_Rebirth",
			bigImage = "HUD/Board/Cards/Big/TC_Rebirth",
			name = Languages.Texts[843],
			desc = Languages.Texts[846],
			cost = 400,
			index = 29,
		},
	},
	
	permCards =
	{
		{
			texture = "HUD/Board/Cards/PC_Soul_Catcher",
			bigImage = "HUD/Board/Cards/Big/PC_Soul_Catcher",
			name = Languages.Texts[350],
			desc = Languages.Texts[374],
			cost = 500,
			index = 13,
		},

		{
			texture = "HUD/Board/Cards/PC_Soul_Keeper",
			bigImage = "HUD/Board/Cards/Big/PC_Soul_Keeper",
			name = Languages.Texts[351],
			desc = Languages.Texts[375],
			cost = 500,
			index = 14,
		},
		
		{
			texture = "HUD/Board/Cards/PC_Soul_Power",
			bigImage = "HUD/Board/Cards/Big/PC_Soul_Power",
			name = Languages.Texts[352],
			desc = Languages.Texts[376],
			cost = 1000,
			index = 15,
		},

		{
			texture = "HUD/Board/Cards/PC_Dark_Soul",
			bigImage = "HUD/Board/Cards/Big/PC_Dark_Soul",
			name = Languages.Texts[353],
			desc = Languages.Texts[377],
			cost = 400,
			index = 16,
		},
		
		{
			texture = "HUD/Board/Cards/PC_Blessing",
			bigImage = "HUD/Board/Cards/Big/PC_Blessing",
			name = Languages.Texts[354],
			desc = Languages.Texts[378],
			cost = 200,
			index = 17,
		},

		{
			texture = "HUD/Board/Cards/PC_Vitality",
			bigImage = "HUD/Board/Cards/Big/PC_Vitality",
			name = Languages.Texts[355],
			desc = Languages.Texts[379],
			cost = 100,
			index = 18,
		},
		
		{
			texture = "HUD/Board/Cards/PC_Double_Ammo",
			bigImage = "HUD/Board/Cards/Big/PC_Double_Ammo",
			name = Languages.Texts[356],
			desc = Languages.Texts[380],
			cost = 500,
			index = 19,
		},

		{
			texture = "HUD/Board/Cards/PC_Double_Treasure",
			bigImage = "HUD/Board/Cards/Big/PC_Double_Treasure",
			name = Languages.Texts[357],
			desc = Languages.Texts[381],
			cost = 2000,
			index = 20,
		},
		
		{
			texture = "HUD/Board/Cards/PC_Forgiveness",
			bigImage = "HUD/Board/Cards/Big/PC_Forgiveness",
			name = Languages.Texts[358],
			desc = Languages.Texts[382],
			cost = 1000,
			index = 21,
		},

		{
			texture = "HUD/Board/Cards/PC_Mercy",
			bigImage = "HUD/Board/Cards/Big/PC_Mercy",
			name = Languages.Texts[359],
			desc = Languages.Texts[383],
			cost = 2000,
			index = 22,
		},
		
		{
			texture = "HUD/Board/Cards/PC_Divine_Intervention",
			bigImage = "HUD/Board/Cards/Big/PC_Divine_Intervention",
			name = Languages.Texts[360],
			desc = Languages.Texts[384],
			cost = 0,
			index = 23,
		},

		{
			texture = "HUD/Board/Cards/PC_Last_Breath",
			bigImage = "HUD/Board/Cards/Big/PC_Last_Breath",
			name = Languages.Texts[361],
			desc = Languages.Texts[385],
			cost = 500,
			index = 24,
		},
		
		{
			texture = "HUD/Board/Cards/PC_Health_Stealer",
			bigImage = "HUD/Board/Cards/Big/PC_Health_Stealer",
			name = Languages.Texts[788],
			desc = Languages.Texts[798],
			cost = 2000,
			index = 30,
		},

		{
			texture = "HUD/Board/Cards/PC_Health_Regeneration",
			bigImage = "HUD/Board/Cards/Big/PC_Health_Regeneration",
			name = Languages.Texts[789],
			desc = Languages.Texts[799],
			cost = 1500,
			index = 31,
		},
		
		{
			texture = "HUD/Board/Cards/PC_Armor_Regeneration",
			bigImage = "HUD/Board/Cards/Big/PC_Armor_Regeneration",
			name = Languages.Texts[790],
			desc = Languages.Texts[800],
			cost = 1000,
			index = 32,
		},

		{
			texture = "HUD/Board/Cards/PC_Fear",
			bigImage = "HUD/Board/Cards/Big/PC_Fear",
			name = Languages.Texts[791],
			desc = Languages.Texts[801],
			cost = 1000,
			index = 33,
		},
		
		{
			texture = "HUD/Board/Cards/PC_666_Ammo",
			bigImage = "HUD/Board/Cards/Big/PC_666_Ammo",
			name = Languages.Texts[792],
			desc = Languages.Texts[802],
			cost = 2000,
			index = 34,
		},
	}
}

MagicBoard =
{
}

function MagicBoard:Setup()
	MagicBoard_LoadStatus()

	if Game.AddOn then
		for i, o in MagicCards.timeCards do
			if o.index < 25 then
				Game.CardsAvailable[o.index] = true
			end
		end
		for i, o in MagicCards.permCards do
			if o.index < 25 and o.index ~= 23 then
				Game.CardsAvailable[o.index] = true
			end
		end
	end

	-- Slots
	local i, o = next( BoardSlots, nil )
	while i do
		local y2 = -1
		if o.y2 then
			y2 = o.y2
		end
		local numSlots = o.numSlots
		if not Game.AddOn and o.numSlots > 4 then numSlots = 12 end

		local x = o.x_pk
		local y = o.y_pk
		local size = o.size_pk
		if Game.AddOn then
			x = o.x_addon
			y = o.y_addon
			size = o.size_addon
		end

		MBOARD.SetupSlots( o.type, numSlots, y, size[1], size[2], o.spaceWidth, y2 )

		for n, m in x do
			MBOARD.SetSlotPosition( o.type, n - 1, x[n] )
		end

		i,o = next( BoardSlots, i )
	end

	-- Cards
	for i, o in MagicCards.timeCards do
		MBOARD.AddCard( MagicCardsTypes.Time, o.name, o.texture, o.desc, o.cost, Game.CardsAvailable[o.index], Game.CardsSelected[o.index], o.bigImage )
	end

	for i, o in MagicCards.permCards do
		MBOARD.AddCard( MagicCardsTypes.Perm, o.name, o.texture, o.desc, o.cost, Game.CardsAvailable[o.index], Game.CardsSelected[o.index], o.bigImage )
	end
end


function MagicBoard_UpdateCardsStatus()
	for i, o in MagicCards.timeCards do
		if Game.CardsAvailable[o.index] then
			if o.index < 25 or Game.AddOn then
				Game.CardsSelected[o.index] = not MBOARD.IsCardInSlot( BoardSlotsTypes.TimeAll, i - 1 )
			end
		end
	end

	for i, o in MagicCards.permCards do
		if Game.CardsAvailable[o.index] then
			if o.index < 25 or Game.AddOn then
				Game.CardsSelected[o.index] = not MBOARD.IsCardInSlot( BoardSlotsTypes.PermAll, i - 1 )
			end
		end
	end
	
	MagicBoard_SaveStatus()
end

function MagicBoard_SaveStatus()
end

function MagicBoard_LoadStatus()
end
