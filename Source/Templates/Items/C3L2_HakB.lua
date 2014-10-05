o.OnInitTemplate = CItem.StdOnInitTemplate

function C3L2_HakB:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.1)
    MDL.SetRagdollAngularDamping(self._Entity,0.1)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

