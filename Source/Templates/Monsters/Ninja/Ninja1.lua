function Ninja1:OnInitTemplate()
    self:SetAIBrain()
end

function Ninja1:CustomOnDeath()
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end


function Ninja1:Throw()
	if self._AIBrain and self._AIBrain._enemyLastSeenTime > 0 then
		local aiParams = self.AiParams
		local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))
		self.Joint = MDL.GetJointIndex(self._Entity, aiParams.holdJoint)
	    local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,aiParams.holdJointDisplace.X,aiParams.holdJointDisplace.Y, aiParams.holdJointDisplace.Z)

		obj.ObjOwner = self
		obj.Pos.X = x
		obj.Pos.Y = y
		obj.Pos.Z = z

		local v = Vector:New(Player._groundx - x, 0, Player._groundz - z)
		v:Normalize()
		
		local angleToPlayer = math.atan2(v.X, v.Z)
		
		local aDist = AngDist(self.angle, angleToPlayer)
		--Game:Print("dist Angles = "..(aDist*180/3.14))
		if math.abs(aDist) > 30 * 3.14/180 then
			--Game:Print("z orienacji")
			v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
			v:Normalize()
		end

		self:BindFX("fire")

		local distToPlayer = Dist3D(x,0,z, Player._groundx, 0, Player._groundz)
		v.X = v.X * distToPlayer
		v.Y = v.Y * distToPlayer
		v.Z = v.Z * distToPlayer

        obj.PosDest = {}
        obj.PosDest.X = v.X + x
        obj.PosDest.Z = v.Z + z
		obj.PosDest.Y = Player._groundy + 1.7
		
		obj.Rot:FromEuler( 0, -self.angle, 0)
		
		obj._RotAngle = self.angle
		obj:Apply()

		obj:Synchronize()
		--self._AIBrain._AxethrowedRight = true
		
	end
end

----------------------------
o._CustomAiStates = {}
o._CustomAiStates.ninjaTeleport = {
	name = "ninjaTeleport",
	_lastTimeTeleport = 0,
}

function o._CustomAiStates.ninjaTeleport:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	self.state = 0

	self._oldspeed = actor._randomizedParams.RotateSpeed
	actor.onlyWPmove = true
	actor._randomizedParams.RotateSpeed = actor._randomizedParams.RotateSpeed * 6
	self.destx = nil
	self.destx2 = nil
	self.destx3 = nil
	-- losowanie punktu z boku gracza
	if debugMarek then
		Game:Print(actor._Name.." teleport INIT")
		--Game.freezeUpdate = true
	end
	local enemy = brain.r_closestEnemy
    if enemy then
		self._lastTimeTeleport = brain._currentTime
		actor._overrideMovingCurve = aiParams.teleportSpeed

        -- TODO:obliczanie najktr. sciezki
		-- TODO:sciezki i widocznosci...
		local sign = 1
		if math.random(100) < 50 then
			sign = -1
		end

		local done = false
		local maxCount = 4
        if debugMarek then
            actor.DDEB = {}
        end
		while not done do
			--Game:Print("trying "..maxCount)
			local angle = FRand(75 * math.pi/180, 100 * math.pi/180) * sign
			local v = Vector:New(math.sin(enemy.angle - angle), 0, math.cos(enemy.angle - angle))		-- pozniej troche random
			v:Normalize()

   			local d = FRand(5.5,6.6)
			self.destx = enemy._groundx + v.X * d
			self.desty = enemy._groundy
			self.destz = enemy._groundz + v.Z * d

			--Game:Print("roznica "..(Dist3D(self.destx, self.desty, self.destz, enemy._groundx, enemy._groundy, enemy._groundz)))

			local angle = FRand(100 * math.pi/180, 175 * math.pi/180) * sign		-- pozniej nie od 100, ale od poprzedniego angle?
			local v2 = Vector:New(math.sin(enemy.angle - angle), 0, math.cos(enemy.angle - angle))		-- pozniej troche random
			v2:Normalize()
	       
			d = FRand(4.5,5.5)
			self.destx2 = enemy._groundx + v2.X * d
			self.desty2 = enemy._groundy
			self.destz2 = enemy._groundz + v2.Z * d
			--Game.freezeUpdate = true
            if debugMarek then
                table.insert(actor.DDEB, {self.destx2,self.desty2+1,self.destz2,enemy._groundx,enemy._groundy+1,enemy._groundz})
            end
			
			local b,d = WORLD.LineTraceFixedGeom(self.destx2, self.desty2+1, self.destz2, enemy._groundx, enemy._groundy+1, enemy._groundz)
			if not d then
				done = true
				--Game:Print("ok.")
			else
				sign = -sign
				maxCount = maxCount - 1
				if maxCount < 0 then
					done = true
					--Game:Print("failed..")
				end
			end
		end
		
		if maxCount >= 0 then
		
			local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(self.destx, self.desty+2.8, self.destz, actor._groundx,actor._groundy+2.8,actor._groundz)
			if b then
				if debugMarek then 
					local obj = EntityToObject[e]
					Game:Print(actor._Name.." col1")
					if obj then
						Game:Print(actor._Name.." col1 "..obj._Name)
					end
				end
				return
			end
		
			actor:WalkTo(self.destx, self.desty, self.destz, true)
			actor:PlaySound("sprint")
			actor:PlaySound("shuri")
			--Game:Print(actor._Name.." teleport")
			self.active = true
			--[[if debugMarek then
				actor.DEBUGl4 = self.destx
				actor.DEBUGl5 = self.desty
				actor.DEBUGl6 = self.destz
				actor.DEBUGl7 = self.destx2
				actor.DEBUGl8 = self.desty2
				actor.DEBUGl9 = self.destz2
				actor.d1,actor.d2,actor.d3 = self.destx, self.desty+2.8, self.destz
				actor.d4,actor.d5,actor.d6 = actor._groundx,actor._groundy+2.8,actor._groundz
			end--]]

			-- 
			local v = Vector:New(self.destx2 - enemy._groundx, self.desty2 - enemy._groundy, self.destz2 - enemy._groundz)
			v:Normalize()
			v.X = v.X * 3
			v.Y = v.Y * 3
			v.Z = v.Z * 3
			self.destx3 = enemy._groundx + v.X
			self.desty3 = enemy._groundy + v.Y
			self.destz3 = enemy._groundz + v.Z
			if debugMarek then
				actor.DEBUGl1 = self.destx3
				actor.DEBUGl2 = self.desty3
				actor.DEBUGl3 = self.destz3
			end

			local tdj = actor.s_SubClass.DeathJoints
			if tdj then
				local size = actor._SphereSize * 0.3
				for i=1,table.getn(tdj) do
					actor:BindFX(aiParams.teleportPFX, 0.1, tdj[i])
				end
			end
			--if debugMarek then WORLD.SetWorldSpeed(1/10) end
		end
    end
