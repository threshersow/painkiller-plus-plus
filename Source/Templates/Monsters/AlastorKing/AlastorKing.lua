function o:OnPrecache()
	Cache:PrecacheDecal(self.HitDecal)
	Cache:PrecacheItem("WallPart.CItem")
	Cache:PrecacheActor("FX_Thorhit.CActor")
end


function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:CustomOnDeath()
	ENTITY.SetVelocity(self._Entity, 0, self.velocityUpOnDeath, 0)
	self:EndFlame()
	self._timerToDemon = 0
end

function o:CustomUpdate()
	if not self._died then
		Game.MegaBossHealth = self.Health
	else
		Game.MegaBossHealth = 0
	end

	if self._flameFX then
		self:CheckDamageFromFlame()
	end
end

function o:CustomOnDeathUpdate()
	if self._timerToDemon then
		self._timerToDemon = self._timerToDemon - 1
		if self._timerToDemon <= 0 then
			self._demonfx = Game:EnableDemon(true, 10, false, 1.0)
			self._timerToDemon = nil
		end
	else
		if self._demonfx and self._demonfx.TickCount > self._demonfx.EffectTime - 1.0 then
			self._demonfx = nil
			GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		end
	end
end



function o:OnCreateEntity()
--	self._disableHits = true
	Game.MegaBossHealthMax = self.Health
	Game.MegaBossHealth = self.Health	

	self._lastDamageFromFire = 0

	self.AiParams.wingJointsNo = {}
	for i,v in self.AiParams.wingJoints do
		local idx  = MDL.GetJointIndex(self._Entity,v)
		if idx == -1 then
			Game:Print(v.." not found")
		end
		table.insert(self.AiParams.wingJointsNo, idx)
	end
	if not debugMarek then
		Game.showCompassArrow = false
    else
        DebugSpheres = {}
	end

	 self._moveWithAnimationDoNotUpdateAngle = true
	 self._pissedOffRatio = 0
    self._delayExplTime = 2
end

function o:OnApply()
	if not self._sp then
		self._sp = self:AddPFX("spawn")
		self:PlayRandomSound2D("Spawn")
	end
end

function o:CustomOnDamage(he,x,y,z,obj,damage,type,nx,ny,nz)
	-- tu spr. czy nie od wlasnej eksplozji
	if type == AttackTypes.OutOfLevel then
		self._died = true
		self.Health = 0
		self._disableDemonic = true
		Game.MegaBossHealth = nil
		self._deathTimer = self.DeathTimer
		GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		Game.MegaBossHealthMax = nil
		Game:Print("ERROR: ALASTOR POZA LEVELEM")
		return true
	end

	if obj == self then
		return true
	end

	if obj and obj.Model == "stonegolem" then
		if self.Animation ~= "stuned" and not self._gotDamage then
			Game._EarthQuakeProc:Add(self._groundx,self._groundy,self._groundz, --[[self.StompTimeOut--]]20, 100--[[self.StompRange--]], 0.4, 0.4, 1.0)
			self._gotDamage = true
		end
		return false
	end
	if self.Animation == "stuned" then
		return false
	end
	return true
end
 




