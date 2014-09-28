function Lucifer:OnInitTemplate()
    self:SetAIBrain()
end

function Lucifer:CustomUpdate()
	if self.AIenabled then
		Game.MegaBossHealth = self.Health
	end
end

function o:OnPrecache()
    Cache:PrecacheParticleFX("AlastorchargeFX")
    Cache:PrecacheParticleFX("lucyferhead_fx")
    Cache:PrecacheParticleFX("sword")
    Cache:PrecacheParticleFX("head")
end





function Lucifer:BindParticles()
	if not self._binded then
		self._binded = true
		for i=1,9 do
			self:BindFX("sword", nil,"emiter_miecz_"..i)
		end
		for i=1,3 do
			self:BindFX("head", nil,"emiter_glowa_"..i)
		end

		self:BindFX("lucyferhead_fx", 1.0,"n_l_biodro",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"n_l_kolano",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"n_l_kolano2",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"n_l_stopa",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"n_p_biodro",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"n_p_kolano",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"n_p_kolano2",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"joint64",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"k_zebra",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"r_l_bark",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"r_l_ramie",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"r_l_dlon",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"r_p_bark",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"r_p_ramie",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"r_p_dlon",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"joint75",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"joint70",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"joint77",0,0,0)
		self:BindFX("lucyferhead_fx", 1.0,"joint80",0,0,0)

		--self._trail = ENTITY.Create(ETypes.Trail,self.swordTrail,"trailName")
		--ENTITY.AttachTrailToBones(self._Entity,self._trail,"emiter_miecz_1","emiter_miecz_2","emiter_miecz_3","emiter_miecz_4",
		--	"emiter_miecz_5","emiter_miecz_6","emiter_miecz_7","emiter_miecz_8","emiter_miecz_9")
		--WORLD.AddEntity(self._trail)
	end
end

function Lucifer:UnBindParticles()
	--ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end



function Lucifer:OnCreateEntity()
    self._disableHits = true
	self._MegaBossHealthMax = self.Health
	Game.MegaBossHealth = self.Health	
    self._delayExplTime = 10
    self._lastTimeDamage = 0
    if debugMarek then
		self._ABdo = true
	end
end

--function Lucifer:OnApply()
	--self:PlayRandomSound2D({"Lucifer_ambient-stereo1","Lucifer_ambient-stereo2","Lucifer_ambient-stereo3",})
	--self._flySound = self:BindSound("actor/Lucifer/Lucifer_fly-loop",16, 60, true)
--end

function Lucifer:CustomOnDeath()
	self.notBleeding = true
	Game.MegaBossHealthMax = nil
	Game.MegaBossHealth = nil
	if debugMarek then Game:Print("lucifer death "..Lev._demonfx.TickCount) end
	Game._EarthQuakeProc:Add(Player._groundx,Player._groundy,Player._groundz, self.demonFXTimeAfterDeath*30, 999, 0.27, 0.27, 1.0)	

	if Lev._demonfx then
		Lev._demonfx.TickCount = Lev._demonfx.EffectTime - self.demonFXTimeAfterDeath		-- moze zle dzialac
		Game:Print("Lev._demonfx.TickCount "..Lev._demonfx.TickCount.." "..Lev._demonfx.EffectTime)

		--if self.bulletTimeAfterDeath and not Game.BulletTime then
            --Game.BulletTime = true
            --Game:Print("BTAIME")
            --Game._BTimeProc = AddObject(PBulletTimeControler:New(self.bulletTimeAfterDeath,0.2,20.0,0.2),nil,nil,nil,true)
            --WORLD.SetWorldSpeed(self.bulletTimeAfterDeath)
		--end

	end
	SOUND.Play2D("actor/alastor/alastor_death")
    --ENTITY.SetVelocity(self._Entity, 0, self.velocityUpOnDeath, 0)
end

function Lucifer:CustomDelete()
	if self._procStoneThrow then
		GObjects:ToKill(self._procStoneThrow)
		self._procStoneThrow = nil
	end
end


function Lucifer:CustomOnDamage(he,x,y,z,obj,damage,type,nx,ny,nz)
	if debugMarek then
		return false
	end
	

	if type == AttackTypes.Stone then
		if not self._ABdo then
			if debugMarek then Game:Print("1 damage "..self.Health.." "..damage) end
			if self._HealthMax * 0.5 < self.Health then
				self._ABdo = true
				self:PlaySound("hit")
				self:Stop()
				if self.Health - damage <= 0 then
					self.Health = damage + 1.0
				end
			end
			return false
		else
			if obj and obj.Model == "lucy_sword" then
				--Game:Print("2 damage")
				return false
			end
		end
	end
	return true
