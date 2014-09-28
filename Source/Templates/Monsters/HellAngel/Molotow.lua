function Molotow:OnPrecache()
    Cache:PrecacheParticleFX(self.Particle)
    Cache:PrecacheParticleFX(self.destroyPFX)    
    Cache:PrecacheItem("Gas.CItem")
end

function Molotow:OnCreateEntity()
	self.timer = 4
    local pfx = AddPFX(self.Particle,0.3)
    ENTITY.RegisterChild(self._Entity,pfx)    
	self:PO_Create(BodyTypes.SphereSweep,0.2,ECollisionGroups.Noncolliding)
end


function Molotow:OnUpdate()
	if self.timer then
		self.timer = self.timer - 1
		if self.timer < 0 then
			Game:Print("MOLOTOW enable col")
			ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)
			ENTITY.EnableCollisions(self._Entity, true)
			self.timer = nil
		end
	end
end

function Molotow:OnCollision(x,y,z,nx,ny,nz,e)
	-- tu tworzy "gas" w roznych kierunkach
	PlaySound3D("impacts/molotov-explode",x,y,z,20,50)
	AddPFX(self.destroyPFX,0.3, Vector:New(x,y,z))
	--self.ObjOwner.debugHIT = {}
        
	local amount = self.gasElements
	for i=1,amount do
		local obj = GObjects:Add(TempObjName(),CloneTemplate("Gas.CItem"))
		obj.ObjOwner = self.ObjOwner
		obj.Pos.X = x + nx * 0.5 + FRand(-0.5, 0.5)
		obj.Pos.Y = y + ny * 0.5 + i*0.05
		obj.Pos.Z = z + nz * 0.5 + FRand(-0.5, 0.5)

		--table.insert(self.ObjOwner.debugHIT, {obj.Pos.X, obj.Pos.Y, obj.Pos.Z})
		
		if i == amount then
			obj.TimeToLive = obj.TimeToLive * 1.2
			obj.sound = "impacts/barrel-wood-fire-loop"
		else
			obj.sound = nil
			obj.TimeToLive = FRand(obj.TimeToLive * 0.8, obj.TimeToLive * 1.2)			
		end
		obj:Apply()
		obj:Synchronize()
	end

	GObjects:ToKill(self)
end
