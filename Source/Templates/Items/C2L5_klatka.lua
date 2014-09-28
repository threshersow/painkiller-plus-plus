o.OnInitTemplate = CItem.StdOnInitTemplate

function C2L5_klatka:OnCreateEntity()
	
        MDL.SetRagdollLinearDamping(self._Entity,0.7)
        MDL.SetRagdollAngularDamping(self._Entity,0.9)
        MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end
