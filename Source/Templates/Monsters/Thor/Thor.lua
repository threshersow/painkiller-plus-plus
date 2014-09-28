function Thor:OnPrecache()
	Cache:PrecacheDecal(self.Hammer.HitDecal)
end

function Thor:FootFX(joint)
    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,-2,1,0)
    AddPFX('butthor',1.3,Vector:New(x,y,z))
end

function Thor:CustomOnDeathUpdate()
	if self._timerToDemon then
		self._timerToDemon = self._timerToDemon - 1
		if self._timerToDemon <= 0 then
			self._demonfx = Game:EnableDemon(true,10, false, 0.25)
			self._timerToDemon = nil
		end
	else
		if self._demonfx and self._demonfx.TickCount > self._demonfx.EffectTime - 1.0 then
			self._demonfx = nil
			GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		end
	end
end

function Thor:CustomOnDeath()		-- powinno byc delete Game:EnableCollisions
	self._timerToDemon = 10
	self._disableDemonic = true

	local i = MDL.GetJointIndex(self._Entity, "root")
	local x1,y1,z1 = MDL.GetJointPos(self._Entity, i)

	local v = Vector:New(x1 - PX, y1 - PY, z1 - PZ)
	v:Normalize()
	local rnd2 = self.impulseAfterDeathY
	local rnd1 = v.X * self.impulseAfterDeathXZ
	local rnd3 = v.Z * self.impulseAfterDeathXZ

	ENTITY.SetVelocity(self._Entity, rnd1, rnd2, rnd3)
end

--Thor.CustomOnDeathAfterRagdoll = Thor.CustomOnDeath

function Thor:OnCreateEntity()
    --local pos = Clone(self.Pos)
    --pos.X = pos.X + 5
    --pos.Y = pos.Y + 8
    
    --if not debugColl then
	--	debugColl = {}
    --end
    
    
    local pos = Vector:New(10,0,0)
    local e
    e,self._weaponE = AddItem("ThorMlot.CItem",self.Scale/10,pos,true)     

    local r = Quaternion:New();r:FromEuler(0,0,-1.57);r:ToEntity(e) 
	 
    --PHYSICS.CreateRigidConstraintBetweenEntities(self._Entity,e,pos.X,pos.Y,pos.Z)
    
    local j = MDL.GetJointIndex(self._Entity,"mlot")
    ENTITY.RegisterChild(self._Entity,e,true,j)
    
    --local brain = self._AIBrain
    --brain._JointH = MDL.GetJointIndex(e, "mlot")
    
	Lev.ObjBoss = self
	self._ABdone = false

	--(bool enable, float minimalDelay, float minimalStrength,
	-- float minimalNonFixedDelay, float minimalMass, float maximalMass, float minProbability)

    local count = ENTITY.EnableCollisionsToAll(true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
					 self.StoneParams.miminalMassReportingCollision,
					 self.StoneParams.maximalMassReportingCollision, self.StoneParams.amountReportingCollisions * 100)
	
	Game:Print("enable collision to "..count.." meshes")
	Game.MegaBossHealthMax = self._weaponE.Health
	Game.MegaBossHealth = self._weaponE.Health
end


function Thor:ParticleWhenRised()
    --self:BindFX(self.Hammer.PFXwhenRised, 1.0,"mlot",self.Hammer.PFXwhenRised_Displace.X,FXwhenRised_Displace.Y,FXwhenRised_Displace.Z)
	if not self._ABdone then
		local j = MDL.GetJointIndex(self._Entity,"mlot")
		--local x,y,z = MDL.TransformPointByJoint(self._Entity, j, self.Hammer.FXwhenRised_Displace.X,self.Hammer.FXwhenRised_Displace.Y,self.Hammer.FXwhenRised_Displace.Z)
        local tmp
		tmp, self.eeffxx = AddObject(self.Hammer.FXwhenRised,1.0, self.Hammer.FXwhenRised_Displace)	--Vector:New(x, y, z))
		ENTITY.RegisterChild(self._Entity, self.eeffxx, true, j)
	end
end


--[[
function Thor:OnCollision(x,y,z,nx,ny,nz,e)			-- splat! wdepnal w kogos
	if e then
		local obj = EntityToObject[e]
		if obj and obj.OnDamage and self.Health > 0 then
			--Game:Print("THOR:OnCollision")
			obj:OnDamage(FRand(self.CollisionDamage*0.5, self.CollisionDamage), self)
		end
	end
end
--]]

