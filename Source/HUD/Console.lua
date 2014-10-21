--=======================================================================
Console =
{
}
--=======================================================================
function Console:Cmd_DIFFICULTY(enable)
	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("Difficulty is currently "..tostring(Game.Difficulty))
		return
	end
	Game.Difficulty = enable
end
--=======================================================================
function Console:Cmd_SHOWWEAPON(enable)
	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("showweapon 0/1  (disables/enables weapon rendering)")
		return
	end
	if enable == 1 then Cfg.ViewWeaponModel = true  end
	if enable == 0 then Cfg.ViewWeaponModel = false end
end
--=======================================================================
function Console:Cmd_WHERE()
	local me = 0
	for i,ps in Game.PlayerStats do
		if(Player == Game:FindPlayerByClientID(ps.ClientID))then
			me = ps.ClientID
		end
	end
	if Game.PlayerStats[me] and Game.PlayerStats[me]._Entity and Game.PlayerStats[me]._Entity ~=0 then
		local x,y,z = ENTITY.PO_GetPawnHeadPos(Game.PlayerStats[me]._Entity)
		CONSOLE_AddMessage(x..", "..y..", "..z)
	end
end
--=======================================================================
function Console:Cmd_ADDLOC(location,l1,l2,l3,l4,l5)

	if(location==nil)then CONSOLE_AddMessage("Usage \addloc <location>") return end

	if(l1~=nil)then location = location .." ".. l1 end
	if(l2~=nil)then location = location .." ".. l2 end
	if(l3~=nil)then location = location .." ".. l3 end
	if(l4~=nil)then location = location .." ".. l4 end
	if(l5~=nil)then location = location .." ".. l5 end

	local me = -99
	for i,ps in Game.PlayerStats do
		if(Player == Game:FindPlayerByClientID(ps.ClientID))then
			me = ps.ClientID
		end
	end
	if(me==-99)then return end
	local x = 0
	local y = 0
	local z = 0
	if Game.PlayerStats[me] and Game.PlayerStats[me]._Entity and Game.PlayerStats[me]._Entity ~=0 then
		x,y,z = ENTITY.PO_GetPawnHeadPos(Game.PlayerStats[me]._Entity)
		--CONSOLE_AddMessage(x..", "..y..", "..z)
	end
	local locfile = "../Data/Locs/"
	local mapname = Lev.Map
	if(mapname==nil)then return end
	locfile = locfile .. string.gsub (mapname,"(%a+).mpk", "%1")  .. ".loc"
	local file = io.open(locfile,"a")
	if not file then return end
	local txt = location..","..x..","..y..","..z..'\n'
	file:write(txt)
	CONSOLE_AddMessage("Added Location.")
	io.close(file)
	Loc.Position = {}
	Loc:Load(mapname)
end
--=======================================================================
function Console:Cmd_ADDWAYPOINT(location,l1,l2,l3,l4,l5)

	if(location==nil)then location = "Waypoint" end


	if(l1~=nil)then location = location .." ".. l1 end
	if(l2~=nil)then location = location .." ".. l2 end
	if(l3~=nil)then location = location .." ".. l3 end
	if(l4~=nil)then location = location .." ".. l4 end
	if(l5~=nil)then location = location .." ".. l5 end

	local me = -99
	for i,ps in Game.PlayerStats do
		if(Player == Game:FindPlayerByClientID(ps.ClientID))then
			me = ps.ClientID
		end
	end
	if(me==-99)then return end
	local x = 0
	local y = 0
	local z = 0
	if Game.PlayerStats[me] and Game.PlayerStats[me]._Entity and Game.PlayerStats[me]._Entity ~=0 then
		x,y,z = ENTITY.PO_GetPawnHeadPos(Game.PlayerStats[me]._Entity)
		--CONSOLE_AddMessage(x..", "..y..", "..z)
	end
	location = Game:GetLocationByPosition(x,y,z)
	local Waypointfile = "../Data/Waypoints/"
	local mapname = Lev.Map
	if(mapname==nil)then return end
	Waypointfile = Waypointfile .. string.gsub (mapname,"(%a+).mpk", "%1")  .. ".bwp"
	local file = io.open(Waypointfile,"a")
	if not file then return end
	local txt = location..","..x..","..y..","..z..'\n'
	file:write(txt)
	CONSOLE_AddMessage("Added Location.")
	io.close(file)
	Waypoint.Position = {}
	Waypoint:Load(mapname)
end
--=======================================================================

function Console:Cmd_PRINT(txt)
	CONSOLE_AddMessage(txt)
end
--=======================================================================
function Console:Cmd_PLAYERSPLAYERSTATS()
	CONSOLE_AddMessage("ID	x y z")
	for i,ps in Game.PlayerStats do
		if(ps.Player==nil)then
			CONSOLE_AddMessage(ps.ClientID.."   ".."NIL CPlayer object")
		else

			CONSOLE_AddMessage(ps.ClientID.."   "..tostring(ps.Player.Pos.X).."   "..tostring(ps.Player.Pos.Y).."   "..tostring(ps.Player.Pos.Z))
		end
	end
end
--=======================================================================
function Console:Cmd_ENTITYPLAYERSTATS()
	CONSOLE_AddMessage("ID	x y z")
	for i,ps in Game.PlayerStats do
		local px,py,pz = ENTITY.GetPosition(ps._Entity)
		CONSOLE_AddMessage(ps.ClientID.."   "..tostring(px).."   "..tostring(py).."   "..tostring(pz))

	end
end
--=======================================================================
function Console:Cmd_ENTITYPLAYER()
	CONSOLE_AddMessage("ID	x y z")
	for i,pp in Game.Players do
		local px,py,pz = ENTITY.GetPosition(pp._Entity)
		CONSOLE_AddMessage(pp.ClientID.."   "..tostring(px).."   "..tostring(py).."   "..tostring(pz))

	end
end
--=======================================================================
function Console:Cmd_PLAYERSGAME()
	CONSOLE_AddMessage("ID	x y z")
	for i,pp in Game.Players do
		CONSOLE_AddMessage(pp.ClientID.."   "..tostring(pp.Pos.X).."   "..tostring(pp.Pos.Y).."   "..tostring(pp.Pos.Z))
	end
end
--=======================================================================
function Console:Cmd_STRESSTEST()
	if IsFinalBuild() then return end

	local n = table.getn(PKLevels)
	GOD = true
	Game:LoadLevel(PKLevels[math.random(1,n)])
	Game:OnPlay(true)
	Game:SwitchPlayerToPhysics()
	AddAction({{"Wait:30"},{"L:StringToDo = 'Console:Cmd_STRESSTEST()'"}})
end
--=======================================================================
_tmpLevNr = 1
function Console:Cmd_EXPO()
	local levels = {"C2L5_Demo", "C5L1_Demo", "C5L4_Demo" }
	local n = table.getn(PKLevels)
	Game:LoadLevel(levels[_tmpLevNr])
	Game:OnPlay(true)

	_tmpLevNr = _tmpLevNr + 1
	if _tmpLevNr > 3 then _tmpLevNr = 1 end

	_EndTimeDemoCallBack  = function()
		StringToDo = 'Console:Cmd_EXPO()'
	end

	CONSOLE.Activate(false)
end
--=======================================================================
function Console:Cmd_SERVERINFO()
	if Game.GMode == GModes.SingleGame then return end
	Game.ServerInfoRequest(NET.GetClientID())
end
--=======================================================================
function Console:Cmd_BIND(params,silent)
	if not params or params == "" then
		if not silent then CONSOLE_AddMessage("usage: bind key command") end
		return
	end
	local i = string.find(params," ",1,true)
	if not i then i = string.len(params) + 1 end
	local key = string.sub(params,1,i-1)
	params = Trim( string.sub(params,i) )
	i = string.find(params," ",1,true)
	if not i then i = string.len(params) + 1 end
	local cmd = string.sub(params,1,i-1)

	if not params or params == "" or not key or key == "" then
		if not silent then CONSOLE_AddMessage("usage: bind key command") end
		return
	end

	if not Console["Cmd_"..string.upper(cmd)] then
		if not silent then CONSOLE_AddMessage("Unknown command: ".. cmd) end
		return
	end

	local keyOrig = key
	if key == "[" then key = "LBracket"
	elseif key == "]" then key = "RBracket"
	elseif key == ";" then key = "Semicolon"
	elseif key == "'" then key = "Quote"
	elseif key == "-" then key = "Minus"
	elseif key == "=" then key = "Plus"
	elseif key == "\\" then key = "BSlash"
	elseif key == "~" then key = "Tilde"
	elseif key == "," then key = "Comma"
	elseif key == "." then key = "Period"
	elseif key == "/" then key = "Slash"
	elseif string.upper(key) == "NUMPAD*" then key = "NumpadMulti"
	elseif string.upper(key) == "NUMPAD+" then key = "NumpadAdd"
	elseif string.upper(key) == "NUMPAD-" then key = "NumpadSub"
	elseif string.upper(key) == "NUMPAD." then key = "NumpadDec"
	elseif string.upper(key) == "NUMPAD/" then key = "NumpadDiv"
	end

	local engName = INP.GetEngNameByShortName( key )
	if engName == "None" then
		if not silent then CONSOLE_AddMessage("Unknown key: "..keyOrig) end
		return
	end
	Cfg_ClearKeyBinding( engName )
	INP.BindKeyCommand(string.upper(key),"Console:OnCommand('\\\\"..params.."')")
	Cfg["Bind_"..string.upper(key)] = params