end
 


-----------------
Lucifer._CustomAiStates = {}

Lucifer._CustomAiStates.idleLucifer = {
	lastTimeAmbientSound = 0,
	lastAmbient = 1.0,
	name = "idleLucifer",
}
function Lucifer._CustomAiStates.idleLucifer:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor:Stop()
	--Game:Print("L:idle oninit")
end

function Lucifer._CustomAiStates.idleLucifer:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if self.lastAmbient + 1.0 < brain._currentTime then
		local tabl = aiParams.actions
		Game:Print("losowanie check "..brain._currentTime)
		self.lastAmbient = brain._currentTime
		self._submode = nil
		local mul = 1.0
		--if actor._damage then
		--	mul = 1.2			-- jak dostanie hita to chetniej losuje ataki
		--	actor._damage = false
		--end
		for i,v in tabl do
			if FRand(0.0, 1.0) < v[2] * mul then
				self._submode = v[1]
				break
			end
		end

		if self._submode then
			Game:Print("losowanie "..self._submode)
			brain._submode = self._submode
			return
		end
		actor._damage = false
	end

	--actor._CANWALK = true
end

function Lucifer._CustomAiStates.idleLucifer:OnRelease(brain)
	local actor = brain._Objactor
	brain._rotate180AfterEndWalking = nil
	--actor._CANWALK = false
end

function Lucifer._CustomAiStates.idleLucifer:Evaluate(brain)
	return 0.01
end


------------
Lucifer._CustomAiStates.attackLucifer = {
	name = "attackLucifer",
	active = false,
}

function Lucifer._CustomAiStates.attackLucifer:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.mode = -1
	actor:RotateToVectorWithAnim(Player._groundx,0,Player._groundz)
	Game:Print("czas demona... "..Lev._demonfx.TickCount.." "..Lev._demonfx.EffectTime)
	if Lev._demonfx.TickCount > Lev._demonfx.EffectTime - 3.0 then
		Lev._demonfx.TickCount = Lev._demonfx.TickCount - 10.0
	end
	self.active = true
	if not actor._ABdo then
		Game:Print("ATTACK:brain._distToNearestEnemy "..brain._distToNearestEnemy)
	else
		Game:Print("ATTACK AB:brain._distToNearestEnemy "..brain._distToNearestEnemy)
	end

	if brain._distToNearestEnemy > 48 then
		if actor._ABdo and brain._distToNearestEnemy < 60 then
			self.mode = 2
		else
			self.mode = 0
		end
	else
		if brain._distToNearestEnemy < 24 or math.random(100) < 25 then
			Game:Print("za blisko do ataku -> walk "..brain._distToNearestEnemy)
			self.mode = 2
		else
			Game:Print("za blisko do ataku -> close attack")
			self.mode = 5
		end
	end
end

function Lucifer._CustomAiStates.attackLucifer:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 and not actor._isRotating then
		if actor._ABdo then
			self._anim = "atak_throw"
			actor:RotateToVector(Player._groundx,0,Player._groundz)
		else
			if math.random(100) < 60 then
				self._anim = "atak_meteory"
			else
				self._anim = "atak_wbija_miecz"
			end
		end
		actor:SetAnim(self._anim,false)
		self.mode = 1
	end
	if self.mode == 1 and (not actor._isAnimating or actor.Animation ~= self._anim) then
		if actor._ABdo then
			Game:Print("po ataku "..actor.Health)
			if not debugMarek then
				actor._ABdo = false
			end
			actor.Health = actor._HealthMax
		end
		self.timer = FRand(16,30)
		self.mode = 3
		--Game.freezeUpdate = true
		return
	end
	if self.mode == 2 and not actor._isRotating then
		self.active = false
		Game:Print("za blisko - walk")
		brain._submode = "walk"
		return
	end
	if self.mode == 5 and not actor._isRotating then
		self.active = false
		Game:Print("za blisko - close attack")
		brain._submode = "close"
		--Game.freezeUpdate = true
		return
	end

	if self.mode == 3 then
		self.timer = self.timer - 1
		if self.timer < 0 then
			brain._submode = "walk"
			Game:Print("walk after attack?")
			self.active = false
		end
	end

