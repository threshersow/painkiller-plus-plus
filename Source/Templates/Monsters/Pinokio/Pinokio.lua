function o:OnInitTemplate()
    self:SetAIBrain()
    self._disableHits = true
end

function o:OnApply()
    --MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
	if not self._booting then
		self:EnableRagdoll(true,true)
		self.disableNoAnimDetection = true

		self._DontCheckFloors = true
		local rcoll = self.s_SubClass.RagdollCollisions
		if rcoll then
			for i,v in rcoll.Bones do
				local j = MDL.GetJointIndex(self._Entity, v[1])
				if j >= 0 then
					ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 0.1--[[rcoll.MinTime--]], 0.1--[[rcoll.MinStren--]])
					self._raggDollPrecomputedCollData[j] = {v[2], v[3]}
				end
			end
			self:ReplaceFunction("OnCollision","PinokioOnCollision")
		end
		MDL.SetRagdollLinearDamping(self._Entity, 0.9)
		MDL.SetRagdollAngularDamping(self._Entity, 0.9)

	    local vv = Vector:New(self:GetJointPos("ROOOT"))
		self._vv2 = Vector:New(self:GetJointPos("root"))
		self._vv2:Sub(vv.X,vv.Y,vv.Z)
		--self._vv2:Sub(self.Pos.X,self.Pos.Y,self.Pos.Z)
		--Game:Print("self._vv2 "..self._vv2.X.." "..self._vv2.Y.." "..self._vv2.Z)
        self.disableFreeze = true
	end
end

function o:OnTick(delta)
	if self._up then
		local aiParams = self.AiParams
		MDL.ApplyPositionToJoint(self._Entity, self._up, self._upPos.X, self._upPos.Y, self._upPos.Z)
		self._upPos.Y = self._upPos.Y + delta
		if aiParams.throwRagdollRotationInterpolation then
			if aiParams.ragdollLiftRotationSpeed then
				self._qrot = self._qrot + delta * aiParams.ragdollLiftRotationSpeed
			end
			if self._qrot < 1.0 then
				--Game:Print("interpolacja quaternionow "..self._qrot)
				-- interpolacja quaternionow
				local qtemp = Quaternion:New(1,0,0,0)
				local flip = false
				local coeff0
				local coeff1
				local qdot = self._qsrc.X * self._qdst.X + self._qsrc.Y * self._qdst.Y + self._qsrc.Z * self._qdst.Z + self._qsrc.W * self._qdst.W
				if qdot < 0 then
					flip = true
				end
				coeff0 = 1 - self._qrot
				coeff1 = self._qrot
				if flip then
					qtemp.X = self._qsrc.X*coeff0 - self._qdst.X*coeff1
					qtemp.Y = self._qsrc.Y*coeff0 - self._qdst.Y*coeff1
					qtemp.Z = self._qsrc.Z*coeff0 - self._qdst.Z*coeff1
					qtemp.W = self._qsrc.W*coeff0 - self._qdst.W*coeff1
				else
					qtemp.X = self._qsrc.X*coeff0 + self._qdst.X*coeff1
					qtemp.Y = self._qsrc.Y*coeff0 + self._qdst.Y*coeff1
					qtemp.Z = self._qsrc.Z*coeff0 + self._qdst.Z*coeff1
					qtemp.W = self._qsrc.W*coeff0 + self._qdst.W*coeff1
				end
                qtemp:Normalize()
				MDL.ApplyRotationToJoint(self._Entity, self._up, qtemp.W, qtemp.X, qtemp.Y, qtemp.Z)
			else
				MDL.ApplyRotationToJoint(self._Entity, self._up, self._qdst.W,self._qdst.X,self._qdst.Y,self._qdst.Z)
			end
		else
			if aiParams.rotateRagdollToPlayer then
				MDL.ApplyRotationToJoint(self._Entity, self._up, 0, self._angleRagdoll, 0)
			else
				--MDL.ApplyRotationToJoint(self._Entity, self._up, 1,0,0,0)	-- moze pozniej do oryginalnej rot jointa?
				MDL.ApplyRotationToJoint(self._Entity, self._up, self._upQ.W,self._upQ.X,self._upQ.Y,self._upQ.Z)	-- moze pozniej do oryginalnej rot jointa?
			end
		end
		
		if self._upPos.Y > self._upPosStart + aiParams.upAmount then
			self._ABdo = 3
			--Game.freezeUpdate = true
			self._up = nil
			MDL.SetPinnedJoint(self._Entity, self._up, false)
		end
	end
end

