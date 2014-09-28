function RingB:OnCreateEntity()
    local v = Vector:New(self.Pos.X - PX,self.Pos.Y - PY,self.Pos.Z - PZ)
    v:Normalize()
	v.X = v.X * -self.force[1]
	v.Y = v.Y * self.force[2]
	v.Z = v.Z * -self.force[3]
	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.InsideItems)

	ENTITY.SetVelocity(self._Entity,v.X,v.Y,v.Z)
	ENTITY.SetAngularVelocity(self._Entity, self.rotate[1]*FRand(0.9,1.1), self.rotate[2]*FRand(0.7,1.2), self.rotate[3]*FRand(0.9,1.1))
	ENTITY.PO_SetAngularDamping(self._Entity, self.angularDamping)
	ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    ENTITY.RemoveFromIntersectionSolver(self._Entity) 
	self.TimeToLive = self.TimeToLive * FRand(0.8, 1.1) 
end

function RingB:OnTake(player)
    self.Client_OnTake(player.ClientID,player._Entity,self._Entity,"RingB")
end

