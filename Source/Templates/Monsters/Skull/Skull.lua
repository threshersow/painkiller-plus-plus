function Skull:OnCreateEntity()
    --self:BindFX('fireskull',0.13,'k_glowa',0.13,0,0)
end

function Skull:OnInitTemplate()
    self:SetAIBrain()
end



function Skull:CustomOnDeath()
	if self._proc then
		GObjects:ToKill(self._proc)
        self._proc = nil
	end
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
	
	local h = self._AIBrain.Objhostage
	if h and h._OldDeathTimer then
        MDL.SetPinned(h._Entity, false)
		MDL.SetPinnedJoint(h._Entity, self._AIBrain._JointH, false)
		--MDL.SetPinnedJoint(h._Entity, self._AIBrain._JointH2, false)
		MDL.ApplyPositionToJoint(h._Entity, self._AIBrain._JointH, self.Pos.X, self.Pos.Y, self.Pos.Z)		-- narazie POS., pozniej get POS gdy jeszcze bindowane
		--MDL.ApplyPositionToJoint(h._Entity, self._AIBrain._JointH2, self.Pos.X, self.Pos.Y, self.Pos.Z)		-- narazie POS., pozniej get POS gdy jeszcze bindowane

		--Game:Print(h._Name.." >>>> hostage deathtimer set >>>>> "..h._OldDeathTimer)

		h._dontPinStake = false
		h._deathTimer = h._OldDeathTimer
		h.DeathTimer = h._OldDeathTimer
		h._OldDeathTimer = nil
		h.AIenabled = true
		h._disableHits = false
	end
end

function Skull:Catch()
	local h = self._AIBrain.Objhostage
	if h and h.Health > 0 then
		h.s_SubClass = Clone(h.s_SubClass)
		self.s_SubClass = Clone(self.s_SubClass)
		
		self.s_SubClass.Ambients = {"idlecatch"}
		self.s_SubClass.Animations.idle = nil
		self._forceWalkAnim = "walkcatch"
		self.NeverRun = true
		self.NeverWalk = false
		self.AiParams.FarAttacks = {"shotcatch"}
		self.s_SubClass.Hits = nil
		
		h.s_SubClass.AnimationDeath = nil
		h._disableDeathSounds = true

		if not h._OldDeathTimer then
			h._OldDeathTimer = h.DeathTimer
		end

		h.DeathTimer = 999999
		h.enableGibWhenHPBelow = nil
		h:OnDamage(h.Health + 2, self)
		MDL.SetRagdollCollisionGroup(h._Entity, ECollisionGroups.RagdollSpecial)		
		--[[local p = h.s_Physics
		if p.Mass then
			Game:Print("set mass to "..p.Mass * 10)
			ENTITY.PO_SetMass(h._Entity, p.Mass * 10)	-- nie dziala jak trzeba
		end--]]
		
		self._hostageRagdollEnable = true
		
		local brain = self._AIBrain
		local aiParams = self.AiParams

		MDL.SetPinnedJoint(h._Entity, brain._JointH, true)

		h._dontPinStake = true

		self._proc = Templates["PBindJointToJoint.CProcess"]:New(self._Entity, self, aiParams.holdJoint, brain._JointH, h._Entity)
		GObjects:Add(TempObjName(), self._proc)

		if h.s_SubClass.SoundsDefinitions.catch then
			h:PlaySound("catch")
		end
		self:PlaySound("catchHellb")
	end
end



-----------------------
o._CustomAiStates = {}

o._CustomAiStates.TakeHostage = {
	name = "TakeHostage",
	active = false,
	delayToNextCatch = 0,
}

function o._CustomAiStates.TakeHostage:OnInit(brain)
	local actor = brain._Objactor
	actor._hostageRagdollEnable = nil
	local hostage = brain.Objhostage
	if hostage then
	 	local v = Vector:New(math.sin(hostage.angle), 0, math.cos(hostage.angle))
       	v:Normalize()
       	local aiParams = actor.AiParams
		self.destx = hostage._groundx - v.X * hostage.AiParams.catchPosition.X
		self.desty = hostage._groundy
		self.destz = hostage._groundz - v.Z * hostage.AiParams.catchPosition.Z
		--Game:Print("I'm gonna eat you little fishy")
		actor:WalkTo(self.destx, self.desty, self.destz, true)
		self.active = true

		hostage:SetIdle()
		if hostage.AIenabled and not hostage._died then
			hostage.AIenabled = false
			actor._disableHits = true
			hostage.enableAIin = 5
		else
			self.active = false
			self.delayToNextCatch = math.random(20,60)
			--Game.freezeUpdate = true
			Game:Print(actor._Name.." o sory juz jest zajety")
		end
	else
		Game:Print("NIE MA HOSTAGE???")		
	end
	self.playanim = false
	self.docking = false
	self.retry = false
	self.maxRetries = 25
