--=====================================================================================
function Hud:DrawMOTD()

	if(not Hud or MPCfg.MOTD==nil) then return end
	local w,h = R3D.ScreenSize()
	local font = "Impact"
	local fontfactor = h / 600	
	local linespacing = 1.2
	local mediumfont = 24
	local line = mediumfont*fontfactor*linespacing
	
	-- BREAK INTO LINES
	local txt = ""
	local rest = MPCfg.MOTD  
	 
	local linelevel = h*0.6
	local pattern = "([^%;]+);([%p%s%w%d]+)"
	
	local fade = 1.0
	local timeinout = 3
	if(Hud._MOTDTime - INP.GetTime() < timeinout) then fade = (Hud._MOTDTime - INP.GetTime())/timeinout end
	if(((INP.GetTime() - (Hud._MOTDTime - 10))) < timeinout) then fade = (((INP.GetTime() - (Hud._MOTDTime - 10))))/timeinout end	
	local poo = math.floor(80*fade)
	local pie = math.floor(255*fade)
	

	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
		txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	
	txt = string.gsub(rest, pattern , "%1")  
	if(txt~=nil)then HUD.PrintXY(w*0.2,linelevel,txt,font,poo,pie,poo,mediumfont) end	
	rest = string.gsub(rest, pattern , "%2")
	linelevel = linelevel + line
	  
	
	