-------------
function o:OnTick(delta)
--[[- cheat ---
    if not IsFinalBuild() then
            if INP.Key(Keys.PgUp) == 1 then 
			local obj = {}
			obj.Model = "stonegolem"
            self:OnDamage(1500, obj)
            Game:Print("DAMAGE alastor")
        end
	end
--]]

	if self._flameFX then
	
		local x2,y2,z2,x3,y3,z3 = self:FlamePos()
		
		if debugMarek then
			self.yaaaadebug1 = x2
			self.yaaaadebug2 = y2
			self.yaaaadebug3 = z2
			self.yaaaadebug4 = x3
			self.yaaaadebug5 = y3
			self.yaaaadebug6 = z3
		end
		
		local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v2:Normalize()
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)

		q:ToEntity(self._flameFX)
		ENTITY.SetPosition(self._flameFX,x2,y2,z2) 
	end
	
	if self._isWalking or self._moveWithAnimation then	
		self._delayExplTime = self._delayExplTime - 1
		if self._delayExplTime < 0 then
			if self._flying then
				self._delayExplTime = 4
			else
				self._delayExplTime = 12
			end
			local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
			v:Normalize()
			v:MulByFloat(7.0)
			local x,y,z = self._groundx,self._groundy,self._groundz
			y = y + 6

			--[[if debugMarek then
				DebugSphereX = x + v.X
				DebugSphereY = y
				DebugSphereZ = z + v.Z
				DebugSphereRange = 8
			end--]]
			WORLD.Explosion2(x+v.X, y, z+v.Z, 5000, --[[range--]]8,nil,AttackTypes.Rocket,self.AiParams.walkDamage)
			--if math.random(100) < 15 then
			--	PlayLogicSound("EXPLOSION",x+v.X, y, z+v.Z,16,32)
			--end
		end
	end
end

--[[
function o:Throw()
	local aiParams = self.AiParams
    local brain = self._AIBrain

	local Joint = MDL.GetJointIndex(self._Entity, "d_l_5_3")
	local x,y,z = MDL.TransformPointByJoint(self._Entity,Joint,0,0,0)
	local v2 = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v2:Normalize()
	x = x + v2.X * 3.0
	z = z + v2.Z * 3.0
	local e, obj = AddItem("FireBallo.CItem",nil,Vector:New(x,y,z),true)
	obj.ObjOwner = self
	obj.Pos.X = x
	obj.Pos.Y = y
	obj.Pos.Z = z
	obj:Apply()
	obj:Synchronize()
	self._objTakenToThrow = obj
	brain._enemyLastSeenPoint.X = Player._groundx
	brain._enemyLastSeenPoint.Y = Player._groundy
	brain._enemyLastSeenPoint.Z = Player._groundz
	self:ThrowTaken(nil, true)
end


function o:StrikeGround()
	local x,y,z = self:GetJointPos("d_p_5_3")
	WORLD.Explosion2(x, self._groundy + 1.0, z, 5000, --[[range--]]7,nil,AttackTypes.Rocket,self.AiParams.strikeDamage)
	if debugMarek then
		Game:Print("strike ground")
		self._debugdx3 = x
		self._debugdy3 = self._groundy + 1.0
		self._debugdz3 = z
		self.d1 = x
		self.d2 = y
		self.d3 = z
		self.d4 = x
		self.d5 = y - 3.0
		self.d6 = z
	end
	
	if self.FXwhenHit then
		AddObject(self.FXwhenHit,1.0, Vector:New(x,y,z), nil, true)
	end
	
	if self.HitDecal then
		local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x,y,z,x,y - 3.0,z)
		if e then
			--Game:Print("spawn decal")
			ENTITY.SpawnDecal(e,self.HitDecal,x,y,z,0,1,0, 10)
		end
	end

end
]]


function o:Stomp(joint, modif)
	local p = modif
	if not p then
		p = 1.0
	end
	local x,y,z = self:GetJointPos(joint)
	if not debugMarek then
		Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange * p, self.CameraMov * p, self.CameraRot * p, 1.0)
	end
	WORLD.Explosion2(x, y + 3, z, 1000, --[[range--]]5,self._Entity,AttackTypes.Rocket,200)

    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
	local p = self.s_SubClass.ParticlesDefinitions.step
	self:BindFX(p.pfx,p.scale,joint)
end

function o:EnableRotate()		-- zeby w powietrzu mogl sie obracac
	self._canRotate = true
end

function o:DisableRotate()
	self._canRotate = false
end


o._CustomAiStates = {}
------------
o._CustomAiStates.groundAttackAlastorB = {
	name = "groundAttackAlastorB",
	active = false,
	
	-- atak1 - 27 <- przebyty dystans
	
	ziejeDist = 35.0,	-- <
	hitDist = 30.0,		--
	minAttackDistance = 25.0,
	veryFar = 100.0,
}

