Cache = {}
CacheLog = false

function Cache:PrecacheParticleFX(fx)
  if Cached[fx] then
    return
  end
  Cached[fx] = true
  if CacheLog then
    Game:Print("CACHE PFX: " .. fx)
  end
  local e = ENTITY.Create(ETypes.ParticleFX, "cache", fx)
  LoadParticleFX(e, fx)
  ENTITY.Release(e)
end

function Cache:PrecacheDecal(decal)
  if Cached[decal] then
    return
  end
  Cached[decal] = true
  if CacheLog then
    Game:Print("CACHE DECAL: " .. decal)
  end
  local e = ENTITY.Create(ETypes.Decal, decal, "cache")
  ENTITY.Release(e)
end

function Cache:PrecacheTrail(trail)
  if Cached[trail] then
    return
  end
  Cached[trail] = true
  if CacheLog then
    Game:Print("CACHE TRAIL: " .. trail)
  end
  local e = ENTITY.Create(ETypes.Trail, trail, "cache")
  ENTITY.Release(e)
end

function Cache:PrecacheActor(objname, scale)
  local obj = FindObj(objname)
  if not obj then
    return
  end
  if not scale then
    scale = obj.Scale
  else
    scale = scale * obj.Scale
  end
  if not obj.Model then
    return
  end
  local hash = obj.Model .. scale
  if Cached[hash] then
    return
  end
  Cached[hash] = true
  if CacheLog then
    Game:Print("CACHE MDL: " .. hash)
  end
  local mdl = ENTITY.Create(ETypes.Model, obj.Model, "cache", scale * 0.1)
  local anims = FS.FindFiles("../Data/Models/" .. obj.Model .. ".*.ani", 1, 0)
  for i = 1, table.getn(anims) do
    local i1 = string.find(anims[i], ".", 1, true)
    local i2 = string.find(anims[i], ".", i1 + 1, true)
    if i2 then
      anims[i] = string.sub(anims[i], i1 + 1, i2 - 1)
      local loop = false
      if string.find(anims[i], "idle") or string.find(anims[i], "walk") or string.find(anims[i], "run") then
        loop = true
      end
      local anm = MDL.LoadAnim(mdl, anims[i], loop)
      if loop then
        if CacheLog then
          Game:Print("  " .. anims[i] .. ":" .. anm .. ":looped")
        end
      elseif CacheLog then
        Game:Print("  " .. anims[i] .. ":" .. anm .. ":normal")
      end
    end
  end
  if obj.deathExplosionItem then
    ENTITY.PO_Create(mdl, BodyTypes.Fatter, -1)
    ENTITY.ExplodeItem(mdl, "../Data/Items/" .. obj.deathExplosionItem, 0, 0, 0, obj.deathExplosionItemScale)
  end
  if obj.ReloadTextures then
    local o = Clone(obj)
    o._Entity = mdl
    o:ReloadTextures()
  end
  ENTITY.Release(mdl)
  if obj.enableGibWhenHPBelow then
    if CacheLog then
      Game:Print("CACHE GIB: " .. obj.Model .. "_gib")
    end
    local mdl = ENTITY.Create(ETypes.Model, obj.Model .. "_gib", "cache", scale * 0.1)
    ENTITY.Release(mdl)
  end
  if obj.AiParams and obj.AiParams.madonnaFX then
    self:PrecacheActor("Raven_EscapeAfterCreate.CActor")
  end
  if obj.AiParams and obj.AiParams.ThrowableItem and obj.AiParams.ThrowableItem ~= "" then
    self:PrecacheItem(obj.AiParams.ThrowableItem)
  end
  if obj.AiParams and obj.AiParams.NextThrowableItem and obj.AiParams.NextThrowableItem ~= "" then
    self:PrecacheItem(obj.AiParams.NextThrowableItem)
  end
  if obj.s_SubClass and obj.s_SubClass.ParticlesDefinitions then
    for i, o in obj.s_SubClass.ParticlesDefinitions, nil do
      if o.pfx then
        self:PrecacheParticleFX(o.pfx)
      end
    end
  end
  if obj.AiParams and obj.AiParams.weapon then
    if obj.AiParams.weapon.fireParticle then
      self:PrecacheParticleFX(obj.AiParams.weapon.fireParticle)
    end
    if obj.AiParams.weapon.bulletHitWallParticle then
      self:PrecacheParticleFX(obj.AiParams.weapon.bulletHitWallParticle)
    end
  end
  if obj.s_SubClass and obj.s_SubClass.bindFX then
    if type(obj.s_SubClass.bindFX[1]) == "table" then
      for i, o in obj.s_SubClass.bindFX, nil do
        self:PrecacheParticleFX(o[1])
      end
    else
      self:PrecacheParticleFX(obj.s_SubClass.bindFX[1])
    end
  end
  if obj.s_SubClass and obj.s_SubClass.Trails then
    for i, o in obj.s_SubClass.Trails, nil do
      self:PrecacheTrail(o.name)
    end
  end
  self:PrecacheSoundsDef(obj)
  if obj.OnPrecache then
    obj:OnPrecache()
  end
