function NunSpell:OnCreateEntity()
    local pfx = AddPFX(self.fx,0.15)
    ENTITY.RegisterChild(self._Entity,pfx)    
end

function NunSpell:OnCreateEntity()
	self:PO_Create(BodyTypes.Simple,0.2)
	-- ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.Noncolliding)
	ENTITY.EnableCollisions(self._Entity, true)
	ENTITY.PO_EnableGravity(self._Entity,false)
	self:BindSound("actor/nun/nun-charm-shoot",4,28,false)
    ENTITY.EnableDraw(self._Entity,false)
end

--function NunSpell:OnInitTemplate()
--    self.Update = nil
--end

function NunSpell:OnCollision(x,y,z,nx,ny,nz,e)
	if e then
		local obj = EntityToObject[e]
		if obj then
			--Game:Print("nunspell "..obj._Class)
			if obj._Class == "CPlayer" and self.ObjOwner then
				obj._jammed = self.ObjOwner.AiParams.farAttackJammTime
				obj._DrawColorQuad = true
				obj._ColorOfQuad = Color:New(255, 180, 70)
				obj._QuadAlphaMax = 50
                PlaySound2D("actor/nun/nun-charm-hit")
			end
        else
            PlaySound3D("actor/nun/nun-charm-shoot",x,y,z,25,70)
		end
	end
	GObjects:ToKill(self)
end
