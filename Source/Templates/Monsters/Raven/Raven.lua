function Raven:OnInitTemplate()
    self:SetAIBrain()
end

function Raven:OnCreateEntity()
    --ENTITY.PO_EnableGravity(self._Entity,false)
	self._flyWithAngle = true
end

function o:CustomUpdate()
	if self.TimeToLive then
		self.TimeToLive = self.TimeToLive - 1
		if self.TimeToLive < 0 then
			self.TimeToLive = nil
			self:OnDamage(self.Health + 2, self)
		end
	end
end


--------------------------

o._CustomAiStates = {}

o._CustomAiStates.Ravenhear = {
	name = "Ravenhear",
	active = false,
	lastTimeHEAR = -100,
}

function o._CustomAiStates.Ravenhear:OnInit(brain)
	self.lastTimeHEAR = brain._currentTime
end

function o._CustomAiStates.Ravenhear:Evaluate(brain)
	local actor = brain._Objactor
	if not actor._isWalking then
		if self.lastTimeHEAR + 0.4 < brain._currentTime and table.getn(ActiveSounds) > 0 then
			local aiParams = actor.AiParams
			local soundOfHiPrio = nil
			for i,v in ActiveSounds do
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
			end
			if soundOfHiPrio then
				self.lastTimeFIRE = brain._currentTime
				--if debugMarek then Game:Print("Raven heard : "..soundOfHiPrio[1]) end
				actor:Stop()
				
				local dist = Dist3D(soundOfHiPrio[4], soundOfHiPrio[5], soundOfHiPrio[6], actor._groundx, actor._groundy, actor._groundz)
				if soundOfHiPrio[2] == LogicSounds.STEP and dist > aiParams.distIgnoreSteps then
					--Game:Print("HEARD step")
					actor:RotateToVector(soundOfHiPrio[4], soundOfHiPrio[5], soundOfHiPrio[6])
				else
					--Game:Print("HEARD")
					brain._escape = true
					brain._escapeSrc = Vector:New(soundOfHiPrio[4], soundOfHiPrio[5], soundOfHiPrio[6])
				end
				return 0.2
			end
		end
	end
	return 0.0
end




--------------------------
o._CustomAiStates.RavenIdle = {
	name = "RavenIdle",
	active = false,
	flyPoints = {},
	once = false,
	lastPoint = nil,
}

function o._CustomAiStates.RavenIdle:OnInit(brain)			-- dodac delay pomiedzy atakami
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	-- pobranie punktow w najblizszej okolicy (once)
	if not self.once then
		if aiParams.escapeAfterCreate then
			brain._escape = true
			brain._escapeSrc = Vector:New(actor._groundx + FRand(-0.1, 0.1), actor._groundy, actor._groundz + FRand(-0.1, 0.1))
		end

		self.once = true
		if not brain._walkArea then
			if debugMarek then Game:Print("RAVEN no walkarea") end
		else
			for i,v in brain._walkArea.Points do
				local dist = Dist3D(v.X, v.Y, v.Z, brain._GuardPos.X, brain._GuardPos.Y, brain._GuardPos.Z)
				if dist <= aiParams.guardRange then
					table.insert(self.flyPoints, v)
				end
			end
			if debugMarek then Game:Print("Raven found points: "..table.getn(self.flyPoints)) end
		end
	end
	if brain._escape then
		actor:RotateToVector(brain._escapeSrc.X, brain._escapeSrc.Y, brain._escapeSrc.Z)		-- + random
		actor._angleDest = math.mod(actor._angleDest + math.random(160, 200) * math.pi/180, math.pi*2)
		self.state = 0
		brain._escape = false
	else
		self.state = 3
	end
	self.stFly = true
	self.dest = nil
	self.flyrandcnt = 0
	self.timer = 0
	self.timer2 = 0
	self.landing = false
	self._noland = nil
end

