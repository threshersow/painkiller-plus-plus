function Swamp:OnPrecache()
	MATERIAL.Create("Special/empty")
	MATERIAL.Create("Models/swampsw")
	if debugMarek then
		Game._StoneX = 0
	end
end

function Swamp:CustomOnDamage(he,x,y,z,obj,damage,type)
	if type == AttackTypes.Bubble then
		local brain = self._AIBrain
		if debugMarek then Game:Print("bubble damage") end
		if brain._ABdone and not brain._ABdone1 and self._afterAB then
			brain._ABdone1 = true		-- czy wlasnie gasi
			brain._ABdoNEXT = true		-- gasi
			if debugMarek then Game:Print("CIEMNIEJE1") end
			self:ABeffectON()
			return true		-- true - CActor nie obsluguje dalej damage
		end
		if debugMarek then Game:Print("  SWAMP DAMAGE BUBBLE") end
		return false
	end

	--self._currentWaterImpact = 0
	--self._waterImpact = {}

    if he and not self._ABeffectON then

        local t,e,j = PHYSICS.GetHavokBodyInfo(he)

		self._currentWaterImapct = self._currentWaterImapct + 1
		if self._currentWaterImapct > 2 then
			self._currentWaterImapct = 0
		end
		
		-------------
		if not self._waterImpact[self._currentWaterImapct] then
   			local ke,obj = AddItem("StoneX.CItem",nil,Vector:New(x,y,z),true)
			obj.ObjOwner = self
			obj._no = self._currentWaterImapct
			ENTITY.ComputeChildMatrix(ke,e,j)
			ENTITY.RegisterChild(e,ke,true,j)
			self._waterImpact[self._currentWaterImapct] = obj
		else 
			local objOLD = self._waterImpact[self._currentWaterImapct]
			if objOLD._canKillme then
				GObjects:ToKill(objOLD)
   				local ke,obj = AddItem("StoneX.CItem",nil,Vector:New(x,y,z),true)
   				
				obj.ObjOwner = self
				obj._no = self._currentWaterImapct
				ENTITY.ComputeChildMatrix(ke,e,j)
				ENTITY.RegisterChild(e,ke,true,j)
				self._waterImpact[self._currentWaterImapct] = obj
			end
		end

		-------------

	end
	
	self:PlaySound(self.s_SubClass.Sounds.hitsSplash, 60, 300)
	if self._canGetNormalDamage then
		if debugMarek then Game:Print("  SWAMP DAMAGE OK") end
		return false
	end
	return true
end

function Swamp:CreateTentacle(anglePlus)
	if not self.AIenabled then return end
	local v = Vector:New(Player._groundx, 0, Player._groundz)

	if debugMarek then	
		self.yadebug1 = Player._groundx 
		self.yadebug2 = 0
		self.yadebug3 = Player._groundz
		self.yadebug4 = 0
		self.yadebug5 = 0
		self.yadebug6 = 0
	end
		
	local dist
	local distPlayerFromCentre = v:Len()
	if distPlayerFromCentre < 0.01 then
		Game:Print("gracz jest w srodku")
		distPlayerFromCentre = 0
		v = Vector:New(self._groundx, 0, self._groundz)
	end
	v:Normalize()

	-- tu srp. czy nie ten sam kat co potwor
	local aPl = math.atan2(Player._groundx,Player._groundz)
	local aEn = math.atan2(self._groundx,self._groundz)
	local aDist = AngDist(aPl,aEn+anglePlus)
	--Game:Print("aPl "..aPl.." , aEn "..aEn)

	if math.abs(aDist) > 0.4 then
		local angle = FRand(-0.2, 0.2)+ anglePlus
		--Game:Print("  ## MACKA angle = "..angle)
		v.X,v.Y,v.Z = VectorRotate(v.X, v.Y, v.Z, 0, angle,0)	
	else
		local amount = FRand(0.35, 0.45) + anglePlus
		--Game:Print("  ## MACKA angle = "..amount)
		if aDist < 0 then
			amount = -amount
		end
		--self.DEBUG_P4 = v.X * 34
		--self.DEBUG_P5 = 61
		--self.DEBUG_P6 = v.Z * 34
		v.X,v.Y,v.Z = VectorRotate(v.X, v.Y, v.Z, 0, amount,0)	
	end
	if distPlayerFromCentre < 34 then
		-- pozniej rotate lewo/prawo o kilka stopni - potzrebne bedzie do dwoch rak
		--Game:Print("&**& player jest na kamieniach "..aDist)
		dist = FRand(32,34) + distPlayerFromCentre * 0.5
	else
		-- player jest dalej
		--Game:Print("&**& player jest dalej "..aDist)
		dist = FRand(32,34) + distPlayerFromCentre
		if dist > 80 then
			dist = 80
		end
	end
	v:MulByFloat(dist)

	local obj = GObjects:Add(TempObjName(),CloneTemplate("SwampTentacle.CActor"))
	obj.Pos.X = v.X
	obj.Pos.Y = 61
	obj.Pos.Z = v.Z
	obj:Apply()
