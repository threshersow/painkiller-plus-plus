function Amputee:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastTimeAttack = 0
end


function Amputee:SetIdle()		-- narazie
	self._state = "IDLE"
	self._isWalking = nil
	self._flying = nil
	return true
end

function Amputee:CustomOnDeath()
	self:barfend()
end

Amputee.CustomDelete = Amputee.CustomOnDeath
------------

o._CustomAiStates = {}
o._CustomAiStates.amputeeIdle = {
	name = "amputeeIdle",
}

function o._CustomAiStates.amputeeIdle:OnInit(brain)
	local actor = brain._Objactor
	self.lastAnim = actor.Animation
	--Game:Print("zaczyna z "..self.lastAnim)
	self.time = -100
    if self.patrolmode and self.patrolmode > 0 then
        self.patrolmode = -90           -- ??
    end
    self.delay = FRand(1.0, 1.8)
end


function o._CustomAiStates.amputeeIdle:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if self.patrolmode then
		self.patrolmode = self.patrolmode - 1
		if self.patrolmode > 0 then
			if not actor._isWalking then
				Patrol(actor, brain, false, nil, nil, self.lastAnim)
			end
		else
			if not actor._isWalking then
				actor:Stop()
				actor.Animation = ""
			end
		end
		if self.patrolmode < -120 then
			self.patrolmode = nil
		end
	end
	
	if not actor._isAnimating or actor.Animation == "" or math.random(100) < 30 then
		if not actor._isAnimating or actor.Animation == "" then
			self.delay = 0
		end
		if self.time + self.delay < brain._currentTime then
			for i,v in aiParams.idle do
				if v[1] == self.lastAnim then
					if actor._isAnimating and not v[5] then		-- not breakable
						break
					end
					if FRand(0.0, 1.0) < v[3] then
						--Game:Print(self.lastAnim.." wylosowane: "..v[2].." "..v[3])
						if v[2] == "walk1" then
							if not aiParams.GuardStill and not self.patrolmode then
								--Game:Print("walk patrol")
								Patrol(actor, brain, false, nil, nil, v[2])
								self.delay = FRand(2.0, 12.0)
								self.patrolmode = math.random(30,120)
								self.lastAnim = v[2]
								self.time = brain._currentTime
								break
							end
						else
							if self.patrolmode and self.patrolmode > 0 then
								self.patrolmode = -1
							end
							actor:Stop()
							actor:SetAnim(v[2],v[4])
							self.lastAnim = v[2]
							self.time = brain._currentTime
							brain._isLyingOnFloor = v[6]
							self.delay = FRand(1.5, 3.0)		-- pozniej lokalnie dla kazdego przejscia
							break
						end
					end
				end
			end
		end
	end

end

function o._CustomAiStates.amputeeIdle:OnRelease(brain)
	self.active = false
end

function o._CustomAiStates.amputeeIdle:Evaluate(brain)
	return 0.1
end


------------
o._CustomAiStates.amputeeAttack = {
	name = "amputeeAttack",
	walkAnims = {"walk1","walk2", "walk3", "walk4",},
	attackAnims = {"walk_atak", "walk_atak1",},
	lastAnim = "walk4",
    lastTimeDamage = -100,
}

-- dodac zmeczenie

function o._CustomAiStates.amputeeAttack:OnInit(brain)
	local actor = brain._Objactor
	self.active = true
	brain._enemyLastSeenTime = -1
	self.atakMode = nil
	brain._lastTimeAttack = brain._currentTime
	self.timeOut = nil
end

