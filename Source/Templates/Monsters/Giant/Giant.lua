function Giant:OnPrecache()
	Cache:PrecacheParticleFX("tornado3_1")
	Cache:PrecacheParticleFX("tornado3")
	Cache:PrecacheParticleFX("tornado2")
	Cache:PrecacheParticleFX("tornado1")
	Cache:PrecacheSounds("impacts/silos-explode")
	Cache:PrecacheItem("GiantChain.CItem")
	Cache:PrecacheItem("GStone.CItem")
	Cache:PrecacheItem(self.spitParticle)
	Cache:PrecacheActor("Zombie_Soldier_MStar_forGiant.CActor")
	Cache:PrecacheSounds("actor/giant/tornado")
end

function Giant:OnCreateEntity()
	Game.MegaBossHealthMax = self.Health
	Game.MegaBossHealth = self.Health	
	self._lastDamageStep = -100
	
	ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.OnlyWithFixedSpecial)

--	if debugMarek then
--	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)	-- todo: grupa tylko z playerbody i body
--	end
--	ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)
	
    MDL.SetMeshLighting(self._Entity,"transp_tornado",false)
    MDL.SetMeshLighting(self._Entity,"transp_tornado1",false)
	for i,v in self.s_SubClass.zasysa do
		MDL.SetMeshVisibility(self._Entity, v, false)		-- narazie 
	end
end

function Giant:CustomOnDeathUpdate()
	if self._timerToDemon then
		self._timerToDemon = self._timerToDemon - 1
		if self._timerToDemon <= 0 then
			self._demonfx = Game:EnableDemon(true, 12, false, 1.0)
			self._timerToDemon = nil
		end
	else
		if self._demonfx and self._demonfx.TickCount > self._demonfx.EffectTime - 1.0 then
			self._demonfx = nil
			GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		end
	end
end



function Giant:DestroyChain()
	--Game:Print("destroy chain")
	--Game.freezeUpdate = true
	MDL.SetMeshVisibility(self._Entity, "polySurfaceShape689", false)
	MDL.SetMeshVisibility(self._Entity, "polySurfaceShape688", false)
	local j = MDL.GetJointIndex(self._Entity, "op1")
	local x,y,z = self.Pos.X,self.Pos.Y,self.Pos.Z--MDL.GetJointPos(self._Entity, j)
	
	local q = Quaternion:New_FromEuler(0,-self.angle,0)	-- self.angle
	local obj,e = AddObject("GiantChain.CItem",nil,Vector:New(x,y,z),q,true) 
	Game._EarthQuakeProc:Add(self._groundx, self._groundy, self._groundz, 20, 250, 0.25, 0.25, 1.0)

	local pfx = self.s_SubClass.ParticlesDefinitions.chainbreak    
    local i = 1
    if pfx then
		while i <= 15 do
			local j = MDL.GetJointIndex(self._Entity, "op"..i)
			local x,y,z = MDL.GetJointPos(self._Entity, j)
			AddPFX(pfx.pfx, pfx.scale, Vector:New(x,y,z))
			
			local j = MDL.GetJointIndex(self._Entity, "ol"..i)
			local x,y,z = MDL.GetJointPos(self._Entity, j)
			AddPFX(pfx.pfx, pfx.scale, Vector:New(x,y,z))
			i = i + 1
		end
	end
end


function Giant:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._goals = {self._CustomAiStates.idleGiant, self._CustomAiStates.strike,
		self._CustomAiStates.walkAndStrike, self._CustomAiStates.spawn, self._CustomAiStates.abreak, self._CustomAiStates.spikes }
end

-----------------
Giant._CustomAiStates = {}
Giant._CustomAiStates.idleGiant = {
	--lastTimeAmbientSound = 0,
	lastAmbient = -2,
	name = "idleGiant",
}

function Giant._CustomAiStates.idleGiant:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	--actor:Stop()
	self.delay = nil
	self.GuardStill = aiParams.GuardStill
	self.timeChangeStillToFalse = nil
	self.walked = false
	self._submode = "idle"
	--Game:Print("IDLE GIANT oninit")
	self._walkAfterRot = false
end