function o._CustomAiStates.groundAttackAlastorB:OnInit(brain)
	--Game:Print("gr attack "..brain._distToNearestEnemy)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	self.atak1minDistance = actor.AiParams.breathAttackDistMin
	brain._submode = nil
	--self.mode = 0
	self.active = true
	actor:SetAnim("idle1",false)
	actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
	--actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
	self.attackMode = false
	self.lastTimeOnAttack = brain._currentTime + FRand(0, 0.5)
	actor._pissedOffRatio = 0
	
	self.lastTimeFireball = brain._currentTime + FRand(0, 2)
	self.lastTimeZieje = brain._currentTime + FRand(-5, -2)
	self.lastTimeWall = brain._currentTime + FRand(3, 6)
	self.lastTimeHit = brain._currentTime + FRand(-5, -2)
	self.lastTimeShock = -100

	self.TimeBetweenFireball = aiParams.TimeBetweenFireball
	self.TimeBetweenZieje = aiParams.TimeBetweenZieje
	self.TimeBetweenHit = aiParams.TimeBetweenHit
	self.TimeBetweenWall = aiParams.TimeBetweenWall
	self.TimeBetweenShock = aiParams.TimeBetweenShock
	
	self.lastTimeLaugh = brain._currentTime + FRand(-1, 0)
end

function o._CustomAiStates.groundAttackAlastorB:CanHit(brain)
	if self.lastTimeHit + self.TimeBetweenHit < brain._currentTime then
		brain._Objactor:FullStop()
		--local b,d,e = brain._Objactor:Trace(35, 0, true)

		local actor = brain._Objactor		
		local idx  = MDL.GetJointIndex(actor._Entity,"root")
		local cx,cy,cz = MDL.TransformPointByJoint(actor._Entity, idx,0,0,-8)
		
		local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
		v:Normalize()

		local length = 35
		local fx = v.X*length + cx
		local fy = v.Y*length + cy
		local fz = v.Z*length + cz
		
		if debugMarek then
			DEBUGcx, DEBUGcy, DEBUGcz, DEBUGfx, DEBUGfy, DEBUGfz = cx,cy,cz,fx,fy,fz
		end

		local b = WORLD.LineTraceFixedGeom(cx,cy,cz,fx,fy,fz)
		local cx,cy,cz = MDL.TransformPointByJoint(actor._Entity, idx,0,0,8)
		
		if debugMarek then
			actor.d1,actor.d2,actor.d3,actor.d4,actor.d5,actor.d6 = cx,cy,cz,fx,fy,fz
		end
		
		local b2
		if not b then
			b2 = WORLD.LineTraceFixedGeom(cx,cy,cz,fx,fy,fz)
		end
		
		if not b and not b2 then
			self.lastTimeHit = brain._currentTime + FRand(self.TimeBetweenHit,self.TimeBetweenHit*1.2)
			return true
		end
		if debugMarek then
			--Game.freezeUpdate = true
			Game:Print("KOLIZJA PRZY HIT")
		end
	end
	return false
end
function o._CustomAiStates.groundAttackAlastorB:CanWall(brain)
	if self.lastTimeWall + self.TimeBetweenWall < brain._currentTime then
		brain._Objactor:FullStop()
		self.lastTimeWall = brain._currentTime + FRand(self.TimeBetweenWall,self.TimeBetweenWall*1.2)
		return true
	end
	return false
end
function o._CustomAiStates.groundAttackAlastorB:CanZieje(brain)
	if self.lastTimeZieje + self.TimeBetweenZieje < brain._currentTime then
		brain._Objactor:FullStop()
		self.lastTimeZieje = brain._currentTime + FRand(self.TimeBetweenZieje,self.TimeBetweenZieje*1.2)
		return true
	end
	return false
end
function o._CustomAiStates.groundAttackAlastorB:CanShock(brain)
	if self.lastTimeShock + self.TimeBetweenShock < brain._currentTime then
		return true
	end
	return false
