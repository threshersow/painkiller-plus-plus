--============================================================================
-- ParticleFX class
--============================================================================
CParticleFX =
{
    Pos = Vector:New(0,0,0),
    Rot = Quaternion:New(),
    Scale = 1.0,
    Effect = "Default",
    _Class = "CParticleFX",
    _Entity = 0,
}
Inherit(CParticleFX,CObject)
--============================================================================
function CParticleFX:OnClone(old)
    if old == CParticleFX then 
        self.Pos = OppositeToCamera() 
    else
        self.Pos.X = old.Pos.X - 0.5
        self.Pos.Z = old.Pos.Z - 0.5
    end
    self._Entity = 0
end
--============================================================================
function CParticleFX:Delete()	
    ENTITY.Release(self._Entity)
    self._Entity = nil
end
--============================================================================
function CParticleFX:LoadData()
    ENTITY.Release(self._Entity)
    self._Entity = ENTITY.Create(ETypes.ParticleFX,"",self._Name..":Script") -- tu nie moge podac name bo bedzie ladowal
    LoadParticleFX(self._Entity,self.Effect)    
	WORLD.AddEntity(self._Entity)
    PARTICLE.SetEvolve(self._Entity,true) -- only evolve in level
end
--============================================================================
function CParticleFX:Apply(old)
    if not old or (old and old.Effect ~= self.Effect) then 
        self:LoadData()         
    end    
    ENTITY.SetScale(self._Entity,self.Scale)      
    PARTICLE.SetEvolve(self._Entity,true) -- protection for master emitter update
    ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
    self.Rot:ToEntity(self._Entity)
    ENTITY.EnableDraw(self._Entity,self.Visible) 
end
--============================================================================
--function CParticleFX:Synchronize()
    -- synchronization with  C++ object
--    ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
--    self.Rot:ToEntity(self._Entity)
--    PARTICLE.SetEvolve(self._Entity,true) -- protection for master emitter update
--end 
--============================================================================
ParticleFXArray = {
    
}
--============================================================================
function LoadParticleFX(entity,name)   

    if(IsBlockedPFX(name)) then name = "EvilMonkEye" end

    local fx = nil
    ParticleFX = nil
    if not ParticleFXArray[name] then 
        Game:Print("PFX: "..name)
        DoFile("../Data/Scripts/Effects/"..name..".pfx",false)    
        ParticleFXArray[name] = ParticleFX
        fx = ParticleFX
        ParticleFX = nil
    else
        fx = ParticleFXArray[name]        
    end
    
    if not fx then return end

    if fx.FixedTransform then
    	PARTICLE.SetFixedTransform(entity, fx.FixedTransform)
    end
    
    for id,v in fx.Emitters do
        local i = PARTICLE.AddEmitter(entity,v.File)
        PARTICLE.SetupEmitter(entity,i,v.Scale,
            v.Position[1],v.Position[2],v.Position[3],
            v.Rotation[1],v.Rotation[2],v.Rotation[3])        
    end
    
end
--============================================================================
function AddParticleFX(x,y,z,name) 
    if true then return end
    local e = ENTITY.Create(ETypes.ParticleFX,ParticlesFX[name][2],name)  
    ENTITY.SetScale(e,ParticlesFX[name][1])      
    ENTITY.SetPosition(e,x,y,z)  
	WORLD.AddEntity(e)
    return e
end 
--============================================================================
function AddPFX(effect,scale,pos,rot) 

    if(IsBlockedPFX(effect)) then effect = "EvilMonkEye" end
   			
    local e = ENTITY.Create(ETypes.ParticleFX,"",effect)
    LoadParticleFX(e,effect)    
    if pos then ENTITY.SetPosition(e,pos.X,pos.Y,pos.Z) end
    if rot then rot:ToEntity(e) end
    if scale then ENTITY.SetScale(e,scale) end
	WORLD.AddEntity(e)
    return e
end
--============================================================================
function IsBlockedPFX(effect)

	--if true then return false end

    --if(effect == "BodyBlood" and Cfg.NoBlood) then return true end
    --if(effect == "FX_gib_blood" and Cfg.NoBlood) then return true end
     
    --if(effect == "FX_rexplode1" and Cfg.NoExplosions) then return true end
    --if(effect == "FX_rexplodea" and Cfg.NoExplosions) then return true end
    --if(effect == "GrenadeSmoke" and Cfg.NoExplosions) then return true end
    --if(effect == "Grenade" and Cfg.NoExplosions) then return true end
    --if(effect == "stakeHitWall" and Cfg.NoExplosions) then return true end
    --if(effect == "molotowexplo" and Cfg.NoExplosions) then return true end
    
    --if(effect == "gibExplosion" and Cfg.NoGibs) then return true end
    --if(effect == "BodyExplosion" and Cfg.NoGibs) then return true end
   
    --if(effect == "but" and Cfg.NoSmoke) then return true end
    --if(effect == "butbig" and Cfg.NoSmoke) then return true end
    --if(effect == "butk" and Cfg.NoSmoke) then return true end
    --if(effect == "FX_shotgunmp" and Cfg.NoSmoke) then return true end
    --if(effect == "shotgunHitWall" and Cfg.NoSmoke) then return true end
    --if(effect == "shotgunHitWater" and Cfg.NoSmoke) then return true end
    --if(effect == "sgKamykFX" and Cfg.NoSmoke) then return true end
    --if(effect == "RocketSmoke" and Cfg.NoSmoke) then return true end
    if(effect == "dymm" and Cfg.NoSmoke) then return true end
    if(effect == "acidsmoke" and Cfg.NoSmoke) then return true end
     
    --if(effect == "spawn_effect" and Cfg.NoSpawnEffects) then return true end
    --if(effect == "spawn_smoke" and Cfg.NoSpawnEffects) then return true end
    
    --if(effect == "stakeflame" and Cfg.NoFlames) then return true end
    --if(effect == "RFT_smallflame" and Cfg.NoFlames) then return true end
    --if(effect == "RFT_flame" and Cfg.NoFlames) then return true end
    --if(effect == "RFT_flameWarp" and Cfg.NoFlames) then return true end
    --if(effect == "barrel_flame_FX" and Cfg.NoFlames) then return true end
    if(effect == "demonflame" and Cfg.NoFlames) then return true end
    if(effect == "Pochodnia_flame" and Cfg.NoFlames) then return true end
    if(effect == "Pochodnia_flame_re" and Cfg.NoFlames) then return true end
  
    return false
end