end

function o._CustomAiStates.TakeHostage:OnUpdate(brain)
	local actor = brain._Objactor
    local hostage = brain.Objhostage
    local aiParams = actor.AiParams
    if hostage then
        if hostage.AIenabled then
            Game:Print(actor._Name.." MA JUZ AI, to go olewam")
            self.active = false
            self.delayToNextCatch = math.random(20,60)
            return
        end
        if hostage.enableAIin then
            hostage.enableAIin = hostage.enableAIin + 1
        end
    
        
        --- 1st stage
        --
        if not actor._isWalking then
            if not self.docking and not self.playanim then
                if self.retry then
                    local v = Vector:New(math.sin(hostage.angle), 0, math.cos(hostage.angle))
                    v:Normalize()
                    self.destx = hostage._groundx - v.X * hostage.AiParams.catchPosition.X
                    self.desty = hostage._groundy
                    self.destz = hostage._groundz - v.Z * hostage.AiParams.catchPosition.Z
                    Game:Print("I'm gonna eat you little fishy AGAIN "..(Dist3D(self.destx, self.desty, self.destz, actor._groundx,actor._groundy,actor._groundz)).." RETRY no"..self.maxRetries)
                    self.maxRetries =  self.maxRetries - 1
                    if self.maxRetries < 0 then
                        Game:Print("Max retries reached!")
                        self.active = false
                        --Game.freezeUpdate = true
                        return
                    end
                    if actor:WalkTo(self.destx, self.desty, self.destz, true) then
                        self.retry = false
                    else
                        Game:Print("Cant eat you!")
                        --Game.freezeUpdate = true
                        self.active = false
                        return
                    end
                end
    
                local dist = Dist3D(self.destx, self.desty, self.destz, actor._groundx,actor._groundy,actor._groundz)
                if dist > 0.7 then
                    Game:Print(actor._Name.." zle miejsce RETRY")
                    --self.active = false
                    --Game.freezeUpdate = true
                    self.retry = true
                    return
                end
    
                local dist2 = Dist3D(hostage._groundx, hostage._groundy, hostage._groundz, actor._groundx,actor._groundy,actor._groundz)
                if dist2 < aiParams.minCatchDistance then
                    brain._JointH = MDL.GetJointIndex(hostage._Entity, hostage.AiParams.catchJoint)
                    --brain._JointH2 = MDL.GetJointIndex(hostage._Entity, hostage.AiParams.catchJoint2)
                    if brain._JointH >= 0 and hostage.Health > 0 then
                        if hostage._AIBrain._velocity >= 1 then
                            self.active = false
                            self.delayToNextCatch = math.random(20,60)
                            Game:Print(actor._Name.." sorry, target moved "..hostage._AIBrain._velocity.." "..hostage.Health)
                            return
                        end
    
                        hostage._NonCollidableWithOtherRagDolls = true
                        Game:Print(actor._Name.." ---- GOTCHA")
                        self.docking = true
                    else
                        Game:Print(actor._Name.." joint not found of hostage or hostage died")
                        self.active = false
                        self.delayToNextCatch = math.random(20,60)
                        return
                    end
                else
                    --Game.freezeUpdate = true
                    Game:Print(actor._Name.." za daleko... RETRY "..dist2)
                    --self.retry = true
                    self.active = false
                    return
                end	
            end
        end
        
        -- 3rd stage:
        if self.docking and not self.playanim then
            local dist = Dist3D(self.destx, self.desty, self.destz, actor._groundx,actor._groundy,actor._groundz)
            if not actor._isWalking or dist < 0.1 then
                self.playanim = actor:SetAnim("catch",false)
                actor:Stop()
                actor:RotateToVector(hostage._groundx, hostage._groundy, hostage._groundz)
                Game:Print(actor._Name.." docked "..dist)
                self.docking = false
    --			Game.freezeUpdate = true
            end
        else
            -- last stage:
            if self.playanim then
                if (not actor._isAnimating or actor.Animation ~= "catch") then
                    Game:Print(actor._Name.." anim finished. Mam go?")
                    --MDL.ApplyPositionToJoint(hostage._Entity, brain._JointH, xa, ya, za)
                    self.active = false
                    self.delayToNextCatch = math.random(20,60)
                end
            end
        end
    else
        self.active = false
    end
