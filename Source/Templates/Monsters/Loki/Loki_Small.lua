function Loki_Small:OnPrecache()
	Cache:PrecacheActor("Loki_Small_v2.CActor")
	Cache:PrecacheActor("Loki_Small_v3.CActor")
	Cache:PrecacheSounds("actor/loki_small/tick_big_explode")
end


function Loki_Small:OnInitTemplate()
	self._LokiStage = 1	
	self._toNextTransform = 0
end

function Loki_Small:OnUnbind()
	
	self.Pos.X,self.Pos.Y,self.Pos.Z = ENTITY.GetPosition(self._Entity)
	self.CreatePO = true
	self:SetAIBrain()
	self:Apply()

	--local v = Vector:New(x - self.ObjOwner.Pos.X, y - self.ObjOwner.Pos.Y, z - self.ObjOwner.Pos.Z)
	--v.Y = math.abs(v.Y)
	--v.X = v.X * force
	--v.Z = v.Z * force

	local v = self._addVel
	v:Normalize()
	
	self.angle = math.atan2(v.X, v.Z)
	self._angleDest = self.angle

	self.AIenabled = false
	self.enableAIin = 20
	local force = self.breedJumpVelocity
	ENTITY.PO_SetFlying(self._Entity, true)
	self:PlaySound("born")
	ENTITY.SetVelocity(self._Entity, v.X*force*0.5,v.Y*force,v.Z*force*0.5)

	self:SetAnim("walk", true)
	self.AiParams.timeToTransform = FRand(self.AiParams.timeToTransform * 0.9, self.AiParams.timeToTransform * 1.1)
end

--function Loki_Small:SetVel()
--	ENTITY.SetVelocity(self._Entity,self._vdest.X, self._vdest.Y, self._vdest.Z)
--end


function Loki_Small:CustomUpdate()
	if not ENTITY.PO_Exist(self._Entity) then
		return
	end
	if self._LokiStage < 3 then
		self._toNextTransform = self._toNextTransform + 1
		if self._toNextTransform > self.AiParams.timeToTransform then
			self._toNextTransform = 0
			self._LokiStage	= self._LokiStage + 1

			--self.throwHeart = false
			ENTITY.PO_Enable(self._Entity, false)

			self._disableDeathSounds = true
			self:PlaySound({"tick_morph_into_bigger"})

			local t
			if self._LokiStage == 3 then
				t = CloneTemplate("Loki_Small_v3.CActor")
			else
				t = CloneTemplate("Loki_Small_v2.CActor")
			end
			t._LokiStage = self._LokiStage
		
			local obj = GObjects:Add(TempObjName(), t)
			obj.Pos.X = self.Pos.X
			obj.Pos.Y = self.Pos.Y
			obj.Pos.Z = self.Pos.Z
			obj.angle = self.angle
			obj._angleDest = self._angleDest
			obj:SetAIBrain()
			obj:Apply()
			obj:SetAnim("walk", true)
			obj:Synchronize()

			local tdj = obj.s_SubClass.DeathJoints
			if tdj then
				local size = obj._SphereSize * 0.4
				for i=1,table.getn(tdj) do
					--local x,y,z = obj:GetJointPos(tdj[i])
					--AddPFX(self.transformIntoBigVampFX, size ,Vector:New(x,y,z))
					obj:BindFX(self.transformFX, size, tdj[i])
				end
			end
			--Game.BodyCountTotal = Game.BodyCountTotal - 1
			GObjects:ToKill(self)
		end

		if math.random(1000) < 25 then
			if self._AIBrain then
				local enemy = self._AIBrain.r_closestEnemy
				if enemy then
					self:Stop()
					self:RotateToVector(enemy._groundx,enemy._groundy,enemy._groundz)
				end
			end
		end
    else
        if self.TimeToLive then
            self.TimeToLive = self.TimeToLive - 1
            if self.TimeToLive < 0 then
                self.TimeToLive = nil
                if debugMarek then Game:Print("time out -> explode") end
                local aiParams = self.AiParams
                self:SetAnim(aiParams.collisionAnim, false)
                self.AIenabled = false
            end
        end
	end
end

function Loki_Small:Explode()
	if not self._exploded then
		if debugMarek then Game:Print("EXPLODE") end
		self._exploded = true
		local aiParams = self.AiParams
		local x,y,z = self._groundx,self._groundy + 1.8, self._groundz
		--WORLD.Explosion2(x,y,z, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)
		-- sound

		local r = Quaternion:New_FromNormal(0,1,0)
		--AddObject("FX_rexplode.CActor",1,Vector:New(x,y,z),r,true) 
		self:AddPFX("explode")
		
		--[[ physical parts
		local px,py,pz = x+nx/2,y+ny/2,z+nz/2
		local n = math.random(4,6) -- how many (min,max)
		for i = 1, n do
			local scale = FRand(0.5,0.8) -- size (min,max)
			local ke = AddItem("KamykWybuchRakieta.CItem",scale,Vector:New(px+FRand(-0.2,0.2),py+FRand(-0.2,0.2),pz+FRand(-0.2,0.2)))
			vx,vy,vz  = r:TransformVector(FRand(-30,30),FRand(22,34),FRand(-30,30))
			ENTITY.SetVelocity(ke,vx,vy,vz)
			ENTITY.SetTimeToDie(ke,FRand(1,2)) -- lifetime (min,max)
			--ENTITY.PO_SetPinned(ke,true)
		end
		--]]
		-- light
		
		AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y,z)
		if Game._EarthQuakeProc then
			local g = Templates["Grenade.CItem"]
			Game._EarthQuakeProc:Add(x,y,z, 5, g.ExplosionCamDistance, g.ExplosionCamMove, g.ExplosionCamRotate, false)
		end


        --local e = AddItem("BarrelSmall.CItem",nil,self.Pos,nil,Quaternion:New_FromEuler( 0, -self.angle, math.pi/2))
        --ENTITY.PO_Enable(e, false)
	    --ENTITY.ExplodeItem(e, "../Data/Items/beczka_mala_zlom.dat", self.BarrelExplosion.streng, self.BarrelExplosion.Radius, false, false, self.BarrelExplosion.LifetimeAfterExplosion)
        --ENTITY.Release(e)
        if self.Health > 0 then
			self:OnDamage(self.Health + 2, self)
		end
		local distToPlayer = Dist3D(Player._groundx, Player._groundy, Player._groundz, self._groundx, self._groundy, self._groundz)
		if distToPlayer < aiParams.Explosion.ExplosionRange then
			Player:OnDamage(aiParams.Explosion.Damage, self)
		end
		--
	end
end



-------------------------------



function Loki_Small:SetIdle()
    --if debugMarek then Game:Print(self._Name.." loki small wants idle") end
end
