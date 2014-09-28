function EvilMonk:OnInitTemplate()
    self:SetAIBrain()
end


function o:IfMissedPlaySound()
	local brain = self._AIBrain
	if brain then
		if brain._lastHitTime < brain._lastMissedTime then
			self:PlaySound("missed")
			if self.s_SubClass.hitGroundJoint then
			
				local j = MDL.GetJointIndex(self._Entity, self.s_SubClass.hitGroundJoint)
				local x,y,z = MDL.TransformPointByJoint(self._Entity, j,1.3,0,0)
				--[[
				DEBUGcx = x
				DEBUGcy = y + 0.3
				DEBUGcz = z
				DEBUGfx = x
				DEBUGfy = y - 0.8
				DEBUGfz = z
				--]]
				local b,d,x1,y1,z1 = WORLD.LineTraceFixedGeom(x,y+0.2,z,x,y-0.8,z)
				if b then
					local q = Quaternion:New_FromNormal(nx,ny,nz)
					AddPFX("monsterweap_hitground",0.17, Vector:New(x1,y1,z1),q)
				end
			end
		end
	end
end

function EvilMonk:CustomOnGib()
	if self._AIBrain._AxethrowedRight then
		MDL.SetMeshVisibility(self._Entity, Templates[self.AiParams.ThrowableItem].Mesh, false)
		MDL.EnableJoint(self._Entity, MDL.GetJointIndex(self._Entity, "joint21"), false)
	end
end


function EvilMonk:Throw()
	if self._AIBrain and self._AIBrain._enemyLastSeenTime > 0 then
	
		local obj = GObjects:Add(TempObjName(),CloneTemplate(self.AiParams.ThrowableItem))
		MDL.SetMeshVisibility(self._Entity, obj.Mesh, false)	-- "polySurfaceShape905"

		self.Joint = MDL.GetJointIndex(self._Entity, "dlo_prawa_root")
	    local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,0,0,0)

		local player = Player
		if self._AIBrain.r_closestEnemy then
			player = self._AIBrain.r_closestEnemy
		end
		
		obj.ObjOwner = self
		obj.Pos.X = x
		obj.Pos.Y = y + 0.6
		obj.Pos.Z = z

		local v = Vector:New(player._groundx - x, 0, player._groundz - z)
		v:Normalize()
		
		local angleToPlayer = math.atan2(v.X, v.Z)
		
		local aDist = AngDist(self.angle, angleToPlayer)
		--Game:Print("dist Angles = "..(aDist*180/3.14))
		if math.abs(aDist) > 30 * 3.14/180 then
			--Game:Print("z orienacji")
			v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
			v:Normalize()
		end

		local distToPlayer = Dist2D(x,z, player._groundx, player._groundz)
		v.X = v.X * distToPlayer
		v.Y = v.Y * distToPlayer
		v.Z = v.Z * distToPlayer

        obj.PosDest = Vector:New(v.X + x,player._groundy + 1.7,v.Z + z)
		
		obj.Rot:FromEuler( 0, -self.angle, 0)
		
		obj._RotAngle = self.angle
		obj:Apply()
		--ENTITY.SetAngularVelocity(obj._Entity, 10, 0, 0) 
		obj:Synchronize()
		
		self._AIBrain._AxethrowedRight = true
	end
end


function EvilMonk:CustomOnHit()
	if not self._ABdo then
		if self._HealthMax * self.AiParams.specialAttackHP > self.Health and ENTITY.PO_IsOnFloor(self._Entity) then
			local brain = self._AIBrain
			if brain._enemyLastSeenTime > 0 then
				if brain.r_lastDamageWho then
					brain._goals = {}
					brain._currentGoal = nil
					
					self._disableHits = true
					self:Stop()
					self:RotateToVector(brain.r_lastDamageWho._groundx, brain.r_lastDamageWho._groundy, brain.r_lastDamageWho._groundz)
					self._ABdo = 0
				end
			end
		end
	end
end

function EvilMonk:CustomUpdate()
	if self._ABdo then
		local player = Player
		if self._AIBrain.r_closestEnemy then
			player = self._AIBrain.r_closestEnemy
		end
		if self._ABdo == 0 and not self._isRotating then
			self:RotateToVector(player._groundx, player._groundy, player._groundz)
			self:SetAnim(self.AiParams.ThrowAnim, false)
			self._ABdo = 1
		end
		if self._ABdo == 1 then
			if (not self._isAnimating or self.Animation ~= self.AiParams.ThrowAnim) then
				self:OnDamage(self.Health + 2, self)
				self._ABdo = 2
			else
				if not self._AIBrain._AxethrowedRight then
					self:RotateToVector(player._groundx, player._groundy, player._groundz)
				end
			end
		end
	end
end	
	



--------------------------
EvilMonk._CustomAiStates = {}
EvilMonk._CustomAiStates.throwAndDie = {
	name = "throwAndDie",
}

function EvilMonk._CustomAiStates.throwAndDie:OnUpdate(brain)
	local actor = brain._Objactor
	if math.random(100) < 25 and not actor._ABdo then
		if brain._distToNearestEnemy < actor.AiParams.attackRange then
			actor:RotateToVector(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz)
			--if Player
			local player = Player
			if brain.r_closestEnemy then
				player = brain.r_closestEnemy
			end
			local x,y,z,mag = ENTITY.GetVelocity(player._Entity)
			if (math.random(100) < 30 and mag < FRand(1,3)) or actor.AiParams.throwImmid or math.random(1000) < 6 then
				actor._ABdo = 0
				--Game:Print("actor.AiParams.specialAttackHP = 1.01")
			end
		end
	end
end

function EvilMonk._CustomAiStates.throwAndDie:Evaluate(brain)
	if brain.r_closestEnemy then
		return 0.5
	end
	return 0.01
end

---------

