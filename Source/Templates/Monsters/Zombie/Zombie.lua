function Zombie:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastTimeSpecial = -100
end


function Zombie:CustomOnDeath()
	local brain = self._AIBrain
	if brain.Objhostage2 then
		if self._oldColGr and self._oldColGr > 0 and brain.Objhostage2._enabledRD then
			if debugMarek then Game:Print("old col "..brain.Objhostage2._Name) end
			MDL.SetRagdollCollisionGroup(brain.Objhostage2._Entity, self._oldColGr)
			self._oldColGr = nil
		end

		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end


function Zombie:ShieldBlow(par3, par4)
	local br = self._AIBrain
	if br and br.r_closestEnemy and br.r_closestEnemy._Class == "CPlayer" then
		local aiParams = self.AiParams
		local dist = Dist3D(self._groundx, self._groundy, self._groundz, br.r_closestEnemy._groundx, br.r_closestEnemy._groundy, br.r_closestEnemy._groundz)
		local angleAttack = math.atan2(br.r_closestEnemy._groundx - self._groundx, br.r_closestEnemy._groundz - self._groundz)
		local aDist = AngDist(self.angle, angleAttack)
		
		if dist <= aiParams.attackRange and math.abs(aDist) < aiParams.attackRangeAngle*math.pi/180 then
			local cam = aiParams.ShieldBlow
			Game._EarthQuakeProc:Add(br.r_closestEnemy._groundx, br.r_closestEnemy._groundy, br.r_closestEnemy._groundz, cam.cameraShakeTime, self.StompRange, cam.cameraShake * 0.1, cam.cameraShake)
			local x,y,z = CAM.GetAng()
			--x = math.mod(x, 360)
			--y = math.mod(y, 360)
			--z = math.mod(z, 360)
			x = x - cam.cameraMess.X * FRand(0.9, 1.1)
			y = y - cam.cameraMess.Y * FRand(0.9, 1.1)
			z = z - cam.cameraMess.Z * FRand(0.9, 1.1)
			CAM.SetAng(x,y,z)

            PlaySound2D(self._SoundDirectory.."zombie_shieldhit")
		end
	end
end

function Zombie:OffWithHisHead(target,vx,vy,vz)
	if not target._headLess then
		MDL.SetMeshVisibility(target._Entity,"polySurfaceShape543", false)
		
		self._beheadedTarget = true
		
		if debugMarek then Game:Print(target._Name.." znowu idle 3") end
		target:SetAnim("idle", false)
		target:FullStop()
		target.enableAIin = nil
		target.AIenabled = false
		target._headLess = 1
		target._disableHits = true
		
		--
		local obj = GObjects:Add(TempObjName(),CloneTemplate("Zombie_Soldier_Head.CItem"))
		local Joint = MDL.GetJointIndex(target._Entity, "k_glowa")
		local x,y,z = MDL.TransformPointByJoint(target._Entity,Joint,0,0,0)

		obj.ObjOwner = target
		obj.Pos.X = x
		obj.Pos.Y = y
		obj.Pos.Z = z
		if self._AIBrain and self._AIBrain.r_closestEnemy then
			obj.PosDestX = target._groundx - self._groundx
			obj.PosDestY = target.Pos.Y - self.Pos.Y
			obj.PosDestZ = target._groundz - self._groundz
		end
		obj:Apply()
		--
		
		if Tweak.GlobalData.GermanVersion then
			target._fx = target:BindFX("FX_cuthead_german",0.5,"k_glowa")
		else
			target._fx = target:BindFX("FX_cuthead",0.5,"k_glowa")
		end
		target:PlaySound("missingHead")

		--target._proc = PMove:New(target, target.AiParams.moveSpeedWhileBerserk)
		target._proc = Templates["PMove.CProcess"]:New(target, target.AiParams.moveSpeedWhileBerserk)
		target._proc:SetDir(Vector:New(Player._groundx - x, 0, Player._groundz - z))
		GObjects:Add(TempObjName(), target._proc)

		if target.Health > 0 then
			target.Health = 1
		end
		
		if target.CustomUpdateHeadless then
			target:ReplaceFunction("CustomUpdate","CustomUpdateHeadless")
		end
	end	
end

--------------------------
AiStates.beheadZombie = {
	name = "beheadZombie",
	lastTimeCiach = -100,
}

function AiStates.beheadZombie:OnInit(brain)
	local actor = brain._Objactor
	local target = brain.Objhostage2
    if target then
        self.lastTimeCiach = brain._currentTime
        -- pozniej: staje w pewnej odleglosci kolesia
        local dist = Dist3D(target._groundx, target._groundy, target._groundz, actor._groundx,actor._groundy,actor._groundz)
        if dist > 3 then
            actor:WalkTo(target._groundx, target._groundy, target._groundz, true)		-- narazie
        else
            actor:RotateToVector(target._groundx, target._groundy, target._groundz)
        end
        self.state = 0

        self.active = true
        target._locked = true
        self.lastDirSwordX, self.lastDirSwordY, self.lastDirSwordZ = 0,0,0
        
        target.enableAIin = 2
        target:FullStop()
        if debugMarek then Game:Print(target._Name.." sciecie: target set idle 1 "..dist) end
        target.AIenabled = false
        target:SetIdle()
    end
end

