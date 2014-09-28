o.OnInitTemplate = CItem.StdOnInitTemplate

function C6L6_palpion:OnCreateEntity()
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	--ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, self.speed)
    
    local j = MDL.GetJointIndex(self._Entity, "joint5")
    ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 0.1, 0)
end

function C6L6_palpion:OnCollision(x,y,z,nx,ny,nz,e)
	if e then
		local obj = EntityToObject[e]
		if obj and obj.OnDamage then
            obj:OnDamage(15, nil, AttackTypes.Shuriken,x,y,z,nx,ny,nz)
            ENTITY.PO_Hit(e,x,y,z,nx*1200,ny*1200,nz*1200)
            if obj._Class == "CPlayer" then
                ENTITY.PO_SetPlayerShocked(e)
			end
            self:SndEnt("Hit",obj._Entity)
		end
	end
end


