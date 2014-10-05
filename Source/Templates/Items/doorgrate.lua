o.OnInitTemplate = CItem.StdOnInitTemplate

function doorgrate:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.5)
    MDL.SetRagdollAngularDamping(self._Entity,0.5)
  MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