function Thor:atak1()
	local j = MDL.GetJointIndex(self._Entity,"mlot")
	if self._ABdone then
		self:boom(MDL.TransformPointByJoint(self._Entity, j, 5,0,0))
	else
		self:boom(MDL.TransformPointByJoint(self._Entity, j, 25,0,0))
	end
end


function Thor:recharge()
	local j = MDL.GetJointIndex(self._Entity,"mlot")
	local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, j, 5,0,0)
	local v = Vector:New(self._groundx, self._groundy, self._groundz)
	local d = 5
	local v2 = Vector:New(math.sin(self.angle + d*3.14/180), 0, math.cos(self.angle + d*3.14/180))
	v2:Normalize()
	v.X = v.X + v2.X * d
	v.Y = v.Y + v2.Y * d
	v.Z = v.Z + v2.Z * d
	Game._EarthQuakeProc:Add(v.X, v.Y, v.Z, 8, 60, self.CameraMov, self.CameraRot, 1.0)
	if self.Hammer.HitDecal then
		local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(v.X,v.Y + 2.0,v.Z,v.X,v.Y - 6.0,v.Z)
		--self.DEBUG_P1 = v.X
		--self.DEBUG_P2 = v.Y + 2.0
		--self.DEBUG_P3 = v.Z
		ENTITY.SpawnDecal(e,self.Hammer.HitDecal,v.X,v.Y,v.Z,0,1,0, 5)
	end
	if self._weaponE and not self._weaponE._died then
		--Game:Print("add healt to hammer")
		self._weaponE.Health = self._weaponE.Health + self.AiParams.HammerRecharge * self._weaponE._HealthMax
		if self._weaponE.Health > self._weaponE._HealthMax then
			self._weaponE.Health = self._weaponE._HealthMax
		end
		self._drawLightingOnce = true
		self._drawLighting = 2.0
	end
	
end


function o:Render(delta)
	if self._drawLighting and self._weaponE then
		local t = Templates["DriverElectro.CWeapon"]
        local j = MDL.GetJointIndex(self._weaponE._Entity, "mlot1") 
		local start = Vector:New(MDL.GetJointPos(self._weaponE._Entity,j))

		if self._drawLightingOnce then
			self._weaponE:BindFX("LighintgHitHammer")
			
			SOUND.Play2D("impacts/lightning_"..math.random(1,2))
			WORLD.AmbientColor(210,210,255,Lev.GunAmbientMultiplier)
			--WORLD.SetDirLight(d.Dir.X,d.Dir.Y,d.Dir.Z,Color:New(cl,cl,cl):Compose(),3)
		
			if Lev.Flash then
				Lev:Flash(true)
			end
			self._drawLightingOnce = false
		end

		self._points = {}
		self._points[1] = start

		--(points,parts,mode,size,color,pfx)
		if (self._drawLighting > 1.95 and self._drawLighting <= 2.0) then
			
			for z=1,3 do

				if not self._points[2] then
					local zakres = 1
					for i=2,8 do
						self._points[i] = Vector:New(self._points[i-1].X + FRand(-zakres,zakres),self._points[i-1].Y + FRand(3,6),self._points[i-1].Z + FRand(-zakres,zakres))
					end
					zakres = zakres * 6
					for i=9,22 do
						self._points[i] = Vector:New(self._points[i-1].X + FRand(-zakres,zakres),self._points[i-1].Y + FRand(4,8),self._points[i-1].Z + FRand(-zakres,zakres))
					end
				else
					local zakres = 1
					for i=2,8 do
						self._points[i] = Vector:New(self._points[i].X + FRand(-zakres,zakres),self._points[i].Y + FRand(-zakres,zakres),self._points[i].Z + FRand(-zakres,zakres))
					end
					zakres = zakres * 4
					for i=9,20 do
						self._points[i] = Vector:New(self._points[i].X + FRand(-zakres,zakres),self._points[i].Y + FRand(-zakres,zakres),self._points[i].Z + FRand(-zakres,zakres))
					end
				end

				t:DrawBezierLine(self._points,10,11, FRand(1.4, 1.5), R3D.RGB(FRand(75,85),FRand(85,105),FRand(200,255)))
				--t:DrawBezierLine(self._points,10,12, FRand(1.4, 1.5), R3D.RGB(FRand(75,85),FRand(85,105),FRand(200,255)))

			end

			--[[for i=2,8 do
				self._points[i] = Vector:New(self._points[i-1].X + FRand(-zakres,zakres),self._points[i-1].Y + FRand(3,6),self._points[i-1].Z + FRand(-zakres,zakres))
			end
			
			t:DrawBezierLine(self._points,30,11, 1.4, R3D.RGB(FRand(75,85),FRand(85,105),FRand(200,255)))
			t:DrawBezierLine(self._points,30,12, 1.4, R3D.RGB(FRand(75,85),FRand(85,105),FRand(200,255)))
--]]

			
			--[[local lv = Clone(self.points[1])
			lv:Sub(self.points[2])
			lv:Normalize()
			ENTITY.SetPosition(self._light,ex+lv.X*0.5,ey+lv.Y*0.5+0.5,ez+lv.Z*0.5)    
			LIGHT.Setup(self._light,2,R3D.RGBA(200,200,255,255),0,0,0,FRand(1,3))
			LIGHT.SetFalloff(self._light,FRand(2,3),FRand(5,6))--]]
			self._fin = false
		end
		if self._drawLighting < 1.86 and not self._fin then
			 WORLD.AmbientColor(Lev.Ambient.R,Lev.Ambient.G,Lev.Ambient.B,Lev.GunAmbientMultiplier)
			 self._fin = true
		end
		self._drawLighting = self._drawLighting - delta
		if self._drawLighting < 0 then
			self._drawLighting = nil
			self._points = nil
		end

	end
