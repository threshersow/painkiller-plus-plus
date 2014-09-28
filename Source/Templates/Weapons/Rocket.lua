-------------------------------------------------------------------------------
function Rocket:OnCreateEntity()
    ENTITY.EnableNetworkSynchronization(self._Entity,true,false,2)
    ENTITY.SetSynchroString(self._Entity,"Rocket.CItem")
    --if Game.GMode == GModes.SingleGame then 
    --    self:PO_Create(BodyTypes.SphereSweep,0.001,ECollisionGroups.Missile)    
    --else
        self:PO_Create(BodyTypes.Sphere,0.001,ECollisionGroups.Particles)    
    --end    
    ENTITY.EnableCollisions(self._Entity,true,0,0)
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    ENTITY.RemoveFromIntersectionSolver(self._Entity) 
    ENTITY.PO_EnableGravity(self._Entity,false)
    self._time = 0
    self._lPos = Vector:New(self.Pos)
    self._StartPos = Vector:New(self.Pos)
    ENTITY.PO_SetMissile(self._Entity)
    self:Client_OnCreateEntity(self._Entity)
end
--============================================================================
function Rocket:Client_OnCreateEntity(entity)
    if Game.GMode == GModes.SingleGame then     
        local smokefx = AddPFX("RocketSmoke",2)
        ENTITY.RegisterChild(entity,smokefx)
    end
    
    local e = ENTITY.Create(ETypes.Trail,"trail_grenade","trailName")
    ENTITY.AttachTrailToBones(entity,e)
    WORLD.AddEntity(e)    
    BindSoundToEntity(entity,"weapons/machinegun/rl-flyingnoise-loop",3,18,true,nil,nil,nil,nil,0.3,0.4)     
end
--============================================================================
function Rocket:Client_OnCreatePO(entity,po)
    if Game.GMode == GModes.MultiplayerClient then 
        ENTITY.PO_SetCollisionGroup(entity, ECollisionGroups.Noncolliding)			
    end
end
--============================================================================
function Rocket:OnPrecache()
	Cache:PrecacheActor("FX_rexplode.CActor")
	Cache:PrecacheParticleFX("RocketSmoke")
	Cache:PrecacheItem("KamykWybuchRakieta.CItem")     
	Cache:PrecacheDecal("rockethole")         
    Cache:PrecacheTrail("trail_grenade")        
end
-------------------------------------------------------------------------------
function Rocket:Update()
    self.Timeout = self.Timeout - 1
    if self.Timeout <= 0 then   
        self:OnCollision(self.Pos.X,self.Pos.Y,self.Pos.Z,0,-1,0)
    end
end
-------------------------------------------------------------------------------
function Rocket:Tick(delta)    
    
    self._time = self._time + delta    
    
    local x,y,z = ENTITY.GetPosition(self._Entity)
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
                self:OnCollision(lx,ly,lz,nx,ny,nz,e)
            end
        end
    end    

end
-------------------------------------------------------------------------------
function Rocket:OnCollision(x,y,z,nx,ny,nz,e,h_me,h_other,vx,vy,vz,vl)
    --MsgBox("Rocket:OnCollision:"..x.." "..y.." "..z)   
    if not vx then
        vx,vy,vz = ENTITY.GetVelocity(self._Entity)
    end

    -- negate normal if wrong
    if vx*nx+vy*ny+vz*nz > 0 then
        nx = -nx
        ny = -ny
        nz = -nz
    end
    
    if Game.GMode == GModes.SingleGame and ENTITY.IsWater(e) then 
		self:InDeathZone(x,y,z,"wat")
		return
	end

    local obj = EntityToObject[e]

    -- PEOPLE CAN FLY MODE
    local factorY = 1
    if MPCfg.GameMode == "People Can Fly" then
	self.ExplosionRange = 4.5
        self.ExplosionStrength = self.ExplosionStrength * 0.5
        factorY = 5
        local d = self._StartPos:Dist(x,y,z)
        self.Damage = self.Damage * d * d / 33
        if obj and obj._Class == "CPlayer" then 
            obj._score = 1
            if d  > 6 then obj._score = 2 end
            if d  > 16 then obj._score = 3 end
            if d  > 23 then obj._score = 5 end
            if d  > 30 then obj._score = 10 end
        end        
    end
    -- PEOPLE CAN FLY MODE
    
    if self.ObjOwner.HasQuad then
        self.ExplosionStrength = self.ExplosionStrength * 1.2
    end
	
    -- instant damage
    local obj = EntityToObject[e]
    if obj and not obj._ToKill --[[and not obj._died--]] and obj.OnDamage then 
        --Game:Print("*** INSTANT_DAMAGE: "..obj._Name.." ["..self.Damage.."]")
        obj:OnDamage(self.Damage,self.ObjOwner,AttackTypes.Rocket,x,y,z)                                    
        if obj.bulletsFliesThru then
			--Game:Print("fly through")
            return
        end
        obj._GotInstantExplosion = Game.Counter
    end

    ENTITY.EnableCollisions(self._Entity,false) -- disable next callbacks    
    ENTITY.RemoveFromIntersectionSolver(self._Entity)
    ENTITY.PO_Enable(self._Entity, false)

    if(Cfg.RocketFix or MPCfg.RocketFix)then --MPCfg.ProPlus or 
    	local resultfactor = 1 + ((math.abs(vy) / 40) * 0.23 ) --Cfg.RocketFactor
    	self.ExplosionStrength = 3150 --Cfg.RocketExplosionStrength
    	resultfactor = math.pow(resultfactor,5.2) --Cfg.RocketFactorOrder
    	if(Cfg.RocketLogging)then
		local file = io.open ("rocketinclines.log","a")
		file:write( tostring((math.abs(vy) / 40))..'\n' )
		io.close(file)
	end
    	if MPCfg.GameMode == "People Can Fly" then
		self.ExplosionRange = 4.5
	        self.ExplosionStrength = 3150 * 0.5 --Cfg.RocketExplosionStrength
	        Explosion(x,y,z,self.ExplosionStrength/resultfactor,self.ExplosionRange,self.ObjOwner.ClientID,AttackTypes.Rocket,self.Damage,resultfactor*5)
        else
    		Explosion(x,y,z,self.ExplosionStrength/resultfactor,self.ExplosionRange,self.ObjOwner.ClientID,AttackTypes.Rocket,self.Damage,resultfactor)
   	end
    else
    	if MPCfg.GameMode == "People Can Fly" then
		self.ExplosionRange = 4.5
	        self.ExplosionStrength = self.ExplosionStrength * 0.5
	        factorY = 5
        end
    	Explosion(x,y,z,self.ExplosionStrength,self.ExplosionRange,self.ObjOwner.ClientID,AttackTypes.Rocket,self.Damage,factorY)
    end
    
    self.ExplosionFX(self._Entity,x,y,z,nx,ny,nz)
    GObjects:ToKill(self)
