o.OnInitTemplate = CItem.StdOnInitTemplate

function C7L1_ostrza:OnCreateEntity()
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	--ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, self.speed)
    
    local j = MDL.GetJointIndex(self._Entity, "joint3")
    ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 0.1, 0)
    local j = MDL.GetJointIndex(self._Entity, "joint4")
    ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 0.1, 0)
end

function C7L1_ostrza:OnCollision(x,y,z,nx,ny,nz,e)
	if e then
		local obj = EntityToObject[e]
		if obj and obj.OnDamage then
            obj:OnDamage(15, nil, AttackTypes.Shuriken,x,y,z,nx,ny,nz)
            if not SOUND3D.IsPlaying(self._snd) then
                self._snd = PlaySound3D("impacts/knife-trap-impact", x,y,z, 4, 10)
            end
		end
	end
end
