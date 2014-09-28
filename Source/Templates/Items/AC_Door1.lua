o.OnInitTemplate = CItem.StdOnInitTemplate

function AC_Door1:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.5)
    MDL.SetRagdollAngularDamping(self._Entity,0.9)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)    
end
