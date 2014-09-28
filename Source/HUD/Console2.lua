function Console:Cmd_GETPLAYERSETTINGS()
	CONSOLE_AddMessage(PKPLUSPLUS_VERSION) -- needs to send something like this, so that all clients send their info at once
end
--=======================================================================
function Console:Cmd_STATSALL(player)
	for i,ps in Game.PlayerStats do 
		CONSOLE_AddMessage(Game:StatsText(ps.ClientID))
	end
end
--============================================================================
function Console:Cmd_STATSDUMP(filename)
	Game.DumpNextStats = true
	if Game:IsServer() then  
		Console:Cmd_PRINTSTATSALL()
	else
		Game:Client2ServerCommand("CMD:UPDATESTATSALL")
	end	
end
--============================================================================
function Game:WriteStats(filename)
	if(filename==nil)then filename="stats" end
	filename = os.date("%m-%d-%y", os.time()).."-"..filename..".txt"
	local file = io.open(filename,"a")
	if not file then return end
	file:write("***PK STATS***"..'\n'..'\n')
	file:write("Date: "..os.date("%m-%d-%y %X", os.time())..'\n')
	file:write("Map: "..Lev._Name..""..'\n')
	file:write("GameMode: "..MPCfg.GameMode..""..'\n'..'\n')
	for i,ps in Game.PlayerStats do 
		local txt = Game:StatsText(ps.ClientID)
		file:write(txt)
	end
	file:write("***END OF STATS***"..'\n'..'\n')
	CONSOLE_AddMessage("Stats written to /Bin/"..filename)
	io.close(file)
end
--=======================================================================
function Console:Cmd_PRINTSTATSALL()
	for i,ps in Game.PlayerStats do 
		CONSOLE_AddMessage(Game:StatsText(ps.ClientID))
	end	
	if(Game.DumpNextStats)then
		Game.DumpNextStats = nil
		Game:WriteStats()
	end
end
--=======================================================================
function Console:Cmd_STATS(player)
	if Game:IsServer() then  
		Console:Cmd_PRINTSTATSALL()
	else
		Game:Client2ServerCommand("CMD:UPDATESTATSALL")
	end
end
--=======================================================================
function Game:StatsText(statsplayer)
	local txt = ""
	local totaldamage = 0
	if(Game.Stats[statsplayer]~=nil)then --and Game.Stats[statsplayer].PlayerWepStats~=nil
	 txt = txt .. "Weapon Statistics for "..Game.PlayerStats[statsplayer].Name..'\n'..'\n'
	 txt = txt .. "Attacktype        Hits  Shots Damage Efficiency"..'\n'

	    for i,attack_type in Game.Stats[statsplayer].PlayerWepStats do	
	    	local failed = false 
		local attacktypetext = ""			    						
		if(attack_type.attacktype==1)then attacktypetext  = "Shotgun        " end
		if(attack_type.attacktype==2)then attacktypetext  = "Grenade        " end
		if(attack_type.attacktype==3)then attacktypetext  = "Rocket         " end
		if(attack_type.attacktype==4)then attacktypetext  = "OutOfLevel     " end
		if(attack_type.attacktype==5)then attacktypetext  = "MiniGun        " end
		if(attack_type.attacktype==6)then attacktypetext  = "Fire           " end
		if(attack_type.attacktype==7)then attacktypetext  = "Explosion      " end
		if(attack_type.attacktype==8)then attacktypetext  = "Poison         " end
		if(attack_type.attacktype==9)then attacktypetext  = "Bubble         " end
		if(attack_type.attacktype==10)then attacktypetext = "Stake          " end
		if(attack_type.attacktype==11)then attacktypetext = "Painkiller     " end
		if(attack_type.attacktype==12)then attacktypetext = "HitGround      " end
		if(attack_type.attacktype==13)then attacktypetext = "TeleFrag       " end
		if(attack_type.attacktype==14)then attacktypetext = "Suicide        " end
		if(attack_type.attacktype==15)then attacktypetext = "StickyBomb     " end
		if(attack_type.attacktype==16)then attacktypetext = "Step           " end
		if(attack_type.attacktype==17)then attacktypetext = "AIClose        " end
		if(attack_type.attacktype==18)then attacktypetext = "AIFar          " end
		if(attack_type.attacktype==19)then attacktypetext = "Shuriken       " end
		if(attack_type.attacktype==20)then attacktypetext = "Physics        " end
		if(attack_type.attacktype==21)then attacktypetext = "Stone          " end
		if(attack_type.attacktype==22)then attacktypetext = "Demon          " end
		if(attack_type.attacktype==23)then attacktypetext = "Electro        " end
		if(attack_type.attacktype==24)then attacktypetext = "PainkillerRotor" end
		if(attack_type.attacktype==25)then attacktypetext = "Fireball       " end
		if(attack_type.attacktype==26)then attacktypetext = "ItemCollision  " end
		if(attack_type.attacktype==27)then attacktypetext = "Tank           " end
		if(attack_type.attacktype==28)then attacktypetext = "Lava           " end
		if(attack_type.attacktype==29)then attacktypetext = "ConsoleKill    " end
		if(attack_type.attacktype==30)then attacktypetext = "Hurt_Pent      " end
		if(attack_type.attacktype==31)then attacktypetext = "Rifle          " end
		if(attack_type.attacktype==32)then attacktypetext = "FlameThrower   " end
		if(attack_type.attacktype==33)then attacktypetext = "Flag           " end
		if(attack_type.attacktype==34)then attacktypetext = "BoltStick      " end
		if(attack_type.attacktype==35)then attacktypetext = "HeaterBomb     " end
		local 			  hitspace = "     "
		if(attack_type.hits>9)then hitspace = "    " end
		if(attack_type.hits>99)then hitspace = "   " end
		if(attack_type.hits>999)then hitspace = "  " end
		if(attack_type.hits>9999)then hitspace = " " end
		local 			  shotspace = "     "
		if(attack_type.shots>9)then shotspace = "    " end
		if(attack_type.shots>99)then shotspace = "   " end
		if(attack_type.shots>999)then shotspace = "  " end
		if(attack_type.shots>9999)then shotspace = " " end
		local 			  damagepace = "      "
		if(attack_type.damage>9)then damagepace = "     " end
		if(attack_type.damage>99)then damagepace = "    " end
		if(attack_type.damage>999)then damagepace = "   " end
		if(attack_type.damage>9999)then damagepace = "  " end
		if(attack_type.damage>99999)then damagepace = " " end
		
		local percentage = 0
		if(attack_type.shots~=0)then percentage = (attack_type.hits / attack_type.shots) * 100 end
		if(percentage > 100)then percentage = 100 end
		if(not failed)then
		    txt = txt .. 
		    	    attacktypetext.."   "..
			    attack_type.hits..hitspace..
			    attack_type.shots..shotspace..
			    math.floor(attack_type.damage)..damagepace..
			    string.format("%02d",percentage).."%"..'\n'
			    totaldamage = totaldamage + attack_type.damage
		    else
		    	txt = txt .. "failed due to blah"
		end   
		end --for  
		txt = txt  ..'\n'
		txt = txt  .."Total Damage Given: "..tostring(math.floor(totaldamage))..'\n'
	else
		--txt = txt .. "failed due toGame.Stats[me]~=nil"
	end   

	txt = txt  ..'\n'
	return txt
end
--=======================================================================
function Console:Cmd_TEAMLOCK(enable)    
	if(enable=="1")then MPCfg.TeamLock = true CONSOLE_AddMessage("State: TeamLock is currently enabled.") return end
	if(enable=="0")then MPCfg.TeamLock = false CONSOLE_AddMessage("State: TeamLock is currently disabled.") return end
	CONSOLE_AddMessage("Syntax: TeamLock [0/1]")
	CONSOLE_AddMessage("Help: Locks the game to new players.")
	if(MPCfg.TeamLock) then CONSOLE_AddMessage("State: TeamLock is currently enabled.") 
	else CONSOLE_AddMessage("State: TeamLock is currently disabled.") end
end
--=======================================================================
function CONSOLE_AddMessage(txt,color)    
	CONSOLE.AddMessage(txt,color)
	if(Cfg.Logging) then Logfile:Write(txt) end
end
--=======================================================================
function Console:Cmd_ALLUNREADY()    
    if Game:IsServer() then   
	for i, ps in Game.PlayerStats do
		if ps and ps.Spectator == 0 then
			ps.State = 0
		end
	end
    end
end
--=======================================================================
function Console:Cmd_ALLREADY()    
    if Game:IsServer() then   
	for i, ps in Game.PlayerStats do
		if ps and ps.Spectator == 0 then
			ps.State = 1
		end
	end
    end
end
--=======================================================================
function Console:Cmd_BREAKMATCH()    
    if Game:IsServer() then   
	for i, ps in Game.PlayerStats do
		if ps and ps.Spectator == 0 then
			ps.State = 2
		end
	end
    end
end
--=======================================================================
function Console:Cmd_FORCESPECTATOR(clientid)    
    if Game:IsServer() then   
    clientid = tonumber(clientid)
        nr = 1
        if nr and (nr == 0 or nr == 1)then
            if Game.GMode ~= GModes.SingleGame then
                local spec = true
                if nr == 0 then spec = false end
                if spec ~= NET.IsSpectator(clientid) and Game.PlayerStats[clientid] and not Game.PlayerStats[clientid].Bot then
                    if NET.IsPlayingRecording() then
                        if nr == 0 then
                            GObjects:ToKill(Game._procSpec)
                            Game._procSpec = nil
                            Player = Game._spectatorRecordingPlayer
                        elseif(Game.PlayerStats[clientid] and not Game.PlayerStats[clientid].Bot)then -- DOESN'T WORK ON BOTS
                            GObjects:ToKill(Game._procStats)
                            Game._procStats = nil
                            Game._procSpec = GObjects:Add(TempObjName(),PSpectatorControler:New())
                            Game._procSpec:Init()
                            Game._spectatorRecordingPlayer = Game.PlayerStats[clientid].Player
                            Game.PlayerStats[clientid].Player = nil
                        end
                        NET.SetSpectator(clientid,1)
                    else
                        Game.PlayerSpectatorRequest(clientid,1)
                    end
                end
            end
        end
    end
end
--=======================================================================
function Console:Cmd_FORCEJOIN(clientid)    
    if Game:IsServer() then   
    clientid = tonumber(clientid)
        nr = 0
        if nr and (nr == 0 or nr == 1)then
            if Game.GMode ~= GModes.SingleGame then
                local spec = true
                if nr == 0 then spec = false end
                if spec ~= NET.IsSpectator(clientid) and Game.PlayerStats[clientid] and not Game.PlayerStats[clientid].Bot then
                    if NET.IsPlayingRecording() then
                        if nr == 0 then
                            GObjects:ToKill(Game._procSpec)
                            Game._procSpec = nil
                            Player = Game._spectatorRecordingPlayer
                        elseif(not Game.PlayerStats[clientid].Bot)then -- DOESN'T WORK ON BOTS
                            GObjects:ToKill(Game._procStats)
                            Game._procStats = nil
                            Game._procSpec = GObjects:Add(TempObjName(),PSpectatorControler:New())
                            Game._procSpec:Init()
                            Game._spectatorRecordingPlayer = Game.PlayerStats[clientid].Player
                            Game.PlayerStats[clientid].Player = nil
                        end
                        NET.SetSpectator(clientid,0)
                    else
                        Game.PlayerSpectatorRequest(clientid,0)
                    end
                end
            end
        end
    end
