function HellAngel_V3:OnInitTemplate()
    self:SetAIBrain()
end

function HellAngel_V3:CustomOnDamage(he,x,y,z,obj, damage, type)
	if type == AttackTypes.Demon then
        return false
    end

	if obj then
		if obj == self then
			if debugMarek then Game:Print(self._Name.." damage from self") end
			return true
		end
	end
end

--obj.ObjOwner
function HellAngel_V3:OnCreateEntity()
--	self:BindFX("pochodnia",0.2,"gun",-0.3,0.2,1.7)
	 ENTITY.PO_SetMovedByExplosions(self._Entity,false)
end

function HellAngel_V3:CustomOnDeath()
	ENTITY.PO_SetMovedByExplosions(self._Entity,true)		-- ### potrzebne?
end

--------------------------------------
HellAngel_V3._CustomAiStates = {}

HellAngel_V3._CustomAiStates.rocketJump = {
	name = "rocketJump",
    lastTimeRJumpRnd = 0.5,
    lastTimeRJump = 0,
}

function HellAngel_V3._CustomAiStates.rocketJump:OnInit(brain)
	-- spr. widocznosci z gory
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	local maxHeight = aiParams.JumpVelocity * aiParams.JumpVelocity / Tweak.GlobalData.Gravity
	local x1,y1,z1 = actor._groundx,actor._groundy + 1.8,actor._groundz
	local b,d = WORLD.LineTraceFixedGeom(x1,y1,z1,x1,y1 + maxHeight,z1)
	if b then
		Game:Print(actor._Name.." za niski sufit")
		return
	end
	local b,d = WORLD.LineTraceFixedGeom(x1,y1 + maxHeight,z1, brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y + aiParams.throwDeltaY, brain._enemyLastSeenPoint.Z)
	if b then
		Game:Print(actor._Name.." spod sufitu plater nie bedzie widoczny")
		return
	end
	
	actor:FullStop()
	actor:SetAnim("rjump_start",false)
	actor._DontCheckFloors = true
	actor._disableHits = true
	self.mode = 0
	self.active = true
	actor._vdest = {}
	actor._vdest.X, actor._vdest.Y, actor._vdest.Z = 0,aiParams.JumpVelocity,0
	actor.disableNoAnimDetection = true
end

function HellAngel_V3._CustomAiStates.rocketJump:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if not self.active then return end
	
	local speed = MDL.GetAnimTimeScale(actor._Entity, actor._CurAnimIndex)


	if self.mode == 0 then		-- wyskok
		if not ENTITY.PO_IsOnFloor(actor._Entity) then		-- dodac timeout?
			if brain._velocityy <= 0 then
				--[[if debugMarek then
					Game:Print("strzal")
					ENTITY.PO_EnableGravity(actor._Entity,false)
					Game.freezeUpdate = true
				end--]]
                actor:PlaySound("shoot")
				actor:ThrowImmid(nil, true)
				self.mode = 1
				--if debugMarek then WORLD.SetWorldSpeed(1/8) end

				return
			else
				if math.random(100) < 14 then
					actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y + aiParams.throwDeltaY, brain._enemyLastSeenPoint.Z)
					--MDL.ApplyRotationToJoint(actor._Entity,MDL.GetJointIndex(self._Entity,"root"),1,1,1)
				end
			end
		else
			if speed == 0 or not actor._isAnimating or actor.Animation ~= "rjump_start" then
				if debugMarek then
					Game:Print(actor._Name.." Warning: isnt flying, a koniec anim "..actor.Animation)
					Game.freezeUpdate = true
				end
				actor:SetIdle()
				self.active = false
			end
		end
	end
	if self.mode == 1 then
		--if ENTITY.PO_IsOnFloor(actor._Entity) then
		local b,d = WORLD.LineTraceFixedGeom(actor._groundx,actor._groundy + 0.1,actor._groundz,actor._groundx,actor._groundy - 5.0,actor._groundz)
		if b then
			ENTITY.PO_SetFlying(actor._Entity, false)
			actor:SetAnim("rjump_land",false)
			if debugMarek then Game:Print("na ziemi "..d) end
			self.mode = 2
			return
		end
	end
	if self.mode == 2 then
		if not actor._isAnimating or actor.Animation ~= "rjump_land" then
			self.active = false
		end
	end
	self.lastTimeRJump = brain._currentTime
end

function HellAngel_V3._CustomAiStates.rocketJump:OnRelease(brain)
	local actor = brain._Objactor
	ENTITY.PO_SetFlying(actor._Entity, false)
	actor._DontCheckFloors = false
	actor.disableNoAnimDetection = false
	actor._disableHits = false
end

function HellAngel_V3._CustomAiStates.rocketJump:Evaluate(brain)
	if self.active then
		return 0.6
	else
		local actor = brain._Objactor
		if (brain.r_closestEnemy or brain._enemyLastSeenTime + 1.0 > brain._currentTime) and actor._state ~= "ATTACKING" then
			if self.lastTimeRJump + actor.AiParams.RJumpFreq + self.lastTimeRJumpRnd < brain._currentTime then
				self.lastTimeRJump = brain._currentTime
				self.lastTimeRJumpRnd = FRand(0.0, 2.0)
				if debugMarek then Game:Print("want jump") end
				return 0.6
			end
		end
	end
	return 0.0
end


function HellAngel_V3:OnThrow(x,y,z)
	local e = self._objTakenToThrow._Entity
	ENTITY.PO_EnableGravity(e, false)
	self._objTakenToThrow.ExplodeOnCollision = true
	BindSoundToEntity(e,"weapons/machinegun/rl-flyingnoise-loop",3,18,true,nil,nil,nil,nil,0.3,0.4)     

	local aiParams = self.AiParams
	local Joint = MDL.GetJointIndex(self._Entity, aiParams.weaponBindPos)
	ax,ay,az = aiParams.weaponBindPosShift.X, aiParams.weaponBindPosShift.Y, aiParams.weaponBindPosShift.Z
	
	local srcx,srcy,srcz = MDL.TransformPointByJoint(self._Entity, Joint, ax,ay,az)
	
	
	local gun = aiParams.weapon
	--local pfx = AddPFX(gun.fireParticle, gun.fireParticleSize, Vector:New(srcx,srcy,srcz), q)
	--ENTITY.RegisterChild(self._Entity,pfx)
	self:BindFX(gun.fireParticle, gun.fireParticleSize, Joint, ax,ay,az, 0, -math.pi/2,0,0)
	AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,srcx,srcy,srcz)
end

function HellAngel_V3:GetThrowItemRotation()
	local q = Quaternion:New()
	q:FromEuler( 0, -self.angle - math.pi/2, -math.pi/2)
	return q
end

function HellAngel_V3:RocketJump()
	local aiParams = self.AiParams
	local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))
	if self.GetThrowItemRotation then
		obj.Rot = self:GetThrowItemRotation()
	end
	
	local Joint = MDL.GetJointIndex(self._Entity, aiParams.throwItemBindTo)
	local x,y,z = MDL.TransformPointByJoint(self._Entity,Joint,aiParams.throwItemBindToOffset.X,aiParams.throwItemBindToOffset.Y, aiParams.throwItemBindToOffset.Z)

	obj.ObjOwner = self
	obj.Pos.X = x
	obj.Pos.Y = y
	obj.Pos.Z = z
	obj:Apply()
	obj:Synchronize()
	obj:Explode()
end
