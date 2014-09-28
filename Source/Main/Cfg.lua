CfgFile = "config.ini"
--============================================================================
-- Configuration
--============================================================================
Cfg =
{
	--AddPlayerObjects = true,
	--Interpolation = 1,
	--InterpolationNoSmooth = true,
	--InterpolationTolerance = 100,
	--NetcodeServerFrameRate = 30,
	DeferLoadingPlayers = false,
	DeferLoadingRest = true,
	
	--DefaultFont = "Courbd",
	--ShowHide = true,
	--ShowHidePrint = false,

	NoExplosions = false,
	NoBlood = false,
	NoGibs = false,
	NoSmoke = false,
	NoSpawnEffects = false,
	NoFlames = false,
	DirectInput = true,

	TeamScoresShadowLevel = 2,
	ShowFPSShadowLevel = 2,
	ShowPingShadowLevel = 2,
	ShowTimerShadowLevel = 2,

	HitSounds = true,
	NoGong = false,
	NoMPComments = false,
	BrightSkins = true,


	ImpureClientWarning = false,

	PitabotEnabled = false,

	ShowTimerShadow = true,
	ShowFPSShadow = true,
	ShowPingShadow = true,
	ShowPingX = 0.8789,
	ShowPingY = 0.1412,

	DisableHud = false,

	AutoScreenshot = false,

	RocketFix = true,
	--DeadBodyFix = false,
	--FreezerFix = false,
	FallingDamage = true,

	WeaponPrediction = true,

	RestartMaps = true,
	--RocketExplosionStrength = 3150,
	--RocketFactor = 0.6,
	--RocketFactorOrder = 1,
	RocketLogging = false,

	TournamentSettings = false,

	DisableMOTDRendering = false,

	TeamOverlay = true,
	CrosshairNames = true,
	CrosshairNamesTeamOnly = false,
	CrosshairNamesDisableInDuel = true,
	TeamScores = true,
	TeamScoresShadow = true,
	ConfigMapView = false,
	MapView = false,
	MapViewShowRespawns = false,

	MOTD = " ;Enjoy your stay;Have fun!; ",

	AutoTeamLock = false,
	AutoStatsDump = true,
	DuelQueue = true,

	WarmupDamage = true,
	ItemRespawnFix = true,

	BotMinPlayers = 2,
	ForceModel = true,
	ForceSpec = false,
	RocketsFromGun = true,
	ProPlus = false,
	BotAttack = true,
	BotFindItems = true,
	BotFakePing = true,
	BotCheckStubNose = true,
	ShowPing = false,
	AmmolistHideWeapons = false,
	ColouredIcons = false,

	LogfileDaily = true,
	Logging = true,
	Logfile = "GameLog",
	BotSkill = 5,
	BotNames = {"#4Robotn#4i#1k","Pie#3","#1S#2c#3u#4b#5a#6d#7i#8v#9e#0r","#5B#3lue#4m#5int","#0Unnewerr","C#3o#2smo","#C#4o#5W#4P#3i#2E","E#2liza","#6O#3m#ego","#7F#5rog","#3L#1ippman","C#4H#3#m'1#4astry","#3P#3etronius","#P#3O#2J","#3BlueLizard","#3W#4orrie","#2W#4estbrook","#3D#1HMEJA","#4Sud#1a#4fed","#4Heath#4Moore","P#3oo#0H","O#4ri#2on","#6K#4um#2quat","#6R#4i#6ngo","#4Laur#5ence","#3Sword#2king","klaus", "seb", "#3Gozo#423","#3M#4arvin","Luxor","#4G#3unkel","Will£4456","H#34x#40#2r","#3Billy","#3S#2cott","C#2hewy","#3Bikini#3Girl","#3Pr#4o#1wl","#4Ob#6seq#6ious","Numin","#1Aftershock","MaidMarian","#3Rumbraugh","#4I#1den","#4S#2wiss#5T#6ony","Gabba","#4Grrr","#4O","Aj","#2flump","Powerbladder5.3","S#4tropp","Yurrie"},
	BotTaunts = {"are you trying?","lag","do you know who vo0 is?","erm?","...?","I'm not even trying, can you tell?","hmm?","are you aliasing?","damn netcode","u sux","i dont know this map that well","pie","I'm only using keys","Try harder? :)",":o)","hahahahehehe :-)","All hail the king!","leave the armour for me please","I own Maniax, do you know him?",":DDDD","blah","hmmm","stop using the rl please","can we play fallen2 after this?","my mouse feels odd","my monitor just went off","hmm","erm","hm","nm","give me a sec while I clean my mouse","hi","k?","wtf?","cpl what?","err","do you have lag too?","are you in a clan?","how?","ok","sure","yes","erm","good",":)","fu",":/",":p",":d",":))",":o","B)",">:(","<:)","hah","dumdeedum","hmmm..","try aiming?","heh","where is the RL?","dont shoot for a sec","wanna join my clan?","*yawn*","haha","hehe","hoho","mm :)","pow!","I beat vo0 once","damn","zut alors","oh","er"},
	BotEliza = true,
	BotChat = true,
	BotQuickRespawn = true,
	OldScoreboard = false,
	AltScoreboard = false,
	ScoreboardShowPacketLoss = false,

	CustomCrosshairLocation = false,
	CustomCrosshairLocationX = 0.5,
	CustomCrosshairLocationY = 0.5,

	TeamScoresX = 0.86,
	TeamScoresY = 0.75,
	TeamOverlayX = 0.7,
	TeamOverlayY = 0.6,
	ShowTimerX = 0.8789,
	ShowTimerY = 0.0651,
	TeamOverlayW = 0.3,

	TeamScoresFontSize = 32,
	TeamOverlayFontSize = 16,
	ScoreboardFontSize = 20,
	ShowTimerFontSize = 45,
	CameraInterpolatePosition = false,
	CameraInterpolateAngle = false,

	Newhitsound = false,
	Simplehud = false,
	SimplehudShadow = true,
	Autorecord = true,
	Overtime = 2,
	SafeRespawn = false,

	Password = "",
	RefPass = "",
	RconPass = "",


	AllowBrightskins = true,
	AllowBunnyhopping = true,
	AllowForwardRJ = true,
	AmbientSounds = true,
	AmbientVolume = 77,
	AutoChangeWeapon = true,
	BestExplosives = {0,41,32,},
	BestNonExplosives = {72,71,62,61,51,52,42,31,22,21,12,11,0,},
	BestWeapons1 = {32,0,72,71,62,61,51,52,41,42,31,22,21,12,11,},
	BestWeapons2 = {12,0,72,71,62,61,51,52,41,42,32,31,22,21,11,},
	Bloom = true,
	Brightness = 0.5,
	BrightskinEnemy = "Red",
	BrightskinTeam = "Blue",
	FixedColors = true    ,
	CaptureLimit = 10,
	CharacterShadow = "Off",
	ClipPlane = 100,
	ConnectionSpeed = 4,
	Contrast = 0.5,
	Coronas = true,
	Credits = true,
	Crosshair = 34,
	CrosshairR = 255,
	CrosshairG = 255,
	CrosshairB = 255,
	CrosshairSize = 1,
	CrosshairTrans = 100,
	Decals = false,
	DecalsStayTime = 0.4,
	DedicatedServer = false,
	DetailTextures = true,
	DisturbSound3DFreq = 0.1,
	DynamicLights = 1,
	EAXAcoustics = true,
	FOV = 95,
	FragLimit = 0,
	Fullscreen = true,
	GameMode = "Free For All",
	Gamma = 1,
	GraphicsQuality = 0, -- Custom
	HeadBob = 100,
	HUDSize = 1,
	HUDTransparency = 25,
	InvertMouse = false,
	KeyAlternativeAlternativeFire = "Right Ctrl",
	KeyAlternativeBulletTime = "Return",
	KeyAlternativeFire = "None",
	KeyAlternativeFireBestWeapon1 = "None",
	KeyAlternativeFireBestWeapon2 = "None",
	KeyAlternativeFireSwitch = "None",
	KeyAlternativeFireSwitchToggle = "None",
	KeyAlternativeFlashlight = "None",
	KeyAlternativeForwardRocketJump = "None",
	KeyAlternativeJump = "None",
	KeyAlternativeMenu = "None",
	KeyAlternativeMoveBackward = "Cursor Down",
	KeyAlternativeMoveForward = "Cursor Up",
	KeyAlternativeNextWeapon = "None",
	KeyAlternativePause = "P",
	KeyAlternativePreviousWeapon = "None",
	KeyAlternativeQuickLoad = "None",
	KeyAlternativeQuickSave = "None",
	KeyAlternativeRocketJump = "None",
	KeyAlternativeSayToAll = "None",
	KeyAlternativeSayToTeam = "None",
	KeyAlternativeScoreboard = "None",
	KeyAlternativeScreenshot = "None",
	KeyAlternativeSelectBestWeapon1 = "None",
	KeyAlternativeSelectBestWeapon2 = "None",
	KeyAlternativeStrafeLeft = "Cursor Left",
	KeyAlternativeStrafeRight = "Cursor Right",
	KeyAlternativeWeapon1 = "Delete",
	KeyAlternativeWeapon2 = "None",
	KeyAlternativeWeapon3 = "End",
	KeyAlternativeWeapon4 = "Page Down",
	KeyAlternativeWeapon5 = "None",
	KeyAlternativeWeapon6 = "None",
	KeyAlternativeWeapon7 = "None",
	KeyAlternativeWeapon8 = "None",
	KeyAlternativeWeapon9 = "None",
	KeyAlternativeWeapon10 = "None",
	KeyAlternativeWeapon11 = "None",
	KeyAlternativeWeapon12 = "None",
	KeyAlternativeWeapon13 = "None",
	KeyAlternativeWeapon14 = "None",
	KeyAlternativeUseCards = "None",
	KeyAlternativeZoom = "Middle Mouse Button",
	KeyPrimaryAlternativeFire = "Right Mouse Button",
	KeyPrimaryBulletTime = "None",
	KeyPrimaryFire = "Left Mouse Button",
	KeyPrimaryFireBestWeapon1 = "Left Shift",
	KeyPrimaryFireBestWeapon2 = "Left Ctrl",
	KeyPrimaryFireSwitch = "R",
	KeyPrimaryFireSwitchToggle = "T",
	KeyPrimaryFlashlight = "L",
	KeyPrimaryForwardRocketJump = "None",
	KeyPrimaryJump = "Space",
	KeyPrimaryMenu = "None",
	KeyPrimaryMoveBackward = "S",
	KeyPrimaryMoveForward = "W",
	KeyPrimaryNextWeapon = "Mouse Wheel Forward",
	KeyPrimaryPause = "P",
	KeyPrimaryPreviousWeapon = "Mouse Wheel Back",
	KeyPrimaryQuickLoad = "F9",
	KeyPrimaryQuickSave = "F5",
	KeyPrimaryRocketJump = "None",
	KeyPrimarySayToAll = "None",
	KeyPrimarySayToTeam = "None",
	KeyPrimaryScoreboard = "Tab",
	KeyPrimaryScreenshot = "F12",
	KeyPrimarySelectBestWeapon1 = "None",
	KeyPrimarySelectBestWeapon2 = "None",
	KeyPrimaryStrafeLeft = "A",
	KeyPrimaryStrafeRight = "D",
	KeyPrimaryWeapon1 = "1",
	KeyPrimaryWeapon2 = "2",
	KeyPrimaryWeapon3 = "3",
	KeyPrimaryWeapon4 = "4",
	KeyPrimaryWeapon5 = "5",
	KeyPrimaryWeapon6 = "6",
	KeyPrimaryWeapon7 = "7",
	KeyPrimaryWeapon8 = "8",
	KeyPrimaryWeapon9 = "9",
	KeyPrimaryWeapon10 = "0",
	KeyPrimaryWeapon11 = "F1",
	KeyPrimaryWeapon12 = "F2",
	KeyPrimaryWeapon13 = "F3",
	KeyPrimaryWeapon14 = "F4",
	KeyPrimaryUseCards = "E",
	KeyPrimaryZoom = "Z",
	Language = "english",
	LMSLives = 5,
	ManualIP = "127.0.0.1",
	MasterVolume = 100,
	MaxPlayers = 16,
	MaxSpectators = 8,
	MessagesKeys = {"None","None","None","None","None","None","None","None","None","None","None","None","None","None","None","None","None","None",},
	MessagesSayAll = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	MouseSensitivity = 40,
	Multisample = "x0",
	MusicVolume = 33,
	NetworkInterface = "",
	ParticlesDetail = 2,
	PlayerModel = 2,
	PlayerName = "Unnamed",
	PowerupDrop = false,
	Powerups = true,
	PrecacheData = 0,
	Projectors = false,
	PublicServer = false,
	RenderSky = 2,
	Resolution = "1024X768",
	ReverseStereo = false,
	ServerMaps = {},
	ServerMapsFFA = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerMapsTDM = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerMapsTLB = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerMapsPCF = {"DMPCF_Tower","DMPCF_Warehouse","DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerMapsVSH = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerMapsCTF = {"CTF_Forbidden","CTF_Chaos","CTF_Trainstation"},
	ServerMapsDUE = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerMapsLMS = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerMapsCLA = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"},
	ServerName = "Painkiller++",
	ServerPassword = "",
	ServerPort = 3455,
	SfxVolume = 100,
	Shadows = 0,
	ShowDaydreamWarning = true,
	SmoothMouse = true,
	SoundFalloffSpeed = 6,
	SoundPan = 50,
	SoundProvider3D = "Miles Fast 2D Positional Audio",
	SoundQuality = "High",
	SpeakersSetup = "Two Speakers",
	StartupWeapon = 0,
	SwitchFire = { false, false, false, false, false },
	Team = 0,
	TeamDamage = false,
	TextureFiltering = "Bilinear",
	TextureQuality = 0,
	TextureQualityArchitecture = 0,
	TextureQualityCharacters = 0,
	TextureQualitySkies = 0,
	TextureQualityWeapons = 0,
	TimeLimit = 15,
	LimitServerFPS = false,
	ServerFPS = 30,
	UserCaptureLimit = true,
	UserLMSLives = true,
	UserKick = true,
	UserBankick = true,
	UserMaxPlayers = true,
	UserMaxSpectators = true,
	UserPowerupDrop = true,
	UserPowerups = true,
	UserWeaponsStay = true,
	UserTeamDamage = true,
	UserWeaponRespawnTime = true,
	UserAllowBunnyhopping = true,
	UserAllowBrightskins = true,
	UserAllowForwardRJ = true,
	UserReloadMap = true,
	UserGameMode = true,
	UserMapChange = true,
	UserTimeLimit = true,
	UserFragLimit = true,
	UserStartupWeapon = true,
	ViewWeaponModel = true,
	WeaponBob = 0,
	WeaponNormalMap = true,
	WeaponPriority = { 72, 71, 62, 61, 51, 52, 41, 42, 32, 31, 22, 21, 12, 11, 0 },
	WeaponSpecular = true,
	WeaponsStay = true,
	WeaponRespawnTime = 30,
	NoAmmoSwitch = false,
	LowQualityMultiplayerSFX = false,
	WarpEffects = true,
	WaterFX = 1,
	WeatherEffects = true,
	WheelSensitivity = 3,
	WarmUpTime = 10,
	CameraInterpolation = true, -- only for MP client
	MaxFpsMP = 125,
	NetcodeStatsUpdateDelay = 1000,
	NetcodeStatsNumberToAverageFrom = 1,
	NetcodeServerFramerate = 25,
	NetcodeClientMaxBytesPerSecond = -1,
	NetcodeLocalPlayerSynchroEveryNFrames = 0,
	NetcodeMaxPlayerActionsPassed = 3,
	NetcodeEnemyPredictionInterpolation = true,
	NetcodeEnemyPredictionInterpolationFactor = 0.66,
	NetcodeMinUpstreamFrameSize = 0,
	ZoomFOV = 50,
	StopMatchOnTeamQuit = true,
	NoWarmup = false,
	PureScripts = false,	-- strict scripts checksum checking during net connection
	ShowTimer = true,
	ShowTimerCountUp = true,
	PKTV = false,
	PKTVFps = 20,
	PKTVDelay = 30000, --ms
	HUD_FragMessage = true,
	HUD_AmmoList = 1,
	HUD_CurrentWeapon_Icon = true,
	--HUD_TimerPos = 900,
	--overtime = 2,
	FPS = true,
	PKTVPassword = "",


	--    MBStats = {0,0,0,0,0,12495}, -- (fury,endurance,double haste,blessing,forgiveness)

	-- Admin info (for ASE)
	Admin = "",
	Email = "",
	URL = "",
	Location = "",
	ModName = "PK++",
	ClientConsoleLockdown = false,
	PiTaBOT = 1,
}

--============================================================================
function Cfg:Save()
	local f = io.open (CfgFile,"w")
	if not f then
		if Game then
			Game:Print("WARNING: "..CfgFile.."is read-only. Configuration not saved.")
		else
			MsgBox("WARNING: "..CfgFile.." is read-only. Configuration not saved.")
		end
		return
	end

	local sorted = {}
	for i,o in self do  table.insert(sorted,{i,o}) end
	table.sort(sorted,function (a,b) return a[1] < b[1] end)


	for i,v in sorted do
		if string.sub(v[1],1,1) ~= '_' and (type(v[2]) == "string" or type(v[2]) == "number" or type(v[2]) == "boolean") then
			local val = v[2]
			if type(v[2]) == "string" then
				--val = '"'..v[2]..'"'
				val = string.format('%q', v[2])
			end
			if type(v[2]) == "boolean" then
				if v[2] == true then val = "true" else val = "false" end
			end
			f:write("Cfg."..v[1].." = "..val..'\n')
		end
		if type(v[2]) == "table" then
			local tab = v[2]
			f:write( "Cfg."..v[1].." = {" )
			for i=1,table.getn(tab) do
				local val = tab[i]
				if type(val) == "string" or type(val) == "number" or type(val) == "boolean" then
					if type(val) == "string" then
						--val = '"'..val..'"'
						val = string.format('%q', val)
					end
					if type(val) == "boolean" then
						if val == true then val = "true" else val = "false" end
					end
					f:write( val.."," )
				end
			end
			f:write( "}"..'\n' )
		end
	end
	io.close(f)
end
--============================================================================
function Cfg:Load()
	Cfg:CheckLanguage()
	Cfg:CheckLimitations()
	DoFile(CfgFile,false)
	Cfg:Check()
	Cfg:Save()
end
--============================================================================
function Cfg:CheckLimitations()
	if IsMPDemo() then
		Cfg.ServerName = "Painkiller Demo"
	end

	if not IsPKInstalled() then
	ServerMapsFFA = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"}
	ServerMapsTDM = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"}
	ServerMapsTLB = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"}
	ServerMapsPCF = {"DMPCF_Tower","DMPCF_Warehouse"}
	ServerMapsVSH = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"}
	ServerMapsCTF = {"CTF_Forbidden","CTF_Chaos","CTF_Trainstation"}
	ServerMapsDUE = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"}
	ServerMapsLMS = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"}
	ServerMapsCLA = {"DM_Mine","DM_Illuminati","DM_Cursed","DM_Sacred","DM_Psycho","DM_Fragenstein","DM_Factory","DM_Trainstation","DM_Fallen1","DM_Fallen2"}

	end
end
--============================================================================
function toboolean(statement)
	if (statement==true or statement=="true" or statement==1) then
		return true
	else
		return false
	end
end

--============================================================================
function Cfg:CheckVar(var,vartype,lower,upper)

	if vartype == "n" then
		if not var then var = lower end
		var = tonumber(var)
		if var < lower then var = lower end
		if var > upper then var = upper end
		return var
	end
	if vartype == "b" then
		var = toboolean(var)
		return var
	end
end
--============================================================================
function Cfg:Check()
	-- General checking of variables
	Cfg.TextureQuality = Cfg:CheckVar(Cfg.TextureQuality,"n",0,999)
	Cfg.TimeLimit = Cfg:CheckVar(Cfg.TimeLimit,"n",0,999)
	Cfg.FragLimit = Cfg:CheckVar(Cfg.FragLimit,"n",0,999)
	Cfg.MaxPlayers = Cfg:CheckVar(Cfg.MaxPlayers,"n",1,32)
	Cfg.MaxSpectators = Cfg:CheckVar(Cfg.MaxSpectators,"n",0,32)
	Cfg.FragLimit = Cfg:CheckVar(Cfg.FragLimit,"n",0,999)
	Cfg.PlayerModel = Cfg:CheckVar(Cfg.PlayerModel,"n",1,7)
	Cfg.MaxFpsMP = Cfg:CheckVar(Cfg.MaxFpsMP,"n",30,120)
	Cfg.MouseSensitivity = Cfg:CheckVar(Cfg.MouseSensitivity,"n",0,999)
	Cfg.RenderSky = Cfg:CheckVar(Cfg.RenderSky,"n",0,2)
	Cfg.GraphicsQuality = Cfg:CheckVar(Cfg.GraphicsQuality,"n",0,6)
	Cfg.DynamicLights = Cfg:CheckVar(Cfg.DynamicLights,"n",0,2)
	Cfg.ConnectionSpeed = Cfg:CheckVar(Cfg.ConnectionSpeed,"n",1,5)
	Cfg.WheelSensitivity = Cfg:CheckVar(Cfg.WheelSensitivity,"n",0,999)
	Cfg.DecalsStayTime = Cfg:CheckVar(Cfg.DecalsStayTime,"n",0,999)
	Cfg.CrosshairSize = Cfg:CheckVar(Cfg.CrosshairSize,"n",0,999)
	Cfg.StartupWeapon = Cfg:CheckVar(Cfg.StartupWeapon,"n",0,7)
	--Cfg.Tiny = Cfg:CheckVar(Cfg.Tiny,"n",0,999)
	--Cfg.ShowWeaponX = Cfg:CheckVar(Cfg.ShowWeaponX,"n",-999,999)
	--Cfg.ShowWeaponY = Cfg:CheckVar(Cfg.ShowWeaponY,"n",-999,999)
	--Cfg.ShowWeaponZ = Cfg:CheckVar(Cfg.ShowWeaponZ,"n",-999,999)
	--Cfg.Interpolation = Cfg:CheckVar(Cfg.Interpolation,"n",0,1)
	--Cfg.InterpolationTolerance = Cfg:CheckVar(Cfg.InterpolationTolerance,"n",0,9999)
	--Cfg.NetcodeServerFrameRate = Cfg:CheckVar(Cfg.NetcodeServerFrameRate,"n",0,999)
	
	--Cfg.AddPlayerObjects = Cfg:CheckVar(Cfg.AddPlayerObjects,"b")
	--Cfg.InterpolationNoSmooth = Cfg:CheckVar(Cfg.InterpolationNoSmooth,"b")
	Cfg.DeferLoadingPlayers = Cfg:CheckVar(Cfg.DeferLoadingPlayers,"b")
	Cfg.DeferLoadingRest = Cfg:CheckVar(Cfg.DeferLoadingRest,"b")

	--Cfg.DrawGraphGamePulses = Cfg:CheckVar(Cfg.DrawGraphGamePulses,"b")
	--Cfg.DrawGraphFramerate = Cfg:CheckVar(Cfg.DrawGraphFramerate,"b")
	--Cfg.DrawGraphLatency = Cfg:CheckVar(Cfg.DrawGraphLatency,"b")
	--Cfg.DrawGraphScriptIn = Cfg:CheckVar(Cfg.DrawGraphScriptIn,"b")
	--Cfg.DrawGraphScriptOut = Cfg:CheckVar(Cfg.DrawGraphScriptOut,"b")
	--Cfg.DrawGraphEventIn = Cfg:CheckVar(Cfg.DrawGraphEventIn,"b")
	--Cfg.DrawGraphEventOut = Cfg:CheckVar(Cfg.DrawGraphEventOut,"b")


	-- Specific cases
	if type(Cfg.BestExplosives[1]) == "string" or table.getn(Cfg.WeaponPriority) < 15 then
		Cfg.BestExplosives = {0,41,32,}
		Cfg.BestNonExplosives = {72,71,62,61,51,52,42,31,22,21,12,11,0,}
		Cfg.BestWeapons1 = {32,0,72,71,62,61,51,52,41,42,31,22,21,12,11,}
		Cfg.BestWeapons2 = {12,0,72,71,62,61,51,52,41,42,32,31,22,21,11,}
		Cfg.WeaponPriority = { 72, 71, 62, 61, 51, 52, 41, 42, 32, 31, 22, 21, 12, 11, 0 }
	end
	for i=1,table.getn(Cfg.MessagesSayAll) do
		if Cfg.MessagesSayAll[i] ~= 0 then
			Cfg.MessagesSayAll[i] = 1
		end
	end
	Cfg.PlayerName = HUD.ColorSubstr(tostring(Cfg.PlayerName),16)
	-- Removal of obsolete variables from the config.ini
	Cfg.NewPrediction = nil
	Cfg.FramerateLock = nil
	Cfg.UseGamespy = nil
	Cfg.PushLatency = nil
	Cfg.PlayerPrediction = nil
	if not IsPKInstalled() then
		Cfg.PublicServer = false
	end
	if IsBlackEdition() then
		Cfg.BlackEdition = true
	else
		Cfg.BlackEdition = false
	end
end
--============================================================================
function Cfg:CheckLanguage()
	local label = GetCDLabel()
	local lang = Cfg.Language
	if label then label = string.lower(label) end
	if label == "pk_fr_1" then
		lang = "french"
	elseif label == "pk_de_1" then
		lang = "german"
	elseif label == "pk_it_1" then
		lang = "italian"
	elseif label == "pk_sp_1" then
		lang = "spanish"
	elseif label == "pk_pl_1" then
		lang = "polish"
	elseif label == "pk_ru_1" then
		lang = "russian"
	elseif label == "pk_cz_1" then
		lang = "czech"
	elseif label == "pk_1" then
		lang = "english"
	end
	if lang == "french" then
		Cfg.KeyPrimaryStrafeLeft = "Q"
		Cfg.KeyPrimaryMoveForward = "Z"
	end
	if Cfg.Language == "german" then
		Tweak.GlobalData.DisableGibs = true
		Tweak.GlobalData.GermanVersion = true
	end
	Cfg.Language = lang
end
--============================================================================
function Cfg:FindMPModel(name)
	for i=1,table.getn(MPModels) do
		if MPModels[i] == name then return i end
	end
	return 2
end
--============================================================================
function Cfg_ClearKeyBinding( key )
	local name, o = next( Cfg, nil )
	while name do
		if string.find( name, "KeyAlternative" ) or string.find( name, "KeyPrimary" ) then
			if( Cfg[name] == key ) then Cfg[name] = "None" end
		end
		name,o = next( Cfg, name )
	end

	for i=1,table.getn(Cfg.MessagesKeys) do
		if Cfg.MessagesKeys[i] == key then
			Cfg.MessagesKeys[i] = "None"
		end
	end

	local short = INP.GetShortNameByEngName( key )
	if short and Cfg["Bind_"..string.upper(short)] then
		Cfg["Bind_"..string.upper(short)] = nil
	end
end
--============================================================================
function Cfg_BindKeyCommands()
	local name, o = next( Cfg, nil )
	while name do
		if string.find( name, "Bind_" ) then
			Console:Cmd_BIND(string.sub(name,6).." "..Cfg[name],true)
		end
		name,o = next( Cfg, name )
	end
end
--============================================================================