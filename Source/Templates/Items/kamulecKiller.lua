o.OnInitTemplate = CItem.StdOnInitTemplate

function kamulecKiller:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
    --ENTITY.EnableCollisions(self._Entity, true, 0.1, 1.0)
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
end

function o:CustomOnCollision(e_other, velocity_me, velocity_other)
	local x,y,z = ENTITY.GetPosition(self._Entity)
	Game._EarthQuakeProc:Add(x,y,z, 6, 16, 0.15, 0.15, 1.0)
	
	if e_other then
		if velocity_me > 1.4 then
			local obj = EntityToObject[e_other]
			if obj and obj.OnDamage then
				obj:OnDamage(10000,self)
			end
		end
	end

end
