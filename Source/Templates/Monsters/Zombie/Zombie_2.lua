function Zombie_2:Take()
    local brain = self._AIBrain
    if brain.Objhostage2 then
        local aiParams = self.AiParams
        
        local j = MDL.GetJointIndex(self._Entity,aiParams.holdJoint)
        local x,y,z = MDL.TransformPointByJoint(self._Entity, j, aiParams.holdJointDisplaceSword.X, aiParams.holdJointDisplaceSword.Y, aiParams.holdJointDisplaceSword.Z)
        local x2,y2,z2
        brain._JointH,x2,y2,z2 = self:GetClosestJoint(x,y,z, brain.Objhostage2._Entity)
		if debugMarek then
			self.DEBUGl4 = x
			self.DEBUGl5 = y
			self.DEBUGl6 = z
	    
			self.DEBUGl1 = x2
			self.DEBUGl2 = y2
			self.DEBUGl3 = z2
		end
        if Dist3D(x,y,z,x2,y2,z2) < 1.0 then
			Game.BodyCountTotal = Game.BodyCountTotal - 1
			local obj = GObjects:Add(TempObjName(),CloneTemplate(brain.Objhostage2.BaseObj))
			
			local v = Vector:New(Player._groundx - self._groundx, Player._groundy - self._groundy, Player._groundz - self._groundz)
		    v:Normalize()

			if self.reviveFXsrc then
				AddPFX(self.reviveFXsrc,0.2,Vector:New(x,y,z))
			end

			local a,b = WPT.GetClosest(x2,y2,z2)
			x,y,z = WPT.GetPosition(a,b)
			
			if debugMarek then
				self.DEBUGl4 = x
				self.DEBUGl5 = y
				self.DEBUGl6 = z
			end

			if self.reviveFXdst then
				AddPFX(self.reviveFXdst,0.2,Vector:New(x,y,z))
			end

			obj.Pos.X = x
			obj.Pos.Y = y + 1.5
			obj.Pos.Z = z
			obj.angle = self.angle
			obj._angleDest = self._angleDest
			obj:Apply()
			obj._AIBrain._enemyLastSeenPoint.X = Player._groundx				-- hunt PLAYER
			obj._AIBrain._enemyLastSeenPoint.Y = Player._groundy
			obj._AIBrain._enemyLastSeenPoint.Z = Player._groundz
			obj._AIBrain._enemyLastSeenTime = obj._AIBrain._currentTime
			obj:Synchronize()
			if brain.Objhostage2._deathTimer then
				brain.Objhostage2._deathTimer = -1
			else
				GObjects:ToKill(brain.Objhostage2)
			end
			if debugMarek then Game:Print("brain.Objhostage2 NIL, bo koniec ozywiania") end
			brain.Objhostage2 = nil
        else
            brain.Objhostage2._locked = false
            brain.Objhostage2 = nil
        end
        brain._JointH = nil
    end
end




function Zombie_2:OffWithHisHead(target,vx,vy,vz)
	if not target._headLess then
		MDL.SetMeshVisibility(target._Entity,"polySurfaceShape543", false)
		
		self._beheadedTarget = true
		
		target:SetAnim("idle", false, false, 0.15)
		target:FullStop()
		target.enableAIin = nil
		target.AIenabled = false
		target._headLess = 1
		target._disableHits = true
		
		--
		local obj = GObjects:Add(TempObjName(),CloneTemplate("Zombie_Soldier_Head.CItem"))
		local Joint = MDL.GetJointIndex(target._Entity, "k_glowa")
		local x,y,z = MDL.TransformPointByJoint(target._Entity,Joint,0,0,0)

		obj.ObjOwner = target
		obj.Pos.X = x
		obj.Pos.Y = y
		obj.Pos.Z = z
		if self._AIBrain and self._AIBrain.r_closestEnemy then
			obj.PosDestX = target._groundx - self._groundx
			obj.PosDestY = target.Pos.Y - self.Pos.Y
			obj.PosDestZ = target._groundz - self._groundz
		end
		obj:Apply()
		--
		
		if Tweak.GlobalData.GermanVersion then
			target._fx = target:BindFX("FX_cuthead_german",0.5,"k_glowa")
		else
			target._fx = target:BindFX("FX_cuthead",0.5,"k_glowa")
		end

		target:PlaySound("missingHead")

		if target.Health > 0 then
			target.Health = 1
		end
		if not target.AiParams.berserkTime then
            target.AiParams.berserkTime = 5
        end
	
		if target.CustomUpdateZombie2 then
			target:ReplaceFunction("CustomUpdate","CustomUpdateZombie2")
		end
	end	
