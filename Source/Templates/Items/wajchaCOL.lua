o.OnInitTemplate = CItem.StdOnInitTemplate

function wajchaCOL:OnCreateEntity()
end

function wajchaCOL:Enable()
    MDL.SetRagdollLinearDamping(self._Entity,0.8)
    MDL.SetRagdollAngularDamping(self._Entity,0.8)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

function wajchaCOL:Disable()
    MDL.SetPinned(self._Entity,true)
end 