end
--=======================================================================
function Console:Cmd_DIRECTINPUT(enable)    
	enable = tonumber(enable)               
	if enable == 1 then Cfg.DirectInput = true INP.SetUseDInput(Cfg.DirectInput)  CONSOLE_AddMessage("directinput is now enabled") return end    
	if enable == 0 then Cfg.DirectInput = false INP.SetUseDInput(Cfg.DirectInput)  CONSOLE_AddMessage("directinput is now disabled") return end  
	CONSOLE_AddMessage("Syntax: directinput [1/0]")
	CONSOLE_AddMessage("Help: Toggles direct input versus windows input.")
	if Cfg.DirectInput then CONSOLE_AddMessage("State: directinput is currently on.")
	else CONSOLE_AddMessage("State: directinput is currently off.") end      
end
--=======================================================================
function Console:Cmd_MAPVIEW(enable)    
	if(enable=="1")then Cfg.MapView = true CONSOLE_AddMessage("Mapview is now enabled") return end
	if(enable=="0")then Cfg.MapView = false CONSOLE_AddMessage("Mapview is now disabled") return end
	CONSOLE_AddMessage("Syntax: mapview [1/0]")
	CONSOLE_AddMessage("Help: Enables the rendering of mapoverlay in specmode.")
	if Cfg.MapView then CONSOLE_AddMessage("State: mapview is currently on.")
	else CONSOLE_AddMessage("State: mapview is currently off.") end
end

function Console:Cmd_TEAMOVERLAY(enable)     
	if(enable=="1")then Cfg.TeamOverlay = true CONSOLE_AddMessage("TeamOverlay is now enabled") return end
	if(enable=="0")then Cfg.TeamOverlay = false CONSOLE_AddMessage("TeamOverlay is now disabled") return end
	CONSOLE_AddMessage("Syntax: TeamOverlay [1/0]")
	CONSOLE_AddMessage("Help: Shows TeamOverlay.")
	if Cfg.TeamOverlay then CONSOLE_AddMessage("State: TeamOverlay is currently on.")
	else CONSOLE_AddMessage("State: TeamOverlay is currently off.") end
end

function Console:Cmd_TEAMSCORES(enable)    
	if(enable=="1")then Cfg.TeamScores = true CONSOLE_AddMessage("TeamScores is now enabled") return end
	if(enable=="0")then Cfg.TeamScores = false CONSOLE_AddMessage("TeamScores is now disabled") return end
	CONSOLE_AddMessage("Syntax: teamscores [1/0]")
	CONSOLE_AddMessage("Help: Shows TeamScores.")
	if Cfg.TeamScores then CONSOLE_AddMessage("State: TeamScores is currently on.")
	else CONSOLE_AddMessage("State: TeamScores is currently off.") end
end

function Console:Cmd_TEAMSCORESSHADOW(enable)    
	if(enable=="1")then Cfg.TeamScoresShadow = true CONSOLE_AddMessage("TeamScoresShadow is now enabled") return end
	if(enable=="0")then Cfg.TeamScoresShadow = false CONSOLE_AddMessage("TeamScoresShadow is now disabled") return end
	CONSOLE_AddMessage("Syntax: TeamScoresShadow [1/0]")
	CONSOLE_AddMessage("Help: Shows TeamScoresShadow.")
	if Cfg.TeamScoresShadow then CONSOLE_AddMessage("State: TeamScoresShadow is currently on.")
	else CONSOLE_AddMessage("State: TeamScoresShadow is currently off.") end
end

function Console:Cmd_AMMOLIST(enable)   
	if(enable=="0")then Cfg.HUD_AmmoList = 0 CONSOLE_AddMessage("AmmoList is now 0, disabled.") return end
	if(enable=="1")then Cfg.HUD_AmmoList = 1 CONSOLE_AddMessage("AmmoList is now 1") return end
	if(enable=="2")then Cfg.HUD_AmmoList = 2 CONSOLE_AddMessage("AmmoList is now 2") return end
	CONSOLE_AddMessage("Syntax: AmmoList [0/1/2]")
	CONSOLE_AddMessage("Help: Shows AmmoList.")
	CONSOLE_AddMessage("State: AmmoList is currently "..tostring(Cfg.HUD_AmmoList))
end

function Console:Cmd_CROSSHAIRNAMES(enable)    
	if(enable=="1")then Cfg.CrosshairNames = true CONSOLE_AddMessage("CrosshairNames is now enabled") return end
	if(enable=="0")then Cfg.CrosshairNames = false CONSOLE_AddMessage("CrosshairNames is now disabled") return end
	CONSOLE_AddMessage("Syntax: crosshairnames [1/0]")
	CONSOLE_AddMessage("Help: Shows crosshair names.")
	if Cfg.CrosshairNames then CONSOLE_AddMessage("State: CrosshairNames is currently on.")
	else CONSOLE_AddMessage("State: CrosshairNames is currently off.") end
end

function Console:Cmd_CROSSHAIRNAMESTEAMONLY(enable)    
	if(enable=="1")then Cfg.CrosshairNamesTeamOnly = true CONSOLE_AddMessage("CrosshairNamesTeamOnly is now enabled") return end
	if(enable=="0")then Cfg.CrosshairNamesTeamOnly = false CONSOLE_AddMessage("CrosshairNamesTeamOnly is now disabled") return end
	CONSOLE_AddMessage("Syntax: crosshairnamesteamonly [1/0]")
	CONSOLE_AddMessage("Help: Shows  team crosshair names.")
	if Cfg.CrosshairNamesTeamOnly then CONSOLE_AddMessage("State: CrosshairNamesTeamOnly is currently on.")
	else CONSOLE_AddMessage("State: CrosshairNamesTeamOnly is currently off.") end
end

function Console:Cmd_AUTORECORD(enable)    
	if(enable=="1")then Cfg.Autorecord = true CONSOLE_AddMessage("Autorecord is now enabled") return end
	if(enable=="0")then Cfg.Autorecord = false CONSOLE_AddMessage("Autorecord is now disabled") return end
	CONSOLE_AddMessage("Syntax: autorecord [1/0]")
	CONSOLE_AddMessage("Help: Enables automatic recording of match demos.")
	if Cfg.Autorecord then CONSOLE_AddMessage("State: Autorecord is currently on.")
	else CONSOLE_AddMessage("State: Autorecord is currently off.") end
end

function Console:Cmd_OVERTIME(enable)    
	if(enable~=nil)then Cfg.Overtime = tonumber(enable) CONSOLE_AddMessage("State: overtime is now "..tostring(tonumber(Cfg.Overtime)).." minutes.") return end
	CONSOLE_AddMessage("Syntax: overtime [n] (minutes)")
	CONSOLE_AddMessage("Help: Sets overtime in the even of a draw, in minutes.")
	CONSOLE_AddMessage("State: overtime is currently "..tostring(tonumber(Cfg.Overtime)).." minutes.")
end

function Console:Cmd_TIME()    
	local timestamp = os.date( "%d-%m-%y-%X", os.time() )
	CONSOLE_AddMessage("The local (client) time is currently "..timestamp)
end

--function Console:Cmd_SERVERTIME()  
--	if(Game:IsServer())then  
--		local timestamp = os.date( "%d-%m-%y-%X", os.time() )
--		local txt = "The (server) time is currently "..timestamp
--		NET.SendVariable( clientID, "MOTD", rest )
--	end
--end

function Console:Cmd_FIXEDCOLORS(enable)    
	if(enable=="1")then Cfg.FixedColors = true CONSOLE_AddMessage("FixedColors is now enabled") Game:ReloadBrightskins() return end
	if(enable=="0")then Cfg.FixedColors = false CONSOLE_AddMessage("FixedColors is now disabled") Game:ReloadBrightskins() return end
	CONSOLE_AddMessage("Syntax: FixedColors [1/0]")
	CONSOLE_AddMessage("Help: Switches colours.")
	if Cfg.FixedColors then CONSOLE_AddMessage("State: FixedColors is currently on.")
	else CONSOLE_AddMessage("State: FixedColors is currently off.") end
end
function Console:Cmd_BRIGHTSKINS(enable)    
	if(enable=="1")then Cfg.BrightSkins = true CONSOLE_AddMessage("BrightSkins is now enabled. Requires restart.") Game:ReloadBrightskins() return end
	if(enable=="0")then Cfg.BrightSkins = false CONSOLE_AddMessage("BrightSkins is now disabled. Requires restart.") Game:ReloadBrightskins() return end
	CONSOLE_AddMessage("Syntax: BrightSkins [1/0]")
	CONSOLE_AddMessage("Help: Switches BrightSkins on/off.")
	if Cfg.BrightSkins then CONSOLE_AddMessage("State: BrightSkins is currently on.")
	else CONSOLE_AddMessage("State: BrightSkins is currently off.") end
end


function Console:Cmd_FIXEDCOLOURS(enable)    
	if(enable=="1")then Cfg.FixedColors = true CONSOLE_AddMessage("FixedColors is now enabled") Game:ReloadBrightskins() return end
	if(enable=="0")then Cfg.FixedColors = false CONSOLE_AddMessage("FixedColors is now disabled") Game:ReloadBrightskins() return end
	CONSOLE_AddMessage("Syntax: FixedColors [1/0]")
	CONSOLE_AddMessage("Help: Switches colours.")
	if Cfg.FixedColors then CONSOLE_AddMessage("State: FixedColors is currently on.")
	else CONSOLE_AddMessage("State: FixedColors is currently off.") end
end

function Console:Cmd_BRIGHTSKINENEMY(enable)  
	if(Cfg.BrightskinEnemy==nil)then Cfg.BrightskinTeam = "Red" end    
	if(enable=="Red" or enable=="red")then Cfg.BrightskinEnemy = "Red" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Green" or enable=="green")then Cfg.BrightskinEnemy = "Green" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Blue" or enable=="blue")then Cfg.BrightskinEnemy = "Blue" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Cyan" or enable=="cyan")then Cfg.BrightskinEnemy = "Cyan" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Magenta" or enable=="magenta")then Cfg.BrightskinEnemy = "Magenta" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Yellow" or enable=="yellow")then Cfg.BrightskinEnemy = "Yellow" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="White" or enable=="white")then Cfg.BrightskinEnemy = "White" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Black" or enable=="black")then Cfg.BrightskinEnemy = "Black" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end

	if(enable=="Orange" or enable=="orange")then Cfg.BrightskinEnemy = "Orange" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Pink" or enable=="pink")then Cfg.BrightskinEnemy = "Pink" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end

	CONSOLE_AddMessage("Syntax: BrightskinEnemy [Red/Green/Blue/Cyan/Magenta/Yellow/White/Black/Orange/Pink]")
	CONSOLE_AddMessage("Help: Switches enemy colours. Check FixedColors setting also.")
	CONSOLE_AddMessage("State: BrightskinEnemy is currently "..Cfg.BrightskinEnemy..".")