function AiStates.beheadZombie:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	local target = brain.Objhostage2
    brain._lastTimeSpecial = brain._currentTime
    if not target then
        self.active = false
        if debugMarek then Game:Print("NOT TARGET") end
        --Game.freezeUpdate = true
        return
    end
	if target.enableAIin then
		target.enableAIin = target.enableAIin + 1
	else
		if target.AIenabled then
			Game:Print(actor._Name.." ERROR: target.enableAIin = NULL")
			self.active = false
			return
		end
	end
	
	if self.state == 0 then
		local dist = Dist3D(target._groundx, target._groundy, target._groundz, actor._groundx,actor._groundy,actor._groundz)
		if not target._isWalking and dist < 2.5 then 
			actor:Stop()
			--actor:RotateToVector(target._groundx, target._groundy, target._groundz)
			self.state = 1
		else
			if not actor._isWalking then
				if dist > 4.5 then 
					if debugMarek then Game:Print("sciecie: doszedl fail") end
					self.active = false
				else
					if debugMarek then Game:Print("sciecie: doszedl fail, ale i tak ciach") end
					self.state = 1
				end
			end
		end
	end
	
	
	if self.state == 1 and not self._isRotating then
		self._fx = actor:BindFX(unpack(aiParams.BeHeadFX))
		actor:SetAnim("atak2", false)
		self.state = 2
		if debugMarek then Game:Print(target._Name.." target set idle 2") end
		target:SetIdle()
		target.enableAIin = 0.3 * 30 + 1
		target.AIenabled = false
		--local dist = Dist3D(target._groundx, target._groundy, target._groundz, actor._groundx,actor._groundy,actor._groundz)
		--if dist < 3 then
		--	target:RotateToVector(actor._groundx, actor._groundy, actor._groundz)
		--end
	end
	
	if target.Health <= 0 then
		self.active = false
	end
	
	if self.state == 2 then
		if (actor.Animation ~= "atak2" or not actor._isAnimating) then
			if self._fx then
				--Game:Print("KONIEC _FX")
				ENTITY.Release(self._fx)
				self._fx = nil
			end
			
			self.active = false
			self.state = 3
			if actor._beheadedTarget and brain._distToNearestEnemy < aiParams.attackRange then
				brain.escape = math.random(30, 40)
				actor._beheadedTarget = nil
				if debugMarek then Game:Print("UCIECZKA") end
			end

			--target.enableAIin = 30
		else
			local idx  = MDL.GetJointIndex(actor._Entity,"joint2")	
			local x,y,z = MDL.TransformPointByJoint(actor._Entity, idx, 0.5,0.0,0.0)	-- 0.7
			local x2,y2,z2 = MDL.TransformPointByJoint(actor._Entity, idx, 1.6,0.0,0.0)
			local vx = self.lastDirSwordX - x
			local vy = self.lastDirSwordY - y
			local vz = self.lastDirSwordZ - z
			y = y - 0.5
			y2 = y
			local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTrace(x,y,z, x2,y2,z2)
			--Game.freezeUpdate = true

			if debugMarek then
				actor.yadebug1 = x
				actor.yadebug2 = y
				actor.yadebug3 = z
				actor.yadebug4 = x2
				actor.yadebug5 = y2
				actor.yadebug6 = z2
			end
			
			if e then
				local obj = EntityToObject[e]
				if obj ~= actor then
					if obj and obj.OnDamage then
						if debugMarek then Game:Print("zombi ciachnal : "..obj._Name) end
						if obj.s_SubClass and obj.s_SubClass.Animations and obj.s_SubClass.Animations.dead then
							if debugMarek then Game:Print("zombi ciachnal : zombasa") end
							--Game.freezeUpdate = true
							actor:OffWithHisHead(obj,vx,vy,vz)
						else
							if debugMarek then Game:Print("duzy sword damage "..obj._Name) end
							obj:OnDamage(aiParams.weaponDamage, actor)
						end
					end
				end
			end
		end
	end
end

function AiStates.beheadZombie:OnRelease(brain)
	local actor = brain._Objactor
	self.active = false
	brain._lastTimeSpecial = brain._currentTime
	actor._beheadedTarget = nil
	if brain.Objhostage2 then
		brain.Objhostage2._locked = nil
		brain.Objhostage2 = nil
	end
	if self._fx then
		ENTITY.Release(self._fx)
		self._fx = nil
	end
end


function AiStates.beheadZombie:Evaluate(brain)
	if self.active and brain.Objhostage2 then
		return 0.7
	else
		local actor = brain._Objactor
		if math.random(100) < 3 and actor._state ~= "ATTACKING" then
			local aiParams = actor.AiParams
			if brain._lastTimeSpecial + aiParams.minDelayBetweenBehead < brain._currentTime and not brain.Objhostage2 then
				local maxDist = 9999
				
				for i,v in Actors do
					if v.Health > 0 and v._AIBrain and v._AIBrain.r_closestEnemy and not v._locked and
						v.s_SubClass.Animations.dead and v.AIenabled and aiParams.CanBehead == v.Model then
						local dist = Dist3D(v._groundx, v._groundy, v._groundz, actor._groundx,actor._groundy,actor._groundz)
						if dist < maxDist and dist < aiParams.viewDistance then
							--if v._AIBrain._lastHitTime > 0 then
								if ENTITY.SeesEntity(actor._Entity, v._Entity) then
									local v2 = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
       								v2:Normalize()
									local destx = actor._groundx + v2.X
									local desty = actor._groundy
									local destz = actor._groundz + v2.Z
									local dist2 = Dist3D(destx, desty, destz, v._groundx,v._groundy,v._groundz)
									if dist2 < dist then 
										maxDist = dist
										brain.Objhostage2 = v
									end
								end
							--end
						end
					end
				end

				if brain.Objhostage2 then
					if debugMarek then Game:Print(actor._Name.." cel namierzony do sciecia: "..brain.Objhostage2._Name) end
					return 0.6
				end
			end
		end
	end
	return 0.0
end
