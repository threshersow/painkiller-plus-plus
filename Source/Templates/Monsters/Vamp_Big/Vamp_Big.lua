function Vamp_Big:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastTimeSpecial = -100
end

function Vamp_Big:CustomDelete()
	Game:Print(self._Name.." delete")
	self:CustomOnDeath()
end

function Vamp_Big:CustomOnDeath()
	local brain = self._AIBrain
	Game:Print("custom on death")
	if self._procStoneThrow then
		GObjects:ToKill(self._procStoneThrow)
		self._procStoneThrow = nil
		Game:Print(self._Name.." proc del")
	end

	if self._objStone then
		Game:Print("stone del")
		if brain._JointH then
			MDL.SetPinned(self._objStone._Entity, false)
			MDL.SetPinnedJoint(self._objStone._Entity, brain._JointH, false)	
		end
		MDL.SetRagdollCollisionGroup(self._objStone._Entity, ECollisionGroups.RagdollNonColliding)
		self._objStone = nil
	end
	
end

function Vamp_Big:CustomUpdate()
	if self._objStone and self._procStoneThrow then
		if not (self.Animation == "take_meat" or self.Animation == "throw_stone") then
			local brain = self._AIBrain
			if brain._JointH and self._objStone then
				Game:Print(self._Name.."inna anim - KILL1 "..self.Animation)
				MDL.SetPinned(self._objStone._Entity, false)
				MDL.SetPinnedJoint(self._objStone._Entity, brain._JointH, false)
				MDL.SetRagdollCollisionGroup(self._objStone._Entity, ECollisionGroups.RagdollNonColliding)
				self._objStone = nil
			end
			
			if self._procStoneThrow then
				Game:Print(self._Name.."inna anim - KILL2")
				GObjects:ToKill(self._procStoneThrow)
				self._procStoneThrow = nil
			end
		end
	end
end

function Vamp_Big:OnCreateEntity()
	--self.s_SubClass.walk = {"walkfast"}
	--self._runAltAnim = "walkfast"
end


function Vamp_Big:TakeMeat()
    local aiParams = self.AiParams
    local brain = self._AIBrain
	local x,y,z = self:GetJointPos(aiParams.holdJoint)
	local e = AddItem(aiParams.ThrowableItem, nil, Vector:New(x,y,z), true)
	local obj = EntityToObject[e]
	Game:Print(self._Name.." CREATE")
	if self._objStone then
		Game:Print(self._Name.." self._objStone already exists")
		GObjects:ToKill(self._objStone)
	end
	self._objStone = obj

    brain._JointH = MDL.GetJointIndex(e, "root")
    MDL.SetPinnedJoint(e, brain._JointH, true)
    MDL.SetPinned(self._objStone._Entity, true)
    self._objStone._pinnedJoint = brain._JointH
	if self._procStoneThrow then
		Game:Print(self._Name.." self._procStoneThrow already exists")
		GObjects:ToKill(self._procStoneThrow)
	end
    self._procStoneThrow = Templates["PBindJointToJoint.CProcess"]:New(self._Entity, self, aiParams.holdJoint, brain._JointH, e)
    self._procStoneThrow:Tick(0, true)
    --MDL.ApplyRotationToJoint(e, brain._JointH, FRand(0,6.28) , FRand(0,6.28), FRand(0,6.28))	-- chyba to nie dziala...?
	GObjects:Add(TempObjName(),self._procStoneThrow)
	self:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
	self:BloodFX(x,y,z)
end


function Vamp_Big:Throw()
    if self._objStone then
        local brain = self._AIBrain
        local aiParams = self.AiParams
        self:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
    
        local entity = self._objStone._Entity
		local force = aiParams.throwSpeed
    
        local x,y,z = self:GetJointPos(aiParams.holdJoint)
        
        local dx = Player._groundx - x
        local dy = Player._groundy - y + FRand(1.65,1.75)
        local dz = Player._groundz - z
    
        local v = Vector:New(dx, dy, dz)
        v:Normalize()
    
        self._objStone._throwed = 2
        self._objStone._velx = v.X*force
        self._objStone._vely = v.Y*force
        self._objStone._velz = v.Z*force

        MDL.SetPinnedJoint(entity, brain._JointH, false)	
        MDL.SetPinned(entity, false)	
        MDL.ApplyVelocitiesToJointLinked(entity, brain._JointH, self._objStone._velx, self._objStone._vely, self._objStone._velz, FRand(0,8),FRand(0,8),FRand(0,8))

--        self._objStone._raggDollPrecomputedCollData = {}
--        for i,v in self._objStone.RagdollCollisions.Bones do
--			Game:Print("r e c "..v[1])
--			ENTITY.EnableCollisionsToRagdoll(entity, MDL.GetJointIndex(entity, v[1]), self._objStone.RagdollCollisions.MinTime, self._objStone.RagdollCollisions.MinStren, self._objStone.RagdollCollisions.MinTime)
  --          --if v[1] >= 0 then
            --    self._objStone._raggDollPrecomputedCollData[v[1]] = {v[2], v[3]}
            --end
	--	end
        self._objStone = nil
    end
    if self._procStoneThrow then
		GObjects:ToKill(self._procStoneThrow)
        self._procStoneThrow = nil
    end

end


function Vamp_Big:FootFX(joint)
    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
    self:AddPFX('but',0.1,Vector:New(x,y,z))
    Game._EarthQuakeProc:Add(x,y,z, 8, 12, 0.014, 0.014, 1.0)
end
