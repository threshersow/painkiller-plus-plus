function Nun1:OnInitTemplate()
    self:SetAIBrain()
end

function Nun1:CustomOnDeath()
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end


function Nun1:OnCreateEntity()
	MDL.SetMeshVisibility(self._Entity,"polySurface990|polySurfaceShape990", false)		-- narazie
end

