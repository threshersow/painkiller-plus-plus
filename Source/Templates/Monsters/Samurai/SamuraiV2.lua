function SamuraiV2:OnInitTemplate()
    self:SetAIBrain()
    self._lastTimeStick = -100
end

function SamuraiV2:OnCreateEntity()
	self._AIBrain._lastChargeTime = -100
	self._AIBrain._lastThrowTime = -100
	self._crossPieces = {}
end

function SamuraiV2:CustomOnHit()
	if not self._ABdone and not self._ABdo then
		if self._HealthMax * self.ABHp > self.Health then
			--Game:Print("ABdo")
			self._ABdo = true
		end
	end
end

function SamuraiV2:CustomOnDeath()
    for i,v in self._crossPieces do
        GObjects:ToKill(v)
    end
end

--[[
function SamuraiV2:CustomUpdate()
	if true then return end

	if self.Animation == "run" and self._isAnimating then
		local brain = self._AIBrain
		local aiParams = self.AiParams
		local x1,y1,z1 = self:GetJointPos("joint21")
		local x2,y2,z2 = self:GetJointPos("d_P_bron")

		local v = Vector:New(x2 - x1, y2 - y1, z2 - z1)
		v:Normalize()


		--
		-- spr. tylko odleglosci
		--local testDist = 2.5
		--local dist = Dist3D(x1 - v.X*testDist,y1 - v.Y*testDist,z1 - v.Z*testDist, Player._groundx, Player._groundy +1.7, Player._groundz)
		--Game:Print("dist = "..dist)
		--self.DEBUG_P1 = x1 - v.X*testDist
		--self.DEBUG_P2 = y1 - v.Y*testDist
		--self.DEBUG_P3 = z1 - v.Z*testDist
		--if dist < 1.5 then
		--end


		-- trace test
		local testDist = 2.8
		--local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x1-v.X,y1-v.Y,z1-v.Z, x1 - v.X*testDist,y1 - v.Y*testDist,z1 - v.Z*testDist)
		local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x1-v.X,y1-v.Y,z1-v.Z, x1 - v.X*testDist,y1 - v.Y,z1 - v.Z*testDist)
		if debugMarek then					
			self.d1 = x1 - v.X
			self.d2 = y1 - v.Y
			self.d3 = z1 - v.Z
			self.d4 = x1 - v.X*testDist
			self.d5 = y1 - v.Y*testDist
			self.d6 = z1 - v.Z*testDist
		end

		if e then
			local obj = EntityToObject[e]
			if obj ~= self then
				if obj and obj.OnDamage then
					Game:Print(self._Name.." nadzial "..obj._Name.." "..brain._currentTime)
					if obj._Class == "CPlayer" then
						if self._lastTimeStick + 0.2 < brain._currentTime then
							--Game:Print(self._Name.." nadzial DAMAGE "..obj._Name)
							obj:OnDamage(aiParams.chargeDamage)
							self._lastTimeStick = brain._currentTime
							self:PlayRandomSound2D(self.s_SubClass.Sounds.stick)
						end
					else
						obj:OnDamage(aiParams.chargeDamage)
					end
					local par3 = -aiParams.chargePOHit
					local par4 = -aiParams.chargePOHitUp
					ENTITY.PO_Hit(obj._Entity, obj.Pos.X, obj.Pos.Y, obj.Pos.Z, v.X*par3, v.Y*par4, v.Z*par3)
					self:Stop()
				end
			else
				Game:Print("trace self")
				--Game.freezeUpdate = true
			end
		end
	end
end
--]]

function SamuraiV2:CreateCrossPiece()
    local aiParams = self.AiParams
	local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))
	self.Joint = MDL.GetJointIndex(self._Entity, aiParams.throwItemBindTo)
	local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,aiParams.holdJointDisplace.X,aiParams.holdJointDisplace.Y, aiParams.holdJointDisplace.Z)
	obj.ObjOwner = self
	obj.Pos.X = x
	obj.Pos.Y = y
	obj.Pos.Z = z
	obj:Apply()
	obj:Synchronize()
    self._getDamageFromX = false
    self._getDamageFromX2 = false
	--ENTITY.PO_Enable(obj._Entity, false)
	table.insert(self._crossPieces, obj)
end

