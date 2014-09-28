-- dodac precache
o.MagicNumber = 1.7			-- roznica w wysokosci

function o:OnPrecache()
     Cache:PrecacheActor("FX_rexplode.CActor")
     Cache:PrecacheSounds("impacts/barrel-tnt-explode")
end

function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
    self.disableFreeze = true
	self._visibleParts = {}
	for i,v in self.s_SubClass.bodyParts do
		local cnt = table.getn(v)
		local no = math.random(1,cnt)
		self._visibleParts[i] = no
		for j=1,cnt do
			if j ~= no then
				MDL.SetMeshVisibility(self._Entity, v[j], false)
			end
		end
	end
end

function o:CustomOnGib()
	if self._gibbed then
		for i,v in self.s_SubClass.bodyParts do
			local no = self._visibleParts[i]
			local cnt = table.getn(v)
			for j=1,cnt do
				if j ~= no then
					MDL.SetMeshVisibility(self._Entity, v[j], false)
				end
			end
		end
	end
end





function o:OnApply()
	ENTITY.PO_Enable(self._Entity,false)
	local gib = MDL.MakeGib(self._Entity, ECollisionGroups.RagdollNonColliding)

	local vv = Vector:New(self:GetJointPos("ROOOT"))

	self._vectorz = {}

	for i=0,60 do
        local joint = i
        local a = MDL.GetJointName(gib, i)
        if a ~= "<none>" then
			local x,y,z = MDL.GetRagdollJointPos(gib, joint)
			self._vectorz[joint] = {}
			self._vectorz[joint].Pos = Vector:New(x,y,z)
				--self._vectorz[joint].Pos:Sub(self.Pos)
			self._vectorz[joint].Pos:Sub(vv)
			self._vectorz[joint].Pos.Y = self._vectorz[joint].Pos.Y + self.MagicNumber
			self._vectorz[joint].RotDst = Quaternion:New(MDL.GetRagdollJointRotation(gib, joint))
		end
	end
	
	ENTITY.Release(gib)
	ENTITY.PO_Enable(self._Entity, true)

	self._oleAngle = self.angle
	
	
    local vv = Vector:New(self:GetJointPos("ROOOT"))
	self._vv2 = Vector:New(self:GetJointPos("root"))
	self._vv2:Sub(vv.X,vv.Y,vv.Z)

---------------------------------
	self._animType = math.random(1,3)
	self._forceWalkAnim = "run"..self._animType


	self.uglyHackToForceAnimateRagdoll = self:BindFX("pinokio",0.001,"root")
    --ENTITY.EnableDraw(self.uglyHackToForceAnimateRagdoll, false)

end

--function o:SetAngVel()
--	ENTITY.SetAngularVelocity(self._Entity,FRand(0,20),FRand(0,20),FRand(0,20))
--end

function o:EnableCOL()
	local joitns = {"k_szyja","n_p_kolano","n_l_kolano","n_l_kolano","r_L_lokiec"}
	
	for i,v in joitns do
		local k_szyja = MDL.GetJointIndex(self._Entity,v)
		ENTITY.EnableCollisionsToRagdoll(self._Entity, k_szyja, 0.0, 0.0)
		   
		local vx,vy,vz,vv,ax,ay,az = MDL.GetVelocitiesFromJoint(self._Entity, k_szyja)
		--Game:Print("vel = "..vx.." "..vy.." "..vz.."  "..ax.." "..ay.." "..az)
		--vx = vx * FRand(3,3)
		--vy = vy * FRand(3,3)
		--vz = vz * FRand(3,3)
		ax = FRand(-180,180)
		ay = FRand(-180,180)
		az = FRand(-180,180)
		MDL.ApplyVelocitiesToJoint(self._Entity, k_szyja, vx,vy,vz,ax,ay,az)
	end	   
   
	self._fallingSnd = self:BindRandomSound("falling")
end

function o:OnCollision(x,y,z)
    --Game:Print("APOC_ZOMBIE_COL")
	if not self.AIenabled and self.enableUnGib and not self._booting then
		if not self._gibbed then
			 local vx,vy,vz = ENTITY.GetVelocity(self._Entity)
			 --Game:Print("vy = "..vx.." "..vy.." "..vz)
			 if self.colVelocityDamping then
				vx = vx * self.colVelocityDamping
				vy = 0
				vz = vz * self.colVelocityDamping
			 end
			 ENTITY.SetVelocity(self._Entity,vx,vy,vz)
			 
			 ENTITY.Release(self.uglyHackToForceAnimateRagdoll)
			 self.uglyHackToForceAnimateRagdoll = nil

			self:FullStop()
			if Tweak.GlobalData.GermanVersion then
				self:PlaySound("gib",nil,nil,nil,nil,x,y,z)
				self._gibbed = true
				self:BloodFX(x,y,z)
			else
				self:CreateGib()
			end
			ENTITY.Release(self._fallingSnd)
			--Game:Print(">>>>>>>>>gib")
			self._timerUnGib = self.enableUnGib
			self._mode = 0
		end
	end
	ENTITY.EnableCollisions(self._Entity, false)