end


function Thor:boom(x2,y2,z2)
--	self.debugHIT = {}

	local v = Vector:New(self._groundx, self._groundy, self._groundz)
	local v2 = Vector:New(math.sin(self.angle + self.Hammer.hitAngleDisplace*3.14/180), 0, math.cos(self.angle + self.Hammer.hitAngleDisplace*3.14/180))
	--local v2 = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v2:Normalize()

	local dis = self.Hammer.hitPosDisplace
	if self._ABdone then
		dis = self.Fists.hitPosDisplace
	end

	v.X = v.X + v2.X * dis
	v.Y = v.Y + v2.Y * dis
	v.Z = v.Z + v2.Z * dis
	if debugMarek then
		DEBUG1f = v.X
		DEBUG2f = v.Y
		DEBUG3f = v.Z
	end

    AddObject(self.Hammer.FXwhenHit,1.0, v, nil, true) 

	if not self._ABdone then
		WORLD.ExplosionUp(v.X, v.Y, v.Z, self.Hammer.stren, self.Hammer.distance, self.Hammer.stren, self.Hammer.random)
	else
		WORLD.ExplosionParabolic(v.X, v.Y, v.Z, self.Fists.flightTime, self.Fists.radius, Player._groundx, Player._groundy, Player._groundz)
	end
	Game._EarthQuakeProc:Add(v.X, v.Y, v.Z, 8, 60, self.CameraMov*10, self.CameraRot*10, 2.0)--, 10)
	local dist = Dist3D(v.X,0,v.Z,Player._groundx, 0, Player._groundz) 
	--Game:Print("dist="..Dist3D(v.X,v.Y,v.Z,Player._groundx, Player._groundy, Player._groundz))
	
	if self.Hammer.HitDecal then
		local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(v.X,v.Y + 2.0,v.Z,v.X,v.Y - 6.0,v.Z)
		--self.DEBUG_P1 = v.X
		--self.DEBUG_P2 = v.Y + 2.0
		--self.DEBUG_P3 = v.Z
		ENTITY.SpawnDecal(e,self.Hammer.HitDecal,v.X,v.Y,v.Z,0,1,0, 10)
	end
	
	if dist < self.Hammer.directHitDistance then
		Player:OnDamage(self.Hammer.DamageWhenPlayerIsClose, self)
		--Game:Print("direct hit")
	else
		if not ENTITY.PO_IsFlying(Player._Entity) then
			ENTITY.PO_SetPlayerFlying(Player._Entity, 0.3)
			--Game:Print("gracz na podlozu")
			local maxDist = 300
			if dist > maxDist then
				dist = maxDist
			end
			
			local maxDist = self.Hammer.DamageRange
			if dist > maxDist then
				dist = maxDist
			end
			--Game:Print("self.Hammer.PlayerThrowUpMax * dist / maxDist "..(self.Hammer.PlayerThrowUpMax * (1 - dist / maxDist)))
			if not self._ABdone then
				local x,y,z = ENTITY.GetVelocity(Player._Entity)
				ENTITY.SetVelocity(Player._Entity, x, self.Hammer.PlayerThrowUpMax * (1 - dist / maxDist), z)
			end
			if self.Hammer.DamageWhenPlayerIsFar then
				Player:OnDamage(self.Hammer.DamageWhenPlayerIsFar - dist / maxDist * self.Hammer.DamageWhenPlayerIsFar, self)
			end
		else
			--Game:Print("gracz fruwa")
		end
	end
	--Game.freezeUpdate = true
