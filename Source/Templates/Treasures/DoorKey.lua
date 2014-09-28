function o:Tick(delta)
	self._angler.X = self._angler.X + delta * self.rotationAngle.X
	self._angler.Y = self._angler.Y + delta * self.rotationAngle.Y
	self._angler.Z = self._angler.Z + delta * self.rotationAngle.Z
	local q = Quaternion:New_FromEuler(self._angler.X,self._angler.Y,self._angler.Z)
	ENTITY.SetRotationQ(self._Entity, q.W, q.X, q.Y, q.Z)
end

function DoorKey:OnCreateEntity()
--	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.InsideItems)
--    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
--    ENTITY.RemoveFromIntersectionSolver(self._Entity) 
	self._angler = Vector:New(0,0,0)
	self:BindFX("pentaklp",0.3)

end
--============================================================================
function DoorKey:OnTake(player)	
    self.Client_OnTake(player.ClientID,player._Entity,self._Entity,"DoorKey")
end