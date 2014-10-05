-------------------------------------------------------------------------------
function Grenade:OnCreateEntity()
    ENTITY.EnableNetworkSynchronization(self._Entity,true,false,2)
    ENTITY.SetSynchroString(self._Entity,"Grenade.CItem")
    if Game.GMode == GModes.SingleGame then
        self:PO_Create(BodyTypes.Sphere,0.15,ECollisionGroups.Missile)    
    else
        self:PO_Create(BodyTypes.Sphere,0.05,ECollisionGroups.Missile)    
    end
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)    
    ENTITY.RemoveFromIntersectionSolver(self._Entity) 
    self:Client_OnCreateEntity(self._Entity)

    ENTITY.EnableCollisions(self._Entity,true,0.3,0)
    ENTITY.PO_SetGrenade(self._Entity)    
    ENTITY.PO_SetMissile(self._Entity, MPProjectileTypes.Grenade )
end
--============================================================================
function Grenade:Client_OnCreateEntity(entity)
    
    if not Cfg.NoSmoke then
    local x,y,z = ENTITY.GetPosition(entity)
    local smokefx = AddPFX("GrenadeSmoke",1,Vector:New(x,y,z))
    ENTITY.RegisterChild(entity,smokefx)
    PARTICLE.SetParentOffset(smokefx,0,-0.15,0)
    end

    local e = ENTITY.Create(ETypes.Trail,"trail_grenade","trailName")
    ENTITY.SetPosition(e,0,-0.15,0)
    ENTITY.AttachTrailToBones(entity,e)
    WORLD.AddEntity(e)
end
--============================================================================
function Grenade:Client_OnCreatePO(entity,po)
    ENTITY.EnableCollisions(entity,true,0.3,0.3)
    ENTITY.PO_SetGrenade(entity)
    ENTITY.PO_SetCollisionGroup(entity, ECollisionGroups.ClientGrenade)
end
--============================================================================
function Grenade:OnPrecache()
	Cache:PrecacheParticleFX("Grenade")
    Cache:PrecacheParticleFX("molotowexplo")
	Cache:PrecacheParticleFX("GrenadeSmoke")
	Cache:PrecacheItem("KamykWybuch.CItem")     
    Cache:PrecacheTrail("trail_grenade")
    Cache:PrecacheItem("GrenadeGas.CItem")
end
--============================================================================
function Grenade:Client_OnCollision(x,y,z)
    PlaySound3D('weapons/grenadelauncher/weapon_grenade_bounce',x,y,z,15,20)
end             
--============================================================================
function Grenade:Update()
    self.Timeout = self.Timeout - 1
    if self.Timeout <= 0 then self:Explode() end
end
--============================================================================
function Grenade:Explode()    
    local x,y,z = ENTITY.GetPosition(self._Entity)   
    ENTITY.EnableCollisions(self._Entity,false) -- disable next callbacks        
    ENTITY.RemoveFromIntersectionSolver(self._Entity)
    ENTITY.PO_Enable(self._Entity, false)	-- bo inaczej by zglaszal msg 'explosion' z soba samym
    Explosion(x,y,z,self.ExplosionStrength,self.ExplosionRange,self.ObjOwner.ClientID,AttackTypes.Grenade,self.Damage)
    self.Client_Explosion(self._Entity,x,y,z)    
    GObjects:ToKill(self)
    
    if self.ObjOwner.HasWeaponModifier then
        self.CL_GasFX(x,y,z)
    end
