--============================================================================
-- Game Version
--============================================================================
PK_VERSION = "1.64"
PKPLUSPLUS_VERSION = "1.31.1.64"
--============================================================================
-- Keys
--============================================================================
SCREEN_WIDTH,SCREEN_HEIGHT = 100,100
Keys = {
    MouseButtonLeft = 1,
    MouseButtonRight = 2,
    MouseButtonMiddle = 4,
    
    Backspace = 8,
    Tab   =  9,
    Enter = 13,
    Shift = 16,
    Ctrl  = 17,
    Alt   = 18,
    Pause = 19,
    CapsLock = 20,
    Esc   = 27,
    Space = 32,
    
    PgUp  = 33,
    PgDn  = 34,
    End   = 35,
    Home  = 36,
    Left  = 37,
    Up    = 38,
    Right = 39,
    Down  = 40,
    
    PrintScreen = 44,
    Insert = 45,
    Delete = 46,
    
    K0    = 48,
    K1    = 49,
    K2    = 50,
    K3    = 51,
    K4    = 52,
    K5    = 53,
    K6    = 54,
    K7    = 55,
    K8    = 56,
    K9    = 57,
    
    A     = 65,
    B     = 66,
    C     = 67,
    D     = 68,
    E     = 69,
    F     = 70,
    G     = 71,
    H     = 72,
    I      = 73,
    J      = 74,
    K      = 75,
    L     = 76,
    M     = 77,
    N     = 78,
    O     = 79,
    P     = 80,
    Q     = 81,
    R     = 82,
    S     = 83,
    T     = 84,
    U     = 85,
    V     = 86,
    W     = 87,
    X     = 88,
    Y     = 89,
    Z     = 90,
    
    LeftWindows = 91,
    RightWindows = 92,
    FarRightWindows = 93,
    
    Num0 = 96,
    Num1 = 97,
    Num2 = 98,
    Num3 = 99,
    Num4 = 100,
    Num5 = 101,
    Num6 = 102,
    Num7 = 103,
    Num8 = 104,
    Num9 = 105,
    NumMultiply = 106,
    NumPlus = 107,
    NumMinus = 109,
    NumDecimal = 110,
    NumDivide = 111,
    
    F1    = 112,
    F2    = 113,
    F3    = 114,
    F4    = 115,
    F5    = 116,
    F6    = 117,
    F7    = 118,
    F8    = 119,
    F9    = 120,
    F10   = 121,
    F11   = 122,
    F12   = 123,

    NumLock = 144,
    ScrollLock = 145,
    
    LeftShift = 160,
    RightShift = 161,
    LeftCtrl = 162,
    RightCtrl = 163,
    
    Semicolon = 186,
    Equal = 187,
    Minus = 189,
    Tylda = 192,
    
    SquareBracketLeft = 219,
    Backslash = 220,
    SquareBracketRight = 221,
    Apostrophe = 222,

    NumlockEnter = 252,
    MouseWheelForward = 253,
    MouseWheelBack = 254,

}
setmetatable(Keys,{__mode="vk"}) 
--============================================================================
KBTypes =
{
	QWERTY	= 1,
	AZERTY	= 2,
	QWERTZ	= 3,
}
setmetatable(KBTypes,{__mode="vk"}) 
--============================================================================
ETypes = 
{
    None        =  0,
    Mesh        =  1,
    Light       =  2,
    ParticleFX  =  3,
    Model	    =  4,
    Region      =  5,
    Decal	    =  6,
    Billboard   =  8,
    Environment =  9,
    Trail       = 10,
    Sound       = 11,
}
setmetatable(ETypes,{__mode="vk"}) 
--============================================================================
ECollisionGroups = 
{
	Fixed =		1,
	Phantom =	2,
	Normal =	3,
	Body =		4,
	Missile =	5,

	Ragdoll =	6,
	Noncolliding =	7,
	Particles =	8,
	InsideItems =	9,
    
    
    RagdollNonColliding = 10,
    RagdollColliding = 20,
    RagdollSpecial = 21,

    Barrier = 22,
    PlayerBody = 23,    
    
    FixedSpecial = 24,
    OnlyWithFixedSpecial = 25,
    HCGNormalNCWithSelf = 26,
    MonsterBarrier	=		27,
    HCGFixedWithNoncollidable = 28,	-- like "Fixed", but collidable with "Noncolliding"
    HCGNormalBodyNCWithSelf = 29,
    ClientGrenade = 30,
}
setmetatable(ECollisionGroups,{__mode="vk"}) 
--============================================================================

