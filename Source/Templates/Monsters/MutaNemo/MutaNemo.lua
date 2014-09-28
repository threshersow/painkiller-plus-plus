function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
    if self.spawnDecalFreq then
        self:AddTimer("SpawnDecalWaterF",self.spawnDecalFreq)
    end
    if self.spawnParticlesFreq then
        self:AddTimer("ParticleWater",self.spawnParticlesFreq)
    end
end

function o:Splash()
	local x,y,z = self.Pos.X, self.Pos.Y, self.Pos.Z
	AddObject("FX_splash.CActor",0.3,Vector:New(x,y,z),nil,true)        
end

function o:ParticleWater()
    if self._isWalking then
        self:AddPFX("swim")
    end
end

function o:SpawnDecalWaterF()
    if self._isWalking then
		self:SpawnDecalWater()
    end
end

function o:SpawnDecalWater()
    local x,y,z = self._groundx,self._groundy,self._groundz
    local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x,y+0.5,z,x,y-0.5,z)
    if b and e then
        ENTITY.SpawnDecal(e,"splashMutaNemo",x,y,z,0,1,0)
	end
	self:PlaySound("swim")
end

function o:CustomOnDeath()
	if self._pfxal then
		ENTITY.Release(self._pfxal)
	end
end

function o:Alarm()
	self._pfxal = self:BindFX('alarm')
end

function o:CalcVel()
	local brain = self._AIBrain
	self:RotateToVector(brain._enemyLastSeenPoint.X,brain._enemyLastSeenPoint.Y,brain._enemyLastSeenPoint.Z)
    self._vdest = Vector:New(0,0,0)
	local v = Vector:New(math.sin(self._angleDest), 0, math.cos(self._angleDest))
	v:Normalize()
	v.Y = self.AiParams.jumpUpStren
	v:MulByFloat(self.AiParams.jumpStren)
	self._vdest.X, self._vdest.Y, self._vdest.Z = v.X, v.Y, v.Z
end

function o:OnStartAnim(anim)
	if anim == "atak" then
		self:StopFlying()
	end
end