end

function o:CustomOnDamage(he,x,y,z,obj, damage, type)
	if not self.AIenabled and self.enableUnGib and not self._booting then
		--Game:Print(self._Name.." CustomOnDamage() TRUE")
        if not self._frozen then
            return true
        end
	end
	if obj == self or type == AttackTypes.Suicide then
		return
	end
	if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        if j then
			local name = MDL.GetJointName(e,j)
			--Game:Print("name = "..name)
			if name == "k_szyja" then
				self:Explode()
				--local x,y,z = MDL.GetJointPos(e,j)
				--AddPFX('Grenade',0.4,Vector:New(x,y,z))
			--	self:BindFX('GasTankExplode',nil,j)
			--	if self.Health > 1 then
			--		self.Health = 1
			--	end
			end
        end
    end

end

function o:Explode()
    --ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
	if not self._exploded then
        local x,y,z = self:GetJointPos("k_szyja")
		self._exploded = true
		self.enableGibWhenHPBelow = 0
		local aiParams = self.AiParams
		WORLD.Explosion2(x,y,z, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,self._Entity,AttackTypes.Suicide,aiParams.Explosion.Damage)
		-- sound
		PlaySound3D("impacts/barrel-tnt-explode",x,y,z,20,150)
		local r = Quaternion:New_FromNormal(0,1,0)
		AddObject("FX_rexplode.CActor",1,Vector:New(x,y,z),r,true) 
		
		-- light
		AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y,z)
		if Game._EarthQuakeProc then
			Game._EarthQuakeProc:Add(x,y,z, 5, 10, 0.15, 0.15, false)
		end

		--MDL.SetMeshVisibility(self._Entity,"BECZKA_MALAShape", false)	
        --local e = AddItem("BarrelSmall.CItem",nil,self.Pos,nil,Quaternion:New_FromEuler( 0, -self.angle, math.pi/2))
        --ENTITY.PO_Enable(e, false)
	    --ENTITY.ExplodeItem(e, "../Data/Items/"..self.deathExplosionItem, self.BarrelExplosion.streng, self.BarrelExplosion.Radius, self.BarrelExplosion.LifetimeAfterExplosion,self.deathExplosionItemScale)
        --ENTITY.Release(e)
        if self.Health > 0 then
			self:OnDamage(self.Health + 2, self)
		end
	end
end



