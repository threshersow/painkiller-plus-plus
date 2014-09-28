function Vamp_Big_Barrel:OnPrecache()
    Cache:PrecacheItem("BarrelSmall.CItem")
    Cache:PrecacheActor("FX_rexplode.CActor")
end

function Vamp_Big_Barrel:OnCreateEntity()
	self._fuseloop = self:BindSound("actor/evilmonkv3/fuse_burning-loop",8,30,true)
end


function Vamp_Big_Barrel:CustomUpdate()
    if self.TimeToLive then
		self.TimeToLive = self.TimeToLive - 1
		if self.TimeToLive < 0 then
			self.TimeToLive = nil
            local aiParams = self.AiParams
			self:SetAnim(aiParams.collisionAnim, false)
            self.AIenabled = false
            return
		end
	end
end

function Vamp_Big_Barrel:CustomOnDamage(he,x,y,z,obj, damage, type)
	if obj == self then
		return false
	end
	if type == AttackTypes.Suicide then
		return true
	end
	if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        local jName = MDL.GetJointName(e,j)
        if jName == self.AiParams.barrelBone then
			return false, self.Health + 2
		end
		return false
	else
		if x and type == AttackTypes.Rocket then
			local x1,y1,z1 = self:GetJointPos(self.AiParams.barrelBone)
			local dist = Dist3D(x,y,z,x1,y1,z1)
			--Game:Print("odleglosc wybuchu od jointa : "..dist.." "..damage)
			if dist < 0.6 then
				return false, self.Health + 2
			end
		end
	end
	return false
end

Vamp_Big_Barrel.CustomDelete = nil

--------------
function Vamp_Big_Barrel:ExplodeBarrel(dist)
	local xd,yd,zd = self._groundx,self._groundy,self._groundz
	local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v:Normalize()
	self:Explode(xd + v.X*dist, yd + 1.0, zd + v.Z*dist)
	--DEB1,DEB2,DEB3 = xd + v.X*dist, yd + 1.0, zd + v.Z*dist
end


function Vamp_Big_Barrel:Explode(x,y,z)
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
	if not self._exploded then
		self._exploded = true
		local aiParams = self.AiParams
		WORLD.Explosion2(x,y,z, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Suicide,aiParams.Explosion.Damage)
		-- sound
		PlaySound3D("impacts/barrel-tnt-explode",x,y,z,20,150)
		local r = Quaternion:New_FromNormal(0,1,0)
		AddObject("FX_rexplode.CActor",1,Vector:New(x,y,z),r,true) 
		
		-- light
		AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y,z)
		if Game._EarthQuakeProc then
			local g = Templates["Grenade.CItem"]
			Game._EarthQuakeProc:Add(x,y,z, 5, g.ExplosionCamDistance, g.ExplosionCamMove, g.ExplosionCamRotate, false)
		end

		MDL.SetMeshVisibility(self._Entity,"BECZKA_MALAShape", false)	
        local e = AddItem("BarrelSmall.CItem",nil,self.Pos,nil,Quaternion:New_FromEuler( 0, -self.angle, math.pi/2))
        ENTITY.PO_Enable(e, false)
	    ENTITY.ExplodeItem(e, "../Data/Items/"..self.deathExplosionItem, self.BarrelExplosion.streng, self.BarrelExplosion.Radius, self.BarrelExplosion.LifetimeAfterExplosion,self.deathExplosionItemScale)
        ENTITY.Release(e)
        if self.Health > 0 then
			self:OnDamage(self.Health + 2, self)
		end
	end
end

function Vamp_Big_Barrel:CustomOnDeath()
	if self._fuseloop then
		ENTITY.Release(self._fuseloop)
		self._fuseloop = nil
	end
	self:Explode(self._groundx,self._groundy,self._groundz)		-- narazie
	ENTITY.SetVelocity(self._Entity, 0, self.velocityUpOnDeath, 0)
end