end


function Swamp:OnDeathUpdate()
	if self._deathTimer then
		if self._deathTimer > 0 then
			self._deathTimer = self._deathTimer - 1
		else
			ENTITY.EnableDraw(self._Entity, false)
			MDL.SetPinned(self._Entity, true)
			self._deathTimer = nil
		end
	end
	
	if self._timerToDemon then
		self._timerToDemon = self._timerToDemon - 1
		if self._timerToDemon <= 0 then
			if debugMarek then Game:Print("E demon") end
			self._demonfx = Game:EnableDemon(true, 10, false, 0.25)
			if debugMarek then Game:Print("E demon2") end
			self._timerToDemon = nil
		end
	else
		if self._demonfx and self._demonfx.TickCount > self._demonfx.EffectTime - 1.0 then
			self._demonfx = nil
			GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		end
	end
end

function Swamp:CustomOnDeath()
	Game.MegaBossHealthMax = nil
	Game.MegaBossHealth = nil
	for i,v in self._waterImpact do
		GObjects:ToKill(v)
	end
	for i,v in self._objONWaterImpact do
		GObjects:ToKill(v)
	end
    if self._bubbles then
        for i,v in self._bubbles do
            GObjects:ToKill(v)
        end
    end
	self._waterImpact = nil
	self._objONWaterImpact = nil
	
    self._disableDemonic = true
	self._timerToDemon = 4
end


function Swamp:CustomDelete()
    if LEVEL_RELEASING then return end
	self:BindFX("explo_bUble", 2.0, "root")
	PlaySound2D("actor/swamp/Swamp_bubbleIgnite")
end

function Swamp:CustomOnHit(damage)
	local brain = self._AIBrain
	if not brain._ABdone and not brain._ABdo then
		if self._HealthMax * self.ABHp > self.Health then
			Game:Print("SWAMP AB")
			brain._ABdo = true
		end
	end

	self._damage = true
	if self._lastPlayedDamage + 1.5 < brain._currentTime then
		self._lastPlayedDamage = brain._currentTime
		self:PlayRandomSound2D(self.s_SubClass.Sounds.hits)
	end
end

function Swamp:OnInitTemplate()
    self:SetAIBrain()
    self._lastTimeMethan = 0
end

function Swamp:DisturbWater(x,y,z)
	local obj = self._objONWaterImpact[self._currentCircle]
	if not obj then
		if water then
   			local ke,obj
   			if not z then
   				ke,obj = AddItem("StoneX.CItem",nil,Vector:New(self._groundx,61,self._groundz),true)
   			else
   				ke,obj = AddItem("StoneX.CItem",nil,Vector:New(x,61,z),true)
   			end
	   		
	   		
			obj.ObjOwner = water
			obj._amp = 0
			obj.impAmplitude = self.waterWALKImpAmplitude
			obj.impPeriod = self.waterWALKImpPeriod
			obj.impRange = self.waterWALKImpRange
			obj.impSpeed = self.waterWALKImpSpeed
			obj.speedUp = 0.5
			obj.speedDown = 2.0
			obj._no = self._currentCircle
			obj._notBinded = true
			-------------
			self._objONWaterImpact[self._currentCircle] = obj
		end
	else
		obj.Pos.X,obj.Pos.Y, obj.Pos.Z = self._groundx,61,self._groundz
		ENTITY.SetPosition(obj._Entity,obj.Pos.X,obj.Pos.Y, obj.Pos.Z)
		obj._amp = 0
		obj._canKillme = false
		obj._up = true
	end
	self._currentCircle = self._currentCircle + 1
	if self._currentCircle > 2 then
		self._currentCircle = 0
	end
end