end

function o._CustomAiStates.ninjaTeleport:OnUpdate(brain)
    local actor = brain._Objactor
	local aiParams = actor.AiParams
	self._lastTimeTeleport = brain._currentTime
	if self.state < 3 then
		actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
	end
    if self.state == 0 then
		if not actor._isWalking then
			-- TODO:obliczanie najktr. sciezki
			if debugMarek then
				actor.DEBUGl4 = self.destx2
				actor.DEBUGl5 = self.desty2
				actor.DEBUGl6 = self.destz2
			end

			local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(self.destx2, self.desty2+2.8, self.destz2, actor._groundx,actor._groundy+2.8,actor._groundz)
			if not b then
				actor:WalkTo(self.destx2, self.desty2, self.destz2, true)	
			else
				if debugMarek then 
					local obj = EntityToObject[e]
					Game:Print(actor._Name.." col2")
					if obj then
						Game:Print(actor._Name.." col2 "..obj._Name)
					end
					--Game.freezeUpdate = true
				end
			end
			
			self.state = 1
			--Game.freezeUpdate = true
		end
	end

    if self.state == 1 then
		if not actor._isWalking then
			if self.destx3 then
				actor:WalkTo(self.destx3, self.desty3, self.destz3, true)
			end
			self.state = 2
		else
			if brain.r_closestEnemy then
				local dist = Dist3D(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz, actor._groundx, actor._groundy, actor._groundz)
				if dist < aiParams.attackRange * 0.6 then
					--Game:Print(actor._Name.." walk2: za blisko playera")
					--Game.freezeUpdate = true
					self.state = 2
				end	
			end
		end
    end
    
    if self.state == 2 then
        if brain.r_closestEnemy then
			if debugMarek then
				actor.DEBUGl4 = brain.r_closestEnemy._groundx
				actor.DEBUGl5 = brain.r_closestEnemy._groundy
				actor.DEBUGl6 = brain.r_closestEnemy._groundz
				actor.DEBUGl7 = actor._groundx
				actor.DEBUGl8 = actor._groundy
				actor.DEBUGl9 = actor._groundz
			end

			local dist = Dist3D(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz, actor._groundx, actor._groundy, actor._groundz)
			if dist < aiParams.attackRange * 0.6  then
				ENTITY.SetVelocity(actor._Entity, 0,0,0)
				ENTITY.UnregisterAllChildren(actor._Entity, ETypes.ParticleFX)
				actor:Stop()
				actor:RotateToVector(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz)
				
				--Game:Print(actor._Name.." teleport anim "..(Dist3D(Player._groundx,Player._groundy,Player._groundz,actor._groundx,actor._groundy,actor._groundz)))
				self.state = 3
				return
			end
		end
        if not actor._isWalking then
            if brain.r_closestEnemy then
                local dist = Dist3D(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz, actor._groundx, actor._groundy, actor._groundz)
                if dist < aiParams.attackRange then
                    ENTITY.SetVelocity(actor._Entity, 0,0,0)
                    ENTITY.UnregisterAllChildren(actor._Entity, ETypes.ParticleFX)
                    actor:Stop()
                    actor:RotateToVector(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz)
                    --Game:Print(actor._Name.." teleport anim "..(Dist3D(Player._groundx,Player._groundy,Player._groundz,actor._groundx,actor._groundy,actor._groundz)))
                    self.state = 3
                    return
                end
            end
            self.active = false
            --Game:Print(actor._Name.." teleport FAILED "..(Dist3D(Player._groundx,Player._groundy,Player._groundz,actor._groundx,actor._groundy,actor._groundz)))
            return
        end
	end
    if self.state == 3 then
		if not actor._isRotating then
            if brain.r_closestEnemy and brain._distToNearestEnemy < aiParams.attackRange * 1.3 then
                actor:RotateToVector(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz)
            else
                --Game:Print(actor._Name.." teleport FAILED2 nie widzi wroga ")
                self.active = false
                return
            end
            actor:SetAnim("atak_hit",false)
			self.state = 4
    	end
    end
    if self.state == 4 then
        if not actor._isAnimating or actor.Animation ~= "atak_hit" then
            self.active = false
            --Game:Print(actor._Name.." teleport end")
		end
    end
