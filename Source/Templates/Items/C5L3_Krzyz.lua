o.OnInitTemplate = CItem.StdOnInitTemplate

function C5L3_Krzyz:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.3)
    MDL.SetRagdollAngularDamping(self._Entity,0.3)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
    MDL.SetRagdollBreakablesThreshold( self._Entity, 4000 )
end

function C5L3_Krzyz:OnBreak()
    self:LaunchAction(self.Actions.OnBreak)
end

