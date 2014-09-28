o.MagicNumber = 8	-- dla skali 14
--o.MagicNumber = 1.7	-- dla skali 4

function o:OnInitTemplate()
    self:SetAIBrain()
    self._disableHits = true
--    self._hitsCounter = 0
--    self._AIBrain._lastThrowTime = FRand(-3, 3)
end

function o:CustomOnRagdollCollision(x,y,z,nx,ny,nz,j,velocity_me,velocity_other)
	if velocity_me and velocity_other then
		if velocity_me + 2.0 > velocity_other then
			AddPFX("but",0.6, Vector:New(x,y,z))
			self:PlaySound("bodyfalls",nil,nil,nil,nil,x,y,z)
		end
	end
end

function o:CustomOnDeathAfterRagdoll()
	MDL.RagdollSelfExplosion(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z,self.SelfExplStr,40)
end

function o:CustomOnDeath(he,x,y,z,obj, damage, type,nx,ny,nz)
	if self._immPFX then
		for i,v in self._immPFX do
			PARTICLE.Die(v)
		end
	end
	self._immPFX = nil
	self:PlaySound("decon")
end

function o:CustomOnDamage(he,x,y,z,obj, damage, type,nx,ny,nz)
	--Game:Print("SG on d")
	if type == AttackTypes.StickyBomb then
		Game:Print("sg on damage")
		return false,99999
	end
	if type == AttackTypes.Shotgun or type == AttackTypes.MiniGun or type == AttackTypes.Painkiller or 
        type == AttackTypes.Rifle or type == AttackTypes.PainkillerRotor or type == AttackTypes.Shuriken then
		if nz then
			local q = Quaternion:New_FromNormal(nx,ny,nz)
			AddPFX("monsterweap_hitground",0.2, Vector:New(x,y,z),q)
		end

		if z then
			self:PlaySound("SoundHitByBullet",nil,nil,nil,nil,x,y,z)
		end
	end
		
	if self._enabledRD then
		return true
	end
end


function o:Stomp(joint)
	local x,y,z = self:GetJointPos(joint)

	y = y - 4
	Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange, self.CameraM, self.CameraM, 1.0)
	if debugMarek then
		DebugSphereX = x
		DebugSphereY = y
		DebugSphereZ = z
		DebugSphereRange = self.AiParams.explosionWhenWalkRange
	end
	WORLD.Explosion2(x,y,z, self.AiParams.explosionWhenfStreng, self.AiParams.explosionWhenWalkRange, nil, AttackTypes.Step, self.AiParams.explosionWhenWalkDamage)
    local j = MDL.GetJointIndex(self._Entity, joint)
    --local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
    AddPFX('but',0.6,Vector:New(x,y,z))
end


--[[function o:CustomOnRelease()
	ENTITY.Release(self.uglyHackToForceAnimateRagdoll)
	self.uglyHackToForceAnimateRagdoll = nil
	self.Health = self._HealthMax
	self._ABdo = nil
	self:ForceAnim("idle1",true,0.0,0.0)
	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0)
	MDL.SetAnimTime(self._Entity,self._CurAnimIndex,0)
	self._onNextTick = true
	--self:AddTimer("aa",0.0)
	self.AIenabled = false
	Game:Print("custom on death")
	return true
end]]


function o:CustomDelete()
	if not LEVEL_RELEASING then
        AddAction({{"Wait:5"},{"L:Lev:Respawn(a[1],a[2],a[3])"}},nil,nil,self._orygPos.X,self._orygPos.Y,self._orygPos.Z)
	end
end

function o:OnConfuseEnemyLost()
    local brain = self._AIBrain
	brain._confuseEnemy = nil
	brain._lockedEnemy = nil
    for i,v in Actors do
		if v._AIBrain and v.Health > 0 and v.Model ~= self.Model and v.AIenabled then --and not v.NeverMove then
			if v.Animation ~= "stuned" then
				brain._confuseEnemyTimer = 99999
				brain._confuseEnemy = v
				brain._forceUpdateVisibility = true
				brain._enemyLastSeenPoint.X = v._groundx
				brain._enemyLastSeenPoint.Y = v._groundy
				brain._enemyLastSeenPoint.Z = v._groundz
				Game:Print(self._Name.." atakuje "..v._Name)
				self:Stop()
				break
			end
		end
    end
    if not brain._confuseEnemy then
		Game:Print(self._Name.." nie atakuje nikogo ")
		self:OnDamage(99999,self,AttackTypes.StickyBomb)
    end
