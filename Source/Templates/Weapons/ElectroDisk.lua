-------------------------------------------------------------------------------
function ElectroDisk:OnCreateEntity()
    ENTITY.EnableNetworkSynchronization(self._Entity,true,false,2)
    ENTITY.SetSynchroString(self._Entity,"ElectroDisk.CItem")
    self:PO_Create(BodyTypes.SphereSweep,0.001,ECollisionGroups.Noncolliding)    
    ENTITY.PO_EnableGravity(self._Entity,false)
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    self._lPos = Vector:New(self.Pos)    
    self:Client_OnCreateEntity(self._Entity)
end
-------------------------------------------------------------------------------
function ElectroDisk:OnRelease()
    ENTITY.Release(self._light)   
    self:Client_OnDeleteEntity(self._Entity)
end
-------------------------------------------------------------------------------
function ElectroDisk:OnInitTemplate()
    self:ReplaceFunction("_Synchronize","Synchronize")
    self:ReplaceFunction("Synchronize","nil")
end
--============================================================================
function ElectroDisk:OnPrecache()
	Cache:PrecacheParticleFX("electro_hit")
	Cache:PrecacheParticleFX("electro_hit_wall")
	Cache:PrecacheParticleFX("explo_electrodisk")
	Cache:PrecacheParticleFX("spark_shuriken")
	Cache:PrecacheParticleFX("electrodisk")    
    Cache:PrecacheTrail("trail_shuriken")        
end
--============================================================================
MPElectroDiskFX = {    
    _Entity = nil,
    _lockedEntity = nil,
}
Inherit(MPElectroDiskFX,CProcess)
-------------------------------------------------------------------------------
function MPElectroDiskFX:New(entity)
    local p = Clone(MPElectroDiskFX)
    p._Entity = entity
    return p
end
-------------------------------------------------------------------------------
function MPElectroDiskFX:Render()
    if not self._lockedEntity or self._lockedEntity == 0  then return end
    
    local x,y,z = ENTITY.GetWorldPosition(self._Entity)
    local ex,ey,ez = ENTITY.GetPosition(self._lockedEntity)
    if ENTITY.GetType(self._lockedEntity) ==  ETypes.Model then
        local idx = MDL.GetJointIndex(self._lockedEntity,"root")
        if idx > -1 then              
            ex,ey,ez = MDL.GetJointPos(self._lockedEntity,idx)  
        end
    end                            

    --Game:Print("S:"..x..", "..y..", "..z)
    --Game:Print("E:"..ex..", "..ey..", "..ez)
    
    local t = Templates["DriverElectro.CWeapon"]    
    
    local start = Vector:New(x,y,z)
    local pos1 = start:Copy()
    pos1:Interpolate(ex,ey,ez,FRand(0.3,0.7))
    local points = 
    {
        start,
        Vector:New(pos1.X + FRand(-1,1),pos1.Y + FRand(0.5,1.0),pos1.Z + FRand(-1,1)),
        Vector:New(ex,ey,ez),
    }
    t:DrawBezierLine(points,10,11,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))
    t:DrawBezierLine(points,10,12,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))
    
    local pos1 = start:Copy()
    pos1:Interpolate(ex,ey,ez,FRand(0.3,0.7))
    local points = 
    {
        start,
        Vector:New(pos1.X + FRand(-1,1),pos1.Y + FRand(0.5,1.0),pos1.Z + FRand(-1,1)),
        Vector:New(ex,ey,ez),
    }
    t:DrawBezierLine(points,10,11,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))
    t:DrawBezierLine(points,10,12,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))

    if math.random(0,10) == 5 then
        AddPFX("electro_hit_wall", 0.5 ,Vector:New(x,y,z))        
        AddPFX("electro_hit",0.8,Vector:New(ex,ey,ez))
    end        
    
    --local lv = start:Copy()
    --lv:Sub(ex,ey,ez)
    --lv:Normalize()    
    --ENTITY.SetPosition(self._light,ex+lv.X*0.5,ey+lv.Y*0.5+0.5,ez+lv.Z*0.5)    
    --LIGHT.Setup(self._light,2,R3D.RGBA(200,200,255,255),0,0,0,FRand(1,3))
    --LIGHT.SetFalloff(self._light,FRand(2,3),FRand(5,6))
