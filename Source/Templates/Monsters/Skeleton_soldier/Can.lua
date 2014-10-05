function Can:OnCreateEntity()
	self:PO_Create(BodyTypes.Simple,0.2, ECollisionGroups.Noncolliding)
	ENTITY.SetAngularVelocity(self._Entity, 0, 10, 0)
    local pfx = AddPFX(self._fx,0.15)
    ENTITY.RegisterChild(self._Entity,pfx)    
    PARTICLE.SetParentOffset(pfx,0.25,0,0)            
    self:BindSound("actor/skeleton_soldier/can_smoke-loop",6,20,true)
	self.timer = 3
	
	--ENTITY.EnableCollisions(self._Entity, true)
	
    --local q = Quaternion:New_FromNormal(1,0,0)
    --q:ToEntity(pfx)
	--self.mode = 0
end


function Can:OnUpdate()
	if self.timer then
		self.timer = self.timer - 1
		if self.timer < 0 then
			self.timer = nil
			--Game:Print("enable col")
			ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.Normal)
			ENTITY.EnableCollisions(self._Entity, true)
		end
	else
		--if self.mode == 0 then
			if math.random(100) < 15 then
                local x,y,z = self.Pos.X,self.Pos.Y,self.Pos.Z
				local dist = Dist3D(Player._groundx, Player._groundy, Player._groundz, x,y,z)
				if dist < self.Poison.Range then
	                if not SOUND2D.IsPlaying(Player._oldSND) then
		                Player._oldSND = PlaySound2D("hero/hero_poison"..math.random(1,3),nil,nil,true)
			        end
                    
                    Player._poisoned = self.Poison.TimeOut
                    Player._poisonedTime = 0
                    Player._poison = self.Poison
                    Player._DrawColorQuad = true
                    Player._ColorOfQuad = Color:New(255, 10, 10)
                    Player._QuadAlphaMax = 50
				end
                self._fx_lastx = x
                self._fx_lasty = y
                self._fx_lastz = z
            end
		--end
	end
end


function Can:OnCollision(x,y,z,nx,ny,nz,e)
	--Game:Print("Can collison")
	if e then
		local obj = EntityToObject[e]
		if not obj then
			ENTITY.EnableCollisions(self._Entity, false)
			PlaySound3D("actor/skeleton_soldier/can_drop", x,y,z, 8,30)
		end
	else
		ENTITY.EnableCollisions(self._Entity, false)
		PlaySound3D("actor/skeleton_soldier/can_drop", x,y,z, 8,30)
	end
end