end

function Console:Cmd_BRIGHTSKINTEAM(enable)  
	if(Cfg.BrightskinTeam==nil)then Cfg.BrightskinTeam = "Blue" end  
	if(enable=="Red" or enable=="red")then Cfg.BrightskinTeam = "Red" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Green" or enable=="green")then Cfg.BrightskinTeam = "Green" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Blue" or enable=="blue")then Cfg.BrightskinTeam = "Blue" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Cyan" or enable=="cyan")then Cfg.BrightskinTeam = "Cyan" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Magenta" or enable=="magenta")then Cfg.BrightskinTeam = "Magenta" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Yellow" or enable=="yellow")then Cfg.BrightskinTeam = "Yellow" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="White" or enable=="white")then Cfg.BrightskinTeam = "White" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Black" or enable=="black")then Cfg.BrightskinTeam = "Black" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end

	if(enable=="Orange" or enable=="orange")then Cfg.BrightskinTeam = "Orange" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end
	if(enable=="Pink" or enable=="pink")then Cfg.BrightskinTeam = "Pink" CONSOLE_AddMessage("Colours changed") Game:ReloadBrightskins() return end

	CONSOLE_AddMessage("Syntax: BrightskinTeam [Red/Green/Blue/Cyan/Magenta/Yellow/White/Black/Orange/Pink]")
	CONSOLE_AddMessage("Help: Switches team colours. Check FixedColors setting also.")
	CONSOLE_AddMessage("State: BrightskinTeam is currently "..Cfg.BrightskinTeam..".")
end

function Console:Cmd_CONFIGUREMAPVIEW(enable)    
	if(enable=="1")then Cfg.ConfigMapView = true CONSOLE_AddMessage("ConfigMapView is now enabled")  return end
	if(enable=="0")then Cfg.ConfigMapView = false CONSOLE_AddMessage("ConfigMapView is now disabled")  return end
	CONSOLE_AddMessage("Syntax: ConfigMapView [1/0]")
	CONSOLE_AddMessage("Help: Enables mapview configuration.")
	if Cfg.ConfigMapView then CONSOLE_AddMessage("State: ConfigMapView is currently on.")
	else CONSOLE_AddMessage("State: ConfigMapView is currently off.") end
end

function Console:Cmd_MAPVIEWSHOWRESPAWNS(enable)    
	if(enable=="1")then Cfg.MapViewShowRespawns = true CONSOLE_AddMessage("MapViewShowRespawns is now enabled")  return end
	if(enable=="0")then Cfg.MapViewShowRespawns = false CONSOLE_AddMessage("MapViewShowRespawns is now disabled") return end
	CONSOLE_AddMessage("Syntax: MapViewShowRespawns [1/0]")
	CONSOLE_AddMessage("Help: Shows respawns on mapview during configure.")
	if Cfg.MapViewShowRespawns then CONSOLE_AddMessage("State: MapViewShowRespawns is currently on.")
	else CONSOLE_AddMessage("State: MapViewShowRespawns is currently off.") end
end

function Console:Cmd_OLDSCOREBOARD(enable)    
	if(enable=="1")then Cfg.OldScoreboard = true CONSOLE_AddMessage("OldScoreboard is now enabled. Requires restart.")  return end
	if(enable=="0")then Cfg.OldScoreboard = false CONSOLE_AddMessage("OldScoreboard is now disabled. Requires restart.") return end
	CONSOLE_AddMessage("Syntax: OldScoreboard [1/0]")
	CONSOLE_AddMessage("Help: Shows the old crappy pcf scoreboard. <o/ matchsticks :(")
	if Cfg.OldScoreboard then CONSOLE_AddMessage("State: OldScoreboard is currently on.")
	else CONSOLE_AddMessage("State: OldScoreboard is currently off.") end
end

function Console:Cmd_ALTSCOREBOARD(enable)    
	if(enable=="1")then Cfg.AltScoreboard = true CONSOLE_AddMessage("AltScoreboard is now enabled. Requires restart.")  return end
	if(enable=="0")then Cfg.AltScoreboard = false CONSOLE_AddMessage("AltScoreboard is now disabled. Requires restart.") return end
	CONSOLE_AddMessage("Syntax: AltScoreboard [1/0]")
	CONSOLE_AddMessage("Help: Shows softer colours scoreboard")
	if Cfg.AltScoreboard then CONSOLE_AddMessage("State: AltScoreboard is currently on.")
	else CONSOLE_AddMessage("State: AltScoreboard is currently off.") end
end
function Console:Cmd_SHOWPING(enable)    
	if(enable=="1")then Cfg.ShowPing = true CONSOLE_AddMessage("ShowPing is now enabled.")  return end
	if(enable=="0")then Cfg.ShowPing = false CONSOLE_AddMessage("ShowPing is now disabled.") return end
	CONSOLE_AddMessage("Syntax: ShowPing [1/0]")
	CONSOLE_AddMessage("Help: Shows the ping in player HUD")
	if Cfg.ShowPing then CONSOLE_AddMessage("State: ShowPing is currently on.")
	else CONSOLE_AddMessage("State: ShowPing is currently off.") end
end

function Console:Cmd_SIMPLEHUD(enable)    
	if(enable=="1")then Cfg.Simplehud = true CONSOLE_AddMessage("Simplehud is now enabled.")  return end
	if(enable=="0")then Cfg.Simplehud = false CONSOLE_AddMessage("Simplehud is now disabled.") return end
	CONSOLE_AddMessage("Syntax: Simplehud [1/0]")
	CONSOLE_AddMessage("Help: Shows simple HUD")
	if Cfg.Simplehud then CONSOLE_AddMessage("State: Simplehud is currently on.")
	else CONSOLE_AddMessage("State: Simplehud is currently off.") end
end

function Console:Cmd_SIMPLEHUDSHADOW(enable)    
	if(enable=="1")then Cfg.SimplehudShadow = true CONSOLE_AddMessage("SimplehudShadow is now enabled.")  return end
	if(enable=="0")then Cfg.SimplehudShadow = false CONSOLE_AddMessage("SimplehudShadow is now disabled.") return end
	CONSOLE_AddMessage("Syntax: SimplehudShadow [1/0]")
	CONSOLE_AddMessage("Help: Shows simple HUD Shadow")
	if Cfg.SimplehudShadow then CONSOLE_AddMessage("State: SimplehudShadow is currently on.")
	else CONSOLE_AddMessage("State: SimplehudShadow is currently off.") end
end

function Console:Cmd_COLOUREDICONS(enable)    
	if(enable=="1")then Cfg.ColouredIcons = true CONSOLE_AddMessage("ColouredIcons is now enabled. Requires restart.")  return end
	if(enable=="0")then Cfg.ColouredIcons = false CONSOLE_AddMessage("ColouredIcons is now disabled. Requires restart.") return end
	CONSOLE_AddMessage("Syntax: ColouredIcons [1/0]")
	CONSOLE_AddMessage("Help: Use of coloured icons")
	if Cfg.ColouredIcons then CONSOLE_AddMessage("State: ColouredIcons is currently on.")
	else CONSOLE_AddMessage("State: ColouredIcons is currently off.") end
end

function Console:Cmd_COLOREDICONS(enable)    
	if(enable=="1")then Cfg.ColouredIcons = true CONSOLE_AddMessage("ColouredIcons is now enabled. Requires restart.")  return end
	if(enable=="0")then Cfg.ColouredIcons = false CONSOLE_AddMessage("ColouredIcons is now disabled. Requires restart.") return end
	CONSOLE_AddMessage("Syntax: ColouredIcons [1/0]")
	CONSOLE_AddMessage("Help: Use of coloured icons")
	if Cfg.ColouredIcons then CONSOLE_AddMessage("State: ColouredIcons is currently on.")
	else CONSOLE_AddMessage("State: ColouredIcons is currently off.") end
end

function Console:Cmd_AMMOLISTHIDEWEAPONS(enable)    
	if(enable=="1")then Cfg.AmmolistHideWeapons = true CONSOLE_AddMessage("AmmolistHideWeapons is now enabled.")  return end
	if(enable=="0")then Cfg.AmmolistHideWeapons = false CONSOLE_AddMessage("AmmolistHideWeapons is now disabled.") return end
	CONSOLE_AddMessage("Syntax: AmmolistHideWeapons [1/0]")
	CONSOLE_AddMessage("Help: Hides missing weapon icons")
	if Cfg.AmmolistHideWeapons then CONSOLE_AddMessage("State: AmmolistHideWeapons is currently on.")
	else CONSOLE_AddMessage("State: AmmolistHideWeapons is currently off.") end
end



function Console:Cmd_CAMERAINTERPOLATEPOSITION(enable)    
	if(enable=="1")then Cfg.CameraInterpolatePosition = true CONSOLE_AddMessage("CameraInterpolatePosition is now enabled.")  return end
	if(enable=="0")then Cfg.CameraInterpolatePosition = false CONSOLE_AddMessage("CameraInterpolatePosition is now disabled.") return end
	CONSOLE_AddMessage("Syntax: CameraInterpolatePosition [1/0]")
	CONSOLE_AddMessage("Help: Smooths camera postion in spec")
	if Cfg.CameraInterpolatePosition then CONSOLE_AddMessage("State: CameraInterpolatePosition is currently on.")
	else CONSOLE_AddMessage("State: CameraInterpolatePosition is currently off.") end
end

function Console:Cmd_CAMERAINTERPOLATEANGLE(enable)    
	if(enable=="1")then Cfg.CameraInterpolateAngle = true CONSOLE_AddMessage("CameraInterpolateAngle is now enabled.")  return end
	if(enable=="0")then Cfg.CameraInterpolateAngle = false CONSOLE_AddMessage("CameraInterpolateAngle is now disabled.") return end
	CONSOLE_AddMessage("Syntax: CameraInterpolateAngle [1/0]")
	CONSOLE_AddMessage("Help: Smooths camera angle in spec")
	if Cfg.CameraInterpolateAngle then CONSOLE_AddMessage("State: CameraInterpolateAngle is currently on.")
	else CONSOLE_AddMessage("State: CameraInterpolateAngle is currently off.") end
end


