function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
--	self._AIBrain._lastThrowTime = FRand(-2, 2)
--	self:BindFX("pochodnia",0.1,self.AiParams.weaponBindPos,self.AiParams.weaponBindPosShift.X,self.AiParams.weaponBindPosShift.Y,self.AiParams.weaponBindPosShift.Z)
--	self:BindFX("pochodnia",0.1,self.AiParams.secondWeaponBindPos,self.AiParams.secondWeaponBindPosShift.X,self.AiParams.secondWeaponBindPosShift.Y,self.AiParams.secondWeaponBindPosShift.Z)
end

function o:CustomOnDamage(he,x,y,z,obj)
	if obj == self then
		return true
	end
end

function o:OnThrow(x,y,z)
	local aiParams = self.AiParams
	local gun = aiParams.weapon
	local v2 = Vector:New(x,y,z)
	v2:Normalize()
	local q = Quaternion:New_FromNormal(v2.X, v2.Y, v2.Z)

    local idx
    
	--[[if self._useSecondWeapon then
		idx = MDL.GetJointIndex(self._Entity, aiParams.secondWeaponBindPos)
	else
        idx = MDL.GetJointIndex(self._Entity, aiParams.weaponBindPos)
    end
	local srcx,srcy,srcz = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)--]]
	
	local srcx,srcy,srcz = self._objTakenToThrow.Pos.X,self._objTakenToThrow.Pos.Y,self._objTakenToThrow.Pos.Z
	if gun.fireParticle then
		AddPFX(gun.fireParticle, gun.fireParticleSize, Vector:New(srcx,srcy,srcz), q)
	end
end
