function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
	ENTITY.PO_EnableGravity(self._Entity,false)
--	self._flyWithAngle = true
    self._bindedFlyLoop = self:BindSound("actor/wingeddemon/wdemon-fly-loop",8,28,true)
	ENTITY.EnableCollisions(self._Entity, true, 0.2)
end

function o:CustomOnDeath()
    if self._bindedFlyLoop then
        ENTITY.Release(self._bindedFlyLoop)
        self._bindedFlyLoop = nil
    end
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


--[[function o:OnCollision(x,y,z,nx,ny,nz,e)
	if e then
		local obj = EntityToObject[e]
	end
end--]]

--------------------------

o._CustomAiStates = {}

o._CustomAiStates.DemonIdle = {
	name = "DemonIdle",
	active = false,
	_wait = 0,
	_retryWalk = false,
    _lastAttackAmbient = 0,
}

function o._CustomAiStates.DemonIdle:OnInit(brain)
end

function o._CustomAiStates.DemonIdle:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
    if brain._seeEnemy then
        if actor.s_SubClass.SoundsDefinitions.attackAmbient then
            if self._lastAttackAmbient + aiParams.soundAmbientDelay < brain._currentTime and math.random(100) < 3 then
				self._lastAttackAmbient = brain._currentTime
                actor:PlaySoundHitBinded("attackAmbient")
            end
        end
    end

	ENTITY.RemoveRagdollFromIntersectionSolver(actor._Entity)

	

	if brain._seeEnemy then
		brain._distToNearestEnemy = Dist2D(brain.r_closestEnemy._groundx,brain.r_closestEnemy._groundz, actor._groundx,actor._groundz)
	end

    
    if brain.r_closestEnemy then
		--Game:Print(brain._distToNearestEnemy)
        if brain._distToNearestEnemy < actor.AiParams.attackRange * 0.9 and not brain._disableAtak then		-- albo przeszkoda (disttoplayer spr)
            local deltaY = actor.Pos.Y - (brain.r_closestEnemy._groundy + 1.0)
            --if debugMarek then
			--	Game:Print(brain._distToNearestEnemy.." dist clo y = "..deltaY)
			--end
            if deltaY < 3.3 then
                actor:Stop()
                brain._atak = "atak"
                return
            end
        end
    
        if brain._distToNearestEnemy < actor.AiParams.attackRangeAcid and not brain._disableAtak then		-- albo przeszkoda (disttoplayer spr)		
            local deltaY = actor.Pos.Y - (brain.r_closestEnemy._groundy + 1.0)
            --if debugMarek then
			--	Game:Print(brain._distToNearestEnemy.." dist far y = "..deltaY)
			--end
            if deltaY >= 3.3 then
                actor:Stop()
                brain._atak = "atakAcid"
                return
            end
        end
    end

	if not actor._isWalking and not actor._isRotating then
		if self._wait > 0 then
			self._wait = self._wait - 1
			--if debugMarek then
			--	Game:Print("waiting")
			--end
			return
		end
		brain._disableAtak = false
		if (math.random(100) < 30 and not self._retryWalk) or (self._retryWalk and math.random(100) < 10) then
			if math.random(100) < 50 and brain._seeEnemy then
				actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
			end
			actor:Rotate(FRand(-80,80))
		else
			if math.random(100) < 45 and not self._retryWalk then
				self._wait = FRand(aiParams.moveDelays[1], aiParams.moveDelays[2])
				if brain._distToNearestEnemy < 8 then
					self._wait = self._wait * 0.6
				end
			else
			
				local x,y,z
				
				local dist = FRand(4,11)
				local up = FRand(-aiParams.moveUpRange, aiParams.moveUpRange)
				local ang = nil
				if self._retryWalk then
					ang = FRand(0,360)
				end
				
				--if brain.r_closestEnemy then
					local x,y,z = brain._enemyLastSeenPoint.X,brain._enemyLastSeenPoint.Y,brain._enemyLastSeenPoint.Z

					-- atak na playera
					-- lata na boki prostopadle do player i co jakis czas atakuje (zal od wysokosci na jakiej jest)
					local dist2D = Dist2D(x,z, actor._groundx,actor._groundz)
					-- jesli cos zaslania wroga to z gory?
					--
					
					local chance = 0.4
					if brain._distToNearestEnemy < 16 then		-- albo przeszkoda (disttoplayer spr)
						chance = 0.7
					end
					
					if FRand(0,1) < chance then		-- albo przeszkoda (disttoplayer spr)
						--Game:Print("to enemy -> "..((brain._enemyLastSeenPoint.Y + 2.0) - actor._groundy).." dist to = "..brain._distToNearestEnemy)
						actor:RotateToVector(x,y,z)
						
						dist = brain._distToNearestEnemy * FRand(0.3, 0.4)
						if dist < 2 then
							dist = 2
						end
						
						ang = FRand(-43,43)
						up = (brain._enemyLastSeenPoint.Y + 2.0) - actor._groundy + FRand(1.0,3.5)
					end
					-- ktory atak? jesli jest wysoko to acid?
					--

				local xd,yd,zd = actor._groundx,actor._groundy,actor._groundz
				yd = yd + up

				
				local dy = yd - (brain._enemyLastSeenPoint.Y + 2.0) 
				--Game:Print(" dy = "..dy)
				if aiParams.keepMinHeight and aiParams.keepMinHeight > 0 then
					if dy < aiParams.keepMinHeight then
						yd = yd + (aiParams.keepMinHeight - dy)
						
						--Game:Print(" dy modified = "..(yd - (brain._enemyLastSeenPoint.Y + 2.0)))
					end
				end

				local angle = actor._angleDest
				if ang then
					angle = math.mod(angle + ang * math.pi/180, math.pi * 2)
				end
				local v = Vector:New(math.sin(angle), 0, math.cos(angle))
				v:Normalize()
				
				x,y,z = xd + v.X*dist, yd, zd + v.Z*dist
				local b2,d2,x2,y2,z2,nx2,ny2,nz2,e = WORLD.LineTrace(actor._groundx, actor.Pos.Y, actor._groundz, x,y,z)	-- moze nie co update?
				self._retryWalk = false
				
				if debugMarek then
					actor.d1 = x
					actor.d2 = y
					actor.d3 = z
					actor.d4 = actor._groundx
					actor.d5 = actor.Pos.Y
					actor.d6 = actor._groundz
				end
				-- jesli za wysoko nad graczem, to w dol
				--
				if not b2 then
					--Game:Print("fly to")
					actor:FlyTo(x,y,z,nil,nil,true)
				else
					--Game:Print("retry walk")
					self._retryWalk = true
				end

			end
		end
	end
	ENTITY.AddRagdollToIntersectionSolver(actor._Entity)