function o:PinokioOnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl, velocity_me, velocity_other)
	--Game:Print("PinokioOnCollision")
	if e_other then
		local obj = EntityToObject[e_other]
		if obj then
			if obj._Class == "CPlayer" then
				if not self._ABdo then
					self._ABdo = 1
					ENTITY.EnableCollisions(self._Entity,false)
				end
			end
		else
			local dist = Dist3D(Player._groundx,Player._groundy,Player._groundz, x,y,z)
			if dist < 1.5 and not self._ABdo then
				self._ABdo = 1
				ENTITY.EnableCollisions(self._Entity,false)
			end
		end
	end
	
end

function o:CheckNose()
    local x,y,z = self:GetJointPos("nos1")
    local x2,y2,z2 = self:GetJointPos("nos2")
    local b = true
    ENTITY.RemoveRagdollFromIntersectionSolver(self._Entity)
    --while b do
        local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x,y,z, x2,y2,z2)    
        if b then
            Game:Print(self._Name.." c "..d)
            x,y,z = xcol,ycol,zcol
            if e then
                local obj = EntityToObject[e]
                if obj and obj.OnDamage then
                    obj:OnDamage(self.AiParams.weaponDamage,self,AttackTypes.AIClose,xcol,ycol,zcol,nx,ny,nz)
                    if obj._Class == "CPlayer" then
						self:PlayRandomSound2D("damage")
					end
                end
            end
        end
    --end
    
    ENTITY.AddRagdollToIntersectionSolver(self._Entity)
end

o._CustomAiStates = {}
--------------------------
o._CustomAiStates.wakeup = {
	name = "wakeup",
}
function o._CustomAiStates.wakeup:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
end

function o._CustomAiStates.wakeup:OnUpdate(brain)
	local actor = brain._Objactor
	if actor._ABdo then
		if actor._ABdo < 2 then
			Game:Print("actor._ABdo "..actor._ABdo)
			actor._ABdo = 2
			actor._up = MDL.GetJointIndex(actor._Entity,"k_szyja")
			actor._upPos = Vector:New(MDL.GetJointPos(actor._Entity, actor._up))
			actor._upQ = Quaternion:New(MDL.GetRagdollJointRotation(actor._Entity, actor._up))
			local x,y,z = actor._upQ:ToEuler()
			--Game:Print(x.." "..y.." "..z)
			actor:PlaySound("wakeup")
			x = 0
			z = 0
			actor.angle = y
			actor._upQ = Quaternion:New_FromEuler(x,y,z)
			MDL.SetPinnedJoint(actor._Entity, actor._up, true)
			actor._upPosStart = actor._upPos.Y
			actor:BindFX("eye1")
			actor:BindFX("eye2")
		else
			if actor._ABdo == 2 then
				
			end
			if actor._ABdo == 3 then
				actor._booting = true
				actor._enabledRD = false

				local q = Quaternion:New(MDL.GetRagdollJointRotation(actor._Entity, MDL.GetJointIndex(actor._Entity,"root")))
				local x,y,z = q:ToEuler()
				local a = ENTITY.GetOrientation(actor._Entity)
				Game:Print("actor.angle = "..actor.angle.." "..y)

				actor._upQ = Quaternion:New(MDL.GetRagdollJointRotation(actor._Entity, actor._up))
				
				actor.angle = y
				--actor.Pos = Vector:New(actor:GetJointPos("ROOOT"))	

				actor.Pos = Vector:New(actor:GetJointPos("root"))		-- czy rooot?
				actor.Pos:Sub(actor._vv2.X,actor._vv2.Y,actor._vv2.Z)

				MDL.SetRagdollCollisionGroup(actor._Entity, ECollisionGroups.Ragdoll)
				MDL.EnableRagdoll(actor._Entity,false)
				ENTITY.PO_Enable(actor._Entity,true)
				ENTITY.SetPosition(actor._Entity,actor.Pos.X,actor.Pos.Y,actor.Pos.Z)
				ENTITY.SetOrientation(actor._Entity,actor.angle)

				actor:ForceAnim("idle",true,nil,0.5)
				actor._enabledRD = false
				actor.disableNoAnimDetection = false
				actor._DontCheckFloors = false

				--Game:Print("WAKEUP "..actor.Animation)
				--Game.freezeUpdate = true
				actor._ABdo = 4
				self._delay = 20
			end
			if actor._ABdo == 4 then
				self._delay = self._delay - 1
				if self._delay < 0 then
					brain._ready = true
				end
			end
		end
	end
end

function o._CustomAiStates.wakeup:OnRelease(brain)
    local actor = brain._Objactor
    actor._DontCheckFloors = false
    actor.disableFreeze = false
	ENTITY.PO_SetPinned(actor._Entity, false)
    actor._disableHits = false
end

function o._CustomAiStates.wakeup:Evaluate(brain)
	if not brain._ready then
		return 0.9
	end
	return 0.0
end


function o:CustomOnDamage()
	local aiParams = self.AiParams
	if not self._ABdo  then
		self._ABdo = 0
	end
	if self._ABdo < 3 then
		return true
	end
end

