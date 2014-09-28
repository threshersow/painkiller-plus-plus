function Executioner:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastSliceTime = 0
    self._dontPinStake = true
end

function Executioner:OnPrecache()
	Cache:PrecacheActor("Spider.CActor")
	Cache:PrecacheParticleFX("monsterweap_hitground")
end



function Executioner:CustomOnDeath()
	local brain = self._AIBrain
	if brain.Objhostage2 then
		brain.Objhostage2._locked = false
		brain.Objhostage2 = nil
	end
	MDL.SetMeshVisibility(self._Entity, "br", false)
end

function Executioner:CustomOnDeathAfterRagdoll()
	if self.pfxToBru then
		self:BindFX(self.pfxToBru[1], self.pfxToBru[2], "bru")
	end
end



function Executioner:CustomOnDamage(he,x,y,z,obj, damage, type)
    if type == AttackTypes.Demon or self._frozen or type == AttackTypes.OutOfLevel then
         return false
    end

    if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        local jName = MDL.GetJointName(e,j)
        if jName == "bru" then
			return false
        else
        	if type == AttackTypes.Shotgun or type == AttackTypes.MiniGun or type == AttackTypes.Painkiller then
                self:PlaySound("Hit")
            end
		end
	else
		if x and (type == AttackTypes.Rocket or type == AttackTypes.Shuriken) then
			local x1,y1,z1 = self:GetJointPos("bru")
			local dist = Dist3D(x,y,z,x1,y1,z1)
			--Game:Print("odleglosc wybuchu od jointa : "..dist.." "..damage)
			if dist < 0.5 then
				damage = damage * (5/10 - dist)*10/5
				return false, damage
			end
		end
	end

	--[[local animName = "hit"
	if obj ~= self and animName ~= self.Animation and self:SetAnim(animName, false) then
		--Game:Print("MASO ONDAMGE hit: SET ANIM HIT")
		self._lastHitAnim = animName
		self._hitDelay = 99999			-- czeka na zakonczenie animacji
		self:Stop()
	end
	if self.enableGibWhenHPBelow then
		if (self.Health - damage) < self.enableGibWhenHPBelow then
			if debugMarek then Game:Print(self._Name.." bedzie GIBBOWANY") end
			return false
		end
	end--]]
	return true
end


----------------------------
Executioner._CustomAiStates = {}
Executioner._CustomAiStates.sliceCorpse = {
	name = "sliceCorpse",
	delayRandom = FRand(0,1),
}

function Executioner._CustomAiStates.sliceCorpse:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	Game:Print("******* start sliceBody")
	self.mode = 0
	if brain.Objhostage2 then
		if brain.Objhostage2._deathTimer < 200 then
			brain.Objhostage2._deathTimer = brain.Objhostage2._deathTimer + 60		-- +2 sec. bonusu
		end

		brain.Objhostage2._locked = true
		local x,y,z = brain.Objhostage2:GetJointPos(aiParams.holdJointDst)
		self._orygPos = Vector:New(x,y,z)
		--Game.freezeUpdate = true
		actor:WalkTo(x,y,z,true)
		self.active = true
	end
end

function Executioner._CustomAiStates.sliceCorpse:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if brain.Objhostage2 then
		if brain.Objhostage2._deathTimer and brain.Objhostage2._deathTimer > 2 then
			brain.Objhostage2._deathTimer = brain.Objhostage2._deathTimer + 1
		else
			if debugMarek then Game:Print(actor._Name.." death timer too low!") end
			actor:SetIdle()
			self.active = false
			return
		end
		if brain.Objhostage2.Pinned then
			if debugMarek then Game:Print(actor._Name.." ktos przybil kolkiem kolesia!") end
			actor:SetIdle()
			self.active = false
			return
		end
	end
	
	if self.mode == 0 then
		if not actor._isWalking then
			if debugMarek then Game:Print("not is walking.....") end
			self.active = false
		else
			local x,y,z = brain.Objhostage2:GetJointPos(aiParams.holdJointDst)
			local dist = Dist3D(x,y,z,actor._groundx,actor._groundy,actor._groundz)
			if dist < 2.5 then
				if debugMarek then Game:Print("odp. zasieg, tnie") end
				actor:Stop()
				actor:RotateToVector(x,y,z)
				self.mode = 1
				actor:SetAnim("tnie_trupa", false)
			else
				local dist = Dist3D(x,y,z,self._orygPos.X, self._orygPos.Y, self._orygPos.Z)
				if dist > 1.2 then		-- ragdoll sie rusza
					if math.random(100) < 18 then
						actor:WalkTo(x,y,z,true)
						if debugMarek then Game:Print("retry walk") end
						self._orygPos = Vector:New(x,y,z)
					end
				end
			end
		end
	else
		if not actor._isAnimating or actor.Animation ~= "tnie_trupa" then
			self.active = false
			if debugMarek then Game:Print("koniec anim tnie_trupa") end
		end
	end
	
	brain._lastSliceTime = brain._currentTime
end