end
-------------------------------------------------------------------------------
function Rocket:ExplosionFX(entity,x,y,z,nx,ny,nz)

    --Log("Rocket.ExplosionFX START\n")
    ENTITY.EnableDraw(entity,false) 
    --local x,y,z = ENTITY.GetPosition(entity)   
    local vx,vy,vz = ENTITY.GetVelocity(entity)    

    --Log("Rocket.ExplosionFX 2\n")
    local b,d,dx,dy,dz,dnx,dny,dnz,he,e = WORLD.LineTrace(x,y,z,x-nx,y-ny,z-nz)        
    --Log("Rocket.ExplosionFX 2.5\n")
    if b and e and not EntityToObject[e] then ENTITY.SpawnDecal(e,'rockethole',dx,dy,dz,dnx,dny,dnz) end
    
    -- sound
    --Log("Rocket.ExplosionFX 3\n")
    SOUND.Play3D("weapons/machinegun/rocket_hit",x,y,z,30,200)
    
    --Log("Rocket.ExplosionFX 4\n")
    local r = Quaternion:New_FromNormal(nx,ny,nz)
    --AddPFX("Grenade",0.4,Vector:New(x,y,z),r)                
    if MPCfg.GameMode == "People Can Fly" then
        if not Cfg.NoExplosions then AddObject("FX_rexplodePCF.CActor",1,Vector:New(x,y,z),r,true) end
    else    
        if not Cfg.NoExplosions then AddObject("FX_rexplode.CActor",1,Vector:New(x,y,z),r,true) end 
    end
    
    --Log("Rocket.ExplosionFX 5\n")
    -- physical parts
    if Game.GMode == GModes.SingleGame then 
        local px,py,pz = x+nx/2,y+ny/2,z+nz/2
        local n = math.random(4,6) -- how many (min,max)
        for i = 1, n do
            local ke = AddItem("KamykWybuchRakieta.CItem",0.6,Vector:New(px+FRand(-0.2,0.2),py+FRand(-0.2,0.2),pz+FRand(-0.2,0.2)),
                false,Quaternion:New_FromEuler(FRand(0,3.14), FRand(0,3.14), FRand(0,3.14)))
            vx,vy,vz  = r:TransformVector(FRand(-30,30),FRand(22,34),FRand(-30,30))
            ENTITY.SetVelocity(ke,vx,vy,vz)
            ENTITY.SetTimeToDie(ke,FRand(1,2)) -- lifetime (min,max)
            --ENTITY.PO_SetPinned(ke,true)
        end
    end
    
    -- light
    local lx,ly,lz = x+nx*2,y+ny*2,z+nz*2
    --Log("Rocket.ExplosionFX 6\n")
    
    --AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,lx,ly+1.5,lz)
    
    if Game._EarthQuakeProc then
        local g = Templates["Grenade.CItem"]
        Game._EarthQuakeProc:Add(x,y,z, 5, g.ExplosionCamDistance, g.ExplosionCamMove, g.ExplosionCamRotate, false)
    end
    --Log("Rocket.ExplosionFX - END\n")
end
Network:RegisterMethod("Rocket.ExplosionFX", NCallOn.AllClients, NMode.Reliable, "effffff") 
-------------------------------------------------------------------------------
