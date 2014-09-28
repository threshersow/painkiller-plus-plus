function Vamp_Big_throwragdoll:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastTimeSpecial = -100
end

function Vamp_Big_throwragdoll:CustomDelete()
	self:CustomOnDeath()
end


function Vamp_Big_throwragdoll:CustomOnDeath()
	local brain = self._AIBrain
	if brain.Objhostage2 then
		if brain._JointH then
            MDL.SetPinned(brain.Objhostage2._Entity, false)	
			MDL.SetPinnedJoint(brain.Objhostage2._Entity, brain._JointH, false)	
		end
		MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.RagdollNonColliding)
		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end
end

function Vamp_Big_throwragdoll:OnCreateEntity()
	--self.s_SubClass.walk = {"walkfast"}
	--self._runAltAnim = "walkfast"
end


function Vamp_Big_throwragdoll:Test()
	--Game.freezeUpdate = true
--[[    local brain = self._AIBrain
    if brain.Objhostage2 then
        local aiParams = self.AiParams
        
        local x,y,z = self:GetJointPos(aiParams.holdJoint)
        local x2,y2,z2
        brain._JointH,x2,y2,z2 = self:GetClosestJoint(x,y,z, brain.Objhostage2._Entity)
        if Dist3D(x,y,z,x2,y2,z2) < 1 and brain._JointH > 0 then
            self.DEBUGl4 = x
            self.DEBUGl5 = y
            self.DEBUGl6 = z

	        self.DEBUGl1 = x2
            self.DEBUGl2 = y2
            self.DEBUGl3 = z2
        end
    end--]]
end


function Vamp_Big_throwragdoll:Take()
    local brain = self._AIBrain
    if brain.Objhostage2 then
        local aiParams = self.AiParams
        
        local x,y,z = self:GetJointPos(aiParams.holdJoint)
        local x2,y2,z2
        brain._JointH,x2,y2,z2 = self:GetClosestJoint(x,y,z, brain.Objhostage2._Entity)
        if Dist3D(x,y,z,x2,y2,z2) < 1 and brain._JointH > 0 then
			if debugMarek then
				self.DEBUGl4 = x
				self.DEBUGl5 = y
				self.DEBUGl6 = z

				self.DEBUGl1 = x2
				self.DEBUGl2 = y2
				self.DEBUGl3 = z2
			end

			MDL.SetRagdollLinearDamping(brain.Objhostage2._Entity, aiParams.hostagesRagdollDamping)
			MDL.SetRagdollAngularDamping(brain.Objhostage2._Entity, aiParams.hostagesRagdollDamping)
               --brain._JointH = MDL.GetJointIndex(brain.Objhostage2._Entity, "r_p_lokiec")
            Game:Print("take "..brain._JointH.." dist to move: "..Dist3D(x,y,z,x2,y2,z2))
            MDL.SetPinnedJoint(brain.Objhostage2._Entity, brain._JointH, true)
            MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.Noncolliding)
            self._proc = PBindJointToJoint:New(self._Entity, self, aiParams.holdJoint, brain._JointH, brain.Objhostage2._Entity)
            self._proc:Tick(0, true)
            self._proc.rotationDisabled = aiParams.disableRotationRagdollWhileTake
            -- self._proc.CopyWholeMatrix = true
            GObjects:Add(TempObjName(), self._proc)
    
            self:RotateToVector(Player._groundx, Player._groundy, Player._groundz)

        else
            Game:Print("missed!")
            --MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.RagdollNonColliding)
            brain.Objhostage2._locked = nil
            brain.Objhostage2 = nil
        end
    end
end



function Vamp_Big_throwragdoll:Throw()
    if self._proc then
        GObjects:ToKill(self._proc)
        self._proc = nil
    end
    if self._AIBrain.Objhostage2 then
        local brain = self._AIBrain
        local aiParams = self.AiParams
    
        local x1,y1,z1 = self:GetJointPos(aiParams.holdJoint)
    
        local entity = brain.Objhostage2._Entity
    
--  rzut ukosny          
        local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
        v:Normalize()
        local temp = brain._distToNearestEnemy * Tweak.GlobalData.Gravity/math.sin(2 * aiParams.hostagesRagdollThrowAngle * math.pi/180)
        local force = math.sqrt(temp)
		brain.Objhostage2._velx = v.X*force
		brain.Objhostage2._vely = force		-- * v.Y
		brain.Objhostage2._velz = v.Z*force


