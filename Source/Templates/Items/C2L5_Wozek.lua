o.OnInitTemplate = CItem.StdOnInitTemplate

function C2L5_Wozek:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.3)
    MDL.SetRagdollAngularDamping(self._Entity,0.3)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
    MDL.SetRagdollHardDeactivator(self._Entity)
	self._j = MDL.GetJointIndex(self._Entity, self.RagdollMoveSound.joint) 
	self._delayCreak = nil
	self:AddTimer("Creak",0.4)
end


function C2L5_Wozek:Creak()
    local s = self.RagdollMoveSound
	if self._soundSample then
		if not SOUND3D.IsPlaying(self._soundSample) then
			if self._delayCreak then
				self._delayCreak = self._delayCreak - 0.2 --s.checkSpeed
				if self._delayCreak > 0 then
					return
				else
					self._soundSample = nil
					self._delayCreak = nil
				end
			else
				self._soundSample = nil
			end
		else
			return
		end
	end
	
    local vx,vy,vz,vl,ax,ay,az,al = MDL.GetVelocitiesFromJoint(self._Entity,self._j)
  
	local j = MDL.GetJointIndex(self._Entity, "joint4_getmass")
	local x1,y1,z1 = MDL.TransformPointByJoint(self._Entity, j,0,0,0)		-- czy nie jest odwrocona
	local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,1,0)
	
    if al > s.minVel and y - 0.2 > y1 then
		self._soundSample = self:Snd3D("RagdollMoveSound",x,y,z)
		if al < s.minVel * 2 then
			local volume = 100 - ((s.minVel * 2 - al)/s.minVel * 100)
			SOUND3D.SetVolume(self._soundSample, volume)
		end
		self._delayCreak = s.minDelayBetweenSounds
        --
    end
end
