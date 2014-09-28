function HellAngel:OnInitTemplate()
    self:SetAIBrain()
end


function HellAngel:Throw()
	local brain = self._AIBrain
	if brain and self._AIBrain._enemyLastSeenTime > 0 then
		local aiParams = self.AiParams

		if aiParams.weaponAmmo > 0 then
			aiParams.weaponAmmo = aiParams.weaponAmmo - 1
			
			--MDL.SetMeshVisibility(self._Entity, "polySurfaceShape905", false)
			
			local distToTarget = Dist3D(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z,
                self.Pos.X, self.Pos.Y, self.Pos.Z)
			if distToTarget > 5 then
				local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))

				self.Joint = MDL.GetJointIndex(self._Entity, aiParams.throwItemBindTo)
				local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,aiParams.throwItemBindToOffset.X, aiParams.throwItemBindToOffset.Y, aiParams.throwItemBindToOffset.Z)

				obj.ObjOwner = self
				obj.Pos.X = x
				obj.Pos.Y = y
				obj.Pos.Z = z
				obj.Rot:FromEuler(0, -self.angle, 0)
				obj:Apply()
				obj:Synchronize()
				self._objTakenToThrow = obj
				self:ThrowTaken()
			else
				--Game:Print(self._Name.." to close to throw")
			end
		end
	end
end

--[[	
function HellAngel:CustomOnDeath(obj)
	Game:Print("cod")
	if obj == self then
		Game:Print("1")
	end
	if self.disableGhost then
		Game:Print("2")
	end
	if self.AiParams.walkArea then
		Game:Print("3")
	end
	
	
	if obj ~= self and not self.disableGhost and not self.AiParams.walkArea then
		local ghost = CloneTemplate(self.BaseObj)
		ghost.angle = self.angle
		ghost.Pos = self.Pos
		ghost.s_SubClass = Clone(ghost.s_SubClass)
		ghost.s_SubClass.Decal = nil
		ghost:Apply()
		ghost.NotCountable = true
		GObjects:Add(TempObjName(), ghost)
		--Game:Print("create ghost")
		ENTITY.PO_SetCollisionGroup(ghost._Entity, ECollisionGroups.Particles)
		ENTITY.PO_SetMovedByExplosions(ghost._Entity,false)
		ENTITY.RemoveFromIntersectionSolver(ghost._Entity)
		ghost.AIenabled = false
		ghost.TimeToLive = ghost.AiParams.TimeToLive
		ghost.Health  = 99999
		
		local tdj = ghost.s_SubClass.DeathJoints
		if tdj then
			local size = ghost._SphereSize * 0.3
			for i=1,table.getn(tdj) do
				ghost:BindFX(ghost.ghostPFX, size, tdj[i])
			end
		end
		
		ENTITY.RemoveRagdoll(ghost._Entity)
		-- narazie
		MDL.SetMeshVisibility(ghost._Entity, "pCylinderShape2", false)
		MDL.SetMeshVisibility(ghost._Entity, "polySurfaceShape962", false)
		MDL.SetMeshVisibility(ghost._Entity, "polySurfaceShape964", false)
		MDL.SetMeshVisibility(ghost._Entity, "polySurfaceShape1052", false)
		MDL.SetMeshVisibility(ghost._Entity, "polySurfaceShape1056", false)
		MDL.SetMeshVisibility(ghost._Entity, "polySurfaceShape1058", false)
		MDL.SetMeshVisibility(ghost._Entity, "polySurfaceShape1059", false)
		MDL.SetMeshVisibility(ghost._Entity, "polySurfaceShape1055", false)
		
		--
		
		function ghost:CustomUpdate()
			local dist = Dist3D(Player._groundx, Player._groundy, Player._groundz, self._groundx, self._groundy, self._groundz)
			local aiParams = self.AiParams
			if (not self._isWalking or math.random(100) < 10) and dist > 0.1 then
				self:WalkTo(Player._groundx, Player._groundy, Player._groundz, nil, nil, "walk_ghost")
			end
			if dist < 1.5 and FRand(0.0, 1.0) < aiParams.ghostDamageFreq then
				Player:OnDamage(aiParams.ghostDamage, self)
			end
			if self.TimeToLive then
				self.TimeToLive = self.TimeToLive - 1
				if self.TimeToLive < 0 then
					self.TimeToLive = nil
					GObjects:ToKill(self)
				end
			end
		end
	end
end
--]]
