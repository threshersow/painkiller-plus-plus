function KrustyFlying:OnInitTemplate()
    self:SetAIBrain()
    --self.disableNoAnimDetection = true
    local brain = self._AIBrain
    brain._lastThrow = 0
end

function KrustyFlying:OnCreateEntity()
	ENTITY.PO_EnableGravity(self._Entity,false)
	self._flyWithAngle = true
end


function o:OnThrow(vx,vy,vz)
	local obj = self
	self._objTakenToThrow._selfSpeed = Vector:New(vx,vy,vz)
	if obj._AIBrain.r_closestEnemy then
		self._objTakenToThrow._target = obj._AIBrain.r_closestEnemy
		--Game:Print("targt locked")
	else
		--Game:Print("targt not found")
	end
end

function o:OnFinishAnim(anim)
	if anim == "atak_fly" then
	    local brain = self._AIBrain
	    brain._lastThrow = brain._currentTime + FRand(0, 0.5)
	end
end

o._CustomAiStates = {}

o._CustomAiStates.KrustyFlyingIdle = {
	name = "KrustyFlyingIdle",
	active = false,
	flyPoints = {},
	once = false,
	lastPoint = nil,
    timer = 0,
}

function o._CustomAiStates.KrustyFlyingIdle:OnInit(brain)			-- dodac delay pomiedzy atakami
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	self._notMoving = 0
end

