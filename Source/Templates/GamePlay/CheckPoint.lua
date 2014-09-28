--============================================================================
function CheckPoint:OnPrecache()
	Cache:PrecacheParticleFX("checkpoint_fx2")    
	Cache:PrecacheParticleFX("checkpoint_fx1") 
end
--============================================================================
function CheckPoint:OnCreateEntity()
	self:BindFX("checkpoint_fx2",0.1,"root")
	self:BindFX("checkpoint_fx1",0.1,"e1")
	self:BindFX("checkpoint_fx1",0.1,"e2")
	self:BindFX("checkpoint_fx1",0.1,"e3")
	MDL.SetAnim(self._Entity,"idle",true,2.0)
end
--============================================================================
function CheckPoint:OnApply(old)
	ENTITY.EnableDraw(self._Entity,not self.Frozen,true)
end
--============================================================================
function CheckPoint:OnLaunch(monsterstokill,leavePrev)
	if monsterstokill then
		self.MonstersToKill = Game.BodyCountTotal + monsterstokill
		if leavePrev then self.leavePrev = leavePrev end
		return
	end

	PlaySound2D("misc/checkpoint-demon")

	self.Frozen = false
	self:OnApply()

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
end
--============================================================================
function CheckPoint:OnUpdate()
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
end
--============================================================================
function CheckPoint:OnTake(player)
	if self.Frozen then return end
	if not player then return end

	if player.Health < Game.HealthCapacity then
		if Game.Difficulty < 2 then
			player.Health = Game.HealthCapacity
			CONSOLE_AddMessage(Languages.Texts[685])
		end
	end

    local snd = self.SoundTake[math.random(1, table.getn(self.SoundTake))]
    SOUND.Play2D(snd,nil,nil,nil,nil,true)

	self.Frozen = true

	Game.CheckPoint = Game.CheckPoint + 1
    SaveGame:SaveRequest(nil,"CheckPoint")
end
--============================================================================
function CheckPoint:OnShow()
	self.Frozen = false
	self:OnApply()
end
--============================================================================
function CheckPoint:OnHide()
	self.Frozen = true
	self:OnApply()
end
