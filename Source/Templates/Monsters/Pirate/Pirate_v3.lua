function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
    self._AIBrain._lastThrowTime = FRand(-2, 2)
--	self:BindFX("pochodnia",0.1,self.AiParams.weaponBindPos,self.AiParams.weaponBindPosShift.X,self.AiParams.weaponBindPosShift.Y,self.AiParams.weaponBindPosShift.Z)
--	self:BindFX("pochodnia",0.1,self.AiParams.secondWeaponBindPos,self.AiParams.secondWeaponBindPosShift.X,self.AiParams.secondWeaponBindPosShift.Y,self.AiParams.secondWeaponBindPosShift.Z)
end



function o:WeaponFireL(par3, par4, par5)
	self._AIBrain._useSecondWeapon = true			-- narazie
	self._AIBrain:WeaponFire(par3, par4, par5)
	self._AIBrain._useSecondWeapon = false
end

function o:WeaponFireR(par3, par4, par5)
	self._AIBrain:WeaponFire(par3, par4, par5)
end