end


--------------------------
AiStates.zombieRevive = {
	name = "zombieRevive",
}

function AiStates.zombieRevive:OnInit(brain)
	local actor = brain._Objactor
	actor:WalkTo(self.vecx, self.vecy, self.vecz, true)
	--self.initialDistance = Dist3D(actor._groundx,actor._groundy,actor._groundz, self.vecx, self.vecy, self.vecz)
	self.active = true
	self.state = 0

	actor._oldColGr = MDL.GetRagdollCollisionGroup(brain.Objhostage2._Entity)
	
	if debugMarek then Game:Print(brain.Objhostage2._Name.." RCG = "..actor._oldColGr) end
	
    MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.RagdollSpecial)
	if brain.Objhostage2._deathTimer < 600 then
		brain.Objhostage2._deathTimer = brain.Objhostage2._deathTimer + 60		-- +2 sec. bonusu
	end
	self.maxRetries = 5
	brain._JointH = nil
end

function AiStates.zombieRevive:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	brain._lastTimeSpecial = brain._currentTime
	if brain.Objhostage2 then
		if brain.Objhostage2._deathTimer then
			brain.Objhostage2._deathTimer = brain.Objhostage2._deathTimer + 1
		end
	else
		self.active = false
		return
	end
	if actor._isWalking --[[and not actor._proc--]] then
		--local x,y,z = brain.Objhostage2:GetJointPos(brain.Objhostage2.s_SubClass.ragdollJoint)
		
		local j,x,y,z = actor:GetClosestJoint(actor._groundx,actor._groundy,actor._groundz, brain.Objhostage2._Entity)
		
		local diff = Dist3D(x,y,z, self.vecx, self.vecy, self.vecz)
		if debugMarek then
			actor.DEBUG_P1 = self.vecx
			actor.DEBUG_P2 = self.vecy
			actor.DEBUG_P3 = self.vecz
			-- if pos changed:
			actor.DEBUG_P4 = actor._groundx
			actor.DEBUG_P5 = actor._groundy
			actor.DEBUG_P6 = actor._groundz
		end
		
		local dist = Dist3D(x,y,z, actor._groundx,actor._groundy,actor._groundz)

