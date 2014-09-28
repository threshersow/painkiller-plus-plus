o.OnInitTemplate = CItem.StdOnInitTemplate

function C3L3_Brama:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.3)
    MDL.SetRagdollAngularDamping(self._Entity,0.3)
    MDL.SetRagdollCollisionGroup(self._Entity,ECollisionGroups.Normal)
--    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

