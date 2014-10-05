o.OnInitTemplate = CItem.StdOnInitTemplate

function C3L6_Mostek:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.4)
    MDL.SetRagdollAngularDamping(self._Entity,0.4)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

