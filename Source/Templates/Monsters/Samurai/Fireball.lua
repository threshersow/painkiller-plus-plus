function Fireball:OnPrecache()
    Cache:PrecacheParticleFX(self.fx)
end

function Fireball:OnCreateEntity()
    local pfx = AddPFX(self.fx,0.15)
    ENTITY.RegisterChild(self._Entity,pfx)
    ENTITY.EnableDraw(self._Entity,false)

	self:PO_Create(BodyTypes.Simple,0.2,ECollisionGroups.Noncolliding)
	ENTITY.PO_EnableGravity(self._Entity,false)
	self.timer = 3
	self:BindSound("actor/samurai/samurai-fireball",4,28,false)			
end


function Fireball:OnUpdate()
	if self.timer then
		self.timer = self.timer - 1
		if self.timer < 0 then
			self.timer = nil
			ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)
			ENTITY.EnableCollisions(self._Entity, true)
		end 
	end
end

function Fireball:OnCollision(x,y,z,nx,ny,nz,e)
	if e then
		local obj = EntityToObject[e]
		if obj then
			if obj.OnDamage then
				obj:OnDamage(self.damage, self.ObjOwner)
                PlaySound3D("actor/samurai/samurai-fireball-hit",x,y,z)
			end
		else
            PlaySound3D("actor/nun/nun-charm-shoot",x,y,z,25,70)
            ENTITY.PO_Enable(self._Entity, false)
            if self.ObjOwner then
				WORLD.Explosion2(x,y,z, 0.01, 6, self.ObjOwner._Entity, AttackTypes.Rocket, 0)
			else
				WORLD.Explosion2(x,y,z, 0.01, 6, nil, AttackTypes.Rocket, 0)
			end
		end
	end
	GObjects:ToKill(self)
end
