o.OnInitTemplate = CItem.StdOnInitTemplate

function C2L2_Chain1:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.5)
    MDL.SetRagdollAngularDamping(self._Entity,0.5)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end
