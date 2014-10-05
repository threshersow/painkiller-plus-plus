--============================================================================
function Game:IsTeammate(clientid)
	if not(MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams)then
		return false
	end
	-- CHECK MY ID
	local me = Game.GetMyID()
	if(me==-99)then return false end
	-- CHECK TEAMMATE
	if(not Game.PlayerStats[clientid]) then return false end
	if Game.PlayerStats[me].Spectator == 0 and Game.PlayerStats[clientid].Spectator == 0 and Game.PlayerStats[me].Spectator == 0 and Game.PlayerStats[clientid].Team == Game.PlayerStats[me].Team then
		return true
	end
	return false
end
--=======================================================================
function Game:IsMapRestartDue()
	local willrestart = true

    	local maps =  PainMenu.mapsOnServer
    	if maps and table.getn(maps) > 0 then
        for i=1,table.getn(maps) do
            if string.upper(maps[i]) == string.upper(Lev._Name) then
                if maps[i+1]  then 
                    if string.upper(maps[i+1]) ~= string.upper(Lev._Name)  or not Cfg.RestartMaps then
                     	willrestart = false              
                    else
                    	willrestart = true
                    end
                    return willrestart
                else
                    if string.upper(maps[1]) ~= string.upper(Lev._Name)  or not Cfg.RestartMaps then
                     	willrestart = false
                    else
                    	willrestart = true
                    end
                end
                return willrestart
            end
        end
        if string.upper(maps[1]) ~= string.upper(Lev._Name)  or not Cfg.RestartMaps then
        	willrestart = false
        else
        	willrestart = true	
        end 
        return willrestart      
    end
    if Cfg.RestartMaps then
    	return true
    else
     	return false
    end
end
--=======================================================================
--============================================================================
function Game:GetMyID()
	local me = -99
	for i,ps in Game.PlayerStats do 
		if(Player == Game:FindPlayerByClientID(ps.ClientID))then
			me = ps.ClientID
		end
	end
	return me
end
--============================================================================
function Game:GetLocation(clientid)
	local areaname = "Unknown"
	local min = 1000000
	local x = 0
	local y = 0
	local z = 0
        if Game.PlayerStats[clientid]~=nil and Game.PlayerStats[clientid]._Entity~=nil then   		               
		x,y,z = ENTITY.PO_GetPawnHeadPos(Game.PlayerStats[clientid]._Entity) 
		--MsgBox("Entity okay")
	end
	--if(x==nil or y==nil or z==nil)then return areaname end
	--for i,locitem in Loc.Position do	
		--local px = locitem.x
		--local py = locitem.y
		--local pz = locitem.z 
		--MsgBox("PIE something "..px..py..pz..min)
		--if(x~=nil and y~=nil and z~=nil and px~=nil and py~=nil and pz~=nil)then 
		--min = Dist3D(x,y,z,px,px,px)
		--end
		--areaname = locitem.location
	--end
	for i,locitem in Loc.Position do 
		--if(locitem~=nil)then 
		        local px = locitem.x
		        local py = locitem.y
		        local pz = locitem.z	      
		        --if(px==nil or py==nil or pz==nil)then return areaname end
			if(Dist3D(x,y,z,px,py,pz)<min)then
				--if(locitem.location~=nil)then
			        	areaname = locitem.location
			        --else
			        	--areaname = "Somewhere"
				--end
				min = Dist3D(x,y,z,px,py,pz)
			end
	        --end
	end 
	return areaname
end
--============================================================================
function Game:GetLocationByPosition(x,y,z)
	local areaname = "Unknown"
	local min = 1000000
	for i,locitem in Loc.Position do 
		--if(locitem~=nil)then 
		        local px = locitem.x
		        local py = locitem.y
		        local pz = locitem.z	      
		        --if(px==nil or py==nil or pz==nil)then return areaname end
			if(Dist3D(x,y,z,px,py,pz)<min)then
			        areaname = locitem.location
				min = Dist3D(x,y,z,px,py,pz)
			end
	        --end
	end 
	return areaname
end
--============================================================================
function Game:ClientMapRestart() 
	GObjects:ToKill(Game._procStats)
	Game._procStats = nil
