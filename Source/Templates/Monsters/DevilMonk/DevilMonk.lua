function DevilMonk:OnInitTemplate()
    self:SetAIBrain()
end

function DevilMonk:OnCreateEntity()
	self._fx2 = self:BindFX(self.FX,0.3,'br1',-0.9,0,0)
end



function DevilMonk:CustomUpdate()
	if self._fx2 and not self._gibbed then
		if math.random(100) < 20 and Player then
			self._checkSpeed = 30/self.Poison.checkSpeed 
			local x,y,z = ENTITY.GetPosition(self._fx2)
			local dist = Dist3D(x,y,z, Player._groundx,Player._groundy, Player._groundz)
			local distLast = 9999
			if self._fx_lastx then
				distLast = Dist3D(self._fx_lastx,self._fx_lasty,self._fx_lastz, Player._groundx,Player._groundy, Player._groundz)
			end
			if dist < self.Poison.Range or distLast < self.Poison.Range then
				--Game:Print("PLAYER poisoned")
                --Player:PlaySoundHit2D("hero/hero_poison"..math.random(1,3))
                
                if not SOUND2D.IsPlaying(Player._oldSND) then
	                Player._oldSND = PlaySound2D("hero/hero_poison"..math.random(1,3),nil,nil,true)
	            end
                
				Player._poisoned = self.Poison.TimeOut
				Player._poisonedTime = 0
				Player._poison = self.Poison
				Player._DrawColorQuad = true
				Player._ColorOfQuad = Color:New(255, 10, 10)
				Player._QuadAlphaMax = 50
			end
			--self.DEBUGl1 = x
			--self.DEBUGl2 = y
			--self.DEBUGl3 = z
			--self.DEBUGl4 = self._fx_lastx
			--self.DEBUGl5 = self._fx_lasty
			--self.DEBUGl6 = self._fx_lastz
			self._fx_lastx = x
			self._fx_lasty = y
			self._fx_lastz = z
		end
	end
end

DevilMonk.CustomOnDeathUpdate = DevilMonk.CustomUpdate