end
--============================================================================
function Grenade:CL_GasFX(x,y,z)    
    PlaySound3D("impacts/grenade-wm-explode",x,y,z,20,50)
    if not Cfg.NoExplosions then AddPFX("molotowexplo",0.3, Vector:New(x,y,z)) end
    
    local s = Templates["StakeGunGL.CWeapon"]:GetSubClass()
    
    for i=1, s.GrenadeWMGasAmount do
        local obj = GObjects:Add(TempObjName(),CloneTemplate("GrenadeGas.CItem"))
        obj.Pos.X = x + 0 * 0.5 + FRand(-0.5, 0.5)
        obj.Pos.Y = y + 1 * 0.5 + i * 0.05
        obj.Pos.Z = z + 0 * 0.5 + FRand(-0.5, 0.5)     
        obj.HPDrainDistance = s.GrenadeWMGasRange
        obj.HPDrain         = s.GrenadeWMGasDamage        
        
        if Game.GMode == GModes.MultiplayerClient then obj.HPDrain = 0 end
        
        obj.TimeToLive      = s.GrenadeWMGasLifeTime * 30
        
        if i == amount then
            obj.TimeToLive = obj.TimeToLive * 1.2
            obj.sound = "impacts/barrel-wood-fire-loop"
        else
            obj.sound = nil
            obj.TimeToLive = FRand(obj.TimeToLive * 0.8, obj.TimeToLive * 1.2)			
        end
        obj:Apply()
        obj:Synchronize()
    end
end
Network:RegisterMethod("Grenade.CL_GasFX", NCallOn.ServerAndAllClients, NMode.Reliable, "ffffff")
--============================================================================
function Grenade:OnCollision(x,y,z,nx,ny,nz,e)
        
    if Game.GMode == GModes.MultiplayerClient then return end
    
    if Game.GMode == GModes.SingleGame and ENTITY.IsWater(e) then 
		self:InDeathZone(x,y,z,"wat")
		return
    end
    
    local obj = EntityToObject[e]
    --if obj and obj._Class == "CActor" then
    if obj and (self._collided or obj._Name ~= self.ObjOwner._Name) then
        if obj and not obj._ToKill --[[and not obj._died--]] and obj.OnDamage then 
            --Game:Print("*** INSTANT_DAMAGE: "..obj._Name.." ["..self.Damage.."]")
            obj:OnDamage(self.Damage,self.ObjOwner,AttackTypes.Grenade)
            obj._GotInstantExplosion = Game.Counter
        end
        self:Explode()    
    else
        self:Client_OnCollision(x,y,z)
        self._collided = true
    end    
end
-------------------------------------------------------------------------------
function Grenade:Client_Explosion(entity,x,y,z)

    ENTITY.EnableDraw(entity,false) 
    
    --local x,y,z = ENTITY.GetPosition(entity)
    ENTITY.PO_Enable(entity,false)
    --Game:Print("Explosion: "..s..", "..i..", "..f)
    
    -- special FX
    SOUND.Play3D("weapon_grenade_explosion",x,y,z,30,200)
    if not Cfg.NoExplosions then AddPFX("Grenade",0.4,Vector:New(x,y,z)) end           
    
    if Game.GMode == GModes.SingleGame then 
        -- physical parts
        local n = math.random(4,6) -- how many (min,max)
        for i = 1, n do
            local ke = AddItem("KamykWybuch.CItem",0.6,Vector:New(x,y+0.5+i/10,z),
				false,Quaternion:New_FromEuler(FRand(0,3.14), FRand(0,3.14), FRand(0,3.14)))
            local vx = FRand(-27,37) -- velocity x
            local vy = FRand(22,34)  -- velocity y
            local vz = FRand(-27,37) -- velocity z
            ENTITY.SetVelocity(ke,vx,vy,vz)
            ENTITY.SetTimeToDie(ke,FRand(1,2)) -- lifetime (min,max)
        end
    end
    
    -- light
    AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y+1.5,z)
    if Game._EarthQuakeProc then
        local g = Templates["Grenade.CItem"]
        Game._EarthQuakeProc:Add(x,y,z, 5, g.ExplosionCamDistance, g.ExplosionCamMove, g.ExplosionCamRotate, false)
    end
end
-------------------------------------------------------------------------------
Network:RegisterMethod("Grenade.Client_Explosion", NCallOn.AllClients, NMode.Reliable, "efff")
-------------------------------------------------------------------------------