end
function o._CustomAiStates.groundAttackAlastorB:CanFireball(brain)
	if self.lastTimeFireball + self.TimeBetweenFireball < brain._currentTime then
		brain._Objactor:FullStop()
		self.lastTimeFireball = brain._currentTime + FRand(self.TimeBetweenFireball,self.TimeBetweenFireball*1.2)
		return true
	end
	return false
end


function o._CustomAiStates.groundAttackAlastorB:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
    
    local x,y,z = brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y,brain._enemyLastSeenPoint.Z
	
    if self._mode then
		if actor._canRotate then
			actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
		else
			if actor._isRotating then
				actor:FullStop()
			end
		end

		actor._moveWithAnimationDoNotUpdateAngle = false
		if actor.Animation ~= self._mode or not actor._isAnimating then
			Game:Print("end self._mode "..actor.Animation)

			actor._moveWithAnimationDoNotUpdateAngle = true
			if (Player._lastTimeHit + 120 > Game.currentTime or math.random(100) < 20) 
				 and self._mode ~= "stuned" and self._mode ~= "laugh" and not actor._gotDamage then
				if self.lastTimeLaugh + 5.0 < brain._currentTime then
					if math.random(100) < 80 then
						actor:SetAnim("laugh", false)
						self._mode = "laugh"
						--Game:Print("LAUGH")
						self.lastTimeLaugh = brain._currentTime + FRand(5,6)
						return
					end
				end
			end
			self._mode = nil
		else
			return
		end
	end

	if actor._gotDamage	and not actor._rotatingWithAnim then
		actor._gotDamage = nil
		Game:Print("stunned")
		self._mode = "stuned"
		actor:SetAnim("stuned",false)
		for i,v in Actors do
			if v.Model == "stonegolem" and v.Health > 0 and v.AIenabled then
				v:OnDamage(99999,self,AttackTypes.StickyBomb)
			end	
		end
		return
	end
	--
	local angleToPlayer = math.atan2(brain._enemyLastSeenPoint.X - actor._groundx, brain._enemyLastSeenPoint.Z - actor._groundz)
	local aDist = math.abs(AngDist(actor.angle, angleToPlayer) * 180/math.pi)
	local dist = brain._distToNearestEnemy
	local distPlayerToWP = 19
    local centre = arenaCentre.Points[1]
    
	local zn,idx = WPT.GetClosest(x,y,z)  
	local x2,y2,z2
	if idx > -1 then
		x2,y2,z2 = WPT.GetPosition(zn,idx)
		distPlayerToWP = Dist3D(x,y,z, x2,y2,z2)
	end
	---

	if self._golemHunt then
        local v = self._golemHunt
        if v.Health > 0 then
			local d = Dist3D(v._groundx,v._groundy,v._groundz,actor._groundx,actor._groundy,actor._groundz)
			if d < aiParams.distWhenSphereAttack then
				--Game.freezeUpdate = true
				actor:FullStop()
				Game:Print("atak_sphere_of_fire")
				actor:SetAnim("atak_sphere_of_fire",false)
				self._mode = "atak_sphere_of_fire"

				self._golemHunt = nil
				return
			end

			if not actor._isWalking then
				actor:WalkTo(self._golemHunt._groundx,self._golemHunt._groundy,self._golemHunt._groundz,nil,FRand(50,60))
			end
        else
            self._golemHunt = nil
		end
		return
	end

	---------------
	if not actor._rotatingWithAnim then
		if self:CanShock(brain) then
			--Game:Print("----------------- lookni for golem "..brain._currentTime)
			local dist = 9999
			local actor = brain._Objactor
			for i,v in Actors do
				if v.Model == "stonegolem" and v.Health > 0 and (v.AIenabled --[[or v._ABdo--]]) then
					local d = Dist3D(v._groundx,v._groundy,v._groundz,actor._groundx,actor._groundy,actor._groundz)
					if d < dist then

						actor:FullStop()
						self.lastTimeShock = brain._currentTime + FRand(1,3)

						Game:Print("ma golema "..v._Name.." "..self.lastTimeShock)
						self._golemHunt = v
						dist = d
					end
				end
			end
		end
		if self._golemHunt then
			return
		end


