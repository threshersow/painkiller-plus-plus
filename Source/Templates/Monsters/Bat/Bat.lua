function Bat:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._batfly = false
    self._AIBrain._landAfterAttack = false
end

function Bat:OnCreateEntity()
	ENTITY.PO_EnableGravity(self._Entity, false)
    self._flyWithAngle = true
end

function Bat:OnDeathUpdate()
	if not self._enabledRD then
		self:EnableRagdoll(true,true)
		ENTITY.PO_EnableGravity(self._Entity, true)
	else
		if self._deathTimer > 0 then
			self._deathTimer = self._deathTimer - 1
		else
			GObjects:ToKill(self)
		end
	end
end

function Bat:CustomUpdate()
	if self._activated then
		self._activated = self._activated - 1/30
		if self._activated < 0 then
			self._activated = nil
			GObjects:ToKill(self)
		end
	end
end


Bat._CustomAiStates = {}

--------------------------
Bat._CustomAiStates.Bathear = {
	name = "Bathear",
	active = false,
}

function Bat._CustomAiStates.Bathear:OnInit(brain)
	self.lastTimeHEAR = brain._currentTime
	brain._landAfterAttack = false
end

function Bat._CustomAiStates.Bathear:OnUpdate(brain)
	if self.lastTimeHEAR + 0.7 < brain._currentTime and table.getn(ActiveSounds) > 0 then
		local actor = brain._Objactor
		local aiParams = actor.AiParams
		local soundOfHiPrio = nil
		--if debugMarek then Game:Print(actor._Name.." Sound det : "..ActiveSounds[1][1]) end
		for i,v in ActiveSounds do
			--if i ~= "__mode" then
				local dist = Dist3D(v[4], v[5], v[6], actor._groundx, actor._groundy, actor._groundz)
				dist = dist / aiParams.hearing
				if dist < v[8] then
					local inRange = 1
					if dist > v[7] then
						local d = dist - v[7]
						d = d/(v[8] - v[7])
						if math.random(100) < d*100 then
							inRange = 0
						end
					end
					if inRange == 1 then
						if soundOfHiPrio then
							if soundOfHiPrio[2] < v[2] then
								soundOfHiPrio = v
							end
						else
							soundOfHiPrio = v
						end
					end
				end
			--end
		end
		if soundOfHiPrio then
			self.lastTimeFIRE = brain._currentTime
			--if debugMarek then Game:Print("Sound heard : "..soundOfHiPrio[1]) end
			actor:Stop()
			brain._batfly = true
			brain._batflySndSrc = Vector:New(soundOfHiPrio[4], soundOfHiPrio[5], soundOfHiPrio[6])
			--if not actor.DEBUG_SND then
			--	actor.DEBUG_SND = {}
			--end
			--table.insert(actor.DEBUG_SND, {brain._batflySndSrc.X, brain._batflySndSrc.Y, brain._batflySndSrc.Z})
		end
	end
end


function Bat._CustomAiStates.Bathear:Evaluate(brain)
	return 0.02
end


--------------------------
Bat._CustomAiStates.BatEscape = {
	name = "BatEscape",
	active = false,
}

function Bat._CustomAiStates.BatEscape:OnInit(brain)
	local actor = brain._Objactor

	local v = Vector:New(brain._batflySndSrc.Z - actor.Pos.Z, 0, actor.Pos.X - brain._batflySndSrc.X)
	v:Normalize()
	local displace = FRand(2.5,6)		-- left/right
	if math.random(100) < 50 then
		displace = -displace
	end
	local d = displace * FRand(0.5,1.0)
	local dxx = actor.Pos.X + v.X * d
	local dzz = actor.Pos.Z + v.Z * d

	local b,d2 = WORLD.LineTraceFixedGeom(dxx, actor.Pos.Y, dzz,	 dxx, actor.Pos.Y - d, dzz)
	if b then
		--Game:Print("nie mogl w dol!!")
		d = FRand(0, d2 * 0.33)
	end
	
	local dyy = actor.Pos.Y - math.abs(d)
	