function Swamp:ThrowBubble()
	local brain = self._AIBrain
    local aiParams = self.AiParams

	local idx  = MDL.GetJointIndex(self._Entity,"bru1")
	local x,y,z = MDL.GetJointPos(self._Entity,idx)
	local ke,obj = AddItem("BubbleV2.CItem",nil,Vector:New(x,y,z),true)

	obj:BindSound("actor/swamp/Swamp_bubbleFlying-loop",30,120,true)

	local x2,y2,z2 = Player._groundx, Player._groundy, Player._groundz
	
	local distToTarget = Dist3D(x2,0,z2, x,0,z)
    local minus = self.throwDistMinus
    if not minus then
        minus = 0
    end
	if distToTarget < 4 then
		distToTarget = 4
	end

	local angleXZ = math.atan2(Player._groundz - self._groundz, Player._groundx - self._groundx)
	local x,y,z = CalcThrowVectorGivenAngle(distToTarget - minus, aiParams.bubbleThrowAngle, angleXZ, (Player._groundy + 1.6) - y)

	if debugMarek then					
		self.d1 = self._groundx + x
		self.d2 = self._groundy + y
		self.d3 = self._groundz + z
		self.d4 = self._groundx
		self.d5 = self._groundy
		self.d6 = self._groundz
	end
	ENTITY.SetVelocity(ke,x,y,z)

end

function Swamp:OnCreateEntity()
	self._lastPlayedDamage = 0
	self._bindedPos = {}
	self._addSome = 0
	self._currentWaterImapct = 0
	self._currentCircle = 0
	self._objONWaterImpact = {}

	self._currentWaterImpact = 0
	self._waterImpact = {}

	self._oldRagdollColGroup = MDL.GetRagdollCollisionGroup(self._Entity)
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.Noncolliding)
	Game.MegaBossHealthMax = self.Health
	Game.MegaBossHealth = self.Health	
end       
 
function Swamp:CustomUpdate()
    local brain = self._AIBrain
    Game.MegaBossHealth = self.Health
    if self._startBubblesIn then
		self._startBubblesIn = self._startBubblesIn - 1
		if self._startBubblesIn < 0 then
			self._startBubblesIn = nil
   			for i,v in self._bubbles do
				ENTITY.EnableDraw(v._Entity, true)
				v._disabled = false
			end
		end
	end

	-- losowanie babelkow
	if not brain._ABdone and self._lastTimeMethan + self.minTimeBetweenBubble < Game.currentTime then
		self._lastTimeMethan = Game.currentTime + math.random(0,3)
		local angle = math.random(0,360)
		local x = math.sin(angle) + math.cos(angle)
		local z = math.cos(angle) - math.sin(angle)
		local y = 60
		local dist
		local chance = 0
		--if debugMarek then
		--	chance = 50
		--end
		if math.random(100) < chance then
			-- kolo kolesia:
			dist = FRand(4, 12)
			x = x * dist + self._groundx
			z = z * dist + self._groundz
		else
			-- przypadkowo
			dist = FRand(40, 76)
			x = x * dist
			z = z * dist
		end

		-- babelki wokol bossa
		local scales = {0.7,0.9,1.2,1.5}
		local scale = scales[math.random(1,4)]
		local obj,e = AddObject("Bubble.CItem",scale,Vector:New(x,y,z),r,true) 
		obj._scale = scale
		obj._CurAnimIndex = MDL.SetAnim(e,"wyplywa",false, 1.0, 0.0)
		if math.random(100) < 25 then
			PlaySound3D("actor/Swamp/Swamp_bubbleOut"..math.random(1,3), x,y,z, 40, 160)
		end
		obj.ObjOwner = self
	end

end




-----------------
Swamp._CustomAiStates = {}
Swamp._CustomAiStates.idleSwamp = {
	lastTimeAmbientSound = 0,
	lastAmbient = 1.0,
	name = "idleSwamp",
}
function Swamp._CustomAiStates.idleSwamp:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor:Stop()
end

function Swamp._CustomAiStates.idleSwamp:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if not actor._isRotating then
		if self.lastAmbient + 1.0 < brain._currentTime then
			--Game:Print("losowanie check "..brain._currentTime)
			self.lastAmbient = brain._currentTime
			local tabl = aiParams.actions
			self._submode = nil
			local mul = 1.0
			if actor._damage then
				mul = 1.2			-- jak dostanie hita to chetniej losuje ataki
			end
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
	end
	actor._CANWALK = true
end

function Swamp._CustomAiStates.idleSwamp:OnRelease(brain)
	local actor = brain._Objactor
	brain._rotate180AfterEndWalking = nil
	actor._CANWALK = false
	Game:Print("idle release")
end

function Swamp._CustomAiStates.idleSwamp:Evaluate(brain)
	return 0.01
end

------------
Swamp._CustomAiStates.waterBall = {
	name = "waterBall",
	active = false,
}

