function Skull_V2:CustomOnDamage()
	if self._immortal then
		return true
	else
		--self._AIBrain._lastTimeShotRnd = 0
	end
end

function Skull_V2:CustomUpdate()
	if self._immortalTime then
		self._immortalTime = self._immortalTime - 1
		if self._immortalTime < 0 then
			self._immortal = false
			self._immortalTime = nil
			if self._fx	then
				PARTICLE.Die(self._fx)
				self._fx = nil
			end
		end
	end
end

function Skull_V2:OnCreateEntity()
	self._AIBrain._lastTimeShotRnd = 1.0
end

function Skull_V2:firehead()
	self._immortal = true
	self._fx = self:BindFX('fireskull',0.13,'k_glowa',0.13,0,0)
	self._immortalTime = FRand(self.AiParams.immortalTime * 0.8, self.AiParams.immortalTime * 1.2)

	local aiParams = self.AiParams
	local Joint = MDL.GetJointIndex(self._Entity, aiParams.weaponBindPos)
	local x1,y1,z1 = MDL.GetJointPos(self._Entity,Joint)
	ax,ay,az = aiParams.weaponBindPosShift.X, aiParams.weaponBindPosShift.Y, aiParams.weaponBindPosShift.Z
	
	local srcx,srcy,srcz = MDL.TransformPointByJoint(self._Entity, Joint, ax,ay,az)
	
	local v2 = Vector:New(srcx - x1, srcy - y1, srcz - z1)
	v2:Normalize()
	local q = Quaternion:New_FromNormal(v2.X, v2.Y, v2.Z)
	
	local gun = aiParams.weapon
	AddPFX(gun.fireParticle, gun.fireParticleSize, Vector:New(srcx,srcy,srcz), q)
end

Skull_V2._CustomAiStates = {}
--------------------------
Skull_V2._CustomAiStates.shot_head = {
	name = "shot_head",
	lastTimeShotHead = 0,
}
function Skull_V2._CustomAiStates.shot_head:OnInit(brain)
	local actor = brain._Objactor
	actor._disableHits = true
	actor:Stop()
	actor:SetAnim("fire_head",false)
	self.active = true
	Game:Print("shot in the head")
end

function Skull_V2._CustomAiStates.shot_head:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isAnimating or actor.Animation ~= "fire_head" then
		self.active = false
	end
end

function Skull_V2._CustomAiStates.shot_head:OnRelease(brain)
	local actor = brain._Objactor
	self.active = false
	actor._disableHits = false
end

function Skull_V2._CustomAiStates.shot_head:Evaluate(brain)
	if self.active then
		return 0.55
	else
		local actor = brain._Objactor
		if brain.r_closestEnemy and actor._state ~= "ATTACKING" and not actor._immortal and brain._lastDamageTime > 0 then
			if self.lastTimeShotHead + actor.AiParams.ShotHeadFreq + brain._lastTimeShotRnd < brain._currentTime then
				self.lastTimeShotHead = brain._currentTime
				brain._lastTimeShotRnd = FRand(0.0, actor.AiParams.ShotHeadFreq*0.5)
				return 0.55
			end
		end
	end
	return 0.01
end
