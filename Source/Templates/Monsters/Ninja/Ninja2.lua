function Ninja2:OnCreateEntity()
    self._AIBrain._lastThrowTime = FRand(-5, 1) 
    if debugMarek then
		self._AIBrain._lastThrowTime = -100
    end
    self._AIBrain._lastRollTime = -100
end


function Ninja2:Throw()
	if self._AIBrain and self._AIBrain._enemyLastSeenTime > 0 then
		local aiParams = self.AiParams
		local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))
		self.Joint = MDL.GetJointIndex(self._Entity, aiParams.throwItemBindTo)
	    local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,aiParams.holdJointDisplace.X,aiParams.holdJointDisplace.Y, aiParams.holdJointDisplace.Z)

		obj.ObjOwner = self
		obj.Pos.X = x
		obj.Pos.Y = y
		obj.Pos.Z = z

		local v = Vector:New(Player._groundx - x, (Player._groundy + 1.7) - y, Player._groundz - z)
		v:Normalize()
		
		local angleToPlayer = math.atan2(v.X, v.Z)
		
		local aDist = AngDist(self.angle, angleToPlayer)
		if math.abs(aDist) > 30 * math.pi/180 then
			--Game:Print("z orienacji")
			v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
			v:Normalize()
		end

		local force = aiParams.ThrowSpeed * FRand(0.8, 1.2)
        v:MulByFloat(force)
		
		if debugMarek then					
			self.d1 = x
			self.d2 = y
			self.d3 = z
			self.d4 = x + v.X
			self.d5 = y + v.Y
			self.d6 = z + v.Z
		end

		obj.Rot:FromEuler( 0, -self.angle, 0)
		obj._RotAngle = self.angle

		obj:Apply()
		obj:Synchronize()
		obj._enabled = true
		ENTITY.SetVelocity(obj._Entity, v.X, v.Y, v.Z)
	end
end



----------------------
AiStates.ninjaRoll = {
	name = "ninjaRoll",
	delayRandom = FRand(0,2),
}

function AiStates.ninjaRoll:OnInit(brain)
	local actor = brain._Objactor
	if debugMarek then Game:Print(actor.Model.." throw "..brain.r_closestEnemy._groundx.." "..brain.r_closestEnemy._groundz) end
	local aiParams = actor.AiParams
	actor:Stop()
	if brain.r_closestEnemy then
		actor:RotateToVector(brain.r_closestEnemy._groundx, 0, brain.r_closestEnemy._groundz)
    else
        if debugMarek then
            Game.freezeUpdate = true
            Game:Print("NIE WIDZI WROGA?????")
        end
	end

    actor._disableHits = true
	self._throwed = true
	self.active = true
	self.mode = 0
end

function AiStates.ninjaRoll:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if self.mode == 0 then
		if not actor._isRotating then
			-- tu trace, czy nie trafi w sciane
			actor:SetAnim(aiParams.rollAnim, false)
			actor._moveWithAnimation = true
			aiParams.throwAmmo = aiParams.throwAmmo - 1
			self.mode = 1
		end
	else
		if not actor._isAnimating or actor.Animation ~= aiParams.rollAnim then
			self.active = false
			--[[if actor._proc then
				GObjects:ToKill(actor._proc)
				actor._proc = nil
			end--]]
		else
			actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
		end
	end
	brain._lastRollTime = brain._currentTime
end

function AiStates.ninjaRoll:OnRelease(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor._moveWithAnimation = nil
	self.delayRandom = FRand(0,aiParams.minDelayBetweenThrow)
	self.active = false
    actor._disableHits = nil
end

function AiStates.ninjaRoll:Evaluate(brain)
	if self.active then
		return 0.8
	else
        if brain.r_closestEnemy then
		    local actor = brain._Objactor
			local aiParams = actor.AiParams
            if brain._lastRollTime + self.delayRandom + aiParams.minDelayBetweenRoll < brain._currentTime then
				if brain._distToNearestEnemy < aiParams.rollRangeMax and brain._distToNearestEnemy > aiParams.rollRangeMin then
					if math.random(100) < (8 - brain.r_closestEnemy._velocity) * 5 then
						Game:Print("roll "..brain._distToNearestEnemy)
						return 0.61
					end
				end
			end
		end
	end
	return 0
end

