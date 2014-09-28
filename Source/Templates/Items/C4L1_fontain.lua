function o:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function o:OnPrecache()
    Cache:PrecacheItem("C4L1_Lava.CItem")
end

function o:OnCreateEntity()
	if not debugMarek then
		ENTITY.EnableDraw(self._Entity,false)
	else
		self:Start()
	end
end

function o:Start()
	self:ReleaseTimers()
	self:AddTimer("Spawn",self.spawnFreq)
end

function o:Stop()
	self:ReleaseTimers()
end

function o:Spawn()
	local dist = Dist3D(PX,PY,PZ,self.Pos.X,self.Pos.Y,self.Pos.Z)
	if dist > self.fireBallSpawnMinDist and dist < self.fireBallSpawnMaxDist then
		local obj2 = GObjects:Add(TempObjName(),CloneTemplate("C4L1_Lava.CItem"))
		
		obj2.Pos.X = self.Pos.X
		obj2.Pos.Y = self.Pos.Y
		obj2.Pos.Z = self.Pos.Z
		
		obj2:Apply()
		obj2:Synchronize()

		ENTITY.PO_SetMovedByExplosions(obj2._Entity, false)
		
		local v = Vector:New(PX - self.Pos.X,0,PZ - self.Pos.Z)
		local angleToPlayer = math.atan2(v.Z, v.X)
		
		local x,y,z = CalcThrowVectorGivenAngle(dist, self.fireBallAngle, angleToPlayer, PY - self.Pos.Y)
		v = Vector:New(x,y,z)
		ENTITY.SetVelocity(obj2._Entity,v.X,v.Y,v.Z)
	end
end