function Swamp._CustomAiStates.waterBall:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.mode = 0
	local dist = math.sqrt(actor._groundx*actor._groundx+actor._groundz*actor._groundz)
	Game:Print("waterBall dist = "..dist)
	self.active = true
	--if dist > actor.AiParams.walkRadiusMin + 30 then
	--	Game:Print("water ball OK")
	--	actor:WalkTo(0,0,0,false, 14)			-- pozniej spr. odleglosci
	--else
		Game:Print("water ball too close ~")
		-- rotate
		actor:RotateToVectorWithAnim(0,0,0)
	--end
end

function Swamp._CustomAiStates.waterBall:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 then
		if not actor._isWalking and not actor._isRotating then
			Game:Print("2, waterBall dist = "..(Dist3D(actor._groundx, 0 ,actor._groundz, 0, 0, 0)))
			actor:SetAnim("atak1",false)
			self.mode = 1
		end
	end
	if self.mode == 1 then
		if (not actor._isAnimating or actor.Animation ~= "atak1") then
			if math.random(100) < 50 then
				actor:RotateWithAnim(90)
			else
				actor:RotateWithAnim(-90)
			end
			self.mode = 2
		end
	end
	if self.mode == 2 then
		if not actor._isRotating then
			self.active = false
		end
	end
end

function Swamp._CustomAiStates.waterBall:OnRelease(brain)
	self.active = nil
end

function Swamp._CustomAiStates.waterBall:Evaluate(brain)
	if self.active or brain._submode == "waterBall" then
		return 0.3
	end
	return 0
end



------------
Swamp._CustomAiStates.waterHand = {
	name = "waterHand",
	active = false,
}

function Swamp._CustomAiStates.waterHand:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.mode = 0
	local dist = math.sqrt(actor._groundx*actor._groundx+actor._groundz*actor._groundz)
	self.active = true
	--if dist > actor.AiParams.walkRadiusMin + 30 then
	--	Game:Print("water hand OK "..dist)
	--	actor:WalkTo(0,0,0,false, 14)			-- pozniej spr. odleglosci
	--else
		Game:Print("water hand too close "..dist)
		-- rotate
		--Game.freezeUpdate = true
		actor:RotateToVectorWithAnim(0,0,0)		-- pozniej PLAYER
	--end
end

function Swamp._CustomAiStates.waterHand:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
	if self.mode == 0 then
		if not actor._isWalking and not actor._isRotating then
			actor:SetAnim(aiParams.FarAttack,false)
			self.mode = 1
		end
	end
	if self.mode == 1 then
		if (not actor._isAnimating or actor.Animation ~= aiParams.FarAttack) then
			self.active = nil
		end
	end
end

function Swamp._CustomAiStates.waterHand:OnRelease(brain)
	self.active = nil
end

function Swamp._CustomAiStates.waterHand:Evaluate(brain)
	if self.active or brain._submode == "waterHand" then
		return 0.3
	end
	return 0
end