--		if dist > self.initialDistance then
--			self.active = false
--			Game:Print("za daleko, ignore")
--			return
--		end
		
		if (diff > 0.5 and math.random(100) < 20) then
			actor:WalkTo(x,y,z, true)
			self.vecx = x
			self.vecy = y
			self.vecz = z
			if debugMarek then Game:Print("diff > 0.5 "..diff) end
		end
		
		if dist < 1.0 and diff <= 0.5 then
			actor:Stop()
			--WORLD.SetWorldSpeed(0.1)
			actor:SetAnim('nadziewa', false)
			self._fx = actor:BindFX(unpack(aiParams.ReviveSwordFX))
			self.state = 1
			--self.OLDminimumTimeBetweenHitAnimation = actor.minimumTimeBetweenHitAnimation
			--actor.minimumTimeBetweenHitAnimation = -1
		end
		
		if brain._distToNearestEnemy < aiParams.attackRange then
			if debugMarek then Game:Print("przerwal dochodzenie do ragdolla, zeby mnie zdzielic w rylo") end
			self.active = false
			actor:Stop()
		end
	else
		-- jesli obstacle, to walk again
		--
		if self.state == 0 then
		
			self.maxRetries = self.maxRetries - 1
			if self.maxRetries < 0 then
				self.active = false
				if debugMarek then Game:Print("behead - max retries reached") end
				return
			end

			if debugMarek then Game:Print("retry - narazie") end
			local x,y,z = brain.Objhostage2:GetJointPos(brain.Objhostage2.s_SubClass.ragdollJoint)
			actor:WalkTo(x,y,z, true)
		end
	end

	if self.state == 1 then
		--Game:Print("actor.Animation = "..actor.Animation.." "..brain._lastDamageTime.." "..brain._currentTime)
		if (not actor._isAnimating or actor.Animation ~= "nadziewa") then
			if debugMarek then Game:Print("inna animacja") end
			if self._fx then
				ENTITY.Release(self._fx)
				self._fx = nil
			end

			if brain.Objhostage2 then
				--[[if actor._proc then
					actor._proc._ToKill = true
					if debugMarek then Game:Print(">ktos przerwal mu ozywianie") end
				end
				if brain._JointH then
					--Game:Print(">odpinowanie")
					MDL.SetPinnedJoint(brain.Objhostage2._Entity, brain._JointH, false)	
					brain._JointH = nil
				end--]]
				if debugMarek then Game:Print(">NILowanie") end

				if actor._oldColGr then
					actor._oldColGr = nil
					MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, actor._oldColGr)
				end
				brain.Objhostage2._locked = nil
				brain.Objhostage2 = nil
			else
				if debugMarek then Game:Print(">NO Hostage") end
			end
			self.active = false
		end
	end
end


function AiStates.zombieRevive:OnRelease(brain)
	local actor = brain._Objactor
	self.active = false
	--if not actor._proc or actor._proc._ToKill
	--actor._proc = nil
	if debugMarek then Game:Print("zombieRevive:OnRelease(brain)") end
	if brain.Objhostage2 then
		--[[if brain._JointH then
			MDL.SetPinnedJoint(brain.Objhostage2._Entity, brain._JointH, false)
			brain._JointH = nil
		end--]]
		if actor._oldColGr then
			MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, actor._oldColGr)
			actor._oldColGr = nil
		end
		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end
	if self._fx then
		ENTITY.Release(self._fx)
		self._fx = nil
	end
end


function AiStates.zombieRevive:Evaluate(brain)
	if self.active and brain.Objhostage2 then
		return 0.7
	else
		local actor = brain._Objactor
		local aiParams = actor.AiParams
		if brain._distToNearestEnemy > aiParams.attackRange and math.random(100) < 30 and not actor._proc and not brain.Objhostage2 then		-- ### czy potrzebne _proc i _proc jest killowany
			--local x,y,z = actor:GetJointPos(aiParams.holdJoint)			-- sprawdzanie odl od j do j
			if brain._lastTimeSpecial + aiParams.minDelayBetweenBehead < brain._currentTime then
				local maxDist = 9999
				for i,v in Actors do
					if v.Health <= 0 then
						if v.s_SubClass.ragdollJoint and v._enabledRD and not v._locked and not v._gibbed and not v.Pinned and
							aiParams.CanBehead == v.Model then
							self.vecx, self.vecy, self.vecz = v:GetJointPos(v.s_SubClass.ragdollJoint)
							local dist = Dist3D(self.vecx, self.vecy, self.vecz, actor._groundx,actor._groundy,actor._groundz)
							-- get velocity of joint
							--local _velocityx,_velocityy,_velocityz,_velocity = ENTITY.GetVelocity(v._Entity)
							--Game:Print("dist to enemy = "..(brain._distToNearestEnemy*0.9).." dist to rd = "..dist)
							--
							if dist < maxDist and dist < aiParams.viewDistance and dist < brain._distToNearestEnemy * 0.9 then
								if ENTITY.SeesEntity(actor._Entity, v._Entity) then
									maxDist = dist
									brain.Objhostage2 = v
								end
							end
						end
					end
				end
				if brain.Objhostage2 then
					brain.Objhostage2._locked = true
					return 0.65
				end
			end
		end
	end
	return 0.0
end