--[[		if brain._seeEnemy then
			Game:Print("ZEEdist = "..dist.." ad = "..aDist)
		else
			Game:Print("___dist = "..dist.." ad = "..aDist)
		end]]
		if dist < self.ziejeDist then
			if (dist < self.hitDist + 5) and (dist > self.hitDist - 5) and math.random(100) < 80 and brain._seeEnemy then
				-- tu trace, czy jest miejsce
				if aDist < 30 and self:CanHit(brain) then
					Game:Print("VF: atak hit")
					actor:SetAnim("atak_hit",false)
					self._mode = "atak_hit"
					return
				end
			end
			if math.random(100) < 30 and dist > self.minAttackDistance and aDist < 25 and self:CanWall(brain) then
				Game:Print("VF: atak_wall_of_fire")
				actor:SetAnim("atak_wall_of_fire",false)
				self._mode = "atak_wall_of_fire"
				return
			else
				if dist > 10 and aDist < 46 and self:CanZieje(brain) then
					Game:Print("VF: atak_zieje")
					actor:SetAnim("atak_zieje",false)
					self._mode = "atak_zieje"
					return
				end
			end
			
		else
			if dist < self.veryFar then
				if brain._seeEnemy then
					if dist < 50 and aDist < 25 and self:CanWall(brain) then
						Game:Print("VF: atak_wall_of_fire")
						actor:SetAnim("atak_wall_of_fire",false)
						self._mode = "atak_wall_of_fire"
						return
					else
						if aDist < 45 and self:CanFireball(brain)  then
							Game:Print("VF: atak_fireballs")
							actor:SetAnim("atak_fireballs",false)
							self._mode = "atak_fireballs"
							return
						end
					end
				else
					if aDist < 26 and self:CanWall(brain) then
						Game:Print("VF: atak_wall_of_fire2")
						actor:SetAnim("atak_wall_of_fire",false)
						self._mode = "atak_wall_of_fire"
						return
					else
						if aDist < 45 and self:CanFireball(brain)  then
							Game:Print("VF: atak_fireballs2")
							actor:SetAnim("atak_fireballs",false)
							self._mode = "atak_fireballs"
							return
						else
							--Game:Print("?")
						end
					end
				end				
			else
				--Game:Print("too far?")
				--if brain._seeEnemy then
				--	actor:FullStop()
				--end
			end
		end
	end
	
	------------------------
	if not actor._isRotating and not actor._isWalking then    

		if brain._currentTime < actor._lastCantMoveTime + 2/30 then
			Game:Print("Cant move, walk random")
			if not actor._rotatingWithAnim then
				actor:WalkForward(FRand(20,30),nil,FRand(100,260))
			end
			return
		end
		-------------- gracz b. daleko
		if dist > self.veryFar then
			if not brain._seeEnemy or math.random(100) < 80 then
				if aDist > 40 and math.random(100) < 90 then
					Game:Print("VF: rw1")
					actor:RotateToVectorWithAnim(x,y,z)
					return
				else
					if math.random(100) < 20 and not brain._seeEnemy then
						Game:Print("VF: random")
						--120
						actor:WalkTo(centre.X + FRand(-120,120), centre.Y, centre.Z + FRand(-120,120),nil, FRand(50,120))
					else
						local displace = self.veryFar / 6
						if displace > 15 then
							displace = 15
						end
						Game:Print("VF: walk")
						actor:WalkTo(x + FRand(-displace,displace), y, z + FRand(-displace,displace),nil,FRand(60,80))
					end
					return
				end
			else
				-- 
				if (aDist < 30) and self:CanFireball(brain) then
					Game:Print("VF: atak fireball")
					actor:SetAnim("atak_fireballs",false)
					self._mode = "atak_fireballs"
					return
				else
					Game:Print("VF: rw2")
					actor:RotateToVectorWithAnim(x,y,z)
				end
			end
		else
			-------------- gracz nie b. daleko
			if aDist > 40 then
				Game:Print("NVF: rw1")
				actor:RotateToVectorWithAnim(x,y,z)
				return
			else
				if distPlayerToWP > 20 and math.random(100) < 55 then
					Game:Print("distPlayerToWP > 20")
					if math.random(100) < 80 then
						actor:WalkTo(x + FRand(-40,40), y, z + FRand(-40,40),nil, FRand(40,80))				
					else
						actor:WalkTo(centre.X + FRand(-120,120), centre.Y, centre.Z + FRand(-120,120),nil, FRand(40,80))
					end
					return
				end
				if dist < self.minAttackDistance then
					if math.random(100) < 20 and not brain._seeEnemy and self:CanWall(brain) then
						Game:Print("BLISKO: atak_wall_of_fire")
						actor:SetAnim("atak_wall_of_fire",false)
						self._mode = "atak_wall_of_fire"
						return
					else
						Game:Print("BLISKO: walk forward")
						actor:WalkForward(FRand(20,50),nil,FRand(-30,30))
					end
				else
					Game:Print("NVF: walk "..distPlayerToWP)
					actor:WalkTo(x + FRand(-6,6), y, z + FRand(-6,6),nil,FRand(50,80))
				end
				return
			end
		end
	end