function o:OnTick(delta)
	if (self._gibbed or self._booting) and self.enableUnGib then

		---------- koniec--------
		if self._booting then
			if self._gibbed then
				self._gibbed = nil
				self.Pos = Vector:New(self:GetJointPos("root"))		-- czy rooot?
				self.Pos:Sub(self._vv2.X,self._vv2.Y,self._vv2.Z)
				self.Animation = "idle"
				self.angle = self._oleAngle
				self:Apply()
				self._vectorz = nil
	            self._gibJoinMode = nil
				self._gibbed = nil
			end
			-- 
			self:SetAnimSpeed((self.enableUnGibStart - self._booting)/self.enableUnGibStart)
			self._booting = self._booting - delta
			if self._booting < 0 then
				self._booting = nil
				--Game:Print("end bootong")
                self.disableFreeze = false
				self:SetAnimSpeed(1.0)
				self.AIenabled = true
			end
			return
		end
		if not self._gibJoinMode then
			---------- poczatek --------
			if not self._timerUnGib then
				MsgBox(self._Name.." nie ma ungib")
				return
			end
			self._timerUnGib = self._timerUnGib - delta
			if self._timerUnGib < 1 then
				local a = 0.5 + (1 - self._timerUnGib)
				MDL.SetRagdollLinearDamping(self._Entity, a)
				--MDL.SetRagdollAngularDamping(self._Entity, a)
			end
			
			if self._timerUnGib < 0 then
			
				self._mode = 0
				self._timerUnGib = self.enableUnGibReturn
				
				--o.enableUnGibDelay
				--Game:Print("pin")
				--Game.freezeUpdate = true
				self._gibJoinMode = true
				self:PlaySound("reconstruct")


				local vv = Vector:New(self:GetJointPos("root"))

				local zn,idx = WPT.GetClosest(vv.X,vv.Y,vv.Z)  
				if idx > -1 then
					vv.X,vv.Y,vv.Z = WPT.GetPosition(zn,idx)  
				end

				for i,v in self._vectorz do
					v.Pos:Add(vv.X, vv.Y, vv.Z)
				end

			
				for i=0,60 do
					--local joint = MDL.GetJointIndex(self._Entity, v[1])
					local joint = i
					local a = MDL.GetJointName(self._Entity, i)
                    if a ~= "<none>" then
						local x,y,z = MDL.GetRagdollJointPos(self._Entity, joint)
						self._vectorz[joint].v = Vector:New(x - self._vectorz[joint].Pos.X, y - self._vectorz[joint].Pos.Y, z - self._vectorz[joint].Pos.Z)

						self._vectorz[joint].RotSrc = Quaternion:New(MDL.GetRagdollJointRotation(self._Entity, joint))
						MDL.SetPinnedJoint(self._Entity, joint, true)
					end
				end
			end
		else
			---------- 2 --------
			local t = self._timerUnGib
			if self._timerUnGib < 0 then
			
				if not Tweak.GlobalData.GermanVersion then
					if self.s_SubClass.GibEmitters then
						for i,v in self.s_SubClass.GibEmitters do
							local gibFX = self.s_SubClass.reverseGibFX
							self:BindFX(gibFX,0.2,v[1], nil,nil,nil, v[3])
						end
					end
				end			
				--Game.freezeUpdate = true
				--Game:Print("->boot")
				self._booting = self.enableUnGibStart
				self._timerUnGib = 0
				t = 0

			end
			if true then
				--for i,v in self.s_SubClass.GibEmitters do
				
                for i=0,60 do
					--local joint = MDL.GetJointIndex(self._Entity, v[1])
                    local joint = i
                    local a = MDL.GetJointName(self._Entity, i)
                    if a ~= "<none>" then

                        local v2 = Clone(self._vectorz[joint].v)
                        local coe = self._timerUnGib / self.enableUnGibReturn
                        
	                    local coe2 = 1 - (1 - coe)*(1 - coe)

                        v2:MulByFloat(coe2)
                        local pos = self._vectorz[joint].Pos
                        MDL.SetJointPositionLowLevel(self._Entity, joint, pos.X + v2.X, pos.Y + v2.Y, pos.Z + v2.Z)

						-------------
		
						self._qsrc = self._vectorz[joint].RotSrc
						self._qdst = self._vectorz[joint].RotDst
						self._qrot = 1 - t / self.enableUnGibReturn
	                    
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
						--if t == 0 then 
							--Game:Print("- "..pos.X + v2.X.." "..pos.Y + v2.Y.." "..pos.Z + v2.Z)
							--MDL.SetPinnedJoint(self._Entity, joint, false)
						--end
						
						
						MDL.ApplyRotationToJoint(self._Entity, joint, qtemp.W, qtemp.X, qtemp.Y, qtemp.Z)
						
                    end
                end
				
			end
			self._timerUnGib = self._timerUnGib - delta
		end
	end
end


function o:CustomUpdate()
	if (self._gibbed or self._booting) and self.enableUnGib then
		if self._enableMovedByExplosions then
			self._enableMovedByExplosions = self._enableMovedByExplosions - 1
			if self._enableMovedByExplosions <= 0 then
				local x,y,z = self._Ax, self._Ay, self._Az
				MDL.SetRagdollMovedByExplosions(self._Entity, true)
				local st = self.s_SubClass.GibExplosionStrength
			
				MDL.RagdollSelfExplosion(self._Entity,x,y,z,st*FRand(0.2,0.25),self.s_SubClass.GibExplosionRange)

				self._enableMovedByExplosions = nil
				self._Ax, self._Ay, self._Az = nil,nil,nil
			end
		end
	end
	if self.TimeToLive and self.AIenabled then
        self.TimeToLive = self.TimeToLive - 1
        if self.TimeToLive < 0 then
            self:Explode()
            self.TimeToLive = nil
        end
    end
end