function o._CustomAiStates.KrustyFlyingIdle:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	if actor.Animation == "atak_fly" and actor._isAnimating then
		return
	end

	if actor._flying or actor.NeverMove then

		if brain._seeEnemy and brain._distToNearestEnemy < aiParams.throwRangeMax and brain._distToNearestEnemy > aiParams.throwRangeMin then
			if brain._lastThrow + aiParams.minDelayBetweenThrow < brain._currentTime then
				local angle = actor.angle
				local v = Vector:New(brain.r_closestEnemy._groundx - actor._groundx, 0, brain.r_closestEnemy._groundz - actor._groundz)
				v:Normalize()
				local angleToPlayer = math.atan2(v.X, v.Z)
				local aDist = AngDist(angle, angleToPlayer)
				--Game:Print("aDist = "..aDist)
				if math.abs(aDist) < aiParams.throwMaxAngleYawDiff * 3.14/180 then
					--Game:Print("fireball")
					 actor:Stop()
					actor:RotateToVector(brain.r_closestEnemy._groundx,0,brain.r_closestEnemy._groundz)
					actor:SetAnim("atak_fly",false)
					--actor:FlyTo(enemy?, nil, "atak_fly")
					
					brain._lastThrow = brain._currentTime + FRand(0, 0.5)
					return
				else
					--[[if brain._distToNearestEnemy < aiParams.throwRangeMax * 0.5 then
						Game:Print("rotate to")
						actor:Stop()
						actor:RotateToVector(brain.r_closestEnemy._groundx,0,brain.r_closestEnemy._groundz)
					end--]]
				end

				
			end
		end

		local zakres = actor._SphereSize * 0.6

		local rnd1 = FRand(-zakres, zakres)
		local rnd2 = FRand(-zakres, zakres)
		local rnd3 = FRand(-zakres, zakres)
		local v = Vector:New(0,0,0)
		local v2 = Vector:New(0,1,0)

		if self._lastPos then
			v2 = Vector:New(self._lastPos.X - actor.Pos.X,self._lastPos.Y - actor.Pos.Y,self._lastPos.Z - actor.Pos.Z)
				
			
			--Game:Print(brain._velocity)
			--if v:Len() < 0.05 then
			v = Vector:New(math.sin(actor._angleDest), 0, math.cos(actor._angleDest))
			--end
			v:Normalize()
						
			local zakres = actor._SphereSize * 0.6
			if debugMarek then
				DEBUG1,DEBUG2,DEBUG3 = actor.Pos.X+rnd1,actor.Pos.Y+rnd2,actor.Pos.Z+rnd3
				DEBUG4,DEBUG5,DEBUG6 = actor.Pos.X+rnd1+v.X*3.0,actor.Pos.Y+rnd2+v.Y*3.0,actor.Pos.Z+rnd3+v.Z*3.0
			end

		end
		self._lastPos = Clone(actor.Pos)
		

		if actor.NeverMove and brain.r_closestEnemy and math.random(100) < 5 then
			actor:RotateToVector(brain.r_closestEnemy._groundx,0,brain.r_closestEnemy._groundz)
		end
		

		self.timer = self.timer - 1
		if self.timer < 0 and not actor.NeverMove then
			--Game:Print(v2:Len())
			if true then
				self.timer = aiParams.traceSpeed1
		
				ENTITY.RemoveRagdollFromIntersectionSolver(actor._Entity)
				--[[local v = Vector:New(brain._velocityx, brain._velocityy, brain._velocityz)
				if brain._velocity < 0.05 then
					local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
					Game:Print(actor._Name.."too little vel "..brain._velocity)
				end
				v:Normalize()
							
				local zakres = actor._SphereSize * 0.6
				local rnd1 = 0--FRand(-zakres, zakres)
				local rnd2 = 0--FRand(-zakres, zakres)
				local rnd3 = 0--FRand(-zakres, zakres)
				if debugMarek then
					DEBUG1,DEBUG2,DEBUG3 = actor.Pos.X+rnd1,actor.Pos.Y+rnd2,actor.Pos.Z+rnd3
					DEBUG4,DEBUG5,DEBUG6 = actor.Pos.X+rnd1+v.X*3.0,actor.Pos.Y+rnd2+v.Y*3.0,actor.Pos.Z+rnd3+v.Z*3.0
				end--]]

				local b,d,x,y,z,nx,ny,nz = WORLD.LineTrace(actor._groundx+rnd1,actor.Pos.Y+rnd2,actor._groundz+rnd3,
					actor._groundx+rnd1+v.X*3.0, actor.Pos.Y+rnd2+v.Y*3.0, actor._groundz+rnd3+v.Z*3.0)
				if d then
					if debugMarek then
						DEBUG10,DEBUG11,DEBUG12 = x,y,z
						DEBUG13,DEBUG14,DEBUG15 = x+nx,y+ny,z+nz
					end
					local mul = FRand(2.0, 2.2)
					if math.random(100) < 50 then
						--Game:Print("col normal")			-- not SURE czy potrzebne
						actor:FlyTo(x + nx*mul,y + ny*mul ,z + nz*mul, nil,nil,nil, 20)
					else
						--Game:Print("col revese")
						actor:FlyForward(-mul*FRand(1,2), FRand(-30,30), FRand(-2,2),nil,true)
						--actor.AIenabled = false
						--self._disableColCheck = true
						--Game.freezeUpdate = true
						return
					end
				--else
					--Game:Print("no col")
				end
			end
			if v2:Len() < 0.01 and not actor.NeverMove  then
				self._notMoving = self._notMoving + 1
				--Game:Print("not moving? "..self._notMoving)
				if self._notMoving == 4 then
					--Game:Print("zaklinowal sie")
					actor:Stop()
				end
			else
				self._notMoving = 0
			end
			ENTITY.AddRagdollToIntersectionSolver(actor._Entity)
		end
	else
	
		self._notMoving = 0
		self.timer = -1
	
		if brain._distToNearestEnemy > 40 then

			--Game:Print("flyto > 40")
			local heig = 0
			-- heig max wys. az jest przejscie, ale nie duzo wyzej niz jest kolo, i nie nizej niz wp. ?
			
			-- przyspieszanie, gdy daleko
			if brain._distToNearestEnemy > 60 then
				actor._randomizedParams.FlySpeed = FRand(actor.FlySpeed * 2, actor.FlySpeed * 3)
			else
				actor._randomizedParams.FlySpeed = FRand(actor.FlySpeed * 1, actor.FlySpeed * 2)
			end
			
			--Game:Print("fs="..actor._randomizedParams.FlySpeed)
			actor:FlyTo(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y + heig, brain._enemyLastSeenPoint.Z, nil,nil,nil, 30)
			-- +dodatkowo velocity gracza
			-- w flyto nie ma limitu max. dist
			
			self.flyrandcnt = 0
		else

			actor._randomizedParams.FlySpeed = FRand(actor.FlySpeed * 0.9, actor.FlySpeed * 1.1)
			--Game:Print("fs="..actor._randomizedParams.FlySpeed)
			if brain._seeEnemy then
				--Game:Print("flyto < 40 zee")
				actor:FlyTo(brain._enemyLastSeenPoint.X + FRand(-12,12), brain._enemyLastSeenPoint.Y + FRand(-1,5), brain._enemyLastSeenPoint.Z + FRand(-12,12), nil,nil,nil, 30)
			else
				--Game:Print("flyto < 40")
				actor:FlyTo(brain._enemyLastSeenPoint.X + FRand(-8,8), brain._enemyLastSeenPoint.Y + FRand(-1,2), brain._enemyLastSeenPoint.Z + FRand(-8,8), nil,nil,nil, 30)
			end
		
--[[			-- random fly
			local dist = FRand(aiParams.walkStep * 0.7, aiParams.walkStep * 1.0)
			local xd,yd,zd = actor._groundx,actor._groundy,actor._groundz
			local y = FRand(-aiParams.flyDown, aiParams.flyUp)
			yd = yd + y
			--Game:Print("$ next fly = "..y.." "..aiParams.flyDown.." "..aiParams.flyUp)
			self.stFly = false

			
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

			actor:FlyTo(xd + v.X*dist, yd, zd + v.Z*dist)
			if self.stFly then
				MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, FRand(2.6, 2.8))
			else
				MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, actor.s_SubClass.Animations[actor.Animation][1])
			end
			self.dest = nil
			self.flyrandcnt = self.flyrandcnt - 0.05--]]

		end
	end
end


function o._CustomAiStates.KrustyFlyingIdle:Evaluate(brain)
	return 0.01
end
