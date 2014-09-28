--o.OnInitTemplate = CItem.StdOnInitTemplate

function MovingBoulder:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.Phantom)
	--ENTITY.PO_SetPinned( self._Entity, true )
	ENTITY.EnableCollisions(self._Entity, true, 0.1, 0.1)
	ENTITY.PO_EnableGravity(self._Entity, false)
--	ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0, true )
	ENTITY.PO_SetFreedomOfRotation( self._Entity, EFreedomsOfRotation.Disabled )
	self._start = self.Pos.Y
	self._end = self.Pos.Y - self.moveDistance
	self._state = 0
	self._timer = 0
	self._stopped = true
end

function MovingBoulder:EditTick( delta )
    ENTITY.PO_MaintainLinearMovement( self._Entity, false )
    ENTITY.PO_MaintainVelocity( self._Entity, false)
	self._start = self.Pos.Y
	self._end = self.Pos.Y - self.moveDistance
	self._state = 0
	self._timer = 0
--    ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0, true )
end

function MovingBoulder:OnRelease()
	if self._loopSnd then
		SOUND3D.Stop(self._loopSnd)
		SOUND3D.SetLoopCount(self._loopSnd,1)
		self._loopSnd = nil
	end
end

function MovingBoulder:Start()
	self._stopped = false
end

function MovingBoulder:Stop()
    ENTITY.PO_MaintainVelocity( self._Entity, false )
	ENTITY.SetVelocity(self._Entity, 0,0,0)
	if self._loopSnd then
		SOUND3D.Stop(self._loopSnd)
    	SOUND3D.SetLoopCount(self._loopSnd,1)
		self._loopSnd = nil
	end
	self._stopped = true
end


function MovingBoulder:Tick(delta)
	if self._stopped then return end
	if self._state == 0 then		-- UP
		self._timer = self._timer + delta
		if self._timer > self.timeUp then
			PlaySound3D("items/stoneblock-movingdown-start", self.Pos.X, self.Pos.Y, self.Pos.Z, 4, 8)
			self._loopSnd = PlaySound3D("items/stoneblock-movingdown-loop", self.Pos.X, self.Pos.Y, self.Pos.Z, 5, 12)
			SOUND3D.SetLoopCount(self._loopSnd,0)
			self._state = 1
			self._timer = 0
			ENTITY.PO_MaintainVelocity( self._Entity, true, 0, -self.velocityDown, 0, 0.1 )
		end
	else
	if self._state == 1 then
		--self.Pos.Y = self.Pos.Y - delta * self.velocityDown
		if self.Pos.Y < self._end then
			self._state = 2
			self._timer = 0
			ENTITY.PO_MaintainVelocity( self._Entity, false )
			ENTITY.SetVelocity(self._Entity, 0,0,0)

			AddPFX('butbig',0.5,Vector:New(self.Pos.X, self.Pos.Y + self.effectDeltaY, self.Pos.Z))
			Game._EarthQuakeProc:Add(self.Pos.X, self.Pos.Y + self.effectDeltaY, self.Pos.Z, 14, 3, 0.1, 0.1, false)
			SOUND3D.Stop(self._loopSnd)
			SOUND3D.SetLoopCount(self._loopSnd,1)
			PlaySound3D("items/stoneblock-movingdown-stop", self.Pos.X, self.Pos.Y, self.Pos.Z, 10, 40)

		else
			ENTITY.SetVelocity(self._Entity, 0,-self.velocityDown,0)
		end
	else
	if self._state == 2 then
		self._timer = self._timer + delta
		if self._timer > self.timeDown then
			self._state = 3
			self._timer = 0
			self._loopSnd = PlaySound3D("items/stoneblock-movingup-loop", self.Pos.X, self.Pos.Y, self.Pos.Z, 5, 12)
			SOUND3D.SetLoopCount(self._loopSnd,0)
			ENTITY.PO_MaintainVelocity( self._Entity, true, 0, self.velocityUp, 0, 0.1 )
		end
	else
	if self._state == 3 then
		self.Pos.Y = self.Pos.Y + delta * self.velocityUp
		if self.Pos.Y > self._start then
			self._state = 0
			self._timer = 0
			SOUND3D.Stop(self._loopSnd)
			SOUND3D.SetLoopCount(self._loopSnd,1)
			PlaySound3D("items/stoneblock-movingup-stop",self.Pos.X, self.Pos.Y, self.Pos.Z, 4, 8)
			ENTITY.PO_MaintainVelocity( self._Entity, false )
			ENTITY.SetVelocity(self._Entity, 0,0,0)
		else
			ENTITY.SetVelocity(self._Entity, 0,self.velocityUp,0)
		end
	end end end end
end

function MovingBoulder:OnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl,velocity_me, velocity_other)	--e.he
	--Game:Print(self._Name.." "..velocity_me.." "..velocity_other.." "..self._velBefore)
	--Game:Print(self._Name.." "..nx.." "..ny.." "..nz)
	if e_other and self._state == 1 and ny < -0.5 then		-- -self._velBefore > self.velocityDown * 0.3 then
		--Game:Print("vvv")
		local obj = EntityToObject[e_other]
		if obj and obj.OnDamage then
			obj:OnDamage(self.Damage, self, AttackTypes.Physics)
			--if obj == Player and self.s_SubClass.Sounds and self.s_SubClass.Sounds.damageByRagdoll then
			--	self:PlayRandomSound2D(self.s_SubClass.Sounds.damageByRagdoll)
			--end
		end
	end
end