end

function Thor:atak2()
	Game._EarthQuakeProc:Add(self._groundx, self._groundy, self._groundz, 5, 50, self.CameraMov, self.CameraRot, 2.0, 10)
	local j = MDL.GetJointIndex(self._Entity,"mlot")
	--self:boom(MDL.TransformPointByJoint(self._Entity, j, 0,25,0))
end


function Thor:Stomp(joint, modif)
	local p = modif
	if not p then
		p = 1.0
	end
	local x,y,z = self:GetJointPos(joint)
	Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange, self.CameraMov * p, self.CameraRot * p, 1.0)
	if debugMarek then
		DebugSphereX = x
		DebugSphereY = y
		DebugSphereZ = z
		DebugSphereRange = 5
	end
	WORLD.Explosion2(x, y, z, 1000, --[[range--]]5,self._Entity,AttackTypes.Rocket,self.AiParams.stepDamage)
	self:FootFX(x,y,z)
end

function Thor:FootFX(x,y,z)
    AddPFX('but',0.8,Vector:New(x,y,z))
end


function Thor:CustomUpdate()
	if self._ABdone then
		Game.MegaBossHealth = self.Health
	else
		if self._weaponE then
			Game.MegaBossHealth = self._weaponE.Health
		end
	end
end

--[[
function Thor:OnTick()
	if debugMarek and INP.Key(Keys.RightShift) == 2 then
		if INP.Key(Keys.K1) == 1 then
			self:RotateWithAnim(46)
		end
		if INP.Key(Keys.K2) == 1 then
			self:RotateWithAnim(-46)
		end
		if INP.Key(Keys.K3) == 1 then
			self:RotateWithAnim(91)			-- pozniej 89
		end
		if INP.Key(Keys.K4) == 1 then
			self:RotateWithAnim(-91)
		end
		if INP.Key(Keys.K5) == 1 then
			self:WalkForward(30)
		end

	end
end
--]]

function Thor:CustomOnElectro()
	if not self._ABdone then
	end
end

function Thor:CustomOnDamage(he,x,y,z,obj, damage, type)
	if self._ABdone then
		return false
	else
		return true
	end
end




function Thor:CustomDelete()
	Game.MegaBossHealth = nil
	Game.MegaBossHealthMax = nil
end

----------------------------------
Thor._CustomAiStates = {}
Thor._CustomAiStates.idleThor = {
	name = "idleThor",
	lastTimeAmbientSound = 0,
	lastAmbient = 0,
}


function Thor._CustomAiStates.idleThor:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor:SetIdle()
	self.delay = nil
	self.GuardStill = aiParams.GuardStill
	self.timeChangeStillToFalse = nil
	self.OLDonlyWPmove = self.onlyWPmove
	if not brain._walkArea then
		actor.onlyWPmove = aiParams.useOnlyWaypointsWhenGuard
	end
	self.walked = false
	self._submode = "idle"
end

