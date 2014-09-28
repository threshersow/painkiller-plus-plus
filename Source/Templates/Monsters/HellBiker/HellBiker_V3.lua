function HellBiker_V3:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._drunk = true
end

function HellBiker_V3:CustomOnHit()
	local aiParams = self.AiParams
	if not self._ABdo and not self._ABdone then
		if self._HealthMax * aiParams.ABhp > self.Health and ENTITY.PO_IsOnFloor(self._Entity) then
			self._ABdo = true
		end
	end
end

function HellBiker_V3:OnCreateEntity()
	MDL.SetMeshVisibility(self._Entity,"bottle_b_2sided", false)
end

function HellBiker_V3:breakbottle()
	MDL.SetMeshVisibility(self._Entity,"bottle_a_2sided", false)
	MDL.SetMeshVisibility(self._Entity,"bottle_b_2sided", true)
	self:BindFX("breakbottle")
end

--------------------------
HellBiker_V3._CustomAiStates = {}
HellBiker_V3._CustomAiStates.ABhellbikerV3 = {
	name = "ABhellbikerV3",
}
function HellBiker_V3._CustomAiStates.ABhellbikerV3:OnInit(brain)
	local actor = brain._Objactor
	actor._disableHits = true
	actor:Stop()
	actor:SetAnim("break_bottle",false)
end

function HellBiker_V3._CustomAiStates.ABhellbikerV3:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isAnimating or actor.Animation ~= "break_bottle" then
		actor._ABdo = false
	end
end

function HellBiker_V3._CustomAiStates.ABhellbikerV3:OnRelease(brain)
	local actor = brain._Objactor
	actor._ABdone = true
	actor.AiParams.NearAttacks = {"atak2"}
	actor._disableHits = false
	local aiParams = actor.AiParams
	aiParams.weaponDamage = aiParams.weapon2Damage
	aiParams.attackRangeAngle = aiParams.attack2RangeAngle
	aiParams.attackRange = aiParams.attack2Range
end

function HellBiker_V3._CustomAiStates.ABhellbikerV3:Evaluate(brain)
	local actor = brain._Objactor
	if actor._ABdo and actor._state ~= "ATTACKING" then
		return 0.55
	end
	return 0.01
end


HellBiker_V3._CustomAiStates.drink = {
	name = "drink",
	lastTimeDrunk = 0,
	lastTimeDrunkRnd = 1,
	wantDrunk = 0.3,
}
function HellBiker_V3._CustomAiStates.drink:OnInit(brain)
	local actor = brain._Objactor
	actor._disableHits = true
	actor:Stop()
	actor._forceGibFX = actor.gibFXwhenDrink
	actor._forceGibExplosionStrength = actor.s_SubClass.GibExplosionStrengthWhenDrink
	actor:SetAnim("drink",false)
	self.active = true
	--if debugMarek then Game:Print("Drinking....") end
end

function HellBiker_V3._CustomAiStates.drink:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isAnimating or actor.Animation ~= "drink" then
		brain._drunk = true
		self.active = false
	end
end

function HellBiker_V3._CustomAiStates.drink:OnRelease(brain)
	local actor = brain._Objactor
	actor._forceGibFX = nil
	actor._forceGibExplosionStrength = nil
	--if debugMarek then Game:Print("Drinking.... END") end
	actor._disableHits = false
	self.active = false
end

function HellBiker_V3._CustomAiStates.drink:Evaluate(brain)
	if self.active then
		return 0.6
	end
	local actor = brain._Objactor
	if not actor._ABdone and not actor._ABdo then
		if not brain._drunk and brain._Objactor._state ~= "ATTACKING" then
			return 0.6
		else
			if self.lastTimeDrunk + actor.AiParams.DrinkFreq + self.lastTimeDrunkRnd < brain._currentTime then
				self.lastTimeDrunk = brain._currentTime
				self.lastTimeDrunkRnd = FRand(0.0, 2.0)
				--if debugMarek then Game:Print("chce mu sie pic") end
				brain._drunk = false
			end
		end
	end
	return 0.01
end

function HellBiker_V3:StartBreath(name)
	local fx = self.s_SubClass.ParticlesDefinitions[name]
	local pfx = self:AddPFX(fx.pfx,fx.scale)
	ENTITY.RegisterChild(self._Entity,pfx)
	PARTICLE.SetParentOffset(pfx,fx.offset.X,fx.offset.Y,fx.offset.Z,fx.joint, nil,nil,nil, fx.rotation.X, fx.rotation.Y, fx.rotation.Z)
	self._fx = pfx
end

function HellBiker_V3:StopBreath()
	if self._fx then
		PARTICLE.Die(self._fx)
		self._fx = nil
	end
end

function HellBiker_V3:OnStartAnim()
	self:StopBreath()
end
function HellBiker_V3:OnFinishAnim()
	self:StopBreath()
end

function HellBiker_V3:CustomOnDeathAfterRagdoll()
	--ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
	if self.Animation == "drink" and self._gibbed then
		local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(self._groundx,self._groundy+0.5,self._groundz,self._groundx,self._groundy-0.6,self._groundz)
		if b and e then
			ENTITY.SpawnDecal(e,"molotov",x,y,z,nx,ny,nz)
		end
		self:AddPFX("explodeSpecial")
	end
end
