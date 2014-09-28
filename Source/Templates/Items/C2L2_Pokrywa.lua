o.OnInitTemplate = CItem.StdOnInitTemplate

function o:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end

function o:OnDamage(damage, owner, attacktype)
	if self._disableDamage then return end
	self.Health = self.Health - damage
	if self.Health < 1 then
		Game:Print("pokrywa death")
		self.Health = 1
		self._disableDamage = true
		ENTITY.PO_SetPinned(self._Entity, false)
		ENTITY.PO_SetAngularDamping(self._Entity, 2.0)
		--WORLD.Explosion2(self.Pos.X,self.Pos.Y-6,self.Pos.Z,15000,5,nil,AttackTypes.Explosion,50)
		ENTITY.SetVelocity(self._Entity, 0,18,6)
		PlaySound3D("impacts/barrel-metal-explode",self.Pos.X,self.Pos.Y-9,self.Pos.Z,15,60)
		AddPFX("Flame_factory",2,Vector:New(self.Pos.X,self.Pos.Y-9,self.Pos.Z))
		self:AddTimer("kill",3.0)
	end
end

function o:kill()
	GObjects:ToKill(self)
end