function Thor._CustomAiStates.idleThor:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	if not self.GuardStill then
		if not actor._isWalking and not actor._isRotating then
            if brain._currentTime < actor._lastCantMoveTime + 2/30  then
                if debugMarek then Game:Print("obstacle detected by idle goal") end
                local ang = math.random(45,60)
                brain._walkStepLocal = brain._walkStepLocal * 0.65
                if brain._walkStepLocal < aiParams.walkStep*0.4 then
                    brain._walkStepLocal = aiParams.walkStep*0.4
                end
                if math.random(100) < 50 then
                    ang = -ang
                end
                --local b = actor:Trace(actor._SphereSize * FRand(1.0, 1.3), ang)
                --if b then
                --    actor:RotateWithAnim(-ang)
                --else
                    --if debugMarek then Game:Print("idle.state -> normal rot") end
                    --local b = actor:Trace(actor._SphereSize * FRand(1.0, 1.3), -ang)
                    --if b then
				--		actor:RotateWithAnim(ang)
					--end
                --end
            else
                if aiParams.stopAfterWalking and FRand(0.0, 1.0) <= aiParams.stopAfterWalking and self.walked then
                    self.timeChangeStillToFalse = math.random(aiParams.stopAfterWalkingTime[1],aiParams.stopAfterWalkingTime[2])
                    self.GuardStill = true
                    self.walked = false
                    if debugMarek then Game:Print("test czy nie patrzy sie w sciane") end
                    --
                    local cx,cy,cz = actor._groundx,actor._groundy + actor._SphereSize*6, actor._groundz

                    local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
                    v:Normalize()

                    local length = actor._SphereSize*4
                    local fx = v.X*length + cx
                    local fy = v.Y*length + cy
                    local fz = v.Z*length + cz

					if debugMarek then
						actor.yadebug1,actor.yadebug2,actor.yadebug3 = fx,fy,fz
						actor.yadebug4,actor.yadebug5,actor.yadebug6 = cx,cy,cz
					end
					
                    local b,d = WORLD.LineTraceFixedGeom(cx,cy,cz,fx,fy,fz)
                    if d then
                        actor:RotateWithAnim(math.random(100, 260))
                        if debugMarek then Game:Print("to still: sciana!!!!!!!!!!!!!") end
                    else
                        if debugMarek then Game:Print("to still: no sciana") end
                    end
                    --
                    return
                else
                    if math.random(100) < 25 and self.lastAmbient + 1.0 < brain._currentTime then
						self.lastAmbient = brain._currentTime

						local tabl = aiParams.actions
						local total = 0
						for i,v in tabl do
							total = total + v[2]
						end

						local rnd = FRand(total)
						total = 0
						for i,v in tabl do
							total = total + v[2]
							if total >= rnd then
								self._submode = v[1]
								break
							end
						end

						if debugMarek then Game:Print(" () losowansko2 "..self._submode) end
						if self._submode ~= "idle" then
							-- dodac delay zeby za czesto idle anim sie nie odpalaly
							brain._submode = self._submode
							return
						end
					end

                    brain._walkStepLocal = brain._walkStepLocal * 1.1
                    if brain._walkStepLocal > aiParams.walkStep then
                        brain._walkStepLocal = aiParams.walkStep
                    end

                    local maxDist
                    
                    local movement = FRand(brain._walkStepLocal, brain._walkStepLocal * 2)
                    local ang = FRand(-30,30)

                    --[[local b,d = actor:Trace(movement + actor._SphereSize, ang)
                    if b then
						Game:Print("trace w bok? "..d)
                        ang = math.random(45,60)
                        local b = actor:Trace(movement, ang)
                        if b then
                            ang = -ang
                        end
                    end--]]
                    
                    local xd,yd,zd = actor._groundx,actor._groundy,actor._groundz
                    local angle = actor.angle + ang * math.pi/180				-- czy angle
                    local v = Vector:New(math.sin(angle), 0, math.cos(angle))
                    v:Normalize()
                    local xd2 = xd + v.X*(movement + actor._SphereSize * 3)
                    local zd2 = zd + v.Z*(movement + actor._SphereSize * 3)
                    xd = xd + v.X*movement
                    zd = zd + v.Z*movement
                    
                    local yTest = actor.StoneParams.minYwhenPFXandSound + 10

					if debugMarek then
						actor.yadebug1,actor.yadebug2,actor.yadebug3,actor.yadebug4,actor.yadebug5,actor.yadebug6 = xd,actor.StoneParams.minYwhenPFXandSound,zd,xd,actor.StoneParams.minYwhenPFXandSound - 20,zd
						actor.yaadebug1,actor.yaadebug2,actor.yaadebug3,actor.yaadebug4,actor.yaadebug5,actor.yaadebug6 = xd2,actor.StoneParams.minYwhenPFXandSound,zd2,xd2,actor.StoneParams.minYwhenPFXandSound - 20,zd2
					end

                    local b2 = WORLD.LineTraceFixedGeom(xd,actor.StoneParams.minYwhenPFXandSound,zd,xd,actor.StoneParams.minYwhenPFXandSound - 20,zd)
                    local b3 = WORLD.LineTraceFixedGeom(xd2,actor.StoneParams.minYwhenPFXandSound,zd2,xd2,actor.StoneParams.minYwhenPFXandSound - 20,zd2)
                    if b2 and b3 then
                        actor:WalkTo(xd, yd, zd, false, maxDist)
                    else
                        --Game:Print("scianaa")
                        --Game.freezeUpdate = true
                        if math.random(100) < 30 then
							if debugMarek then Game:Print("rotate po prostu") end
                            actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
                        else
							local v = Vector:New(xd2 - actor._groundx,0,zd2 - actor._groundz)
							local dist = v:Len() + actor._SphereSize * 3
							v:Normalize()
							x,y,z = VectorRotate(v.X, v.Y, v.Z, 0, 35*math.pi/180,0)

							actor.yaaadebug1,actor.yaaadebug2,actor.yaaadebug3,actor.yaaadebug4,actor.yaaadebug5,actor.yaaadebug6 = actor._groundx,yTest, actor._groundz,actor._groundx + x * dist,yTest,actor._groundz + z * dist
	                        local b = WORLD.LineTraceFixedGeom(actor._groundx,yTest, actor._groundz,actor._groundx + x * dist,yTest,actor._groundz + z * dist)
							if b then
								if debugMarek then Game:Print("scianaa 1 false") end
								x,y,z = VectorRotate(v.X, v.Y, v.Z, 0, -35*math.pi/180,0)
								actor.yaaaadebug1,actor.yaaaadebug2,actor.yaaaadebug3,actor.yaaaadebug4,actor.yaaaadebug5,actor.yaaaadebug6 = actor._groundx,yTest, actor._groundz,actor._groundx + x * dist,yTest,actor._groundz + z * dist
								local b = WORLD.LineTraceFixedGeom(actor._groundx,yTest, actor._groundz,actor._groundx + x * dist,yTest,actor._groundz + z * dist)
								if b then
									if debugMarek then Game:Print("scianaa 2 false") end
									--actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
									brain._submode = "walkToPlayerAndStrike"
								else
									actor:WalkTo(actor._groundx + x*dist, y, actor._groundz + z*dist, false, maxDist)
								end
							else
								actor:WalkTo(actor._groundx + x*dist, y, actor._groundz + z*dist, false, maxDist)
							end
                        end
                        return
                    end

                    self.walked = true
                end
            end
		end
	else
		if not actor._isRotating and not actor._isWalking then
			if self.lastAmbient + 1.0 < brain._currentTime then
				self.lastAmbient = brain._currentTime

				local tabl = aiParams.actions
				local total = 0
				for i,v in tabl do
					total = total + v[2]
				end

				local rnd = FRand(total)
				total = 0
				for i,v in tabl do
					total = total + v[2]
					if total >= rnd then
						self._submode = v[1]
						break
					end
				end

				if debugMarek then Game:Print(" () losowansko "..self._submode) end
				if self._submode ~= "idle" then
					-- dodac delay zeby za czesto idle anim sie nie odpalaly
					brain._submode = self._submode
					return
				end
			end
			--if self.delay then
			--	self.delay = self.delay - 1
			--	if self.delay <= 0 then
			--		self.delay = nil
			--	end
			--else
                actor:RotateWithAnim(math.random(-60,60))
                self.GuardStill = false
			--end
		end
	end
