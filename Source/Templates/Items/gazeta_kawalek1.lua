function gazeta_kawalek1:OnCreateEntity()
   	local angle = math.random(0,360)
	local x = math.sin(angle) + math.cos(angle)
	local z = math.cos(angle) - math.sin(angle)
	local y = FRand(1,2)
	local naboki = FRand(0.9, 1.2)
	x = x * self.forceOut * naboki
	y = y * self.forceUp
	z = z * self.forceOut * naboki

	--local a = INP.GetTimeFromTimerReset()
	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.InsideItems)
	--local b = INP.GetTimeFromTimerReset()
	ENTITY.PO_SetAngularDamping(self._Entity, FRand(self.angularDamping * 0.5, self.angularDamping * 2.0))
	ENTITY.PO_SetLinearDamping(self._Entity, FRand(self.linearDamping * 0.5, self.linearDamping * 2.0))
	--local c = INP.GetTimeFromTimerReset()
	ENTITY.PO_SetMovedByExplosions(self._Entity, false)
	--local d = INP.GetTimeFromTimerReset()
    ENTITY.RemoveFromIntersectionSolver(self._Entity) 
    --local e = INP.GetTimeFromTimerReset()
	ENTITY.PO_Hit(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z,x,y,z)
	--local f = INP.GetTimeFromTimerReset()
	--Game:Print((b-a).." "..(c-b).." "..(d-c).." "..(e-d).." "..(f-e).." ")
	self.TimeToLive = self.TimeToLive * FRand(0.8, 1.1)    
	self:AddTimer("MomentLater",0.2)
end

function gazeta_kawalek1:MomentLater()
	local q = Quaternion:New_FromEuler(FRand(-3.14,3.14), FRand(-3.14,3.14), FRand(-3.14,3.14))
	q:ToEntity(self._Entity)
	ENTITY.SetAngularVelocity(self._Entity, self.rotate[1]*FRand(0.9,1.1), self.rotate[2]*FRand(0.7,1.2), self.rotate[3]*FRand(0.9,1.1))
	self:ReleaseTimers()
end

function gazeta_kawalek1:Update()
    if self.TimeToLive then
		if self.TimeToLive > 0 then
			self.TimeToLive = self.TimeToLive - 1
		else
			GObjects:ToKill(self,true)
			ENTITY.SetTimeToDie(self._Entity,2)
		end
	end
end