end

function o._CustomAiStates.groundAttackAlastorB:OnRelease(brain)
	self.active = nil
	local actor = brain._Objactor
	actor:EndFlame()
end

function o._CustomAiStates.groundAttackAlastorB:Evaluate(brain)
	return 0.1
end



	
-------------------
function o:CustomOnDeathUpdate()
	if self._timerToDemon then
		self._timerToDemon = self._timerToDemon - 1
		if self._timerToDemon <= 0 then
			self._demonfx = Game:EnableDemon(true, 10, false, 0.25)
			self._timerToDemon = nil
		end
	else
		if self._demonfx and self._demonfx.TickCount > self._demonfx.EffectTime - 1.0 then
			self._demonfx = nil
			GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		end
	end
end

function o:BurnWings()
	self._wingsPFX = {}
	self:AddTimer("BurnWing",0.1)
end

function o:BurnWing()
	local count = table.getn(self.AiParams.wingJoints)
	local b = math.random(1,count)
	if not self._wingsPFX[b] then
		local p = self.s_SubClass.ParticlesDefinitions.wings
		self._wingsPFX[b] = self:BindFX(p.pfx, p.scale, self.AiParams.wingJoints[b])
	end
end

function o:Firewall()
	for i,v in self._wingsPFX do
		PARTICLE.Die(v)
	end
    self:ReleaseTimers()
    
    local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v:Normalize()
	local v3 = Clone(v)
	v3:MulByFloat(22)
	v:MulByFloat(14)

	v.X = v.X + self._groundx
	v.Y = v.Y + self._groundy - 1
	v.Z = v.Z + self._groundz

    local v2 = Vector:New(math.sin(self.angle + math.pi/2), 0, math.cos(self.angle + math.pi/2))
	v2:Normalize()
	v2:MulByFloat(4)
	
    for i=1,9 do
		local obj = GObjects:Add(TempObjName(),CloneTemplate("WallPart.CItem"))
		obj.Pos = Vector:New(v.X + v2.X * (i-4),v.Y,v.Z + v2.Z * (i-4))
		obj.ObjOwner = self
		obj:Apply()
		if obj.Synchronize then
			obj:Synchronize()
		end
		--Game:Print("CW")
		if i == 4 then
			obj:BindSound("actor/kingalastor/alastor_firewall-loop",20,40, true)
		end
		ENTITY.SetVelocity(obj._Entity, v3.X,v3.Y,v3.Z)
	end
    
	self._wingsPFX = nil
end

