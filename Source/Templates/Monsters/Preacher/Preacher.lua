function o:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastThrowTime = FRand(-3, 0)
	self._AIBrain._moveLR = 0
end

function o:OnCreateEntity()
--	self:BindFX("pochodnia",0.2,"tasak",0,0.8,2)
	self._bodyCountimmortalEnd = Game.BodyCountTotal + self.AiParams.immortalBodiesCounter
end

function o:SomeoneDied(target)
	if self._bodyCountimmortalEnd >= Game.BodyCountTotal and target.throwHeart then
		local obj = GObjects:Add(TempObjName(),CloneTemplate("MonsterSoul.CItem"))
		obj.Pos = Vector:New(target:GetJointPos("root"))
		obj._destPos = Clone(self.Pos)
		obj:Apply()
		obj:Synchronize()
		--Game:Print("Create Soul")
        target.throwHeart = nil
	end
end

function o:OnPrecache()
    Cache:PrecacheParticleFX("monsterweap_hitground")
    Cache:PrecacheItem("MonsterSoul.CItem")
end

function o:CustomOnDamage(he,x,y,z,obj, damage, type,nx,ny,nz)
	if self._bodyCountimmortalEnd >= Game.BodyCountTotal then
		self:PlaySoundHit("hitImmortal")
			if z then
				local s = self.s_SubClass.ParticlesDefinitions.hitImmortal
				local q
				if nz then
					q = Quaternion:New_FromNormal(-nx,-ny,-nz)
				end
				AddPFX(s.pfx,s.scale,Vector:New(x,y,z),q)
			end
		return true
	end
end

function o:CustomOnDeath()
	if self._rtfx then
		PARTICLE.Die(self._rtfx)
		self._rtfx = nil
	end
	ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
	local brain = self._AIBrain
	if brain._stuffToThrow then
		local stuff = brain._stuffToThrow
		if stuff.Model then
			MDL.SetPinnedJoint(stuff._Entity, stuff._holdJoint, false)
			MDL.SetRagdollLinearDamping(stuff._Entity,0.5)
			if stuff._holdQ then
				--stuff.Rot = Quaternion:New_FromEuler(stuff._holdQ.X,stuff._holdQ.Y,stuff._holdQ.Z)
			end
		else
			ENTITY.PO_SetPinned(stuff._Entity, false)
		end
		stuff._locked = nil
		stuff._pinnedByAI = nil
		brain._stuffToThrow = nil
		if self._bindedRagdollFX then
			for i,v in self._bindedRagdollFX do
				PARTICLE.Die(v)
			end
			self._bindedRagdollFX = nil
		end
	end

	if self._bindedRagdollSound then
		local e = ENTITY.GetPtrByIndex(self._bindedRagdollSound)
		if e then
			ENTITY.Release(e)
		end
		self._bindedRagdollSound = nil
	end
end

function o:CustomOnGib()
	if self._AIBrain._throwed then
		--MDL.SetMeshVisibility(self._Entity, "polySurfaceShape991", false)
		--MDL.EnableJoint(self._Entity, MDL.GetJointIndex(self._Entity, "br1"), false)
	end
end


function o:GetThrowItemRotation()
	local q = Quaternion:New()
	q:FromEuler( 0, -self.angle - math.pi/2, math.pi/2)
	self._AIBrain._throwed = true
	return q
end

