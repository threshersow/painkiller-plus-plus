function FlameThrowerGas:OnPrecache()
    Cache:PrecacheParticleFX(self.burninFX)
    Cache:PrecacheDecal(self.Decal)    
end

function FlameThrowerGas:OnCreateEntity()
	self:PO_Create(BodyTypes.Simple,0.2,ECollisionGroups.Particles)
	ENTITY.EnableCollisions(self._Entity, true)
    ENTITY.RemoveFromIntersectionSolver(self._Entity)
    ENTITY.EnableDraw(self._Entity,false)    
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    self.OnDamage = nil
end

function FlameThrowerGas:OnUpdate()
    if math.random(100) < 50 then
        if self.HPDrain >  0 then
            for i,o in Actors do
                if not o._died and o.Health > 0 and not o._burning and not o.NotCountable then
                    local x,y,z = ENTITY.GetWorldPosition(o._Entity)
                    local dist = Dist3D(x,y,z,self.Pos.X, self.Pos.Y, self.Pos.Z)
                    if dist < self.HPDrainDistance then
                        Game:Print(o._Name)
                        --o:OnDamage(FRand(self.HPDrain * 0.8, self.HPDrain * 1.2), self.ObjOwner, AttackTypes.Fire)
                        if CanBurning(o) then
                            local p = Templates["PBurningObject.CProcess"]:New(o) 
                            p:Init()
                            GObjects:Add(TempObjName(),p)
                        end  
                    end
                end
            end
            if math.random(100) < 30 then
                for i,o in Game.Players do
                    if not o._died and o.Health > 0 then
                        local x,y,z = ENTITY.GetPosition(o._Entity)
                        local dist = Dist3D(x,y,z,self.Pos.X, self.Pos.Y, self.Pos.Z)
                        if dist < self.HPDrainDistance then
                            o:OnDamage(FRand(self.HPDrain * 0.8, self.HPDrain * 1.2), self.ObjOwner, AttackTypes.Fire)
                        end
                    end
                end
            end
        end
    end
end


function FlameThrowerGas:OnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz)
    --Game:Print("vx:"..vx.." vy:"..vy.." vz:"..vz)
    local pfx = AddPFX(self.burninFX,FRand(0.3, 0.4),Vector:New(0,0,0)) -- ,Quaternion:New_FromNormalZ(-nx,-ny,-nz)
    ENTITY.RegisterChild(self._Entity,pfx)
    
	self.Pos.X = x
	self.Pos.Y = y
	self.Pos.Z = z

	if self.Decal then
        local v = Vector:New(vx,vy,vz)
        v:Normalize()    
        local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x-v.X,y-v.Y,z-v.Z,x+v.X,y+v.Y,z+v.Z)
        if b and e then
            ENTITY.SpawnDecal(e,self.Decal,x,y,z,nx,ny,nz)
        end
    end

    ENTITY.PO_Enable(self._Entity, false)
	if self.sound then
		self._soundSample = SOUND3D.Create(self.sound)
		SOUND3D.SetPosition(self._soundSample,self.Pos.X,self.Pos.Y,self.Pos.Z)    
		SOUND3D.SetHearingDistance(self._soundSample,14,42)
		SOUND3D.SetLoopCount(self._soundSample,0)  
		SOUND3D.Play(self._soundSample)
	end
end

o.Client_OnCollision = o.OnCollision

function FlameThrowerGas:OnRelease()
	if self._soundSample then
		SOUND3D.Stop(self._soundSample)
	end
end