end
--============================================================================
function Game:NextRound() 
    if Game:IsServer() then 
    	-- TBD
    	CONSOLE_AddMessage ("Round Started.")
    end
end
--============================================================================
Game._recordinggame = false
--============================================================================
function Game:AutoRecordStart()
	if(Game._recordinggame==nil)then Game._recordinggame = false end
	if(Game._autoscreenshot==nil)then Game._autoscreenshot = true end
	if not Game._recordinggame then
		local timestamp = os.date( "%d-%m-%y-%X", os.time() )
		local p1name = nil
		local p2name = nil
		for i,o in Game.PlayerStats do
			if o.Spectator == 0 then
				if not p1name then
					p1name = HUD.StripColorInfo(o.Name)
				else
					p2name = HUD.StripColorInfo(o.Name)
				end
			end
		end
		
		-- SWAP
		if(Player)then
			if HUD.StripColorInfo(Game.PlayerStats[Player.ClientID].Name) == p2name then
				local temp = p1name
				p1name = p2name
				p2name = temp
			end
		end
		
		if(p1name==nil or p1name=="")then p1name = "Unknown" end
		if(p2name==nil or p2name=="")then p2name = "Unknown" end

			
		p1name = string.gsub(p1name, ":", "_", 200)
		p1name = string.gsub(p1name, "\"", "_", 200)
		p1name = string.gsub(p1name, "/", "_", 200)
		p1name = string.gsub(p1name, "\\", "_", 200)
		p1name = string.gsub(p1name, "<", "_", 200)
		p1name = string.gsub(p1name, ">", "_", 200)
		p1name = string.gsub(p1name, "|", "_", 200)
		p1name = string.gsub(p1name, "*", "_", 200)
		p1name = string.gsub(p1name, "?", "_", 200)
		
		p2name = string.gsub(p2name, ":", "_", 200)
		p2name = string.gsub(p2name, "\"", "_", 200)
		p2name = string.gsub(p2name, "/", "_", 200)
		p2name = string.gsub(p2name, "\\", "_", 200)
		p2name = string.gsub(p2name, "<", "_", 200)
		p2name = string.gsub(p2name, ">", "_", 200)
		p2name = string.gsub(p2name, "|", "_", 200)
		p2name = string.gsub(p2name, "*", "_", 200)
		p2name = string.gsub(p2name, "?", "_", 200)
		
		local levelname = ""
		if(Lev==nil or Lev._Name==nil)then levelname = "Unknown" 
		else levelname = Lev._Name end
		if Cfg~=nil and MPCfg~=nil then
			if Cfg.Autorecord and MPCfg.GameState == GameStates.Counting then 
				timestamp = string.gsub (timestamp, ":", "-")
				Console:Cmd_DEMORECORD (""..p1name.."-"..p2name.."."..levelname.."."..timestamp)
				CONSOLE_AddMessage ("DEMO RECORDING STARTED Time:"..timestamp)
				Game._recordinggame = true
			end
		end
	end
end
--============================================================================
function Game:AutoRecordStop()
	if(Game._recordinggame==nil)then Game._recordinggame = false end
	if Game._recordinggame then Game._recordinggame = false Console:Cmd_DEMOSTOP() end
end
--============================================================================
function Game:AutoScreenshot()
	if(Game._autoscreenshot==nil)then Game._autoscreenshot = true end
	if Game._autoscreenshot and Cfg.AutoScreenshot then Game._autoscreenshot = false INP.TakeScreenshot() end