function Console:Cmd_SCOREBOARDSHOWPACKETLOSS(enable)    
	if(enable=="1")then Cfg.ScoreboardShowPacketLoss = true CONSOLE_AddMessage("ScoreboardShowPacketLoss is now enabled.")  return end
	if(enable=="0")then Cfg.ScoreboardShowPacketLoss = false CONSOLE_AddMessage("ScoreboardShowPacketLoss is now disabled.") return end
	CONSOLE_AddMessage("Syntax: ScoreboardShowPacketLoss [1/0]")
	CONSOLE_AddMessage("Help: Shows packet loss information on the scoreboard")
	if Cfg.ScoreboardShowPacketLoss then CONSOLE_AddMessage("State: ScoreboardShowPacketLoss is currently on.")
	else CONSOLE_AddMessage("State: ScoreboardShowPacketLoss is currently off.") end
end

function Console:Cmd_BOTCHAT(enable)    
	if(enable=="1")then Cfg.BotChat = true CONSOLE_AddMessage("BotChat is now enabled.")  return end
	if(enable=="0")then Cfg.BotChat = false CONSOLE_AddMessage("BotChat is now disabled.") return end
	CONSOLE_AddMessage("Syntax: BotNoBotChatChat [1/0]")
	CONSOLE_AddMessage("Help: Toggles bot talking.")
	if Cfg.BotChat then CONSOLE_AddMessage("State: BotChat is currently on.")
	else CONSOLE_AddMessage("State: BotChat is currently off.") end
end

function Console:Cmd_BOTATTACK(enable)    
	if(enable=="1")then Cfg.BotAttack = true CONSOLE_AddMessage("BotAttack is now enabled.")  return end
	if(enable=="0")then Cfg.BotAttack = false CONSOLE_AddMessage("BotAttack is now disabled.") return end
	CONSOLE_AddMessage("Syntax: BotAttack [1/0]")
	CONSOLE_AddMessage("Help: Toggles bots attack.")
	if Cfg.BotAttack then CONSOLE_AddMessage("State: BotAttack is currently on.")
	else CONSOLE_AddMessage("State: BotAttack is currently off.") end
end

function Console:Cmd_SAFERESPAWN(enable)    
	if(enable=="1")then Cfg.SafeRespawn = true CONSOLE_AddMessage("SafeRespawn is now enabled.")  return end
	if(enable=="0")then Cfg.SafeRespawn = false CONSOLE_AddMessage("SafeRespawn is now disabled.") return end
	CONSOLE_AddMessage("Syntax: SafeRespawn [1/0]")
	CONSOLE_AddMessage("Help: Toggles non telefrag respawns.")
	if Cfg.SafeRespawn then CONSOLE_AddMessage("State: SafeRespawn is currently on.")
	else CONSOLE_AddMessage("State: SafeRespawn is currently off.") end
end

function Console:Cmd_FORCESPEC(enable)    
	if(enable=="1")then Cfg.ForceSpec = true CONSOLE_AddMessage("ForceSpec is now enabled.")  return end
	if(enable=="0")then Cfg.ForceSpec = false CONSOLE_AddMessage("ForceSpec is now disabled.") return end
	CONSOLE_AddMessage("Syntax: ForceSpec [1/0]")
	CONSOLE_AddMessage("Help: Toggles whether new connections are forced into spectator mode during a game.")
	if Cfg.ForceSpec then CONSOLE_AddMessage("State: ForceSpec is currently on.")
	else CONSOLE_AddMessage("State: ForceSpec is currently off.") end
end

function Console:Cmd_WARMUPDAMAGE(enable)    
	if(enable=="1")then Cfg.WarmupDamage = true CONSOLE_AddMessage("WarmupDamage is now enabled.")  return end
	if(enable=="0")then Cfg.WarmupDamage = false CONSOLE_AddMessage("WarmupDamage is now disabled.") return end
	CONSOLE_AddMessage("Syntax: WarmupDamage [1/0]")
	CONSOLE_AddMessage("Help: Toggles damage in warmup.")
	if Cfg.WarmupDamage then CONSOLE_AddMessage("State: WarmupDamage is currently on.")
	else CONSOLE_AddMessage("State: WarmupDamage is currently off.") end
end




function Console:Cmd_TEAMSCORESX(enable)    
	if(enable~=nil)then Cfg.TeamScoresX = tonumber(enable) CONSOLE_AddMessage("TeamScoresX is now "..tostring(Cfg.TeamScoresX))  return end
	CONSOLE_AddMessage("Syntax: TeamScoresX [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-width where teamscores is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: TeamScoresX is currently "..tostring(Cfg.TeamScoresX))
end

function Console:Cmd_TEAMSCORESY(enable)    
	if(enable~=nil)then Cfg.TeamScoresY = tonumber(enable) CONSOLE_AddMessage("TeamScoresY is now "..tostring(Cfg.TeamScoresY))  return end
	CONSOLE_AddMessage("Syntax: TeamScoresY [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-height where teamscores is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: TeamScoresY is currently "..tostring(Cfg.TeamScoresY))
end

function Console:Cmd_TEAMOVERLAYX(enable)    
	if(enable~=nil)then Cfg.TeamOverlayX = tonumber(enable) CONSOLE_AddMessage("TeamOverlayX is now "..tostring(Cfg.TeamOverlayX))  return end
	CONSOLE_AddMessage("Syntax: TeamOverlayX [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-width where teamoverlay is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: TeamOverlayX is currently "..tostring(Cfg.TeamOverlayX))
end

function Console:Cmd_TEAMOVERLAYY(enable)    
	if(enable~=nil)then Cfg.TeamOverlayY = tonumber(enable) CONSOLE_AddMessage("TeamOverlayY is now "..tostring(Cfg.TeamOverlayY))  return end
	CONSOLE_AddMessage("Syntax: TeamOverlayY [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-height where teamoverlay is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: TeamOverlayY is currently "..tostring(Cfg.TeamOverlayY))
end

function Console:Cmd_TEAMOVERLAYW(enable)    
	if(enable~=nil)then Cfg.TeamOverlayW = tonumber(enable) CONSOLE_AddMessage("TeamOverlayW is now "..tostring(Cfg.TeamOverlayW))  return end
	CONSOLE_AddMessage("Syntax: TeamOverlayW [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-width which is teamoverlay width. Non-CPL compliant.")
	CONSOLE_AddMessage("State: TeamOverlayW is currently "..tostring(Cfg.TeamOverlayW))
end


function Console:Cmd_SHOWPINGX(enable)    
	if(enable~=nil)then Cfg.ShowPingX = tonumber(enable) CONSOLE_AddMessage("ShowPingX is now "..tostring(Cfg.ShowPingX))  return end
	CONSOLE_AddMessage("Syntax: ShowPingX [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-width where ping is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: ShowPingX is currently "..tostring(Cfg.ShowPingX))
end

function Console:Cmd_SHOWPINGY(enable)    
	if(enable~=nil)then Cfg.ShowPingY = tonumber(enable) CONSOLE_AddMessage("ShowPingY is now "..tostring(Cfg.ShowPingY))  return end
	CONSOLE_AddMessage("Syntax: ShowPingY [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-height where ping is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: ShowPingY is currently "..tostring(Cfg.ShowPingY))
end

function Console:Cmd_SHOWTIMERX(enable)    
	if(enable~=nil)then Cfg.ShowTimerX = tonumber(enable) CONSOLE_AddMessage("ShowTimerX is now "..tostring(Cfg.ShowTimerX))  return end
	CONSOLE_AddMessage("Syntax: ShowTimerX [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-width where timer is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: ShowTimerX is currently "..tostring(Cfg.ShowTimerX))
end

function Console:Cmd_SHOWTIMERY(enable)    
	if(enable~=nil)then Cfg.ShowTimerY = tonumber(enable) CONSOLE_AddMessage("ShowTimerY is now "..tostring(Cfg.ShowTimerY))  return end
	CONSOLE_AddMessage("Syntax: ShowTimerY [Fraction]")
	CONSOLE_AddMessage("Help: Sets the fraction of the screen-height where timer is drawn. Non-CPL compliant.")
	CONSOLE_AddMessage("State: ShowTimerY is currently "..tostring(Cfg.ShowTimerY))
end

function Console:Cmd_SHOWTIMERFONTSIZE(enable)    
	if(enable~=nil)then Cfg.ShowTimerFontSize = math.floor(tonumber(enable)) CONSOLE_AddMessage("ShowTimerFontSize is now "..tostring(Cfg.ShowTimerFontSize))  return end
	CONSOLE_AddMessage("Syntax: ShowTimerFontSize [integer]")
	CONSOLE_AddMessage("Help: Sets the timer font size. Non-CPL compliant.")
	CONSOLE_AddMessage("State: ShowTimerFontSize is currently "..tostring(Cfg.ShowTimerFontSize))
end

function Console:Cmd_SCOREBOARDFONTSIZE(enable)    
	if(enable~=nil)then Cfg.ScoreboardFontSize= math.floor(tonumber(enable)) CONSOLE_AddMessage("ScoreboardFontSize is now "..tostring(Cfg.ScoreboardFontSize))  return end
	CONSOLE_AddMessage("Syntax: ScoreboardFontSize [integer]")
	CONSOLE_AddMessage("Help: Sets the scoreboard font size. Non-CPL compliant.")
	CONSOLE_AddMessage("State: ScoreboardFontSize is currently "..tostring(Cfg.ScoreboardFontSize))
end

function Console:Cmd_TEAMOVERLAYFONTSIZE(enable)    
	if(enable~=nil)then Cfg.TeamOverlayFontSize= math.floor(tonumber(enable)) CONSOLE_AddMessage("TeamOverlayFontSize is now "..tostring(Cfg.TeamOverlayFontSize))  return end
	CONSOLE_AddMessage("Syntax: TeamOverlayFontSize [integer]")
	CONSOLE_AddMessage("Help: Sets the teamoverlay font size. Non-CPL compliant.")
	CONSOLE_AddMessage("State: TeamOverlayFontSize is currently "..tostring(Cfg.TeamOverlayFontSize))
end

function Console:Cmd_TEAMSCORESFONTSIZE(enable)    
	if(enable~=nil)then Cfg.TeamScoresFontSize= math.floor(tonumber(enable)) CONSOLE_AddMessage("TeamScoresFontSize is now "..tostring(Cfg.TeamScoresFontSize))  return end
	CONSOLE_AddMessage("Syntax: TeamScoresFontSize [integer]")
	CONSOLE_AddMessage("Help: Sets the teamscores font size. Non-CPL compliant.")
	CONSOLE_AddMessage("State: TeamScoresFontSize is currently "..tostring(Cfg.TeamScoresFontSize))
end

function Console:Cmd_RESTARTMAP() 
  --if MPCfg.GameState == GameStates.Playing then   
		Game:MapRestart()
	--end
end

function Console:Cmd_EXEC(enable)    
	if(enable~=nil)then 
	local temp = CfgFile 
	CfgFile = enable..".ini" 
	Cfg:Load() 
	CfgFile = temp 
	CONSOLE_AddMessage("Bin\\"..enable..".ini executed.") 
	return 
	end
	CONSOLE_AddMessage("Syntax: exec <filename>")
	CONSOLE_AddMessage("Help: Executes config file")