function Swamp:OnTick(delta)
	local actor = self				-- narazie
	if debugMarek and Game.freezeUpdate then
		return
	end

	if not self._rotatingWithAnim then
		if not actor._isWalking and actor._CANWALK then
			local aiParams = self.AiParams

			local zakres = 0.15
			local zakres2 = 0.0
			local pointFound = false
			local angle2 = math.atan2(actor._groundz - 0, actor._groundx - 0)
			local adist = (AngDist(angle2, actor.angle))
			--Game:Print((actor.angle*180/math.pi).." "..(angle2*180/math.pi).."   AngDist = "..(adist*180/math.pi))
			local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
			v:Normalize()
			local x1 = actor._groundx + v.X
			local y1 = actor._groundz + v.Z
			local d1 = math.sqrt(actor._groundz*actor._groundz + actor._groundx*actor._groundx)
			local d2 = math.sqrt(x1*x1+y1*y1)
			local p = ((0 - actor._groundz) * (x1 - actor._groundx) - (0 - actor._groundx) * (y1 - actor._groundz))/d1
			--Game:Print(p)
			if math.abs(p) < 0.3 then
				-- rotate -
				if (d1 > d2 and p > 0) or (d1 < d2 and p < 0) then
					Game:Print("za duzy zakres to rotate + "..d1.." "..d2)
					actor:RotateWithAnim(45)
				end
				if (d1 < d2 and p > 0) or (d1 > d2 and p < 0) then
					Game:Print("za duzy zakres to rotate - "..d1.." "..d2)
					actor:RotateWithAnim(-45)
				end
				pointFound = true
			end

			local bonusDist = 0.0
			
			while not pointFound do	
				
				local angle
				if p < 0.0 then
					angle = FRand(-zakres2,zakres) + actor.angle
				else
					angle = FRand(-zakres,zakres2) + actor.angle
				end

				local v = Vector:New(math.sin(angle), 0, math.cos(angle))
				v:Normalize()
				local dist = FRand(3.0, 3.5) + bonusDist
				local x,y,z
				x = v.X * dist + actor._groundx
				z = v.Z * dist + actor._groundz

				--if debugMarek then			
				--	table.insert(actor.debugHIT, {x, actor._groundy + 1, z})
				--end
				local dist = math.sqrt(x*x+z*z)

				if dist > aiParams.walkRadiusMin and dist < aiParams.walkRadiusMax then
					--Game:Print("search point OK = "..zakres.." "..zakres2)
					pointFound = true
					--Game:Print("can and walk "..self._AIBrain._currentTime)
					actor:WalkTo(x, actor._groundy, z)
				end
				zakres = zakres + 0.1
				zakres2 = zakres2 + 0.05
				if zakres> math.pi/4 then
					zakres = math.pi/4
				end
				if zakres2 > math.pi/4 then		-- 0.78 
					Game:Print("zakres przekroczony "..p)
					--[[if (d1 > d2) then
						self._AIBrain._submode = self.AiParams.actions[1]		-- pozniej gdzies indziej
						Game:Print("ZA BLISKO -submode "..self._AIBrain._submode)
						self._CANWALK = false
						break
					end--]]
					
					if math.abs(p) < 0.7 then
						if (d1 > d2 and p > 0) or (d1 < d2 and p < 0) then
							Game:Print("2 to rotate + "..d1.." "..d2)
							actor:RotateWithAnim(45)
							break
						end
						if (d1 < d2 and p > 0) or (d1 > d2 and p < 0) then
							Game:Print("2 to rotate - "..d1.." "..d2)
							actor:RotateWithAnim(-45)
							break
						end
					end
					--Game.freezeUpdate = true
					if bonusDist > 20 then
						Game:Print("do nothing ++")
						self:Stop()
						break
					else
						bonusDist = bonusDist + FRand(8,10)
						Game:Print("BONUS ++ "..bonusDist)
						zakres = 0.15
						zakres2 = 0.0
					end
				end
			end
		else
			--Game:Print("canT "..self._AIBrain._currentTime)
		end
	end


	if self._getSwampLights and swamp_lights_001 then
		local x,y,z
		if self._getSwampLights == 0 then
			x,y,z = self:GetJointPos("dlo_lewa_root")
		end
		if self._getSwampLights == 1 then
			x,y,z = self._targetx, self._targety, self._targetz
		end


		for i,v in swamp_lights_001._binded do
			local obj = EntityToObject[v]
			if self._getSwampLights == 2 then
				x,y,z = self._bindedPos[i].X,self._bindedPos[i].Y,self._bindedPos[i].Z
			end

			local x2,y2,z2 = obj.Pos.X,obj.Pos.Y,obj.Pos.Z
			local v2 = Vector:New(x2-x, y2-y, z2-z)
			local len = v2:Len()
			local d = self.disturbFlyingFlames
			if len > 0.1 then
				if d > 0 then
					local a = d
					if a > len*2 then
						a = len*2
					end
					v2.X,v2.Y,v2.Z = VectorRotate(v2.X, v2.Y, v2.Z, FRand(-a,a), FRand(-a,a),FRand(-a,a))
				end
				local speed = 1.0
				if self._getSwampLights == 0 then			-- leca do goscia
					speed = 2.6
				end
				if self._getSwampLights == 1 then			-- leca na playera
					if len > delta * self.flamesSpeed then
						v2:Normalize()
						v2:MulByFloat(self.flamesSpeed)
					else
						self._getSwampLights = 2
						if self._bindedEnergy then
							ENTITY.Release(self._bindedEnergy)
							self._bindedEnergy = nil
						end
						Game:Print("speed > delta")
						PlaySound2D("actor/swamp/Swamp-energyballHitsHero")
						break
					end
					if len < 0.7 then
						self._getSwampLights = 2
						PlaySound2D("actor/swamp/Swamp-energyballHitsHero")
						if self._bindedEnergy then
							ENTITY.Release(self._bindedEnergy)
							self._bindedEnergy = nil
						end
						break
					end
				end
				if self._getSwampLights == 1 then
					local distToPlayer = Dist3D(obj.Pos.X, obj.Pos.Y, obj.Pos.Z, Player._groundx, Player._groundy + 1.7, Player._groundz)
					--if debugMarek then Game:Print("distToPlayer "..distToPlayer) end
					if distToPlayer < 3.0 and self._canDamageByFlames then
						Player:OnDamage(self.flamesDamage)
						PlaySound2D("actor/swamp/Swamp-energyballHitsHero")
						self._canDamageByFlames = false
						self._getSwampLights = 2
						
						if self._bindedEnergy then
							ENTITY.Release(self._bindedEnergy)
							self._bindedEnergy = nil
						end
						break
					end
				end
				if self._getSwampLights == 2 then
					if len < 1.0 then
						self._canReturn = nil
						self._getSwampLights = nil
						--PlaySound2D("actor/swamp/Swamp-energyballHitsHero")
						swamp_lights_001:BindAll()
						self._bindedPos = {}		-- narazie no repeat
						self._canDamageByFlames = false
						MDL.SetAnimTimeScale(swamp_lights_001._Entity, swamp_lights_001._CurAnimIndex, self._oldeSpeed)
						break
					end
				end
				obj.Pos.X = obj.Pos.X - v2.X * delta * speed
				obj.Pos.Y = obj.Pos.Y - v2.Y * delta * speed
				obj.Pos.Z = obj.Pos.Z - v2.Z * delta * speed
			end
		end
	end
