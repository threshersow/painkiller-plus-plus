function FireBallAlastor:OnCreateEntity()
	self:PO_Create(BodyTypes.Simple,0.2,ECollisionGroups.Noncolliding)
	ENTITY.PO_EnableGravity(self._Entity,false)
	self._timer = 5
	--self:BindSound("actor/samurai/samurai-fireball",20,200,false)
	self:BindSound("actor/alastor/alastor_attack1-fireball",20,200,false)
    local pfx = AddPFX(self.fx,0.4)
    ENTITY.RegisterChild(self._Entity,pfx)
    ENTITY.EnableDraw(self._Entity,false)
    ENTITY.PO_SetMovedByExplosions(self._Entity,false)
    ENTITY.RemoveFromIntersectionSolver(self._Entity)
end

--function FireBallAlastor:OnInitTemplate()
--    self.Update = nil
--end

function FireBallAlastor:OnUpdate()
	if self._timer then
		self._timer = self._timer - 1
		if self._timer < 0 then
			self._timer = nil
			Game:Print("fireball coll normal")
			ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.Normal)
			ENTITY.EnableCollisions(self._Entity, true)
		end 
	end
	--[[local x,y,z,v = ENTITY.GetVelocity(self._Entity)
	if v > 50 then			-- UGLY HACK!!!!!!!!!!!!!!!!!!!!
		Game:Print(self._Name.." !!!!!! predkosc fireballa = "..v)
		ENTITY.SetVelocity(self._Entity, self._velx, self._vely, self._velz)
	end--]]
	
end

function FireBallAlastor:OnCollision(x,y,z,nx,ny,nz,e)
    local obj
	if e then
		Game:Print(self._Name.." fireball collision e")
		obj = EntityToObject[e]
		if obj and obj.OnDamage then
			obj:OnDamage(self.damage, self.ObjOwner)
			Game:Print("fireball damage "..obj._Name)
            if obj == Player then
                PlaySound2D("actor/samurai/samurai-fireball-hit")
            end
		else
			Game:Print("fireball explosion - no obj")
            ENTITY.PO_Enable(self._Entity, false)
			WORLD.Explosion2(x,y,z, 1000, 6, nil, AttackTypes.Rocket, 50)
		end
	else
		Game:Print(self._Name.." fireball collision no e")
	end
    if obj ~= Player then
        PlaySound3D("actor/samurai/samurai-fireball-hit",x,y,z, 30, 200)
    end
	GObjects:ToKill(self)
end
