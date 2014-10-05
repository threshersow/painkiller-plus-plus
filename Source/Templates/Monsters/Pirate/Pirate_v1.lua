function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
    self._AIBrain._lastThrowTime = FRand(-2, 2)
--	self:BindFX("pochodnia",0.1,self.AiParams.weaponBindPos,self.AiParams.weaponBindPosShift.X,self.AiParams.weaponBindPosShift.Y,self.AiParams.weaponBindPosShift.Z)
end
