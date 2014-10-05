--============================================================================
function Game:Server2ClientCommand(clientid,command,param)
	-- SERVER SENDING MESSAGES TO THE CLIENT
	-- WHERE SPAM COMES FROM
	if(param==nil)then param="" end
	if(command == "pollall")then
		if Game:IsServer() then           
	    		for i,ps in Game.PlayerStats do
	    			--if(Game.PlayerStats[ps.ClientID].Version==nil)then Game.PlayerStats[ps.ClientID].Version = false end
				if(Game.PlayerStats[ps.ClientID].Version==false or Game.PlayerStats[ps.ClientID].Version==nil)then					
					local txt = "Please install PK++ www.pkzone.org"
					SendNetMethod(Game.ConsoleClientMessage, ps.ClientID, true, true, ServerID, txt, 0)
				end
			end
		end
	end
	if(command == "enableproplusall")then
		if Game:IsServer() then           
	    		for i,ps in Game.PlayerStats do
	    			if(Game.PlayerStats[ps.ClientID].Version==true)then	
					local txt = "CMD:PROPLUS1"
					SendNetMethod(Game.ConsoleClientMessage, ps.ClientID, true, true, ServerID, txt, 0)
				end
			end
		end
	end
	if(command == "disenableproplusall")then
		if Game:IsServer() then           
	    		for i,ps in Game.PlayerStats do
	    			if(Game.PlayerStats[ps.ClientID].Version==true)then
					local txt = "CMD:PROPLUS0"
					SendNetMethod(Game.ConsoleClientMessage, ps.ClientID, true, true, ServerID, txt, 0)
				end
			end
		end
	end
	if(command == "CMD:PRINTSTATSALL" 
	or command == "PK++VERSIONOKAY" 
	or command == "CMD:STATSDUMP" 
	or command == "CMD:STATS"
	or command == "PK++VERSIONOKAY"
	or command == "PK++ Authenticated.")then
		if Game:IsServer() then           
	    		for i,ps in Game.PlayerStats do
				if(ps.ClientID~=nil and ps.ClientID == clientid)then --and Game.PlayerStats[ps.ClientID].Version
					SendNetMethod(Game.ConsoleClientMessage, ps.ClientID, true, true, ServerID, command..param, 0)
				end
			end
		end
	end