end

function Console:Cmd_WRITECONFIG(enable)    
	if(enable~=nil)then local temp = CfgFile 
	CfgFile = enable..".ini" 
	Cfg:Save() 
	CfgFile = temp 
	CONSOLE_AddMessage("Bin\\"..enable..".ini written.") 
	return 
	end
	CONSOLE_AddMessage("Syntax: writeconfig <filename>")
	CONSOLE_AddMessage("Help: Writes config file")
end




function Console:Cmd_RCONPASS(enable)    
	if(enable~=nil)then Cfg.RconPass = tostring(enable) CONSOLE_AddMessage("RconPass is enabled.")  return end
	CONSOLE_AddMessage("Syntax: RconPass [password]")
	CONSOLE_AddMessage("Help: Sets the local rcon password.")
	if Cfg.RconPass==nil or Cfg.RconPass=="" then CONSOLE_AddMessage("State: Rcon is disabled.") else
	CONSOLE_AddMessage("State: Rcon is "..tostring(Cfg.RconPass)) end
end

function Console:Cmd_RCON(enable)    
	if(enable~=nil and Cfg.RconPass~=nil and Cfg.RconPass~="")then 
	NET.SendVariable( NET.GetClientID(), "rcon", tostring(NET.GetClientID())..","..Cfg.RconPass..","..enable )  
	return end
	CONSOLE_AddMessage("Syntax: rcon [command] [parameters]")
	CONSOLE_AddMessage("Help: Sends rcon command to the server.")
	CONSOLE_AddMessage("State: Rcon is disabled")
end

function Console:Cmd_REFPASS(enable)    
	if(enable~=nil)then Cfg.RefPass = tostring(enable) CONSOLE_AddMessage("RefPass is enabled.")  return end
	CONSOLE_AddMessage("Syntax: RefPass [password]")
	CONSOLE_AddMessage("Help: Sets the local referee password.")
	if Cfg.RefPass==nil or Cfg.RefPass=="" then CONSOLE_AddMessage("State: RefPass is disabled.") else
	CONSOLE_AddMessage("State: RefPass is "..tostring(Cfg.RefPass)) end
end

function Console:Cmd_REF(enable)    
	if(enable~=nil)then 
	if(Cfg.RconPass~=nil)then
	NET.SendVariable( NET.GetClientID(), "ref", tostring(NET.GetClientID())..","..Cfg.RconPass..","..enable )
	return 
	else
	NET.SendVariable( NET.GetClientID(), "ref", tostring(NET.GetClientID())..",".."hello"..","..enable )  
	return end end
	CONSOLE_AddMessage("Syntax: ref [command] [parameters]")
	CONSOLE_AddMessage("Help: Sends referee command to the server.")
end

function Console:Cmd_REFEREE(enable)  
	if(enable~=nil)then  
		enable = tonumber(enable) 
		if(enable and enable >= 0 and Game.PlayerStats[enable] and Game.PlayerStats[enable]~=nil)then 
			Game.PlayerStats[enable].Referee = true 
			Game.ConsoleMessageAll("Game.PlayerStats[tonumber(enable)].Name is now a referee.")  
			return 
		end
	else
		CONSOLE_AddMessage("Syntax: Referee [clientid]")
		CONSOLE_AddMessage("Help: Sets a player to referee status.")
	end
end

--function Console:Cmd_TIMEOUT() 
	--INP.SetTimeMultiplier(0.001)
--end
--function Console:Cmd_TIMEIN()  
	--INP.SetTimeMultiplier(1.0)
--end
function Console:Cmd_RELOADWAYPOINTS()
    Waypoint.Position = {}
    Waypoint:Load(Lev.Map)
end

function Console:Cmd_ROCKETFACTOR(factor)  
        if true then CONSOLE_AddMessage("RocketFactor is a restricted command.") end

	if(factor~=nil) then Cfg.RocketFactor = tonumber(factor) return CONSOLE_AddMessage("Factor set") end
	CONSOLE_AddMessage("Syntax: rocketfactor [number]")
	CONSOLE_AddMessage("Help: Sets the scaling factor between horizontal and vertical rockets.")	
	Game.ConsoleMessageAll("State: RocketFactor is currently "..tostring(Cfg.RocketFactor))	
end

function Console:Cmd_ROCKETFACTORORDER(factor)  
	if true then CONSOLE_AddMessage("RocketFactorOrder is a restricted command.") end

	if(factor~=nil) then Cfg.RocketFactorOrder = tonumber(factor) return CONSOLE_AddMessage("Factor set") end
	CONSOLE_AddMessage("Syntax: RocketFactorOrder [number]")
	CONSOLE_AddMessage("Help: Sets the exponent of the rocket direction factor.")	
	Game.ConsoleMessageAll("State: RocketFactorOrder is currently "..tostring(Cfg.RocketFactorOrder))	
end

function Console:Cmd_ROCKETEXPLOSIONSTRENGTH(factor)  
        if true then CONSOLE_AddMessage("RocketExplosionStrength is a restricted command.") end
        
	if(factor~=nil) then Cfg.RocketExplosionStrength = tonumber(factor) return CONSOLE_AddMessage("RocketExplosionStrength set") end
	CONSOLE_AddMessage("Syntax: RocketExplosionStrength [number]")
	CONSOLE_AddMessage("Help: Sets the explosion impulse strength.")	
	Game.ConsoleMessageAll("State: RocketExplosionStrength is currently "..tostring(Cfg.RocketFactorOrder))	
end



--=======================================================================
function Console:Cmd_PROPLUS(state)
	if(tonumber(state)==1) then Game:EnableProPlus() return end
	if(tonumber(state)==0) then Game:DisableProPlus() return end     
	CONSOLE_AddMessage("Syntax: proplus [0/1]")
	CONSOLE_AddMessage("Help: Sets the server to proplus mode.")
	if MPCfg.ProPlus then Game.ConsoleMessageAll("State: Proplus is enabled.")
	else Game.ConsoleMessageAll("State: Proplus is disabled.") end	
end




function Console:Cmd_TOGGLECONSOLE()
	if(Console.Activated)then
		CONSOLE.Activate(false)
		Console.Activated = false
	else
		CONSOLE.Activate(true)
		Console.Activated = true
	end
	--INP.BindKeyCommand("F1","Console:Cmd_TOGGLECONSOLE()")
end


function Console:Cmd_SERVERPASSWORD(password)
	if(password~=nil) then Cfg.ServerPassword = password end
	if(password==nil) then Cfg.ServerPassword = "" end
	CONSOLE_AddMessage("Syntax: ServerPassword [password]")
	CONSOLE_AddMessage("Help: Sets the server password.")
	if Cfg.ServerPassword=="" then CONSOLE_AddMessage("State: ServerPassword is disabled.")
	else CONSOLE_AddMessage("State: ServerPassword is now "..tostring(Cfg.ServerPassword)) end	
end

--function Console:Cmd_SERVERTIMELIMIT(state)
--	if(state~=nil) then Cfg.TimeLimit = state CONSOLE_AddMessage("State: TimeLimit is now "..tostring(Cfg.TimeLimit)) return end
--	CONSOLE_AddMessage("Syntax: TimeLimit [time]")
--	CONSOLE_AddMessage("Help: Sets the server TimeLimit.")
--	CONSOLE_AddMessage("State: TimeLimit is now "..tostring(Cfg.TimeLimit)) end	
--end
--
--function Console:Cmd_SERVERFRAGLIMIT(state)
--	if(state~=nil) then Cfg.FragLimit = state CONSOLE_AddMessage("State: FragLimit is now "..tostring(Cfg.FragLimit)) return end
--	CONSOLE_AddMessage("Syntax: FragLimit [frags]")
--	CONSOLE_AddMessage("Help: Sets the server FragLimit.")
--	CONSOLE_AddMessage("State: FragLimit is now "..tostring(Cfg.FragLimit)) end	
--end
--
--function Console:Cmd_SERVERGAMEMODE(state)
--	if(state~=nil) then Cfg.GameMode = state CONSOLE_AddMessage("State: GameMode is now "..tostring(Cfg.GameMode)) return end
--	CONSOLE_AddMessage("Syntax: GameMode [mode]")
--	CONSOLE_AddMessage("Help: Sets the server GameMode.")
--	CONSOLE_AddMessage("State: GameMode is now "..tostring(Cfg.GameMode)) end	
--end
--
--function Console:Cmd_SERVERMAXPLAYERS(state)
--	if(state~=nil) then Cfg.MaxPlayers = state CONSOLE_AddMessage("State: MaxPlayers is now "..tostring(Cfg.MaxPlayers)) return end
--	CONSOLE_AddMessage("Syntax: MaxPlayers [number]")
--	CONSOLE_AddMessage("Help: Sets the server MaxPlayers.")
--	CONSOLE_AddMessage("State: MaxPlayers is now "..tostring(Cfg.MaxPlayers)) end	
--end
--
--function Console:Cmd_SERVERMAXSPECTATORS(state)
--	if(state~=nil) then Cfg.MaxSpectators = state CONSOLE_AddMessage("State: MaxSpectators is now "..tostring(Cfg.MaxSpectators)) return end
--	CONSOLE_AddMessage("Syntax: MaxSpectators [number]")
--	CONSOLE_AddMessage("Help: Sets the server MaxSpectators.")
--	CONSOLE_AddMessage("State: MaxSpectators is now "..tostring(Cfg.MaxSpectators)) end	
--end


function Console:Cmd_NOBLOOD(enable)    
	if(enable=="1")then Cfg.NoBlood = true CONSOLE_AddMessage("NoBlood is now enabled.")  return end
	if(enable=="0")then Cfg.NoBlood = false CONSOLE_AddMessage("NoBlood is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoBlood [1/0]")
	CONSOLE_AddMessage("Help: Toggles blood rendering. May require a restart for full effect.")
	if Cfg.NoBlood then CONSOLE_AddMessage("State: NoBlood is currently on.")
	else CONSOLE_AddMessage("State: NoBlood is currently off.") end
end

function Console:Cmd_NOEXPLOSIONS(enable)    
	if(enable=="1")then Cfg.NoExplosions = true CONSOLE_AddMessage("NoExplosions is now enabled.")  return end
	if(enable=="0")then Cfg.NoExplosions = false CONSOLE_AddMessage("NoExplosions is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoExplosions [1/0]")
	CONSOLE_AddMessage("Help: Toggles explosion rendering. May require a restart for full effect.")
	if Cfg.NoExplosions then CONSOLE_AddMessage("State: NoExplosions is currently on.")
	else CONSOLE_AddMessage("State: NoExplosions is currently off.") end
end

