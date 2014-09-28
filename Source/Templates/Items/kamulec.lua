o.OnInitTemplate = CItem.StdOnInitTemplate

function kamulec:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
end

function o:CustomOnCollision()
	local x,y,z = ENTITY.GetPosition(self._Entity)
	Game._EarthQuakeProc:Add(x,y,z, 6, 16, 0.15, 0.15, 1.0)
end