function o._CustomAiStates.RavenIdle:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if actor._flying then
	--if actor._isWalking then
		self.timer = self.timer - 1
		if self.timer < 0 then
			self.timer = aiParams.traceSpeed1
	
			ENTITY.RemoveRagdollFromIntersectionSolver(actor._Entity)
			local v = Vector:New(brain._velocityx, brain._velocityy, brain._velocityz)
			if brain._velocity < 0.05 then
				local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
				Game:Print(actor._Name.."too little vel "..brain._velocity)
			end
			v:Normalize()
						
			local zakres = actor._SphereSize * 0.55
			local rnd1 = FRand(-zakres, zakres)
			local rnd2 = FRand(-zakres, zakres)
			local rnd3 = FRand(-zakres, zakres)
			if debugMarek then
				DEBUG1,DEBUG2,DEBUG3 = actor.Pos.X+rnd1,actor.Pos.Y+rnd2,actor.Pos.Z+rnd3
				DEBUG4,DEBUG5,DEBUG6 = actor.Pos.X+rnd1+v.X*3.0,actor.Pos.Y+rnd2+v.Y*3.0,actor.Pos.Z+rnd3+v.Z*3.0
				DEBUG7,DEBUG8,DEBUG9 = actor.Pos.X+v.X*6.0+rnd1,actor.Pos.Y-2.0+rnd2,actor.Pos.Z+v.Z*6.0+rnd3
			end

			local b,d,x,y,z,nx,ny,nz = WORLD.LineTrace(actor._groundx+rnd1,actor.Pos.Y+rnd2,actor._groundz+rnd3,
				 actor._groundx+rnd1+v.X*3.4, actor.Pos.Y+rnd2+v.Y*3.4, actor._groundz+rnd3+v.Z*3.4)
			if d then
				if debugMarek then
					DEBUG10,DEBUG11,DEBUG12 = x,y,z
					DEBUG13,DEBUG14,DEBUG15 = x+nx,y+ny,z+nz
				end
				-- trace w dol
				local b2,d2--[[,x2,y2,z2,nx2,ny2,nz2,e--]] = WORLD.LineTrace(actor._groundx, actor._groundy + 0.01, actor._groundz, actor._groundx, actor._groundy - 2.0, actor._groundz)	-- moze nie co update?
				if d2 and not self.stFly then
					--if e then		-- zeby nie siadaly jeden na drugim
					--	local obj = EntityToObject[e]
					--	if obj and obj._AIBrain then
					--	end
					--end
					self.landing = true
					--Game:Print(actor._Name.." landing")
					actor:SetIdle()
					self.flyrandcnt = 0
					--self.timer2 = 0
				else
					if not self.landing then
						--Game:Print(actor._Name.." fly reverse")
						local mul = FRand(2.0, 2.2)
						actor:FlyTo(x + nx*mul,y + ny*mul ,z + nz*mul)
					end
				end
			else
				if not self.dest and not self.stFly then
					local b,d,x,y,z,nx,ny,nz = WORLD.LineTrace(actor._groundx+rnd1,actor.Pos.Y+rnd2,actor._groundz+rnd3, actor._groundx+v.X*6.0+rnd1,actor.Pos.Y-2.0+rnd2,actor._groundz+v.Z*6.0+rnd3)
					if b and ny > 0.9 then
						--Game:Print("plaskie podloze - land")
						actor:FlyTo(x,y,z)
						self.dest = Vector:New(x,y,z)
						self.flyrandcnt = 0
						self.stFly = true
						self.landing = true
					end
				end
			end
			ENTITY.AddRagdollToIntersectionSolver(actor._Entity)
			if self.dest --[[and brain._velocityy < 0--]] and not self._noland then
				local dist = Dist3D(self.dest.X, self.dest.Y, self.dest.Z, actor._groundx, actor._groundy, actor._groundz)
				if dist < 4 then
					--Game:Print("Setanim FLY_IDLE")
					MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, FRand(2.6, 2.8))
					--actor:ForceAnim("fly", true, FRand(2.6, 2.7))
					self._noland = true
				end
			end
		end
	else
		self._noland = nil
		self.landing = false
		if self.state == 2 then
			self.dest = nil
			self.state = 3
			self.timer2 = -1
		end
		if self.state == 3 then
			self.timer2 = self.timer2 - 1
			if self.timer2 < 0 then
				self.timer2 = aiParams.traceSpeed2

				ENTITY.RemoveRagdollFromIntersectionSolver(actor._Entity)
				if debugMarek then
					DEBUG1,DEBUG2,DEBUG3 = actor._groundx, actor._groundy + 0.01, actor._groundz
					DEBUG4,DEBUG5,DEBUG6 = actor._groundx, actor._groundy - 1.2, actor._groundz
					DEBUG7,DEBUG8,DEBUG9 = actor._groundx, actor._groundy - 1.2, actor._groundz
				end
				local b,d,x,y,z = WORLD.LineTrace(actor._groundx, actor._groundy + 0.01, actor._groundz, actor._groundx, actor._groundy - 1.2, actor._groundz)	-- moze nie co update?
				if b then
					if actor.Animation == "fly" or actor.Animation == "fly_idle" then
						actor:SetIdle()
						--Game:Print("ladowanie")
						ENTITY.AddRagdollToIntersectionSolver(actor._Entity)
						return
					end
					if not actor._isRotating and not actor._isWalking then
						if math.random(100) < 20 then
							local distToPlayer = Dist3D(actor._groundx,actor._groundy,actor._groundz,Player._groundx,Player._groundy,Player._groundz)
							if (distToPlayer < aiParams.distWhenAlwaysEscape) then
								self.state = 0
								--Game:Print("gracz za blisko")
								return
							end
						end
						if math.random(1000) < 40 then
							if math.random(100) < 30 then
								actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
							else
								actor:Rotate(math.random(-15,15))
							end
						end
						if math.random(1000) < aiParams.ambientAnimationFreq * 1000 and actor._state ~= "ANIMATING" then
							if actor.s_SubClass.Ambients then
								local animName = actor.s_SubClass.Ambients[math.random(1,table.getn(actor.s_SubClass.Ambients))]
								--Game:Print("set ambient "..animName)
								if actor:SetAnim(animName, false) then
									actor._state = "ANIMATING"
								end
							end
						end
						if actor._state ~= "ANIMATING" and math.random(1000) < aiParams.walkOnTheGroundFreq * 1000 then
							local angleDiff = FRand(-40,40) * math.pi/180
							local angle = math.mod(actor.angle + angleDiff, math.pi * 2)
							local v = Vector:New(math.sin(angle), 0, math.cos(angle))
							v:Normalize()
							v:MulByFloat(FRand(1.0, 2.2))
							--Game:Print("want walk")
							local b,d,x,y,z = WORLD.LineTrace(actor._groundx + v.X, actor._groundy + 0.5, actor._groundz + v.Z, actor._groundx + v.X, actor._groundy - 0.5, actor._groundz + v.Z)
							if debugMarek then
								--actor.d1,actor.d2,actor.d3,actor.d4,actor.d5,actor.d6 = actor._groundx + v.X, actor._groundy + 0.5, actor._groundz + v.Z, actor._groundx + v.X, actor._groundy - 0.5, actor._groundz + v.Z
							end
							if b then
								local b,d,x,y,z = WORLD.LineTrace(actor._groundx, actor._groundy + actor._SphereSize*0.5, actor._groundz, actor._groundx + v.X, actor._groundy + actor._SphereSize*0.5, actor._groundz + v.Z)
								if debugMarek then
									--Game:Print(actor._Name.."wiec walk?")
									actor.d1,actor.d2,actor.d3,actor.d4,actor.d5,actor.d6 = actor._groundx, actor._groundy + actor._SphereSize*0.5, actor._groundz, actor._groundx + v.X, actor._groundy + actor._SphereSize*0.5, actor._groundz + v.Z
								end
								if not b then
									actor:WalkTo(actor._groundx + v.X, actor._groundy + v.Y, actor._groundz + v.Z)
								else
									--Game:Print(actor._Name.."niestety sciana")
								end
							else
								--Game:Print(actor._Name.."nie rowny grunt?")
							end
						end
					end
				else
					--Game:Print("spada?")
					self.state = 0
				end
				ENTITY.AddRagdollToIntersectionSolver(actor._Entity)
			end
			--return
		end
		
		if self.state == 0 then
			local dist = aiParams.guardRange
			self.dest = nil
			--local p = 1
			local dist = Dist3D(actor._groundx,actor._groundy,actor._groundz, brain._GuardPos.X, brain._GuardPos.Y, brain._GuardPos.Z)
			if dist > aiParams.guardRange then
				--Game:Print("max range")
				actor:Rotate(math.random(60, 100))
			end
			if FRand(0.0, 1.0) < aiParams.flyFactor - self.flyrandcnt then
				for i,v in self.flyPoints do
					local v2 = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
       				v2:Normalize()

					local x = v.X - v2.X
					local y = v.Y
					local z = v.Z - v2.Z
					local distToTarget = Dist3D(v.X, v.Y, v.Z, actor._groundx,actor._groundy,actor._groundz)
					local distToTargetBack = Dist3D(x,y,z, actor._groundx,actor._groundy,actor._groundz)
					if distToTargetBack < distToTarget then		-- sprawdzanie, czy punkt lezy przedemna
						local d = Dist3D(v.X, v.Y, v.Z, actor._groundx, actor._groundy, actor._groundz)
						if d < dist and d > 1 then
							dist = d
							self.dest = v
						end
					end
				end
			end

			if self.dest then
				--Game:Print("fly to point")
				actor:FlyTo(self.dest.X, self.dest.Y + 0.5, self.dest.Z)
				self.flyrandcnt = 0
			else
				-- random fly
				--Game:Print("random fly "..self.flyrandcnt)
				local dist = FRand(aiParams.walkStep * 0.7, aiParams.walkStep * 1.0)
				local xd,yd,zd = actor._groundx,actor._groundy,actor._groundz
				if self.flyrandcnt == 0 then
					--Game:Print("1st fly")
					PlaySound3D("actor/raven/raven_wings_flap",actor._groundx,actor._groundy,actor._groundz,10,math.random(20,26))
					actor:AddPFX('but', actor._SphereSize * 0.6, Vector:New(actor._groundx,actor._groundy,actor._groundz))
					dist = FRand(aiParams.walkStep * 0.3, aiParams.walkStep * 0.7)
					yd = yd + dist * 1.5
					self.stFly = true
					self.timer = 0
				else
					local y = FRand(-aiParams.flyDown, aiParams.flyUp)
					yd = yd + y
					--Game:Print("$ next fly = "..y.." "..aiParams.flyDown.." "..aiParams.flyUp)
					self.stFly = false
				end
				
				local angle = actor.angle + FRand(-14,46) * math.pi/180
				--Game:Print("angle = "..(angle * 180/math.pi).." old actor._angleDest "..(actor._angleDest * 180/math.pi))
				local v = Vector:New(math.sin(angle), 0, math.cos(angle))
				v:Normalize()
				-- tutaj trace?
				if aiParams.guardRange > 0 then
					local dist = Dist3D(brain._GuardPos.X, brain._GuardPos.Y, brain._GuardPos.Z, xd + v.X*dist, yd, zd + v.Z*dist)
					if dist > aiParams.guardRange then
						dist = 0
						xd = brain._GuardPos.X + FRand(-2,2)
						yd = brain._GuardPos.Y + FRand(0,2)		-- moze tutaj trace w dol az trafienie w mesha
						if aiParams.guardRangeCalcFloor then
							local b,d,x,y,z,nx,ny,nz = WORLD.LineTrace(xd,yd,zd, xd,yd - 60,zd)
							if y then
								yd = y + FRand(2,5)
							end
						end
						zd = brain._GuardPos.Z + FRand(-2,2)
					end
				end

				--[[if math.random(100) < 100 then
					local r = 0.25
					actor._randomizedParams.FlySpeed = FRand(actor.FlySpeed * (1 - r), actor.FlySpeed * (1 + r))
					Game:Print("randomize speed = "..actor._randomizedParams.FlySpeed)
				end--]]
				actor:FlyTo(xd + v.X*dist, yd, zd + v.Z*dist)
				if self.stFly then
					MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, FRand(2.6, 2.8))
				else
					MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, actor.s_SubClass.Animations[actor.Animation][1])
				end
				self.dest = nil
				self.flyrandcnt = self.flyrandcnt - 0.05

			end
			self.state = 2
			self.state2time = brain._currentTime
			--return
		end
	end
end


function o._CustomAiStates.RavenIdle:Evaluate(brain)
	return 0.01
end