end
--============================================================================
function Game:CheckOvertime()
    	if Game:IsServer() and Cfg.Overtime  ~= nil and Cfg.Overtime ~= 0 and Game._TimeLimitOut ~= nil and MPCfg.TimeLimit ~= nil then
    		if MPCfg.GameState == GameStates.Playing then
	    		if((MPCfg.TimeLimit*60 - Game._TimeLimitOut) < 2)then
			    	local p1score = nil
			    	local p2score = nil
			    	local playercount = 0
			    	local redcount = 0
			    	local bluecount = 0
			    	for i,o in Game.PlayerStats do
			       		if o.Spectator == 0 then
			       			if not p1score then
			       				p1score = o.Score
			       			else
				       			p2score = o.Score
			       			end
			       			playercount = playercount + 1
			       			if(o.Team == 0) then
			       			redcount = redcount + 1
			       			end
			       			if(o.Team == 1) then
			       			bluecount = bluecount + 1
			       			end
			    		end
			    	end
			       	if (MPCfg.TimeLimit*60 - Game._TimeLimitOut) < 2 then
			       	if not(MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams)then
			        	if p1score == p2score and playercount >= 2 then
			        		local totaltime = MPCfg.TimeLimit + Cfg.Overtime
				            	Game.SetTimeLimit(totaltime,Game._TimeLimitOut)
						MPSTATS.SetFragLimit(MPCfg.FragLimit)
				                Game.ConsoleMessageAll( "Overtime: "..tostring(Cfg.Overtime).." min" )
			        	end
			        else
			            	if Game._team1Score == Game._team2Score and redcount >= 1 and bluecount >= 1 then
			        		local totaltime = MPCfg.TimeLimit + Cfg.Overtime
				            	Game.SetTimeLimit(totaltime,Game._TimeLimitOut)
						MPSTATS.SetFragLimit(MPCfg.FragLimit)
				                Game.ConsoleMessageAll( "Overtime: "..tostring(Cfg.Overtime).." min" )
			        	end	
			        end	
			    	end
			end
		end
	end
end
--============================================================================


function Game:GetTimeoutState()
	for i, o in Game.PlayerStats do
		Game.PlayerStats[o.ClientID].tox,Game.PlayerStats[o.ClientID].toy,Game.PlayerStats[o.ClientID].toz = ENTITY.PO_GetPawnHeadPos(Game.PlayerStats[o.ClientID]._Entity) 
	end
end
--=======================================================================
function Game:Timeout()
	for i, o in Game.PlayerStats do
		ENTITY.PO_SetPawnHeadPos(Game.PlayerStats[o.ClientID]._Entity,Game.PlayerStats[o.ClientID].tox,Game.PlayerStats[o.ClientID].toy,Game.PlayerStats[o.ClientID].toz) 
	end
end
--=======================================================================
function Game:AutoStatsDump()
	Game.DumpNextStats = true
	Console:Cmd_STATSDUMP()
end
--==============================================================
function Game:EnableProPlus()
	--MsgBox(tostring(Tweak.MultiPlayerMove.AlternateRocketJump))
	--Tweak.MultiPlayerMove.AlternateRocketJump = false
	if(Game:IsServer()) then 
		Cfg.ProPlus = true 
		Game:Server2ClientCommand(0,"enableproplusall")
		if(not MPCfg.ProPlus)then
			--Game.ConsoleMessageAll( "#1***ProPlus has now been enabled on the server***" )
		end
	end
	if(not MPCfg.ProPlus)then
		    	CONSOLE_AddMessage ("#1***ProPlus has now been enabled on the server***")
	end
	MPCfg.ProPlus = true
	--WORLD.ApplyTweaks()
	if(Cfg.RocketFix)then
		--Tweak.MultiPlayerMove.AlternateRocketJump = false
		--WORLD.ApplyTweaks()
	else
		--Tweak.MultiPlayerMove.AlternateRocketJump = false
		--WORLD.ApplyTweaks()
	end	
end
--==============================================================
function Game:DisableProPlus()
	--MsgBox(tostring(Tweak.MultiPlayerMove.AlternateRocketJump))
	--Tweak.MultiPlayerMove.AlternateRocketJump = true
	if(Game:IsServer()) then 
		Cfg.ProPlus = false 
		Game:Server2ClientCommand(0,"disenableproplusall")
		if(MPCfg.ProPlus)then
			--Game.ConsoleMessageAll( "#1***ProPlus has now been disabled on the server***" )
		end
	end
	if(MPCfg.ProPlus)then
		    	CONSOLE_AddMessage ("#1***ProPlus has now been disabled on the server***")
	end
	MPCfg.ProPlus = false
	--WORLD.ApplyTweaks()
	if(Cfg.RocketFix)then
		--Tweak.MultiPlayerMove.AlternateRocketJump = false
		--WORLD.ApplyTweaks()
	else
		--Tweak.MultiPlayerMove.AlternateRocketJump = true
		--WORLD.ApplyTweaks()
	end	