end

function o._CustomAiStates.ninjaTeleport:OnRelease(brain)
    local actor = brain._Objactor
	actor._overrideMovingCurve = nil
	ENTITY.UnregisterAllChildren(actor._Entity, ETypes.ParticleFX)
	actor.onlyWPmove = false
	actor._randomizedParams.RotateSpeed = self._oldspeed
end

function o._CustomAiStates.ninjaTeleport:Evaluate(brain)
	if self.active then
		return 0.8
	end
	if brain.r_closestEnemy then
        local actor = brain._Objactor
        local aiParams = actor.AiParams
		if math.random(100) < 10 then
            if self._lastTimeTeleport + aiParams.minimumTimeBetweenTeleport < brain._currentTime and actor._state ~= "ATTACKING" and Player._velocity < 1 then		-- dodac random do czasu
        		local enemy = brain.r_closestEnemy
				local v2 = Vector:New(math.sin(enemy.angle), 0, math.cos(enemy.angle))
       			v2:Normalize()

				self.destx = enemy._groundx - v2.X * actor._SphereSize * 2
				self.desty = enemy._groundy + 1
				self.destz = enemy._groundz - v2.Z * actor._SphereSize * 2
				local b,d = WORLD.LineTraceFixedGeom(enemy._groundx, enemy._groundy + 1, enemy._groundz, self.destx, self.desty, self.destz)
				if not d then	
					-- czy jest miejsce za celem?
					local b,d = WORLD.LineTraceFixedGeom(self.destx, self.desty + actor._SphereSize * 3, self.destz, self.destx, self.desty - actor._SphereSize * 3, self.destz)
					if d and d > actor._SphereSize*1.5 and d < actor._SphereSize * 4.5 then
						return 0.8
					end
				end
				return 0.8
			end
		end
	end
	return 0.0
end

--[[function Ninja1:SetVelocity(par3, par4)
	local br = self._AIBrain
	if br and br.r_closestEnemy then
		local v = Vector:New(br.r_closestEnemy._groundx - self._groundx, 0,  br.r_closestEnemy._groundz - self._groundz)
		v:Normalize()
		ENTITY.SetVelocity(br.r_closestEnemy._Entity, br.r_closestEnemy.Pos.X, br.r_closestEnemy.Pos.Y, br.r_closestEnemy.Pos.Z, v.X*par3, v.Y*par4, v.Z*par3)
	end
end
--]]
