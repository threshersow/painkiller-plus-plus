function o:IfMissedPlaySound()
	local brain = self._AIBrain
	if brain then
		if brain._lastHitTime < brain._lastMissedTime then
			self:PlaySound("missed")
			if self.s_SubClass.hitGroundJoint then
			
				local j = MDL.GetJointIndex(self._Entity, self.s_SubClass.hitGroundJoint)
				local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)

				DEBUGcx = x
				DEBUGcy = y + 0.3
				DEBUGcz = z
				DEBUGfx = x
				DEBUGfy = y - 0.8
				DEBUGfz = z

				local b,d,x1,y1,z1 = WORLD.LineTraceFixedGeom(x,y+0.2,z,x,y-0.8,z)
				if b then
					local q = Quaternion:New_FromNormal(nx,ny,nz)
					AddPFX("monsterweap_hitground",0.17, Vector:New(x1,y1,z1),q)
				end
			end
		end
	end
end


function EvilMonkV2:Throw()
	if self._AIBrain and self._AIBrain._enemyLastSeenTime > 0 then
		local player = Player
		if self._AIBrain.r_closestEnemy then
			player = self._AIBrain.r_closestEnemy
		end
		
		self._angleDest = self.angle	
		local obj = GObjects:Add(TempObjName(),CloneTemplate(self.AiParams.ThrowableItem))
		MDL.SetMeshVisibility(self._Entity, "polySurfaceShape918", false)

		self.Joint = MDL.GetJointIndex(self._Entity, "dlo_prawa_root")
	    local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,0,0,0)

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
		
		local distToPlayer = Dist3D(x,0,z, player._groundx, 0, player._groundz)
		v.X = v.X * distToPlayer
		v.Y = v.Y * distToPlayer
		v.Z = v.Z * distToPlayer

        obj.PosDest = {}
        obj.PosDest.X = v.X + x
        obj.PosDest.Z = v.Z + z
		obj.PosDest.Y = player._groundy + 1.7
		
		obj.Rot:FromEuler( 0, -self.angle, 0)
		
		obj._RotAngle = self.angle
		obj:Apply()
		--ENTITY.SetAngularVelocity(obj._Entity, 10, 0, 0) 
		obj:Synchronize()
		self._AIBrain._AxethrowedRight = true
	end
end


function EvilMonkV2:ThrowLeftAxe()
	if self._AIBrain and self._AIBrain._enemyLastSeenTime > 0 then

		self._angleDest = self.angle 
		local obj = GObjects:Add(TempObjName(),CloneTemplate(self.AiParams.ThrowableItem))
		MDL.SetMeshVisibility(self._Entity, "polySurfaceShape926", false)	-- 

		local player = Player
		if self._AIBrain.r_closestEnemy then
			player = self._AIBrain.r_closestEnemy
		end

		self.Joint = MDL.GetJointIndex(self._Entity, "dlo_lewa_root")
	    local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,0,0,0)
	    
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

		
		local distToPlayer = Dist3D(x,0,z, player._groundx, 0, player._groundz)
		v.X = v.X * distToPlayer
		v.Y = v.Y * distToPlayer
		v.Z = v.Z * distToPlayer

        obj.PosDest = {}
        obj.PosDest.X = v.X + x
        obj.PosDest.Z = v.Z + z
		obj.PosDest.Y = player._groundy + 1.7
		
		self.DEBUG_P4,self.DEBUG_P5,self.DEBUG_P6 = obj.PosDest.X, obj.PosDest.Y, obj.PosDest.Z
		--Game:Print(obj.PosDest.X.." dest "..obj.PosDest.Z)
		
		obj.Rot:FromEuler( 0, -self.angle, 0)
		--Game:Print("self.angle "..(self.angle*180/3.14))
		
		obj._RotAngle = self.angle
		obj:Apply()
		--ENTITY.SetAngularVelocity(obj._Entity, 10, 0, 0) 
		obj:Synchronize()
		self._AIBrain._Axethrowed = true
	end
end

function EvilMonkV2:CustomOnGib()
	if self._AIBrain._Axethrowed then
		MDL.SetMeshVisibility(self._Entity, "polySurfaceShape926", false)
		MDL.EnableJoint(self._Entity, MDL.GetJointIndex(self._Entity, "axeL"), false)
	end
	if self._AIBrain._AxethrowedRight then
		MDL.SetMeshVisibility(self._Entity, "polySurfaceShape916", false)
		MDL.EnableJoint(self._Entity, MDL.GetJointIndex(self._Entity, "axeR"), false)
	end
end


--------------------------
o._CustomAiStates.throwImmid = {
	name = "throwImmid",
}
function o._CustomAiStates.throwImmid:OnInit(brain)
	self.active = true
	self.state = -2
	--Game:Print("throw immid")
end

function o._CustomAiStates.throwImmid:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
	local player = Player
	if brain.r_closestEnemy then
		player = brain.r_closestEnemy
	end

    if self.state < 0 then
		self.state = self.state + 1
    end
	if self.state == 0 then
		actor:RotateToVector(player._groundx, player._groundy, player._groundz)
		self.state = 1
		return
	end
	if self.state == 1 and not actor._isRotating then
		actor:RotateToVector(player._groundx, player._groundy, player._groundz)
		actor:SetAnim(aiParams.ThrowAnimImmid, false)
		self.state = 2
	end		
	if self.state == 2 then
		if (not actor._isAnimating or actor.Animation ~= aiParams.ThrowAnimImmid) then
			self.active = false
			--Game:Print("throw immid end")
			self.state = -2
		else
			if not brain._AxethrowedRight then
				actor:RotateToVector(player._groundx, player._groundy, player._groundz)
			end
		end
	end
end

function o._CustomAiStates.throwImmid:Evaluate(brain)
	if not brain._Axethrowed and brain._seeEnemy and brain._distToNearestEnemy < brain._Objactor.AiParams.throwAttackRange then
		return 0.8
	else
		if self.active then
			return 0.8
		end
	end
	return 0.0
end

---------