Actions = 
{
    None				= 1,
    Forward				= 2,
--	Forward				= 256*256*256,
    Backward			= 4,
    Left				= 8,
    Right				= 16,
    Jump				= 32,
    Fire				= 64,
    AltFire				= 128,
    NextWeapon			= 256,
    PrevWeapon			= 2*256,
    Weapon1				= 4*256,
    Weapon2				= 8*256,
    Weapon3				= 16*256,
    Weapon4				= 32*256,
    Weapon5				= 64*256,
    Weapon6				= 128*256,
    Weapon7				= 256*256,
    Weapon8				= 2*256*256,
    Weapon9				= 4*256*256,
    Weapon10			= 8*256*256,
    Weapon11			= 16*256*256,
    Weapon12			= 32*256*256,
    Weapon13			= 64*256*256,
    Weapon14			= 128*256*256,

	FireBestWeapon1		= 256*256*256,
--	FireBestWeapon1		= 2,
    FireBestWeapon2		= 2*256*256*256,

    RocketJump			= 4*256*256*256,
    ForwardRocketJump	= 8*256*256*256,    
    UseCards			= 16*256*256*256,

    ComboFire			= 32*256*256*256,

    SelectBestWeapon1	= 64*256*256*256,
    SelectBestWeapon2	= 128*256*256*256,
}
setmetatable(Actions,{__mode="vk"}) 
--============================================================================
UIActions =
{
	None				= 1,
	Pause				= 2,
	Screenshot			= 4,
	Menu				= 8,
	Scoreboard			= 16,
	SayToAll			= 32,
	SayToTeam			= 64,
	QuickLoad			= 128,
	QuickSave			= 256,
	Flashlight			= 2*256,
	Zoom				= 4*256,
}
setmetatable(UIActions,{__mode="vk"}) 
--============================================================================
BodyTypes = 
{
    Default     = 0,
    Simple      = 1,
    Sphere      = 1,
    Fatter      = 2,
    
    FromMesh = 4,
    FromMeshNonConvex = 5,
    FromMeshNotCentered = 7,
    
    SphereSweep = 9,
    FromMeshSweep = 11,
    DefaultSweep = 3,
    FatterSweep = 10,

    FromRagdoll = 15,
    
    Player      = 100,
}
setmetatable(BodyTypes,{__mode="vk"}) 
--============================================================================
EFreedomsOfRotation = 
{
	Disabled = 0,
	YAxis = 1,
	AllAxes = 2,
	FullFree = 3,
	HardTurn = 4,
	XAxis = 5,
	ZAxis = 6,
}
setmetatable(EFreedomsOfRotation,{__mode="vk"}) 
--============================================================================
ProjectileTypes = 
{
    Timed      = 1,
    Impact    = 2,
    NoGravity = 4,
}
setmetatable(ProjectileTypes,{__mode="vk"}) 
--============================================================================
MPProjectileTypes = 
{
    Default    = 0,
    Stake      = 1,
    Grenade    = 2,
    PainHead   = 3,
    HeaterBomb = 4,
    Soul       = 5,
    Spectator  = 6,
}
setmetatable(MPProjectileTypes,{__mode="vk"}) 
--============================================================================
TextureFlags =
{
	Invalid		= 1,
	NoMipMaps	= 2,
	DuDv		= 4,
	NoLOD		= 8,
	Raw32		= 2048,
	Raw8		= 4096,
	Anim		= 8192,
	System		= 16384,
	Raw32Alpha	= 32768,
}
--============================================================================
MenuWindowTypes = 
{
    SimpleWindow         = 0,
    Button                   = 1,
    ProgressBar            = 2,
    ScrollBar                = 3,
    EditField                 = 4,
    ListControl              = 5,
    CheckBox               = 6,
    GameSpyControl      = 7,
    RedefineKeysControl = 8,
}
setmetatable(MenuWindowTypes,{__mode="vk"}) 
--============================================================================
MenuBackgroundTypes =
{
	Image		= 1,
	Movie		= 2,
}
setmetatable(MenuBackgroundTypes,{__mode="vk"})
--============================================================================
MenuItemTypes =
{
	TextButton	= 1,
	Checkbox	= 2,
	TextButtonEx= 3,
	Slider		= 4,
	ControlCfg	= 5,
	Scroller	= 6,
	TextEdit	= 7,
	SliderImage = 8,
	ServerList  = 9,
	ServerData  = 10,
	Password    = 11,
	NumEdit		= 12,
	List		= 13,
	MapTable	= 14,
	NumRange	= 15,
	LoadSave	= 16,
	StaticText	= 17,
	ImageButton	= 18,
	KeyList		= 19,
	Border		= 20,
	TabGroup	= 21,
	PlayerModel	= 22,
	ColorPicker = 23,
	CharPicker  = 24,
	ImageButtonEx = 25,
	WeaponList	= 26,
	MessagesKeys = 27,
	SimpleKeyConf = 28,
}
setmetatable(MenuItemTypes,{__mode="vk"})
--============================================================================
MenuAlign =
{
	None		= 1,
	Left		= 2,
	Right		= 3,
	Center		= 4,
}
setmetatable(MenuAlign,{__mode="vk"})
--============================================================================
ConsoleMode =
{
	Full		= 0,
	SayAll		= 1,
	SayTeam		= 2,
}
setmetatable(ConsoleMode,{__mode="vk"})
--============================================================================
R3DHWClass =
{
	Unsupported	= 0,
	GenericTnL	= 1,
	NV20		= 2,
	NV25		= 3,
	R200		= 4,
	NV30		= 5,
}
setmetatable(R3DHWClass,{__mode="vk"})
--============================================================================
BoardSlotsTypes =
{
	TimeAll		= 0,
	PermAll		= 1,
	TimeSel		= 2,
	PermSel		= 3,
}
setmetatable(BoardSlotsTypes,{__mode="vk"})
--============================================================================
MagicCardsTypes =
{
	Time		= 1,
	Perm		= 2,
}
setmetatable(MagicCardsTypes,{__mode="vk"})
--============================================================================
MultiplayerErrorTypes =
{
    Information		= 0,
    Disconnected	= 1,
	BadPassword		= 2,
	BadCDKey		= 3,
}
setmetatable(MultiplayerErrorTypes,{__mode="vk"})
--============================================================================
TextJustification = 
{
    DontJustify       = 0,
    FromLeft          = 1,
    FromRight         = 2,
    Centered          = 3,
    FromLeftOutside = 4,
}
setmetatable(TextJustification,{__mode="vk"}) 
--============================================================================
AttackTypes = 
{
    Shotgun    =  1,
    Grenade    =  2,
    Rocket     =  3,
    OutOfLevel =  4,
    MiniGun    =  5,    
    Fire	   =  6,
    Explosion  =  7,
    Poison     =  8,
    Bubble     =  9,
    Stake      = 10,
    Painkiller = 11,
    HitGround  = 12,
    TeleFrag   = 13,
    Suicide    = 14,    
    StickyBomb = 15,    -- AI
    Step       = 16,    -- AI
    AIClose    = 17,
    AIFar      = 18,
    Shuriken   = 19,
    Physics    = 20,
    Stone      = 21,
    Demon      = 22,
    Electro    = 23,    
    PainkillerRotor = 24,
    Fireball = 25,
    ItemCollision = 26,
    Tank = 27,
    Lava = 28,
    ConsoleKill = 29,
    Hurt_Pent = 30,
    Rifle = 31,
    FlameThrower = 32,
    Flag = 33,
    BoltStick = 34,
    HeaterBomb = 35,
}
setmetatable(AttackTypes,{__mode="vk"}) 
--============================================================================
Weapon2Ammo = 
{
    [11] = "Full",
    [12] = "Full",
    [21] = "Shotgun",
    [22] = "IceBullets",
    [31] = "Stakes",
    [32] = "Grenades",
    [41] = "Grenades",
    [42] = "MiniGun",
    [51] = "Shurikens",
    [52] = "Electro",
    [61] = "Rifle",
    [62] = "FlameThrower",
    [71] = "Bolt",
    [72] = "HeaterBomb",
}
setmetatable(Weapon2Ammo,{__mode="vk"}) 
--============================================================================
Slot2Action = 
{
    [1] = Actions.Weapon1,
    [2] = Actions.Weapon2,
    [3] = Actions.Weapon3,
    [4] = Actions.Weapon4,
    [5] = Actions.Weapon5,
    [6] = Actions.Weapon6,
    [7] = Actions.Weapon7,
}
setmetatable(Slot2Action,{__mode="vk"}) 
--============================================================================
ArmorTypes =  
{
    None        = 0,
    Weak        = 1,
    Medium      = 2,
    Strong      = 3,
}
setmetatable(ArmorTypes,{__mode="vk"}) 
--============================================================================
MovingCurve = 		-- Moving Curve
{
	None	= 0,
	ETransX	= 1,
	ETransY = 2,
	ETransZ = 4,
	ERot    = 8,
}
setmetatable(MovingCurve,{__mode="vk"}) 
MC = MovingCurve
--============================================================================
--Templates = {} -- templates cache
--============================================================================
EntityToObject = {} -- table of references
setmetatable(EntityToObject,{__mode="vk"}) 
--============================================================================
LogicSounds = 
{
    ["EXPLOSION"]  = 10,			-- im wiekszy numer, tym wiekszy priorytet
    ["FIRE"]       = 8,
    ["RICOCHET"]   = 6,
    ["STEP"]       = 4,
    ["ANIMAL"]     = 3,
    ["RELOAD"]     = 2,
}
setmetatable(LogicSounds,{__mode="vk"}) 

