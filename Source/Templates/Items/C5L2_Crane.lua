o.OnInitTemplate = CItem.StdOnInitTemplate

function C5L2_Crane:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end

function o:OnDestroy()
	local parts = WORLD.GetLastExplodedEntities(entity)
    for i,v in parts do
		local mass = ENTITY.PO_GetMass(v)
		--Game:Print("mass = "..mass)
		if mass > 100 then			-- mass > 3
			MESH.SetMeshGroup(v, 70)
			ENTITY.EnableCollisions(v, true, 2.0, 6.0)
		end
    end

end
