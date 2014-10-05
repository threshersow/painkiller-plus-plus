o.OnInitTemplate = CItem.StdOnInitTemplate

function C2L2_switch:OnCreateEntity()
end

function C2L2_switch:Enable()
    MDL.SetRagdollLinearDamping(self._Entity,0.8)
    MDL.SetRagdollAngularDamping(self._Entity,0.8)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
end

function C2L2_switch:Disable()
    MDL.SetPinned(self._Entity,true)
end