function CAction:Action_RunAndJumpGib(obj,area,point,anim,pow,uppow)
    if not obj or obj._died then return end
    obj.__cg = ENTITY.PO_GetCollisionGroup(obj._Entity)
    local action = {
        {"AI:p,false"},
        {"RunTo:p,a[1].Points[a[2]]"},
        {"WaitForWalk:p"},
        {"RotateTo:p,a[1].Points[a[2]].A"},
        {"WaitForRotate:p"},
        --{"Anim:p,a[3]"},
        --{"L:ENTITY.PO_SetCollisionGroup(p._Entity,7)"}, 
        {"Jump:p,a[4],a[5]"},
        {"Wait:0.2"},
        --{"L:p:SetAngVel()"},
        --{"L:ENTITY.PO_SetCollisionGroup(p._Entity,p.__cg)"}, 
        --{"L:p:EnableRagdoll(true,true)"},
        {"L:ENTITY.PO_Enable(p._Entity,false)"},
        {"L:MDL.EnableRagdoll(p._Entity,true,ECollisionGroups.RagdollNonColliding)"},
        {"L:p:EnableCOL()"},
        {"Wait:0.2"},
        {"WaitForJump:p"},
        {"Wait:0.06"},			-- bo wykrywa podloge troche wczesniej i zeby pfx od walk nie odpalal sie za wysoko
        --{"L:p:LaunchFullAnimEvent('walk')"},         
        --{"L:p:LaunchFullAnimEvent('walk')"}, 
        --{"AI:p,true"}, 
    }
    AddAction(action,obj,"p._died",area,point,anim,pow,uppow)
end




o._CustomAiStates = {}
o._CustomAiStates.ApocZombierunToPlayer = {
	name = "ApocZombierunToPlayer",
}


function o._CustomAiStates.ApocZombierunToPlayer:OnInit(brain)
    local actor = brain._Objactor
    actor:PlaySoundHit("attackVoice")
    actor.disableFreeze = false
    self.lastTimeOnAttackAmbient = brain._currentTime + FRand(1,2)
end

function o._CustomAiStates.ApocZombierunToPlayer:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	if self._donoth then
		if not actor._isAnimating or actor.Animation ~= self._donoth then
			actor:Explode()
		end
		return
	end
	if self._waitForAnim then
		if actor._finishedWalkAnim or actor.Animation ~= actor._forceWalkAnim then
			--Game:Print(actor._Name.."_finishedWalkAnim "..actor.Animation)
			actor:Stop()
			actor:SetAnim("atak1", false)
			self._donoth = "atak1"
		else
			if debugMarek then Game:Print(actor._Name.." wait "..actor._animType) end
		end
		return
	end
	

	if brain.r_closestEnemy then
		if not actor._isWalking or math.random(100) < 10 then
			actor:WalkTo(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz)
		end
	end

	local dist = Dist3D(actor._groundx, actor._groundy, actor._groundz, Player._groundx, Player._groundy, Player._groundz)
	if dist < aiParams.actionDistance + aiParams.actionDistanceBonusAtak1 then
		local anim = actor._animType
		if anim > 1 then
			if dist < aiParams.actionDistance then
				self._donoth = "atak"..anim
				actor._disableHits = true
				actor.disableFreeze = true
				actor:Stop()
				actor:SetAnim("atak"..anim, false)
			end
		else
			actor._finishedWalkAnim = false
			self._waitForAnim = true
			actor.doNotUseWP = true
			actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
			actor.disableFreeze = true
			actor._disableHits = true
			actor:WalkForward(50)
			if debugMarek then Game:Print(actor._Name.." wf "..actor._animType) end
			--
		end
        --actor.AIenabled = false
	end

    if actor.s_SubClass.SoundsDefinitions.attackVoice then
        if self.lastTimeOnAttackAmbient + aiParams.soundAmbientDelay < brain._currentTime and math.random(100) < 3 then
            self._lastAttackAmbient = actor:PlaySoundHit("attackVoice")
            if self._lastAttackAmbient then
                self.lastTimeOnAttackAmbient = brain._currentTime
            end
        end
    end


end

function o._CustomAiStates.ApocZombierunToPlayer:OnRelease(brain)
	--Game:Print("error:RUN TO ON RELEASE")
	--Game.freezeUpdate = true
end

function o._CustomAiStates.ApocZombierunToPlayer:Evaluate(brain)
	local actor = brain._Objactor

	if brain.r_closestEnemy or self._waitForAnim or self._donoth then
		return 0.9
	end
	return 0.0
end

function o:OnFinishAnim(anim)
	if anim == self._forceWalkAnim then
		self._finishedWalkAnim = true
	end
end