end
--=====================================================================================
function Hud:DrawTeamScores(indicateID)
	if(not Hud) then return end
	if(indicateID<0)then indicateID = 999 end
	local w,h = R3D.ScreenSize()
	local border = 4
	--local largefont = math.floor(0.1*0.8 * w)
	if(Cfg.TeamScoresFontSize == nil)then Cfg.TeamScoresFontSize = 26 end
	local mediumfont = Cfg.TeamScoresFontSize
	local font = "Impact"
	local bigfont = "Impact"
	if(Cfg.TeamScoresX == nil)then Cfg.TeamScoresX = 0.86 end
	if(Cfg.TeamScoresY == nil)then Cfg.TeamScoresY = 0.82 end
	local scorepanel = {x = Cfg.TeamScoresX, y = Cfg.TeamScoresY, w = 0.11, d = 0.11}
	local bluescore = 0
	local redscore = 0
	local highlight = 1
	scorepanel.w = scorepanel.w * Cfg.TeamScoresFontSize / 32 
	--if(scorepanel.y*h + scorepanel.d*h > (768-Cfg.HUDSize*98)*h/768) then scorepanel.y = (((768-Cfg.HUDSize*98)*h/768) - scorepanel.d*h) / h end
	
	if(MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams)then
		-- GET BLUE SCORE
		for id,ps in Game.PlayerStats do 
			if ps.Spectator == 0 and ps.Team == 1 then
				bluescore = bluescore + ps.Score
			end
		end
		-- GET RED SCORE
		
		for id,ps in Game.PlayerStats do 
			if ps.Spectator == 0 and ps.Team == 0 then
				redscore = redscore + ps.Score
			end
		end	
	end
	
	-- FIX TWEAK
		
	bluescore = Game._team2Score
        redscore = Game._team1Score
                
	-- WIDEN FOR LARGE SCORES
	if(bluescore>99 or redscore>99)then 
		scorepanel.w = scorepanel.w * 3/2
	end	
	if(bluescore>999 or redscore>999)then 
		scorepanel.w = scorepanel.w * 3/2
	end			
	if(MPGameRules[MPCfg.GameMode] and not MPGameRules[MPCfg.GameMode].Teams and Game.PlayerStats[indicateID]~=nil)then
		-- FFA FIRST
		-- IF NOT TOP SCORER AND FRAGLIMIT, FRAGLIMIT, ME
		-- IF NOT TOP SCORER AND NO FRAGLIMIT, ME, SECOND PLACE
		-- IF TOP SCORER, ME SECOND PLACE
	
			redscore = Game.PlayerStats[indicateID].Score
			if(MPCfg.FragLimit~=0)then
				redscore = MPCfg.FragLimit
				bluescore = Game.PlayerStats[indicateID].Score
				highlight = 1
			end
	end
	


	if(MPCfg.GameMode=="Duel")then	
		-- DUEL CHECK
		local dueller1 = -1
		local dueller2 = -1
		for i,ps in Game.PlayerStats do 
			if ps.Spectator == 0 and dueller1 ~= -1 then dueller2 = ps.ClientID end
			if ps.Spectator == 0 and dueller1 == -1 then dueller1 = ps.ClientID end
		end
		if(MPCfg.GameMode=="Duel" and dueller1>=0 and Game.PlayerStats[dueller1]~=nil)then
			bluescore =  Game.PlayerStats[dueller1].Score
		end
		if(MPCfg.GameMode=="Duel" and dueller2>=0 and Game.PlayerStats[dueller2]~=nil)then
			redscore = Game.PlayerStats[dueller2].Score
		end	
		if(indicateID==dueller1)then
		highlight = 0
		end
		if(indicateID==dueller2)then
		highlight = 1
		end
	end
	
	if(MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams and Game.PlayerStats[indicateID]~=nil)then
		
		if Game.PlayerStats[indicateID].Team==1 then highlight = 0 end
		if Game.PlayerStats[indicateID].Team==0 then highlight = 1 end
	end
	
	--INDICATE ME
	
	local outerh = mediumfont*h / 768+(border*2)+2
	local innerw = ((w*scorepanel.w)/2)-(border*2)
	local shiftx = (w*scorepanel.w)/2
	
	if(highlight==1)then
		-- top middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+border,h*scorepanel.y,innerw,border,255,255,255,255)
		-- left vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x,h*scorepanel.y,border,outerh,255,255,255,255)
		-- right vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+innerw+border,h*scorepanel.y,border,outerh,255,255,255,255)
				-- bottom middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+border,h*scorepanel.y+outerh-border,innerw,	border,255,255,255,255)
		-- top middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+border,h*scorepanel.y,innerw,border,255,255,255,255)
		-- left vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x,h*scorepanel.y,border,outerh,255,255,255,255)
		-- right vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+innerw+border,h*scorepanel.y,border,outerh,255,255,255,255)
				-- bottom middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+border,h*scorepanel.y+outerh-border,innerw,	border,255,255,255,255)
		-- top middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+border,h*scorepanel.y,innerw,border,255,255,255,255)
		-- left vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x,h*scorepanel.y,border,outerh,255,255,255,255)
		-- right vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+innerw+border,h*scorepanel.y,border,outerh,255,255,255,255)
				-- bottom middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	w*scorepanel.x+border,h*scorepanel.y+outerh-border,innerw,	border,255,255,255,255)
	elseif(highlight==0)then
		-- top middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+border,h*scorepanel.y,innerw,border,255,255,255,255)
		-- left vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x,h*scorepanel.y,border,outerh,255,255,255,255)
		-- right vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+innerw+border,h*scorepanel.y,border,outerh,255,255,255,255)
				-- bottom middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+border,h*scorepanel.y+outerh-border,innerw,	border,255,255,255,255)
		-- top middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+border,h*scorepanel.y,innerw,border,255,255,255,255)
		-- left vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x,h*scorepanel.y,border,outerh,255,255,255,255)
		-- right vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+innerw+border,h*scorepanel.y,border,outerh,255,255,255,255)
				-- bottom middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+border,h*scorepanel.y+outerh-border,innerw,	border,255,255,255,255)
		-- top middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+border,h*scorepanel.y,innerw,border,255,255,255,255)
		-- left vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x,h*scorepanel.y,border,outerh,255,255,255,255)
		-- right vertical
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+innerw+border,h*scorepanel.y,border,outerh,255,255,255,255)
				-- bottom middle horizontal
		HUD.DrawQuadRGBA(Hud._matGreenPix,	shiftx+ w*scorepanel.x+border,h*scorepanel.y+outerh-border,innerw,	border,255,255,255,255)
	end
	HUD.DrawQuadRGBA(	Hud._matBluePix,	w*scorepanel.x,h*scorepanel.y,					w*scorepanel.w/2,										outerh,255,255,255,255)
	HUD.DrawQuadRGBA(	Hud._matRedPix,		shiftx + w*scorepanel.x,h*scorepanel.y,					w*scorepanel.w/2,		outerh,255,255,255,255)

	local ts1x = w*scorepanel.x + border + 1 + innerw/2 - Cfg.TeamScoresFontSize * 0.3
	local ts2x = ts1x + shiftx
	local tsy = h*scorepanel.y + border + border/2 + 1

  if Cfg.TeamScoresShadow then
	HUD.PrintXY(	ts1x+2,tsy+Cfg.TeamScoresShadowLevel,	redscore,font,0,0,0,mediumfont)
	HUD.PrintXY(	ts2x+2,tsy+Cfg.TeamScoresShadowLevel,	bluescore,font,0,0,0,mediumfont)
	end
	
	HUD.PrintXY(	ts1x,tsy,	redscore,font,255,255,255,mediumfont)
	HUD.PrintXY(	ts2x,tsy,	bluescore,font,255,255,255,mediumfont)