end

function Lucifer._CustomAiStates.attackLucifer:OnRelease(brain)
	local actor = brain._Objactor
	--brain._bonusToWalk = 0.1
	self.active = nil
end

function Lucifer._CustomAiStates.attackLucifer:Evaluate(brain)
	if self.active or brain._submode == "attack" then
		return 0.3
	end
	return 0
end


--------------

Lucifer._CustomAiStates.walkLucifer = {
	name = "walkLucifer",
	active = false,
}

function Lucifer._CustomAiStates.walkLucifer:OnInit(brain)
	local actor = brain._Objactor
	brain._bonusToWalk = 0.0
	brain._submode = nil
	self.mode = 0
	if actor._ABdo then
		Game:Print("abdo mode a walk "..brain._distToNearestEnemy)
		if brain._distToNearestEnemy > 42 then
			return
		end
	end
	self.active = true
	actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
	self.canAttack = true
	if math.random(100) < 70 then
		self.canAttack = false
	end
end

function Lucifer._CustomAiStates.walkLucifer:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 and not actor._isRotating then
		Game:Print("distToEnemy = "..brain._distToNearestEnemy)

		actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
		local v = Vector:New(math.sin(actor._angleDest), 0, math.cos(actor._angleDest))
		v:Normalize()
		local backward = false
		local dist = brain._distToNearestEnemy * FRand(1.5, 2.0)
		if dist < 40 then
			if math.random(100) < 65 then
				dist = 40 + FRand(10,30)
			else
				backward = true
				dist = -(40-dist + FRand(20,30))
			end
			Game:Print(">>>>>> gracz blisko "..dist)
			--Game.freezeUpdate = true
		end
		----------
		if debugMarek then
			actor.d1, actor.d2, actor.d3 = actor._groundx, actor._groundy + 18, actor._groundz
			actor.d4, actor.d5, actor.d6 = actor._groundx + v.X*(dist+25), actor._groundy + 18, actor._groundz + v.Z*(dist+25)
		end
		
		local b,d = WORLD.LineTraceFixedGeom(actor._groundx, actor._groundy + 18, actor._groundz, actor._groundx + v.X*(dist+25), actor._groundy + 18, actor._groundz + v.Z*(dist+25))
		if d then
			Game:Print("walk col! "..d)
			if d > 50 then
				dist = d - 30
			else
				Game:Print("d <= 50")
				self.active = false
				return
			end
		end
		-------
		if debugMarek then
			actor.yaadebug1, actor.yaadebug2, actor.yaadebug3 = actor._groundx + v.X*(dist+25), actor._groundy + 20, actor._groundz + v.Z*(dist+25)
			actor.yaadebug4, actor.yaadebug5, actor.yaadebug6 = actor._groundx + v.X*(dist+25), actor._groundy - 50, actor._groundz + v.Z*(dist+25)
		end
		-- ! jeszcze trace w dol, -16, czy nie wejdzie do wody
		local b,d,x,y,z = WORLD.LineTraceFixedGeom(actor._groundx + v.X*(dist+25), actor._groundy + 20, actor._groundz + v.Z*(dist+25), actor._groundx + v.X*(dist+25), actor._groundy - 50, actor._groundz + v.Z*(dist+25))
		if d then
			Game:Print("LEVEL Y = "..y)
			if y < -16 then
				Game:Print("y < -16")
				self.active = false
				return
			end
			--Game.freezeUpdate = true
		else
			--Game.freezeUpdate = true
			Game:Print("no LEVEL Y!!!")
			self.active = false
			return
		end
		
		if backward and dist < 0 then
			dist = -dist
		end
		actor:WalkForward(dist,nil, nil, nil, nil, nil, nil, backward)
		self.mode = 1
	end
	
	if self.mode == 1 and not actor._isWalking then
		actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
		self.mode = 2
	else
		-- if dist to enemy, to close attack
		if self.canAttack and brain._distToNearestEnemy > 28 and brain._distToNearestEnemy < 44 then
			--Game:Print("w zas "..brain._distToNearestEnemy)
			local v = Vector:New(Player._groundx - actor._groundx, 0, Player._groundz - actor._groundz)
			v:Normalize()
			local angleToPlayer = math.atan2(v.X, v.Z)
			local angDist = AngDist(actor.angle, angleToPlayer)
			--Game:Print("KATY, atoP "..(angleToPlayer*180/math.pi).." "..(actor.angle*180/math.pi).." "..(angDist*180/math.pi))
			if math.abs(angDist) < 26*math.pi/180 then
				brain._submode = "close"
				self.active = false
				actor:Stop()
				--Game.freezeUpdate = true
				return
			end
		end
		--
	end
	
	if self.mode == 2 and not actor._isRotating then
		self.active = false
		return
	end