--============================================================================
SynchroClassesUpdateDelay = {0, 0.2, 0.4, 0.6, 1}
SynchroClasses = 
{
    Realtime = 1,
    Temp01   = 2,
    Temp02   = 3,
}
setmetatable(SynchroClasses,{__mode="vk"}) 

ActiveSounds = {}		--{__mode = "vk"}
--============================================================================
GModes = 
{
    ShutDown = 0,
    StartupMenu = 1,
    SingleGame = 2,
    DedicatedServer = 3,
    MultiplayerServer = 4,
    MultiplayerClient = 5,
    Default = 2,
}
ServerID = 255
--============================================================================
SoundsDefs = {
	cementary_stones = {
		path = "impacts/",
		samples = {"figure-stone-impact1","figure-stone-impact2"},
        dist1 = 15,
        dist2 = 60,
    },

    catacombs_stones = {
		path = "impacts/",
        samples = {"stonebig-impact1","stonebig-impact2","stonebig-impact3","stonebig-impact4"},
        dist1 = 20,
        dist2 = 80,
    },
    catacombs_column = {
		samples = {"actor/thor/thor-hammer-punch1"},
        dist1 = 20,
        dist2 = 60,
    },
    opera_trashcan = {
		path = "impacts/",
		samples = {"trashcan-impact1","trashcan-impact2","trashcan-impact3"},
        dist1 = 10,
        dist2 = 40,
    },
    opera_trashcancover = {
    	path = "impacts/",
		samples = {"trashcancover-impact1","trashcancover-impact2","trashcancover-impact3"},
        dist1 = 10,
        dist2 = 40,
    },
    asylum_chair = {
    	path = "impacts/",
		samples = {"pallet-impact1","pallet-impact2","pallet-impact3"},
        dist1 = 10,
        dist2 = 40,
    },
    asylum_bed = {
		path = "impacts/",
		samples = {"chest-wood-impact1","chest-wood-impact2","chest-wood-impact3"},
        dist1 = 15,
        dist2 = 40,
    },
    militaryb_tank = {
		path = "impacts/",
        samples = {"gasbotlle-impact1","gasbotlle-impact2","gasbotlle-impact3",},
        dist1 = 15,
        dist2 = 60,
    },
    heavymetal = {
		samples = {"impacts/hook-ground"},
        dist1 = 50,
        dist2 = 200,
	},	
	woodfalls = {
		path = "impacts/",
		samples = {"wood-fallsdown1","wood-fallsdown2","wood-fallsdown3"},
        dist1 = 15,
        dist2 = 50,
	},
    boxmetal = {
		path = "impacts/",
		samples = {"box-metal-impact1","box-metal-impact2","box-metal-impact3"},
        dist1 = 15,
        dist2 = 40,
	},

	-- actors
    gibSplash = {
        path = "impacts/",
        samples = {"meat-splash1","meat-splash2","meat-splash3","meat-splash4","meat-splash5"},
        dist1 = 16,
        dist2 = 60,
    },
    frozenSplash = {
        path = "impacts/",
        samples = {"meat_frozen-splash1","meat_frozen-splash2","meat_frozen-splash3","meat_frozen-splash4"},
        dist1 = 16,
        dist2 = 60,
    },
    gibFrozen = {
		path = "impacts/",
		dist1 = 16,
		dist2 = 50,
        samples = {"gib_frozen1","gib_frozen2","gib_frozen3"},
    },
    gib = {
		path = "impacts/",
		dist1 = 16,
		dist2 = 50,
        samples = {"gib_big","gib_big2","gib_big3"},
    },
    monsterExplosion = {
		path = "/",
		samples = {"monster_body_explosion"},
		dist1 = 8,
		dist2 = 32,
	},
	waterSplash = {
		path = "impacts/",
		samples = {"water-splash1","water-splash2","water-splash3"},
		dist1 = 20,
		dist2 = 50,
	},
    light_chair = {
    	path = "impacts/",
		samples = {"carton-box-impact1","carton-box-impact2","carton-box-impact3"},
        dist1 = 10,
        dist2 = 40,
    },
}

