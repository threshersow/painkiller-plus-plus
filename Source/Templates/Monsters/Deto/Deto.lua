function Deto:OnPrecache()
    Cache:PrecacheItem("Deto_bomb.CItem")
end

function Deto:OnInitTemplate()
    self:SetAIBrain()
    --self._AIBrain._lastSliceTime = 0
    self._bombs = {}
end

function Deto:CustomOnDamage(he,x,y,z,obj, damage, type)
	if type == AttackTypes.Suicide then
		return true
	end
end

function Deto:CustomOnDeath()
	if LEVEL_RELEASING then return end
	local x,y,z = self:GetJointPos("root")
    SOUND.Play3D("actor/deto/deto-dynamite-explosion",x,y,z,12,48)
    AddPFX("Grenade",0.6,Vector:New(x,y,z))            

	local s = self.s_SubClass
	
	WORLD.Explosion2(x,y,z,s.DeathExplosionStrength,s.DeathExplosionRange,nil,AttackTypes.Suicide,s.DeathExplDamage)  
    
    -- light
    AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y+1.5,z)
    if Game._EarthQuakeProc then
        Game._EarthQuakeProc:Add(x,y,z, 12, 10 --[[g.ExplosionCamDistance--]], 0.25, 0.25)
    end

end

--[[
function o:Drop()
	if self._startThrowing > 0 then
		local x,y,z = self:GetJointPos("dlo_prawa_root")
		local ke,obj = AddItem("Deto_bomb.CItem",nil,Vector:New(x,y,z),true)
		table.insert(self._bombs, obj)
		ENTITY.SetVelocity(obj._Entity, 0, -6, 0)
		self._startThrowing = self._startThrowing - 1
	else
		self._forceWalkAnim = nil
		Game:Print("koniec startthro")
	end
end


function o:EndDrop()
	if self._startThrowing <= 0 then
		self._forceWalkAnim = nil
		self:FullStop()
	end
end

o._CustomAiStates = {}
o._CustomAiStates.detoAttack = {
	name = "detoAttack",
    lastTimeOnAttackAmbient = 0,
	_mode = 0,
	_maxRetries = 3,
	lastTimeCHECK = 0,
}


function o._CustomAiStates.detoAttack:OnInit(brain)
	local actor = brain._Objactor
	actor:Stop()
	self._lastTimeLost = brain._currentTime
	
	
	if not self.firstTime then
		self.firstTime = true
		if actor.s_SubClass.SoundsDefinitions.onAttackOnce then
			actor:PlaySoundAndStopLast("onAttackOnce", nil, nil, true)
		end
	end
	actor._disableHits = false
end

function o._CustomAiStates.detoAttack:OnUpdate(brain)
	local actor = brain._Objactor
	local enemy = brain.r_closestEnemy
	local aiParams = actor.AiParams
	
	if self._mode == 0 then
		if not actor._isWalking then
			if actor._startThrowing and brain._distToNearestEnemy < 3 then
				self._mode = 1
				Game:Print("-->1")
				actor:RotateToVector(enemy._groundx, enemy._groundy, enemy._groundz)
				actor:Rotate(FRand(-30,30))
				actor:WalkForward(10, true)
			else
				-- punkt z lewej lub prawej gracza
				local v = Vector:New(actor._groundz - enemy._groundz, 0, enemy._groundx - actor._groundx)
				v:Normalize()
				v:MulByFloat(FRand(2.6, 2.8))
				if debugMarek then
					actor.yadebug1 = enemy._groundx + v.X
					actor.yadebug2 = enemy._groundy + v.Y + 1.5
					actor.yadebug3 = enemy._groundz + v.Z
					actor.yadebug4 = actor._groundx
					actor.yadebug5 = actor._groundy + 1.5
					actor.yadebug6 = actor._groundz

					actor.yaadebug1 = enemy._groundx - v.X
					actor.yaadebug2 = enemy._groundy - v.Y + 1.5
					actor.yaadebug3 = enemy._groundz - v.Z
					actor.yaadebug4 = actor._groundx
					actor.yaadebug5 = actor._groundy + 1.5
					actor.yaadebug6 = actor._groundz

				end
				local b,d = WORLD.LineTraceFixedGeom(actor._groundx, actor._groundy + 1.5, actor._groundz, enemy._groundx + v.X, enemy._groundy + v.Y + 1.5, enemy._groundz + v.Z)
				if not b then
					Game:Print("1 ok")
					actor:WalkTo(enemy._groundx + v.X, enemy._groundy, enemy._groundz + v.Z, true)
				else
					b,d = WORLD.LineTraceFixedGeom(actor._groundx, actor._groundy + 1.5, actor._groundz, enemy._groundx - v.X, enemy._groundy - v.Y + 1.5, enemy._groundz - v.Z)
					if not b then
						Game:Print("2 ok")
						actor:WalkTo(enemy._groundx - v.X, enemy._groundy, enemy._groundz - v.Z, true)
					else
						Game:Print("2 not ok")
						actor:WalkTo(enemy._groundx + FRand(-2,2), enemy._groundy, enemy._groundz + FRand(-2,2), true)
					end
				end
			end
		else
			-- odp odleglosc od gracza, to zrzucanie bomb
			if not self._lastTimeThrow and brain._distToNearestEnemy < 12 then
				actor._forceWalkAnim = "run_drop"
				actor:WalkForward(10,true)
				actor._startThrowing = 6
				self._lastTimeThrow = 0
				Game:Print("-->st t")
				--Game.freezeUpdate = true
			end
		end
	end
	
	if self._mode == 1 and not actor._isWalking then
		self._mode = 0
		Game:Print("-->0")
		
	end
	
	if actor._startThrowing and actor._isWalking then
		if not actor._forceWalkAnim then
			self._mode = 2
			self._lastTimeThrow = nil
			actor:WalkForward(FRand(10,12),true, FRand(-90,90), nil, nil, true)
			Game:Print("-->2 "..actor._startThrowing)
			actor._startThrowing = nil
		end
	end


	if actor._isWalking and ENTITY.PO_IsOnFloor(actor._Entity) then
			-- trace
			
        if self.lastTimeCHECK + 0.4 < brain._currentTime then
        
            local length = 2
            ENTITY.RemoveRagdollFromIntersectionSolver(actor._Entity)	
        
            local cx,cy,cz = actor._groundx,actor._groundy + actor._SphereSize * 1.5, actor._groundz

            local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
            v:Normalize()

            local v2 = Vector:New(math.sin(actor.angle + math.pi/2), 0, math.cos(actor.angle + math.pi/2))
            v2:Normalize()
            v2:MulByFloat(FRand(0.3,0.4))


            local sx
            local sy
            local sz
            
            for i=1,2 do
                if i == 1 then
                    sx = cx + v2.X
                    sy = cy + v2.Y
                    sz = cz + v2.Z
                else
                    sx = cx - v2.X
                    sy = cy - v2.Y
                    sz = cz - v2.Z
                end

                if debugMarek then
                    actor.yaaadebug1 = cx + v2.X
                    actor.yaaadebug2 = cy + v2.Y
                    actor.yaaadebug3 = cz + v2.Z
                    actor.yaaaadebug1 = cx - v2.X
                    actor.yaaaadebug2 = cy - v2.Y
                    actor.yaaaadebug3 = cz - v2.Z
                end
                
                local fx = v.X*length + sx
                local fy = v.Y*length + sy
                local fz = v.Z*length + sz

                if debugMarek then
                    actor.yaaadebug4 = v.X*length + cx + v2.X
                    actor.yaaadebug5 = v.Y*length + cy + v2.Y
                    actor.yaaadebug6 = v.Z*length + cz + v2.Z
                    actor.yaaaadebug4 = v.X*length + cx - v2.X
                    actor.yaaaadebug5 = v.Y*length + cy - v2.Y
                    actor.yaaaadebug6 = v.Z*length + cz - v2.Z
                end
                
                local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(sx,sy,sz,fx,fy,fz)	-- FixedGeom

                if e then
                    self.lastTimeCHECK = brain._currentTime
                    local obj = EntityToObject[e]
                    if obj then
                        Game:Print(" kolizja z "..obj._Name)
                        local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
                        v:Normalize()
                        self.ImpulseSTR = aiParams.pushStren

                        if obj._Class == "CPlayer" then
                            ENTITY.PO_SetPlayerFlying(e, 0.33)
                            ENTITY.SetVelocity(e, v.X*self.ImpulseSTR,self.ImpulseSTR*0.66,v.Z*self.ImpulseSTR)
                        else
                            local a = self.ImpulseSTR * 0.3
                            ENTITY.SetVelocity(e, v.X*a,v.Y*a + a*0.5,v.Z*a)
                        end
                        if obj._Class == "CPlayer" then
                            obj:OnDamage(aiParams.pushDamage,actor)
                        end
                        if obj._Class == "CPlayer" then
                            actor:PlayRandomSound2D("damage")
                        end
                    end
                    
                    
                end
            end

            ENTITY.AddRagdollToIntersectionSolver(self._Entity)
		end
	end

	if self._mode == 2 and not actor._isWalking then
		actor._disableHits = true
		actor:RotateToVector(enemy._groundx, enemy._groundy, enemy._groundz)
		actor:SetAnim("detonacja",false)
		if actor._HealthMax * aiParams.ABHp > actor.Health then
			Game:Print("-->3")
			self._mode = 3
			self._timeOut = aiParams.ABtimeOut
		else
			Game:Print("-->0")
			self._mode = -1
		end
		return
	end
	
	if self._mode == -1 and (not actor._isAnimating or actor.Animation ~= "detonacja") then
		self._mode = 0
		actor._disableHits = false
	end
	
	if self._mode == 3 and (not actor._isAnimating or actor.Animation ~= "detonacja") then
		actor._disableHits = false
		-- w detonacji spr. czy blisko gracza, jesli tak to self bum
		if not actor._isWalking then
			if enemy then
				actor:WalkTo(enemy._groundx, enemy._groundy, enemy._groundz,true)
			end
		else
			if enemy  and math.random(1000) < 40 then
				actor:WalkTo(enemy._groundx, enemy._groundy, enemy._groundz,true)
			end
		end
		self._timeOut = self._timeOut - 1/30
		
		if brain._distToNearestEnemy < aiParams.detonateAtRange * 0.9 or self._timeOut < 0 then
			actor:Stop()
			actor:SetAnim("detonacja",false)
			Game:Print("koniec "..self._timeOut.." "..brain._distToNearestEnemy)
			actor.AIenabled = false
			return
		end
		
	end
	
    if actor.s_SubClass.SoundsDefinitions.attackAmbient then
        if self.lastTimeOnAttackAmbient + aiParams.soundAmbientDelay < brain._currentTime and math.random(100) < 3 and actor.Animation ~= "detonacja" then
            self._lastAttackAmbient = actor:PlaySoundHitBinded("attackAmbient")
            if self._lastAttackAmbient then
                self.lastTimeOnAttackAmbient = brain._currentTime
            end
        end
    end

end

function o._CustomAiStates.detoAttack:OnRelease(brain)
	local actor = brain._Objactor
end

function o._CustomAiStates.detoAttack:Evaluate(brain)
	if brain.r_closestEnemy or self._mode >= 3 then
		return 0.6
	end
	return 0
end


function o:Detonate()
	for i,v in self._bombs do
		if not v._ToKill then
			v:Detonate()
		end
	end
	self._bombs = {}
	local aiParams = self.AiParams
	local brain = self._AIBrain
	if self._HealthMax * aiParams.ABHp > self.Health and (brain._distToNearestEnemy < aiParams.detonateAtRange or not self.AIenabled) then
		self:OnDamage(self.Health + 1000, true)
	end
end

--]]

function o:SStop()
	self:Stop()
end

function o:Detonate()
	self:OnDamage(self.Health + 1000, true)
end