end

function Lucifer._CustomAiStates.walkLucifer:OnRelease(brain)
	local actor = brain._Objactor
	actor:FullStop()
	self.active = nil
end

function Lucifer._CustomAiStates.walkLucifer:Evaluate(brain)
	if self.active or brain._submode == "walk" then
		return 0.3
	end
	return 0
end



-------------[[
function Lucifer:OnTick(delta)

--- cheat ---
--	if INP.Key(Keys.PgUp) == 1 then 
--		self:OnDamage(1500, Player,nil,nil,nil,nil,AttackTypes.Rocket,nil,nil,0)
--		Game:Print("DAMAGE Lucifer")
--	end
-------------
	
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
			if self._flying then
				y = y + 2
			else
				y = y + 6
			end

			self.DEBUGl1 = x + v.X
			self.DEBUGl2 = y
			self.DEBUGl3 = z + v.Z
			WORLD.Explosion2(x+v.X, y, z+v.Z, 5000, --[[range--]]8,nil,AttackTypes.Rocket,self.AiParams.walkDamage)
		end
	end
	
	if self._selfrotate then
		self.angle = self.angle + self.fallingRotateSpeed * delta
		self._angleDest = self.angle
		ENTITY.SetOrientation(self._Entity,self.angle)
	end
end
--]]


function Lucifer:Stomp(joint, modif, disableExpl)
	local p = modif
	if not p then
		p = 1.0
	end
	local x,y,z = self:GetJointPos(joint)
	Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange * p, self.CameraMov * p, self.CameraRot * p, 1.0)
	if not disableExpl then
		WORLD.Explosion2(x, y, z, 5000, self.AiParams.walkDamageRange, nil,AttackTypes.Rocket,self.AiParams.walkDamage)
	end
	if debugMarek then
		DebugSphereX = x
		DebugSphereY = y
		DebugSphereZ = z
		DebugSphereRange = self.AiParams.walkDamageRange
	end
    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
    AddPFX('but',0.8,Vector:New(x,y,z))
end




-----------------
Lucifer._CustomAiStates.closeAttackLucifer = {
	name = "closeAttackLucifer",
}
function Lucifer._CustomAiStates.closeAttackLucifer:OnInit(brain)
	local actor = brain._Objactor
	actor:SetAnim("atak_sword", false)
	brain._submode = nil
	self.active = true
	actor:RotateToVector(Player._groundx,0,Player._groundz)
end

function Lucifer._CustomAiStates.closeAttackLucifer:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if not actor._isAnimating or actor.Animation ~= "atak_sword" then
		self.active = false
	else
		if math.random(100) < 5 then
			actor:RotateToVector(Player._groundx,0,Player._groundz)
		end
	end
end

function Lucifer._CustomAiStates.closeAttackLucifer:OnRelease(brain)
	local actor = brain._Objactor
end

function Lucifer._CustomAiStates.closeAttackLucifer:Evaluate(brain)
	if self.active or brain._submode == "close" then
		return 0.1
	end
	return 0
end

function Lucifer:OnTick()
	if self._lastTimeDamage + 1.5 < self._AIBrain._currentTime then
		if self.Animation == "atak_sword" then
			for i=5,9 do
				local x,y,z = self:GetJointPos("emiter_miecz_"..i)
				--WORLD.Explosion2(x,y,z, --[[self.Explosion.ExplosionStrength--]]1000,--[[self.Explosion.ExplosionRange--]]5,
				--nil,AttackTypes.Rocket,--[[self.Explosion.Damage--]]100)
				local dist = Dist3D(x,y,z,Player._groundx,Player._groundy + FRand(0.5,1.5),Player._groundz)
				local range = self.AiParams.swordDamageRange
				if dist < range then
					self._lastTimeDamage = self._AIBrain._currentTime
					--Game:Print("DDD dist to sword = "..dist)
					Player:OnDamage(self.AiParams.swordDamage,self,AttackTypes.AIClose)
					break
				end
			end
		end
	end