function o:Take()
    local brain = self._AIBrain

    if brain._stuffToThrow then
        local aiParams = self.AiParams
		local stuff = brain._stuffToThrow
        
        brain._stuffToThrow.Pos.X,brain._stuffToThrow.Pos.Y,brain._stuffToThrow.Pos.Z = ENTITY.GetPosition(brain._stuffToThrow._Entity)
		--brain._stuffToThrow._holdJointX = nil
        self._holdBastardPos = true


		if not brain._stuffToThrow.Model then
			ENTITY.PO_SetPinned(brain._stuffToThrow._Entity, true)
			ENTITY.SetVelocity(brain._stuffToThrow._Entity,0,0,0)
		else
			brain._stuffToThrow._holdJoint = MDL.GetJointIndex(brain._stuffToThrow._Entity, self.AiParams.destJoint)
			brain._stuffToThrow._holdJointX,brain._stuffToThrow._holdJointY,brain._stuffToThrow._holdJointZ = MDL.GetJointPos(brain._stuffToThrow._Entity,brain._stuffToThrow._holdJoint)
			
	        local q = Quaternion:New(MDL.GetRagdollJointRotation(stuff._Entity, stuff._holdJoint))
            local x,y,z = q:ToEuler()
            brain._stuffToThrow._holdQ = Vector:New(x,y,z)
			
			MDL.SetPinnedJoint(brain._stuffToThrow._Entity, brain._stuffToThrow._holdJoint, true)
			MDL.SetRagdollLinearDamping(brain._stuffToThrow._Entity,0.0)
			MDL.ApplyVelocitiesToJoint(brain._stuffToThrow._Entity, brain._stuffToThrow._holdJoint, 0,0,0,0,0,0)
		end

		brain._stuffToThrow._pinnedByAI = true
        self._stuffUp = true
        self._stuffUpVel = 0.05
        self._velInterpol = 0
        
        
        snd, self._bindedRagdollSound = brain._stuffToThrow:BindSound("actor/preacher/preacher-charm-loop",10,40,true)
		local sndPtr = SND.GetSound3DPtr(snd)
		SOUND3D.SetVolume(sndPtr, 0, 0)
		SOUND3D.SetVolume(sndPtr, 100, 2.0)

    end
end

function o:Throw()
    local brain = self._AIBrain
	if brain._stuffToThrow and brain._stuffToThrow.Health > 0 then
		self._stuffUp = false
		self._objTakenToThrow = brain._stuffToThrow
		self._getVelOnly = Vector:New(0,0,0)
		
		self:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)

		self:ThrowTaken()
	end
end

