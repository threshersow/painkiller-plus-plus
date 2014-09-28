-------------------------------------------------------------------------------
function IceBullet:OnCreateEntity()
    ENTITY.EnableNetworkSynchronization(self._Entity,true,false,2)
    ENTITY.SetSynchroString(self._Entity,"IceBullet.CItem")
        
    if Game.GMode == GModes.SingleGame then 
        self:PO_Create(BodyTypes.SphereSweep,0.001,ECollisionGroups.Missile)
    else
        self:PO_Create(BodyTypes.SphereSweep,0.001,ECollisionGroups.Particles)
    end
    ENTITY.EnableDraw(self._Entity,false)
    ENTITY.EnableCollisions(self._Entity)
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    self._time = 0
    self._lPos = Vector:New(self.Pos)
    self:Client_OnCreateEntity(self._Entity)
end
--============================================================================
function IceBullet:Client_OnCreateEntity(entity)
    local fx = AddPFX("FX_icebullet",0.5,Vector:New(0,0,0))
    ENTITY.RegisterChild(entity,fx,true)
    PARTICLE.SetParentOffset(fx,0,0,0,nil)
    local t = ENTITY.Create(ETypes.Trail,"trail_spawn","t")
    ENTITY.SetPosition(t,0,0,0)
    ENTITY.AttachTrailToBones(entity,t)
    WORLD.AddEntity(t)
end
--============================================================================
function IceBullet:OnPrecache()
	Cache:PrecacheParticleFX("FX_icebullet")
    Cache:PrecacheTrail("trail_spawn")        
end
-------------------------------------------------------------------------------
function IceBullet:Update()
    self.Timeout = self.Timeout - 1
    if self.Timeout <= 0 then   
        self:OnCollision(self.Pos.X,self.Pos.Y,self.Pos.Z,0,0,0)
    end
end
-------------------------------------------------------------------------------
function IceBullet:Tick(delta)    
    
    self._time = self._time + delta     
    local x,y,z = ENTITY.GetPosition(self._Entity)
    local vx,vy,vz,vl = ENTITY.GetVelocity(self._Entity)    
    
    ENTITY.RemoveFromIntersectionSolver(self.ObjOwner._Entity)
    ENTITY.RemoveFromIntersectionSolver(self._Entity)    
    local b,d,lx,ly,lz,nx,ny,nz,he,e = WORLD.LineTrace(self._lPos.X,self._lPos.Y,self._lPos.Z,x,y,z)            
    ENTITY.AddToIntersectionSolver(self.ObjOwner._Entity)
    ENTITY.AddToIntersectionSolver(self._Entity)
    
    if b then self:OnCollision(lx,ly,lz,nx,ny,nz,e) end    
    self._lPos:Set(x,y,z)
end
-------------------------------------------------------------------------------
function IceBullet:OnCollision(x,y,z,nx,ny,nz,e)
    
    local mode = 0
    local obj = EntityToObject[e]
    if obj then
        if Game.GMode == GModes.SingleGame then        
            if obj._Class == "CActor" and not obj.disableFreeze and not obj.notBleeding then        
                obj:Freeze()
            end
        else
            if obj._Class == "CPlayer" then
                mode = 1
            end            
        end
    end
        
    
    self.CL_OnHit(e,x,y,z,mode)
    GObjects:ToKill(self)
end
-------------------------------------------------------------------------------
function IceBullet:CL_OnHit(e,x,y,z,mode)
    
    if mode == 1 then
        local obj = EntityToObject[e]
        if obj then 
        
	            local action = {
	                {"L:p.FrozenArmor = true"},
	                {"Wait:5"},
	                {"L:p.FrozenArmor = false"},
	            }	
	            AddAction(action,obj,"p._died")      
	            	end   
        
        if not obj or obj ~= Player then
            local fx = AddPFX("bones_glow",0.5)
            ENTITY.RegisterChild(e,fx)
            PARTICLE.SetParentOffset(fx,0,0,0,"k_chest",0.8,0.8,0.8)                 
            local action = {
                {"Wait:5"},
                {"L:ENTITY.KillAllChildrenByName("..e..",'bones_glow')"},
            }
            AddAction(action)
        end
    end
    
    PlaySound3D("impacts/bullet-glass1",x,y,z,10,25)        
    --AddPFX("RifleHitWall", 0.5 ,Vector:New(x,y,z))       
end
Network:RegisterMethod("IceBullet.CL_OnHit", NCallOn.ServerAndAllClients, NMode.Reliable, "efffb") 
-------------------------------------------------------------------------------