end

function Cache:PrecacheSpawnPoint(objname)
  local obj = FindObj(objname)
  if not obj then
    return
  end
  if string.find(obj.SpawnTemplate, ".CItem") then
    self:PrecacheItem(obj.SpawnTemplate)
  else
    self:PrecacheActor(obj.SpawnTemplate)
  end
  local temp = obj.SpawnFX and Templates[obj.SpawnFX]
end

function Cache:PrecacheItem(objname)
  local obj = Clone(FindObj(objname))
  if not obj then
    return
  end
  if obj.PreApply then
    obj:PreApply()
  end
  if obj.SlotIndex then
    self:PrecacheActor(CPlayer.EnabledWeapons[obj.SlotIndex] .. ".CWeapon")
  end
  if obj.Model and obj.Model ~= "" then
    self:PrecacheActor(objname)
    return
  end
  local hash = obj.Pack .. obj.Mesh .. obj.Scale
  if not Cached[hash] then
    Cached[hash] = true
    if CacheLog then
      Game:Print("CACHE MESH: " .. hash)
    end
    if fLog then
      local dpack = ""
      if obj.DestroyPack then
        dpack = obj.DestroyPack
      end
      fLog:write(obj.Pack .. "," .. obj.Mesh .. "," .. dpack .. "," .. obj.Scale .. "\n")
    end
    local item = ENTITY.Create(ETypes.Mesh, "../Data/Items/" .. obj.Pack, obj.Mesh, obj.Scale, not obj.DontTranslateToZero)
    if obj.s_SubClass and obj.s_SubClass.bindFX then
      if type(obj.s_SubClass.bindFX[1]) == "table" then
        for i, o in obj.s_SubClass.bindFX, nil do
          self:PrecacheParticleFX(o[1])
        end
      else
        self:PrecacheParticleFX(obj.s_SubClass.bindFX[1])
      end
    end
    if obj.DestroyPack then
      if CacheLog then
        Game:Print("CACHE DESTROY PACK: " .. obj.DestroyPack)
      end
      ENTITY.PO_Create(item, BodyTypes.FromMesh, obj.Scale, nil, true)
      ENTITY.ExplodeItem(item, "../Data/Items/" .. obj.DestroyPack, 0, 0, 0)
      if obj.Destroy.Effect then
        self:PrecacheParticleFX(obj.Destroy.Effect)
      end
      if obj.Destroy.CustomThrowItem then
        for i, o in obj.Destroy.CustomThrowItem, nil do
          self:PrecacheItem(o)
        end
      end
      if obj.Destroy.ThrowItem then
        for i, o in obj.Destroy.ThrowItem, nil do
          self:PrecacheItem(o)
        end
      end
    end
    ENTITY.Release(item)
  end
  if Templates[obj.BaseObj] then
    hash = hash .. obj.BaseObj
    if Cached[hash] and obj.OnPracache == Templates[obj.BaseObj].OnPracache then
      return
    end
    Cached[hash] = true
  end
  if obj.FX then
    local xx = {
      obj.FX
    }
    if type(obj.FX[1]) == "table" then
      xx = obj.FX
    end
    for i, v in xx, nil do
      self:PrecacheParticleFX(v[1])
    end
  end
  self:PrecacheSoundsDef(obj)
  if obj.SoundsImpact then
    self:PrecacheSounds(obj.SoundsImpact)
  end
  if obj.CollisionSound then
    self:PrecacheSounds(obj.CollisionSound)
  end
  if obj.LoopSound then
    self:PrecacheSounds(obj.LoopSound)
  end
  if obj.ThrowSound then
    self:PrecacheSounds(obj.ThrowSound)
  end
  if obj.OnPrecache then
    obj:OnPrecache()
  end