function o._CustomAiStates.amputeeAttack:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if not brain._seeEnemy then
		if actor._isWalking and FRand(0.0, 1.0) < 0.005 then
			if debugMarek then Game:Print("koniec ataku exit KONIEC BO") end
			actor:Stop()
			actor:SetAnim("idle_kolana", true)
			self.atakMode = nil
			self.active = false
			return
		end
	end
	if self.atakMode then
		if not actor._isAnimating then
			--Game:Print("pmove stopped normal")
			if actor._proc then
				GObjects:ToKill(actor._proc)
				actor._proc = nil
			end
		
			if FRand(0.0, 1.0) < aiParams.idleAfterAttack then
				--Game:Print("koniec ataku exit")
				actor:Stop()
				--if actor.Animation == "walk_atak" then
				--	actor:SetAnim("lezenie_idle", true)
				--else
					actor:SetAnim("idle_kolana", true)
				--end
				self.active = false
				return
			else
				--Game:Print("koniec ataku again")
				if brain.r_closestEnemy then
					actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
				end
				actor:Stop()
				local d = Dist3D(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, actor._groundx, actor._groundy, actor._groundz)
				if d > aiParams.attackRange then
					--local walkAnim = self.walkAnims[math.random(1,4)]
					--actor:WalkTo(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, false, nil, walkAnim)
					if debugMarek then Game:Print("koniec ataku 2") end
					--actor:SetAnim("idle_kolana", false)
					self.atakMode = nil
					self.timeOut = 15
					--self.active = false
					return
				else	
					local anim = self.attackAnims[math.random(1,2)]
					actor:SetAnim(anim, false)
				end
			end
		else
			if actor.Animation == aiParams.jumpAnim and brain.r_closestEnemy then				-- gdy jest za blisko gracza, a porusza sie z animacja, zeby go nie przepychal
				if self.lastTimeDamage + 1.5 < brain._currentTime then
					local dist = Dist3D(brain.r_closestEnemy._groundx,brain.r_closestEnemy._groundy,brain.r_closestEnemy._groundz,actor._groundx,actor._groundy,actor._groundz)
					if dist < aiParams.jumpDamageRange then
						self.lastTimeDamage = brain._currentTime
						brain.r_closestEnemy:OnDamage(actor.CollisionDamage, actor)
						PlaySound2D("actor/amputee/amp_hand_hit")
						if actor._proc then
							GObjects:ToKill(actor._proc)
							actor._proc = nil
						end
					end
				end
			end
		end
	else
		local d = Dist3D(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, actor._groundx, actor._groundy, actor._groundz)
		
		if d > aiParams.jumpRangeMin and brain._distToNearestEnemy < aiParams.jumpRangeMax and not actor._proc and brain._seeEnemy then
			--if (not actor._isAnimating or (actor._isAnimating and actor.Animation ~= aiParams.jumpAnim)) then
			if not self.timeOut then
				self.atakMode = true
				--if debugMarek then Game:Print("jump") end

				local speed = aiParams.jumpSpeed * aiParams.jumpAnimLen / d
				
				
				if debugMarek then Game:Print("%%%%% JUMP anim "..actor._CurAnimTime.." "..actor._CurAnimLength.." "..actor.Animation) end
					
					
				actor:SetAnim(aiParams.jumpAnim, false, speed)
				--actor._proc = PMove:New(actor, aiParams.jumpSpeed * 3.0)
				actor._proc = Templates["PMove.CProcess"]:New(actor, aiParams.jumpSpeed * 3.0)
				
				-- mam skakac przed siebie... a nie w strone wroga
				actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
				actor._proc:SetDir(Vector:New(brain._enemyLastSeenPoint.X - actor._groundx, 0, brain._enemyLastSeenPoint.Z - actor._groundz))
				GObjects:Add(TempObjName(), actor._proc)
				return
			end
		end

		if d > aiParams.attackRange or not brain._seeEnemy then
			if not actor._isWalking then
				local walkAnim = self.walkAnims[1]
				if math.random(100) < 20 then
					walkAnim = self.walkAnims[math.random(2,4)]
				end
				self.lastAnim = walkAnim
				--Game:Print(actor._Name.." walkto nw")
				actor:WalkTo(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, false, nil, walkAnim)
			else
				if math.random(100) < 4 then
					if math.random(100) < 20 then
						self.lastAnim = self.walkAnims[math.random(1,4)]
					end
					--Game:Print(actor._Name.." walkto ww")
					actor:WalkTo(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, false, nil, self.lastAnim)
				end
			end
		else
			actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
			local anim = self.attackAnims[math.random(1,2)]
			self.lastAnim = anim
			actor:SetAnim(anim, false)
			self.atakMode = true
		end
	end
	if self.timeOut then
		self.timeOut = self.timeOut - 1
		if self.timeOut < 0 then
			 self.timeOut = nil
		end
	end
	brain._lastTimeAttack = brain._currentTime
end

function o._CustomAiStates.amputeeAttack:OnRelease(brain)
	self.active = false
	local actor = brain._Objactor
	if actor._proc then
		GObjects:ToKill(actor._proc)
		actor._proc = nil
	end
end

function o._CustomAiStates.amputeeAttack:Evaluate(brain)
	if self.active then
		return 0.2
	end
	
	if math.random(100) < 5 then
    	local actor = brain._Objactor
    	local aiParams = actor.AiParams
		if not self._oneTime and brain.r_closestEnemy then
			actor:PlaySound("onAttackOnce")
			self._oneTime = true
		end

		if aiParams.aggresive or (not aiParams.aggresive and actor.Health ~= actor._HealthMax) then
			--	table.insert(self._goals, Clone(AiStates[state]))

			if brain._lastTimeAttack + aiParams.minDelayBetweenEncounterAndAttack < brain._currentTime and not brain._isLyingOnFloor then
				if brain._enemyLastSeenTime > 0 then
					return 0.2
				end
			end
		end
	end
	return 0.0
end

function Amputee:barf()
	self._barffx = self:BindFX("barf")
end

function Amputee:barfend()
	if self._barffx then
		PARTICLE.Die(self._barffx)
		self._barffx = nil
	end
end

function Amputee:OnStartAnim()
	self:barfend()
end