end

function Thor._CustomAiStates.idleThor:OnRelease(brain)
	local actor = brain._Objactor
	--if actor._state == "ANIMATING" then
	--	actor:SetIdle()
	--end
	brain._rotate180AfterEndWalking = nil
	actor.onlyWPmove = self.OLDonlyWPmove
end

function Thor._CustomAiStates.idleThor:Evaluate(brain)
	return 0.01
end



--------------------------
Thor._CustomAiStates.strikeThor = {
	name = "strikeThor",
	active = false,
}

function Thor._CustomAiStates.strikeThor:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.active = true
	self.done = nil
	actor:Stop()
	actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
	actor._angleDest = math.mod(actor._angleDest - actor.Hammer.hitAngleDisplace * math.pi/180, math.pi*2)		-- tweak
	DEBUG1g = Player._groundx
	DEBUG2g = Player._groundy
	DEBUG3g = Player._groundz
	--Game:Print("strikethor oninit")
	self.delay = 15
end

function Thor._CustomAiStates.strikeThor:OnUpdate(brain)
	if self.delay then
		if self.delay > 0 then
			self.delay = self.delay - 1
		else
			self.delay = nil
		end
		return
	end
	local actor = brain._Objactor
	if not actor._isRotating and not self.done then
		self.done = 1
		if actor._ABdone then
			actor:SetAnim("atak3", false)
		else
			local chance = 75
			if brain._distToNearestEnemy > 50 then
				chance = 65
			end
			if brain._walkedBeforeStrike or Game.Difficulty == 0 then
				chance = 101
			end

			if debugMarek then Game:Print(" STRIKE "..chance) end
			--if not actor._weaponE then
			--end
			if math.random(100) < chance or (actor._weaponE and actor._weaponE._HealthMax * 0.33 < actor._weaponE.Health) then
				actor:SetAnim("atak1", false)
			else
				--Game:Print("recharge")
				actor:SetAnim("atak2", false)
			end
		end
	end
	if not actor._isAnimating and self.done then
		self.active = nil
		if actor.eeffxx then
			ENTITY.Release(actor.eeffxx)
			actor.eeffxx = nil
		end
	end
