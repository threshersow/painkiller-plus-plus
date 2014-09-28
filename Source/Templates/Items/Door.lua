o.OnInitTemplate = CItem.StdOnInitTemplate

function Door:OnCreateEntity()
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end
