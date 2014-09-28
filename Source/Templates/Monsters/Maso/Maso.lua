function Maso:OnInitTemplate()
    self:SetAIBrain()
end

function Maso:OnCreateEntity()
	if self.flame_FX then
		self._Flame2 = self:BindFX(self.flame_FX,0.07,"joint22",0,0,0.2)
	end
    self._AIBrain._lastThrowTime = self._AIBrain._currentTime + FRand(0,2)
    self._soundSample = SOUND3D.Create("actor/maso/maso_flametrower-loop")
	SOUND3D.SetHearingDistance(self._soundSample,14,42)
    SOUND3D.SetLoopCount(self._soundSample,0) 
    SOUND3D.SetVolume(self._soundSample, 0.0)
end

function Maso:CheckDamageFromFlame()
	local idx  = MDL.GetJointIndex(self._Entity,"joint22")
	local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0.2)
	local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0.2+self.AiParams.attackRange)
	if debugMarek then
		self.d1 = x2
		self.d2 = y2
		self.d3 = z2
		self.d4 = x3
		self.d5 = y3
		self.d6 = z3
	end
	local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x3,y3,z3, x2,y2,z2)
	--local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTrace(x3,y3,z3, x2,y2,z2)
	if e then
		--Game:Print("flame col")
		local obj = EntityToObject[e]
		if obj then
			if obj ~= self then
				if obj.Ignite then
					obj:Ignite()
				else
					if obj.OnDamage then
						--if debugMarek then Game:Print("flame col with "..obj._Name) end
						obj:OnDamage(self.flameDamage, self)
						if obj._Class == "CPlayer" then
							self._AIBrain._lastHitTime = self._AIBrain._currentTime
						end
					end
				end
			else
				Game:Print(self._Name.." flame col with self!!!!!!!!!!")
			end
		end
	end
	
	
	
--[[	if math.random(100) < 15 then			-- pozniej moze kilka obiektow "gas" wyrzucac
		local obj = GObjects:Add(TempObjName(),CloneTemplate("GasMaso.CItem"))
		obj.Pos.X = x2
		obj.Pos.Y = y2
		obj.Pos.Z = z2
		obj.Decal = nil
		obj.whileFlyingSize = 0.1
		obj:Apply()
		local v = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v:Normalize()
		local vel = 8
		ENTITY.SetVelocity(obj._Entity, v.X*vel, v.Y*vel, v.Z*vel)
	end--]]

end

function Maso:Flame()
	if not self._flameFX then
		local idx  = MDL.GetJointIndex(self._Entity,"joint22")
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0.25)
		local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,1.0)
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

		self._flameFX = AddPFX(self.flamerFX, 0.4, Vector:New(x2,y2,z2), q)
		if self._flameProc then
			Game.freezeUpdate = true
			if debugMarek then Game:Print("self._flameProc juz istnieje") end
		end
		self._flameProc = true
		self:PlaySound({"maso_flametrower-start"})
		SOUND3D.Play(self._soundSample)
		SOUND3D.SetVolume(self._soundSample, 100.0, 0.3)
		SOUND3D.SetPosition(self._soundSample,self._groundx,self._groundy,self._groundz)
		if self._Flame2 then
			PARTICLE.Die(self._Flame2)
			self._Flame2 = nil
		end
		
		--ENTITY.RegisterChild(self._Entity,self._flameFX)
		--Game:Print("flame start")
	else
		if debugMarek then Game:Print("flame started???") end
	end
end

function Maso:FlameEnd()
	--Game:Print("flame end")
	if self._flameFX then
		--ENTITY.Release(self._flameFX)
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end

	self._flameProc = nil

	if not self._Flame2 and self.flame_FX then
		self._Flame2 = self:BindFX(self.flame_FX,0.07,"joint22",0,0,0.2)
	end

end

function Maso:CustomUpdate()
	if self.flame_FX and self._flameFX and self.Animation ~= "atak_flame" then
		self:FlameEnd()
		SOUND3D.SetVolume(self._soundSample, 0.0)
		SOUND3D.Stop(self._soundSample)
		self:PlaySound({"maso_flametrower-stop"})
	end
end


