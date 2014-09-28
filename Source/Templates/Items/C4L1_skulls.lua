o.OnInitTemplate = CItem.StdOnInitTemplate

function o:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
	self:AddTimer("Start",0.5)
end

function o:OnPrecache()
    Cache:PrecacheItem("C4L1_SkullFireball.CItem")    
end

function o:CustomOnDamage(damage, owner, attacktype)
	if attacktype == AttackTypes.Fireball then
		return true
	end
end

function o:Start()
	self._head = 0
	ENTITY.PO_SetPinned(self._Entity,true)
	ENTITY.PO_Activate(self._Entity,true)
	self:ReleaseTimers()
	self:AddTimer("Spawn",self.fireFreqency)
end

function o:Spawn()
	local angle = ENTITY.GetOrientation(self._Entity)
	if self.randomFire then
		self._head = math.random(0,3)
	end
	angle = angle + self._head * math.pi/2
	self._head = self._head + 1
	if self._head > 3 then
		self._head = 0
	end
	local v = Vector:New(math.sin(angle),0,math.cos(angle))
	v:Normalize()
	v:MulByFloat(1.6)
	
	local obj2 = GObjects:Add(TempObjName(),CloneTemplate("C4L1_SkullFireball.CItem"))
	
	obj2.Pos.X = self.Pos.X + v.X
	obj2.Pos.Y = self.Pos.Y + v.Y + 0.2
	obj2.Pos.Z = self.Pos.Z + v.Z
	
	obj2:Apply()
	obj2:Synchronize()

	ENTITY.PO_SetMovedByExplosions(obj2._Entity, false)
	
	local v = Vector:New(obj2.Pos.X - self.Pos.X,0,obj2.Pos.Z - self.Pos.Z)
	v:Normalize()
	v:MulByFloat(self.fireballSpeed)
	ENTITY.SetVelocity(obj2._Entity,v.X,0,v.Z)
end
