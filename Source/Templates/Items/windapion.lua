o.OnInitTemplate = CItem.StdOnInitTemplate

function windapion:OnCreateEntity()
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	--ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    
    MDL.SetAnim(self._Entity,"none")
end