function Giant._CustomAiStates.idleGiant:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	local tabl = aiParams.actions
	if self.lastAmbient + 1.0 < brain._currentTime and not actor._isRotating then
		if debugMarek then Game:Print("losowanie check "..brain._currentTime) end
		self.lastAmbient = brain._currentTime
		local tabl = aiParams.actions
		self._submode = nil
		for i,v in tabl do
			if FRand(0.0, 1.0) < v[2] then
				self._submode = v[1]
				break
			end
		end

		if self._submode then
			if debugMarek then Game:Print("losowanie "..self._submode) end
			if self._submode == "idleAnim" and actor._isWalking then
				if debugMarek then Game:Print("losowanie idleAnim canceled bo walking") end
				return
			end
			brain._submode = self._submode
			return
		end
	end


	if not actor._isWalking and actor._state == "ANIMATING" then
		if self.timeChangeStillToFalse then
			self.timeChangeStillToFalse = nil
			self.GuardStill = false
		end
		return
	end
	
	if self.timeChangeStillToFalse then
		self.timeChangeStillToFalse =  self.timeChangeStillToFalse - 1
		if self.timeChangeStillToFalse < 0 then
			self.timeChangeStillToFalse = nil
			self.GuardStill = false
			--Game:Print("self.GuardStill END")
		end
	end

	local distToPlayer = Dist2D(actor._groundx, actor._groundz, Player._groundx, Player._groundz)
	if not actor._isWalking then
		if distToPlayer < 17 then
			self.delay = nil
			self.timeChangeStillToFalse = nil
			self.GuardStill = false
			--Game.freezeUpdate = true
			--Game:Print("gracz blisko "..distToPlayer)
		end
	end

	if not self.GuardStill then
		if not actor._isWalking and not actor._isRotating then
			if brain._currentTime < actor._lastCantMoveTime + 2/30  then
				--Game:Print("obstacle detected by idle goal")
				local ang = math.random(45,60)
				brain._walkStepLocal = brain._walkStepLocal * 0.65
				if brain._walkStepLocal < aiParams.walkStep*0.4 then
					brain._walkStepLocal = aiParams.walkStep*0.4
				end
				if math.random(100) < 50 then
					ang = -ang
				end
			else
				if self._walkAfterRot then
					self._walkAfterRot = false
					Game:Print("walk after rot")
					actor:WalkTo(FRand(-30, 30),actor._groundy,FRand(-30, 30))
				end

				if aiParams.stopAfterWalking and FRand(0.0, 1.0) <= aiParams.stopAfterWalking and self.walked then
					self.timeChangeStillToFalse = math.random(aiParams.stopAfterWalkingTime[1],aiParams.stopAfterWalkingTime[2])
					self.GuardStill = true
					self.walked = false
				else
					brain._walkStepLocal = brain._walkStepLocal * 1.1
					if brain._walkStepLocal > aiParams.walkStep then
						brain._walkStepLocal = aiParams.walkStep
					end

					local maxDist
					
					local movement = FRand(brain._walkStepLocal * 1.2, brain._walkStepLocal * 2)
					if distToPlayer < 17 then
						movement = FRand(50, 70)
					end
					
					
					--[[local ang = math.random(-30,30)

					local b = actor:Trace(movement + actor._SphereSize, ang)
					if b then
						ang = math.random(45,60)
						local b = actor:Trace(movement, ang)
						if b then
							ang = -ang
						end
					end--]]

					local xd,yd,zd = actor._groundx,actor._groundy,actor._groundz
					local angle = actor._angleDest				-- czy angle
					angle = angle + FRand(-0.1,0.1)
					local v = Vector:New(math.sin(angle), 0, math.cos(angle))
					v:Normalize()
					--local xd2 = xd + v.X*(movement + actor._SphereSize * 3)
					--local zd2 = zd + v.Z*(movement + actor._SphereSize * 3)
					xd = xd + v.X*movement
					zd = zd + v.Z*movement
					
					 Game:Print("movement = "..movement)
					
					local d = Dist2D(xd, zd, 0,0)
					if d < 100 then
						actor:WalkTo(xd, yd, zd, false, maxDist)
					else
						local v = Vector:New(-actor._groundx, 0, -actor._groundz)
						v:Normalize()
						local angleToZero = math.atan2(v.X, v.Z)
						local dist = AngDist(actor.angle, angleToZero) * 180/math.pi
						if debugMarek then Game:Print("DIST "..dist) end
						if math.abs(dist) > 45 then
							if debugMarek then Game:Print("scianaa "..d.." "..movement) end
							actor:RotateToVectorWithAnim(FRand(-30, 30),actor._groundy,FRand(-30, 30))
							self._walkAfterRot = true
						else
							actor:WalkTo(FRand(-30, 30),actor._groundy,FRand(-30, 30))
						end
					end

					self.walked = true
				end
			end
		end
	else
		if not actor._isRotating and not actor._isWalking then
			if self.delay then
				self.delay = self.delay - 1
				if self.delay <= 0 then
					self.delay = nil
				end
			end
		end
	end
end

function Giant._CustomAiStates.idleGiant:OnRelease(brain)
	local actor = brain._Objactor
end

function Giant._CustomAiStates.idleGiant:Evaluate(brain)
	return 0.01
end


------------
Giant._CustomAiStates.idleAnim = {
	name = "idleAnim",
	active = false,
}

function Giant._CustomAiStates.idleAnim:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.done = false
	self.active = true
	actor:Stop()
	actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
	--actor._angleDest = math.mod(actor._angleDest - math.random(-30,30) * math.pi/180, math.pi*2)		-- tweak
end

function Giant._CustomAiStates.idleAnim:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isRotating and not self.done then
		if actor.s_SubClass.Ambients then
			self.animName = actor.s_SubClass.Ambients[math.random(2,table.getn(actor.s_SubClass.Ambients))]
			if actor:SetAnim(self.animName, false) then
				actor._state = "ANIMATING"
			end
		end
		self.done = 1
	end
	if (not actor._isAnimating or actor.Animation ~= self.animName) and self.done then
		self.active = nil
	end
end

function Giant._CustomAiStates.idleAnim:OnRelease(brain)
	self.active = nil
end

function Giant._CustomAiStates.idleAnim:Evaluate(brain)
	if self.active or brain._submode == "idleAnim" then
		return 0.3
	end
	return 0
end


--------------------------
Giant._CustomAiStates.walkAndStrike = {
	active = false,
	name = "walkAndStrike",
	_lastHitByEnemyTime = -100,
	delayBetweenReactionsOnHit = 10,
}

function Giant._CustomAiStates.walkAndStrike:OnInit(brain)
	local actor = brain._Objactor
	self.distanceToPlayerStd = 72							--- odleglosc od lay do bossa
	local dist = Dist2D(Player._groundx,Player._groundz, actor._groundx, actor._groundz)
	local distToPlayer = Dist2D(0, 0, Player._groundx, Player._groundz)
	local hit = false
	if brain._submode ~= "walkToPlayerAndStrike" then		-- dostal rane
		if debugMarek then Game:Print("walk and strike dist = "..dist.." player dist to 0 "..distToPlayer) end
		
		if dist > self.distanceToPlayerStd * 0.85 and dist < self.distanceToPlayerStd * 1.15 then
			if debugMarek then Game:Print("walk and strike dist OK") end
			actor:RotateToVectorWithAnim(Player._groundx, Player._groundy,Player._groundz)
			if math.random(100) < 50 then
				Game:Print("spawn od razu odl. dobra")
				brain._submode = "spawn"
			else
				Game:Print("walk&str od razu odl. dobra")
				brain._submode = "strike"
			end
			return
		end
		if dist > 110 then
			if math.random(100) < 50 then
				brain._submode = "spikes"
				if debugMarek then Game:Print("v.long attack spikes") end
				return
			end
		end
		hit = true
	end

	if actor._isWalking then
		actor:Stop()
		if actor:GetAngleDistToPlayer() > 50 then
			actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
		end
	else
		actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
	end
	
	brain._submode = nil
	self.mode = 0
	if dist > self.distanceToPlayerStd * 1.1 then
		-- pozniej nie do koncoa w to miejcs
		if debugMarek then Game:Print("walk and strike dist = "..dist.." dist to player "..distToPlayer) end

	else
		if debugMarek then Game:Print("walkandstrike oninit close, przechodzi przez gracza "..dist.." "..distToPlayer) end
		--self._doNotLoopWalkAnim = true
		self._doNotLoopWalkAnim = false
		local distGiant = Dist2D(0, 0, actor._groundx, actor._groundz)
		if distToPlayer > 120 and (hit or distGiant < distToPlayer) then
			if debugMarek then Game:Print("walkandstrike oninit close, nie przechodzi przez gracza "..dist.." bo on przy scianie jest "..distToPlayer) end
			brain._submode = "spikes"
			return
		end
		if math.random(100) < 50 then
			if debugMarek then Game:Print("walkandstrike oninit close, nie przechodzi przez gracza, INNY ATAK "..dist) end
			if math.random(100) < 40 then
				brain._submode = "spikes"
			else
				brain._submode = "spawn"
			end
			return
		end
		self.mode = 3
	end
	self.active = true