function Console:Cmd_NOGIBS(enable)    
	if(enable=="1")then Cfg.NoGibs = true CONSOLE_AddMessage("NoGibs is now enabled.")  return end
	if(enable=="0")then Cfg.NoGibs = false CONSOLE_AddMessage("NoGibs is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoGibs [1/0]")
	CONSOLE_AddMessage("Help: Toggles gibs rendering.")
	if Cfg.NoGibs then CONSOLE_AddMessage("State: NoGibs is currently on. May require a restart for full effect.")
	else CONSOLE_AddMessage("State: NoGibs is currently off.") end
end	

function Console:Cmd_NOSMOKE(enable)    
	if(enable=="1")then Cfg.NoSmoke = true CONSOLE_AddMessage("NoSmoke is now enabled.")  return end
	if(enable=="0")then Cfg.NoSmoke = false CONSOLE_AddMessage("NoSmoke is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoSmoke [1/0]")
	CONSOLE_AddMessage("Help: Toggles smoke rendering.")
	if Cfg.NoSmoke then CONSOLE_AddMessage("State: NoSmoke is currently on. May require a restart for full effect.")
	else CONSOLE_AddMessage("State: NoSmoke is currently off.") end
end	

function Console:Cmd_NOSPAWNEFFECTS(enable)    
	if(enable=="1")then Cfg.NoSpawnEffects = true CONSOLE_AddMessage("NoSpawnEffects is now enabled.")  return end
	if(enable=="0")then Cfg.NoSpawnEffects = false CONSOLE_AddMessage("NoSpawnEffects is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoSpawnEffects [1/0]")
	CONSOLE_AddMessage("Help: Toggles spawn particle effects rendering.")
	if Cfg.NoSpawnEffects then CONSOLE_AddMessage("State: NoSpawnEffects is currently on. May require a restart for full effect.")
	else CONSOLE_AddMessage("State: NoSpawnEffects is currently off.") end
end	

function Console:Cmd_NOFLAMES(enable)    
	if(enable=="1")then Cfg.NoFlames = true CONSOLE_AddMessage("NoFlames is now enabled.")  return end
	if(enable=="0")then Cfg.NoFlames = false CONSOLE_AddMessage("NoFlames is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoFlames [1/0]")
	CONSOLE_AddMessage("Help: Toggles flame particle effects rendering.")
	if Cfg.NoFlames then CONSOLE_AddMessage("State: NoFlames is currently on. May require a restart for full effect.")
	else CONSOLE_AddMessage("State: NoFlames is currently off.") end
end	

function Console:Cmd_LOGGING(enable)    
	if(enable=="1")then Cfg.Logging = true CONSOLE_AddMessage("Logging is now enabled.")  return end
	if(enable=="0")then Cfg.Logging = false CONSOLE_AddMessage("Logging is now disabled.") return end
	CONSOLE_AddMessage("Syntax: Logging [1/0]")
	CONSOLE_AddMessage("Help: Toggles Logging.")
	if Cfg.Logging then CONSOLE_AddMessage("State: Logging is currently on.")
	else CONSOLE_AddMessage("State: Logging is currently off.") end
end	

function Console:Cmd_ROCKETLOGGING(enable)    
	if(enable=="1")then Cfg.RocketLogging = true CONSOLE_AddMessage("RocketLogging is now enabled.")  return end
	if(enable=="0")then Cfg.RocketLogging = false CONSOLE_AddMessage("RocketLogging is now disabled.") return end
	CONSOLE_AddMessage("Syntax: RocketLogging [1/0]")
	CONSOLE_AddMessage("Help: Toggles RocketLogging.")
	if Cfg.RocketLogging then CONSOLE_AddMessage("State: RocketLogging is currently on.")
	else CONSOLE_AddMessage("State: RocketLogging is currently off.") end
end	

function Console:Cmd_ROCKETFIX(enable)    
	if(enable=="1")then Cfg.RocketFix = true 
		Tweak.MultiPlayerMove.AlternateRocketJump = false
		WORLD.ApplyTweaks()
		CONSOLE_AddMessage("RocketFix is now enabled.")  
		Game:SendRocketFix()
		return end
	if(enable=="0")then Cfg.RocketFix = false
		Tweak.MultiPlayerMove.AlternateRocketJump = true
		WORLD.ApplyTweaks()
		CONSOLE_AddMessage("RocketFix is now disabled.") 
		Game:SendRocketFix()
		return end
	CONSOLE_AddMessage("Syntax: RocketFix [1/0]")
	CONSOLE_AddMessage("Help: Toggles PK++ RocketFix.")
	if Cfg.RocketFix then CONSOLE_AddMessage("State: RocketFix is currently on.")
	else CONSOLE_AddMessage("State: RocketFix is currently off.") end
end

function Console:Cmd_DEADBODYFIX(enable)  
	if true then CONSOLE_AddMessage("Command is disabled in this version.") return end  
	if(enable=="1")then Cfg.DeadBodyFix = true CONSOLE_AddMessage("DeadBodyFix is now enabled.")  return end
	if(enable=="0")then Cfg.DeadBodyFix = false CONSOLE_AddMessage("DeadBodyFix is now disabled.") return end
	CONSOLE_AddMessage("Syntax: DeadBodyFix [1/0]")
	CONSOLE_AddMessage("Help: Toggles PK++ DeadBodyFix.")
	if Cfg.DeadBodyFix then CONSOLE_AddMessage("State: DeadBodyFix is currently on.")
	else CONSOLE_AddMessage("State: DeadBodyFix is currently off.") end
end

function Console:Cmd_FREEZERFIX(enable)  
	if true then CONSOLE_AddMessage("Command is disabled in this version.") return end
	if(enable=="1")then Cfg.FreezerFix = true CONSOLE_AddMessage("FreezerFix is now enabled.")  return end
	if(enable=="0")then Cfg.FreezerFix = false CONSOLE_AddMessage("FreezerFix is now disabled.") return end
	CONSOLE_AddMessage("Syntax: FreezerFix [1/0]")
	CONSOLE_AddMessage("Help: Toggles PK++ FreezerFix.")
	if Cfg.FreezerFix then CONSOLE_AddMessage("State: FreezerFix is currently on.")
	else CONSOLE_AddMessage("State: FreezerFix is currently off.") end
end

function Console:Cmd_FALLINGDAMAGE(enable)    
	if(enable=="1")then Cfg.FallingDamage = true CONSOLE_AddMessage("FallingDamage is now enabled.")  return end
	if(enable=="0")then Cfg.FallingDamage = false CONSOLE_AddMessage("FallingDamage is now disabled.") return end
	CONSOLE_AddMessage("Syntax: FallingDamage [1/0]")
	CONSOLE_AddMessage("Help: Toggles FallingDamage.")
	if Cfg.FallingDamage then CONSOLE_AddMessage("State: FallingDamage is currently on.")
	else CONSOLE_AddMessage("State: FallingDamage is currently off.") end
end	

function Console:Cmd_WEAPONPREDICTION(enable)    
	if true then CONSOLE_AddMessage("Command is disabled in this version.") return end
	if(enable=="1")then Cfg.WeaponPrediction = true CONSOLE_AddMessage("WeaponPrediction is now enabled.")  return end
	if(enable=="0")then Cfg.WeaponPrediction = false CONSOLE_AddMessage("WeaponPrediction is now disabled.") return end
	CONSOLE_AddMessage("Syntax: WeaponPrediction [1/0]")
	CONSOLE_AddMessage("Help: Toggles WeaponPrediction.")
	if Cfg.WeaponPrediction then CONSOLE_AddMessage("State: WeaponPrediction is currently on.")
	else CONSOLE_AddMessage("State: WeaponPrediction is currently off.") end
end	

function Console:Cmd_AUTOSCREENSHOT(enable)    
	if(enable=="1")then Cfg.AutoScreenshot = true CONSOLE_AddMessage("AutoScreenshot is now enabled.")  return end
	if(enable=="0")then Cfg.AutoScreenshot = false CONSOLE_AddMessage("AutoScreenshot is now disabled.") return end
	CONSOLE_AddMessage("Syntax: AutoScreenshot [1/0]")
	CONSOLE_AddMessage("Help: Toggles AutoScreenshot.")
	if Cfg.AutoScreenshot then CONSOLE_AddMessage("State: AutoScreenshot is currently on.")
	else CONSOLE_AddMessage("State: AutoScreenshot is currently off.") end
end

function Console:Cmd_VERSION()    
	CONSOLE_AddMessage(PKPLUSPLUS_VERSION)
end	

