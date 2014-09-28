function dead_body:OnInitTemplate()
    self:ReplaceFunction("Update", nil)
	self:ReplaceFunction("Tick", nil)
    self:ReplaceFunction("_Synchronize","Synchronize")
    self:ReplaceFunction("Synchronize")
end

function dead_body:OnApply()
    MDL.SetRagdollLinearDamping(self._Entity,0.5)
    MDL.SetRagdollAngularDamping(self._Entity,0.5)
    --MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
    self:EnableRagdoll(true)
    self._enabledRD = true
    self._died = true
    self._deathTimer = 99999
end