end

function Giant._CustomAiStates.walkAndStrike:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 then
		if not actor._isRotating then
			local dist = Dist2D(Player._groundx,Player._groundz, actor._groundx, actor._groundz)
			actor:WalkTo(Player._groundx, Player._groundy,Player._groundz,nil, dist - 15)
			self.mode = 1
		end
	end
	if self.mode == 1 then
		if actor._isWalking then
			local d = Dist2D(actor._groundx, actor._groundz, 0,0)
			local dist = Dist2D(Player._groundx, Player._groundz, actor._groundx, actor._groundz)
			if dist > self.distanceToPlayerStd * 0.85 and		-- pozniej dokladniej
				 dist < self.distanceToPlayerStd * 1.15 then
				if debugMarek then Game:Print("1: dystans do ciosu "..dist) end
				actor:FullStop()
				brain._submode = "strike"
				self.active = nil
			end
			if d > 100 then
				local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
				v:Normalize()
				local dist2 = Dist2D(0, 0, actor._groundx+v.X, actor._groundz+v.Z)
				--if debugMarek then Game:Print("za daleko? "..d.." "..dist2) end
				if dist2 > d then
					actor:Stop()
					if debugMarek then Game:Print("1: za daleko wyszedl") end
					actor:RotateToVectorWithAnim(FRand(-40,40), 0, FRand(-40,40))
					self.active = false
				end
			end
		else
			Game:Print("1: animacja rozglada")
			actor:SetAnim("idle2", false)
			self.mode = 2
		end
	end
	if self.mode == 2 then	
		if not actor._isAnimating or actor.Animation ~= "idle2" then
			local dist = Dist2D(Player._groundx, Player._groundz, actor._groundx, actor._groundz)
			if dist > self.distanceToPlayerStd * 0.85 and		-- pozniej dokladniej
				 dist < self.distanceToPlayerStd * 1.15 then
				brain._submode = "strike"
				if debugMarek then Game:Print("2: dystans do ciosu after "..dist) end
			else
				if debugMarek then Game:Print("2: nie ma dyst do ciosu "..dist) end
				if dist > 100 then
					if math.random(100) < 60 then
						brain._submode = "spikes"
					end
				end
			end
			self.active = nil
		end
	end
	---
	if self.mode == 3 and not actor._isRotating then
		local angle = actor.angle
		local v = Vector:New(math.sin(angle), 0, math.cos(angle))
		v:Normalize()
		local dis = FRand(50,70)
		v:MulByFloat(dis)
		local d = Dist2D(v.X+actor._groundx, v.Z+actor._groundz, 0,0)
		if d < 100 then
			Game:Print("walkforward "..dis.." "..d)
			actor:WalkTo(v.X+actor._groundx, actor._groundy, v.Z+actor._groundz)
		else
			actor:WalkTo(FRand(-30,30),actor._groundy, FRand(-30,30))
			Game:Print("cant walkforward - wyjdzie poza "..d)
		end
		self.mode = 4
	end
	if self.mode == 4 and not actor._isWalking then
		Game:Print("walkforward - END <<")
		self.active = nil
	end
	self._lastHitByEnemyTime = brain._currentTime
end

function Giant._CustomAiStates.walkAndStrike:OnRelease(brain)
	if debugMarek then Game:Print("walk and strike end") end
	self.active = nil
end

function Giant._CustomAiStates.walkAndStrike:Evaluate(brain)
	if brain._lastHitByEnemyPos then
		brain._lastHitByEnemyPos = nil
		if not self.active and math.random(100) < 70 then
			local dist = Dist2D(0, 0, Player._groundx, Player._groundz)
			if self._lastHitByEnemyTime + self.delayBetweenReactionsOnHit < brain._currentTime and dist < 130 then
                local actor = brain._Objactor
				local distToPlayer = Dist2D(actor._groundx, actor._groundz, Player._groundx, Player._groundz)
				if distToPlayer < 65 then
					self._lastHitByEnemyTime = self._lastHitByEnemyTime + 1.0
					Game:Print("reaction on canceled, gracz za blisko")
					return 0
				end

				self._lastHitByEnemyTime = brain._currentTime
				if debugMarek then Game:Print("reaction on hit "..distToPlayer) end
				self.delayBetweenReactionsOnHit = math.random(brain._Objactor.AiParams.delayBeetweenAttack,brain._Objactor.AiParams.delayBeetweenAttack*2)	-- sec.
				return 0.25
			else
				self.delayBetweenReactionsOnHit = self.delayBetweenReactionsOnHit - 0.4
				if self.delayBetweenReactionsOnHit < 1.0 then
					self.delayBetweenReactionsOnHit = 1.0
				end
			end
		end
	end
	if self.active or brain._submode == "walkToPlayerAndStrike" then
		return 0.25
	end
	return 0
end


------------
Giant._CustomAiStates.spawn = {
	name = "spawn",
	active = false,
}