end

function Swamp:Fireball()
	self._getSwampLights = 1
	self._targetx = Player._groundx
	self._targety = Player._groundy + 1.7
	self._targetz = Player._groundz
	local v = swamp_lights_001._binded[1]
	local obj = EntityToObject[v]
	self._bindedEnergy = obj:BindSound("actor/swamp/Swamp-energyballFLying-loop",30,160,true)
end

------------
Swamp._CustomAiStates.getFlames = {
	name = "getFlames",
	active = false,
}

function Swamp._CustomAiStates.getFlames:OnInit(brain)
	local actor = brain._Objactor
	Game:Print("Swamp GET FLAMES?")
	brain._submode = nil
	if swamp_lights_001 and table.getn(actor._bindedPos) == 0 then
		self.active = true
		Game:Print("Swamp GET FLAMES!")
		actor:RotateToVectorWithAnim(Player._groundx, Player._groundy, Player._groundz)
	end
	self.mode = 0
end

function Swamp._CustomAiStates.getFlames:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
    if self.active then
		if self.mode == 0 and not actor._isRotating then
			actor:SetAnim("atak3",false)
			ENTITY.UnregisterAllChildren(swamp_lights_001._Entity)

			Game:Print("Swamp GET FLAMES unregister")
			actor._getSwampLights = 0
			for i,v in swamp_lights_001._binded do
				local obj = EntityToObject[v]
				local x,y,z = ENTITY.TransformLocalPointToWorld(v,0,0,0)
				actor._bindedPos[i] = Vector:New(x,y,z)
				obj.Pos.X = x
				obj.Pos.Y = y
				obj.Pos.Z = z
			end
			actor._oldeSpeed = MDL.GetAnimTimeScale(swamp_lights_001._Entity, swamp_lights_001._CurAnimIndex)
			MDL.SetAnimTimeScale(swamp_lights_001._Entity, swamp_lights_001._CurAnimIndex, 0)
			actor._canDamageByFlames = true
			self.mode = 1
		end
		if self.mode == 1 then
			if (not actor._isAnimating or actor.Animation ~= "atak3") then
				self.active = nil
				Game:Print("done with get flames")
			end
		end
	end
	brain._submode = nil
end

function Swamp._CustomAiStates.getFlames:OnRelease(brain)
	self.active = nil
end

function Swamp._CustomAiStates.getFlames:Evaluate(brain)
	if self.active or brain._submode == "getFlames" then
		return 0.3
	end
	return 0
end


------------
Swamp._CustomAiStates.AB = {
	name = "AB",
	active = false,
}