function o:OnTick(delta)
    if not self.AIenabled then return end
	if self._holdBastardPos then
        local brain = self._AIBrain
		local stuff = brain._stuffToThrow
		if stuff and stuff._gibbed then
			self._holdBastardPos = nil
			return
		end
		if stuff and not stuff._ToKill then
			if self._stuffUp then
				
				if stuff.Model then
	
					stuff._holdJointY = stuff._holdJointY + delta * self._stuffUpVel * self.AiParams.stuffLiftSpeed
					
					MDL.ApplyPositionToJoint(stuff._Entity, stuff._holdJoint, stuff._holdJointX,stuff._holdJointY,stuff._holdJointZ)

					stuff._holdQ.Y = stuff._holdQ.Y + delta * self.AiParams.throwAngularVelocitySpeed/3
					local q = Quaternion:New_FromEuler(stuff._holdQ.X,stuff._holdQ.Y,stuff._holdQ.Z)
					MDL.ApplyRotationToJoint(stuff._Entity, stuff._holdJoint, q.W,q.X,q.Y,q.Z)

				else
					stuff.Pos.Y = stuff.Pos.Y + delta * self._stuffUpVel
					ENTITY.SetPosition(stuff._Entity, stuff.Pos.X, stuff.Pos.Y, stuff.Pos.Z)
					ENTITY.SetAngularVelocity(stuff._Entity,0,self._stuffUpVel,0)
				end
				self._stuffUpVel = self._stuffUpVel + delta * 1.66

			else
				if self._velInterpol < 1 then
					self._velInterpol = self._velInterpol + delta * 3
					if self._velInterpol > 1 then
						self._velInterpol = 1
					end
					
					if stuff.Model then
						stuff._holdJointY = stuff._holdJointY + delta * self._stuffUpVel * (1 - self._velInterpol)
						stuff._holdJointX = stuff._holdJointX + self._getVelOnly.X * self._velInterpol * delta
						stuff._holdJointZ = stuff._holdJointZ + self._getVelOnly.Z * self._velInterpol * delta

						MDL.ApplyPositionToJoint(stuff._Entity, stuff._holdJoint, stuff._holdJointX, stuff._holdJointY, stuff._holdJointZ)
						stuff._holdQ.Y = stuff._holdQ.Y + delta * self.AiParams.throwAngularVelocitySpeed/3
						local q = Quaternion:New_FromEuler(stuff._holdQ.X,stuff._holdQ.Y,stuff._holdQ.Z)
						MDL.ApplyRotationToJoint(stuff._Entity, stuff._holdJoint, q.W,q.X,q.Y,q.Z)

					else
						stuff.Pos.Y = stuff.Pos.Y + delta * self._stuffUpVel * (1 - self._velInterpol)
						stuff.Pos.X = stuff.Pos.X + self._getVelOnly.X * self._velInterpol * delta
						stuff.Pos.Z = stuff.Pos.Z + self._getVelOnly.Z * self._velInterpol * delta

						ENTITY.SetPosition(stuff._Entity, stuff.Pos.X, stuff.Pos.Y, stuff.Pos.Z)
					end
				else
					if self._velInterpol == 1 then
						self._velInterpol = 2
						self._objTakenToThrow = stuff
						self:ThrowTaken()		-- recalc velocity
						Game:Print(":: "..self._getVelOnly.X.." "..self._getVelOnly.Y.." "..self._getVelOnly.Z)
						
						if stuff.Model then
							MDL.SetPinnedJoint(stuff._Entity, stuff._holdJoint, false)
							MDL.SetRagdollLinearDamping(stuff._Entity,0.0)
							MDL.ApplyVelocitiesToAllJoints(stuff._Entity, self._getVelOnly.X, self._getVelOnly.Y, self._getVelOnly.Z,  
							    --self._toThrowAngularVel.X,self._toThrowAngularVel.Y,self._toThrowAngularVel.Z)
							    0,self.AiParams.throwAngularVelocitySpeed,0)
							--stuff.Rot = Quaternion:New_FromEuler(stuff._holdQ.X,stuff._holdQ.Y,stuff._holdQ.Z)
						else
							ENTITY.PO_SetPinned(stuff._Entity, false)
							ENTITY.SetVelocity(stuff._Entity, self._getVelOnly.X, self._getVelOnly.Y, self._getVelOnly.Z)
						end

						stuff.killOnCollision = true
						stuff._giveDamageOnCollision = self.AiParams.thrownItemDamage
						if not stuff.Model then
							ENTITY.EnableCollisions(brain._stuffToThrow._Entity, true, 0.5, 3)
						end
						if not stuff.OnCollision then
							stuff:ReplaceFunction("OnCollision","StdOnCollision")
						end
						
						self._holdBastardPos = nil
						if self._bindedRagdollSound then
							local e = ENTITY.GetPtrByIndex(self._bindedRagdollSound)
							if e then
								ENTITY.Release(e)
							end
							self._bindedRagdollSound = nil
						end
					end
				end
			end
		end
	end
	if self._preacherFly then
		ENTITY.PO_Move(self._Entity, self._mvx, self._mvy, self._mvz)
		local speed = delta * self.FlySpeed
		self._mvx = self._mvx + self._vo.X * speed
		self._mvy = self._mvy + self._vo.Y * speed
		self._mvz = self._mvz + self._vo.Z * speed
	end
end


function o:aaa()
	local stuff = self._a
	if not stuff.OnCollision then
		if stuff.Model then
			for i=1,4 do
				local joint = MDL.GetJointIndex(stuff._Entity,"joint"..i.."_getmass")
				if joint >= 0 then
					Game:Print(" ecol to "..joint)
					ENTITY.EnableCollisionsToRagdoll(stuff._Entity, joint, 0.01, 0.01)
				end
			end
		else
			ENTITY.EnableCollisions(stuff._Entity, true, 0.5, 3)
		end
		stuff:ReplaceFunction("OnCollision","StdOnCollision")
		
	end
end

----------------------------
o._CustomAiStates = {}


o._CustomAiStates.preacherAttack = {
	name = "preacherAttack",
}
function o._CustomAiStates.preacherAttack:OnInit(brain)
    local actor = brain._Objactor
    if not self.firstTime then
        self.firstTime = true
        if actor.s_SubClass.SoundsDefinitions.onAttackOnce then
			actor:PlaySoundAndStopLast("onAttackOnce", nil, nil, true)
		end
    end