SoundsDefsGroups = {}
SoundsDefsGroups[20] = SoundsDefs.cementary_stones
SoundsDefsGroups[21] = SoundsDefs.asylum_chair
SoundsDefsGroups[22] = SoundsDefs.opera_trashcan
SoundsDefsGroups[23] = SoundsDefs.catacombs_stones
SoundsDefsGroups[24] = SoundsDefs.catacombs_column
SoundsDefsGroups[25] = SoundsDefs.opera_trashcancover
SoundsDefsGroups[26] = SoundsDefs.asylum_bed
SoundsDefsGroups[27] = SoundsDefs.militaryb_tank
SoundsDefsGroups[28] = SoundsDefs.heavymetal
SoundsDefsGroups[29] = SoundsDefs.woodfalls
SoundsDefsGroups[30] = SoundsDefs.boxmetal
SoundsDefsGroups[31] = SoundsDefs.light_chair
--============================================================================

SoundsProperties =
{
    {"default", 6, 0.1},		-- max. ilosc instancji, nie czesciej niz (sec.)
    {"monster_raven_wings_flap", 4, 0.4},
    {"monster_body_explosion", 3, 0.4},
    {"weapon_grenade_explosion", 3, 0.4},
    {"actor/raven/raven_wings_flap", 4, 0.4},
	
--- hellbiker ---	
	{"actor/hellbiker/hellb-krokp",3, 0.5},
	{"actor/hellbiker/hellb-krokl",3, 0.5},
	{"actor/hellbiker/hellb-run1_1",3, 0.5},
    {"actor/hellbiker/hellb-run2_2",3, 0.5},
    {"actor/hellbiker/hellb-run1_2",3, 0.5},
    {"actor/hellbiker/hellb-run2_1",3, 0.5},
--- sado ---
    {"actor/sado/sado_krok1",2, 0.6},
    {"actor/sado/sado_krok2",2, 0.6},
    {"actor/sado/sado_krok3",2, 0.6},
    {"actor/sado/sado_krok4",2, 0.6},
    
    {"actor/sado/sado_fire-shoot1",2, 0.5},
    {"actor/sado/sado_fire-shoot2",2, 0.5},
    {"actor/sado/sado_fire-shoot3",2, 0.5},
    
    {"actor/sado/sado_fire-shell1",2, 0.5},
    {"actor/sado/sado_fire-shell2",2, 0.5},
    {"actor/sado/sado_fire-shell3",2, 0.5},
    
--- maso ---
	{"actor/maso/maso_krok1",3, 0.5},
	{"actor/maso/maso_krok2",3, 0.5},
	{"actor/maso/maso-weapon-explode",4, 0.5},
	{"actor/maso/maso_bodyfalls",4, 0.5},

--- zombie ---
	{"actor/zombie_soldier/zombs_krok1",3, 0.5},
	{"actor/zombie_soldier/zombs_krok2",3, 0.5},
	{"actor/zombie_soldier/zombs_swish-prepare",4, 0.5},
	{"actor/zombie/zombie_krok1",3, 0.5},
	{"actor/zombie/zombie_krok2",3, 0.5},
	{"actor/zombie/zombie_swish1",3, 0.4},
	{"actor/zombie/zombie_swish2",3, 0.4},

--- skeleton ---
	{"actor/skeleton_soldier/skeleton_krok1",3, 0.5},
	{"actor/skeleton_soldier/skeleton_krok2",3, 0.5},
	{"actor/skeleton_soldier/skeleton_rifle-shoot1",2, 0.5},
	{"actor/skeleton_soldier/skeleton_rifle-shoot2",2, 0.5},
	{"actor/skeleton_soldier/skeleton_weapon-lost",3, 0.5},
	{"actor/skeleton_soldier/skeleton_bodyfalls",3, 0.4},
-- evil ---
	{"actor/evilmonk/evil_krok1",3, 0.5},
	{"actor/evilmonk/evil_krok2",3, 0.5},

-- devil ---
	{"actor/devilmonk/devil_krokl",3, 0.5},
	{"actor/devilmonk/devil_krokp",3, 0.5},


	{"actor/Psycho_elektro/psycho_krok1",3, 0.5},
	{"actor/Psycho_elektro/psycho_krok2",3, 0.5},
	{"actor/Psycho_elektro/psycho_elektro-krok1",3, 0.5},
	{"actor/Psycho_elektro/psycho_elektro-krok2",3, 0.5},
	{"actor/loki/loki_krok1",3, 0.5},
	{"actor/loki/loki_krok2",3, 0.5},
	{"actor/loki/loki_krok3",3, 0.5},
	{"actor/loki/loki_krok4",3, 0.5},
	{"actor/loki_small/tick_krok1",3, 0.5},
	{"actor/loki_small/tick_krok2",3, 0.5},
	{"actor/loki_small/tick_krok3",3, 0.5},
	{"actor/loki_small/tick_krok4",3, 0.5},
	{"actor/samurai/samurai-krokl",3, 0.5},
	{"actor/samurai/samurai-krokp",3, 0.5},
	{"actor/ninja/ninja-krokl",3, 0.5},
	{"actor/ninja/ninja-krokp",3, 0.5},
	{"actor/ninja/ninja_boddyfalls",3, 0.5},
    {"actor/skull/monster_skull_krokl",3, 0.5},
    {"actor/skull/monster_skull_krokp",3, 0.5},

    {"actor/leper/lepper_bodyfalls",3, 0.5},
    
--- impacts ---
	{"impacts/bullet-stone", 2, 0.6},
	{"impacts/bullet-stone2", 2, 0.6},
	{"impacts/bullet-stone3", 2, 0.6},
	{"impacts/bullet-stone4", 2, 0.6},
    
    {"impacts/wood-fallsdown1", 3, 0.6},
    {"impacts/wood-fallsdown2", 3, 0.6},
    {"impacts/wood-fallsdown3", 3, 0.6},
    {"impacts/wood-fallsdown4", 3, 0.6},
    
    {"impacts/meat-splash1", 2, 0.5},
    {"impacts/meat-splash2", 2, 0.5},
    {"impacts/meat-splash3", 2, 0.5},
    {"impacts/meat-splash4", 2, 0.5},
    {"impacts/meat-splash5", 2, 0.5},

	{"impacts/ricochet1", 2, 0.6},
	{"impacts/ricochet2", 2, 0.6},
	{"impacts/ricochet3", 2, 0.6},
	{"impacts/ricochet4", 2, 0.6},
    {"impacts/barrel-wood-explode", 5, 0.4},
	{"impacts/stone-crash", 4, 0.4},
	{"impacts/barrel-metal-explode", 5, 0.4},

    {"impacts/glass_crack", 3, 0.4},
	{"impacts/glass_pause_1", 3, 0.5},
	{"impacts/glass_pause_2", 3, 0.5},
	{"impacts/glass_pause_3", 3, 0.5},
	{"impacts/coffin_cover_crash2", 4, 0.4},

    {"weapons/machinegun/rocket_hit", 10, 0.01},
    {"weapons/grenadelauncher/weapon_grenade_bounce", 3, 0.5},    
}
--setmetatable(SoundsProperties,{__mode="k"})	-- nie trzeba bo sie ja kasuje po zaladowaniu