function Swamp._CustomAiStates.AB:OnInit(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
	brain._ABdo = nil
			
	Game:Print("---> swamp AB")
	--self:EnableRagdoll(true,false,x,y,z)
	swamp_lights_001:BindAll()

	brain._ABdone = true
	-- szesc babli
	actor:SetAnim("AB", false)				-- narazie 
	aiParams.FarAttack = "atak2_2hand"
	--Game.freezeUpdate = true
	actor._bubbles = {}
	for i=1,6 do
		local obj,e = AddObject("Bubble.CItem",1.4,Vector:New(C2L6_Swamp._flames[i].Pos.X,C2L6_Swamp._flames[i].Pos.Y,C2L6_Swamp._flames[i].Pos.Z),r,true) 
		obj.ObjOwner = actor
		obj._flameIndex = i
		obj._modeBurn = true
		table.insert(actor._bubbles, obj)
		obj._CurAnimIndex = MDL.SetAnim(e,"idle",true, 1.0, 0.0)
	end
	if debugMarek then Game:Print("CIEMNIEJE2") end
	actor:ABeffectON()
	aiParams.actions = aiParams.actionsAB
	self.active = true
end

function Swamp._CustomAiStates.AB:OnUpdate(brain)
	local actor = brain._Objactor
    --local aiParams = actor.AiParams
	if (not actor._isAnimating or actor.Animation ~= "AB") then
		self.active = nil
	end
end

function Swamp._CustomAiStates.AB:OnRelease(brain)
	local actor = brain._Objactor
	actor._afterAB = true
	actor:ABeffectOFF()
end

function Swamp._CustomAiStates.AB:Evaluate(brain)
	if self.active or brain._ABdo then
		return 0.2
	end
	return 0.0
end


---------------

Swamp._CustomAiStates.extinguishFire = {
	name = "extinguishFire",
	active = false,
}

function Swamp._CustomAiStates.extinguishFire:OnInit(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
	brain._ABdoNEXT = nil
	self.active = true
	-- get closest fire
	local closest = 9999
	brain._noBubbleToExtin = -1
	for i,v in actor._bubbles do
		local dist = Dist3D(v.Pos.X, 0, v.Pos.Z, actor._groundx, 0, actor._groundz)
		if dist < closest and dist > 30 then
			closest = dist
			brain._noBubbleToExtin = i
		end 
		ENTITY.EnableDraw(v._Entity, false)
		v._disabled = true
	end
    local x,y,z = actor._bubbles[brain._noBubbleToExtin].Pos.X, actor._bubbles[brain._noBubbleToExtin].Pos.Y, actor._bubbles[brain._noBubbleToExtin].Pos.Z
    if debugMarek then
		Game:Print("extinguish "..brain._noBubbleToExtin)
		--Game.freezeUpdate = true
		DEB1 = x
		DEB2 = y
		DEB3 = z
	end
	actor:RotateToVectorWithAnim(x,y,z)
	self.mode = 0
	self.extCounter = 0
	--actor._canGetNormalDamage = true
	self.dir = nil
end

function Swamp._CustomAiStates.extinguishFire:OnUpdate(brain)
	local actor = brain._Objactor
	
	if self.mode == 0 then
		if not actor._isRotating then
			self.mode = 1
			self.submode = 0
			actor:WalkTo(actor._bubbles[brain._noBubbleToExtin].Pos.X, actor._bubbles[brain._noBubbleToExtin].Pos.Y, actor._bubbles[brain._noBubbleToExtin].Pos.Z)
		end
	end
	if self.mode == 1 then
		if self.submode == 0 then
			local dist = Dist3D(actor._groundx, 0, actor._groundz, actor._bubbles[brain._noBubbleToExtin].Pos.X, 0, actor._bubbles[brain._noBubbleToExtin].Pos.Z)
			if dist < 25.0 then		-- bylo 25
				actor:FullStop()
				self.submode = 1
				if actor._bubbles[brain._noBubbleToExtin]._burnin then
					actor._doNotLoopWalkAnim = true
					--actor:SetAnim("atak4", false)
					if debugMarek then Game:Print("walk gaszenie "..dist) end
					actor:RotateToVector(actor._bubbles[brain._noBubbleToExtin].Pos.X, 0, actor._bubbles[brain._noBubbleToExtin].Pos.Z)
					actor:WalkForward(20, false, nil, nil, "atak4")
					actor._doNotLoopWalkAnim = false
				else
					if debugMarek then Game:Print("nie trzeba gasic "..dist) end
					actor:RotateToVector(actor._bubbles[brain._noBubbleToExtin].Pos.X, 0, actor._bubbles[brain._noBubbleToExtin].Pos.Z)
					actor:WalkForward(20, false)
				end
			else
				if not actor._isWalking then
					if debugMarek then Game:Print("retry "..dist) end
					local x,y,z = actor._bubbles[brain._noBubbleToExtin].Pos.X, actor._bubbles[brain._noBubbleToExtin].Pos.Y, actor._bubbles[brain._noBubbleToExtin].Pos.Z
					actor:WalkTo(x,y,z)
				end
			end
		else
			if not actor._isAnimating or actor.Animation ~= "atak4" then
				-- po pierwszym, trzeba dorbic aby szedl w strone w ktora patrzy (w lewo albo w prawo)
				if not self.dir then

					local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
					v:Normalize()
					local x1 = actor._groundx + v.X
					local y1 = actor._groundz + v.Z
					local d1 = math.sqrt(actor._groundz*actor._groundz + actor._groundx*actor._groundx)
					local d2 = math.sqrt(x1*x1+y1*y1)
					local p = ((0 - actor._groundz) * (x1 - actor._groundx) - (0 - actor._groundx) * (y1 - actor._groundz))/d1
					
					if p < 0 then
						self.dir = -1
					else
						self.dir = 1
					end
					--
				end
								
				brain._noBubbleToExtin = brain._noBubbleToExtin + self.dir
				if brain._noBubbleToExtin > 6 then
					brain._noBubbleToExtin = 1
				end
				if brain._noBubbleToExtin < 1 then
					brain._noBubbleToExtin = 6
				end

				local burninCount = 0
				for i,v in actor._bubbles do
					if v._burnin then
						burninCount = burninCount + 1
					end
				end
				
				if burninCount == 0 then
					Game:Print("..koniec gaszenia..")
					actor._startBubblesIn = actor.timeOutAfterExtinguished
					self.active = false
					actor:ABeffectOFF()
					return
				end

				local x,y,z = actor._bubbles[brain._noBubbleToExtin].Pos.X, actor._bubbles[brain._noBubbleToExtin].Pos.Y, actor._bubbles[brain._noBubbleToExtin].Pos.Z
				actor:WalkTo(x,y,z)
				if debugMarek then Game:Print("next DO "..brain._noBubbleToExtin) end
				self.submode = 0
				if debugMarek then Game:Print("next i zostalo "..burninCount) end
			end
		end
	end
	
end

function Swamp._CustomAiStates.extinguishFire:OnRelease(brain)
	local actor = brain._Objactor
	--actor._canGetNormalDamage = nil
	brain._ABdone1 = false
end

function Swamp._CustomAiStates.extinguishFire:Evaluate(brain)
	if self.active or brain._ABdoNEXT then
		return 0.15
	end
	return 0.0
end

function Swamp:FootFX(joint,x1,y1,z1)
	local j = MDL.GetJointIndex(self._Entity, joint)
	local x,y,z
	if not z1 then
		x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
	else
		x,y,z = MDL.TransformPointByJoint(self._Entity, j,x1,y1,z1)
	end
	AddObject(self.splashFX, 1.0, Vector:New(x,y,z),nil,true)
end

function Swamp:Extin()
	if not self.AIenabled then return end
    local brain = self._AIBrain
	--Game:Print("gaszenie "..brain._noBubbleToExtin)
	if self._bubbles[brain._noBubbleToExtin] then
		self._bubbles[brain._noBubbleToExtin]:Extinguish()
	end
end

function Swamp:ABeffectON()
	if not self._ABeffectON then
		local brain = self._AIBrain
		ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
		self:ApplySpecular(self.s_SubClass.RefractFresnelAB)
		self:ApplyFresnel(self.s_SubClass.RefractFresnelAB)
		MDL.SetRagdollCollisionGroup(self._Entity, self._oldRagdollColGroup)
		self._objWaterImpactMain._amp = 0
		self.bulletsFliesThru = nil
		if debugMarek then
			Game:Print("CIEMNIEJE")
		end
		MDL.SetTexture(self._Entity, "swampsw","empty")
		self._canGetNormalDamage = true
		self._ABeffectON = true
	end
end


function Swamp:RestoreFromSave()
	CActor.RestoreFromSave(self)
	if self._ABeffectON then
		self:ApplySpecular(self.s_SubClass.RefractFresnelAB)
		self:ApplyFresnel(self.s_SubClass.RefractFresnelAB)
		MDL.SetTexture(self._Entity, "swampsw","empty")
	else
		--self:ApplySpecular(self.s_SubClass.RefractFresnel)
		--self:ApplyFresnel(self.s_SubClass.RefractFresnel)
		--MDL.SetTexture(self._Entity, "swampsw","swampsw")
	end
end

function Swamp:ABeffectOFF()
	if self._ABeffectON then
		self:ApplySpecular(self.s_SubClass.RefractFresnel)
		self:ApplyFresnel(self.s_SubClass.RefractFresnel)
		self._objWaterImpactMain._amp = self._objWaterImpactMain.impAmplitude
		self.bulletsFliesThru = true
		MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.Noncolliding)
		MDL.SetTexture(self._Entity, "swampsw","swampsw")
		for i,v in self.s_SubClass.bindFX do
			self:BindFX(v[1], v[2], v[3], v[4], v[5], v[6])
		end
		if debugMarek then Game:Print("JASNIEJE") end
		self._canGetNormalDamage = false
		self._ABeffectON = false
	end
end