end

function o._CustomAiStates.preacherAttack:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	if not actor._isWalking then
		if math.random(100) < 10 then
			--Game:Print(">> Rot")
			actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
		end
	end

	if not actor._isWalking and not actor._isRotating then
		self.changePosOrEscapeInProgress = false
		
		if brain._distToNearestEnemy > aiParams.throwRangeMax * 0.85 or brain._moveLR > 2 then
			local run = true
			if math.random(100) < 40 then
				run = false
			end
			if math.random(100) < 50 and brain._moveLR <= 2 then
				--Game:Print(">> far:Rot")
				actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
			else
				--Game:Print(">> far:walkto")
				-- pozniej jesli sredni dystans to na boki
				local maxDist = aiParams.throwRangeMax * 0.25
				if brain._moveLR > 2 then
					Game:Print(">> far:walk move lr")
					brain._moveLR = 0
					maxDist = FRand(8,12)
				end
				actor:WalkTo(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, run, maxDist)
			end
		else
			if brain._distToNearestEnemy < aiParams.throwRangeMin * 1.2 and brain._distToNearestEnemy >= aiParams.attackRange then
				--Game:Print(">> close")
				actor:WalkTo(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
				return
			end

			if brain._changePos then
				brain._changePos = false
				-----
				--Game:Print(">> changePOS")
				brain._moveLR = 0
							
				if aiParams.changePosAfterFireDist then
					dist = FRand(aiParams.changePosAfterFireDist*0.8,aiParams.changePosAfterFireDist*2.0)
				else
					dist = FRand(4,9)
				end
				
				local ang = math.random(50,100)
				if math.random(100) < 50 then
					ang = -ang
				end
				--local ang = math.random(-90,90)
				local angle = math.mod(actor._angleDest + ang * math.pi/180, math.pi * 2)

				local v = Vector:New(math.sin(angle), 0, math.cos(angle))
				v:Normalize()
				local dxx = actor._groundx + v.X*dist
				local dy = actor._groundy
				local dzz = actor._groundz + v.Z*dist
				
				local b2,d2 = WORLD.LineTraceFixedGeom(actor._groundx,actor._groundy + 1,actor._groundz,actor._groundx + v.X*(dist + actor._SphereSize * 1.3333),dy + 1,actor._groundz + v.Z*(dist + actor._SphereSize * 1.3333))
				if debugMarek then
					actor.d1, actor.d2, actor.d3, actor.d4, actor.d5, actor.d6 = actor._groundx,actor._groundy + 1,actor._groundz,actor._groundx + v.X*(dist + actor._SphereSize * 1.3333),dy + 1,actor._groundz + v.Z*(dist + actor._SphereSize * 1.3333)
				end
				if b2 and d2 then
					--Game:Print(".changePosAfterFire col = "..d2..", planned= "..dist)
					dist = d2 - actor._SphereSize * 1.5
					dxx = actor._groundx + v.X*dist
					dzz = actor._groundz + v.Z*dist
					if dist < actor._SphereSize * 1.5 then
						--if debugMarek then Game:Print("CANCEL.changePosAfterFire - too close") end
						return
					else
						--Game:Print("changePosAfterFire - shortened to "..dist)
					end
				else
					--Game:Print("changePosAfterFire col = OK, dist = "..dist)
				end


				local b,d = WORLD.LineTraceFixedGeom(dxx, dy + actor._SphereSize * 3, dzz, dxx, dy - actor._SphereSize * 3, dzz)
				if d and d > actor._SphereSize*1.5 and d < actor._SphereSize * 4.5 then
					if debugMarek then
						actor.yaadebug1,actor.yaadebug2,actor.yaadebug3,actor.yaadebug4,actor.yaadebug5,actor.yaadebug6 = dxx, dy + actor._SphereSize * 3, dzz, dxx, dy - actor._SphereSize * 3, dzz
						actor.DEBUG_P1 = dxx
						actor.DEBUG_P2 = dy
						actor.DEBUG_P3 = dzz
					end
					--local b,d = WORLD.LineTraceFixedGeom(dxx,dy + 2,dzz,dxx,dy - 8,dzz)
					--if d and d > 1 and d < 3 then
					local distToPlayer2D = Dist3D(brain.r_closestEnemy._groundx, 0, brain.r_closestEnemy._groundz, dxx, 0, dzz)
					if distToPlayer2D > aiParams.attackRange * 1.2 then
						--Game:Print("Zmienia pozycje "..distToPlayer2D)
						actor:WalkTo(dxx, dy, dzz, true, dist * 1.3333, nil, true)		--- ### czy potrzebny tru na koncu
					else
						--if debugMarek then Game:Print("Nie zmienia pozycji, bo by sie znalazl za blisko gracza "..distToPlayer2D) end
					end
				else
					--if debugMarek then Game:Print("Nie zmienia pozycji, bo by sie znalazl za blisko gracza2") end
					return
				end


				-----
			end
		end
	end
end

function o._CustomAiStates.preacherAttack:OnRelease(brain)
end

function o._CustomAiStates.preacherAttack:Evaluate(brain)
	if brain._seeEnemy or self.changePosOrEscapeInProgress then
		return 0.2
	end
	return 0
end

o._CustomAiStates.throwStuff = {
	name = "throwStuff",
	delayRandom = FRand(0,1),
}

function o._CustomAiStates.throwStuff:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	Game:Print("start trzymanie")
	actor:Stop()
	actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z) -- czy do itema
	actor:SetAnim("atak3", false)
	--actor._rtfx = actor:BindFX(aiParams.ragdollThrowFX,aiParams.ragdollThrowFXScale,"dlo_lewa_root")
	actor._disableHits = true
	self.active = true
	if brain._stuffToThrow and brain._stuffToThrow.Model then
		aiParams.throwDistMinus = aiParams.throwDistMinus_M
		aiParams.throwDeltaY = aiParams.throwDeltaY_M
	else
		aiParams.throwDistMinus = aiParams.throwDistMinus_D
		aiParams.throwDeltaY = aiParams.throwDeltaY_D
	end