end
-------------------------------------------------------------------------------
function ElectroDisk:Client_OnCreateEntity(entity)
    BindSoundToEntity(entity,"Weapons/DriverElectro/shuricane-onfly-loop",3,18,true,nil,nil,nil,nil,0.1)   
    BindTrailToEntity(entity,"trail_shuriken",-1,0,0,0)
    BindFX(entity,"electrodisk",0.8,-1,0,0,0,0.35,0.35,0.35)    
    
    if Game.GMode == GModes.MultiplayerClient then
        -- tworze proces z efektem na kliencie
        local proc = MPElectroDiskFX:New(entity)
        GObjects:Add(TempObjName(),proc)
        EntityToObject[entity] = proc
    end
end

-------------------------------------------------------------------------------
function ElectroDisk:Client_OnDeleteEntity(e)
    if Game.GMode == GModes.MultiplayerClient then
        local process = EntityToObject[e]
        -- zabijam proces z efektem na kliencie
        if process then
            GObjects:ToKill(process)
        end
    end
end
-------------------------------------------------------------------------------
function ElectroDisk:Client_ChangeEnemyFX(e,le)   
    local process = EntityToObject[e]
    if process then
        process._lockedEntity = le
    end
end
Network:RegisterMethod("ElectroDisk.Client_ChangeEnemyFX", NCallOn.AllClients, NMode.Unreliable, "ee") 
-------------------------------------------------------------------------------
function ElectroDisk:FindAndDamageEnemy(x,y,z,avoid)
    local enemy = nil
    local enemies = {}
    if Game.GMode == GModes.SingleGame then
        for i,o in Actors do
            if o ~= avoid and o._AIBrain and o.Health > 0 and o.OnDamage and o.Pos:Dist(x,y,z) < 5 then
                table.insert(enemies,o)
            end
        end
    else
        for i,o in Game.Players do
            if o ~= self.ObjOwner and not o._died and o.Health > 0 and o.OnDamage and o.Pos:Dist(x,y,z) < 5 then
                table.insert(enemies,o)
            end
        end
    end
    local n = table.getn(enemies)
    if n > 0 then
        enemy = enemies[math.random(1,n)]
        local ex,ey,ez = enemy:GetJointPos("root")
        enemy:OnDamage(5,self.ObjOwner,AttackTypes.Electro,ex,ey,ez)        
        if math.random(0,4) == 2 then
            AddPFX("electro_hit_wall", 0.5 ,Vector:New(x,y,z))        
            AddPFX("electro_hit",0.8,Vector:New(ex,ey,ez))
        end        
    end
    
    if enemy ~= self._lastEnemy then
        local e = 0
        if enemy then e = enemy._Entity end
        local tml = Templates["ElectroDisk.CItem"]
        tml.Client_ChangeEnemyFX(self._Entity, e)
        self._lastEnemy =  enemy
    end

    return enemy
end
-------------------------------------------------------------------------------
function ElectroDisk:Update()
    --Game:Print(self.Timeout)
    local x,y,z = ENTITY.GetWorldPosition(self._Entity)
    self.Timeout = self.Timeout - 1
    if self.Timeout <= 0 then
        ENTITY.PO_Enable(self._Entity, false)
        Explosion(x,y,z,self.ExplosionStrength,self.ExplosionRange,self.ObjOwner.ClientID,AttackTypes.Shuriken,self.ExplosionDamage)    
        GObjects:ToKill(self)
        self.HitFX(x,y,z,0)    
    end
    
    self._Enemy = self:FindAndDamageEnemy(x,y,z)
    
    if self._Enemy then
        if not self._light then
            self._light = CreateLight(0,0,0,255,255,255,2,5,1)
        end
    else
        ENTITY.Release(self._light)   
        self._light = nil
    end

end
-------------------------------------------------------------------------------
function ElectroDisk:Tick(delta)
    local x,y,z = ENTITY.GetWorldPosition(self._Entity)
    if self._pinned then return end
    local vx,vy,vz,vl = ENTITY.GetVelocity(self._Entity)    
    
    ENTITY.RemoveFromIntersectionSolver(self.ObjOwner._Entity)
    ENTITY.RemoveFromIntersectionSolver(self._Entity)    
    local b,d,lx,ly,lz,nx,ny,nz,he,e = WORLD.LineTrace(self._lPos.X,self._lPos.Y,self._lPos.Z,x,y,z)            
    --Game:Print(self._lPos.X..","..self._lPos.Y..","..self._lPos.Z..","..x..","..y..","..z)
    ENTITY.AddToIntersectionSolver(self.ObjOwner._Entity)
    ENTITY.AddToIntersectionSolver(self._Entity)
        
    self._lPos:Set(x,y,z)

    if b then 
        if Game.GMode == GModes.SingleGame and ENTITY.IsWater(e) then 
            self:InDeathZone(lx,ly,lz,"wat")
        else
            local cg = ENTITY.PO_GetCollisionGroup(e)
            if not CheckStartGlass(he,lx,ly,lz,0.3,vx,vy,vz) and cg~=7 and cg~=8 then
                self:OnCollision(lx,ly,lz,nx,ny,nz,e,he)
                --Game:Print(lx.." "..ly.." "..lz)
            end
        end
    end    
