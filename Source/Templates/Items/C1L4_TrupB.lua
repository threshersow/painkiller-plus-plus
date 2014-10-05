o.OnInitTemplate = CItem.StdOnInitTemplate

function C1L4_TrupB:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.4)
    MDL.SetRagdollAngularDamping(self._Entity,0.4)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end