end

function o:HiT()
	local brain = self._AIBrain
	if brain._lastHitTime > brain._lastMissedTime or not self.AIenabled then
		self:AddPFX("hit")
	end
end


function o:Respawn()
	if not self._enabledRD and not self._ABdo then
		ENTITY.EnableDraw(self._Entity, true)
		--Game:Print(self._Name.." DRAW TRUE ")
		
		self:EnableRagdoll(true,true)
		self.disableNoAnimDetection = true

		self._DontCheckFloors = true
		MDL.SetRagdollLinearDamping(self._Entity, 0.9)
		MDL.SetRagdollAngularDamping(self._Entity, 0.9)
	
		local vv = Vector:New(self:GetJointPos("ROOOT"))
		self._vv2 = Vector:New(self:GetJointPos("root"))
		self._vv2:Sub(vv.X,vv.Y,vv.Z)
	
		self._vectorz = {}

		for i=0,60 do
			local joint = i
			local a = MDL.GetJointName(self._Entity, i)
			if a ~= "<none>" then
				local x,y,z = MDL.GetRagdollJointPos(self._Entity, joint)
				self._vectorz[joint] = {}
				self._vectorz[joint].Pos = Vector:New(x,y,z)
					--self._vectorz[joint].Pos:Sub(self.Pos)
				self._vectorz[joint].Pos:Sub(vv)
				self._vectorz[joint].Pos.Y = self._vectorz[joint].Pos.Y + self.MagicNumber
				self._vectorz[joint].RotDst = Quaternion:New(MDL.GetRagdollJointRotation(self._Entity, joint))
			end
		end
				
		self._oleAngle = self.angle
		
		self.uglyHackToForceAnimateRagdoll = self:BindFX("pinokio",0.001,"root")
		--ENTITY.EnableDraw(self.uglyHackToForceAnimateRagdoll, false)
		self:ReleaseTimers()
		self.AIenabled = false
		--Game:Print("apply "..self.Animation.." "..MDL.GetAnimTime(self._Entity,self._CurAnimIndex))
		MDL.SetBlendAlpha(self._Entity, 0)
		self:AddPFX("spawn")
		--MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	end

	self:ReleaseTimers()
end

function o:OnApply()
	if not self._skipShit then
		self._orygPos = Clone(self.Pos)
		self:ReleaseTimers()
		--Game:Print(self._Name.." DRAW FALSE "..GetCallStackInfo(2).." "..GetCallStackInfo(3))
		self:Respawn()
	end
end

function o:WakeUp()
	if not self._ABdo and not self.AIenabled then
		self._ABdo = 1
		self._timerUnGib = self.enableUnGib
		self._mode = 0
		
		MDL.SetMaterial(self._Entity, self.effect)
		self._alpha = 1
		self:PlaySound("con")
	end
end