function Console:Cmd_BLOWFISH()   
	Cfg.AltScoreboard = false
	Cfg.AmbientSounds = false
	Cfg.AmbientVolume = 0
	Cfg.AmmolistHideWeapons = false
	Cfg.AutoChangeWeapon = false
	Cfg.AutoScreenshot = false
	Cfg.AutoStatsDump = true
	Cfg.AutoTeamLock = false
	Cfg.Autorecord = false
	Cfg.Bloom = false
	Cfg.BotAttack = true
	Cfg.BotChat = false
	Cfg.BotCheckStubNose = true
	Cfg.BotEliza = false
	Cfg.BotFakePing = true
	Cfg.BotFindItems = true
	Cfg.BotMinPlayers = 2
	Cfg.BotQuickRespawn = true
	Cfg.BotSkill = 10
	Cfg.BrightSkins = true
	Cfg.Brightness = 1
	Cfg.BrightskinEnemy = "Cyan"
	Cfg.BrightskinTeam = "Blue"
	Cfg.CharacterShadow = "Off"
	Cfg.ColouredIcons = false
	Cfg.ConfigMapView = false
	Cfg.ConnectionSpeed = 5
	Cfg.Contrast = 1
	Cfg.Coronas = false
	Cfg.Credits = true
	Cfg.Crosshair = 3
	Cfg.CrosshairB = 0
	Cfg.CrosshairG = 255
	Cfg.CrosshairNames = true
	Cfg.CrosshairNamesDisableInDuel = true
	Cfg.CrosshairNamesTeamOnly = true
	Cfg.CrosshairR = 0
	Cfg.CrosshairSize = 1
	Cfg.CrosshairTrans = 100
	Cfg.CustomCrosshairLocation = false
	Cfg.CustomCrosshairLocationX = 0.5
	Cfg.CustomCrosshairLocationY = 0.5
	Cfg.Decals = false
	Cfg.DecalsStayTime = 1000
	Cfg.DedicatedServer = false
	Cfg.DetailTextures = false
	Cfg.DisableHud = false
	Cfg.DisableMOTDRendering = false
	Cfg.DisturbSound3DFreq = 0.1
	Cfg.DuelQueue = true
	Cfg.DynamicLights = 0
	Cfg.EAXAcoustics = true
	Cfg.FOV = 110
	Cfg.FPS = true
	Cfg.FallingDamage = true
	Cfg.FixedColors = false
	Cfg.ForceModel = true
	Cfg.ForceSpec = false
	Cfg.FragLimit = 0
	Cfg.Fullscreen = true
	Cfg.Gamma = 1.11
	Cfg.GraphicsQuality = 0
	Cfg.HUDSize = 2
	Cfg.HUDTransparency = 33
	Cfg.HUD_AmmoList = 0
	Cfg.HUD_CurrentWeapon_Icon = true
	Cfg.HUD_FragMessage = true
	Cfg.HeadBob = 0
	Cfg.HitSounds = true
	Cfg.ImpureClientWarning = false
	Cfg.InvertMouse = false
	Cfg.ItemRespawnFix = true
	Cfg.LimitServerFPS = false
	Cfg.Logfile = "GameLog"
	Cfg.LogfileDaily = true
	Cfg.Logging = true
	Cfg.LowQualityMultiplayerSFX = true
	Cfg.MOTD = " ;Enjoy your stay;Have fun!; "
	Cfg.MapView = false
	Cfg.MapViewShowRespawns = false
	Cfg.MasterVolume = 100
	Cfg.MaxFpsMP = 125
	Cfg.MaxPlayers = 8
	Cfg.MaxSpectators = 4
	Cfg.MouseSensitivity = 30
	Cfg.Multisample = "x0"
	Cfg.MusicVolume = 0
	Cfg.NetcodeClientMaxBytesPerSecond = -1
	Cfg.NetcodeEnemyPredictionInterpolation = true
	Cfg.NetcodeEnemyPredictionInterpolationFactor = 0.66
	Cfg.NetcodeLocalPlayerSynchroEveryNFrames = 45
	Cfg.NetcodeMaxPlayerActionsPassed = 1
	Cfg.NetcodeMinUpstreamFrameSize = 0
	Cfg.NetcodeServerFramerate = 45
	Cfg.NetcodeStatsNumberToAverageFrom = 1
	Cfg.NetcodeStatsUpdateDelay = 1000
	Cfg.Newhitsound = false
	Cfg.NoAmmoSwitch = false
	Cfg.NoBlood = true
	Cfg.NoExplosions = true
	Cfg.NoFlames = true
	Cfg.NoGibs = true
	Cfg.NoGong = true
	Cfg.NoMPComments = true
	Cfg.NoSmoke = true
	Cfg.NoSpawnEffects = true
	Cfg.NoWarmup = false
	Cfg.OldScoreboard = false
	Cfg.Overtime = 2
	Cfg.ParticlesDetail = 1
	Cfg.PitabotEnabled = false
	Cfg.PlayerModel = 3
	Cfg.PowerupDrop = false
	Cfg.Powerups = false
	Cfg.PrecacheData = 0
	Cfg.ProPlus = false
	Cfg.Projectors = false
	Cfg.PublicServer = false
	Cfg.PureScripts = false
	Cfg.RenderSky = 0
	Cfg.Resolution = "800x600"
	Cfg.RestartMaps = true
	Cfg.ReverseStereo = false
	Cfg.RocketFix = true
	Cfg.RocketLogging = false
	Cfg.RocketsFromGun = true
	Cfg.SafeRespawn = false
	Cfg.ScoreboardFontSize = 20
	Cfg.ScoreboardShowPacketLoss = false
	Cfg.SfxVolume = 100
	Cfg.Shadows = 0
	Cfg.ShowDaydreamWarning = true
	Cfg.ShowFPSShadow = true
	Cfg.ShowFPSShadowLevel = 2
	Cfg.ShowPing = false
	Cfg.ShowPingShadow = true
	Cfg.ShowPingShadowLevel = 2
	Cfg.ShowPingX = 0.8789
	Cfg.ShowPingY = 0.1412
	Cfg.ShowTimer = true
	Cfg.ShowTimerCountUp = false
	Cfg.ShowTimerFontSize = 45
	Cfg.ShowTimerShadow = true
	Cfg.ShowTimerShadowLevel = 2
	Cfg.ShowTimerX = -1
	Cfg.ShowTimerY = 0.0651
	Cfg.Simplehud = true
	Cfg.SmoothMouse = false
	Cfg.SoundFalloffSpeed = 6
	Cfg.SoundPan = 50
	Cfg.SoundProvider3D = "Miles Fast 2D Positional Audio"
	Cfg.SoundQuality = "Low"
	Cfg.SpeakersSetup = "Two Speakers"
	Cfg.StartupWeapon = 0
	Cfg.StopMatchOnTeamQuit = true
	Cfg.Team = 0
	Cfg.TeamDamage = true
	Cfg.TextureFiltering = "Bilinear"
	Cfg.TextureQuality = 0
	Cfg.TextureQualityArchitecture = 31
	Cfg.TextureQualityCharacters = 31
	Cfg.TextureQualitySkies = 31
	Cfg.TextureQualityWeapons = 31
	Cfg.TimeLimit = 15
	Cfg.ViewWeaponModel = false
	Cfg.WarmUpTime = 5
	Cfg.WarmupDamage = true
	Cfg.WarpEffects = false
	Cfg.WaterFX = 0
	Cfg.WeaponBob = 0
	Cfg.WeaponNormalMap = false
	Cfg.WeaponPrediction = true
	Cfg.WeaponRespawnTime = 15
	Cfg.WeaponSpecular = true
	Cfg.WeaponsStay = false
	Cfg.WeatherEffects = false
	Cfg.WheelSensitivity = 3
	Cfg.KeyPrimaryWeapon2 = "F"
	Cfg.KeyPrimaryWeapon3 = "R"
	Cfg.KeyPrimaryWeapon4 = "E"
	Cfg.KeyPrimaryWeapon5 = "C"
	
	
	Cfg.TeamScores = true
	Cfg.TeamScoresFontSize = 32
	Cfg.TeamScoresShadow = true
	Cfg.TeamScoresShadowLevel = 2
	Cfg.TeamScoresX = 0.86
	Cfg.TeamScoresY = 0.05
	
	Cfg.TeamOverlay = true
	Cfg.TeamOverlayFontSize = 16
	Cfg.TeamOverlayW = 0.3
	Cfg.TeamOverlayX = 0.7
	Cfg.TeamOverlayY = 0.6
	PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset()
	
	CONSOLE_AddMessage("Blowfish config executed.")
end

function Console:Cmd_DISABLEHUD(enable)    
	if(enable=="1")then Cfg.DisableHud = true CONSOLE_AddMessage("DisableHud is now enabled.")  return end
	if(enable=="0")then Cfg.DisableHud = false CONSOLE_AddMessage("DisableHud is now disabled.") return end
	CONSOLE_AddMessage("Syntax: DisableHud [1/0]")
	CONSOLE_AddMessage("Help: Toggles DisableHud.")
	if Cfg.DisableHud then CONSOLE_AddMessage("State: DisableHud is currently on.")
	else CONSOLE_AddMessage("State: DisableHud is currently off.") end
end

function Console:Cmd_NODECALS(enable)    
	if(enable=="1")then Cfg.DecalsStayTime = 1000 PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset() INP.SetUseDInput(Cfg.DirectInput) CONSOLE_AddMessage("NoDecals is now enabled.")  return end
	if(enable=="0")then Cfg.DecalsStayTime = 1 PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset() INP.SetUseDInput(Cfg.DirectInput) CONSOLE_AddMessage("NoDecals is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoDecals [1/0]")
	CONSOLE_AddMessage("Help: Toggles NoDecals. 'On' means Cfg.DecalsStayTime = 1000.")
	if Cfg.DecalsStayTime==1000 then CONSOLE_AddMessage("State: NoDecals is currently on.")
	else CONSOLE_AddMessage("State: NoDecals is currently off.") end
end

function Console:Cmd_PITABOTENABLED(enable)    
	if(enable=="1")then Cfg.PitabotEnabled = true CONSOLE_AddMessage("PitabotEnabled is now enabled.")  return end
	if(enable=="0")then Cfg.PitabotEnabled = false CONSOLE_AddMessage("PitabotEnabled is now disabled.") return end
	CONSOLE_AddMessage("Syntax: PitabotEnabled [1/0]")
	CONSOLE_AddMessage("Help: Toggles Pitabot On/Off.")
	if Cfg.PitabotEnabled then CONSOLE_AddMessage("State: PitabotEnabled is currently on.")
	else CONSOLE_AddMessage("State: PitabotEnabled is currently off.") end
end

function Console:Cmd_MOTD(enable)    
	if(enable~=nil)then Cfg.MOTD = tostring(enable) CONSOLE_AddMessage("MOTD Set.")  return end
	CONSOLE_AddMessage("Syntax: MOTD <text>")
	CONSOLE_AddMessage("Help: Sets MOTD.")
	CONSOLE_AddMessage("State: MOTD is currently "..tostring(Cfg.MOTD))
end


function Console:Cmd_TEXTUREQUALITY(enable)    
	if(enable~=nil)then Cfg.TextureQuality = tonumber(enable) CONSOLE_AddMessage("TextureQuality Set.") PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset()  return end
	CONSOLE_AddMessage("Syntax: TextureQuality <N>")
	CONSOLE_AddMessage("Help: Sets TextureQuality.")
	CONSOLE_AddMessage("State: TextureQuality is currently "..tostring(Cfg.TextureQuality))
end

function Console:Cmd_TEXTUREQUALITYARCHITECTURE(enable)    
	if(enable~=nil)then Cfg.TextureQualityArchitecture = tonumber(enable) CONSOLE_AddMessage("TextureQualityArchitecture Set.") PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset()  return end
	CONSOLE_AddMessage("Syntax: TextureQualityArchitecture <N>")
	CONSOLE_AddMessage("Help: Sets TextureQualityArchitecture.")
	CONSOLE_AddMessage("State: TextureQualityArchitecture is currently "..tostring(Cfg.TextureQualityArchitecture))
end

function Console:Cmd_TEXTUREQUALITYCHARACTERS(enable)    
	if(enable~=nil)then Cfg.TextureQualityCharacters = tonumber(enable) CONSOLE_AddMessage("TextureQualityCharacters Set.") PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset() return end
	CONSOLE_AddMessage("Syntax: TextureQualityCharacters <N>")
	CONSOLE_AddMessage("Help: Sets TextureQualityCharacters.")
	CONSOLE_AddMessage("State: TextureQualityCharacters is currently "..tostring(Cfg.TextureQualityCharacters))
end

function Console:Cmd_TEXTUREQUALITYSKIES(enable)    
	if(enable~=nil)then Cfg.TextureQualitySkies = tonumber(enable) CONSOLE_AddMessage("TextureQualitySkies Set.") PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset() return end
	CONSOLE_AddMessage("Syntax: TextureQualitySkies <N>")
	CONSOLE_AddMessage("Help: Sets TextureQualitySkies.")
	CONSOLE_AddMessage("State: TextureQualitySkies is currently "..tostring(Cfg.TextureQualitySkies))
end

function Console:Cmd_TEXTUREQUALITYWEAPONS(enable)    
	if(enable~=nil)then Cfg.TextureQualityWeapons = tonumber(enable) CONSOLE_AddMessage("TextureQualityWeapons Set.") PainMenu:ApplyVideoSettings() INP.SetUseDInput(Cfg.DirectInput) INP.Reset() return end
	CONSOLE_AddMessage("Syntax: TextureQualityWeapons <N>")
	CONSOLE_AddMessage("Help: Sets TextureQualityWeapons.")
	CONSOLE_AddMessage("State: TextureQualityWeapons is currently "..tostring(Cfg.TextureQualityWeapons))