end
--=======================================================================
-- MAP
--=======================================================================
function Console:Cmd_MAP(name)
	if name == nil then
		CONSOLE_AddMessage('Map "name"')
	else
		name = string.lower(name)
		local path = "../Data/Levels/"
		local files = FS.FindFiles(path.."*",0,1)
		local found = false
		for i=1,table.getn(files) do
			if string.lower(files[i]) == name then
				found = true
			end
		end
		if Game:IsServer() then
			NET.LoadMapOnServer(name)
		else
			Game:LoadLevel(name)
		end
	end
end
--=======================================================================
function Console:Cmd_MAPLIST() -- 04.10.2004 [Blowfish]
	local path = "../Data/Levels/"
	local files = FS.FindFiles(path.."*",0,1)
	CONSOLE_AddMessage("Available maps:")
	for i=1,table.getn(files) do
		CONSOLE_AddMessage("  |  "..files[i])
	end
end
--=======================================================================
function Console:Cmd_RELOADMAP()
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end
	if Lev._Name then
		Console:Cmd_MAP(Lev._Name)
	end
end
--=======================================================================
function Console:Cmd_TEAM(nr)

	if(nr=="b" or nr=="blue" or nr=="Blue") then
		nr = 1
	end
	if(nr=="r" or nr=="red" or nr=="Red") then
		nr = 2
	end
	if(nr=="f" or nr=="free") then
		nr = 1
	end
	if(nr=="s" or nr=="spectator") then
		Console:Cmd_SPECTATOR(1)
		return
	end

	if nr then
		nr = tonumber(nr)
		if nr and (nr == 1 or nr == 2) and Cfg.Team ~= nr - 1 then
			Cfg.Team = nr - 1
			if Game.GMode ~= GModes.SingleGame then
				Game.NewPlayerTeamRequest(NET.GetClientID(),Cfg.Team)
				return
			end
		end
	end
	if((Cfg.Team+1)==0)then
		CONSOLE_AddMessage("current team: blue")
	else
		CONSOLE_AddMessage("current team: red")
	end
end
--=======================================================================
function Console:Cmd_KILL()
	if Game.GMode == GModes.SingleGame then return end
	Game.PlayerKill(NET.GetClientID())
end
--=======================================================================
function Console:Cmd_SPECTATOR(nr)
	if nr then
		nr = tonumber(nr)
		if nr and (nr == 0 or nr == 1)then
			if Game.GMode ~= GModes.SingleGame then
				local spec = true
				if nr == 0 then spec = false end
				if spec ~= NET.IsSpectator(NET.GetClientID()) then
					if NET.IsPlayingRecording() then
						if nr == 0 then
							GObjects:ToKill(Game._procSpec)
							Game._procSpec = nil
							Player = Game._spectatorRecordingPlayer
						else
							GObjects:ToKill(Game._procStats)
							Game._procStats = nil
							Game._procSpec = GObjects:Add(TempObjName(),PSpectatorControler:New())
							Game._procSpec:Init()
							Game._spectatorRecordingPlayer = Player
							Player = nil
						end
						NET.SetSpectator(NET.GetClientID(),nr)
					else
						Game.PlayerSpectatorRequest(NET.GetClientID(),nr)
					end
				end
			end
		end
	end
end
--=======================================================================
function Console:Cmd_READY()
	if Game.GMode == GModes.SingleGame then return end
	Game.SetStateRequest(NET.GetClientID(),1)
end
--=======================================================================
function Console:Cmd_NOTREADY()
	if Game.GMode == GModes.SingleGame then return end
	Game.SetStateRequest(NET.GetClientID(),0)
end
--=======================================================================
function Console:Cmd_BREAK()
	if Game.GMode == GModes.SingleGame then return end
	Game.SetStateRequest(NET.GetClientID(),2)
end
--=======================================================================
function Console:Cmd_BANKICK(name)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end
	if name == nil then
		CONSOLE_AddMessage('bankick "name"  (disconnect and ban player from the server)')
		return
	end
	name = string.lower(name)
	for i,o in Game.PlayerStats do
		if string.lower(HUD.StripColorInfo(o.Name)) == name then
			NET.BanClient( o.ClientID )
			NET.DisconnectClient( o.ClientID )
		end
	end
end
--=======================================================================
function Console:Cmd_KICK(name)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end
	if name == nil then
		CONSOLE_AddMessage('kick "name"  (disconnect player from the server)')
		return
	end
	name = string.lower(name)
	for i,o in Game.PlayerStats do
		if string.lower(HUD.StripColorInfo(o.Name)) == name then
			NET.DisconnectClient( o.ClientID )
		end
	end
end
--=======================================================================
function Console:Cmd_BANKICKID(id)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end
	if id == nil then
		CONSOLE_AddMessage('kickid id  (disconnect player from the server)')
		return
	end
	id = tonumber(id)
	if id then
		NET.BanClient( id )
		NET.DisconnectClient( id )
	end
end
--=======================================================================
function Console:Cmd_KICKID(id)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end
	if id == nil then
		CONSOLE_AddMessage('kickid id  (disconnect player from the server)')
		return
	end
	id = tonumber(id)
	if id then NET.DisconnectClient( id ) end
end
--=======================================================================
function Console:Cmd_MAXPLAYERS(val)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	if val == nil then
		CONSOLE_AddMessage("maxplayers value (sets max number of players on server)")
		return
	end

	if Cfg.GameMode == "Duel" then
		CONSOLE_AddMessage("maxplayers cannot be changed in Duel mode")
		return
	end

	val = tonumber(val)
	if val and val > 1 then
		Cfg.MaxPlayers = val
		local gameState = "playing"
		if MPCfg.GameState == GameStates.WarmUp then
			gameState = "warmup"
		elseif MPCfg.GameState == GameStates.Counting then
			gameState = "counting"
		elseif MPCfg.GameState == GameStates.Finished then
			gameState = "finished"
		end
		local numPlayers = 0
		local numSpecs = 0
		for id,ps in Game.PlayerStats do
			if ps.Spectator == 0 then
				numPlayers = numPlayers + 1
			else
				numSpecs = numSpecs + 1
			end
		end
		GAMESPY.SetServerInfo(
		PK_VERSION,
		Cfg.ServerName,
		Cfg.ServerPassword,
		Lev._Name,
		Cfg.GameMode,
		Cfg.MaxPlayers,
		Cfg.MaxSpectators,
		Cfg.FragLimit,
		Cfg.TimeLimit,
		--            Cfg.TimeLimit * 60
		Game._TimeLimitOut,
		gameState,
		numPlayers,
		numSpecs
		)

		Game.ConsoleMessageAll( "Max number of players is now "..val )
	else
		CONSOLE_AddMessage("Max number of players cannot be lower than 2")
	end
end
--=======================================================================
function Console:Cmd_MAXSPECTATORS(val)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	if val == nil then
		CONSOLE_AddMessage("maxplayers value (sets max number of players on server)")
	end

	val = tonumber(val)
	if val then
		Cfg.MaxSpectators = val
		local gameState = "playing"
		if MPCfg.GameState == GameStates.WarmUp then
			gameState = "warmup"
		elseif MPCfg.GameState == GameStates.Counting then
			gameState = "counting"
		elseif MPCfg.GameState == GameStates.Finished then
			gameState = "finished"
		end
		local numPlayers = 0
		local numSpecs = 0
		for id,ps in Game.PlayerStats do
			if ps.Spectator == 0 then
				numPlayers = numPlayers + 1
			else
				numSpecs = numSpecs + 1
			end
		end
		GAMESPY.SetServerInfo(
		PK_VERSION,
		Cfg.ServerName,
		Cfg.ServerPassword,
		Lev._Name,
		Cfg.GameMode,
		Cfg.MaxPlayers,
		Cfg.MaxSpectators,
		Cfg.FragLimit,
		Cfg.TimeLimit,
		--            Cfg.TimeLimit * 60
		Game._TimeLimitOut,
		gameState,
		numPlayers,
		numSpecs
		)

		Game.ConsoleMessageAll( "Max number of spectators is now "..val )
	end
end
--=======================================================================
function Console:Cmd_HMRECORD()
	if IsFinalBuild() then return end
	if Game.GMode == GModes.SingleGame then return end
	PLAYER.RecordMovement( Player._Entity )
end
--=======================================================================
function Console:Cmd_HMTEST()
	if IsFinalBuild() then return end
	if Game.GMode == GModes.SingleGame then return end
	PLAYER.TestMovement( Player._Entity )
end
--=======================================================================
function Console:Cmd_SETMAXFPS(val)
	if val == nil then
		CONSOLE_AddMessage( "Give a new value after this command to change maxfps." )
		CONSOLE_AddMessage( "Give a 0 to remove the limit." )
		return
	end
	val = tonumber(val)
	if val then
		if( val > 125 ) then val = 125 end	-- enforce max FPS
		WORLD.SetMaxFPS(val)
		if Game.GMode == GModes.MultiplayerClient then
			Cfg.MaxFpsMP = val
		end
	end
