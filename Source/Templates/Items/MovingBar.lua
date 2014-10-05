--o.OnInitTemplate = CItem.StdOnInitTemplate

function o:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.Phantom)
	ENTITY.EnableCollisions(self._Entity, true, 0.1, 0.1)
	--ENTITY.PO_EnableGravity(self._Entity, false)
	ENTITY.PO_SetPinned(self._Entity, true)
	--ENTITY.PO_SetFreedomOfRotation( self._Entity, EFreedomsOfRotation.Disabled )
	
	local q = Quaternion:New(ENTITY.GetRotationQ(self._Entity))
	
	self._orient = Vector:New(q:TransformVector(0,0,1))
	--Game:Print(">>>>>>>>> rot "..x.." "..y.." "..z)
	--self._orient = Vector:New(1,0,0)
	--self._orient:Rotate(x,y,z)
	
	self._startPos1 = Clone(self.Pos)
    self._startPos = Clone(self._startPos1)
	self._startPos2 = Clone(self.Pos)
	self._startPos2.X = self._startPos2.X - self._orient.X * self.moveDistance
	self._startPos2.Y = self._startPos2.Y - self._orient.Y * self.moveDistance
	self._startPos2.Z = self._startPos2.Z - self._orient.Z * self.moveDistance
	
	self._state = 0
	self._timer = 0
	self._delta = 0
	self._stopped = true
end

function o:EditTick( delta )
    ENTITY.PO_MaintainLinearMovement( self._Entity, false )
    ENTITY.PO_MaintainVelocity( self._Entity, false)
	self._state = 0
	self._timer = 0

end

function o:OnRelease()
	if self._loopSnd then
		SOUND3D.Stop(self._loopSnd)
		SOUND3D.SetLoopCount(self._loopSnd,1)
		self._loopSnd = nil
	end
end

function o:Start()
	self._stopped = false
end

function o:Stop()
    --ENTITY.PO_MaintainVelocity( self._Entity, false )
	ENTITY.SetVelocity(self._Entity, 0,0,0)
	if self._loopSnd then
		SOUND3D.Stop(self._loopSnd)
    	SOUND3D.SetLoopCount(self._loopSnd,1)
		self._loopSnd = nil
	end
	self._stopped = true
end


function o:Tick(delta)
	if self._stopped or Game.freezeUpdate then return end
	
	if self._state == 0 then		-- UP
		self._timer = self._timer + delta
		if self._timer > self.timeUp then
			PlaySound3D("doors/woodentrap-start", self.Pos.X, self.Pos.Y, self.Pos.Z, 4, 8)
			self._loopSnd = PlaySound3D("doors/woodentrap-loop", self.Pos.X, self.Pos.Y, self.Pos.Z, 5, 12)
			SOUND3D.SetLoopCount(self._loopSnd,0)
			self._state = 1
			self._timer = 0

			self._delta = 0
			self._startPos = Clone(self._startPos1)
			ENTITY.SetPosition( self._Entity, self._startPos.X,self._startPos.Y,self._startPos.Z)
			return
		end
	end

	if self._state == 1 then

		self._delta = self._delta + delta * self.velocityUp

		local x,y,z = self.Pos.X - self._orient.X*self._delta, self.Pos.Y - self._orient.Y*self._delta, self.Pos.Z - self._orient.Z*self._delta
		local distToEnd = Dist3D(x,y,z, self._startPos.X, self._startPos.Y, self._startPos.Z)

		ENTITY.SetPosition( self._Entity, x,y,z)
		
		if distToEnd > self.moveDistance then
			ENTITY.SetPosition( self._Entity, self._startPos.X - self._orient.X*self.moveDistance, self._startPos.Y - self._orient.Y*self.moveDistance, self._startPos.Z - self._orient.Z*self.moveDistance)

			self._state = 2
			self._timer = 0
			self._delta = 0
			ENTITY.PO_MaintainVelocity( self._Entity, false )
			ENTITY.SetVelocity(self._Entity, 0,0,0)
			
			if self.effectDeltaY then
				AddPFX('butbig',0.5,Vector:New(self.Pos.X, self.Pos.Y + self.effectDeltaY, self.Pos.Z))
				Game._EarthQuakeProc:Add(self.Pos.X, self.Pos.Y + self.effectDeltaY, self.Pos.Z, 14, 3, 0.1, 0.1, false)
			end
			SOUND3D.Stop(self._loopSnd)
			SOUND3D.SetLoopCount(self._loopSnd,1)
			PlaySound3D("doors/woodentrap-stop", self.Pos.X, self.Pos.Y, self.Pos.Z, 10, 40)
		end
	end
	
	if self._state == 2 then
		self._timer = self._timer + delta
		if self._timer > self.timeDown then
			self._state = 3
			self._timer = 0
			self._loopSnd = PlaySound3D("doors/woodentrap-loop", self.Pos.X, self.Pos.Y, self.Pos.Z, 5, 12)
			SOUND3D.SetLoopCount(self._loopSnd,0)

			self._startPos = Clone(self._startPos2)
			ENTITY.SetPosition( self._Entity, self._startPos.X,self._startPos.Y,self._startPos.Z)

			self._delta = 0

			return
		end
	end
	
	if self._state == 3 then
		self._delta = self._delta + delta * self.velocityDown

		local x,y,z = self.Pos.X + self._orient.X*self._delta, self.Pos.Y + self._orient.Y*self._delta, self.Pos.Z + self._orient.Z*self._delta
		local distToEnd = Dist3D(x,y,z, self._startPos.X, self._startPos.Y, self._startPos.Z)

		ENTITY.SetPosition( self._Entity, x,y,z)
		
		if distToEnd > self.moveDistance then

			ENTITY.SetPosition( self._Entity, self._startPos.X + self._orient.X*self.moveDistance, self._startPos.Y + self._orient.Y*self.moveDistance, self._startPos.Z + self._orient.Z*self.moveDistance)
			
			self._state = 0
			self._timer = 0
			SOUND3D.Stop(self._loopSnd)
			SOUND3D.SetLoopCount(self._loopSnd,1)
			PlaySound3D("doors/woodentrap-stop",self.Pos.X, self.Pos.Y, self.Pos.Z, 4, 8)

			ENTITY.SetVelocity(self._Entity, 0,0,0)
			self._delta = 0
			return
		end
	end

end

function o:OnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl,velocity_me, velocity_other)	--e.he
	if e_other and self._state == 1 and ny < -0.5 then		-- -self._velBefore > self.velocityDown * 0.3 then
		local obj = EntityToObject[e_other]
		if obj and obj.OnDamage then
			obj:OnDamage(self.Damage, self, AttackTypes.Physics)
		end
	end
end