end

function Cache:PrecacheSounds(sounds, path)
  if not sounds then
    return
  end
  local pt = path
  local xx = {sounds}
  if type(sounds) == "table" then
    xx = sounds
  end
  for i, v in xx, nil do
    local s = v
    if string.find(s, "$/") then
      s = string.gsub(s, "$/", "")
      pt = nil
    end
    local snd
    snd = "../Data/Sounds/" .. s .. ".wav"
    if pt then
      snd = "../Data/Sounds/" .. pt .. "/" .. s .. ".wav"
    end
    snd = string.lower(snd)
    if Cached[snd] then
      return
    end
    Cached[snd] = true
    if CacheLog then
      Game:Print("CACHE SOUND: " .. snd)
    end
    SOUND.PreloadFile(snd)
  end
end

function Cache:PrecacheSoundsDef(obj)
  if obj.s_SubClass and obj.s_SubClass.SoundsDefinitions then
    for i, o in obj.s_SubClass.SoundsDefinitions, nil do
      if type(o) == "table" then
        local path
        if obj.s_SubClass.SoundsDefinitions.path then
          path = obj.s_SubClass.SoundsDefinitions.path
        end
        if o.path then
          path = o.path
        end
        if not path and obj._SoundDirectory then
          path = "actor/" .. obj.Model
          if obj.s_SubClass.SoundDir then
            path = "actor/" .. obj.s_SubClass.SoundDir
          end
        end
        self:PrecacheSounds(o.samples, path)
      end
    end
  end
end

function Cache:PrecacheMPModel(model)
  local mdl = ENTITY.Create(ETypes.Model, model, "cache", 0.155)
  ENTITY.Release(mdl)
  local mdl = ENTITY.Create(ETypes.Model, model .. "_gib", "cache", 0.155)
  ENTITY.Release(mdl)
end