--	DEBUG1 = actor.Pos.X DEBUG2 = actor.Pos.Y DEBUG3 = actor.Pos.Z
--	DEBUG4 = dxx DEBUG5 = dyy DEBUG6 = dzz
	
	actor:PlaySound("wings")
	PlayLogicSound("ANIMAL",actor.Pos.X, actor.Pos.Y, actor.Pos.Z,2,3,actor)

	actor:FlyTo(dxx, dyy, dzz, false)

	self._lastPosX = actor.Pos.X
	self._lastPosY = actor.Pos.Y
	self._lastPosZ = actor.Pos.Z
	self._fin = false
	self._up = 0
	self._timeOut = 30 * 60 * 2				-- po 2 minutach latania ginie
	self.checkTime = 0.99
	
	actor._activated = actor.AiParams.dieAfterActivationTime
end

function Bat._CustomAiStates.BatEscape:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	self._timeOut = self._timeOut - 1
	if self._timeOut < 0 then				-- narazie
		actor:OnDamage(actor.Health + 2, actor)
		return
	end
	
	if not actor._isWalking then
		if self._fin then
			actor:SetIdle()
			ENTITY.SetVelocity(actor._Entity,0,0,0)
			brain._batfly = false
		else
			--Game:Print("fly next")
			actor:FlyForward(FRand(4,8), math.random(-20,20), FRand(self._up, self._up+2))
			self._up = self._up + 1
			if self._up > 8 then
				self._up = 8
			end
		end
	else
		self.checkTime = self.checkTime + aiParams.collisionCheckSpeed
		if (self.checkTime > 1) and not self._fin then		--if (math.random(100) < aiParams.collisionCheckSpeed) and not self._fin then
			self.checkTime = self.checkTime - 1
			local v = Vector:New(self._lastPosX - actor.Pos.X, self._lastPosY - actor.Pos.Y, self._lastPosZ - actor.Pos.Z)
			--Game:Print("mag="..v.X*v.X+v.Y*v.Y+v.Z*v.Z)
			v:Normalize()
			local distCheck = 2.2
			 --DEBUG1 = actor.Pos.X DEBUG2 = actor.Pos.Y DEBUG3 = actor.Pos.Z
			 --DEBUG4 = actor.Pos.X-v.X*distCheck DEBUG5 = actor.Pos.Y-v.Y*distCheck DEBUG6 = actor.Pos.Z-v.Z*distCheck

			if self._up > 0 then
				local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(actor.Pos.X,actor.Pos.Y,actor.Pos.Z, actor.Pos.X,actor.Pos.Y + distCheck,actor.Pos.Z)
				if b then
					self._fin = true
					local barrier = PHYSICS.GetHavokBodyBarrierInfo(he)
					--Game:Print("barrier == "..barrier)
					if barrier == 1 then
						GObjects:ToKill(actor)
						return
					end

					--if d < 1 then d = 1 end
					actor:FlyTo(actor.Pos.X,actor.Pos.Y + d*0.5,actor.Pos.Z)
					return
				end			
			end
			local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(actor.Pos.X,actor.Pos.Y,actor.Pos.Z, actor.Pos.X-v.X*2.0,actor.Pos.Y-v.Y*2.0,actor.Pos.Z-v.Z*2.0)
			if b then
				 --DEBUG10 = x + nx DEBUG11 = y + ny DEBUG12 = z + nz
				 --DEBUG13 = x DEBUG14 = y DEBUG15 = z
				--if ny < 0 then
				--	actor:FlyForward(actor._distToEnd - actor._distStart + 0.5, math.random(-60,60))
				--	Game:Print("fly another dir")
				--	Game.freezeUpdate = true					
				--else
					local mul = d * 1.2
					actor:FlyTo(x + nx*mul,y + ny*mul ,z + nz*mul)
					--if debugMarek then Game:Print("fly to normal") end
				--end
			end
		end
		self._lastPosX = actor.Pos.X
		self._lastPosY = actor.Pos.Y
		self._lastPosZ = actor.Pos.Z
	end
end

function Bat._CustomAiStates.BatEscape:OnRelease(brain)
	brain._batfly = false
end

function Bat._CustomAiStates.BatEscape:Evaluate(brain)
	if brain._batfly then
		return 0.2
	end
	return 0.0
