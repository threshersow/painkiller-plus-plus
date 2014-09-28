function Apple:OnCreateEntity()
    --local pfx = AddPFX(self.fx,0.15)
    --ENTITY.RegisterChild(self._Entity,pfx)    
end

function Apple:OnCreateEntity()
--	self:PO_Create(BodyTypes.Simple,0.2)
	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.Noncolliding)
	self.timer = 4
	self.mode = 0
--	self._enabled = true
end

function Apple:OnDamage()
	self._damaged = true
end


function Apple:OnUpdate()
	if not self._enabled then return end
	if self.timer then
		self.timer = self.timer - 1
		if self.timer < 0 then
			self.timer = nil
			--Game:Print("1:Apple coll normal")
			ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.Normal)
			--ENTITY.EnableCollisions(self._Entity, true)
		end
	else
		if self.mode == 0 then
			self._velx,self._vely,self._velz,self._mag = ENTITY.GetVelocity(self._Entity)
			--Game:Print(":Apple "..(math.abs(self._vely)).." "..self._mag)
			if math.abs(self._vely) < 0.05 and self._mag < 0.8 then
				self.mode = 1
				--if debugMarek then WORLD.SetWorldSpeed(1/20) end
				--ENTITY.SetVelocity(self._Entity,0, 0, 0, 0,0,0)
				--ENTITY.PO_SetPinned(self._Entity, true)
				--Game:Print("2:Apple active")
				self:BindFX(self._fx, 0.2)
				return
			end
		end
		if self.mode == 1 then
			if math.random(100) < 20 then
				local x,y,z = self.Pos.X, self.Pos.Y, self.Pos.Z
				--for i,v in Actors do		-- a itemy?
				--	if v.OnDamage and v.Health > 0 then
				if Player.Health > 0 then
					local dist = Dist3D(Player._groundx, Player._groundy, Player._groundz, x,y,z)
					if dist < self.distance or self._damaged then
						self.mode = 2
                        PlaySound3D("actor/sado/sado_apple_ticktock", x,y,z, 20, 80)
						--Game:Print("3:Apple activated")
						--ENTITY.PO_SetPinned(self._Entity, false)
						ENTITY.SetVelocity(self._Entity,0, self.moveUpVel, 0)
					end
				end
			end
		end
		if self.mode == 2 then
			self._velx,self._vely,self._velz,self._mag = ENTITY.GetVelocity(self._Entity)
			if self._vely <= 0 then
				--Game:Print("4:Apple exploded")
				ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.Noncolliding)
				for i=1,self.nailsCount do
					local obj = GObjects:Add(TempObjName(),CloneTemplate("Nail.CItem"))
					obj.ObjOwner = self.ObjOwner

					local angle = math.random(0,360)
					local x = math.sin(angle) + math.cos(angle)
					local z = math.cos(angle) - math.sin(angle)

					local naboki = FRand(0.04, 0.07)
					x = x * naboki
					z = z * naboki
					obj.Pos.X = self.Pos.X + x
					obj.Pos.Y = self.Pos.Y + i * 0.001
					obj.Pos.Z = self.Pos.Z + z
					local v = Vector:New(obj.Pos.X - self.Pos.X, 0, obj.Pos.Z - self.Pos.Z)
					v:Normalize()
					local force = FRand(self.nailsVel*0.8,self.nailsVel*1.2)
					v.Y = FRand(-0.1, 0.1)
					obj:Apply()
					
					obj:Synchronize()
					ENTITY.SetVelocity(obj._Entity,v.X*force, v.Y*force, v.Z*force)
				end
				local pfx = self.s_SubClass.ParticlesDefinitions.explode
				AddPFX(pfx.pfx, pfx.scale,Vector:New(self.Pos.X,self.Pos.Y,self.Pos.Z))
				SOUND.Play3D("actor/sado/sado_apple-explosion",self.Pos.X,self.Pos.Y,self.Pos.Z,30,100)
                
				GObjects:ToKill(self)
			end
		end
	end
end