function Executioner._CustomAiStates.sliceCorpse:OnRelease(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	self.active = false
	if brain.Objhostage2 then
		brain.Objhostage2._locked = false
		brain.Objhostage2 = nil
	end
	Game:Print("koniec sliceBody release")
end

function Executioner._CustomAiStates.sliceCorpse:Evaluate(brain)
	-- tu trzeba spr. czy jest ragdoll miedzy playerem a soba i mozna nim rzucic
	if self.active then
		return 0.7
	else
		local actor = brain._Objactor
		local aiParams = actor.AiParams
		if brain._seeEnemy and brain._distToNearestEnemy > 5 and brain._distToNearestEnemy < 40
			and math.random(100) < 10 and not brain.Objhostage2 and not actor._hitDelay then
			if brain._lastSliceTime + aiParams.minDelayBetweenSliceCorpse < brain._currentTime then
				local maxDist = aiParams.sliceCorpseRangeMax
				local v2 = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
				v2:Normalize()

				for i,v in Actors do
					if v.Health <= 0 then
						if not v._locked and not v._gibbed and not v.Pinned and not v.NotCountable and v._enabledRD and not v.notBleeding then	-- + v.gibWhenBelow
							-- get velocity of joint, zeby lezacego ragdola bral, a nie lecacego
							local j  = MDL.GetJointIndex(v._Entity, aiParams.holdJointDst)
							local _velocityx,_velocityy,_velocityz,_velocity = MDL.GetVelocitiesFromJoint(v._Entity, j)

							local x,y,z = MDL.GetJointPos(v._Entity,j)
							local dist = Dist3D(x,y,z, actor._groundx,actor._groundy,actor._groundz)
							local dist2 = Dist3D(x,y,z, actor._groundx + v2.X,actor._groundy,actor._groundz + v2.Z)
							
							if debugMarek then Game:Print(actor._Name.." possible target "..v._Name.." "..dist.." "..dist2) end
							if _velocity < 1.0 and dist < maxDist and dist2 < dist then
								if debugMarek then
									--Game:Print(actor._Name.."possible target1"..v._Name)
									actor.d1 = actor._groundx
									actor.d2 = actor._groundy + 1.5
									actor.d3 = actor._groundz
									actor.d4 = x
									actor.d5 = y
									actor.d6 = z
								end
								local b,d,x,y,z,nx,ny,nz = WORLD.LineTraceFixedGeom(actor._groundx,actor._groundy + 1.5, actor._groundz, x,y,z)
								if not b then
									brain.Objhostage2 = v
									maxDist = dist
								else
									--if debugMarek then Game:Print(actor._Name.."nie widzi ragdola: "..v._Name) end
								end
							end
						end
					end
				end
				if brain.Objhostage2 then
					return 0.605
				end
			end
		end
	end
	return 0.0
end

function Executioner:Slice()
    local brain = self._AIBrain
    local aiParams = self.AiParams
	if brain.Objhostage2 and not brain.Objhostage2._gibbed and brain.Objhostage2._deathTimer > 0 then
		local x,y,z = brain.Objhostage2:GetJointPos(aiParams.holdJointDst)
		local x2,y2,z2 = self:GetJointPos("dlo_lewa_root")
		local dist = Dist3D(x,y,z,x2,y2,z2)
		if debugMarek then
			self.DEBUG_P1 = x
			self.DEBUG_P2 = y
			self.DEBUG_P3 = z
			self.DEBUG_P4 = x2
			self.DEBUG_P5 = y2
			self.DEBUG_P6 = z2
			Game:Print("slice? "..dist)
		end
		if dist < 1.6 then
			if debugMarek then Game:Print("slice") end
            brain.Objhostage2.throwHeart = false
            if brain.Objhostage2.enableGibWhenHPBelow then
                brain.Objhostage2:CreateGib()
            end
			self:PlaySound("sliceHit")
			for i=1, aiParams.SpiderSpawnCount do
				local x3,y3,z3 = x + FRand(-0.5,0.5), y + i*0.05, z + FRand(-0.5,0.5)
				local obj = GObjects:Add(TempObjName(),CloneTemplate("Spider.CActor"))
				obj.Pos.X = x3
				obj.Pos.Y = y3
				obj.ObjOwner = self
				obj.Pos.Z = z3
				local v = Vector:New(x3 - x, y3 - y, z3 - z)
				--local force = 1--aiParams.SpawnSpeed
				--v.Y = math.abs(v.Y) * force
				--v.X = v.X * force
				--v.Z = v.Z * force
				obj.angle = math.atan2(v.X, v.Z)
				obj._angleDest = obj.angle
				obj:Apply()
				obj:Synchronize()
			end
		end
	end
end

function o:IfMissedPlaySound()
	local brain = self._AIBrain
	if brain then
		if brain._lastHitTime < brain._lastMissedTime then
			self:PlaySound("missed")
			if self.s_SubClass.hitGroundJoint then
				local x,y,z = self:GetJointPos(self.s_SubClass.hitGroundJoint)
				if debugMarek then
					DEBUGcx = x
					DEBUGcy = y
					DEBUGcz = z
					DEBUGfx = x
					DEBUGfy = y - 1.5
					DEBUGfz = z
				end
				local b,d,x1,y1,z1 = WORLD.LineTraceFixedGeom(x,y,z,x,y-1.5,z)
				if b then
					local q = Quaternion:New_FromNormal(nx,ny,nz)
					AddPFX("monsterweap_hitground",0.2, Vector:New(x1,y1,z1),q)
				end
			end
		end
	end
end
