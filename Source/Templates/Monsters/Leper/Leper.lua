function Leper:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastThrowTime = FRand(-4, 0.5)

    self._animMode = math.random(1,6)
    self._forceWalkAnim = self.s_SubClass.walkList[self._animMode]
    self._lastTimeChangeAnim = 0
    self._changeAnimIn = FRand(20.0, 50.0)	-- sec.
end

function Leper:OnPrecache()
    Cache:PrecacheItem("GenericLeperThrowable.CItem")    
    Cache:PrecacheItem("LeperHammer.CItem")
    Cache:PrecacheItem("LeperHook.CItem")
    Cache:PrecacheItem("LeperKnife.CItem")
    Cache:PrecacheItem("LeperTorch.CItem")
end


function Leper:GetThrowItemRotation()
	if self._torchFX then
		ENTITY.Release(self._torchFX)
		self._torchFX = nil
	end

	local q = Quaternion:New()
	q:FromEuler( 0, -self.angle+math.pi/2, math.pi)	-- -self.angle - math.pi/2
	return q
end

function Leper:CustomOnDeath()
	if self._proc then
		GObjects:ToKill(self._proc)
		self._proc = nil
	end

	if self._objTakenToThrow then
		local brain = self._AIBrain
		if brain._JointH then
			MDL.SetPinned(self._objTakenToThrow._Entity, false)	
			MDL.SetPinnedJoint(self._objTakenToThrow._Entity, brain._JointH, false)	
		end
		MDL.SetRagdollCollisionGroup(self._objTakenToThrow._Entity, ECollisionGroups.RagdollNonColliding)
		self._objTakenToThrow = nil
	end
end


function Leper:CustomOnDeathAfterRagdoll()
	if self._gibbed then
		for i,v in self.s_SubClass.bodyParts do
			local no = self._visibleParts[i]
			local cnt = table.getn(v)
			for j=1,cnt do
				if j ~= no then
					MDL.SetMeshVisibility(self._Entity, v[j], false)
				end
			end
		end
	end
end

Leper.CustomOnGib = Leper.CustomOnDeathAfterRagdoll



function Leper:OnCreateEntity()
	self._visibleParts = {}
	for i,v in self.s_SubClass.bodyParts do
		local cnt = table.getn(v)
		local no = math.random(1,cnt)
		if debugMarek then
			if cnt >= 5 then
				no = 5
			end
		end
		self._visibleParts[i] = no
		for j=1,cnt do
			if j ~= no then
				MDL.SetMeshVisibility(self._Entity, v[j], false)
			end
		end
	end
	
	local weapon = self._visibleParts[1]
	self.AiParams.ThrowableItem = self.s_SubClass.weapons[weapon]
	self.AiParams.hideMesh = self.s_SubClass.bodyParts[1][weapon]
	if weapon == 5 then		-- torch
		local fx = self.torchFX
		self._torchFX = self:BindFX("torch")
		local l = self.s_SubClass.Light
		if l then
			local obj = CloneTemplate(l.template)
			obj.Pos:Set(1.0,0.0,-0.1)
			obj:Apply()
			ENTITY.RegisterChild(self._Entity,obj._Entity,true,MDL.GetJointIndex(self._Entity, l.joint))
			self._bindedLight = obj
		end
		l = self.s_SubClass.BillBoard
		if l then
			local obj = CloneTemplate(l.template)
			obj.Pos:Set(1.0,0.0,-0.1)
			obj:Apply()
			ENTITY.RegisterChild(self._Entity,obj._Entity,true,MDL.GetJointIndex(self._Entity, l.joint))
			self._bindedBill = obj
		end
	end
end

function Leper:SetIdle(once)
	self:Stop()	
	local loop = true
	if once then
		loop = once
	end
	self:SetAnim(self.s_SubClass.idlesList[self._animMode], loop)
end

function Leper:CustomUpdate()
	if self._lastTimeChangeAnim + self._changeAnimIn < self._AIBrain._currentTime and not self._isWalking and not self._notIsWalkingTimer then
		self._changeAnimIn = FRand(20.0, 50.0)	-- sec.
		self._lastTimeChangeAnim = self._AIBrain._currentTime
	    self._animMode = math.random(1,6)
		self._forceWalkAnim = self.s_SubClass.walkList[self._animMode]
	end
end

function Leper:OnTick()
	if self._bindedLight then
		local l = Templates[self.s_SubClass.Light.template]
		local rnd = FRand(0.67, 1.0)
		local i = l.Intensity
		LIGHT.SetIntensity(self._bindedLight._Entity, i * rnd)
		local f = l.StartFalloff * rnd
		local radius = l.Range * rnd
		LIGHT.SetFalloff(self._bindedLight._Entity,f,radius)
	end
end

function Leper:OnThrow()
	local aiParams = self.AiParams
	if aiParams.aiGoalsAfterThrow and aiParams.throwAnim ~= "atak3" then
		local brain = self._AIBrain
		brain._goals = {}
		for i,v in aiParams.aiGoalsAfterThrow do
			if not brain:AddState(v) then
				Game:Print(v.." state not found")
			end
		end
		
		if aiParams.NextThrowableItem then
			aiParams.ThrowableItem = aiParams.NextThrowableItem
			aiParams.throwAnim = "atak3"
			aiParams.throwAmmo = 99999
		end
		
		if self._objTakenToThrow then
			local bindOffset = Vector:New(0,-4,0)
			if self._bindedLight then
				ENTITY.UnregisterAllChildren(self._Entity)		-- dodac typ
				ENTITY.RegisterChild(self._objTakenToThrow._Entity,self._bindedLight._Entity,true)
				MESH.SetLighting(self._objTakenToThrow._Entity, false)
				ENTITY.SetPosition(self._bindedLight._Entity,bindOffset.X, bindOffset.Y, bindOffset.Z)
				self._objTakenToThrow._bindedLightT = Templates[self.s_SubClass.Light.template]
				self._objTakenToThrow._bindedLight = self._bindedLight
				self._bindedLight = nil
			end
			if self._bindedBill then
				ENTITY.UnregisterAllChildren(self._Entity)
				ENTITY.RegisterChild(self._objTakenToThrow._Entity,self._bindedBill._Entity,true)
				ENTITY.SetPosition(self._bindedBill._Entity,bindOffset.X, bindOffset.Y, bindOffset.Z)
				self._objTakenToThrow._bindedBill = self._bindedBill
				self._bindedBill = nil
			end
		end

	else
		if self._objTakenToThrow then
			self._objTakenToThrow._throwed = 7
		end
	end
end


function Leper:TakeMeat()
    local aiParams = self.AiParams
    local brain = self._AIBrain
	local x,y,z = self:GetJointPos(aiParams.throwItemBindTo)
	local e
	local obj
	local e,obj = AddItem(aiParams.ThrowableItem, nil, Vector:New(x,y,z), true)
	self._objTakenToThrow = obj

    brain._JointH = MDL.GetJointIndex(e, "root")
    MDL.SetPinnedJoint(e, brain._JointH, true)
    obj._pinnedJoint = brain._JointH
    self._proc = Templates["PBindJointToJoint.CProcess"]:New(self._Entity, self, aiParams.throwItemBindTo, brain._JointH, e)
    self._proc:Tick(0, true)
    --MDL.ApplyRotationToJoint(e, brain._JointH, FRand(0,6.28) , FRand(0,6.28), FRand(0,6.28))	-- chyba to nie dziala...?
	GObjects:Add(TempObjName(),self._proc)
	self._throwModeRagdoll = true
end