---------
function o:FireballCreate()
	if not self._fireballs then
		self._fireballs = {}
		self._fPFX = {}
		local p = self.s_SubClass.ParticlesDefinitions.createFireballs
		table.insert(self._fPFX, self:BindFX(p.pfx, p.scale, "dlo_lewa_root"))
		table.insert(self._fPFX, self:BindFX(p.pfx, p.scale, "dlo_prawa_root"))
	end

	local obj = GObjects:Add(TempObjName(),CloneTemplate(self.AiParams.ThrowableItem))
	obj.ObjOwner = self
	local x,y,z
	local a = table.getn(self._fireballs)
	if a == 0 or a == 2 then
		x,y,z = self:GetJointPos("dlo_lewa_root")
	else
		x,y,z = self:GetJointPos("dlo_prawa_root")
	end

	y = y + 20
	obj.Pos = Vector:New(x,y,z)
	
	obj._enabled = false
	obj:Apply()
	if obj.Synchronize then
		obj:Synchronize()
	end

	local v = Vector:New(FRand(-1,1),4,FRand(-1,1))
	v:Normalize()
	v:MulByFloat(self.AiParams.throwVelocity * FRand(0.45,0.5))
	obj._rot = FRand(0,6.28)
	obj._velInitial = v
	ENTITY.SetVelocity(obj._Entity, v.X,v.Y,v.Z)
	
	table.insert(self._fireballs, obj)
	obj.randomizeTargetPos = FRand(-4,4)
	
	obj._lastAngle = math.atan2(v.X, v.Z)
	obj._lastPitch = math.atan2(v.Y, math.sqrt(v.X*v.X+v.Z*v.Z))

	obj:BindSound("actor/kingalastor/alastor_attack1-fireball",60,200,false)
	--Game:Print("obj.randomizeTargetPos = "..obj.randomizeTargetPos)
end

function o:FireballsThrow()
	if self._fPFX then
		for i,v in self._fPFX do
			PARTICLE.Die(v)
		end
		self._fPFX = nil
	end
	if self._fireballs then
		for i,v in self._fireballs do
			v._target = Player
			v._enabled = true
		end
		self._fireballs = nil
	end
end

--------------------
function o:StrikeGround()
	local x,y,z = self:GetJointPos("d_p_5_3")
	WORLD.Explosion2(x, self._groundy + 1.0, z, 5000, --[[range--]]7.5,nil,AttackTypes.AIClose,self.AiParams.strikeDamage)
	if debugMarek then
		Game:Print("strike ground")
		self._debugdx3 = x
		self._debugdy3 = self._groundy + 1.0
		self._debugdz3 = z
		self.d1 = x
		self.d2 = y
		self.d3 = z
		self.d4 = x
		self.d5 = y - 3.0
		self.d6 = z
	end
	
	if self.FXwhenHit then
		AddObject(self.FXwhenHit,1.0, Vector:New(x,y,z), nil, true)
	end
	
	if self.HitDecal then
		local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x,y,z,x,y - 3.0,z)
		if e then
			--Game:Print("spawn decal")
			ENTITY.SpawnDecal(e,self.HitDecal,x,y,z,0,1,0, 10)
		end
	end
end

------------------
function o:StartFlame()
	if not self._flameFX then
		local x2,y2,z2,x3,y3,z3 = self:FlamePos()
				
		local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v2:Normalize()
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)

		if debugMarek then
			self.yaadebug1 = x2
			self.yaadebug2 = y2
			self.yaadebug3 = z2
			self.yaadebug4 = x3
			self.yaadebug5 = y3
			self.yaadebug6 = z3
		end
		
		
		local p = self.s_SubClass.ParticlesDefinitions.flame
		self._flameFX = AddPFX(p.pfx, p.scale, Vector:New(x3,y3,z3), q)
	end
end

function o:EndFlame()
	if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end
end