function Maso:CustomOnDamage(he,x,y,z,obj, damage, type)
	--Game:Print(self._Name.." on damage "..type)
	if type == AttackTypes.Demon or self._frozen or type == AttackTypes.OutOfLevel then
         return false
    end

    if type == AttackTypes.AIClose then		-- od eksplozji innego maso pol damage
		return false, 0.5*damage
    end

    if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        local jName = MDL.GetJointName(e,j)
        --Game:Print("jName : "..jName)
        if self.AiParams.weaponBindPos == jName then
			return false
		end
	else
		if x and (type == AttackTypes.Rocket or type == AttackTypes.Shuriken) then
			local x1,y1,z1 = self:GetJointPos(self.AiParams.weaponBindPos)
			local dist = Dist3D(x,y,z,x1,y1,z1)
			--Game:Print("odleglosc wybuchu od jointa : "..dist.." "..damage)
			if dist < 0.8 then
				damage = damage * (8/10 - dist)*10/8
				return false, damage
			end
		end
	end

	if type then
		if type == AttackTypes.Shotgun or type == AttackTypes.MiniGun or type == AttackTypes.Painkiller then
			self:PlaySound({"maso_hit_impact1","maso_hit_impact2"},22,52)
		end
	end

	local animName = "hit"
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
	end
	return true
end


function Maso:CustomDelete()
	if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
		Game:Print(self._Name.." !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! maso")
		Game.freezeUpdate = true
	end
	if self._soundSample then
		SOUND3D.Delete(self._soundSample)
		self._soundSample = nil
	end
end


function Maso:CustomOnDeathAfterRagdoll()
    local brain = self._AIBrain
	if brain and brain.Objhostage2 then
		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end
    if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end
	self._flameProc = nil

	if self._Flame2 then
		PARTICLE.Die(self._Flame2)
		self._Flame2 = nil
	end
	self:PlaySound({"maso-weapon-explode"})
	if self._soundSample then
		SOUND3D.Delete(self._soundSample)
		self._soundSample = nil
	end
    local x,y,z = self._groundx, self._groundy+0.5, self._groundz--self:GetJointPos(self.AiParams.weaponBindPos)
    if not self._gibbed then
		self:Explosion(x,y,z)
	end
    local tdj = self.s_SubClass.DeathJoints
    if tdj then
        local size = self.burnPFXSize
        for i=1,table.getn(tdj) do
            self:BindFX(self.burnPFX, size, tdj[i])
        end
    end
	if not self._gibbed then
		self:BindFX("warp")
	end

end

function Maso:GetThrowItemRotation()
	local q = Quaternion:New()
    q:FromEuler(0, math.pi/2-self.angle, math.pi/2)
    return q
end    

function Maso:OnThrow()
	local aiParams = self.AiParams
	self._objTakenToThrow.Damage = aiParams.GrenadeExplosion.Damage
	self._objTakenToThrow.ExplosionStrength = aiParams.GrenadeExplosion.ExplosionStrength
    self._objTakenToThrow.ExplosionRange    = aiParams.GrenadeExplosion.ExplosionRange
end

function Maso:Explosion(x,y,z)
	local aiParams = self.AiParams
	WORLD.Explosion2(x,y,z, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.AIClose,aiParams.Explosion.Damage)
	-- sound
	SOUND.Play3D("weapons/machinegun/rocket_hit",x,y,z,20,150)
	local r = Quaternion:New_FromNormal(0,1,0)
	AddObject("FX_rexplode.CActor",1,Vector:New(x,y,z),r,true) 

	-- light
	AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y,z)
	if Game._EarthQuakeProc then
		local g = Templates["Grenade.CItem"]
		Game._EarthQuakeProc:Add(x,y,z, 5, g.ExplosionCamDistance, g.ExplosionCamMove, g.ExplosionCamRotate, false)
	end
	MDL.SetMeshVisibility(self._Entity,"polySurface1|polySurfaceShape1", false)
end


-------------------
AiStates.burnSkeleton = {
	name = "burnSkeleton",
    _lastTimeBurn = 0,
}
function AiStates.burnSkeleton:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	self.active = true
	local dist = Dist3D(brain.Objhostage2._groundx, brain.Objhostage2._groundy, brain.Objhostage2._groundz, actor._groundx,actor._groundy,actor._groundz)
	if dist > aiParams.attackRange then
		actor:WalkTo(brain.Objhostage2._groundx, brain.Objhostage2._groundy, brain.Objhostage2._groundz, true, dist - 2.0)	-- poznije troche blizej
	end
	if debugMarek then Game:Print("Burn skeleton") end
	self.state = 0
end