end
--============================================================================
function Game:Server2ClientRead(txt)
	-- COMMANDS READ ON CLIENT
	--MsgBox("got data "..txt)
	    local pattern = "(%w+),(%w+),(%w+),(%w+),(%w+),(%w+),(%w+),(%w+)"
	    local check = string.gsub(txt, pattern , "%1")  
	    if(check=="L33T")then
	    	local specplayerid = string.gsub(txt, pattern, "%2")
	    	specplayerid = tonumber(specplayerid)
	    	if(specplayerid >= 0)then	
		    	local specplayeridhealth = string.gsub(txt, pattern, "%3")
		    	local specplayeridarmor = string.gsub(txt, pattern, "%4")
		    	local specplayeridweapon = string.gsub(txt, pattern, "%5")
		    	local specplayeridammo1 = string.gsub(txt, pattern, "%6")
		    	local specplayeridammo2 = string.gsub(txt, pattern, "%7")
			local specplayeridarmortype = string.gsub(txt, pattern, "%8")
		    	
		    	Game.PlayerData[specplayerid] = {ClientID = specplayerid, Health = tonumber(specplayeridhealth),Armour = tonumber(specplayeridarmor),Weapon = tonumber(specplayeridweapon),Ammo1 = tonumber(specplayeridammo1),Ammo2 = tonumber(specplayeridammo2),ArmorType = tonumber(specplayeridarmortype)}	
	    	end
	    	return true
	    end
	    pattern = "(%w+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+)"
	    check = string.gsub(txt, pattern , "%1")  
	    if(check=="ST4TZ")then
	    		--MsgBox("got stats id,type,hits,shots,dmg - "..txt)
			local statsclientid = string.gsub(txt, pattern, "%2")
		    	statsclientid = tonumber(statsclientid)
		   	local statsattacktype = string.gsub(txt, pattern, "%3")
		    	statsattacktype = tonumber(statsattacktype)
		    	local statshits = string.gsub(txt, pattern, "%4")
		    	statshits = tonumber(statshits)
		    	local statshots = string.gsub(txt, pattern, "%5")
		    	statshots = tonumber(statshots)
		    	local statsdamage = string.gsub(txt, pattern, "%6")
		    	statsdamage = tonumber(statsdamage)
		    	--MsgBox("check: "..tostring(statsclientid).." "..tostring(statsattacktype).." "..tostring(statshits).." "..tostring(statshots).." "..tostring(statsdamage))
		    	Game:SetStats(statsclientid,statsattacktype,statshits,statshots,statsdamage)    
		    	return true   
	    end
	    if(txt == "Please install PK++ www.pkzone.org")then
	    	CONSOLE_AddMessage("Attempting to auth with server.")
	    	Game:Client2ServerCommand("CMD:PK++VERSIONOKAY")
	    	return true
	    end	
	    if(txt == "CMD:PROPLUS1")then
	    	if(MPCfg.ProPlus~=true)then
	    		CONSOLE_AddMessage("#1***Proplus on Client Enabled***")
	    	end
	    	--CONSOLE_AddMessage("Proplus Enabled.")
	    	MPCfg.ProPlus = true
	    	return true
	    end	  
	    if(txt == "CMD:PROPLUS0")then
	    	if(MPCfg.ProPlus~=false)then
	    		CONSOLE_AddMessage("#1***Proplus on Client Disabled***")
	    	end
	    	--CONSOLE_AddMessage("Proplus Disabled.")
	    	MPCfg.ProPlus = false
	    	return true
	    end	    
	    if(txt == "CMD:PRINTSTATSALL")then
	    	Console:Cmd_PRINTSTATSALL()
	    	return true
	    end	
	    if(txt == "CMD:STATSDUMP")then
	    	Console:Cmd_STATSDUMP()
	    	return true
	    end	
		if(txt=="CMD:GETPLAYERSETTINGS")then	-- This should force the client to print out net settings, model, etc...
			Console:Cmd_GETPLAYERSETTINGS()
			return true
		end
	    local cmdpattern = "CMD:(%w+):([0-9%a%p%d%s]+)"
	    local cmdcmd = string.gsub(txt, pattern , "%1") 
	    local cmdparam = string.gsub(txt, pattern , "%1")  	    
	    if(cmdcmd == "CMD:PRINT")then
	    	CONSOLE_AddMessage(tostring(cmdparam))
	    	return true
	    end	
	    return false
end
--============================================================================
function Game:Client2ServerCommand(command)
	-- CLIENT SENDING COMMANDS TO THE SERVER
	--SendNetMethod(Game.SayToAll, NET.GetClientID(),command ,0)
	
	--if Player and Player.ClientID == ServerID then
		--RawCallMethod(Game.ConsoleClientMessage,NET.GetClientID(),txt,0) 
	--else
	--MsgBox("Client2ServerCommand "..command)
	--SendNetMethod(Game.ConsoleClientMessage, ServerID, true, true, Player.ClientID,command,0)
	--end
	Game.SayToAll(NET.GetClientID(), command)
end
--============================================================================
function Game:Client2ServerRead(clientid, txt)
	-- COMMANDS READ ON SERVER
	--MsgBox("Client2ServerRead"..txt..clientid)
	if(txt=="CMD:PK++VERSIONOKAY")then 
		CONSOLE_AddMessage(Game.PlayerStats[clientid].Name.." authed PK++ client.")
		Game.PlayerStats[clientid].Version = true 
		Game:Server2ClientCommand(clientid, "PK++ Authenticated.")
		return true 
	end
	if(txt=="CMD:UPDATESTATSALL")then
		CONSOLE_AddMessage("Stats sent.")
		Game:UpdateStats(clientid,"all")
		Game:Server2ClientCommand(clientid, "CMD:PRINTSTATSALL")
		return true
	end
	return false
end
--============================================================================