function Giant._CustomAiStates.spawn:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.active = true
	if debugMarek then Game:Print("spawn >>>>>") end
	actor._spawns = {}
	
	self.distanceToPlayerStd = 46							--- odleglosc od lapy do bossa
	local dist = Dist2D(Player._groundx, Player._groundz, actor._groundx, actor._groundz)
	self.active = true
	self.mode = -1	
	if dist > self.distanceToPlayerStd * 1.1 then
		-- pozniej nie do koncoa w to miejcs
		if debugMarek then Game:Print("spawn oninit walkto") end
		if not actor._isWalking then
			if debugMarek then Game:Print("spawn oninit r") end
			actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
		else
			actor:Stop()
			if actor:GetAngleDistToPlayer() > 50 then
				if debugMarek then Game:Print("spawn oninit walkto duzy kat") end
				actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
			else
				if debugMarek then Game:Print("spawn oninit walkto male kat") end
			end
		end
	else
		actor:Stop()
		local distToPlayer = Dist2D(0, 0, Player._groundx, Player._groundz)
		--if distToPlayer > 20 then
			--actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
			self.mode = 0
		--end
	end

end

function Giant._CustomAiStates.spawn:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == -1 then
		if not actor._isRotating and not actor._isWalking then
			self.mode = 0
			local dist = Dist2D(Player._groundx,Player._groundz, actor._groundx, actor._groundz)
			if dist > self.distanceToPlayerStd * 1.1 then
				actor:WalkTo(Player._groundx, Player._groundy,Player._groundz,nil,dist - self.distanceToPlayerStd*0.6)
			end
		end
	end
	if self.mode == 0 then
		if actor._isWalking then
			local d = Dist2D(actor._groundx, actor._groundz, 0,0)
			if d > 100 then			-- nie uwzglednia ze oddala sie od sciany
				local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
				v:Normalize()
				local dist2 = Dist2D(0, 0, actor._groundx+v.X, actor._groundz+v.Z)
				--if debugMarek then Game:Print("za daleko? "..d.." "..dist2) end
				if dist2 > d then
					actor:FullStop()
					if debugMarek then Game:Print("1: za daleko wyszedl ###") end		-- to poprawic
				end
			end
			local dist = Dist2D(Player._groundx, Player._groundz, actor._groundx, actor._groundz)
			if dist > self.distanceToPlayerStd * 0.85 and		-- pozniej dokladniej
				 dist < self.distanceToPlayerStd * 1.15 then
				if debugMarek then Game:Print("1: dystans ok "..dist) end
				actor:FullStop()
			end
		else
			if debugMarek then Game:Print("1: spawn") end
			if not actor._isRotating then
				actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
				self.mode = 1
			end
		end
	end

	if self.mode == 1 and not actor._isRotating then
		self.mode = 2
		actor:SetAnim("atak1", false)
	end
	
	if self.mode == 2 then
		if not actor._isAnimating or actor.Animation ~= "atak1" then
			self.active = nil
			if debugMarek then Game:Print(" -koniec spawn-- "..actor.Animation) end
		end
	end

end

function Giant._CustomAiStates.spawn:OnRelease(brain)
	local actor = brain._Objactor
	self.active = nil
	Game:Print("koniec spawn")
	for i,v in actor._spawns do
		GObjects:ToKill(v)
	end
end

function Giant._CustomAiStates.spawn:Evaluate(brain)
	if self.active then
		return 0.3
	end
	if not brain._ABdone and brain._submode == "spawn" and not brain._Objactor._isRotating then
		return 0.3
	end
	return 0
end

------------
Giant._CustomAiStates.strike = {
	name = "strike",
	active = false,
	lastTimeDamage = -100,
}

function Giant._CustomAiStates.strike:OnInit(brain)
	local actor = brain._Objactor
	
	self.active = true
	brain._submode = nil
	if debugMarek then Game:Print("strike oninit: "..(Dist3D(Player._groundx,0,Player._groundz, actor._groundx,0, actor._groundz))) end
	-- obrot do playera ###
	actor:Stop()
	if not actor._isRotating then
		actor:RotateToVectorWithAnim(Player._groundx,0,Player._groundz)
	end
	actor._angleDest = math.mod(actor._angleDest + 30 * math.pi/180, math.pi*2)		-- tweak, 
	--
	self.oldPos1 = Vector:New(0,0,0)
	self.oldPos2 = Vector:New(0,0,0)
	self.mode = 0
end

function Giant._CustomAiStates.strike:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 and not actor._isRotating then
		actor:SetAnim("atak2",false)
		self.mode = 1
	else
		if not actor._isAnimating or actor.Animation ~= "atak2" then
			self.active = false
			if debugMarek then Game:Print("koniec strike") end
		else
			local x,y,z = actor:GetJointPos('d_l_3_3')	-- jeszcze 4_3
			local vel1x, vel1y, vel1z = self.oldPos1.X - x, self.oldPos1.Y - y, self.oldPos1.Z - z
			self.oldPos1.X = x
			self.oldPos1.Y = y
			self.oldPos1.Z = z
			local dist = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.7, Player._groundz)

			x,y,z = actor:GetJointPos('d_l_1_3')
			local vel2x, vel2y, vel2z = self.oldPos2.X - x, self.oldPos2.Y - y, self.oldPos2.Z - z
			self.oldPos2.X = x
			self.oldPos2.Y = y
			self.oldPos2.Z = z
			local dist2 = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.7, Player._groundz)

			--Game:Print("dist to lapa = "..dist.." "..dist2)

			local aiParams = actor.AiParams		
			if (dist < aiParams.handRange or dist2 < aiParams.handRange) and self.lastTimeDamage + 0.6 < brain._currentTime then
				Game:Print(">>>>> machnal gracza!")
				self.lastTimeDamage = brain._currentTime
				Player:OnDamage(aiParams.damageHandHit, actor)
				PlaySound2D("actor/giant/giant_hand-hit")
				local v 
				if dist < 5 then
					v = Vector:New(vel1x,0,vel1z)
				else
					v = Vector:New(vel2x,0,vel2z)
				end
				v:Normalize()
				local forceX = -aiParams.strikeForceXZ
				local forceY = aiParams.strikeForceY
				ENTITY.PO_SetPlayerFlying(Player._Entity, 0.5)
				ENTITY.SetVelocity(Player._Entity, v.X*forceX, forceY, v.Z*forceX)
			end
		end
	end
end


function Giant._CustomAiStates.strike:OnRelease(brain)
	if debugMarek then Game:Print("strike on release") end
end

function Giant._CustomAiStates.strike:Evaluate(brain)
	if self.active then
		return 0.3
	end
	if not brain._ABdone and brain._submode == "strike" then
		return 0.3
	end
	return 0
