o.OnInitTemplate = CItem.StdOnInitTemplate

function C2L3_Zyrandol1:OnPrecache()
	Cache:PrecacheParticleFX(self.firstFX)
	Cache:PrecacheParticleFX(self.deathFX)
    Cache:PrecacheParticleFX(self.sparksFX)
    Cache:PrecacheItem("KamykWybuch.CItem")
    Cache:PrecacheSounds("impacts/glass_big")
    Cache:PrecacheSounds("impacts/barrel-metal-explode")
end

function C2L3_Zyrandol1:OnCreateEntity()
    self:AddTimer("Start",1.0)
end

function C2L3_Zyrandol1:Start()
    MDL.SetRagdollLinearDamping(self._Entity,0.1)
    MDL.SetRagdollAngularDamping(self._Entity,0.1)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
    
    local joint = MDL.GetJointIndex(self._Entity,"joint3_getmass")     
    ENTITY.EnableCollisionsToRagdoll(self._Entity, joint, 0.2, 1) 
    self._fristTimeCol = false
    self:ReleaseTimers()
end

function C2L3_Zyrandol1:OnCollision(x,y,z,nx,ny,nz,e,he)
	if self._disableCol then
		self.OnCollision = nil
		return
	end
    if ENTITY.IsFixedMesh(e) then
		if not self._fristTimeCol then
			SOUND.Play3D('impacts/barrel-metal-explode',x,y,z,80,120)
	        SOUND.Play3D('impacts/glass_big',x,y,z,80,120)
	        self._fristTimeCol = true
			local a = {
				"Wait:1.5",        
				"L:p:DisableCol()",
				"Wait:1.0",
				"Kill:p",
			}
			self._fx = AddPFX(self.firstFX,1.5,Vector:New(x,y,z)) 
			
	        ENTITY.RegisterChild(self._Entity,self._fx)    
			PARTICLE.SetParentOffset(self._fx,0,0,0,"joint3_getmass")

			--self._fx = self:BindFX(self.firstFX,1.5,"joint3_getmass") 
			self:LaunchAction(a,x,y,z)
	    end
    end

    local no = math.random(1,table.getn(self.Sounds.Collision))
    SOUND.Play3D(self.Sounds.Collision[no],x,y,z,FRand(20,30),120)
    local no2 = math.random(1,table.getn(self.Sounds.Collision2))
    SOUND.Play3D(self.Sounds.Collision2[no2],x,y,z,FRand(20,30),120)
end

function C2L3_Zyrandol1:DisableCol()
	self._disableCol = true
end

function C2L3_Zyrandol1:OnRelease()
    if LEVEL_RELEASING then return end
	local x,y,z = MDL.TransformPointByJoint(self._Entity,MDL.GetJointIndex(self._Entity,"joint4"),0,5,0)
	AddPFX(self.deathFX,1.5,Vector:New(x,y,z))
	if self._fx then
		PARTICLE.Die(self._fx)
		self._fx = nil
	end
    for i=1, self.sparksNo do
        local obj
        local ke
        ke, obj = AddItem("KamykWybuch.CItem",nil,Vector:New(x + FRand(0, 1.0), y+i/self.sparksNo, z + FRand(0, 1.0)) )
        ENTITY.EnableDraw(ke, false)
        obj:BindFX(self.sparksFX, 0.3)
        
        local angle = math.random(0,360)
		local x = math.sin(angle) + math.cos(angle)
		local z = math.cos(angle) - math.sin(angle)
		local y = FRand(0,1)
		local vx = x * self.sparksVelocity * FRand(0.7, 1.5)
		local vy = y * self.sparksVelocity * FRand(0.7, 1.5)
		local vz = z * self.sparksVelocity * FRand(0.7, 1.5)

        ENTITY.SetVelocity(ke,vx,vy,vz)
        ENTITY.SetTimeToDie(ke,FRand(self.sparksLifeTime*0.8, self.sparksLifeTime*1.2)) -- lifetime (min,max)
    end
    SOUND.Play3D('impacts/glass_pause_1',x,y,z,FRand(20,30),120)
    SOUND.Play3D('impacts/barrel-metal-explode',x,y,z,FRand(20,30),120)
end
