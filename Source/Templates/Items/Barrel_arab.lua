function o:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function o:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
	self._HealthMax = self.Health
end

function o:OnPrecache()
    Cache:PrecacheItem("Gas.CItem")
    Cache:PrecacheParticleFX(self.FlyParticle[1])
    Cache:PrecacheParticleFX(self.destroyPFX)
end


function o:OnUpdate()
	if self._pfx then
		if self.LifeTimeAfterFly > 0 then
			self.LifeTimeAfterFly = self.LifeTimeAfterFly - 1/30
			if self.LifeTimeAfterFly <= 0 then
				self:OnDamage(self.Health + 1, self)
			end
		end
		if self._enableFullCollTime > 0 then
			self._enableFullCollTime = self._enableFullCollTime - 1/30
			if self._enableFullCollTime <= 0 then
				self._onCollsionDestroy = true
			end
		end
	end
end

function o:CustomOnDamage(damage, obj, type, x, y, z, nx, ny, nz, he)
	if self._HealthMax * self.FlyHealth > (self.Health - damage) then
		if z then
			if not self._pfx and (self.Health - damage) > 0 then
				self._pfx = self:BindFX(self.FlyParticle[1],self.FlyParticle[2],nil,0,-1,0)
				local v = Vector:New(z - self.Pos.Z, 0, x - self.Pos.X)
				if v:Len() < 0.05 then
					v = Vector:New(PZ - self.Pos.Z , 0, PX - self.Pos.X)
				end
				v:Normalize()
				ENTITY.SetAngularVelocity(self._Entity, -v.X,0,-v.Z)
				v.X = v.X * -self.force[1] * FRand(0.99, 1.01)
				v.Y = self.force[2] * FRand(0.9, 1.1)
				v.Z = v.Z * -self.force[3] * FRand(0.99, 1.01)
				self._enableFullCollTime = 1.0
				ENTITY.SetVelocity(self._Entity,v.Z,v.Y,v.X)
				PlaySound3D("impacts/barrel-wood-fire-fly",self.Pos.X,self.Pos.Y,self.Pos.Z, 20,50)
				local x1,y1,z1 = ENTITY.GetWorldPosition(self._Entity)
				AddPFX(self.destroyPFX,0.3, Vector:New(x1,y1,z1))
				self._burning = true
			--else
				--PARTICLE.Die()
			end
		end
	end
end


function o:CustomOnDeathAfterDestroy()
	if self._pfx then
		local amount = self.gasElements
		local x,y,z = ENTITY.GetWorldPosition(self._Entity)
		for i=1,amount do
			local obj = GObjects:Add(TempObjName(),CloneTemplate("Gas.CItem"))
			obj.ObjOwner = self.ObjOwner
			
			obj.Pos.X = x + FRand(-0.4, 0.4)
			obj.Pos.Y = y + i*0.05
			obj.Pos.Z = z + FRand(-0.4, 0.4)

			if i == amount then
				obj.TimeToLive = obj.TimeToLive * 1.2
				obj.sound = "impacts/barrel-wood-fire-loop"
			else
				obj.sound = nil
				obj.TimeToLive = FRand(obj.TimeToLive * 0.8, obj.TimeToLive * 1.2)			
			end
			obj:Apply()
			obj:Synchronize()
			ENTITY.PO_SetMovedByExplosions(obj._Entity,false)
		end
	end
end