function o:OnTick(delta)
	if self._alpha and self._alpha > 0 then
		self._alpha = self._alpha - delta * self.BlendOutSpeed
		if self._alpha <= 0 then
			self._alpha = 0
			MDL.SetMaterial(self._Entity, "")
		end
		MDL.SetBlendAlpha(self._Entity, self._alpha)
	end

	--if self._onNextTick then
	--	self:OnApply()
	--	self._onNextTick = false
	--end
	
	local brain = self._AIBrain
	if brain._lastHitTime > 0 and brain._lastHitTime > brain._lastMissedTime and self.Health > 0 then
		Game:Print(self._Name.." walnal alastora")
		self:OnDamage(99999,self,AttackTypes.StickyBomb)
		return
	end
	
	if not self._ABdo then
		--[[if not self.AIenabled and Player and Player._lastTimeHit > 0 and Player._lastTimeHit + 2 > Game.currentTime then
			local dist = Dist2D(Player._lastPosHit.X,Player._lastPosHit.Z, self._groundx, self._groundz)
			local dist1D = math.abs(Player._lastPosHit.Y - self._groundy)
			
			-- trace od player w dol, czy pod spodem jest golem
			if debugMarek then
				Game:Print("gracz zraniony dist = "..Player._lastTimeHit.." "..Game.currentTime)
				DEBUGcx = PX
				DEBUGcy = PY + 1
				DEBUGcz = PZ
				DEBUGfx = PX
				DEBUGfy = PY - 5
				DEBUGfz = PZ
			end
			local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(PX,PY+1.0,PZ, PX,PY-5,PZ)
			if e then

				if debugMarek then
					Game:Print("gracz zraniony dist = "..Player._lastTimeHit.." "..Game.currentTime)
					self.yzdebug1 = PX + 0.1
					self.yzdebug2 = PY - 5 + d
					self.yzdebug3 = PZ
					self.yzdebug4 = PX + 0.1
					self.yzdebug5 = PY - 5
					self.yzdebug6 = PZ
				end


				Game:Print("E pod spodem")
				local obj = EntityToObject[e]
				if obj then
					if obj._Class == "CPlayer" then
						Game:Print(obj._Name.." GRACZ...")
						b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(PX,PY+0.99-d,PZ, PX,PY-5,PZ)
						if e then
							obj = EntityToObject[e]
						end
					end
					--Game:Print(obj._Name.." pod spodeM")
					if obj == self then
						self._ABdo = 1
						self._timerUnGib = self.enableUnGib
						self._mode = 0
						
						MDL.SetMaterial(self._Entity, self.effect)
						self._alpha = 1
						self:PlaySound("con")
					end
				end
			end
--			if dist < self.AiParams.wakeUpWhenPlayerHurtInDistance then
--			end
		end--]]
	else
		if self._ABdo == 1 then
    
            ---------- koniec--------
            if self._booting then
                if self._enabledRD then
                    self._enabledRD = nil
                    MDL.EnableRagdoll(self._Entity,false)
                    --MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.Ragdoll)
					ENTITY.PO_Enable(self._Entity,true)
					
					--MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
					--ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
                    
                    self.Pos = Vector:New(self:GetJointPos("root"))		-- czy rooot?
                    self.Pos:Sub(self._vv2.X,self._vv2.Y,self._vv2.Z)
                    self.Animation = "idle1"
                    self.angle = self._oleAngle
                    self._gibJoinMode = nil
                    self._skipShit = true
                    self:Apply()
                    self._vectorz = nil
                    self.disableNoAnimDetection = false
                    
                    --Game:Print("koniec ragdoll")
                    self._immPFX = {}
					local p = self.s_SubClass.ParticlesDefinitions.forJoints
					for i,v in self.s_SubClass.jointsT do
						table.insert(self._immPFX, self:BindFX(p.pfx, p.scale, v))
					end

                end
                -- 
                self:SetAnimSpeed((self.enableUnGibStart - self._booting)/self.enableUnGibStart)
                
                self._booting = self._booting - delta
                if self._booting < 0 then
                    self._booting = nil
                    if debugMarek then Game:Print("end bootong") end
                    self:SetAnimSpeed(1.0)
                    self.AIenabled = true
                    self._ABdo = 2
                    self:OnConfuseEnemyLost()
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
                
                    if self.s_SubClass.GibEmitters then
                        for i,v in self.s_SubClass.GibEmitters do
                            local gibFX = self.s_SubClass.reverseGibFX
                            if gibFX then
								self:BindFX(gibFX,0.2,v[1], nil,nil,nil, v[3])
							end
                        end
                    end
                
                    Game:Print("->boot")
                    self._booting = self.enableUnGibStart
                    self._timerUnGib = 0
                    t = 0
    
                end
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
                self._timerUnGib = self._timerUnGib - delta
            end
        end
    end
end