-- rzut prosty
--		local v = Vector:New(Player._groundx - self._groundx, Player._groundy - self._groundy, Player._groundz - self._groundz)
--		v.Y = v.Y + 1.7
--		v:Normalize()
--		brain.Objhostage2._velx = v.X*force
--		brain.Objhostage2._vely = v.Y*force
--		brain.Objhostage2._velz = v.Z*force
--      local force = aiParams.throwSpeed		

        MDL.SetPinnedJoint(brain.Objhostage2._Entity, brain._JointH, false)	
        
		if debugMarek then
			self.d1 = brain.Objhostage2._velx
			self.d2 = brain.Objhostage2._vely
			self.d3 = brain.Objhostage2._velz
			self.d4 = x1
			self.d5 = y1
			self.d6 = z1
		end
		    
        MDL.ApplyVelocitiesToJointLinked(brain.Objhostage2._Entity, brain._JointH, brain.Objhostage2._velx, brain.Objhostage2._vely, brain.Objhostage2._velz, 0,0,0)
    end
end

function Vamp_Big_throwragdoll:EnableRagdollColl()
	local brain = self._AIBrain
	if brain.Objhostage2 then
		-- wlaczanie kolizji dla rzuconego ragdola
		Game:Print("EnableRagdollColl()")
		MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.RagdollNonColliding)
		brain.Objhostage2.RagdollCollDamage = self.AiParams.RagdollCollDamage
		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end
end


--------------------------
AiStates.throwRagdoll = {
	name = "throwRagdoll",
	_Class = "CAiGoal",
}

function AiStates.throwRagdoll:OnInit(brain)
	local actor = brain._Objactor
	actor:WalkTo(self.vecx, self.vecy, self.vecz)
	--self.initialDistance = Dist3D(actor._groundx,actor._groundy,actor._groundz, self.vecx, self.vecy, self.vecz)
	self.active = true
	self.state = 0
	MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.RagdollSpecial)
	if brain.Objhostage2 and brain.Objhostage2._deathTimer < 600 then
		brain.Objhostage2._deathTimer = brain.Objhostage2._deathTimer + 60		-- +2 sec. bonusu
	end

	self.maxRetries = 4
	brain._lastTimeSpecial = brain._currentTime
end

function AiStates.throwRagdoll:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if brain.Objhostage2 and brain.Objhostage2._deathTimer then
		brain.Objhostage2._deathTimer = brain.Objhostage2._deathTimer + 1
	end
	if actor._isWalking and not actor._proc then
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
		
		if (diff > 0.5 and math.random(100) < 20) then
			actor:WalkTo(x,y,z)
			self.vecx = x
			self.vecy = y
			self.vecz = z
			Game:Print("diff > 0.5 "..diff)
		end
		
		if dist < 1.0 and diff <= 0.5 then
			actor:Stop()

			--if debugMarek then WORLD.SetWorldSpeed(0.3) end

			actor:SetAnim('take_body',false)
			self.state = 1
		end
		
		if brain._distToNearestEnemy < aiParams.attackRange then
			Game:Print("przerwal dochodzenie do ragdolla, zeby mnie zdzielic w rylo")
			self.active = false
			actor:Stop()
		end
	else
		-- jesli obstacle, to walk again
		--
		if self.state == 0 then
			Game:Print("retry - narazie")
			self.maxRetries = self.maxRetries - 1
			if self.maxRetries < 0 then
				Game:Print("retry finished")
				--MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.RagdollNonColliding)
				brain.Objhostage2._locked = nil
				brain.Objhostage2 = nil
				self.active = false
				return
			end
			actor:WalkTo(brain.Objhostage2:GetJointPos(brain.Objhostage2.s_SubClass.ragdollJoint))
		end
		if self.state == 1 and (not actor._isAnimating or actor.Animation ~= "take_body") then
			if not brain.Objhostage2 then
				self.active = false
				return
			end
			actor:SetAnim('throw_stone', false)
			self.state = 2
		end
		if self.state == 2 and (not actor._isAnimating or actor.Animation ~= "throw_stone") and not actor._isRotating then
			self.active = false
			--actor._proc = nil			-- ############
		end
	end
end

function AiStates.throwRagdoll:OnRelease(brain)
	Game:Print("throw ragdoll on release")
	local actor = brain._Objactor
	self.active = false
	if brain.Objhostage2 then
		--MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, ECollisionGroups.RagdollNonColliding)
		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end
	--actor._proc = nil			-- ### ???
	brain._lastTimeSpecial = brain._currentTime
end


function AiStates.throwRagdoll:Evaluate(brain)
	if self.active then
		return 0.6
	else
		local actor = brain._Objactor
		local aiParams = actor.AiParams
		if brain._distToNearestEnemy > aiParams.attackRange and math.random(100) < 20 and not actor._proc and not brain.Objhostage2 then		-- ### czy potrzebne _proc i _proc jest killowany
			--local x,y,z = actor:GetJointPos(aiParams.holdJoint)			-- sprawdzanie odl od j do j

			if brain._lastTimeSpecial + aiParams.minDelayBetweenTakeHostage < brain._currentTime then
				local maxDist = 9999
				for i,v in Actors do
					if v.Health <= 0 then
						if v.s_SubClass.ragdollJoint and v._enabledRD and not v._locked and not v._gibbed and not v.Pinned then
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
					return 0.6
				end
			end
		end
	end
	return 0.0
end
--------------