end
--=======================================================================
function Console:Cmd_POWERUPDROP(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("powerupdrop 0/1  (disables/enables powerup drop)")
	end
	if enable == 1 then
		Cfg.PowerupDrop = true
		Game.ConsoleMessageAll("Powerup dropping enabled")
	elseif enable == 0 then
		Cfg.PowerupDrop = false
		Game.ConsoleMessageAll("Powerup dropping disabled")
	end
end
--=======================================================================
function Console:Cmd_POWERUPS(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("powerups 0/1  (disables/enables powerups)")
	end
	if enable == 1 then
		Cfg.Powerups = true
		Game.ConsoleMessageAll("Powerups will be enabled after map reload")
	elseif enable == 0 then
		Cfg.Powerups = false
		Game.ConsoleMessageAll("Powerups will be disabled after map reload")
	end
end
--=======================================================================
function Console:Cmd_WEAPONSSTAY(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("weaponsstay 0/1  (disables/enables weapons stay)")
	end
	if enable == 1 then
		Cfg.WeaponsStay = true
		Game.ConsoleMessageAll("Weapons stay enabled")
	elseif enable == 0 then
		Cfg.WeaponsStay = false
		Game.ConsoleMessageAll("Weapons stay disabled")
	end
end
--=======================================================================
function Console:Cmd_TEAMDAMAGE(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("teamdamage 0/1  (disables/enables team damage)")
	end
	if enable == 1 then
		Cfg.TeamDamage = true
		Game.ConsoleMessageAll("Team damage is now enabled")
	elseif enable == 0 then
		Cfg.TeamDamage = false
		Game.ConsoleMessageAll("Team damage is now disabled")
	end

	Game.SetConfiguration(Cfg.AllowBrightskins,Cfg.GameMode,Cfg.FragLimit,Cfg.CaptureLimit,Cfg.LMSLives,Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
end
--=======================================================================
function Console:Cmd_ALLOWBUNNYHOPPING(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("allowbunnyhopping 0/1  (disables/enables bunnyhopping)")
	end
	if enable == 1 then
		Cfg.AllowBunnyhopping = true
	elseif enable == 0 then
		Cfg.AllowBunnyhopping = false
	end

	Game.EnableBunnyhopping(Cfg.AllowBunnyhopping)
end
--=======================================================================
function Console:Cmd_ALLOWBRIGHTSKINS(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("allowbrightskins 0/1  (disables/enables brightskins)")
	end
	if enable == 1 then
		Cfg.AllowBrightskins = true
	elseif enable == 0 then
		Cfg.AllowBrightskins = false
	end

	MPCfg.GameMode         = Cfg.GameMode
	MPCfg.TeamDamage       = Cfg.TeamDamage
	MPCfg.AllowBrightskins = Cfg.AllowBrightskins

	Game.SetConfiguration(Cfg.AllowBrightskins,Cfg.GameMode,Cfg.FragLimit,Cfg.CaptureLimit,Cfg.LMSLives,Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
	Game.ReloadBrightskins()
end
--=======================================================================
function Console:Cmd_ALLOWFORWARDRJ(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("allowforwardrj 0/1  (disables/enables forward rocket jumps)")
	end
	if enable == 1 then
		Cfg.AllowForwardRJ = true
		Game.ConsoleMessageAll( "Forward Rocket Jumps enabled" )
	elseif enable == 0 then
		Cfg.AllowForwardRJ = false
		Game.ConsoleMessageAll( "Forward Rocket Jumps disabled" )
	end
end
--=======================================================================
function Console:Cmd_STARTUPWEAPON(enable)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("startupweapon 0-7 (0 = default)")
	else
		Cfg.StartupWeapon = enable
	end
end
--=======================================================================
function Console:Cmd_GAMEMODE(mode)
	if Game.GMode == GModes.SingleGame then return end
	if not Game:IsServer() then return end

	if IsMPDemo() then
		CONSOLE_AddMessage( "Command 'gamemode' not available in demo version" )
		return
	end

	local toPCF = false
	local fromPCF = false
	if Cfg.GameMode == "People Can Fly" then
		fromPCF = true
	elseif mode == "pcf" then
		toPCF = true
	end

	local newMap = nil
	local mapsTable = nil

	if mode == "ffa" then
		if Cfg.GameMode == "Free For All" then return end
		Cfg.GameMode = "Free For All"
		newMap = "DM_Sacred"
		mapsTable = Cfg.ServerMapsFFA
	elseif mode == "tdm" then
		if Cfg.GameMode == "Team Deathmatch" then return end
		Cfg.GameMode = "Team Deathmatch"
		newMap = "DM_Mine"
		mapsTable = Cfg.ServerMapsTDM
	elseif mode == "voosh" then
		if Cfg.GameMode == "Voosh" then return end
		Cfg.GameMode = "Voosh"
		newMap = "DM_Cursed"
		mapsTable = Cfg.ServerMapsVSH
	elseif mode == "tlb" then
		if Cfg.GameMode == "The Light Bearer" then return end
		Cfg.GameMode = "The Light Bearer"
		newMap = "DM_Sacred"
		mapsTable = Cfg.ServerMapsTLB
	elseif mode == "ctf" then
		if Cfg.GameMode == "Capture The Flag" then return end
		Cfg.GameMode = "Capture The Flag"
		newMap = "CTF_Forbidden"
		mapsTable = Cfg.ServerMapsCTF
	elseif mode == "pcf" then
		if Cfg.GameMode == "People Can Fly" then return end
		Cfg.GameMode = "People Can Fly"
		newMap = "DMPCF_Tower"
		mapsTable = Cfg.ServerMapsPCF
	elseif mode == "duel" then
		if Cfg.GameMode == "Duel" then return end
		Cfg.GameMode = "Duel"
		newMap = "DM_Sacred"
		mapsTable = Cfg.ServerMapsDUE
	elseif mode == "caaa" then
		if Cfg.GameMode == "Clan Arena" then return end
		Cfg.GameMode = "Clan Arena"
		newMap = "DM_Sacred"
		mapsTable = Cfg.ServerMapsCLA


	elseif mode == "lms" then
		if Cfg.GameMode == "Last Man Standing" then return end
		Cfg.GameMode = "Last Man Standing"
		newMap = "DM_Factory"
		mapsTable = Cfg.ServerMapsLMS
		
	elseif mode == "race" then
	    if Cfg.GameMode == "Race" then return end
		Cfg.GameMode = "Race"
		newMap = "RACE_Psycho"
		mapsTable = Cfg.ServerMapsRAC
	else
		CONSOLE_AddMessage("Available modes: ffa, tdm, voosh, tlb, pcf, ctf, duel, lms, race")
		return
	end
	Cfg.ServerMaps = {}
	PainMenu.mapsOnServer = {}

	if mapsTable[1] then
		newMap = mapsTable[1]
		for i=1,table.getn(mapsTable) do
			Cfg.ServerMaps[i] = mapsTable[i]
			PainMenu.mapsOnServer[i] = mapsTable[i]
		end
	else
		Cfg.ServerMaps[1] = newMap
		PainMenu.mapsOnServer[1] = newMap
	end

	Game.SetConfiguration(Cfg.AllowBrightskins,Cfg.GameMode,Cfg.FragLimit,Cfg.CaptureLimit,Cfg.LMSLives,Cfg.TeamDamage, Cfg.ClientConsoleLockdown)

	Console:Cmd_MAP(newMap)
end
--=======================================================================
function Console:CheckVotingParams(cmd,params)
	if cmd == "map" then
		name = string.lower(params)
		if string.sub(name,1,2) ~= "dm" and string.sub(name,1,3) ~= "ctf" and string.sub(name,1,4) ~= "race" then -- Race Additions [ THRESHER ]
			CONSOLE_AddMessage( "Bad map name '"..name.."'" )
			return false
		end

		local path = "../Data/Levels/"
		local files = FS.FindFiles(path.."*",0,1)
		local found = false
		for i=1,table.getn(files) do
			if string.lower(files[i]) == name then
				found = true
			end
		end

		if not found then
			CONSOLE_AddMessage( "Bad map name '"..name.."'" )
			return false
		end

		return true
	elseif cmd == "timelimit" or cmd == "fraglimit" or cmd == "maxplayers" or cmd == "maxspectators" or cmd == "bankickid" or cmd == "kickid" or cmd == "weaponrespawntime" or cmd == "capturelimit" or cmd == "lmslives" or cmd == "startupweapon" then
		local val = tonumber(params)
		if not val or type(val) ~= "number" then
			CONSOLE_AddMessage( "Wrong params for "..cmd )
			return false
		end
		return true
	elseif cmd == "kick" or cmd == "gamemode" or cmd == "bankick" then
		if params and type(params) == "string" then
			return true
		else
			CONSOLE_AddMessage( "Wrong params for "..cmd )
			return false
		end
	elseif cmd == "powerupdrop" or cmd == "powerups" or cmd == "weaponsstay" or cmd == "teamdamage"	or cmd == "allowbunnyhopping" or cmd == "allowbrightskins" or cmd == "allowforwardrj" then
		local val = tonumber(params)
		if val ~= 0 and val ~= 1 then
			CONSOLE_AddMessage( "Wrong params for "..cmd )
			return false
		end
		return true
	elseif cmd == "reloadmap" then
		return true
	elseif cmd == "proplus" then
		local val = tonumber(params)
		if val ~= 0 and val ~= 1 then
			CONSOLE_AddMessage( "Wrong params for "..cmd )
			return false
		end
		return true
	elseif cmd == "forcespec" then
		return true
	elseif cmd == "referee" then
		return true
	elseif cmd == "allready" then
		return true
	elseif cmd == "botskill" then
		local val = tonumber(params)
		if val ~= 0 and val ~= 1 and val ~= 2 and val ~= 3 and val ~= 4 and val ~= 5 and val ~= 6 and val ~= 7 and val ~= 8 and val ~= 9 and val ~= 10 then
			CONSOLE_AddMessage( "Wrong params for "..cmd )
			return false
		end
		return true
	elseif cmd == "addbot" then
		return true
	elseif cmd == "teamlock" then
		return true
	elseif cmd == "kickbot" then
		return true
	elseif cmd == "kickallbots" then
		return true
	elseif cmd == "restartmap" then
		return true
	elseif cmd == "saferespawn" then
		return true
	elseif cmd == "warmupdamage" then
		return true
	elseif cmd == "fallingdamage" then
		return true
	elseif cmd == "rocketfix" then
		return true
	end

	CONSOLE_AddMessage( "Command '"..cmd.."' cannot be used for voting" )
	return false
end
--=======================================================================
function Console:Cmd_CALLVOTE(params)
	if Game.GMode == GModes.SingleGame then return end
	if NET.IsSpectator(NET.GetClientID()) then return end
	if not params or params == "" then return end
	local i = string.find(params," ",1,true)
	if not i then i = string.len(params) + 1 end
	local cmd = string.sub(params,1,i-1)
	params = Trim( string.sub(params,i) )

	if not Console["Cmd_"..string.upper(cmd)] then
		CONSOLE_AddMessage("Unknown command: ".. cmd)
		return
	end

	if not self:CheckVotingParams(cmd,params) then
		return
	end

	local numPlayers = 0
	for i,o in Game.PlayerStats do
		numPlayers = numPlayers + 1
	end
	--	if numPlayers < 2 then
	--		CONSOLE_AddMessage( "Not enough players for voting" )
	--		return
	--	end

	if Game._voteCmd == "" then
		Game.StartVotingRequest(NET.GetClientID(),cmd,params)
	else
		CONSOLE_AddMessage("Please wait till current voting is over")
	end
end
--=======================================================================
function Console:Cmd_VOTE(yesno)
	if Game.GMode == GModes.SingleGame then return end
	if NET.IsSpectator(NET.GetClientID()) then
		CONSOLE_AddMessage( "Spectators cannot vote." )
		return
	end
	if not yesno or (yesno ~= "no" and yesno ~= "yes") then
		CONSOLE_AddMessage( "Usage: vote yes/no" )
		return
	end

	local val = 0
	if yesno == "yes" then val = 1 end

	if Game._voteCmd ~= "" then
		Game.PlayerVoteRequest(NET.GetClientID(),val)
	else
		CONSOLE_AddMessage( "No voting in progress" )
	end
end
--=======================================================================
function Console:Cmd_PLAYERS()
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end

	for i,o in Game.PlayerStats do
		CONSOLE_AddMessage( o.ClientID.."  "..o.Name )
	end
end
--=======================================================================
function Console:Cmd_NETSTATS(cmd)
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end

	if IsNewNetcode() then
		cmd = tonumber(cmd)
		if cmd == 0 then
			NET.SetStatsShow( false )
		else
			if cmd == 1 then
				NET.SetStatsShow( true )
			else
				CONSOLE_AddMessage( 'Params are 0 or 1' )
			end
		end
	else
		if cmd == nil then
			CONSOLE_AddMessage(NET.GetClientStats(255,true))
		else
			if cmd == 'overall' then
				CONSOLE_AddMessage(NET.GetClientStats(255,false))
			else
				if cmd == 'help' then
					CONSOLE_AddMessage( 'Usage:' )
					CONSOLE_AddMessage( ' netstats         - to get stats for last 5 seconds' )
					CONSOLE_AddMessage( ' netstats overall - to get stats for the whole connection' )
					CONSOLE_AddMessage( ' netstats help    - for this message' )
				end
			end
		end
	end
end
--=======================================================================
function Console:Cmd_NETSTATSAVGFROM(cmd)
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end

	if IsNewNetcode() then
		cmd = tonumber(cmd)
		if cmd == nil then
			CONSOLE_AddMessage( 'Usage: netstatsavgfrom (1-1023)' )
		else
			NET.SetStatsNrToAvg( cmd )
		end
	else
		CONSOLE_AddMessage( 'Command not available with old netcode' )
	end
end
--=======================================================================
function Console:Cmd_NETSTATSUPDATEDELAY(cmd)
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end

	if IsNewNetcode() then
		cmd = tonumber(cmd)
		if cmd == nil then
			CONSOLE_AddMessage( 'Usage: netstatsupdatedelay (1-65535)' )
			CONSOLE_AddMessage( '    ( the value to set is in miliseconds)' )
		else
			NET.SetStatsUpdateDelay( cmd )
		end
	else
		CONSOLE_AddMessage( 'Command not available with old netcode' )
	end
end
--=======================================================================
function Console:Cmd_SERVERFRAMERATE(cmd)

	cmd = tonumber(cmd)
	if cmd == nil then
		CONSOLE_AddMessage( 'Usage: serverframerate (1-1000)' )
		CONSOLE_AddMessage( '    ( the value to set is in frames per second)' )
		CONSOLE_AddMessage("Cfg.NetcodeServerFrameRate is currently "..tostring(Cfg.NetcodeServerFrameRate))
	else
		Cfg.NetcodeServerFrameRate = cmd
		NET.SetServerFramerate( Cfg.NetcodeServerFrameRate )
	end

end
--=======================================================================
function Console:Cmd_CLIENTBANDWIDTH(cmd)
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end

	if IsNewNetcode() then
		cmd = tonumber(cmd)
		if cmd == nil then
			CONSOLE_AddMessage( 'Usage: clientbandwidth <bytes-per-second>' )
			CONSOLE_AddMessage( '    ( sets upstream bandwidth limiter )' )
			CONSOLE_AddMessage( 'Current value: '..NET.GetClientBandwidth() )
		else
			NET.SetClientBandwidth( cmd )
		end
	else
		CONSOLE_AddMessage( 'Command not available with old netcode' )
	end
end
--=======================================================================
function Console:Cmd_ENEMYINTERPOLATION(cmd)
	if IsNewNetcode() then
		cmd = tonumber(cmd)
		if cmd == 0 then
			Cfg.NetcodeEnemyPredictionInterpolation = false
			NET.SetEnemyPredictionInterpolation( Cfg.NetcodeEnemyPredictionInterpolation )
		else
			if cmd == 1 then
				Cfg.NetcodeEnemyPredictionInterpolation = true
				NET.SetEnemyPredictionInterpolation( Cfg.NetcodeEnemyPredictionInterpolation )
			else
				CONSOLE_AddMessage( 'Usage: enemyinterpolation 0/1' )
				CONSOLE_AddMessage( '    ( interpolates between last two enemy positions )' )
				CONSOLE_AddMessage("NetcodeEnemyPredictionInterpolation is currently "..tostring(Cfg.NetcodeEnemyPredictionInterpolation))
			end
		end
	else
		CONSOLE_AddMessage( 'Command not available with old netcode' )
	end
end
--=======================================================================
function Console:Cmd_DISCONNECT()
	if Game.GMode == GModes.SingleGame or Game:IsServer() then
		CONSOLE_AddMessage( 'Command not available in Single Player or Server mode' )
		return
	end
	NET.Disconnect()
	Game:NewLevel('NoName','','',0.3); WORLD.Release()
	Game.GameInProgress = false
	Game.LevelStarted = false
	PMENU.ShowMenu()
	PainMenu:BackToLastScreen()
end
--=======================================================================
function Console:Cmd_RECONNECT()
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end
	PMENU.Activate(false)
	local res = PMENU.JoinServer( PainMenu.playerName, PainMenu.passwd, PainMenu.speed, PainMenu.host, PainMenu.port, PainMenu.public, PainMenu.spectator )
	if res == false then
		Game:Print( "Cannot join server "..self.host )
		PainMenu:ShowInfo( "Cannot connect to server "..self.host, "PainMenu:BackToLastScreen()" )
	end
end
--=======================================================================
function Console:Cmd_SAY(txt)
	if not txt then return end
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end
	Game.SayToAll(NET.GetClientID(), txt)
end
--=======================================================================
function Console:Cmd_TEAMSAY(txt)
	if not txt then return end
	if Game.GMode == GModes.SingleGame then
		CONSOLE_AddMessage( 'Command not available in Single Player mode' )
		return
	end
	Game.SayToTeam(NET.GetClientID(), txt)
end
--=======================================================================
-- TIMEDEMO
--=======================================================================
function Console:Cmd_BENCHMARK(name)
	if name == nil then
		CONSOLE_AddMessage('benchmark "name"')
	else
		if not Game:IsServer() then
			Game:LoadLevel(name.."_Benchmark")
			Game:OnPlay(true)
			CONSOLE.Activate(false)
		end
	end
end
--=======================================================================
-- CHEATS
--=======================================================================
-- pkammo [gives full ammo]
function Console:Cmd_PKAMMO()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Player then
		Player.Ammo = Clone(CPlayer.s_SubClass.Ammo)
		CONSOLE_AddMessage(TXT.Cheats.PKAmmo)
	end
end
--=======================================================================
-- pkweapons [gives all weapons]
function Console:Cmd_PKWEAPONS()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Player then
		Player.EnabledWeapons = Clone(CPlayer.EnabledWeapons)
		Player.Ammo = Clone(CPlayer.s_SubClass.Ammo)
		CONSOLE_AddMessage(TXT.Cheats.PKWeapons)
	end
end
--=======================================================================
-- pkhealth [current armor regenerates, if health < 100 then health = 100]
function Console:Cmd_PKHEALTH()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Player then
		if Player.Health < Game.HealthCapacity then
			Player.Health = Game.HealthCapacity
		end

		local t = nil
		local atype = Player.ArmorType
		if atype == ArmorTypes.Weak then t = Templates["ArmorWeak.CItem"] end
		if atype == ArmorTypes.Medium then t = Templates["ArmorMedium.CItem"]  end
		if atype == ArmorTypes.Strong then t = Templates["ArmorStrong.CItem"]  end

		if t then Player.Armor = t.ArmorAdd end

		CONSOLE_AddMessage(TXT.Cheats.PKHealth)
	end
end
--=======================================================================
-- pkpower [pkammo + pkhealth together]
function Console:Cmd_PKPOWER()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	self:Cmd_PKAMMO()
	self:Cmd_PKHEALTH()
end
--=======================================================================
-- pkgod [monsters can't hurt you - on/off toggle]
function Console:Cmd_PKGOD()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if GOD == true then
		GOD = false
		CONSOLE_AddMessage(TXT.Cheats.PKGodOff)
	else
		GOD = true
		CONSOLE_AddMessage(TXT.Cheats.PKGodOn)
	end
end
--=======================================================================
-- pkalwaysgib [always gib the enemy - on/off toggle]
function Console:Cmd_PKALWAYSGIB()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end

	if not Game.Cheat_AlwaysGib then
		Game.Cheat_AlwaysGib = true
		CONSOLE_AddMessage(TXT.Cheats.PKGibOn)
	else
		Game.Cheat_AlwaysGib = false
		CONSOLE_AddMessage(TXT.Cheats.PKGibOff)
	end
end
--=======================================================================
-- pkweakenemies [all monsters have 1 HP - on/off toggle]
function Console:Cmd_PKWEAKENEMIES()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end

	if not Game.Cheat_WeakEnemies then
		Game.Cheat_WeakEnemies = true
		CONSOLE_AddMessage(TXT.Cheats.PKWeakOn)
	else
		Game.Cheat_WeakEnemies = false
		CONSOLE_AddMessage(TXT.Cheats.PKWeakOff)
	end
end
--=======================================================================
-- pkcards [unlimited Golden Cards use]
function Console:Cmd_PKCARDS()
	if IsFinalBuild() then return end
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	Game.GoldenCardsUseUnlimited = true
	CONSOLE_AddMessage(TXT.Cheats.PKCards)
end
--=======================================================================
-- pkgold [99999 gold]
function Console:Cmd_PKGOLD()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Game then Game.PlayerMoney = 99999 end
	MBOARD.SetCashCheat(99999)
	CONSOLE_AddMessage(TXT.Cheats.PKGold)
end
--=======================================================================
-- pkhaste [Haste x 8 - on/off toggle]
function Console:Cmd_PKHASTE()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end

	if Game.BulletTime == true then
		Game:EnableBulletTime(false)
		CONSOLE_AddMessage(TXT.Cheats.PKHasteOff)
	else
		local slow = Game.BulletTimeSlowdown
		Game.BulletTimeSlowdown = 1/8
		Game:EnableBulletTime(true)
		Game.BulletTimeSlowdown = slow
		CONSOLE_AddMessage(TXT.Cheats.PKHasteOn)
	end
end
--=======================================================================
-- pkdemon [Demon Morph - on/off toggle]
function Console:Cmd_PKDEMON()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Game.IsDemon then
		Game:EnableDemon(false)
		CONSOLE_AddMessage(TXT.Cheats.PKDemonOff)
	else
		Game:EnableDemon(true)
		CONSOLE_AddMessage(TXT.Cheats.PKDemonOn)
	end
end
--=======================================================================
-- pkweaponmodifier [enables weapon modifier]
function Console:Cmd_PKWEAPONMODIFIER()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Player then
		if Player.HasWeaponModifier == false then
			Player.HasWeaponModifier = true
			Player._WeaponModifierCounter = 9999999
			CONSOLE_AddMessage(TXT.Cheats.PKWeapModOn)
		else
			Player.HasWeaponModifier = false
			Player._WeaponModifierCounter = 0
			CONSOLE_AddMessage(TXT.Cheats.PKWeapModOff)
		end
	end
end
--=======================================================================
-- pkalllevels [enables all levels]
--function Console:Cmd_PKALLLEVELS()
--	if IsFinalBuild() then return end
--	if Game.GMode ~= GModes.SingleGame then return end
--	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
--	for i=1,table.getn(Levels) do
--		for j=1,table.getn(Levels[i]) do
--			Game:MakeEmptyLevelStats(Levels[i][j][1])
--			Game.LevelsStats[Levels[i][j][1]].Finished = true
--		end
--	end
--	CONSOLE_AddMessage(TXT.Cheats.PKAllLevels)
--	PMENU.SwitchToMenu()
--	PMENU.SwitchToMap()
--end
--=======================================================================
-- pkallcards [gives all black tarot cards]
--function Console:Cmd_PKALLCARDS()
--	if IsFinalBuild() then return end
--	if Game.GMode ~= GModes.SingleGame then return end
--	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
--	for i=1,table.getn(Game.CardsAvailable) do
--		Game.CardsAvailable[i] = true
--	end
--	Game.CardsAvailable[23] = false
--	Game.CardsAvailable[32] = false
--	CONSOLE_AddMessage(TXT.Cheats.PKAllCards)
--	PMENU.SwitchToMap()
--	PMENU.SwitchToBoard()
--end
--=======================================================================
-- pkkeepbodies [bodies never disappear - on/off toggle]
function Console:Cmd_PKKEEPBODIES()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Game.Cheat_KeepBodies then
		Game.Cheat_KeepBodies = false
		CONSOLE_AddMessage(TXT.Cheats.PKKeepBodiesOff)
	else
		Game.Cheat_KeepBodies = true
		CONSOLE_AddMessage(TXT.Cheats.PKKeepBodiesOn)
	end
end
--=======================================================================
-- pkkeepdecals [decals never wear off - on/off toggle]
function Console:Cmd_PKKEEPDECALS()
	if Game.GMode ~= GModes.SingleGame then return end
	if Game.Difficulty > 1 then CONSOLE_AddMessage(TXT.Cheats.LowLevelOnly); return end
	if Game.Cheat_KeepDecals then
		Game.Cheat_KeepDecals = false
		CONSOLE_AddMessage(TXT.Cheats.PKKeepDecalsOff)
	else
		Game.Cheat_KeepDecals = true
		CONSOLE_AddMessage(TXT.Cheats.PKKeepDecalsOn)
	end

	R3D.KeepDecals(Game.Cheat_KeepDecals)
end
--=======================================================================
-- pkperfect [finish level with perfect score]
--[[
function Console:Cmd_PKPERFECT()
	if IsFinalBuild() then return end
	if Game.GMode ~= GModes.SingleGame then return end
	Player.ArmorFound = Game.TotalArmor
	Player.HolyItems = Game.TotalHolyItems
	Game.PlayerAmmoFound = Game.TotalAmmo
	Game.PlayerDestroyedItems = Game.TotalDestroyed
	Player.SecretsFound = Game.TotalSecrets
	GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
end
]]--
--=======================================================================
-- MP Server
--=======================================================================
--asd = 1
function Console:Cmd_SERVER(name)

	if IsFinalBuild() then return end
	if name == nil then
		CONSOLE_AddMessage('server map_name')
	else
		if PMENU.StartServer( Cfg.PlayerName, "", name, 1, 3455 ) then
			NET.LoadMapOnServer(name)
		end
	end
	CONSOLE_AddMessage("server started on map:  "..Lev._Name)

	--CONSOLE_AddMessage(asd)
	--Game:Print(asd)
	--asd = asd +1
end
--=======================================================================
function Console:Cmd_CONNECT(ip)
	--  if IsFinalBuild() then return end
	if ip == nil then
		CONSOLE_AddMessage('connect ip:port')
	else
		local host = nil
		local port = nil

		for h,p in string.gfind( ip, "(.+):(.+)" ) do
			host = h
			port = p
		end

		if host == nil and port == nil then
			host = ip
			port = 3455
		end

		if host ~= nil and port ~= nil then
			PMENU.Activate(false)
			PMENU.JoinServer( Cfg["PlayerName"], "", 1, host, port, true )
			CONSOLE.Activate( false )
		end
	end
end
--=======================================================================
function Console:Cmd_CONNECTPKTV(arguments)
	if IsFinalBuild() then return end
	if arguments == nil then
		CONSOLE.AddMessage('connect <ip[:port]> [password]')
	else
		PMENU.Activate(false)
		PMENU.JoinPKTV( arguments )
		CONSOLE.Activate( false )
	end
end
--=======================================================================
-- MOUSE
--=======================================================================
function Console:Cmd_MSENSITIVITY(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('msensitivity value  (sets mouse sensitivity)')
	elseif type(val) == "number" then
		if val < 201 and val >= 0 then
			Cfg.MouseSensitivity = val
			MOUSE.SetSensitivity(Cfg.MouseSensitivity)
		end
	end

	CONSOLE_AddMessage("current mouse sensitivity:  "..Cfg.MouseSensitivity)
end
--=======================================================================
function Console:Cmd_SENSITIVITY(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('msensitivity value  (sets mouse sensitivity)')
	elseif type(val) == "number" then
		if val < 201 and val >= 0 then
			Cfg.MouseSensitivity = val
			MOUSE.SetSensitivity(Cfg.MouseSensitivity)
		end
	end

	CONSOLE_AddMessage("current mouse sensitivity:  "..Cfg.MouseSensitivity)
end
--=======================================================================
function Console:Cmd_MSMOOTH(enable)
	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage('msmooth value  (enables smooth mouse)')
	end

	if enable == 1 then  Cfg.SmoothMouse = true  end
	if enable == 0 then  Cfg.SmoothMouse = false end

	MOUSE.SetSmooth(Cfg.SmoothMouse)

	if Cfg.SmoothMouse then
		CONSOLE_AddMessage("smooth mouse is enabled")
	else
		CONSOLE_AddMessage("smooth mouse is disabled")
	end
end
--=======================================================================
function Console:Cmd_FOV(val)

	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage("fov value  (sets camera's FOV)")
	elseif type(val) == "number" then
		Cfg.FOV = val
		PainMenu.cameraFOV = val
	end

	R3D.SetCameraFOV(Cfg.FOV)

	CONSOLE_AddMessage("current fov:  "..Cfg.FOV)
end
--=======================================================================
function Console:Cmd_CAMERAINTERPOLATION(enable)
	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("camerainterpolation 0/1  (disables/enables camera interpolation for MP clients)")
	end

	if enable == 1 then Cfg.CameraInterpolation = true  end
	if enable == 0 then Cfg.CameraInterpolation = false end

	CAM.EnableInterpolation(Cfg.CameraInterpolation)

	if Cfg.CameraInterpolation then
		CONSOLE_AddMessage("camera interpolation is enabled")
	else
		CONSOLE_AddMessage("camera interpolation is disabled")
	end
end
--=======================================================================
function Console:Cmd_EXIT()
	--	PMENU.Activate( true )
	--	PainMenu:ActivateScreen(DemoEnd)
	Exit()
end
--=======================================================================
function Console:Cmd_QUIT()
	--	PMENU.Activate( true )
	--	PainMenu:ActivateScreen(DemoEnd)
	Exit()
end
--=======================================================================
function Console:Cmd_TPP(enable,view)
	if IsFinalBuild() then return end
	enable = tonumber(enable)
	view = tonumber(view)

	if enable == nil then
		CONSOLE_AddMessage("third person view [1/0]")
	end

	if enable == 1 then Game.TPP = true end
	if enable == 0 then Game.TPP = false end
	if view == 1 then Game.TPPView = true end
	if view == 0 then Game.TPPView = false end

	if Player and Player._Entity then ENTITY.EnableDraw(Player._Entity,Game.TPP) end

	if Game.TPP then
		CONSOLE_AddMessage("current state: on")
	else
		CONSOLE_AddMessage("current state: off")
	end
end
--=======================================================================
function Console:Cmd_TIMELIMIT(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('timelimit value  (sets time limit)')
	elseif type(val) == "number" then
		Cfg.TimeLimit = val
		if Game:IsServer() then
			Game.SetTimeLimit(Cfg.TimeLimit,Game._TimeLimitOut, Game._countTimer)
		end
	end

	CONSOLE_AddMessage("current time limit:  "..Cfg.TimeLimit)
end
--=======================================================================
function Console:Cmd_FRAGLIMIT(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('fraglimit value  (sets frag limit)')
	elseif type(val) == "number" then
		Cfg.FragLimit = val
		if Game:IsServer() then
			Game.SetConfiguration(Cfg.AllowBrightskins,Cfg.GameMode,Cfg.FragLimit,Cfg.CaptureLimit,Cfg.LMSLives,Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
		end
	end

	CONSOLE_AddMessage("current frag limit:  "..Cfg.FragLimit)
end
--=======================================================================
function Console:Cmd_CAPTURELIMIT(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('capturelimit value  (sets flag capture limit)')
	elseif type(val) == "number" then
		Cfg.CaptureLimit = val
		if Game:IsServer() then
			Game.SetConfiguration(Cfg.AllowBrightskins,Cfg.GameMode,Cfg.FragLimit,Cfg.CaptureLimit,Cfg.LMSLives,Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
		end
	end

	CONSOLE_AddMessage("current capture limit:  "..Cfg.CaptureLimit)
end
--=======================================================================
function Console:Cmd_LMSLIVES(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('lmslives value  (sets number of lives in LMS mode)')
	elseif type(val) == "number" then
		Cfg.LMSLives = val
		if Game:IsServer() then
			Game.SetConfiguration(Cfg.AllowBrightskins,Cfg.GameMode,Cfg.FragLimit,Cfg.CaptureLimit,Cfg.LMSLives,Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
		end
	end

	CONSOLE_AddMessage("current LMS lives:  "..Cfg.LMSLives)
end
--=======================================================================
function Console:Cmd_WEAPONRESPAWNTIME(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('weaponrespawntime value  (sets weapon respawn time)')
	elseif type(val) == "number" then
		Cfg.WeaponRespawnTime = val
	end

	CONSOLE_AddMessage("current weapon respawn time:  "..Cfg.WeaponRespawnTime)
end
--=======================================================================
function Console:Cmd_CROSSHAIR(val)
	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage('crosshair value [1-32] (changes crosshair)')
	elseif type(val) == "number" then
		if val <= 32 and val > 0 then
			Cfg.Crosshair = val
		end
	end

	CONSOLE_AddMessage("current crosshair:  "..Cfg.Crosshair)
end
--=======================================================================
function Console:Cmd_HUDSIZE(val)

	val = tonumber(val)
	if val == nil then
		CONSOLE_AddMessage("hudsize value  (sets HUD size)")
	elseif type(val) == "number" then
		if val > 3.0 then
			Cfg.HUDSize = 3.0
		elseif val <= 0 then
			Cfg.HUDSize = 0.1
		else
			Cfg.HUDSize = val
		end
	end

	CONSOLE_AddMessage("current HUD size:  "..Cfg.HUDSize)
end
--=======================================================================
function Console:Cmd_SPEEDMETER(enable)
	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("shows speed meter [1/0]")
	end

	if enable == 1 then Tweak.PlayerMove.ShowSpeedmeter = true  end
	if enable == 0 then Tweak.PlayerMove.ShowSpeedmeter = false end

	if Tweak.PlayerMove.ShowSpeedmeter then
		CONSOLE_AddMessage("current state: on")
	else
		CONSOLE_AddMessage("current state: off")
	end
end
--=======================================================================
function Console:Cmd_NAME(name)
	if name == nil then
		CONSOLE_AddMessage('name "nick" (changes player name)')
	else
		Cfg.PlayerName = HUD.ColorSubstr(tostring(name),16)
		Cfg.PlayerName = string.gsub(Cfg.PlayerName, "$KILLER", "KILLER")
		Cfg.PlayerName = string.gsub(Cfg.PlayerName, "$PLAYER", "PLAYER")
		if Player and Game.GMode ~= GModes.SingleGame then
			Game.NewPlayerNameRequest(Player.ClientID,Cfg.PlayerName)
		end
	end

	if Game.GMode == GModes.SingleGame and CONSOLE.IsActive() then
		CONSOLE_AddMessage("current player name:  "..Cfg.PlayerName)
	end
end
--=======================================================================
function Console:Cmd_POS(x,y,z)
	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)
	if x then GX = x end
	if y then GY = y end
	if z then GZ = z end
	CONSOLE_AddMessage(GX.." "..GY.." "..GZ)
end
--=======================================================================
function Console:Cmd_ROT(x,y,z)
	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)
	if x then GAX = x end
	if y then GAY = y end
	if z then GAZ = z end
	CONSOLE_AddMessage(GAX.." "..GAY.." "..GAZ)
end
--=======================================================================
function Console:Cmd_WEAPONSPECULAR(enable)
	enable = tonumber(enable)
	if enable == nil then
		CONSOLE_AddMessage("enables weapon specular [1/0]")
	end
	if enable == 1 then Cfg.WeaponSpecular = true end
	if enable == 0 then Cfg.WeaponSpecular = false end
	PainMenu:ReloadWeaponsTextures()
end
--=======================================================================
function Console:Cmd_DEMOPLAY(filename)
	if filename == nil then
		CONSOLE_AddMessage("Usage: demoplay <filename_to_play_from>")
	else
		CONSOLE.DemoPlay(filename)
	end
end
--=======================================================================
function Console:Cmd_TIMEDEMO(filename)
	if filename == nil then
		CONSOLE_AddMessage("Usage: timedemo <filename_to_play_from>")
	else
		--        NET.DemoPlay(filename)
		CONSOLE.DemoPlay(filename,true)
	end
end
--=======================================================================
function Console:Cmd_DEMOPLAYBMP(filename)
	if filename == nil then
		CONSOLE_AddMessage("Usage: demoplaytga <filename_to_play_from>")
	else
		--        NET.DemoPlay(filename)
		CONSOLE.DemoPlay(filename,true,true)
	end
end
--=======================================================================
function Console:Cmd_TIMESCALE(speed)
	if speed then
		INP.SetTimeMultiplier(tonumber(speed))
		WORLD.SetWorldSpeed(tonumber(speed))
		CONSOLE_AddMessage("World speed now x "..tonumber(INP.GetTimeMultiplier()))
	else
		CONSOLE_AddMessage("World speed currently x "..tonumber(INP.GetTimeMultiplier()))
	end
end
--============================================================================
function Console:Cmd_DEMORECORD(filename)
	if filename == nil then
		CONSOLE_AddMessage("Usage: demorecord <filename_to_record_in>")
	else
		--        NET.DemoRecord(filename)
		CONSOLE.DemoRecord(filename)
		CONSOLE_AddMessage("Demo recording scheduled")
	end
end
--============================================================================
function Console:Cmd_RECORDDEMO(filename)
	if filename == nil then
		CONSOLE_AddMessage("Usage: recorddemo <filename_to_record_in>")
	else

		CONSOLE.DemoRecord(filename)
		CONSOLE_AddMessage("Demo recording scheduled")
	end
end
--=======================================================================
function Console:Cmd_DEMOSTOP()
	CONSOLE.DemoStop()
	CONSOLE_AddMessage("Demo stopped")
end
--=======================================================================
function Console:Cmd_SHOWFPS(show)
	show = tonumber(show)
	if show == nil then
		CONSOLE_AddMessage("enables FPS display [1/0]")
		return
	end

	if show == 1 then
		Hud._showFPS = true
		Cfg.ShowFPS = true
	end
	if show == 0 then
		Hud._showFPS = false
		Cfg.ShowFPS = false
	end
end
--=======================================================================
function Console:Cmd_SHOWTIMER(show)
	show = tonumber(show)
	if show == nil then
		CONSOLE_AddMessage("enables timer display [1/0]")
		return
	end

	if show == 1 then
		Hud._showTimer = true
		Cfg.ShowTimer = true
	end
	if show == 0 then
		Hud._showTimer = false
		Cfg.ShowTimer = false
	end
end
--=======================================================================
function Console:Cmd_SHOWTIMERCOUNTUP(show)
	show = tonumber(show)
	if show == nil then
		CONSOLE_AddMessage("enables timer display [1/0]")
		return
	end

	if show == 1 then
		Cfg.ShowTimerCountUp = true
	end
	if show == 0 then
		Cfg.ShowTimerCountUp = false
	end
end
--=======================================================================
function Console:OnCommand(cmd)
	local exist = false
	cmd = Trim(cmd)
	if cmd == "" then return end
	local is_cmd = false
	if IsDedicatedServer() then is_cmd = true end
	if string.find(cmd,"\\",1,true) == 1 or string.find(cmd,"/",1,true) == 1 or string.find(cmd,".",1,true) == 1 then
		cmd = string.sub(cmd,2)
		is_cmd = true
	end
	local i = string.find(cmd," ",1,true)
	if not i then i = string.len(cmd) + 1 end
	if i > 2 and is_cmd == true then
		local func = string.upper(string.sub(cmd,1,i-1))
		for commandname,o in self do
			if type(o) == "function" then
				if string.lower("Cmd_"..func) == string.lower(commandname) then
					if Game.GMode == GModes.MultiplayerClient and MPCfg.ClientConsoleLockdown then CONSOLE_AddMessage("Console is locked!") return end
					local params = string.sub(cmd,i+1)
					local semicolon = string.find(params,";")
					if semicolon and func ~= "BIND" then
						local part = string.sub(params,1,semicolon)
						local second = string.sub(params,semicolon+1)
						params = string.sub(params,1,semicolon-1)
						Console:OnCommand(func.." "..params)
						Console:OnCommand(second)
						return
					end
					local args = {}
					params = Trim(params)
					for w in string.gfind(params, "[%w~`!@#$%%^&*()%-\" _=%.%+\\|{}%[%]<>?/]+") do
						table.insert(args,w)
					end
					if func ~= "CALLVOTE" and func ~= "BIND" then
						Console[commandname](self,unpack(args))
					else
						Console[commandname](self,params)
					end
					Cfg:Save()
					return
				end
			end
		end
		for settingname,o in Cfg do
			if type(o) ~= "function" then
				if string.lower(func) == string.lower(settingname) then
					if Game.GMode == GModes.MultiplayerClient and MPCfg.ClientConsoleLockdown then CONSOLE_AddMessage("Console is locked!") return end
					local params = string.sub(cmd,i+1)
					local semicolon = string.find(params,";")
					if semicolon and func ~= "BIND" then
						local part = string.sub(params,1,semicolon)
						local second = string.sub(params,semicolon+1)
						params = string.sub(params,1,semicolon-1)
						Console:OnCommand(func.." "..params)
						Console:OnCommand(second)
						return
					end
					local args = {}
					params = Trim(params)
					for w in string.gfind(params, "[%w~`!@#$%%^&*()%-\" _=%.%+\\|{}%[%]<>?/]+") do
						table.insert(args,w)
					end
					if func ~= "CALLVOTE" and func ~= "BIND" then
						local setting = unpack(args)
						if setting ~= nil then
							if setting == "false" then setting = false end
							if setting == "true" then setting = true end
							Cfg[settingname] = setting
							Cfg:Check()
							CONSOLE_AddMessage(settingname.." is now "..tostring(Cfg[settingname]))
						else
							Cfg:Check()
							CONSOLE_AddMessage(settingname.." is currently "..tostring(Cfg[settingname]))
						end
					else
						Cfg[settingname] = params
						Cfg:Check()
						CONSOLE_AddMessage(settingname.." is now "..Cfg[settingname])
					end
					Cfg:Save()
					return
				end
			end
		end
	end
	if is_cmd == true then
		if IsDedicatedServer() then
			Console:OnPrompt(cmd)
		else
			-- TRYING SETTINGS
			CONSOLE_AddMessage("Unknown command: ".. cmd)
		end
	else
		cmd = string.sub(cmd,1,200)
		Game.SayToAll(NET.GetClientID(), cmd)
	end
	Cfg:Check()
end
--=======================================================================
function Console:OnPrompt(txt)
	-- 04.10.2004 [Blowfish] modification
	txt = Trim(txt)
	if txt == "" then return end
	if string.find(txt,"\\",1,true) == 1 or string.find(txt,"/",1,true) == 1 or string.find(txt,".",1,true) == 1 then
		txt = string.sub(txt,2)
	end
	txt = string.upper(txt)
	local commandlist = {}
	-- searching similary commands
	for a,o in self do
		if type(o) == "function" then
			local i = string.find(string.lower(a),string.lower("Cmd_"),1,true)
			if i and string.find(string.lower(a),string.lower(txt),5,true) == 5 then
				table.insert(commandlist,string.lower(string.sub(a,5)))
			end
		end
	end

	for a,o in Cfg do
		if type(o) ~= "function" then
			if string.find(string.lower(a),string.lower(txt),1,true) == 1 then
				table.insert(commandlist,a)
			end
		end
	end

	if table.getn(commandlist) > 1 then
		local commonPart = commandlist[1]
		CONSOLE_AddMessage(">"..string.lower(txt))
		table.sort(commandlist,function (a,b) return string.lower(a) < string.lower(b) end)
		for i,o in commandlist do
			CONSOLE_AddMessage("    "..o)
			for j=1, string.len(commonPart) do
				if string.lower(string.sub(commonPart,j,j)) ~= string.lower(string.sub(o,j,j)) then
					commonPart = string.sub(commonPart,1,j-1)
					break
				end
			end
		end
		txt = commonPart
	else
		if table.getn(commandlist) == 1 then
			txt = commandlist[1] .. " "
		end
	end
	CONSOLE.SetCurrentText("\\"..string.lower(txt))
end
--======================================================================

function Console:Cmd_LIST()
	local ents = WORLD.GetEntityList(ETypes.Mesh)
	local Mesh = 0
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Mesh "..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Mesh ".."nil")
			--WORLD.RemoveEntity(i)
		end
		Mesh = Mesh + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Model = 0
	local ents = WORLD.GetEntityList(ETypes.Model)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Model "..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Model "..ENTITY.GetFileName(entity))
			--WORLD.RemoveEntity(i)
			--ENTITY.Release(i)
		end
		Model = Model + 1
	end
	local Particle = 0
	local ents = WORLD.GetEntityList(ETypes.Particle)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Particle ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Particle "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Particle = Particle + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Trail = 0
	local ents = WORLD.GetEntityList(ETypes.Trail)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Trail ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Trail "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Trail = Trail + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Sound = 0
	local ents = WORLD.GetEntityList(ETypes.Sound)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Sound ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Sound "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Sound = Sound + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Region = 0
	local ents = WORLD.GetEntityList(ETypes.Region)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Region ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Region "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Region = Region + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Billboard = 0
	local ents = WORLD.GetEntityList(ETypes.Billboard)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Billboard ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Billboard "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Billboard = Billboard + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Environment = 0
	local ents = WORLD.GetEntityList(ETypes.Environment)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Environment ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Environment "..ENTITY.GetFileName(entity))
		end
		Environment = Environment + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Light = 0
	local ents = WORLD.GetEntityList(ETypes.Light)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Light ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Light "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Light = Light + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local ParticleFX = 0
	local ents = WORLD.GetEntityList(ETypes.ParticleFX)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.ParticleFX ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.ParticleFX "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		ParticleFX = ParticleFX + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Decal = 0
	local ents = WORLD.GetEntityList(ETypes.Decal)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Decal ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Decal "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Decal = Decal + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local total = 0
	CONSOLE_AddMessage(Environment.." Environment")
	total = total + Environment
	CONSOLE_AddMessage(Light.." Light")
	total = total + Light
	CONSOLE_AddMessage(Region.." Region")
	total = total + Region
	CONSOLE_AddMessage(Sound.." Sound")
	total = total + Sound
	CONSOLE_AddMessage(Model.." Model")
	total = total + Model
	CONSOLE_AddMessage(Trail.." Trail")
	total = total + Trail
	CONSOLE_AddMessage(Mesh.." Mesh")
	total = total + Mesh
	CONSOLE_AddMessage(Particle.." Particle")
	total = total + Particle
	CONSOLE_AddMessage(ParticleFX.." ParticleFX")
	total = total + ParticleFX
	CONSOLE_AddMessage(Decal.." Decal")
	total = total + Decal
	CONSOLE_AddMessage(total.." entities in total")
end

function Console:Cmd_LISTMESHES()
	local ents = WORLD.GetEntityList(ETypes.Mesh)
	local Mesh = 0
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Mesh "..obj._Name)
		else
			if ENTITY.GetFileName(i) ~= "" then CONSOLE_AddMessage("ETypes.Mesh "..ENTITY.GetFileName(i)) end
			--WORLD.RemoveEntity(i)
		end
		Mesh = Mesh + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
end

function Console:Cmd_LISTMODELS()
	local Model = 0
	local ents = WORLD.GetEntityList(ETypes.Model)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Model "..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Model "..ENTITY.GetFileName(i))
			--WORLD.RemoveEntity(i)
			--ENTITY.Release(i)
		end
		Model = Model + 1
	end
end

function Console:Cmd_LISTPARTICLES()
	local Particle = 0
	local ents = WORLD.GetEntityList(ETypes.Particle)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Particle ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Particle "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Particle = Particle + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
end

function Console:Cmd_LISTTRAILS()
	local Trail = 0
	local ents = WORLD.GetEntityList(ETypes.Trail)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Trail ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Trail "..ENTITY.GetFileName(i))
			WORLD.RemoveEntity(i)
		end
		Trail = Trail + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
end

function Console:Cmd_LIST()
	local ents = WORLD.GetEntityList(ETypes.Mesh)
	local Mesh = 0
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Mesh "..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Mesh ".."nil")
			--WORLD.RemoveEntity(i)
		end
		Mesh = Mesh + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Model = 0
	local ents = WORLD.GetEntityList(ETypes.Model)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Model "..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Model "..ENTITY.GetFileName(entity))
			--WORLD.RemoveEntity(i)
			--ENTITY.Release(i)
		end
		Model = Model + 1
	end
	local Particle = 0
	local ents = WORLD.GetEntityList(ETypes.Particle)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Particle ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Particle "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Particle = Particle + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Trail = 0
	local ents = WORLD.GetEntityList(ETypes.Trail)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Trail ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Trail "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Trail = Trail + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Sound = 0
	local ents = WORLD.GetEntityList(ETypes.Sound)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Sound ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Sound "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Sound = Sound + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Region = 0
	local ents = WORLD.GetEntityList(ETypes.Region)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Region ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Region "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Region = Region + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Billboard = 0
	local ents = WORLD.GetEntityList(ETypes.Billboard)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Billboard ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Billboard "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Billboard = Billboard + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Environment = 0
	local ents = WORLD.GetEntityList(ETypes.Environment)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Environment ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Environment "..ENTITY.GetFileName(entity))
		end
		Environment = Environment + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Light = 0
	local ents = WORLD.GetEntityList(ETypes.Light)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Light ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Light "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Light = Light + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local ParticleFX = 0
	local ents = WORLD.GetEntityList(ETypes.ParticleFX)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.ParticleFX ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.ParticleFX "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		ParticleFX = ParticleFX + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local Decal = 0
	local ents = WORLD.GetEntityList(ETypes.Decal)
	for i,v in ents do
		local obj = EntityToObject[i]
		if obj~=nil then
			CONSOLE_AddMessage("ETypes.Decal ".."OBJECT"..obj._Name)
		else
			CONSOLE_AddMessage("ETypes.Decal "..ENTITY.GetFileName(entity))
			WORLD.RemoveEntity(i)
		end
		Decal = Decal + 1
		--ENTITY.EnableNetworkSynchronization(i,false,false)
	end
	local total = 0
	CONSOLE_AddMessage(Environment.." Environment")
	total = total + Environment
	CONSOLE_AddMessage(Light.." Light")
	total = total + Light
	CONSOLE_AddMessage(Region.." Region")
	total = total + Region
	CONSOLE_AddMessage(Sound.." Sound")
	total = total + Sound
	CONSOLE_AddMessage(Model.." Model")
	total = total + Model
	CONSOLE_AddMessage(Trail.." Trail")
	total = total + Trail
	CONSOLE_AddMessage(Mesh.." Mesh")
	total = total + Mesh
	CONSOLE_AddMessage(Particle.." Particle")
	total = total + Particle
	CONSOLE_AddMessage(ParticleFX.." ParticleFX")
	total = total + ParticleFX
	CONSOLE_AddMessage(Decal.." Decal")
	total = total + Decal
	CONSOLE_AddMessage(total.." entities in total")
end
--============================================================================
function Console:Cmd_SCAN()
	for i,v in GObjects.TickListItems do
		CONSOLE_AddMessage(tostring(i).." ".."TickListItems: "..v._Name.." "..v._Class)
	end
	CONSOLE_AddMessage("------------------------------------------")
	for i,v in GObjects.TickListActors do
		CONSOLE_AddMessage(tostring(i).." ".."TickListActors: "..v._Name.." "..v._Class)
	end
	CONSOLE_AddMessage("------------------------------------------")
	for i,v in GObjects.TickListRest do
		CONSOLE_AddMessage(tostring(i).." ".."TickListRest: "..v._Name.." "..v._Class)
	end
	CONSOLE_AddMessage("------------------------------------------")
	for i,v in GObjects.UpdateListActors do
		CONSOLE_AddMessage(tostring(i).." ".."UpdateListActors: "..v._Name.." "..v._Class)
	end
	CONSOLE_AddMessage("------------------------------------------")
	for i,v in GObjects.UpdateListItems do
		CONSOLE_AddMessage(tostring(i).." ".."UpdateListItems: "..v._Name.." "..v._Class)
	end
	CONSOLE_AddMessage("------------------------------------------")
	for i,v in GObjects.UpdateListRest do
		CONSOLE_AddMessage(tostring(i).." ".."UpdateListRest: "..v._Name.." "..v._Class)
	end
	CONSOLE_AddMessage("------------------------------------------")
	for i,v in GObjects.SynchronizeList do
		CONSOLE_AddMessage(tostring(i).." ".."SynchronizeList: "..v._Name.." "..v._Class)
	end
end


function Console:Cmd_SCAN2()
	local list = ""
	for i,v in GObjects.TickListItems do
		list = list .. v._Name.." "..v._Class + ", "
	end
	for i,v in GObjects.TickListActors do
		list = list .. v._Name.." "..v._Class .. ", "
	end
	for i,v in GObjects.TickListRest do
		list = list .. v._Name.." "..v._Class .. ", "
	end
	for i,v in GObjects.UpdateListActors do
		list = list .. v._Name.." "..v._Class .. ", "
	end
	for i,v in GObjects.UpdateListItems do
		list = list .. v._Name.." "..v._Class .. ", "
	end
	for i,v in GObjects.UpdateListRest do
		list = list .. v._Name.." "..v._Class .. ", "
	end
	for i,v in GObjects.SynchronizeList do
		list = list .. v._Name.." "..v._Class .. ", "
	end
	CONSOLE_AddMessage(list)
end

--============================================================================
function Console:Cmd_DELETEALL(thing)
	if not thing then thing = "*" end
	local allthings,totalcount = GObjects:GetElementsWithFieldValue("_Name",thing.."*")
	for i,a in allthings do
		CONSOLE_AddMessage("Deleting "..a._Name)
		GObjects:ToKill(a)
	end
end
--============================================================================
function Console:Cmd_OPENANDREMOVEALLSLABS(thing)
	if not thing then thing = "*" end
	local allthings,totalcount = GObjects:GetElementsWithFieldValue("_Name","Slab*")
	for i,a in allthings do
		--CONSOLE_AddMessage("Opening "..a._Name)
		if a.Open then a:Open(false) end
	end
	for i,a in allthings do
		--CONSOLE_AddMessage("Opening "..a._Name)
		a:Delete()
	end
end
--============================================================================