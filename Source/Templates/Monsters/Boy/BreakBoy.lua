function o:CustomOnDeath()
end

function o:CalcVel()
	local brain = self._AIBrain
	self:RotateToVector(brain._enemyLastSeenPoint.X,brain._enemyLastSeenPoint.Y,brain._enemyLastSeenPoint.Z)
    self._vdest = Vector:New(0,0,0)
	local v = Vector:New(math.sin(self._angleDest), 0, math.cos(self._angleDest))
	v:Normalize()
	v.Y = self.AiParams.jumpUpStren
	v:MulByFloat(self.AiParams.jumpStren)
	self._vdest.X, self._vdest.Y, self._vdest.Z = v.X, v.Y, v.Z
end

function o:OnStartAnim(anim)
	if anim == "atak" then
		self:StopFlying()
	end
end