Acoustics = {
    RoomTypes = {"Generic|0", "PaddedCell|1", "Room|2", "Bathroom|3",
                 "LivingRoom|4", "StoneRoom|5","Auditorium|6", "ConcertHall|7","Cave|8",
                 "Arena|9", "Hangar|10", "CarpetedHallway|11", "Hallway|12",	"StoneCorridor|13",
                 "Alley|14", "Forest|15", "City|16", "Mountains|17", "Quarry|18", "Plain|19",
                 "ParkingLot|20", "SewerPipe|21", "UnderWater|22", "Drugged|23", "Dizzy|24",
                 "Psychotic|25"},
    GroundTypes = {
                    "Stone|0", 
                    "Dirt|1", 
                    "Metal|2", 
                    "MetalBig|3", 
                    "Wood|4", 
                    "WoodFloor|5", 
                    "WoodBridge|6", 
                    "Sand|7", 
                    "Snow|8", 
                    "Wet|9", 
                    "Water|10", 
                    "ClimbMetal|11", 
                    "ClimbWood|12",
                    "MetalSkid|13",
                    "WetSmall|14",
                    "Paddle|15",
                }
} 

Difficulties = 
{
  Daydream  = 0,
  Insomnia  = 1,
  Nightmare = 2,
  Trauma    = 3,
}