end

------------
Giant._CustomAiStates.spikes = {
	name = "spikes",
	active = false,
}

function Giant._CustomAiStates.spikes:OnInit(brain)
	local actor = brain._Objactor
	actor:Stop()
	local distToPlayer = Dist2D(0, 0, Player._groundx, Player._groundz)
	if distToPlayer > 17 then
		actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
	end
	self.active = true
	brain._submode = nil
	self.mode = 0
	if debugMarek then Game:Print("spikes start") end
end

function Giant._CustomAiStates.spikes:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 and not actor._isRotating then
		self.mode = 1
		actor:SetAnim("kolce",false)		
	end
	if self.mode == 1 then
		if not actor._isAnimating or actor.Animation ~= "kolce" then
			self.active = false
		end
	end
end

function Giant._CustomAiStates.spikes:OnRelease(brain)
	Game:Print("spikes end")
end

function Giant._CustomAiStates.spikes:Evaluate(brain)
	if self.active then
		return 0.3
	end
	if brain._submode == "spikes" then
		return 0.3
	end
	--[[if math.random(100) < 10 then
		local actor = brain._Objactor
		local dist = Dist2D(actor._groundx, actor._groundz, Player._groundx, Player._groundz)
		if dist < 16 then
			if math.random(100) < 90 then
				-- idzie daleko
				Game.freezeUpdate = true
				
			else
				if debugMarek then Game:Print("##### spikes pod giantem") end
				return 0.1
			end
		end
	end--]]
	return 0
end


------------
Giant._CustomAiStates.sucking = {
	name = "sucking",
	active = false,
    _lastHitByEnemyTime = -100,
	delayBetweenReactionsOnHit = 6,
}

function Giant._CustomAiStates.sucking:OnInit(brain)
	local actor = brain._Objactor

	if actor.s_SubClass.rotateHead > 0 then
		actor._disableRotateHead = true
		actor._angleAttackX = 0
		actor._angleAttackY = 0
		MDL.SetHeadTrackRot(actor._Entity, 0, 0, 0)
	end

	actor:Stop()
	actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
	actor:SetAnim("dmucha",false)
	self.mode = -2
	self.meteorCount = 0
	actor._shakeCam = nil
end

function Giant._CustomAiStates.sucking:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == -2 then
		if not actor._isRotating then
			self.mode = -1
		end
	end
	if self.mode == -1 then
		if not actor._isAnimating or actor.Animation ~= "dmucha" then
			actor:SetAnim("zasysa",false)

			actor._soundSampleTornado = SOUND2D.Create("actor/giant/tornado")
			SOUND2D.DisableRandomize(actor._soundSampleTornado)
			SOUND2D.Play(actor._soundSampleTornado)

			self.active = true
			brain._submode = nil
			self.mode = 0
			-------------------
			for i,v in actor.s_SubClass.zasysa do
				MDL.SetMeshVisibility(actor._Entity, v, true)		-- narazie 
			end
			actor:BindFX("tornado3_1",0.5,'t1')
			actor:BindFX("tornado3_1",0.7,'t2')
			actor:BindFX("tornado3_1",1.3,'t3')
			actor:BindFX("tornado3_1",1.5,'t4')
			actor:BindFX("tornado3_1",1.6,'t5')
			actor:BindFX("tornado3",1.0,'t6')
			actor:BindFX("tornado3",1.1,'t7')
			actor:BindFX("tornado3",1.2,'t8')
			actor:BindFX("tornado3",1.4,'t9')
			actor:BindFX("tornado3",1.5,'t10')
			actor:BindFX("tornado3",1.6,'t11')
			actor:BindFX("tornado3",1.7,'t12')
			actor:BindFX("tornado3",1.8,'t13')

			actor:BindFX("tornado2",4,'t_r18_1')
			actor:BindFX("tornado2",4,'t_r18_2')
			actor:BindFX("tornado2",4,'t_r18_3')
			actor:BindFX("tornado2",4,'t_r18_4')

			actor:BindFX("tornado1",4,'t_r19_1')
			actor:BindFX("tornado1",4,'t_r19_2')
			actor:BindFX("tornado1",4,'t_r19_3')
			actor:BindFX("tornado1",4,'t_r19_4')
		end
	end
	if self.mode == 0 then
		if not actor._isAnimating or actor.Animation ~= "zasysa" then
			self.mode = 1
			actor._shakeCam = nil
			if debugMarek then Game:Print("KONIEC zasysania "..actor.Animation) end
			ENTITY.UnregisterAllChildren(actor._Entity, ETypes.ParticleFX)

			for i,v in actor.s_SubClass.zasysa do
				MDL.SetMeshVisibility(actor._Entity, v, false)		-- narazie 
			end
			SOUND2D.SetVolume(actor._soundSampleTornado, 0, 1.0)
			SOUND2D.Forget(actor._soundSampleTornado)
            actor._soundSampleTornado = nil
			CAM.SetPositionDisplacement(0,0,0)
			CAM.SetRotationDisplacement(0,0,0)
			actor:SetAnim("dmucha_up",false)
			actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
		else
			actor:TornadoUpdate()
			if math.random(100) < 9 then
				actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
			end
		end
	end
	if self.mode == 1 then
		if not actor._isAnimating or actor.Animation ~= "dmucha_up" then
			self.mode = 2
			--Game:Print("delay")
			actor:SetAnim("idle1",true)
			self.delay = FRand(60,70)
		else
			if FRand(0.0, 1.0) < actor.throwFreq and actor._CurAnimTime > 1.4 and actor._CurAnimTime < 2.2 and self.meteorCount < 10 then
			    local j = MDL.GetJointIndex(actor._Entity, "k_szczeka")
			    local x,y,z = MDL.TransformPointByJoint(actor._Entity, j,0,1,4)
				--local x,y,z = actor:GetJointPos("k_szczeka")
				local obj = actor.throwObjs[math.random(1, table.getn(actor.throwObjs))]
				local crap = GObjects:Add(TempObjName(),CloneTemplate(obj))
				crap.Pos.X = x
				crap.Pos.Y = y
				crap.Pos.Z = z
				crap.Rot:FromEuler( FRand(0, 3.14), FRand(0, 3.14), FRand(0, 3.14))
				crap.Scale = crap.Scale * FRand(0.7, 1.0)
				crap.ObjOwner = actor

				crap:Apply()
				--local v = Vector:New(Player._groundx - x, Player._groundy+FRand(1.5,1.8) - y, Player._groundz - z)
				--v:Normalize()
				--local dist = Dist3D(Player._groundx,0, Player._groundz, actor._groundx,0,actor._groundz)
				local speed = actor.spitSpeed * FRand(0.9, 1.1)

				local q = Quaternion:New_FromNormal(0, 1, 0)
				if actor.spitParticle then
					AddPFX(actor.spitParticle, 0.3, Vector:New(x,y,z), q)
				end

				ENTITY.SetAngularVelocity(crap._Entity, FRand(0, 30), FRand(0, 30), FRand(0, 30))
				--ENTITY.EnableCollisions(crap._Entity, true, 0.3, 4, 0.3)
				ENTITY.PO_EnableGravity(crap._Entity, false)
				ENTITY.SetVelocity(crap._Entity,  speed*FRand(-0.2, 0.2), speed, speed*FRand(-0.2, 0.2))
				actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
				self.meteorCount = self.meteorCount + 1
			end
		end
	end
	if self.mode == 2 then
		if self.delay then
			self.delay = self.delay - 1
			if self.delay < 0 then
				self.delay = nil
			end
		else
			self.active = nil
		end
	end
