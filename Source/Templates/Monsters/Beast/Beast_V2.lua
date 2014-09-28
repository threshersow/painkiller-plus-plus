function Beast_V2:OnCreateEntity()
	self._fuseloop = self:BindSound("actor/evilmonkv3/fuse_burning-loop",8,30,true)
end


function Beast_V2:CustomOnDamage(he,x,y,z,obj, damage, type)
	if obj == self then
		return false
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
	return true
end

function Beast_V2:CustomOnDeath()
	if self._fuseloop then
		ENTITY.Release(self._fuseloop)
		self._fuseloop = nil
	end
	self:Explode(self._groundx,self._groundy,self._groundz)		-- narazie
end

function Beast_V2:ExplodeBarrel(dist)
	local xd,yd,zd = self._groundx,self._groundy,self._groundz
	local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v:Normalize()
	self:Explode(xd + v.X*dist, yd + 1.0, zd + v.Z*dist)
end


function Beast_V2:Explode(x,y,z)
	if not self._exploded then
		self._exploded = true
		local aiParams = self.AiParams
		WORLD.Explosion2(x,y,z, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)
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

		MDL.SetMeshVisibility(self._Entity,"pCylinderShape1", false)
		
        local e = AddItem("BarrelBig.CItem",0.5,Vector:New(self._groundx,self._groundy + 1.0,self._groundz),nil,Quaternion:New_FromEuler( 0, -self.angle, 0.5*math.pi))
        ENTITY.PO_Enable(e, false)
	    ENTITY.ExplodeItem(e, "../Data/Items/beczka_mala_zlom.dat", self.BarrelExplosion.streng, self.BarrelExplosion.Radius, self.BarrelExplosion.LifetimeAfterExplosion)
	    ENTITY.Release(e)
        if self.Health > 0 then
            self:OnDamage(self.Health + 2, self)
        end
		--
	end
end