end

--============================================================================
function Hud:GetCrosshairPlayerName()
    --ENTITY.RemoveFromIntersectionSolver(pe)
    local b,d,x,y,z,nx,ny,nz,he,e = Player:Trace(100)
    --ENTITY.AddToIntersectionSolver(pe)   
    if b and e then
	for i,ps in Game.PlayerStats do
		if(ps and ps._Entity and ps._Entity ~=0)then
			if(ps._Entity == e)then return ps.ClientID end
		end 
	end
    end
    return -1
end
--============================================================================
function Hud:DrawTeamOverlay()
	if(not Hud) then return end
	local w,h = R3D.ScreenSize()
	local font ="Impact"
	if(Cfg.TeamOverlayFontSize == nil)then Cfg.TeamOverlayFontSize = 26 end
	local smallfont = Cfg.TeamOverlayFontSize --math.floor(14 * h / 480)
	
	local linespacing = 1.0
	if(Cfg.TeamOverlayX == nil)then Cfg.TeamOverlayX = 0.7 end
	if(Cfg.TeamOverlayY == nil)then Cfg.TeamOverlayY = 0.6 end
	if(Cfg.TeamOverlayW == nil)then Cfg.TeamOverlayW = 0.3 end
	local overlaypanel = {x = Cfg.TeamOverlayX, y = Cfg.TeamOverlayY, w = Cfg.TeamOverlayW, d = 0.1}
	local panelfraction = {status  = 0.0, name = 0.075, location = 0.45}
	-- ADJUSTMENTS FOR LOTS OF PLAYERS
	local font = "Impact"
	local bigfont = "Impact"
	local fontfactor = h / 600
	local delta = smallfont*fontfactor
	--local scorepanel = {x = Cfg.TeamOverlayX, y = Cfg.TeamOverlayY, w = 0.1, d = 0.1}
	local bluescore = 0
	local redscore = 0
	local vspace = (smallfont*linespacing - smallfont)
	
	local botcount = 0
	local playercount = 0
	local bluecount = 0
	local redcount = 0
	local speccount = 0	
	for i,ps in Game.PlayerStats do
		    	if ps.Team == 0 and ps.Spectator == 0 then
		    		bluecount = bluecount + 1
		    	end
		    	if ps.Team == 1 and ps.Spectator == 0 then
		    		redcount = redcount + 1
		    	end
	end
		
	-- RESIZE BASED ON TEAM
	if(Player.Team==0)then
		overlaypanel.d = ((bluecount+1) * smallfont*fontfactor) / h
	else
		overlaypanel.d = ((redcount+1) * smallfont*fontfactor) / h
	end
	
	HUD.DrawQuadRGBA(Hud._matBluePix,w*overlaypanel.x,h*overlaypanel.y,w*overlaypanel.w,h*overlaypanel.d,255,255,255,960)
	HUD.DrawQuadRGBA(Hud._matGreenPix,w*overlaypanel.x,h*overlaypanel.y,w*overlaypanel.w,smallfont*fontfactor,255,255,255,960)
	
	HUD.PrintXY(	w*overlaypanel.x+w*panelfraction.name*overlaypanel.w,		h*overlaypanel.y+vspace+2,	"Name",font,255,255,255,smallfont)
	HUD.PrintXY(	w*overlaypanel.x+w*panelfraction.location*overlaypanel.w,	h*overlaypanel.y+vspace+2,	"Location",font,255,255,255,smallfont)
	
	for i,ps in Game.PlayerStats do 
		if ps.Spectator == 0 and Game:IsTeammate(ps.ClientID) then
			local areaname = Game:GetLocation(ps.ClientID)
			if(areaname==nil)then areaname="" end
			--INDICATE ME
			if(Game.GetMyID()==ps.ClientID)then
				HUD.DrawQuadRGBA(Hud._matBluePix,w*overlaypanel.x,h*overlaypanel.y+delta,w*overlaypanel.w,smallfont*fontfactor,255,255,255,960)
			end
			local playerstate = ""
			for ii,o in Game.Players do
				if o.ClientID == ID then 
						if o.HasQuad then playerstate = "Q" end
						if o.HasWeaponModifier then playerstate = "M" end
						if o.HasPentagram then playerstate = "P" end
						if o.HasFlag then playerstate = "F" end
				end
			end
			HUD.PrintXY(	w*overlaypanel.x+w*panelfraction.status*overlaypanel.w,		h*overlaypanel.y+delta+2,		playerstate,font,255,255,255,smallfont)
			HUD.PrintXY(	w*overlaypanel.x+w*panelfraction.name*overlaypanel.w,		h*overlaypanel.y+delta+2,		ps.Name,font,255,255,255,smallfont)
			HUD.PrintXY(	w*overlaypanel.x+w*panelfraction.location*overlaypanel.w,	h*overlaypanel.y+delta+2,		areaname,font,255,255,255,smallfont)	
			delta = delta + smallfont*fontfactor
		end
	end