end

function o._CustomAiStates.TakeHostage:OnRelease(brain)
	local actor = brain._Objactor
	self.active = false
	self.delayToNextCatch = math.random(20,40)
--	if actor.animation == "catch" then
--		Game:Print("!!!!!!111")
--		Game.freezeUpdate = true
--	end
	if not brain.Objhostage._OldDeathTimer or brain.Objhostage.Health > 0 then
		Game:Print(actor._Name.." >==> take hostage on release")
		if actor._isWalking then
			actor:Stop()
		end
		brain.Objhostage = nil
		actor._disableHits = false
		brain._JointH = nil
	else
		Game:Print(actor._Name.." >==> take hostage on release TAKEN")
	end
end

function o._CustomAiStates.TakeHostage:Evaluate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if brain._JointH and brain._JointH >= 0 and actor._hostageRagdollEnable then
		if brain.r_closestEnemy then
			if math.random(100) < 30 then
				actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
				actor._isRotating = false
			end
		else
			if brain._velocity > 0.1 and math.random(100) < 20 then
				--Game:Print("rrrr")
				self._angleDest = ENTITY.GetOrientation(self._Entity)
				--self._destAngle = math.atan2(destx - x, destz - z)
				--actor:RotateToVector(-brain._velocityx, -brain._velocityy, -brain._velocityz)
			end
		end
	else
		if aiParams.takeHostages and brain.r_closestEnemy and not self.active then
			if self.delayToNextCatch <= 0 then
				if math.random(100) < 10 then
					local candidate = nil
					local candidateDistance = 9999
					for i,v in Actors do
						if v._AIBrain and v.AiParams.catchJoint and v.Health > 0 and not v.Pinned then			-- dorobic zabezpieczenie, zeby dwoch nie staralo sie wzaisc jednego
							local dist = Dist3D(v._groundx,v._groundy,v._groundz,actor._groundx,actor._groundy,actor._groundz)
							if dist > 1.5 and dist < aiParams.viewDistance * 0.7 then
								if v._AIBrain._velocity and v._AIBrain._velocity < 1.0 then
									if ENTITY.SeesEntity(actor._Entity, v._Entity) then

	 									local v2 = Vector:New(math.sin(v.angle), 0, math.cos(v.angle))
       									v2:Normalize()

										self.destx = v._groundx - v2.X * (v.AiParams.catchPosition.X + actor._SphereSize)
										self.desty = v._groundy + 1
										self.destz = v._groundz - v2.Z * (v.AiParams.catchPosition.Z + actor._SphereSize)
										local distToTarget = dist
										local distToTargetBack = Dist3D(self.destx, self.desty, self.destz, actor._groundx,actor._groundy,actor._groundz)
										--Game:Print("dist to target = "..dist..", dist to targetBack = "..distToTargetBack)
										if distToTargetBack < distToTarget + 0.1 then 
											--actor.yaadebug1,actor.yaadebug2,actor.yaadebug3,actor.yaadebug4,actor.yaadebug5,actor.yaadebug6 = v._groundx, v._groundy + 1, v._groundz, self.destx, self.desty, self.destz
											local b,d = WORLD.LineTraceFixedGeom(v._groundx, v._groundy + 1, v._groundz, self.destx, self.desty, self.destz)
											if not d then	
												--actor.yadebug1,actor.yadebug2,actor.yadebug3,actor.yadebug4,actor.yadebug5,actor.yadebug6 = self.destx, self.desty + actor._SphereSize * 3, self.destz, self.destx, self.desty - actor._SphereSize * 3, self.destz
												-- czy jest miejsce za celem?
												local b,d = WORLD.LineTraceFixedGeom(self.destx, self.desty + actor._SphereSize * 3, self.destz, self.destx, self.desty - actor._SphereSize * 3, self.destz)
												if d and d > actor._SphereSize*1.5 and d < actor._SphereSize * 4.5 then
													if candidateDistance > distToTarget then
														candidate = v
														candidateDistance = distToTarget
													end
													--brain.hostage = v
													Game:Print(actor._Name.." ??Set hostage = "..distToTarget)
												end
											end
										end
									end
								end
							end
						end
					end
					if candidate then
						Game:Print(actor._Name.." !!Set hostage = "..candidate._Name)
						brain.Objhostage = candidate
						return 0.9
					end
				end
			else
				self.delayToNextCatch = self.delayToNextCatch - 1
			end
		end
	end

	if self.active then
		return 0.9
	else
		return 0
	end
end