end

function Giant._CustomAiStates.sucking:OnRelease(brain)
	local actor = brain._Objactor
	--Game:Print("koniec dmuchania")
	actor._disableRotateHead = nil
	ENTITY.UnregisterAllChildren(actor._Entity, ETypes.ParticleFX)
	for i,v in actor.s_SubClass.zasysa do
		MDL.SetMeshVisibility(actor._Entity, v, false)		-- narazie 
	end
    CAM.SetPositionDisplacement(0,0,0)
    CAM.SetRotationDisplacement(0,0,0)
end

function Giant._CustomAiStates.sucking:Evaluate(brain)
	if self.active then
		return 0.3
	else
		--[[local actor = brain._Objactor
		if brain._lastHitByEnemyPos then
			brain._lastHitByEnemyPos = nil
			--Game:Print("....reaction on hit?")
			if self._lastHitByEnemyTime + self.delayBetweenReactionsOnHit < brain._currentTime then
				self._lastHitByEnemyTime = brain._currentTime
				if debugMarek then Game:Print("....reaction on hit2") end
				self.delayBetweenReactionsOnHit = math.random(brain._Objactor.AiParams.delayBeetweenAttack,brain._Objactor.AiParams.delayBeetweenAttack*2)	-- sec.
				actor:Stop()
				if not actor._isRotating then
					if debugMarek then Game:Print("....reaction on hit2 rot") end
					actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
				end
				return 0.0
			else
				self.delayBetweenReactionsOnHit = self.delayBetweenReactionsOnHit - 0.4
				if self.delayBetweenReactionsOnHit < 1.0 then
					self.delayBetweenReactionsOnHit = 1.0
				end
			end
		end--]]

	end
	if brain._submode == "sucking" then
		return 0.3
	end
	return 0
end


------------
Giant._CustomAiStates.abreak = {
	name = "abreak",
	active = false,
}

function Giant._CustomAiStates.abreak:OnInit(brain)
	local actor = brain._Objactor
	brain._ABdone = true
	actor:Stop()
	if debugMarek then Game:Print("Giant AB") end
	brain._submode = nil
	actor:SetAnim("zrywa_lancuch",false)
	self.active = true
end

function Giant._CustomAiStates.abreak:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isAnimating or actor.Animation ~= "zrywa_lancuch" then
		self.active = false
	end
end

function Giant._CustomAiStates.abreak:OnRelease(brain)
    local actor = brain._Objactor
    local aiParams = actor.AiParams
    aiParams.actions = aiParams.actionsAB
    -- ciekawe, czy to zadziala...:
    actor._AIBrain._goals = {actor._CustomAiStates.idleGiant, actor._CustomAiStates.sucking, actor._CustomAiStates.spikes}
end

function Giant._CustomAiStates.abreak:Evaluate(brain)
	local actor = brain._Objactor
	if actor._HealthMax * actor.ABHp > actor.Health and not brain._ABdone and not brain._submode and not actor._isRotating then
		return 0.2
	end
	if self.active then
		return 0.5
	end
	return 0
end

-----------------

function Giant:CustomUpdate()
	Game.MegaBossHealth = self.Health
	if self.AIenabled then
        local aiParams = self.AiParams
		local x,y,z = self:GetJointPos('s_p_kostka')
		local dist = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.7, Player._groundz)
		if dist < aiParams.touchFeetRange and self._lastDamageStep + 0.8 < self._AIBrain._currentTime then
			self._lastDamageStep = self._AIBrain._currentTime
			--Game:Print("dotknal gracza p ")
			Player:OnDamage(self.AiParams.touchFeetDamage, self)			-- pozniej min delay dodac
		end
		
		x,y,z = self:GetJointPos('s_l_kostka')
		dist = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.7, Player._groundz)
		if dist < aiParams.touchFeetRange and self._lastDamageStep + 0.8 < self._AIBrain._currentTime then
			self._lastDamageStep = self._AIBrain._currentTime
			--Game:Print("dotknal w gracza l ")
			Player:OnDamage(self.AiParams.touchFeetDamage, self)
		end
	else
		if self.Health <= 0 then
			self:CustomOnDeathUpdate()
			if  not self._disableUpdate then
				if not self._isAnimating or self.Animation ~= "zamiera" then
					Game:Print("koniec animacji zamiera "..self.Animation)
					--AddItem(,nil,Vector:New(self.Pos.X,self.Pos.Y,self.Pos.Z))
					Game.BodyCountTotal = Game.BodyCountTotal + 1
					
					--GObjects:ToKill(self)
					ENTITY.EnableDraw(self._Entity, false)
					
					self._disableUpdate = true
					
					Game.MegaBossHealth = nil
					Game.MegaBossHealthMax = nil

					local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
					v:Normalize()
					local m = 29
					ENTITY.SetPosition(self._Entity,self.Pos.X + v.X*m,self.Pos.Y,self.Pos.Z + v.Z*m)
					ENTITY.EnableDraw(self._Entity, false)

					--AddItem("EndOfLevel.CItem",nil,Vector:New(4,-64, 0), true)		-- pozniej tylko gdy zombiaki nie zyja
					-- Game.freezeUpdate = true

					SOUND.Play2D("impacts/silos-explode")
					ENTITY.PO_Enable(self._Entity, false)
					ENTITY.ExplodeItem(self._Entity, "../Data/Items/"..self.deathExplosionItem, self.deathExplosionStren, self.deathExplosionRadius, 30.0, self.deathExplosionItemScale, nil, false)

					Game._EarthQuakeProc:Add(self.Pos.X,self.Pos.Y,self.Pos.Z, 60, 400, 0.23, 0.23, 1.0)	
					
					local parts = WORLD.GetLastExplodedEntities(self._Entity)
					for i,o in parts do
						ENTITY.EnableCollisions(o, true, 1.5, 4.0)
					end
				end
			end
		end
	end