end

function o._CustomAiStates.DemonIdle:OnRelease(brain)
	self._retryWalk = false
end

function o._CustomAiStates.DemonIdle:Evaluate(brain)
	return 0.1
end

o._CustomAiStates.DemonAtak = {
	name = "DemonAtak",
	--active = false,
}

function o._CustomAiStates.DemonAtak:OnInit(brain)
	local actor = brain._Objactor
	actor:SetAnim(brain._atak,false)
	local x,y,z = brain._enemyLastSeenPoint.X,brain._enemyLastSeenPoint.Y,brain._enemyLastSeenPoint.Z
	actor:RotateToVector(x,y,z)
	actor._doNotLoopWalkAnim = true
	--actor:FlyForward(FRand(4,5),nil,nil,brain._atak)
	actor._doNotLoopWalkAnim = nil
	 --Game.freezeUpdate = true
	 --Game:Print("atakz")
	-- Game.freezeUpdate = true
	--actor._disableHits = true
end

function o._CustomAiStates.DemonAtak:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isAnimating or actor.Animation ~= brain._atak then
		brain._atak = false
		actor:FlyForward(FRand(2.5, 4.5),FRand(-50,50), FRand(-0.5, 1.2))
		brain._disableAtak = true
	end
end

--function o._CustomAiStates.DemonAtak:OnRelease(brain)
--end


function o._CustomAiStates.DemonAtak:Evaluate(brain)
	if brain._atak then
		return 0.2
	end
	return 0.0
end

--------------
function o:damageCustom()
	local br = self._AIBrain
	if br and br.r_closestEnemy then
		local aiParams = self.AiParams
		local dist = Dist3D(self._groundx, self._groundy, self._groundz, br.r_closestEnemy._groundx, br.r_closestEnemy._groundy + 2.0, br.r_closestEnemy._groundz)
		local angleAttack = math.atan2(br.r_closestEnemy._groundx - self._groundx, br.r_closestEnemy._groundz - self._groundz)
		local aDist = AngDist(self.angle, angleAttack)
		
		local angleRange = aiParams.attackRangeAngle
		if not angleRange then
			--if debugMarek then Game:Print(self._Name.." nie ma aiParams.attackRangeAngle!!") end
			angleRange = 120
		end
		local weaponRange = aiParams.weaponRange
		if not weaponRange then
			weaponRange = aiParams.attackRange
		end
		if dist <= weaponRange and math.abs(aDist) < angleRange*math.pi/180 then
			self:PlayRandomSound2D("damage")
			if br.r_closestEnemy.OnDamage then
				local x,y,z
				local nx,ny,nz
				if br.r_closestEnemy._Class == "CActor" and br.r_closestEnemy.GetAnyJoint then
					local j = br.r_closestEnemy:GetAnyJoint()
					x,y,z = MDL.GetJointPos(br.r_closestEnemy._Entity, j)
					nx = 0
					ny = 1
					nz = 0
				end
				br.r_closestEnemy:OnDamage(aiParams.weaponDamage,self,AttackTypes.AIClose,x,y,z,nx,ny,nz)
			end
		end
	end
end

--function o:DropAcid()
--	local x,y,z = self:GetJointPos("joint10")
--	AddObject("Winged_Demon_Acid.CItem",nil,Vector:New(x,y,z),nil,true)
--end

function o:CustomOnFreeze()
	self:OnDamage(999)
end