end
-------------------------------------------------------------------------------
function ElectroDisk:OnCollision(x,y,z,nx,ny,nz,e,he)
    if self._pinned then return end
    
    local etype = 1
    local vx,vy,vz,l  = ENTITY.GetVelocity(self._Entity)
    local dx,dy,dz  = vx/l, vy/l, vz/l
    
    self._pinned = true
    self.Timeout = self.ElectroDiskPinnedLifeTime * 30
    -- release FX
    ENTITY.UnregisterAllChildren(self._Entity,ETypes.Trail) 
    ENTITY.KillAllChildren(self._Entity,ETypes.Sound)
    ENTITY.PO_Remove(self._Entity)
    -- bind
    ENTITY.SetPosition(self._Entity,x-dx*0.2,y-dy*0.2,z-dz*0.2)
    --Game:Print(x.." "..y.." "..z)
    local joint = MDL.GetJointFromHavokBody(e,he)
    ENTITY.ComputeChildMatrix(self._Entity,e,joint)
    ENTITY.RegisterChild(e,self._Entity,true,joint) 
    -- hit PO
    WORLD.HitPhysicObject(he,x,y,z,dx*300,dy*300,dz*300)
    -- fx
    self.HitFX(x,y,z,etype)
end
--============================================================================
function ElectroDisk:Render()
    if self._Enemy then 
        local x,y,z = ENTITY.GetWorldPosition(self._Entity)
        self:RenderFX(x,y,z,self._Enemy)        
    end    
end
--============================================================================
function ElectroDisk:RenderFX(x,y,z,enemy)
    local t = Templates["DriverElectro.CWeapon"]
    local start = Vector:New(x,y,z)
    local ex,ey,ez
    if enemy._Class == "VectorA" then
        ex,ey,ez = enemy.X, enemy.Y, enemy.Z
    else
        ex,ey,ez = enemy:GetJointPos("root")
    end
    local pos1 = start:Copy()
    pos1:Interpolate(ex,ey,ez,FRand(0.3,0.7))
    local points = 
    {
        start,
        Vector:New(pos1.X + FRand(-1,1),pos1.Y + FRand(0.5,1.0),pos1.Z + FRand(-1,1)),
        Vector:New(ex,ey,ez),
    }
    t:DrawBezierLine(points,10,11,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))
    t:DrawBezierLine(points,10,12,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))
    
    local pos1 = start:Copy()
    pos1:Interpolate(ex,ey,ez,FRand(0.3,0.7))
    local points = 
    {
        start,
        Vector:New(pos1.X + FRand(-1,1),pos1.Y + FRand(0.5,1.0),pos1.Z + FRand(-1,1)),
        Vector:New(ex,ey,ez),
    }
    t:DrawBezierLine(points,10,11,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))
    t:DrawBezierLine(points,10,12,FRand(0.1,0.2),R3D.RGB(FRand(65,90),FRand(75,115),FRand(200,250)))
    
    local lv = start:Copy()
    lv:Sub(ex,ey,ez)
    lv:Normalize()
    ENTITY.SetPosition(self._light,ex+lv.X*0.5,ey+lv.Y*0.5+0.5,ez+lv.Z*0.5)    
    LIGHT.Setup(self._light,2,R3D.RGBA(200,200,255,255),0,0,0,FRand(1,3))
    LIGHT.SetFalloff(self._light,FRand(2,3),FRand(5,6))
end
--============================================================================
function ElectroDisk:HitFX(x,y,z,etype)
    if etype == 0 then
        AddPFX("explo_electrodisk", 0.4 ,Vector:New(x,y,z))
        local t = Templates["DriverElectro.CWeapon"]
        t:Snd3D("electrodisk_explosion",x,y,z)        
        return
    end
    if etype == 1 then
        AddPFX("spark_shuriken", 0.2 ,Vector:New(x,y,z))
        SOUND.Play3D("impacts/electrodisk-default",x,y,z,20,50)
    else
        AddPFX("spark_shuriken", 0.2 ,Vector:New(x,y,z))
        SOUND.Play3D("impacts/electrodisk-body",x,y,z,20,50)
    end
end
Network:RegisterMethod("ElectroDisk.HitFX", NCallOn.AllClients, NMode.Unreliable, "fffb") 
-------------------------------------------------------------------------------