end

function Thor._CustomAiStates.strikeThor:OnRelease(brain)
	brain._walkedBeforeStrike = nil
	self.active = nil
end

function Thor._CustomAiStates.strikeThor:Evaluate(brain)
	if self.active or brain._submode == "strike" then
		return 0.5
	end
	return 0
end


--------------------------
Thor._CustomAiStates.walkAndStrikeThor = {
	name = "walkAndStrikeThor",
	active = false,
	_lastHitByEnemyTime = -100,
	delayBetweenReactionsOnHit = 10,
}

function Thor._CustomAiStates.walkAndStrikeThor:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.distanceToPlayerStd = actor.Hammer.hitPosDisplace
	if actor._ABdone then
		self.distanceToPlayerStd = 18
	end
	actor:Stop()
	self.mode = 0
	self.active = true
	actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
end

function Thor._CustomAiStates.walkAndStrikeThor:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 then
		if not actor._isRotating then
			if brain._distToNearestEnemy > self.distanceToPlayerStd then
				if debugMarek then Game:Print("walkandstrike Far") end
				actor:WalkTo(Player._groundx,Player._groundy,Player._groundz)
				self.mode = 1
			else
				if debugMarek then Game:Print("walkandstrike close") end
				self.active = nil
				actor:WalkTo(Player._groundx,Player._groundy,Player._groundz)
				return
			end
		end
	else
		if actor._isWalking then
			if brain._distToNearestEnemy > self.distanceToPlayerStd - 3 and brain._distToNearestEnemy < self.distanceToPlayerStd + 3 then
				actor:Stop()
				if debugMarek then Game:Print("walkandstrike strike") end
				brain._submode = "strike"
				self.active = nil
			end
		else
			if math.random(100) < 75 then
				if debugMarek then Game:Print("retry walkandstrike") end
				actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
				self.mode = 0
			else
				if debugMarek then Game:Print("cancel walkandstrike") end
				actor:Stop()
				brain._walkedBeforeStrike = true
				brain._submode = "strike"
				self.active = nil
			end
		end
	end
end

function Thor._CustomAiStates.walkAndStrikeThor:OnRelease(brain)
	self.active = nil
end

