o.OnInitTemplate = CItem.StdOnInitTemplate

function Hangman:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.5)
    MDL.SetRagdollAngularDamping(self._Entity,0.5)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
    MDL.SetRagdollHardDeactivator(self._Entity)
end