AmmoDifficultyModifier = 
{
  [Difficulties.Daydream]  = 2,
  [Difficulties.Insomnia]  = 1.5,
  [Difficulties.Nightmare] = 1,
  [Difficulties.Trauma]    = 1,
}

PKLevels = {
    "C1L1_Cathedral",
    "C1L2_Atrium_Complex",
    "C1L3_Catacombs",
    "C1L4_Cemetery",    
    "C1L5_Enclave",
    "C2L1_Bridge",
    "C2L2_Prison",
    "C2L3_Opera",
    "C2L4_Asylum",
    "C2L5_Town",
    "C2L6_Swamp",
    "C3L1_Train_Station",
    "C3L2_Factory",
    "C3L3_Military_Base",
    "C3L4_Castle",
    "C3L5_Ruins",
    "C3L6_Forest",
    "C4L1_Oriental_Castle",
    "C4L2_Babel",
    "C4L4_Alastor",
    "C5L1_City_On_Water",
    "C5L2_Docks",
    "C5L3_Monastery",
    "C5L4_Hell",
}

MP_PCF_Frags = 
{
  -- distance, frags
  {0  , 1 },
  {5  , 2 },
  {10 , 3 },
  {20 , 5 },
  {30 , 10},
}

MP_PCF_Damage = 
{
  -- distance, damage
  {0  , 1  },
  {2  , 2  },
  {5  , 3  },
  {10 , 100},
  {20 , 255},
}

if IsMPDemo() then
    MPModels =
    {
        "mp-model-demon",
        "mp-model-fallenangel",
        "mp-model-knight",
        "mp-model-beast",
    }
else
    MPModels =
    {
        "mp-model-demon",
        "mp-model-fallenangel",
        "mp-model-knight",
        "mp-model-beast",
        "mp-model-player7",
        "mp-model-painkiller",
        "mp-model-player6"
    }
end
--============================================================================
havokInfluenceInMonsterMovement = 0.5				-- wplyw havoka na predkosc potwora		1.0 - brak tlumienia havoka
MonsterAcceleration = 0.5                           -- w sec. czas przyspieszania w chodzeniu, >0, albo nil