end

function o._CustomAiStates.throwStuff:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
    if not brain._stuffToThrow then
		Game:Print(actor._Name.." nie ma czym rzucic?")
        self.active = false
        return
    end
    
	if not actor._isAnimating or actor.Animation ~= "atak3" then
		Game:Print(actor._Name.." actor.Animation")
		self.active = false
	else
		if brain._stuffToThrow._ToKill then
			self.active = false
			actor:SetIdle()
		end
	end

	brain._lastThrowTime = brain._currentTime
end

function o._CustomAiStates.throwStuff:OnRelease(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	brain._changePos = true
	--Game:Print(">><< changePOS = true")
	 actor:StopLastSound()
	actor._holdBastardPos = nil
    if brain._stuffToThrow then
		local stuff = brain._stuffToThrow
		if stuff.Model then
			MDL.SetPinnedJoint(stuff._Entity, stuff._holdJoint, false)
			--MDL.SetRagdollLinearDamping(stuff._Entity,0.0)
            if stuff._holdQ then
                --stuff.Rot = Quaternion:New_FromEuler(stuff._holdQ.X,stuff._holdQ.Y,stuff._holdQ.Z)
            end
		else
		   	ENTITY.PO_SetPinned(brain._stuffToThrow._Entity, false)
		end
        brain._stuffToThrow._locked = nil
        brain._stuffToThrow._pinnedByAI = nil
        brain._stuffToThrow = nil
    end
    
    if actor._bindedRagdollSound then
		local e = ENTITY.GetPtrByIndex(actor._bindedRagdollSound)
		if e then
			ENTITY.Release(e)
		end
		actor._bindedRagdollSound = nil
	end
    
    if actor._rtfx then
		PARTICLE.Die(actor._rtfx)
		actor._rtfx = nil
    end

	self.active = false
	actor._disableHits = false
end

function o._CustomAiStates.throwStuff:Evaluate(brain)
	-- tu trzeba spr. czy jest ragdoll miedzy playerem a soba i mozna nim rzucic
	if self.active then
		return 0.8
	else
		local actor = brain._Objactor
		local aiParams = actor.AiParams
		if brain._seeEnemy and brain._distToNearestEnemy > aiParams.throwRangeMin and brain._distToNearestEnemy < aiParams.throwRangeMax
			and math.random(100) < 10 and not brain._stuffToThrow and not actor._hitDelay then
			if brain._lastThrowTime + aiParams.minDelayBetweenThrow < brain._currentTime then
				local maxDist = aiParams.ragdollToThrowDistSearch
				brain._lastThrowTime = brain._currentTime
				local candidate = nil
				--local maxDistDeadBody = aiParams.ragdollToThrowDistSearch
                local candidateDistance = aiParams.throwRangeMax + 1
				for i,v in GObjects.Elements do
					if v._Class == "CItem" and v.Health > 0 and not v.takeDistance --[[and ENTITY.PO_IsEnabled(v._Entity)--]] then
						--Game:Print("p target "..v._Name)
						if not v._locked and not v._pinnedByAI and not v.Pinned and not v._gibbed then
						
							if (v.Model and v.enableGibWhenHPBelow) or not v.Model then
								local vx,vy,vz,vl = ENTITY.GetVelocity(v._Entity)
								local jointI = 0
								if v.Model then
									jointI = MDL.GetJointIndex(v._Entity, aiParams.destJoint)
								end
								if vl < 2.0 and jointI >= 0 and not v.ObjOwner then
									local b,d = WORLD.LineTraceFixedGeom(v.Pos.X,v.Pos.Y,v.Pos.Z, Player._groundx, Player._groundy + 1.7, Player._groundz)	-- moze nie co update?
									if not b then
										--Game:Print("sees "..v._Name)
										if not v.Model or MDL.GetJointIndex(v._Entity, aiParams.destJoint) >= 0 then
											local x,y,z = ENTITY.GetPosition(v._Entity)
											local b,d = WORLD.LineTraceFixedGeom(x,y,z, Player._groundx, Player._groundy + 1.7, Player._groundz)	-- moze nie co update?
											--Game:Print("#-2 "..v._Name)
											if not b then
	 											local v2 = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
       											v2:Normalize()

												--self.destx = x - v2.X
												--self.desty = y
												--self.destz = z - v2.Z
												local distToPlayer = Dist3D(x,y,z, Player._groundx,Player._groundy,Player._groundz)
												local distToTarget = Dist3D(x,y,z, actor._groundx,actor._groundy,actor._groundz)
												--local distToTargetBack = Dist3D(self.destx, self.desty, self.destz, actor._groundx,actor._groundy,actor._groundz)
												--Game:Print("dist to target = "..dist..", dist to targetBack = "..distToTargetBack)
												--Game:Print("#-1 "..v._Name)
												if --[[distToTargetBack < distToTarget + 0.1 and--]] distToPlayer > 4 and distToTarget < aiParams.throwRangeMax and distToPlayer < aiParams.throwRangeMax then 
													--Game:Print("#0 "..v._Name)
													local b = WORLD.LineTraceFixedGeom(x,y,z, x,y + 3.0,z)
													if not b then
														--Game:Print("#1 "..v._Name)
														local b = WORLD.LineTraceFixedGeom(x,y + 3.0,z,Player._groundx,Player._groundy+1.7,Player._groundz)
														if not b and candidateDistance > distToTarget then
															--Game:Print("#2 "..v._Name)
															candidate = v
															candidateDistance = distToTarget
														end
													end
												end
											end
										end
									else
										--Game:Print("nie widzi")
									end
								end
							end
						end
					end
				end
				if candidate then
					--if debugMarek then Game:Print(actor._Name.." %%%%Set hostage = "..candidate._Name) end
					brain._stuffToThrow = candidate
					candidate._locked = true
					return 0.9
				end
				brain._moveLR = brain._moveLR + 1
				--Game:Print("%%%%%%%%%%% brain._moveLR = "..brain._moveLR)
			end
		end
	end
	return 0.0
end






function o:CustomOnHit()
	local aiParams = self.AiParams
	if not self._ABdo and not self._AIBrain._stuffToThrow then
		if self._HealthMax * aiParams.ABHp > self.Health and ENTITY.PO_IsOnFloor(self._Entity) then
			if self._AIBrain._enemyLastSeenTime > 0 then
				local brain = self._AIBrain
				if self._AIBrain.r_lastDamageWho == Player or not self._AIBrain.r_lastDamageWho then
					self._AIBrain._goals = {}
					self._AIBrain._currentGoal = nil
					self._disableHits = true
					self:Stop()
					self:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
					--if self.Health > 1 then
						--self.Health = 1
					--end
					self._ABdo = 0
				end
			end
		end
	end
end



function o:IfMissedPlaySound()
	local brain = self._AIBrain
	if brain then
		if brain._lastHitTime < brain._lastMissedTime then
			self:PlaySound("missed")
			if self.s_SubClass.hitGroundJoint then
				--local x,y,z = self:GetJointPos(self.s_SubClass.hitGroundJoint)

				local Joint = MDL.GetJointIndex(self._Entity, self.s_SubClass.hitGroundJoint)
				--local x,y,z = MDL.GetJointPos(self._Entity,Joint)
				x,y,z = MDL.TransformPointByJoint(self._Entity, Joint, 0,0.8,2.0)

--[[				if debugMarek then
					DEBUGcx = x
					DEBUGcy = y
					DEBUGcz = z
					DEBUGfx = x
					DEBUGfy = y - 1.5
					DEBUGfz = z
				end--]]
				local b,d,x1,y1,z1 = WORLD.LineTraceFixedGeom(x,y+0.5,z,x,y-1.0,z)
				if b then
					local q = Quaternion:New_FromNormal(nx,ny,nz)
					AddPFX("monsterweap_hitground",0.3, Vector:New(x1,y1,z1),q)
				end
			end
		end
	end
end


function o:CustomUpdate()
	if self._ABdo then
		if self._ABdo == 0 and not self._isRotating then
            local brain = self._AIBrain
			self:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
			ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
			self.AiParams.throwDistMinus =	0
			self.AiParams.throwDeltaY = 1.2

			self:SetAnim("atak1",false)
			self._ABdo = 1
			self.AiParams.throwAngularVelocitySpeed = self.AiParams.throwAngularVelocitySpeedAB
			--self.AiParams.throwAngle = 10
			self.AiParams.throwMaxAnglePitchDiff = 30
			self.AiParams.throwMaxAngleYawDiff = 30
			self.AiParams.throwVelocity = 40
			self.AiParams.throwItemBindTo = "dlo_prawa_root"
			self.AiParams.throwDistMinus = 0
		end
		if self._ABdo == 1 then
			if (not self._isAnimating or self.Animation ~= "atak1") then
				self:SetAnim(self.AiParams.ThrowAnim, false)
				-- tuaj leci wolno na gracza
				self._ABdo = 2
			end
		end
		if self._ABdo == 2 then
            local dist = Dist3D(Player._groundx, Player._groundy, Player._groundz, self._groundx,self._groundy,self._groundz)
            if (not self._isAnimating or self.Animation ~= self.AiParams.ThrowAnim) or dist < 4 then
				self:OnDamage(self.Health + 2, self)
                local aiParams = self.AiParams
				WORLD.Explosion2(self.Pos.X,self.Pos.Y,self.Pos.Z, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)
				PlaySound3D("impacts/barrel-tnt-explode",x,y,z,20,150)
				self._ABdo = 3
			end
		end
	end
end


function o:FlyAtPlayer()
    local brain = self._AIBrain
	self:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
	ENTITY.PO_EnableGravity(self._Entity,false)
	self._preacherFly = true

	local angle = self._angleDest	-- czy angle
	local v = Vector:New(math.sin(angle), 0, math.cos(angle))
	v:Normalize()
	self._vo = Clone(v)
	v:MulByFloat(self.initialLevitateSpeed)
	self._mvx = v.X
	self._mvy = v.Y
	self._mvz = v.Z
end
