o.OnInitTemplate = CItem.StdOnInitTemplate

function lampaw2:OnCreateEntity()
	
        MDL.SetRagdollLinearDamping(self._Entity,0.5)
        MDL.SetRagdollAngularDamping(self._Entity,0.9)
        MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)

end
