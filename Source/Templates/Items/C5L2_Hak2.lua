o.OnInitTemplate = CItem.StdOnInitTemplate

function C5L2_Hak2:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.8)
    MDL.SetRagdollAngularDamping(self._Entity,0.8)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