end
--==============================================================
function Game:SendHitSound(kID)
	for i, ps in Game.PlayerStats do
		if(ps.Spectator == 1) then
			NET.SendVariable( ps.ClientID, "HITSND", tostring(kID) )
		end
	end
end
--==============================================================
function Game:SendDeathSound(kID)
	for i, ps in Game.PlayerStats do
		if(ps.Spectator == 1) then
			NET.SendVariable( ps.ClientID, "DTHSND", tostring(kID) )
		end
	end
end
--==============================================================
function Game:SendRocketFix()
	for i, ps in Game.PlayerStats do
		if(Cfg.RocketFix)then
		NET.SendVariable( ps.ClientID, "RFX", "1" )
		else
		NET.SendVariable( ps.ClientID, "RFX", "0" )
		end
	end
end
--==============================================================
function Game:SortDuelQueue()
	--if Game.DuelQueueDone then return end
	--if(Game:IsServer() and not Game:IsMapDue())then
		--MPCfg.TeamLock = false
		--MPCfg.GameState = GameStates.WarmUp
		--Game:DuelQueue()
		--Game.DuelQueueDone = true
	--end
end
--=======================================================================
function Game:ResetAllClientsState()
        for i,ps in Game.PlayerStats do
        	if not ps.Bot then	
        		SendNetMethod(Game.SetStateConfirmation,ps.ClientID, true, true, 0)
        	end
        	Game.SetStateConfirmation(ps.ClientID, 0)
        end 
end
--=======================================================================
function Game:ResetAllClientsGameState()
        for i,ps in Game.PlayerStats do
        	SendNetMethod(Game.SetGameState,ps.ClientID, true, true, MPCfg.GameState)
        end 
end
--=======================================================================
function Game:ResetClientScores()
    	for i,ps in Game.PlayerStats do
	    	ps.Score = 0
	    	ps.Kills = 0
	    	ps.Deaths = 0
	     	MPSTATS.Update(ps.ClientID, ps.Name, ps.Score, ps.Kills, ps.Deaths, ps.Ping, ps.PacketLoss, ps.Team, ps.State, ps.Spectator)  
		Game.NewPlayerTeamConfirmation(ps.ClientID,ps.Team)
	end   
end
--=======================================================================
function Game:ResetClientSpectatorState(includingbots)
    	for i,ps in Game.PlayerStats do
    		if(includingbots)then
			Game.PlayerSpectatorRequest(ps.ClientID,ps.Spectator)
		elseif(not ps.Bot)then
			Game.PlayerSpectatorRequest(ps.ClientID,ps.Spectator)
		end
	end   
end
--=======================================================================
function Game:ResetAllPlayersToSpectator(includingbots)
    	for i,ps in Game.PlayerStats do
		Game:Player2Spectator(ps.ClientID,includingbots)
	end   
end
--=======================================================================
function Game:ResetAllPlayersToPlayers(includingbots)
    	for i,ps in Game.PlayerStats do
    		if(ps.Spectator == 0)then
			Game:Spectator2Player(ps.ClientID,includingbots)
		end 
	end   
end
--=======================================================================
function Game:RespawnAllPlayers()
    	for i,ps in Game.PlayerStats do
    		if(ps.Spectator==0)then
			Game:PlayerRespawnRequest(ps.ClientID)
		end
	end   
end
--=======================================================================
function Game:ResetAllSpectators()
    	for i,ps in Game.PlayerStats do
    		if(ps.Spectator==1)then
			Game:AfterClientDisconnected(ps.ClientID)
			Game.PlayerSpectatorConfirmation(ps.ClientID,1)  
		end
	end   