end
--============================================================================
function Hud:DrawBotInfo()
	if(not Hud) then return end
	local w,h = R3D.ScreenSize()
	--if(Game.PlayerStats[7]==nil)then return end
	local font ="Impact"
	local smallfont = 11
	for i,o in Game.Players do
		if o.ClientID == 6 then 
			--ENTITY.SetVelocity(Game.PlayerStats[7]._Entity,Tweak.MultiPlayerMove.PlayerSpeed*0.4*v.X,0,Tweak.MultiPlayerMove.PlayerSpeed*0.4*v.Z)	
			--ENTITY.SetVelocity(Game.PlayerStats[7]._Entity,vl*entx,vl*enty,vl*entz)	        
				        
			--ENTITY.SetOrientation(Game.PlayerStats[7]._Entity, math.pi-self.botangle)
			--ENTITY.PO_SetMovedByExplosions(Game.PlayerStats[7]._Entity,true)

				
			--ENTITY.PO_AddAction(Game.PlayerStats[7]._Entity,Actions.Forward)
			--PLAYER.ExecMultiPlayerAction(self._Entity,Actions.Forward,o.ForwardVector.X,o.ForwardVector.Y,o.ForwardVector.Z,0,0,0) 
			
			--_velocityx = 0,
			--_velocityy = 0,
			--_velocityz = 0,
			
			local entx,enty,entz,vl = ENTITY.GetVelocity(Game.PlayerStats[7]._Entity)
			HUD.PrintXY(100,100,"Entity vels : "..entx.." "..enty.." "..entz.." "..vl,font,255,255,255,smallfont)	
			HUD.PrintXY(100,110,"ForwardVector : "..o.ForwardVector.X.." "..o.ForwardVector.Y.." "..o.ForwardVector.Z.." ",font,255,255,255,smallfont)	
			HUD.PrintXY(100,120,"cplayer vels : "..o._velocityz.." "..o._velocityz.." "..o._velocityz.." "..o._yaw,font,255,255,255,smallfont)
			if(o:IsOnGround())then HUD.PrintXY(100,130,"shit : ON GROUND ",font,255,255,255,smallfont)end
			HUD.PrintXY(100,140,"ACTION : ON FLOOR "..tostring(INP.GetActionStatus(Game.PlayerStats[7]._Entity)).." "..tostring(Game.bot[7].state),font,255,255,255,smallfont)
			--if(ENTITY.PO_IsShocked(Game.PlayerStats[7]._Entity))then HUD.PrintXY(100,150,"shit : SHOCLKED ",font,255,255,255,smallfont)end
				
			HUD.PrintXY(100,150,"cfdsfdsfdsls : "..o._velocityz.." "..o._velocityz.." "..o._velocityz.." "..o._yaw,font,255,255,255,smallfont)			
			HUD.PrintXY(100,90,"BOT",font,255,255,255,smallfont)	
		end
	end 
end