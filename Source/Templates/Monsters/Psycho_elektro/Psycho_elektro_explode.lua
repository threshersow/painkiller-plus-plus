function Psycho_elektro_explode:OnCreateEntity()
    for i,v in self.s_SubClass.DeathJoints do
        local x,y,z = self:GetJointPos(v)
        AddPFX("psyhoFX", FRand(1,1.5),Vector:New(x,y,z))
    end
    self._fx = self:BindFX("psyhoFlash",0.1,"k_glowa",-0.2,-0.2,0)
end

function Psycho_elektro_explode:CustomUpdate()
    if math.random(1,35) == 10 and self.Animation == "walk_zwiazany_elektro" then
		if not SOUND3D.IsPlaying(self._sndE) then
			self._sndE = SOUND.Play3D("actor/psycho_elektro/psycho_shock"..math.random(1,3),self.Pos.X,self.Pos.Y,self.Pos.Z,30,50)
		end
        for i,v in self.s_SubClass.DeathJoints do
            local x,y,z = self:GetJointPos(v)
            AddPFX("psyhoFX", FRand(1,1.5),Vector:New(x,y,z))
        end
        local x,y,z = ENTITY.GetPosition(self._Entity)
        if not self._fx then
            self._fx = self:BindFX("psyhoFlash",0.1,"k_glowa",-0.2,-0.2,0)
        end
        AddAction({
                   {"Light:a[1],a[2],a[3],200,200,100, 2, 3 , 1, 0.2,0.5,0.2"},
                   {"Wait:1.5"},
                   {"L:PARTICLE.Die(p._fx,false)"},
                   {"L:p._fx=nil"}},self,nil,x,y+1.2,z+0.5)
    end

end


function Psycho_elektro_explode:Explode()
	if not self._exploded then
        
        if self._fx then 
            ENTITY.Release(self._fx) 
            self._fx = nil
        end
        
		self._exploded = true
		local aiParams = self.AiParams
		local x,y,z = self._groundx,self._groundy + 1.8, self._groundz
		WORLD.Explosion2(x,y,z, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)
		-- sound
		self:PlaySound("expl")
		local r = Quaternion:New_FromNormal(0,1,0)
		AddObject("FX_rexplode.CActor",1,Vector:New(x,y,z),r,true) 
		
		-- light
		AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y,z)
		if Game._EarthQuakeProc then
			local g = Templates["Grenade.CItem"]
			Game._EarthQuakeProc:Add(x,y,z, 5, g.ExplosionCamDistance, g.ExplosionCamMove, g.ExplosionCamRotate, false)
		end

        self._disableDeathSounds = true
        if self.Health > 0 then
			self:OnDamage(self.Health + 2, self)
		end
		--
	end
end

function Psycho_elektro_explode:CustomOnHit()
	if self.Animation == "atak_explohead" then
		self:Explode()
	end
end
