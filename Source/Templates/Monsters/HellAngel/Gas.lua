function Gas:OnPrecache()
    Cache:PrecacheParticleFX(self.burninFX)
    Cache:PrecacheDecal(self.Decal)    
end

function Gas:OnCreateEntity()
	self:PO_Create(BodyTypes.Simple,0.2,ECollisionGroups.Particles)
	ENTITY.EnableCollisions(self._Entity, true)
    ENTITY.RemoveFromIntersectionSolver(self._Entity)

   	local angle = math.random(0,360)
	local x = math.sin(angle) + math.cos(angle)
	local z = math.cos(angle) - math.sin(angle)
	local y = math.random(50,60)* 0.01
	local force = FRand(7, 15) * FRand(8, 15)
	
	--Game:Print("PO HItx "..self.Pos.X)
	ENTITY.PO_Hit(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z,x * force,y * force,z * force)
    ENTITY.EnableDraw(self._Entity,false)
    
    self.pfx = AddPFX(self.FXwhileFlying, self.whileFlyingSize)
    ENTITY.RegisterChild(self._Entity,self.pfx)
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    self.OnDamage = nil
end

function Gas:OnUpdate()
    if math.random(100) < 5 then
		for i,v in Actors do		-- a itemy?
			if v.OnDamage and v.Health > 0 then
				local dist = Dist3D(v._groundx,v._groundy,v._groundz,self.Pos.X, self.Pos.Y, self.Pos.Z)
				if dist < self.HPDrainDistance then
					v:OnDamage(FRand(self.HPDrain * 0.8, self.HPDrain * 1.2), self.ObjOwner, AttackTypes.Fire, self.Pos.X, self.Pos.Y, self.Pos.Z)
				end
			end
		end
		if Player and Player.Health > 0 then
			local dist = Dist3D(Player._groundx,Player._groundy,Player._groundz,self.Pos.X, self.Pos.Y, self.Pos.Z)
			if dist < self.HPDrainDistance then
				Player:OnDamage(FRand(self.HPDrain * 0.8, self.HPDrain * 1.2), self.ObjOwner, AttackTypes.Fire)
			end
		end
		if self.pfx then
			--Game:Print("gas - jeszcze leci")
			local x,y,z,m = ENTITY.GetVelocity(self._Entity)
			if m < 0.2 and y < 0.1 then
				ENTITY.Release(self.pfx)
			    ENTITY.PO_Enable(self._Entity, false)
				ENTITY.SetVelocity(self._Entity, 0,0,0)
				Game:Print("ma mala predkosc wiec go usuwam")
				self.pfx = nil
			end
		end
    end
end


function Gas:OnCollision(x,y,z,nx,ny,nz,e)
    ENTITY.Release(self.pfx)
    self.pfx = nil
    local pfx = AddPFX(self.burninFX,FRand(0.3, 0.4))

	if self.Decal then
        local v = Vector:New(ENTITY.GetVelocity(self._Entity))
        v:Normalize()
    
        local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x-v.X,y-v.Y,z-v.Z,x+v.X,y+v.Y,z+v.Z)
        if b and e then
            ENTITY.SpawnDecal(e,self.Decal,x,y,z,0,1,0)
        end
    end

    ENTITY.RegisterChild(self._Entity,pfx)
    ENTITY.PO_Enable(self._Entity, false)
	ENTITY.SetVelocity(self._Entity, 0,0,0)
	self.Pos.X = x
	self.Pos.Y = y
	self.Pos.Z = z
	if self.sound then
		self._soundSample = SOUND3D.Create(self.sound)
		SOUND3D.SetPosition(self._soundSample,self.Pos.X,self.Pos.Y,self.Pos.Z)    
		SOUND3D.SetHearingDistance(self._soundSample,14,42)
		SOUND3D.SetLoopCount(self._soundSample,0)  
		SOUND3D.Play(self._soundSample)
	end
end

function Gas:OnRelease()
	if self._soundSample then
		SOUND3D.Stop(self._soundSample)
	end
end
