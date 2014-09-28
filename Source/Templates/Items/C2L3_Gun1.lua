o.OnInitTemplate = CItem.StdOnInitTemplate

function C2L3_Gun1:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,1.0)
    MDL.SetRagdollAngularDamping(self._Entity,1.0)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end