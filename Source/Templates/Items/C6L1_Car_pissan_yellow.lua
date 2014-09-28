o.gibGetVelFromJoint = "joint2_getmass"

o.OnInitTemplate = CItem.StdOnInitTemplate
function C6L1_Car_pissan_yellow:OnCreateEntity()

    MDL.SetRagdollLinearDamping(self._Entity,0.5)
    MDL.SetRagdollAngularDamping(self._Entity,0.9)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)    
    
    ENTITY.EnableCollisionsToRagdoll(self._Entity, 0, 0.1, 0.1)
    ENTITY.EnableCollisionsToRagdoll(self._Entity, 1, 0.1, 0.1)
    if self.alarmON then
        self:BindSound("misc/car-alarm"..math.random(1,3).."-loop",15,40,true,"joint2_getmass")
    end
    if self.Pinned then
        MDL.SetPinned(self._Entity, true)
    end
end

function o:CustomOnGib()
    local x,y,z = MDL.GetJointPos(self._Entity,0)
	if self.Explosion then
        local e = self.Explosion
		WORLD.Explosion2(x,y,z, e.stren, e.range, nil, AttackTypes.Rocket, e.damage)
		AddPFX(e.fx,e.fxSize,Vector:New(x,y,z)) 
		self:PlaySound("explosion",nil,nil,nil,nil,x,y,z)
        
        Game._EarthQuakeProc:Add(x,y,z, e.eqTimeOut, e.eqRange, e.eqCamera, e.eqCamera, 1.0)
	end
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.RagdollColliding)

--    MDL.SetRagdollLinearDamping(self._Entity,0.1)
    MDL.SetRagdollAngularDamping(self._Entity,0.8)
	
	self._fxb = self:BindFX("burnin")
	self:AddTimer("endfire",FRand(4.0,5.0))


end


function o:endfire()
	PARTICLE.Die(self._fxb)
	self:ReleaseTimers()
    if self.TimeToDisappear then
        self:AddTimer("disappear",self.TimeToDisappear * FRand(1.0,1.2))
    end
end

function o:disappear()
	GObjects:ToKill(self,true)
    ENTITY.SetTimeToDie(self._Entity,2)
end


function o:SetKillOnCol()
    self.killOnCollision = true
end

function o:CustomOnDeath()
	if not self.enableGibWhenHPBelow then
        if self.Explosion then
            local e = self.Explosion
            --WORLD.Explosion2(x,y,z, e.stren, e.range, nil, AttackTypes.Rocket, e.damage)
            local x,y,z = self.Pos.X, self.Pos.Y, self.Pos.Z
            AddPFX(e.fx,e.fxSize,Vector:New(x,y,z)) 
            self:PlaySound("explosion",nil,nil,nil,nil,x,y,z)
            
            Game._EarthQuakeProc:Add(x,y,z, e.eqTimeOut, e.eqRange, e.eqCamera, e.eqCamera, 1.0)
        end
        
        self._fxb = self:BindFX("burnin")
        self:AddTimer("endfire",FRand(4.0,5.0))
	end
end

