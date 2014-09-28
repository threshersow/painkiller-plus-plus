function Nun2:OnInitTemplate()
    self:SetAIBrain()
end

function Nun2:CustomOnDeath()
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end

function Nun2:OnCreateEntity()
    self._AIBrain._lastThrowTime = FRand(-3, 3)
end

function Nun2:CustomOnHit()
	if not self._nunThrowHelmet then
		local throwHelmetHp = self.AiParams.throwHelmetHp
		if not throwHelmetHp then
			throwHelmetHp = FRand(0.3, 0.5)
		end
		if self._HealthMax * throwHelmetHp > self.Health then
			self._nunThrowHelmet = true
			MDL.SetMeshVisibility(self._Entity,"polySurface990|polySurfaceShape990", false)
			
			self:PlaySound("hithelmet")
			
			local obj = GObjects:Add(TempObjName(),CloneTemplate("Helmik.CItem"))

			self.Joint = MDL.GetJointIndex(self._Entity, "k_glowa")
		    local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,0,0,0)

			obj.ObjOwner = self
			obj.Pos.X = x
			obj.Pos.Y = y
			obj.Pos.Z = z
			if self._AIBrain and self._AIBrain.r_closestEnemy then
				obj.PosDestX = self.Pos.X - self._AIBrain.r_closestEnemy._groundx
				obj.PosDestY = self.Pos.Y - self._AIBrain.r_closestEnemy._groundy
				obj.PosDestZ = self.Pos.Z - self._AIBrain.r_closestEnemy._groundz
			end
			
			obj:Apply()
			ENTITY.SetAngularVelocity(obj._Entity, FRand(0,20), 0, 0) 
			obj:Synchronize()
		end
	end
end


--------------------

Nun2._CustomAiStates = {}
Nun2._CustomAiStates.NunSpecialAttack = {
	name = "NunSpecialAttack",
	delayRandom = FRand(0,2),
}

function Nun2._CustomAiStates.NunSpecialAttack:OnInit(brain)
	local actor = brain._Objactor
	actor:Stop()
	if brain.r_closestEnemy then
		actor:RotateToVector(brain.r_closestEnemy._groundx, 0 ,brain.r_closestEnemy._groundz)
	end
	actor:SetAnim("atakczar", false)
	actor._disableHits = true
	self.active = true
end

function Nun2._CustomAiStates.NunSpecialAttack:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isAnimating or actor.Animation ~= "atakczar" then
		self.active = false
	end
	brain._lastThrowTime = brain._currentTime
end

function Nun2._CustomAiStates.NunSpecialAttack:OnRelease(brain)
	local actor = brain._Objactor
	brain._lastThrowTime = brain._currentTime + FRand(0,2)
	self.active = false
	actor._disableHits = nil
end

function Nun2._CustomAiStates.NunSpecialAttack:Evaluate(brain)
	if self.active then
		return 0.6
	else
        local actor = brain._Objactor
		if brain.r_closestEnemy and not brain.r_closestEnemy._slowDownTime and not actor._nunThrowHelmet then
			if brain._lastThrowTime + actor.AiParams.minDelayBetweenThrow < brain._currentTime then
				local aiParams = actor.AiParams
				if brain._distToNearestEnemy < aiParams.throwRangeMax and brain._distToNearestEnemy > aiParams.throwRangeMin then
					--Game:Print("possible")
					if math.random(100) < (10 - brain.r_closestEnemy._velocity) * 4 then
						return 0.6
					end
				end
			end
		end
	end
	return 0
end