function AiStates.burnSkeleton:OnUpdate(brain) 
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if self.state == 0 then
		if not actor._isWalking or brain.Objhostage2.Health <= 0 or brain.Objhostage2._isBurning then
			if debugMarek then
				if debugMarek then Game:Print("burnskel: not is walking or") end
				--Game.freezeUpdate = true
			end
			self.Objattack = nil
			for i,v in Actors do
				if v.Health > 0 and v.canBurn and not v._isBurning then
					local dist = Dist3D(v._groundx, v._groundy, v._groundz, actor._groundx,actor._groundy,actor._groundz)
					if dist < aiParams.attackRange then
						self.Objattack = v
						break
					end
				end
			end
			if self.Objattack then
				actor:RotateToVector(self.Objattack._groundx, self.Objattack._groundy, self.Objattack._groundz)
				if debugMarek then Game:Print("znalazl do podpalenie cel") end
				actor:SetAnim("atak_flame", false)
				self.state = 1
			else
				if debugMarek then Game:Print("self active false") end
				self.active = false
			end
		else
			if math.random(100) < 10 then
				for i,v in Actors do
					if v.Health > 0 and v.canBurn and not v._isBurning then
						local dist = Dist3D(v._groundx, v._groundy, v._groundz, actor._groundx,actor._groundy,actor._groundz)
						if dist < aiParams.attackRange then
							if debugMarek then Game:Print("znalazl podczas biegniecia do innego") end
							self.attack = v
							break
						end
					end
				end
			end
		end
	else
		if not actor._isAnimating or actor.Animation ~= "atak_flame" then
			if debugMarek then Game:Print("koniec podpalanie ssoldiera") end
			self.active = false
		end
	end
	self._lastTimeBurn = brain._currentTime
end

function AiStates.burnSkeleton:OnRelease(brain) 
	local actor = brain._Objactor
	if brain.Objhostage2 then
		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end

	self.Objattack = nil
	actor:FlameEnd()
	SOUND3D.SetVolume(actor._soundSample, 0.0)
	SOUND3D.Stop(actor._soundSample)
	actor:PlaySound({"maso_flametrower-stop"})

end

function AiStates.burnSkeleton:Evaluate(brain)
	if self.active then
		return 0.7
	else
		local actor = brain._Objactor
		local aiParams = actor.AiParams
		if brain._distToNearestEnemy > aiParams.attackRange and math.random(100) < 10 and actor._state ~= "ATTACKING" then
			if self._lastTimeBurn + aiParams.minDelayBetweenBurn + 0.5 < brain._currentTime then
				local maxDist = 9999
				for i,v in Actors do
					if v.Health > 0 and v.canBurn and not v._isBurning and not v._isWalking then
						local dist = Dist3D(v._groundx, v._groundy, v._groundz, actor._groundx,actor._groundy,actor._groundz)
						if dist < maxDist and dist < aiParams.viewDistance and dist < brain._distToNearestEnemy * 0.9 then
							local v2 = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
       						v2:Normalize()
							local destx = actor._groundx + v2.X
							local desty = actor._groundy
							local destz = actor._groundz + v2.Z
							local dist2 = Dist3D(destx, desty, destz, v._groundx,v._groundy,v._groundz)
							
							if debugMarek then
							    --Game:Print("cel do podpalenia?")
								actor.yadebug1 = destx
								actor.yadebug2 = desty
								actor.yadebug3 = destz
								actor.yadebug4 = actor._groundx
								actor.yadebug5 = actor._groundy
								actor.yadebug6 = actor._groundz
							end

							
							if dist2 < dist then 
								if debugMarek then Game:Print("cel do podpalenia2?") end
								if ENTITY.SeesEntity(actor._Entity, v._Entity) then
									maxDist = dist
									--Game.freezeUpdate = true
									brain.Objhostage2 = v
								end
							end
						end
					end
				end
				if brain.Objhostage2 then
					brain.Objhostage2._locked = true
					if debugMarek then Game:Print("cel do podpalenia") end
					return 0.65
				end
			end
		end
	end
	return 0.0
end


function Maso:OnTick()
	if self._flameFX and self._flameProc then
		local idx  = MDL.GetJointIndex(self._Entity,"joint22")
		--Game:Print("PBindPFXToJoint:itck "..idx)
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0.2)
		local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,1.0)
		local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v2:Normalize()
		
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)
		q:ToEntity(self._flameFX)
		ENTITY.SetPosition(self._flameFX,x2,y2,z2) 
	end
end