end


function Giant:CreateSpike()
	local x = Player._groundx + FRand(-0.1, 0.1) + Player._velocityx * self._spikePrecictPlayerVelocity
	local y = Player._groundy + 1
	local z = Player._groundz + FRand(-0.1, 0.1) + Player._velocityz * self._spikePrecictPlayerVelocity
	local b,d,x2,y2,z2 = WORLD.LineTraceFixedGeom(x, y, z, x, y - 10, z)
	if d then
	
		local b,d,x3,y3,z3 = WORLD.LineTraceFixedGeom(x2, y2 - 10, z2, x2, y2 - 0.1, z2)
		if d then
			x2 = x3
			y2 = y3
			z2 = z3
		end
		
		local obj = GObjects:Add(TempObjName(),CloneTemplate("GiantStake.CItem"))	
		obj.Pos.X = x2
		obj.Pos.Y = y2 + obj.initialPosY
		obj.Pos.Z = z2
		--obj.Rot:FromEuler( math.pi/2, 0, 0)
		obj:Apply()
		obj.ObjOwner = self
		AddObject("FX_sground.CActor", 1.0, Vector:New(x2,y2,z2), nil, true)
		Game._EarthQuakeProc:Add(obj.Pos.X,obj.Pos.Y,obj.Pos.Z, 15, 20, 0.12, 0.12, 1.0)
		--table.insert(DEBUGtraces, {obj.Pos.X,obj.Pos.Y+4,obj.Pos.Z,obj.Pos.X, obj.Pos.Y, obj.Pos.Z})
	end
end

---------------
function Giant:Spawn()
	local aiParams = self.AiParams

	--Game.freezeUpdate = true

	local count = math.random(aiParams.spawnCount[1], aiParams.spawnCount[2])
	
	local x2,y2,z2 = self:GetJointPos("d_p_1_3")
	dist = Dist2D(x2,z2, Player._groundx, Player._groundz)
	--Game:Print(">>> ?create zombis "..dist)

	if dist < aiParams.handRange then
		if debugMarek then Game:Print("BEZPOSREDNI hit piescia") end
		Player:OnDamage(self.AiParams.damageFist, self)
	end

	local cnt = table.getn(Actors)
	if cnt >= aiParams.MaxActorsOnLevel then
		--Game:Print("too many actors"..count)
		return
	end

	if cnt + count > aiParams.MaxActorsOnLevel then
		count = aiParams.MaxActorsOnLevel - cnt
		--Game:Print("new actors reduced to "..count)
	end

	if debugMarek then Game:Print(">>> !create zombis "..count) end
	--Game.freezeUpdate = true
	local xpos,ypos,zpos = self:GetJointPos("dlo_prawa_root")
	for i=1,count do
   		local angle = math.random(0,360)
		local x = math.sin(angle) + math.cos(angle)
		local z = math.cos(angle) - math.sin(angle)
		local d = FRand(6,16)
		x = xpos + x * d
		y = ypos
		z = zpos + z * d
		local d = Dist2D(x, z, 0,0)
		if d < 115 then

			local b,d,x2,y2,z2 = WORLD.LineTraceFixedGeom(x, y + 4, z, x, y - 10, z)
			local b2,d2,x3,y3,z3 = WORLD.LineTraceFixedGeom(x + 1, y + 4, z, x + 1, y - 10, z)
			if d then
				local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.spawn))
				obj.shadow = 0			-- na enclave i tak nie ma lightmap
				if d2 and y3 < y2 then
					obj.Pos.X = x3
					obj.Pos.Y = y3 + 2
					obj.Pos.Z = z3
				else
					obj.Pos.X = x2
					obj.Pos.Y = y2 + 2
					obj.Pos.Z = z2
				end
				--table.insert(DEBUGtraces, {obj.Pos.X,obj.Pos.Y+4,obj.Pos.Z,obj.Pos.X, obj.Pos.Y, obj.Pos.Z})
				--obj.StartDelay = FRand(aiParams.spawnDelay[1], aiParams.spawnDelay[2])
				obj:Apply()
				obj:Spawn()
				--Game:Print("CREATE zobmbie s")
				--obj._Launched = true
			end
			table.insert(self._spawns, obj)
		else
			Game:Print("CREATE zobmbie failed > 115")
		end
	end
end

function Giant:Stomp(joint, modif)
	local p = modif
	if not p then
		p = 1.0
	end
	local x,y,z = self:GetJointPos(joint)
	Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange * p, self.CameraMov * p, self.CameraRot * p, 1.0)
	if debugMarek then
		DebugSphereX = x
		DebugSphereY = y - 2
		DebugSphereZ = z
		DebugSphereRange = self.AiParams.explosionWhenWalkRange
	end
	WORLD.Explosion2(x,y - 2,z, self.AiParams.explosionWhenWalkStreng, self.AiParams.explosionWhenWalkRange, nil, AttackTypes.Step, self.AiParams.explosionWhenWalkDamage)		-- damege na zero?
    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
    AddPFX('but',1.2,Vector:New(x,y,z))
end