end

--[[function Lucifer:CheckSwordDamage(joint)
	local aiParams = self.AiParams
	--Game.freezeUpdate = true
	local range = aiParams.swordDamageRange
	local x,y,z = self:GetJointPos(joint)
	local dist = Dist3D(x,y,z,Player._groundx,Player._groundy,Player._groundz)
	Game:Print("dist to sword = "..dist)
	if dist < range then
		Player:OnDamage(aiParams.swordDamage,self,AttackTypes.AIClose)
	end
end
--]]

function Lucifer:OnThrow()
	--Game:Print("onthrow")
	self._sword = self._objTakenToThrow
	self:UnBindParticles()
	self:FullStop()
end

function Lucifer:EndSword()
	if self._sword then
		GObjects:ToKill(self._sword)
		self._sword = nil
	end
	MDL.SetMeshVisibility(self._Entity, self.AiParams.hideMesh, true)
	self:BindParticles()
end

function Lucifer:CreateStonesGround()
	local s = self.AiParams.stonesUp
    local j = math.random(s.count*0.6, s.count)	
	for i=1,j do
		local angle = math.random(0,360)
		local x = math.sin(angle) + math.cos(angle)
		local z = math.cos(angle) - math.sin(angle)
		local d = FRand(s.distMin, s.distMax)
		x = Player._groundx + x * d
		y = Player._groundy
		z = Player._groundz + z * d
		--Game:Print("createstonesground")
		
		local zn,idx = WPT.GetClosest(x,y,z)  
		if idx > -1 then
			local x,y,z = WPT.GetPosition(zn,idx)    
  			--local speed = -Templates["LuciferStone.CItem"].FallSpeed		-- pozniej inna speed
  			local speed = 100
	  		
			local v = Vector:New(0,1,0)
			v:Normalize()

			local a = s.randomizeAngle * math.pi/180
			
			--local rnd = FRand(0.95,1.05)
			local x1,y1,z1 = x,y - 5,z
			local ke,obj = AddItem("LuciferStone.CItem",nil,Vector:New(x1,y1,z1),true)
			local dist = Dist2D(x1,z1,Player._groundx,Player._groundz)
			--local dist = Dist3D(x1,y1,z1,Player._groundx,Player._groundy,Player._groundz)
			local angleXY = math.atan2(Player._groundz - z1,Player._groundx - x1) + FRand(-a, a)
			local x2,y2,z2,v = CalcThrowVectorGivenAngle(dist, s.angle + FRand(-1,1), angleXY, 0--[[(Player._groundy+1.2) - y1--]])
			-- Game:Print("vel = "..v.." "..(angleXY*180/math.pi))
			obj._desiredVel = Vector:New(x2,y2,z2)
			if v < 40 then
				obj._desiredVel:Normalize()
				obj._desiredVel:MulByFloat(40)
			end
			
			obj._desiredVel:MulByFloat(FRand(s.velocityMin, s.velocityMax))
			obj._enableGrav = true
			obj.timer = 0
		end
	end
end

function Lucifer:CreateStones()
	local s = self.AiParams.stonesDown
	local j = math.random(s.count*0.7, s.count)
	--Game:Print("create stones "..j)

	local speed = -Templates["LuciferStone.CItem"].FallSpeed
	for i=1,j do
		local angle = math.random(0,360)
		local x = math.sin(angle) + math.cos(angle)
		local z = math.cos(angle) - math.sin(angle)
		local d = FRand(s.distMin,s.distMax)
		x = Player._groundx + x * d
		y = self._groundy + 300 + FRand(-15,15)
		z = Player._groundz + z * d
		local v = Vector:New(x - Player._groundx, y - Player._groundy, z - Player._groundz)
		v:Normalize()

		local rnd = FRand(0.95,1.05)
		local ke,obj = AddItem("LuciferStone.CItem",nil,Vector:New(x + FRand(-15,15),y + FRand(-15,15),z + FRand(-15,15)),true)
		obj._desiredVel = Vector:New((v.X + FRand(-0.005,0.005))* speed*rnd, v.Y * speed*rnd, (v.Z + FRand(-0.005,0.005)) * speed*rnd)
	end
end

function Lucifer:GetThrowItemRotation()
	local q = Quaternion:New()
	q:FromEuler( 0, -self.angle, 0)
	return q
end
