--==========================================================================
function DemonGun:Fire()
    local s = self:GetSubClass()
    local cx,cy,cz = ENTITY.PO_GetPawnHeadPos(self.ObjOwner._Entity)                
    local fv = self.ObjOwner.ForwardVector
    local rot = Quaternion:New_FromNormalZ(fv.X,fv.Y,fv.Z) 
    for i=1,s.HowManyTraces do
        local r = s.FireRadius
        local sx,sy = RadiusRandom2D(r)
        local sz = s.FireRange
        sx,sy,sz = rot:TransformVector(sx,sy,sz)                
        local b,d,x,y,z,nx,ny,nz,he,e = self.ObjOwner:TraceToPoint(cx+sx,cy+sy,cz+sz)
        if b then
            local obj = EntityToObject[e]
            if obj and obj.OnDamage then obj:OnDamage(s.FireDamage,self.ObjOwner,AttackTypes.Demon,x,y,z,nx,ny,nz,he) end
            CheckStartGlass(he,x,y,z,1,fv.X*50,fv.Y*50,fv.Z*50)
            if obj and obj._died and obj._gibbed and not obj.demonHitDisable then
				-- schedule velocity, because gib doest not react in the same tick after create
				obj._gibbedByDemon = Vector:New(fv.X*s.PhysicsImpulse,fv.Y*s.PhysicsImpulse,fv.Z*s.PhysicsImpulse)
            end
            if not obj or (obj and not obj.demonHitDisable) then
                WORLD.HitPhysicObject(he,x,y,z,fv.X*s.PhysicsImpulse,fv.Y*s.PhysicsImpulse,fv.Z*s.PhysicsImpulse)
            end
        end
    end
    self.ShotTimeOut = s.FireTimeout
    self._ActionState = "Idle"    
    SOUND.Play2D("hero-demon/demon-shoot"..math.random(1,2),100,true)
    PlayLogicSound("FIRE",self.ObjOwner.Pos.X,self.ObjOwner.Pos.Y,self.ObjOwner.Pos.Z,40,90,self.ObjOwner)               
    GObjects:Add(TempObjName(),CloneTemplate("DemonFXWarp.CProcess"))
end
--==========================================================================
function DemonGun:AltFire()
end
--==========================================================================
