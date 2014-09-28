function HellBiker_V4:OnInitTemplate()
    self:SetAIBrain()
end

function HellBiker_V4:OnCreateEntity()
	--self:BindFX("pochodnia",0.1,"joint22",0.6,0.1,0.3)
end

function HellBiker_V4:PlaySoundIfMissed(par1, par2, par3, par4, par5)		-- do aktora?
	local brain = self._AIBrain
	if brain._lastMissedTime > brain._lastHitTime then
		self:PlaySound(par1, par2, par3, par4, par5)
	end
end

function o:OnThrow(x,y,z)
    local v = Vector:New(x,y,z)
    v:Normalize()
	local q = Quaternion:New_FromNormalX(v.X, v.Y, v.Z)
    q:ToEntity(self._objTakenToThrow._Entity)
end
