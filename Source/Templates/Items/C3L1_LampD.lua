o.OnInitTemplate = CItem.StdOnInitTemplate

function C3L1_LampD:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.3)
    MDL.SetRagdollAngularDamping(self._Entity,0.3)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