function Giant:OnDamage(damage, obj, type, x, y, z, nx, ny, nz, he )			-- +pos
	if type == AttackTypes.Demon or self._frozen or type == AttackTypes.OutOfLevel then
         return false
    end

	if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        local jName = MDL.GetJointName(e,j)
        if jName == "n_p_kolano" or jName == "n_l_kolano" then		-- bo ma metalowe
			damage = damage * 0.33
		end
	end

	if self.AIenabled and self.Health > 0 then
		if type == AttackTypes.Step then
			return true
		end

		if obj then
			self._AIBrain._lastHitByEnemyPos = obj.Pos
		end
        --ENTITY.PO_SetFlying(self._Entity,false)

		self.Health =  self.Health - damage
		if self._AIBrain and self.AIenabled then
			self._AIBrain._lastDamageTime = self._AIBrain._currentTime
			self._AIBrain.r_lastDamageWho = obj
		end
		if self.Health <= 0 then
			self.AIenabled = false
			self.Health = 0
			if self._tornado then
				GObjects:ToKill(self._tornado)
				self._tornado = nil
			end

			ENTITY.RemoveRagdoll(self._Entity)
			self:RotateToVector(0,0,0)
			self:SetAnim("zamiera", false)
			for i,v in self.s_SubClass.zasysa do
				MDL.SetMeshVisibility(self._Entity, v, false)		-- narazie 
			end
			ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
			CAM.SetPositionDisplacement(0,0,0)
			CAM.SetRotationDisplacement(0,0,0)
			if debugMarek then Game:Print("--- DEAD ---") end
			
			for i,v in self.s_SubClass.zasysa do
				MDL.SetMeshVisibility(self._Entity, v, false)		-- narazie 
			end
			self:StopLastSound()
			if self._soundSampleTornado then
				SOUND2D.SetVolume(self._soundSampleTornado, 0, 0.2)
				SOUND2D.Forget(self._soundSampleTornado)
				self._soundSampleTornado = nil
			end
			ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
			self._shakeCam = nil
		    self._disableDemonic = true
			self._timerToDemon = 4
			for i,v in Actors do
				if v.Health > 0 and v._AIBrain then
					v:OnDamage(9999,v,AttackTypes.Demon)
				end
			end

		end
	end
end


--[[function Giant:test()
	local x,y,z = self:GetJointPos('d_p_1_3')
	local dist = Dist3D(x,0,z, self._groundx, 0, self._groundz)
	Game:Print("dist to lapa: "..dist)		-- 54 dla d_p_1_3
end--]]

function Giant:OnTick(delta)
	--[[if self._isWalking then
		local d = Dist2D(self._groundx, self._groundz, 0,0)
		if d > 111 then
			Game:Print("GIANT POZA LEVELEM? "..d)
		end
	end--]]
	if self._shakeCam then
	    --CAM.SetPositionDisplacement(0,0,0)
	    --CAM.SetRotationDisplacement(0,0,0)
		if self._shakeCam == 0 then
			local x,y,z = CAM.GetAng() 
			x = x + FRand(-2, 2)
			y = y + FRand(-1, 1)
			CAM.SetAng(x,y,z)
		else
        	x,y,z = self:GetJointPos('t15')
            local dist = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.7, Player._groundz)
            x,y,z = self:GetJointPos('t12')
            local dist2 = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.7, Player._groundz)
            --Game:Print("dist = "..dist)
            
            if dist < self.tornadosuckDistance or dist2 < self.tornadosuckDistance --[[and self._lastDamageStep + 1.0 < self._AIBrain._currentTime--]] then
                local a = dist2
                if dist < dist2 then
                    a = dist
                end

                local x,y,z = CAM.GetAng() 
                local d = 10*(self.tornadosuckDistance - a)/self.tornadosuckDistance
                x = x + FRand(2+d, 6+d)
                y = y + FRand(-4-d, 4+d)
                CAM.SetAng(x,y,z)
                
                if FRand(0.0, 1.0) < delta * 2 then
		            Player:OnDamage(self.tornadoDamage, self)
		        end

           		if Player.Pos.Y < -50 and FRand(0.0, 1.0) < delta * 1.5 then
           			local mul = 4 * FRand(self.tornadosuckStrength[1], self.tornadosuckStrength[2]) + self.tornadosuckStrength[1] * 4
           			ENTITY.PO_SetPlayerFlying(e, 0.2)
           			local x,y,z = ENTITY.GetVelocity(Player._Entity)
					ENTITY.SetVelocity(Player._Entity, x+FRand(-5,5), mul, z+FRand(-5,5))
				end

            else
       			local x,y,z = CAM.GetAng() 
                x = x + FRand(-2, 2)
                y = y + FRand(-1, 1)
                CAM.SetAng(x,y,z)
            end
		end
	end
end

function Giant:TornadoUpdate()
	-- t15, t16, ..t13
	self._shakeCam = 0
    local b = WORLD.LineTraceFixedGeom(Player.Pos.X,Player.Pos.Y,Player.Pos.Z, Player.Pos.X,Player.Pos.Y + 4,Player.Pos.Z)
    if not b then
        self._shakeCam = 1
        --Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange * p, self.CameraMov * p, self.CameraRot * p, 1.0)
    end

end

function Giant:Strike(par1)
    local aiParams = self.AiParams			
    local x,y,z = self:GetJointPos(par1)
    local dist = Dist3D(x,y,z, Player._groundx, Player._groundy+ 1.8, Player._groundz)
    
    if dist < aiParams.handRange then
        --Game:Print(">BEZPOSREDNI hit "..dist)
        Player:OnDamage(aiParams.damageFist, self)
    --else
		--Game:Print("dist to handddd "..dist)
    end
end

function Giant:GetAngleDistToPlayer()
	local v = Vector:New(Player._groundx - self._groundx, 0, Player._groundz - self._groundz)
	v:Normalize()
	local angleToPlayer = math.atan2(v.X, v.Z)
	local dist = AngDist(self.angle, angleToPlayer) * 180/math.pi
	--Game:Print("distToP = "..dist)
	--Game.freezeUpdate = true
	return math.abs(dist)
end

function Giant:CustomDelete()
    if self._soundSampleTornado then
		SOUND2D.Delete(self._soundSampleTornado)
        self._soundSampleTornado = nil
    end
end