end




function Console:Cmd_IMPURECLIENTWARNING(enable)    
	if(enable=="1")then Cfg.ImpureClientWarning = true CONSOLE_AddMessage("ImpureClientWarning is now enabled.")  return end
	if(enable=="0")then Cfg.ImpureClientWarning = false CONSOLE_AddMessage("ImpureClientWarning is now disabled.") return end
	CONSOLE_AddMessage("Syntax: ImpureClientWarning [1/0]")
	CONSOLE_AddMessage("Help: Toggles ImpureClientWarning On/Off.")
	if Cfg.ImpureClientWarning then CONSOLE_AddMessage("State: ImpureClientWarning is currently on.")
	else CONSOLE_AddMessage("State: ImpureClientWarning is currently off.") end
end

function Console:Cmd_CAMERAYAW(enable) 
	if(not Game._procSpec)then CONSOLE_AddMessage("Command only available in spectator mode") return end   
	local ax,ay,az = CAM.GetAng()
	if(enable~=nil) then
		enable = tonumber(enable)
		CAM.SetAng(enable, ay, 0)
		CONSOLE_AddMessage("Camera yaw is now: "..tostring(enable).." degrees.") 
		return
	end
	CONSOLE_AddMessage("Syntax: camerayaw [degrees]")
	CONSOLE_AddMessage("Help: Sets spectator camera yaw.")
	CONSOLE_AddMessage("Camera yaw is now: "..tostring(ax).." degrees.") 
end

function Console:Cmd_CAMERAPITCH(enable) 
	if(not Game._procSpec)then CONSOLE_AddMessage("Command only available in spectator mode") return end   
	local ax,ay,az = CAM.GetAng()
	if(enable~=nil) then
		enable = tonumber(enable)
		CAM.SetAng(ax, enable, 0)
		CONSOLE_AddMessage("Camera pitch is now: "..tostring(enable).." degrees.") 
		return
	end
	CONSOLE_AddMessage("Syntax: camerapitch [degrees]")
	CONSOLE_AddMessage("Help: Sets spectator camera pitch.")
	CONSOLE_AddMessage("Camera pitch is now: "..tostring(ay).." degrees.") 
end


--=======================================================================
function Console:Cmd_SET(params,silent)
	if not params or params == "" then
		if not silent then CONSOLE.AddMessage("usage: set variable value") end
		return
	end
	local i = string.find(params," ",1,true)
	if not i then i = string.len(params) + 1 end
	local variable = string.sub(params,1,i-1)
	params = Trim( string.sub(params,i) )
	Cfg[variable] = params
end

function Console:Cmd_SETS(params,silent)
	if not params or params == "" then
		if not silent then CONSOLE.AddMessage("usage: set variable value") end
		return
	end
	local i = string.find(params," ",1,true)
	if not i then i = string.len(params) + 1 end
	local variable = string.sub(params,1,i-1)
	params = Trim( string.sub(params,i) )
	Cfg[variable] = tostring(params)
end

function Console:Cmd_SETN(params,silent)
	if not params or params == "" then
		if not silent then CONSOLE.AddMessage("usage: set variable value") end
		return
	end
	local i = string.find(params," ",1,true)
	if not i then i = string.len(params) + 1 end
	local variable = string.sub(params,1,i-1)
	params = Trim( string.sub(params,i) )
	Cfg[variable] = tonumber(params)
end

function Console:Cmd_SETB(params,silent)
	if not params or params == "" then
		if not silent then CONSOLE.AddMessage("usage: set variable value") end
		return
	end
	local i = string.find(params," ",1,true)
	if not i then i = string.len(params) + 1 end
	local variable = string.sub(params,1,i-1)
	params = Trim( string.sub(params,i) )
	if(params=="true") then
	Cfg[variable] = true
	end
	if(params=="false") then
	Cfg[variable] =false
	end
end

function Console:Cmd_GET(params,silent)
	if not params or params == "" then
		if not silent then CONSOLE.AddMessage("usage: get variable") end
		return
	end
	Console:OnCommand(tostring(Cfg[params]))
end
--=======================================================================


function Console:Cmd_HITSOUNDS(enable)    
	if(enable=="1")then Cfg.HitSounds = true CONSOLE_AddMessage("HitSounds is now enabled.")  return end
	if(enable=="0")then Cfg.HitSounds = false CONSOLE_AddMessage("HitSounds is now disabled.") return end
	CONSOLE_AddMessage("Syntax: HitSounds [1/0]")
	CONSOLE_AddMessage("Help: Toggles HitSounds.")
	if Cfg.HitSounds then CONSOLE_AddMessage("State: HitSounds is currently on.")
	else CONSOLE_AddMessage("State: HitSounds is currently off.") end
end

function Console:Cmd_NOGONG(enable)    
	if(enable=="1")then Cfg.NoGong = true CONSOLE_AddMessage("NoGong is now enabled.")  return end
	if(enable=="0")then Cfg.NoGong = false CONSOLE_AddMessage("NoGong is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoGong [1/0]")
	CONSOLE_AddMessage("Help: Toggles NoGong.")
	if Cfg.NoGong then CONSOLE_AddMessage("State: NoGong is currently on.")
	else CONSOLE_AddMessage("State: NoGong is currently off.") end
end

function Console:Cmd_NOMPCOMMENTS(enable)    
	if(enable=="1")then Cfg.NoMPComments = true CONSOLE_AddMessage("NoMPComments is now enabled.")  return end
	if(enable=="0")then Cfg.NoMPComments = false CONSOLE_AddMessage("NoMPComments is now disabled.") return end
	CONSOLE_AddMessage("Syntax: NoMPComments [1/0]")
	CONSOLE_AddMessage("Help: Toggles NoMPComments.")
	if Cfg.NoMPComments then CONSOLE_AddMessage("State: NoMPComments is currently on.")
	else CONSOLE_AddMessage("State: NoMPComments is currently off.") end
end

--[[ legacy THRESHER
function Console:Cmd_COINTOSS(coin)  
	if( coin ~= nil ) then
	
		coin = tostring(coin)
		
		if( coin == "heads" or coin == "tails" ) then
			coin = tostring(coin)
			rnd  = FRand(1,1001)
			result = "WON"
				if( rnd <= 500 and coin == "tails" ) then result = "LOST"
				elseif( rnd > 500 and coin == "tails" ) then result = "WON"
				elseif( rnd > 500 and coin == "heads" ) then result = "LOST"
				end
				
			if( rnd <= 500 ) then
				Game.ConsoleMessageAll("COINTOSS "..string.upper(coin)..": It was HEADS! "..Cfg.PlayerName.." tossed a coin and "..result)
			elseif( rnd > 500 ) then
				Game.ConsoleMessageAll("COINTOSS "..string.upper(coin)..": It was TAILS! "..Cfg.PlayerName.." tossed a coin and "..result)
			end
		else
			CONSOLE_AddMessage("Syntax: cointoss <heads|tails>")
			CONSOLE_AddMessage("Help: simulates a cointoss for online games")
		end
	else
		CONSOLE_AddMessage("Syntax: cointoss <heads|tails>")
		CONSOLE_AddMessage("Help: simulates a cointoss for online games")
	end
end
]]--

function Console:Cmd_COINTOSS(clientID, coin)  
	
	if(clientID == ServerID and IsDedicatedServer()) then return end
	
	if( coin ~= nil and ( coin == "heads" or coin == "tails" ) ) then
	
		coin = tostring(coin)
		
		--if( coin == "heads" or coin == "tails" ) then
			coin = tostring(coin)
			rnd  = FRand(1,1001)
			result = "WON"
				if( rnd <= 500 and coin == "tails" ) then result = "LOST"
				elseif( rnd > 500 and coin == "tails" ) then result = "WON"
				elseif( rnd > 500 and coin == "heads" ) then result = "LOST"
				end
				
			--[[
			if( MPCfg.GameState ~= GameStates.WarmUp ) then
				if( rnd <= 500 ) then
				CONSOLE_AddMessage("COINTOSS "..string.upper(coin)..": It was HEADS! You tossed a coin and "..result)
				elseif( rnd > 500 ) then
				CONSOLE_ConsoleMessageAll("COINTOSS "..string.upper(coin)..": It was TAILS! You tossed a coin and "..result)
				end
			]]--
			
			--elseif( MPCfg.GameState == GameStates.WarmUp ) then
			if( MPCfg.GameState == GameStates.WarmUp ) then
				if( rnd <= 500 ) then
					Game.ConsoleMessageAll("COINTOSS "..string.upper(coin)..": It was HEADS! "..Game.PlayerStats[clientID].Name.." tossed a coin and "..result)
				elseif( rnd > 500 ) then
					Game.ConsoleMessageAll("COINTOSS "..string.upper(coin)..": It was TAILS! "..Game.PlayerStats[clientID].Name.." tossed a coin and "..result)
				end
			end
		--else
			--CONSOLE_AddMessage("Syntax: cointoss <heads|tails>")
			--CONSOLE_AddMessage("Help: simulates a cointoss for online games")
		--end
	else
		--[[ THRESHER -- save this for a client update ]]--
		--Game.ConsoleClientMessage(clientID,"Syntax: !cointoss <heads|tails>",R3D.RGB(255,0,0))
		--Game.ConsoleClientMessage(clientID,"Help: simulates a cointoss for online games",R3D.RGB(255,0,0))
	end
end

function Console:Cmd_SPECTALK(clientID, txt) 

	local ps = Game.PlayerStats[clientID]
	
	if clientID == ServerID and not ps then
        ps = {Name = "Dedicated Admin"}
        
    end
	
    if not ps or ps.Spectator == 0 then return end
	
	
	--if(clientID == ServerID and IsDedicatedServer()) then return end	-- dedicated server can't spec talk :<
	
	if( txt == nil ) then return end -- no text, really shouldn't get here to be honest :)
	
	txt = tostring( txt )
            
    for i,o in Game.PlayerStats do
        if o.Spectator == 1 then 
            if o.ClientID == ServerID then
				 --RawCallMethod(Game.ConsoleClientMessage, clientID, true, true, ServerID, txt, R3D.RGB(255,0,255))
				 Game.ConsoleClientMessage(ServerID,false, true, ServerID, "[spec]"..txt, R3D.RGB(255,0,255))
            else
                --Game.ConsoleClientMessage("[spec]"..o.ClientID,txt,R3D.RGB(255,0,255))
				 --RawCallMethod(Game.ConsoleClientMessage, o.clientID, true, true, ServerID, "[spec]"..txt, R3D.RGB(255,0,255))
				 Game.ConsoleClientMessage(clientID,false, true, o.clientID, "[spec]"..txt, R3D.RGB(255,0,255))
            end
        end
    end

end