function HellBiker_V2:OnInitTemplate()
    self:SetAIBrain()
	self._soundSample = SOUND3D.Create("actor/hellbiker/hellb_mgun_rotor-loop")
	SOUND3D.SetHearingDistance(self._soundSample,14,42)
	SOUND3D.SetLoopCount(self._soundSample,0) 

end


function HellBiker_V2:CustomUpdate()
	if self.Animation == "atak" then			-- tempshit
		--if not actor:IsPlayingLastSound(self.startSound) then
			if not SOUND3D.IsPlaying(self._soundSample) then
				SOUND3D.SetPosition(self._soundSample,self.Pos.X,self.Pos.Y,self.Pos.Z)
				SOUND3D.Play(self._soundSample)
			end
		--end
	else
		--if not actor:IsPlayingLastSound(self.startStop) then
			if SOUND3D.IsPlaying(self._soundSample) then
				SOUND3D.Stop(self._soundSample)
			end
		--end
	end
end


function HellBiker_V2:CustomOnDeath()
	if self._soundSample then
		SOUND3D.Delete(self._soundSample)
		self._soundSample = nil
	end
	if self._shootingSound then
		local e = ENTITY.GetPtrByIndex(self._shootingSound)
		if e then
			ENTITY.Release(e)	-- pozniej fadeout
		end
		self._shootingSound = nil
	end
	if self._startGun then
		local e = ENTITY.GetPtrByIndex(self._startGun)
		if e then
			ENTITY.Release(e)
		end
		--Game:Print("stop rotor")
		self._startGun = nil
	end

end


function HellBiker_V2:OnStartAnim(oldAnim)
	if oldAnim == "atak" then
		if self._startShooting then
			self:PlaySound("shootend")
			self._startShooting = false
			if self._shootingSound then
				local e = ENTITY.GetPtrByIndex(self._shootingSound)
				if e then
					ENTITY.Release(e)	-- pozniej fadeout
				end
				self._shootingSound = nil
			end
		end
		if self._startGun then
			local e = ENTITY.GetPtrByIndex(self._startGun)
			if e then
				ENTITY.Release(e)
			end
			--Game:Print("stop rotor")
			self._startGun = nil
		end
		self:PlaySound("stop")
	else
	if oldAnim == "atak_start" then
		if self._startGun then
			local e = ENTITY.GetPtrByIndex(self._startGun)
			if e then
				ENTITY.Release(e)
			end
			self:PlaySound("stop")
			self._startGun = nil
			--Game:Print("stop rotor")
		end
	end
	end
end

function HellBiker_V2:StartRotor()
	local snd
	snd, self._startGun = self:BindRandomSound("start")
end

function HellBiker_V2:ShootingSound(start)
	if start then
		if self._shootingSound then
			local e = ENTITY.GetPtrByIndex(self._shootingSound)
			if e then
				ENTITY.Release(e)	-- pozniej fadeout
			end
			self._shootingSound = nil

		end
		local snd
		snd, self._shootingSound = self:BindRandomSound("shootLoop")
	end
	self._startShooting = start
end