function Thor._CustomAiStates.walkAndStrikeThor:Evaluate(brain)
	if brain._lastHitByEnemyPos then
		local chance = 40
		if brain._Objactor._isWalking then
			chance = 30
		end
		brain._lastHitByEnemyPos = nil
		if not self.active and math.random(100) <= chance then
			if debugMarek then Game:Print("reaction on hit?") end
			if self._lastHitByEnemyTime + self.delayBetweenReactionsOnHit < brain._currentTime then
				self._lastHitByEnemyTime = brain._currentTime
				if debugMarek then Game:Print("reaction on hit") end
				self.delayBetweenReactionsOnHit = math.random(brain._Objactor.AiParams.delayBeetweenAttack,brain._Objactor.AiParams.delayBeetweenAttack*2)	-- sec.
				return 0.4
			else
				self.delayBetweenReactionsOnHit = self.delayBetweenReactionsOnHit - 0.4
				if self.delayBetweenReactionsOnHit < 1.0 then
					self.delayBetweenReactionsOnHit = 1.0
				end
			end
		end
	end
	if self.active or brain._submode == "walkToPlayerAndStrike" then
		return 0.4
	end
	return 0
end


--------------------------
Thor._CustomAiStates.dropHammer = {
	name = "dropHammer",
	active = false,
}

function Thor._CustomAiStates.dropHammer:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	Game.MegaBossHealthMax = Thor_001.Health
	Game.MegaBossHealth = Thor_001.Health
	local j = MDL.GetJointIndex(actor._weaponE._Entity,"mlot")
	local count = 5
	for i=0,count do
		local x,y,z = MDL.TransformPointByJoint(actor._weaponE._Entity, j, i / count * 28,0,0)
		AddPFX("hammerExplosion",4.0,Vector:New(x,y,z))
	end
	local x,y,z = MDL.TransformPointByJoint(actor._weaponE._Entity, j, 0.5 * 28,0,0)
	local a = actor.lightWhenDestroy
	AddAction({a},nil,nil,x,y,z)

	GObjects:ToKill(actor._weaponE)
	actor._weaponE = nil
	
	actor.s_SubClass = Clone(actor.s_SubClass)
	actor.s_SubClass.Ambients = {"idle1_nohammer"}
	actor.s_SubClass.walk = {"walk_nohammer"}
	actor._forceWalkAnim = "walk_nohammer"
	--actor.s_SubClass.run = {"walk_nohammer"}
	--actor._runAltAnim = "walk_nohammer"

   	actor.s_SubClass.rotate45L = "rot45Lnh"
	actor.s_SubClass.rotate45R = "rot45Pnh"
	actor.s_SubClass.rotate90L = "rot90Lnh"
	actor.s_SubClass.rotate90R = "rot90Pnh"

	actor:Stop()
	actor:SetAnim("idle2_nohammer", false)
	
    ENTITY.UnregisterAllChildren(actor._Entity)
    
    self.active = true
    self.mode = 0
end

function Thor._CustomAiStates.dropHammer:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 then
		if not actor._isAnimating or actor.Animation ~= "idle2_nohammer" then
			self.mode = 1
			actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
		end
	else
		if not actor._isRotating then
			actor._ABdone = true
			self.active = false
			actor._ABdone = true
		end
	end
end

function Thor._CustomAiStates.dropHammer:Evaluate(brain)
	local actor = brain._Objactor
	if not actor._ABdone then
		if actor._weaponE and actor._weaponDied then
			return 0.9
		end
	end
	if self.active then
		return 0.9
	end
	return 0
end

--------------------------
Thor._CustomAiStates.idleAnimThor = {
	name = "idleAnimThor",
	active = false,
}

function Thor._CustomAiStates.idleAnimThor:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.done = false
	self.active = true
	actor:Stop()
	actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
	actor._angleDest = math.mod(actor._angleDest - math.random(-30,30) * math.pi/180, math.pi*2)		-- tweak
end

function Thor._CustomAiStates.idleAnimThor:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isRotating and not self.done then
		if actor.s_SubClass.Ambients then
			local animName = actor.s_SubClass.Ambients[math.random(1,table.getn(actor.s_SubClass.Ambients))]
			if actor:SetAnim(animName, false) then
				actor._state = "ANIMATING"
			end
		end
		self.done = 1
	end
	if not actor._isAnimating and self.done then
		self.active = nil
	end
end

function Thor._CustomAiStates.idleAnimThor:OnRelease(brain)
	self.active = nil
end

function Thor._CustomAiStates.idleAnimThor:Evaluate(brain)
	if self.active or brain._submode == "idleAnim" then
		return 0.3
	end
	return 0
end


-------------

function Thor:OnInitTemplate()
    self:SetAIBrain()
end