function SamuraiV2:Throw()
	if self._AIBrain and self._AIBrain._enemyLastSeenTime > 0 then
		local aiParams = self.AiParams

		for i,obj in self._crossPieces do

			if i == 1 then
				--Game:Print("_bindToCrossSound")
				obj:BindSound("actor/samurai/samurai-fireball",4,28,false)
			end

			local x,y,z = obj.Pos.X, obj.Pos.Y, obj.Pos.Z
			local v = Vector:New(Player._groundx - x, (Player._groundy + 1.7) - y, Player._groundz - z)
			v:Normalize()
			
			local angleToPlayer = math.atan2(v.X, v.Z)
			
			local aDist = AngDist(self.angle, angleToPlayer)
			if math.abs(aDist) > 30 * math.pi/180 then
				v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
				v:Normalize()
			end

			local force = aiParams.ThrowSpeed
			v:MulByFloat(force)
			
			if debugMarek then					
				self.d1 = x
				self.d2 = y
				self.d3 = z
				self.d4 = x + v.X
				self.d5 = y + v.Y
				self.d6 = z + v.Z
			end

			obj.Rot:FromEuler( 0, -self.angle, 0)
			obj._RotAngle = self.angle
			obj._enabled = true
			--ENTITY.PO_Enable(obj._Entity, true)
			ENTITY.SetVelocity(obj._Entity, v.X, v.Y, v.Z)
		end
		self._crossPieces = {}
	end
end



function SamuraiV2:ChargeNinjas()
	if debugMarek then Game:Print(self._Name.." charge ninjas") end
    local aiParams = self.AiParams
	for i,v in Actors do
		if v.Health > 0 and v.Model == "ninja" then
			local dist = Dist3D(self._groundx,self._groundy,self._groundz,v._groundx,v._groundy,v._groundz)
			if dist < aiParams.chargeNinjasDistance then
				v.Health = v._HealthMax
				if debugMarek then Game:Print(self._Name.." ninja w zasiegu: "..v._Name) end
			end
		end
	end
    if self.seppukuFX then
        local x,y,z = self:GetJointPos("k_zebra")
        
		--self:AddPFX("seppuku")
		local p = self.s_SubClass.ParticlesDefinitions
		if p.seppuku then
			AddObject(p.seppuku.name,p.seppuku.scale,Vector:New(x,y,z),nil,true) 
		end

        self:BindFX("FX_gib_blood",0.3, "k_zebra", 0.4, -0.1, 0, true, 0, 0, 2.2)        
        self:BindFX("FX_gib_blood",0.3, "k_zebra", 0.4, -0.1, 0, true, 0, -0.3, 2.2)        
        self:BindFX("FX_gib_blood",0.3, "k_zebra", 0.4, -0.1, 0, true, 0, 0.3, 2.2) 

        local a = ENTITY.GetOrientation(self._Entity)
        local nx,nz = -math.cos(a), math.sin(a)
        self:BloodFX(x,y,z,nx,0,nz) 
        self:BloodFX(x,y,z,nx,0,nz) 
        self:BloodFX(x,y,z,nx,0,nz)
        self._frozen = true
        self:OnDamage(9999, self)
    end
    local dist = Dist3D(PX,PY,PZ, self._groundx,self._groundy,self._groundz)
    if debugMarek then
		Game:Print("samuraj death "..dist)
    end
    if dist < aiParams.chargeNinjasPlayerDamageDistance then
		Player:OnDamage(aiParams.chargeNinjasPlayerDamage * (aiParams.chargeNinjasPlayerDamageDistance - dist)/aiParams.chargeNinjasPlayerDamageDistance, self)
    end
end

--------------------
SamuraiV2._CustomAiStates = {}

SamuraiV2._CustomAiStates.samuraiV2AB = {
	name = "samuraiV2AB",
}

function SamuraiV2._CustomAiStates.samuraiV2AB:OnInit(brain)
	local actor = brain._Objactor
	actor:Stop()
	actor:SetAnim("seppuku", false)
	if debugMarek then Game:Print(actor._Name.." AB") end
	actor._ABdo = nil
	actor._disableHits = true
	self.active = true
end

function SamuraiV2._CustomAiStates.samuraiV2AB:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isAnimating or actor.Animation ~= "seppuku" then
		self.active = false
		Game:Print("koniec sepuku")
        actor._disableDeathSounds = true
		actor:OnDamage(actor.Health + 2, actor)
        actor._deathTimer = 0
		actor._ABdone = true
	end
end


function SamuraiV2._CustomAiStates.samuraiV2AB:Evaluate(brain)
	local actor = brain._Objactor
	if actor._ABdo and actor._state ~= "ATTACKING" then
		return 0.6
	end
	if self.active then
		return 0.9
	end
	return 0
end