end


--------------------------
Bat._CustomAiStates.Batattack = {
	name = "Batattack",
	active = false,
}

function Bat._CustomAiStates.Batattack:OnInit(brain)			-- dodac delay pomiedzy atakami
	self.active = true
	local actor = brain._Objactor
	if not brain.r_closestEnemy then
	else
		--local x,y,z = ENTITY.PO_GetPawnHeadPos(brain.r_closestEnemy._Entity)
		--actor:FlyTo(x,y,z)
		actor:FlyTo(brain.r_closestEnemy.Pos.X,brain.r_closestEnemy.Pos.Y + 1.3,brain.r_closestEnemy.Pos.Z)
	end
	self.timerDelay = 0
	--if debugMarek then Game:Print("start atak") end
	self._lastPosX = actor.Pos.X
	self._lastPosY = actor.Pos.Y
	self._lastPosZ = actor.Pos.Z
end

function Bat._CustomAiStates.Batattack:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if (brain.r_closestEnemy) then
		local dist = Dist3D(brain.r_closestEnemy.Pos.X,brain.r_closestEnemy.Pos.Y + 1.3,brain.r_closestEnemy.Pos.Z, actor.Pos.X,actor.Pos.Y,actor.Pos.Z)
		if dist <= aiParams.attackRange then
			if self.timerDelay <= 0 then
				Player:OnDamage(aiParams.weaponDamage * FRand(0.6, 1.4),actor,0)
				self.timerDelay = math.random(7,12)
			else
				self.timerDelay = self.timerDelay - 1
			end
		else
			if math.random(100) < 5 then
				--if debugMarek then Game:Print("fly to AGAIN") end
				actor:FlyTo(brain.r_closestEnemy.Pos.X,brain.r_closestEnemy.Pos.Y + 1.3,brain.r_closestEnemy.Pos.Z)
			end
		end
	end
	if not actor._isWalking then
		brain._landAfterAttack = true
		--Game:Print("koniec ataku")
	else
		if (math.random(100) < aiParams.collisionCheckSpeed) then
			local v = Vector:New(self._lastPosX - actor.Pos.X, self._lastPosY - actor.Pos.Y, self._lastPosZ - actor.Pos.Z)

			v:Normalize()
			--DEBUG1 = actor.Pos.X DEBUG2 = actor.Pos.Y DEBUG3 = actor.Pos.Z
			--DEBUG4 = actor.Pos.X-v.X*2 DEBUG5 = actor.Pos.Y-v.Y*2 DEBUG6 = actor.Pos.Z-v.Z*2

			local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(actor.Pos.X,actor.Pos.Y,actor.Pos.Z, actor.Pos.X-v.X*2.0,actor.Pos.Y-v.Y*2.0,actor.Pos.Z-v.Z*2.0)
			if b then
				brain._landAfterAttack = true
			end
		end
		self._lastPosX = actor.Pos.X
		self._lastPosY = actor.Pos.Y
		self._lastPosZ = actor.Pos.Z
	end
end

function Bat._CustomAiStates.Batattack:OnRelease(brain)
	brain._batfly = true
	brain._landAfterAttack = true
	brain._batflySndSrc = Vector:New(Player.Pos.X + FRand(1,2), Player.Pos.Y, Player.Pos.Z + FRand(1,2))
	self.active = false
end

function Bat._CustomAiStates.Batattack:Evaluate(brain)
	if (brain.r_closestEnemy or self.active) and not brain._landAfterAttack then
		return 0.6
	end
	return 0.0
end



--------------------------
Bat._CustomAiStates.Batidle = {
	name = "Batidle",
	active = false,
}

function Bat._CustomAiStates.Batidle:OnInit(brain)
	self.delayBetweenAttacks = math.random(5, 150)
end

function Bat._CustomAiStates.Batidle:OnUpdate(brain)
	if self.delayBetweenAttacks > 0 then
		self.delayBetweenAttacks = self.delayBetweenAttacks - 1
	else
		brain._landAfterAttack = false
	end
end


function Bat._CustomAiStates.Batidle:Evaluate(brain)
	return 0.01
end

