function DevilMonk_Slowdown:OnInitTemplate()
    self:SetAIBrain()
end

function DevilMonk_Slowdown:OnCreateEntity()
	self._fx2 = self:BindFX(self.FX,0.3,'br1',-0.9,0,0)
end


function DevilMonk_Slowdown:CustomUpdate()
	if self._fx2 and not self._gibbed then
		if math.random(100) < 20 then
			local x,y,z = ENTITY.GetPosition(self._fx2)
			local dist = Dist3D(x,y,z, Player._groundx,Player._groundy, Player._groundz)
			local distLast = 9999
			if self._fx_lastx then
				distLast = Dist3D(self._fx_lastx,self._fx_lasty,self._fx_lastz, Player._groundx,Player._groundy, Player._groundz)
			end
			if dist < self.Poison.Range or distLast < self.Poison.Range then
				--Game:Print("PLAYER poisoned")
				if Player._slowdownSound then
					if not SOUND2D.IsPlaying(Player._slowdownSound) then
						Player._slowdownSound = nil
					end
				end
				if not Player._slowdownSound then
					Player._slowdownSound = PlaySound2D("actor/devilmonk/klatwa-slowdown")
				end
				Player._poisoned = self.Poison.TimeOut
				Player._poisonedTime = 0
				Player._poison = self.Poison
				Player._DrawColorQuad = true
				Player._ColorOfQuad = Color:New(10, 255, 10)
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

DevilMonk_Slowdown.CustomOnDeathUpdate = DevilMonk_Slowdown.CustomUpdate