function o:Shockwave()
	local v = Vector:New(self._groundx,self._groundy,self._groundz)
	v.Y = v.Y - 5

    local s = self.ShockWave
    AddObject(s.FXwhenHit,s.FXwhenHitScale, v, nil, true) 

    Game._EarthQuakeProc:Add(v.X,v.Y,v.Z, s.eqTimeOut, s.eqRange, s.eqCameraMove, s.eqCameraMove, 1.0)
	local dist = Dist3D(v.X,v.Y,v.Z,Player._groundx, Player._groundy, Player._groundz) 
	
    local b,d,x,y,z,nx,ny,nz,he,e
	if s.HitDecal then
		b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(v.X,v.Y + 10.0,v.Z,v.X,v.Y - 50.0,v.Z)
		if debugMarek then
		 self.DEBUG_P1 = v.X
		 self.DEBUG_P2 = v.Y + 2.0
		 self.DEBUG_P3 = v.Z
		end
		ENTITY.SpawnDecal(e,s.HitDecal,v.X,v.Y,v.Z,0,1,0, 10)
	end

	--Game:Print("SHOCK "..dist)	
	if dist < s.range then
		if not ENTITY.PO_IsFlying(Player._Entity) then
			ENTITY.PO_SetPlayerFlying(Player._Entity, 0.3)
			--ENTITY.SetVelocity(Player._Entity, v2.X, v2.Y, v2.Z)
			--Player:OnDamage(s.damage - s.damage * dist / s.range, self)
			local v2 = Vector:New(Player._groundx - v.X,0,Player._groundz - v.Z)
			v2:Normalize()
			v2.Y = 1.2
			v2:MulByFloat(s.playerHitStr * FRand(0.9,1.1))
			ENTITY.SetVelocity(Player._Entity, v2.X, v2.Y, v2.Z)
		end
	end
	
--[[	for i,v in Actors do
		if v.Model == "stonegolem" and v.Health > 0 and v.AIenabled then
			local d = Dist3D(v._groundx,v._groundy,v._groundz,actor._groundx,actor._groundy,actor._groundz)
		end
	end--]]
	
	Game:Print("-----------------EXXXXX")
    WORLD.Explosion2(v.X,v.Y,v.Z, s.explosionStren, s.range, nil, AttackTypes.StickyBomb, 200)

   	if self._immPFX then
		for i,v in self._immPFX do
			PARTICLE.Die(v)
		end
	end
	self._immPFX = nil
end



function o:CheckDamageFromFlame()
	-- dodac min. time between attacks
	local x2,y2,z2,x3,y3,z3 = self:FlamePos()		
	
	local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
	v2:Normalize()
	
	-- spr. kilka sfer na drodze promienia, czy Player jest w zasiegu plomienia
	local i = 5
	if debugMarek then
		DebugSpheres = {}
	end
	
	local dist = 45
	local size = 9

	--Game:Print("dist = "..dist.." size = "..size)
	
	
	
	while i < dist do
		local v3 = Clone(v2)
		v3:MulByFloat(i)
		i = i + size
		local x,y,z = x3 + v3.X, y3 + v3.Y, z3 + v3.Z
		
		if debugMarek then
			local a = {}
			a.X = x
			a.Y = y
			a.Z = z
			a.Size = size
			table.insert(DebugSpheres, a)
		end
		local dist = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.5, Player._groundz)
		if dist < size then
			if self._lastDamageFromFire + 10 < self._AIBrain._currentTime then
				self._lastDamageFromFire = self._AIBrain._currentTime
				Player:OnDamage(self.flameDamage, self)
			end
			break
		end
	end
end

function o:FlamePos()
	local idx  = MDL.GetJointIndex(self._Entity,"k_glowa")
	local idx2  = MDL.GetJointIndex(self._Entity,"k_szczeka")
	local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx,0,-2,0)
	local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx2,0,4,0)
	return x2,y2,z2,x3,y3,z3
end

function o:SphereOfFireFX()
    self._immPFX = {}
	local p = self.s_SubClass.ParticlesDefinitions.attackGolem
	for i,v in p.joints do
		table.insert(self._immPFX, self:BindFX(p.pfx, p.scale, v))
	end
end
