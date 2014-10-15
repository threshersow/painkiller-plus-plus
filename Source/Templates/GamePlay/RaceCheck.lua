function RaceCheck:PreApply()
    if self.isFinish == 0 then
        self.Model = "flag_red"
		--self.Scale = 2.5
    else
        self.Model = "checkpoint"
		--self.Scale = 0.8
    end
end
--============================================================================
function RaceCheck:OnPrecache()
	Cache:PrecacheParticleFX("checkpoint_fx2")    
	Cache:PrecacheParticleFX("checkpoint_fx1") 
end
--============================================================================
function RaceCheck:OnCreateEntity()
	self:BindFX("checkpoint_fx2",0.1,"root")
	self:BindFX("checkpoint_fx1",0.1,"e1")
	self:BindFX("checkpoint_fx1",0.1,"e2")
	self:BindFX("checkpoint_fx1",0.1,"e3")
	MDL.SetAnim(self._Entity,"idle",true,2.0)
end
--============================================================================
function RaceCheck:OnApply(old)
	ENTITY.EnableDraw(self._Entity,not self.Frozen,true)
	--ENTITY.EnableDraw(self._Entity,true)
end
--============================================================================
function RaceCheck:OnLaunch(monsterstokill,leavePrev)
	--[[
	if monsterstokill then
		self.MonstersToKill = Game.BodyCountTotal + monsterstokill
		if leavePrev then self.leavePrev = leavePrev end
		return
	end
	]]--

	PlaySound2D("misc/checkpoint-demon")

	self.Frozen = false
	self:OnApply()

	--[[
	if not self.leavePrev then
		for i,v in GObjects.CheckPoints do
			if v ~= self and v.BaseObj ~= "pentakl.CItem" and v.BaseObj ~= "C5L3_Krzyz.CItem" then
				if not v.Frozen then
					v.Frozen = true
					v:OnApply()
				end
			end
		end
	end
	]]--
end
--============================================================================
function RaceCheck:OnUpdate()
	--[[
	if self.MonstersToKill then
		if Game.BodyCountTotal >= self.MonstersToKill then
			if not self._LaunchTimer then
				self._LaunchTimer = INP.GetTime()
			else
				if INP.GetTime() - self._LaunchTimer > self.delay then
					self.MonstersToKill = nil
					self:OnLaunch()
				end
			end
		end
	end
	]]--
end
function RaceCheck:Update()
	-- prevents the CItem update from running
end
--============================================================================
function RaceCheck:OnTake(player)
	if self.Frozen then return end
	if not player then return end



    local snd = self.SoundTake[math.random(1, table.getn(self.SoundTake))]
    SOUND.Play2D(snd,nil,nil,nil,nil,true)

	--self.Frozen = true


end
--============================================================================
function RaceCheck:OnShow()
	self.Frozen = false
	self:OnApply()
end
--============================================================================
function RaceCheck:OnHide()
	self.Frozen = false  -- original True
	self:OnApply()
end
--============================================================================
function RaceCheck:Tick(delta)

	if MPCfg.GameMode ~= "Race" then return end 
		
    for i,o in Game.Players do
		if o._died then 
			local ps = Game.PlayerStats[o.ClientID]
				ps._isRacing = false
				ps._raceStartTime = 0 
		end
        if not o._died then
            local px,py,pz = ENTITY.GetPosition(o._Entity)

            if PLAYER.GetDistanceFromPoint(o._Entity,self.Pos.X,self.Pos.Y-1,self.Pos.Z) <= self.takeDistance then 
			
				local ps = Game.PlayerStats[o.ClientID]
				local player = EntityToObject[o._Entity]
				
				if self.isFinish == 1 and ps._isRacing then -- is finish line
					
						ps._raceFinishTime = INP.GetTime() - ps._raceStartTime
							ps._raceFinishTime = tonumber( ps._raceFinishTime )
						
							local _currentTimeString = RaceTimeString( ps._raceFinishTime )
								
								local txt = string.gsub("$PLAYER finishes race in " .. _currentTimeString ,"$PLAYER",ps.Name)
								
								SOUND.Play2D("multiplayer/ctf/score",nil,nil,nil,nil,true)
								
								if( ps._raceBestTime == 0 or ps._raceBestTime == nil or ps._raceBestTime > ps._raceFinishTime) then -- if no record/finish or set a new record
								
									txt = txt .. " #4[Personal #4Best]"
										ps._raceBestTime = ps._raceFinishTime
									SOUND.Play2D("multiplayer/lucifer/Lucifer_good03",nil,nil,nil,nil,true)
								else
									txt = txt .. " #2[Personal #2Best:#2" .. RaceTimeString( ps._raceBestTime ) .."]" -- if no personal record set
								end
					
						ps._isRacing = false -- No longer racing
					
						-- respawn the player after capture, only called on server, otherwise player's client crashes :( 
						if( player and Game:IsServer() ) then player:OnDamage(999999,nil,AttackTypes.ConsoleKill) end
						
						CONSOLE_AddMessage(txt)
				
				elseif self.isFinish == 0 and not ps._isRacing then -- starting line
				
					local txt = string.gsub("$PLAYER starts race","$PLAYER",ps.Name)
					if( MPCfg.GameMode == "Race" ) then
							ps._isRacing = true
							ps._raceStartTime = INP.GetTime()
							local snd = self.SoundTake[math.random(1, table.getn(self.SoundTake))]
								SOUND.Play2D(snd,nil,nil,nil,nil,true)
								--PlaySound3D(snd,px,py+2,pz,15,50,player,true) 
							CONSOLE_AddMessage(txt)
					end
					
				end              

            end
        end
    end
	
end
