o.OnInitTemplate = CItem.StdOnInitTemplate

function Ball:OnCreateEntity()
    self:PO_Create(BodyTypes.Simple)
end

function Ball:CustomOnCollision(e,v1,v2,x,y,z)
	if self._lastPlayedImpactSoundDelay then
		if self._lastPlayedImpactSoundDelay + self.SoundImpactMinDelay*30 < Game.currentTime then
			self._lastPlayedImpactSoundDelay = nil
		end
	end
	if not self._lastPlayedImpactSoundDelay then
		--if not SOUND3D.IsPlaying(self._lastPlayedImpactSound) then
			self._lastPlayedImpactSound = self:Snd3D("collisiondetect",x,y,z)
			--Game:Print(v1.." "..v2)
			if v1 > 14 then
				v1 = 14
			end
			v1 = v1 * 100/14
			SOUND3D.SetVolume(self._lastPlayedImpactSound, v1)
			if self.SoundImpactMinDelay then
				self._lastPlayedImpactSoundDelay = Game.currentTime
			end
		--end
	end
	return true
end