function Cache:PrecacheLevel(name)
  if CacheLog then
    fLog = io.open("cache.log", "w")
  end
  Cached = {}
  local overall = PMENU.GetLoadingScreenOverall() + table.getn(GObjects.Elements) + 8
  if Game.PlayerEnabledWeapons then
    overall = overall + table.getn(Game.PlayerEnabledWeapons)
  end
  PMENU.SetLoadingScreenOverall(overall, 20)
  for i, o in GObjects.Elements, nil do
    if o._Class == "CActor" then
      self:PrecacheActor(o._Name)
    end
    if o._Class == "CSpawnPoint" then
      self:PrecacheSpawnPoint(o._Name)
    end
    if o._Class == "CItem" then
      self:PrecacheItem(o._Name)
    end
    if o._Class == "CParticleFX" then
      self:PrecacheParticleFX(o.Effect)
    end
    if o._Class == "CSound" then
      self:PrecacheSounds(Text2Tab(o.Sound, ";")[1])
    end
    PMENU.LoadingProgress()
  end
  if Lev.OnPrecache then
    Lev:OnPrecache()
  end
  self:PrecacheActor("PainKiller.CWeapon")
  if Game.GMode ~= GModes.SingleGame then
    self:PrecacheActor("Shotgun.CWeapon")
    self:PrecacheActor("StakeGunGL.CWeapon")
    self:PrecacheActor("MiniGunRL.CWeapon")
    self:PrecacheActor("DriverElectro.CWeapon")
    self:PrecacheActor("RifleFlameThrower.CWeapon")
    self:PrecacheActor("BoltGunHeater.CWeapon")
    if MPCfg.GameMode ~= "" then
      Game:BrightSkin(entity, true)
    end
    self:PrecacheMPModel("mp-model-demon")
    self:PrecacheMPModel("mp-model-fallenangel")
    self:PrecacheMPModel("mp-model-knight")
    self:PrecacheMPModel("mp-model-beast")
    if not IsMPDemo() then
      self:PrecacheMPModel("mp-model-painkiller")
    end
    self:PrecacheMPModel("mp-model-player6")
    self:PrecacheMPModel("mp-model-player7")
    self:PrecacheActor("FX_ItemRespawn.CActor")
    self:PrecacheItem("SoulMP.CItem")
  end
  self:PrecacheSoundsDef(CPlayer)
  PMENU.LoadingProgress()
  if Game.PlayerEnabledWeapons then
    for i, o in Game.PlayerEnabledWeapons, nil do
      self:PrecacheActor(o .. ".CWeapon")
    end
  end
  MATERIAL.Create("items/1")
  MATERIAL.Create("items/2")
  MATERIAL.Create("items/3")
  MATERIAL.Create("special/flashlight")
  MATERIAL.Create("special/warp_dudv", 4)
  self:PrecacheDecal("shadow")
  self:PrecacheTrail("trail_sword")
  self:PrecacheItem("CoinG.CItem")
  self:PrecacheItem("CoinS.CItem")
  PMENU.LoadingProgress()
  self:PrecacheItem("RingB.CItem")
  self:PrecacheItem("RingR.CItem")
  self:PrecacheItem("StoneB.CItem")
  self:PrecacheItem("StoneG.CItem")
  self:PrecacheItem("StoneR.CItem")
  PMENU.LoadingProgress()
  self:PrecacheItem("Energy.CItem")
  self:PrecacheItem("Blood.CItem")
  self:PrecacheActor("FX_Spawn.CActor")
  self:PrecacheActor("FX_sground.CActor")
  PMENU.LoadingProgress()
  self:PrecacheActor("FX_splash.CActor")
  self:PrecacheActor("FX_splash.CActor", 1.5)
  self:PrecacheDecal("bloodLeak")
  PMENU.LoadingProgress()
  self:PrecacheParticleFX("gibExplosion")
  self:PrecacheParticleFX("FX_gib_blood")
  self:PrecacheParticleFX("but")
  self:PrecacheParticleFX("butk")
  self:PrecacheParticleFX("butbig")
  self:PrecacheParticleFX("demonflame")
  self:PrecacheParticleFX("BodyBlood")
  self:PrecacheParticleFX("BodyExplosion")
  self:PrecacheParticleFX("elektrodeath")
  self:PrecacheParticleFX("RifleHitWall")
  self:PrecacheParticleFX("FX_BrokenGlass")
  self:PrecacheParticleFX("barrel_flame_FX")
  self:PrecacheParticleFX("barrel_part_FX")
  self:PrecacheParticleFX("energy")
  PMENU.LoadingProgress()
  self:PrecacheSounds({
    "misc/weapon-hide",
    "misc/weapon-show"
  })
  self:PrecacheSounds({
    "specials/respawns/respawn_m1",
    "specials/respawns/respawn_m2",
    "specials/respawns/respawn_m3",
    "specials/respawns/respawn_m4",
    "specials/respawns/respawn_m5",
    "specials/respawns/respawn_m6"
  })
  self:PrecacheSounds("misc/spawn_ground")
  self:PrecacheSounds({
    "impacts/gib_frozen1",
    "impacts/gib_frozen2",
    "impacts/gib_frozen3"
  })
  self:PrecacheSounds({
    "impacts/gib_big",
    "impacts/gib_big2",
    "impacts/gib_big3"
  })
  local temp
  temp = Templates["FlashScreen.CProcess"]
  temp = Templates["DemonFX.CProcess"]
  temp = Templates["DemonFXWarp.CProcess"]
  temp = Templates["EndLevel.CProcess"]
  temp = Templates["PMusicFade.CProcess"]
  temp = Templates["PFadeInOutLight.CProcess"]
  temp = Templates["TStomp.CProcess"]
  temp = Templates["TWait.CProcess"]
  PMENU.LoadingProgress()
  Cached = nil
  PMENU.LoadingProgress()
  if CacheLog then
    io.close(fLog)
  end
end