end
--=======================================================================
function Game:ResetGameState()
        MPCfg.GameState = MPGameRules[Cfg.GameMode].StartState  
    	Game.IgnoreRespawner = nil
    	Game.ClearStats()
    	Game._countTimer = 0
    	Game._countTimerStart = nil 	   
   	MPCfg.TeamLock = false 
        if Cfg.NoWarmup then MPCfg.GameState = GameStates.Counting end
        Game.SetConfiguration(Cfg.AllowBrightskins, Cfg.GameMode, Cfg.FragLimit, Cfg.CaptureLimit, Cfg.LMSLives, Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
        Game.SetTimeLimit(Cfg.TimeLimit,0,Cfg.WarmUpTime)                
        Game.VooshCurWeapon = math.random(1,5)        
        GAMESPY.SetGameMode(2)  
end
--=======================================================================
function Game:ClearGameState()
	Game._team1Score = 0
        Game._team2Score = 0
        MPSTATS.SetTeamsScore(0,0)    
end
--=======================================================================
function Game:Player2Spectator(clientid,includingbots)
	if(includingbots==true)then
	Game:AfterClientDisconnected(clientid)
	Game.PlayerSpectatorConfirmation(clientid,1)  
	elseif(not Game.PlayerStats[clientid].Bot)then
	Game:AfterClientDisconnected(clientid)
	Game.PlayerSpectatorConfirmation(clientid,1)  
	end
end
--=======================================================================
function Game:Spectator2Player(clientid,includingbots)
	if(includingbots==true)then
	Game:AfterClientDisconnected(clientid)
	Game.PlayerSpectatorConfirmation(clientid,0)  
	elseif(not Game.PlayerStats[clientid].Bot)then
	Game:AfterClientDisconnected(clientid)
	Game.PlayerSpectatorConfirmation(clientid,0)  
	end
end
--=======================================================================
function Game:ResetAllPlayers()
    	for i,ps in Game.PlayerStats do
		Game.ResetPlayer(ps.ClientID)
	end   
end

--=======================================================================
function Game:MapRestart()  
    
    if Game:IsServer() then 
    
    	if(Game:IsServer())then
		if (Game._procStats)then
			GObjects:ToKill(Game._procStats)
			Game._procStats = nil
		end
	end
	      
    	-- TESTED AND WORKING DO NOT CHANGE
	Game:ResetGameState()
	Game:ClearGameState()
	Game:ResetAllClientsState()
	Game:ResetAllClientsGameState()
	Game:ResetClientSpectatorState(false)
	Game:RespawnAllPlayers()
	Game:ResetAllSpectators()
	Game:ResetClientScores()
	-- TESTED AND WORKING DO NOT CHANGE
	

	
	--Game:AfterWorldSynchronization(Lev.Map,Lev._Name)  
		
    	CONSOLE_AddMessage ("Map Restarted.")
    end
    
 if Game:IsServer() then 
    	local teamsize = 8
        local maxplayers = Cfg.MaxPlayers
        if Cfg.GameMode == "Duel" and not Cfg.ForceSpec then maxplayers = 2 end
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
	    Game._TimeLimitOut,
	    gameState,
	    numPlayers,
	    numSpecs
        )
        if Cfg.AllowBunnyhopping then 
            PHYSICS.SetBunnyHopAcceleration(Tweak.MultiPlayerMove.BunnyHopAcceleration)
        else
            PHYSICS.SetBunnyHopAcceleration(0)
        end

	if(Cfg.ProPlus) then Game:EnableProPlus() else Game:DisableProPlus() end
	
        MPCfg.GameState = MPGameRules[Cfg.GameMode].StartState        
        if Cfg.NoWarmup then MPCfg.GameState = GameStates.Counting end
        Game.SetConfiguration(Cfg.AllowBrightskins, Cfg.GameMode, Cfg.FragLimit, Cfg.CaptureLimit, Cfg.LMSLives, Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
        Game.SetTimeLimit(Cfg.TimeLimit,0,Cfg.WarmUpTime)                
        Game.VooshCurWeapon = math.random(1,5)        
        GAMESPY.SetGameMode(2)        
    else
        -- reset ping
        NET.ClientPingReset()
    end 
    
end



function duff()

 if Game:IsServer() then 
    	local teamsize = 8
        local maxplayers = Cfg.MaxPlayers
        if Cfg.GameMode == "Duel" and not Cfg.ForceSpec then maxplayers = 2 end
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
            levelName,
            Cfg.GameMode,
            maxplayers,
            Cfg.MaxSpectators,
            Cfg.FragLimit,
            Cfg.TimeLimit,
	    Game._TimeLimitOut,
	    gameState,
	    numPlayers,
	    numSpecs
        )
        
        if Cfg.AllowBunnyhopping then 
            PHYSICS.SetBunnyHopAcceleration(Tweak.MultiPlayerMove.BunnyHopAcceleration)
        else
            PHYSICS.SetBunnyHopAcceleration(0)
        end

	if(Cfg.ProPlus) then Game:EnableProPlus() else Game:DisableProPlus() end
	
        MPCfg.GameState = MPGameRules[Cfg.GameMode].StartState        
        if Cfg.NoWarmup then MPCfg.GameState = GameStates.Counting end
        Game.SetConfiguration(Cfg.AllowBrightskins, Cfg.GameMode, Cfg.FragLimit, Cfg.CaptureLimit, Cfg.LMSLives, Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
        Game.SetTimeLimit(Cfg.TimeLimit,0,Cfg.WarmUpTime)                
        Game.VooshCurWeapon = math.random(1,5)        
        GAMESPY.SetGameMode(2)        
    else
        -- reset ping
        NET.ClientPingReset()
    end
end


--============================================================================
function Game:DuelQueue()
    -- DUEL QUEUE
    --if true then return end
    --Game.ConsoleMessageAll("Testing for Duel Queue")
    if Cfg.DuelQueue and Game:IsServer() and MPCfg.GameMode == "Duel" then 
    	Game.ConsoleMessageAll("Running Duel Queue")
    	-- FIND LOSER
    	local player1 = nil
    	local player2 = nil
    	for i,ps in Game.PlayerStats do
		if ps.Spectator == 0 then
			if player1~=nil then
				player2 = ps.ClientID
			else
				player1 = ps.ClientID
			end
		end
	end
	local loser = player1
	if player1~=nil and player2~=nil then
		loser = player1
		if Game.PlayerStats[player1].Score > Game.PlayerStats[player2].Score then
			loser = player2
    			Game.ConsoleMessageAll( Game.PlayerStats[player1].Name.." beat ".. Game.PlayerStats[player2].Name..", "..tostring(Game.PlayerStats[player1].Score).." - "..tostring(Game.PlayerStats[player2].Score))	
		elseif(Game.PlayerStats[player1].Score < Game.PlayerStats[player2].Score)then
			loser = player1
			Game.ConsoleMessageAll( Game.PlayerStats[player2].Name.." beat ".. Game.PlayerStats[player1].Name..", "..tostring(Game.PlayerStats[player2].Score).." - "..tostring(Game.PlayerStats[player1].Score))
		else
			loser = nil
			Game.ConsoleMessageAll( Game.PlayerStats[player1].Name.." drew with ".. Game.PlayerStats[player2].Name..", "..tostring(Game.PlayerStats[player1].Score).." - "..tostring(Game.PlayerStats[player2].Score))
		end
	end
  	
    	-- FIND MAX GAME COUNT
    	local maxplayer = nil
    	local max = 0
    	for i,ps in Game.PlayerStats do
		if ps.Spectator == 1 then
			local ggc = Game.GameCount[ps.ClientID]
			if(ggc==nil)then ggc = 0 end
    			ggc = ggc + 1
    			if ggc >= max then maxplayer = ps.ClientID max = ggc end	
 
    		end
    	end
    	if(maxplayer~=nil)then
    		Game.ConsoleMessageAll( Game.PlayerStats[maxplayer].Name.." has waited the longest" )
    	end
    	if loser~=nil and maxplayer~=nil and player1~=nil and player2~=nil then   		
        	if loser~=nil and maxplayer~=nil and Game.PlayerStats[loser]~=nil and Game.PlayerStats[maxplayer]~=nil then Game.ConsoleMessageAll( "Swapping "..Game.PlayerStats[loser].Name.." with "..Game.PlayerStats[maxplayer].Name ) end
    		Game.GameCount[loser] = 0
    		Game.GameCount[maxplayer] = 0  
		Game.DuelQueueTime = 30
		Game.DuelQueuePlayer1 = maxplayer
		if(loser==player1) then Game.DuelQueuePlayer2 = player2 end
		if(loser==player2) then Game.DuelQueuePlayer2 = player1 end
		if Game:IsMapRestartDue() then
			Game:AfterClientDisconnected(loser)
			Game.PlayerSpectatorConfirmation(loser,0)  
			NET.SetSpectator(loser,1)
			Console:Cmd_FORCEJOIN(maxplayer)
		end
    	end
    end
end
--==============================================================